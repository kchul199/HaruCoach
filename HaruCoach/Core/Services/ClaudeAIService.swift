import Foundation

// MARK: - Claude AI 서비스
/// Anthropic Claude API를 사용하는 실제 AI 서비스 구현체
/// APIConfig.claudeAPIKey가 설정되어 있을 때 AIServiceKey.liveValue에서 자동 선택됩니다.

final class ClaudeAIService: AIServiceProtocol {

    private let apiKey: String
    private let baseURL = URL(string: "https://api.anthropic.com/v1/messages")!
    private let anthropicVersion = "2023-06-01"

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    // MARK: - AIServiceProtocol

    func generateSchedule(from input: String, context: AIContext) async throws -> ScheduleResult {
        let prompt = PromptManager.shared.schedulePrompt(input: input, context: context)
        let responseText = try await sendMessage(
            prompt,
            maxTokens: APIConfig.scheduleMaxTokens
        )
        let tasks = try parseScheduleTasks(from: responseText)
        return ScheduleResult(
            tasks: tasks,
            aiMessage: makeConfirmationMessage(tasks: tasks),
            confidence: 0.9
        )
    }

    func generateReview(for tasks: [TaskData], context: AIContext) async throws -> ReviewResult {
        let prompt = PromptManager.shared.reviewPrompt(tasks: tasks, context: context)
        let responseText = try await sendMessage(
            prompt,
            maxTokens: APIConfig.reviewMaxTokens
        )
        return buildReviewResult(from: responseText, tasks: tasks)
    }

    func generateSuggestion(history: [TaskData], context: AIContext) async throws -> [String] {
        guard !history.isEmpty else {
            return ["오늘도 멋진 하루 계획을 세워보세요! ✨"]
        }
        // 비용 절감: 간단한 추천은 로컬에서 생성
        return localSuggestions(from: history)
    }

    // MARK: - Claude API 호출

    private func sendMessage(_ userMessage: String, maxTokens: Int) async throws -> String {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue(anthropicVersion, forHTTPHeaderField: "anthropic-version")
        request.timeoutInterval = 30

        let body: [String: Any] = [
            "model": APIConfig.defaultModel,
            "max_tokens": maxTokens,
            "messages": [
                ["role": "user", "content": userMessage]
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.networkError
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 429:
            throw AIServiceError.rateLimited
        case 401:
            throw AIServiceError.serverError("API 키가 올바르지 않습니다. APIKeys.plist를 확인해주세요.")
        case 400...499:
            let msg = String(data: data, encoding: .utf8) ?? "클라이언트 오류"
            throw AIServiceError.serverError("요청 오류 (\(httpResponse.statusCode)): \(msg)")
        default:
            throw AIServiceError.serverError("서버 오류 HTTP \(httpResponse.statusCode)")
        }

        let decoded = try JSONDecoder().decode(ClaudeAPIResponse.self, from: data)
        return decoded.content.first?.text ?? ""
    }

    // MARK: - 스케줄 파싱

    /// Claude 응답에서 JSON 배열을 추출하여 TaskData 배열로 변환
    private func parseScheduleTasks(from text: String) throws -> [TaskData] {
        // 응답 텍스트에서 JSON 배열 추출 (마크다운 코드블록 포함 대응)
        let jsonText: String
        if let jsonStart = text.firstIndex(of: "["),
           let jsonEnd = text.lastIndex(of: "]") {
            jsonText = String(text[jsonStart...jsonEnd])
        } else {
            throw AIServiceError.invalidResponse
        }

        guard let jsonData = jsonText.data(using: .utf8) else {
            throw AIServiceError.invalidResponse
        }

        let rawTasks: [RawTaskResponse]
        do {
            rawTasks = try JSONDecoder().decode([RawTaskResponse].self, from: jsonData)
        } catch {
            throw AIServiceError.invalidResponse
        }

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.locale = Locale(identifier: "ko_KR")

        let calendar = Calendar.current
        let today = Date()

        return rawTasks.compactMap { raw in
            guard let timeDate = timeFormatter.date(from: raw.startTime) else { return nil }
            let hour = calendar.component(.hour, from: timeDate)
            let minute = calendar.component(.minute, from: timeDate)
            guard let startTime = calendar.date(
                bySettingHour: hour, minute: minute, second: 0, of: today
            ) else { return nil }

            let validCategory = TaskCategory(rawValue: raw.category) != nil
                ? raw.category
                : "personal"

            return TaskData(
                title: raw.title,
                category: validCategory,
                startTime: startTime,
                duration: TimeInterval(raw.duration * 60)
            )
        }
    }

    // MARK: - 리뷰 파싱

    private func buildReviewResult(from text: String, tasks: [TaskData]) -> ReviewResult {
        let lines = text
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        // 첫 줄 또는 첫 문장을 AI 코멘트로 사용
        let aiComment = lines.first ?? text

        // 숫자나 대시로 시작하는 줄을 제안으로 추출
        let suggestions = lines
            .dropFirst()
            .filter { line in
                line.first?.isNumber == true || line.hasPrefix("-") || line.hasPrefix("•")
            }
            .map { $0
                .replacingOccurrences(of: "^[0-9]+[.)\\s]+", with: "", options: .regularExpression)
                .replacingOccurrences(of: "^[-•]\\s*", with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespaces)
            }
            .filter { !$0.isEmpty }

        let categoryMinutes = tasks.reduce(into: [String: Int]()) { acc, task in
            acc[task.category, default: 0] += Int(task.duration / 60)
        }

        return ReviewResult(
            completionRate: 0, // HomeFeature의 completedTaskIds로 별도 계산
            totalTasks: tasks.count,
            completedTasks: 0,
            aiComment: aiComment,
            tomorrowSuggestions: Array(suggestions.prefix(3)),
            categoryMinutes: categoryMinutes
        )
    }

    // MARK: - 로컬 제안 (비용 절감)

    private func localSuggestions(from history: [TaskData]) -> [String] {
        var suggestions: [String] = []

        let hasWork = history.contains { $0.category == "work" }
        let hasHealth = history.contains { $0.category == "health" }
        let hasGrowth = history.contains { $0.category == "growth" }

        if hasWork { suggestions.append("오늘도 업무에 집중하는 시간을 넣어볼까요? 💼") }
        if !hasHealth { suggestions.append("오늘은 운동 30분을 추가해보세요! 💪") }
        if !hasGrowth { suggestions.append("자기계발 시간도 챙겨보아요 📚") }

        return suggestions.isEmpty
            ? ["어제와 비슷한 일정으로 시작해볼까요? ✨"]
            : suggestions
    }

    // MARK: - 헬퍼

    private func makeConfirmationMessage(tasks: [TaskData]) -> String {
        let totalMinutes = Int(tasks.reduce(0) { $0 + $1.duration } / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        let durationText = hours > 0
            ? (minutes > 0 ? "\(hours)시간 \(minutes)분" : "\(hours)시간")
            : "\(minutes)분"
        return "\(tasks.count)개 일정을 \(durationText)으로 정리했어요! 집중 업무는 오전에 배치했습니다 ✨"
    }
}

// MARK: - 응답 모델 (private)

private struct ClaudeAPIResponse: Decodable {
    let content: [ContentBlock]

    struct ContentBlock: Decodable {
        let type: String
        let text: String
    }
}

private struct RawTaskResponse: Decodable {
    let title: String
    let category: String
    let startTime: String   // "HH:mm" 형식
    let duration: Int       // 분 단위
}
