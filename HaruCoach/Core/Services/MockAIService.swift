import Foundation

// MARK: - Mock AI 서비스
/// Firebase/AI API 없이 앱을 독립 실행할 수 있는 Mock 서비스
/// 개발 및 테스트 단계에서 사용

final class MockAIService: AIServiceProtocol {
    
    // 시뮬레이션 딜레이 (실제 API 응답 시간 흉내)
    private let simulatedDelay: TimeInterval = 1.5
    
    // MARK: - 스케줄 생성
    
    func generateSchedule(from input: String, context: AIContext) async throws -> ScheduleResult {
        // API 호출 시뮬레이션
        try await Task.sleep(nanoseconds: UInt64(simulatedDelay * 1_000_000_000))
        
        let tasks = parseInput(input, context: context)
        
        return ScheduleResult(
            tasks: tasks,
            aiMessage: generateAIMessage(for: tasks),
            confidence: 0.85
        )
    }
    
    // MARK: - 리뷰 생성
    
    func generateReview(for tasks: [TaskData], context: AIContext) async throws -> ReviewResult {
        try await Task.sleep(nanoseconds: UInt64(simulatedDelay * 1_000_000_000))
        
        // Mock: 약 70% 완료율 시뮬레이션 (다양한 리뷰 UI 테스트 가능)
        let completed = tasks.filter { _ in Double.random(in: 0...1) < 0.7 }
        let completionRate = Float(completed.count) / Float(max(tasks.count, 1))
        
        let comments = [
            "오전에 집중력이 좋았네요! 기획서를 예상보다 빨리 끝냈어요 👏",
            "오늘 하루 알차게 보내셨네요! 특히 건강 관리에 시간을 투자한 게 좋았어요 💪",
            "업무에 집중하느라 고생했어요. 내일은 자기계발 시간을 좀 더 넣어볼까요? 📚",
            "꾸준히 달성률이 높아지고 있어요! 이 페이스를 유지해봐요 🔥",
            "오늘은 좀 빡빡했죠? 내일은 여유 시간을 좀 더 넣어볼게요 🌿"
        ]
        
        let suggestions = [
            "오늘 못한 영어 공부, 내일 오전 8시에 넣어볼까요?",
            "이번 주 운동을 3회 이상 하면 건강 목표 달성이에요!",
            "내일 팀 미팅 전에 30분 준비 시간을 넣어둘게요."
        ]
        
        return ReviewResult(
            completionRate: completionRate,
            totalTasks: tasks.count,
            completedTasks: completed.count,
            aiComment: comments.randomElement()!,
            tomorrowSuggestions: Array(suggestions.prefix(2)),
            categoryMinutes: [
                "work": 240,
                "health": 30,
                "growth": 60,
                "personal": 30
            ]
        )
    }
    
    // MARK: - 내일 추천
    
    func generateSuggestion(history: [TaskData], context: AIContext) async throws -> [String] {
        try await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000))
        
        return [
            "어제와 비슷한 일정으로 시작해볼까요?",
            "오전에 집중 업무 2시간 + 오후 미팅",
            "저녁에 30분 운동 추가하면 좋겠어요!"
        ]
    }
    
    // MARK: - 입력 파싱 (Mock 로직)
    
    private func parseInput(_ input: String, context: AIContext) -> [TaskData] {
        var tasks: [TaskData] = []
        let calendar = Calendar.current
        let today = Date()
        
        // 키워드 기반 간단한 파싱
        let keywords: [(keywords: [String], title: String, category: String, duration: TimeInterval)] = [
            (["기획서", "보고서", "문서", "작성"], "기획서 마무리", "work", 7200),
            (["미팅", "회의", "팀"], "팀 미팅", "work", 3600),
            (["러닝", "운동", "조깅", "헬스"], "러닝", "health", 1800),
            (["영어", "공부", "스터디", "독서"], "영어 공부", "growth", 3600),
            (["점심", "밥", "식사"], "점심 식사", "personal", 3600),
            (["코딩", "개발", "프로그래밍"], "코딩", "work", 7200),
            (["이메일", "메일"], "이메일 처리", "work", 1800),
        ]
        
        var baseHour = 9 // 오전 9시 시작
        
        for keywordSet in keywords {
            if keywordSet.keywords.contains(where: { input.contains($0) }) {
                if let startTime = calendar.date(bySettingHour: baseHour, minute: 0, second: 0, of: today) {
                    tasks.append(TaskData(
                        title: keywordSet.title,
                        category: keywordSet.category,
                        startTime: startTime,
                        duration: keywordSet.duration
                    ))
                    baseHour += Int(keywordSet.duration / 3600) + (keywordSet.duration.truncatingRemainder(dividingBy: 3600) > 0 ? 1 : 0)
                    // 점심시간 건너뛰기
                    if baseHour == 12 { baseHour = 13 }
                }
            }
        }
        
        // 매칭되는 키워드가 없으면 기본 스케줄 제공
        if tasks.isEmpty {
            tasks = generateDefaultSchedule(for: today)
        }
        
        return tasks
    }
    
    private func generateDefaultSchedule(for date: Date) -> [TaskData] {
        let calendar = Calendar.current
        return [
            TaskData(
                title: "기획서 마무리",
                category: "work",
                startTime: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: date)!,
                duration: 7200
            ),
            TaskData(
                title: "팀 미팅",
                category: "work",
                startTime: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: date)!,
                duration: 3600
            ),
            TaskData(
                title: "러닝",
                category: "health",
                startTime: calendar.date(bySettingHour: 18, minute: 30, second: 0, of: date)!,
                duration: 1800
            ),
            TaskData(
                title: "영어 공부",
                category: "growth",
                startTime: calendar.date(bySettingHour: 21, minute: 0, second: 0, of: date)!,
                duration: 3600
            )
        ]
    }
    
    private func generateAIMessage(for tasks: [TaskData]) -> String {
        let count = tasks.count
        let totalHours = tasks.reduce(0) { $0 + $1.duration } / 3600
        
        let messages = [
            "오늘 \(count)개의 일정을 \(Int(totalHours))시간으로 정리했어요! 집중 업무는 오전에, 가벼운 활동은 저녁에 배치했습니다.",
            "\(count)가지 할 일을 시간대별로 배치했어요. 점심시간은 보호해뒀어요 🍽️",
            "알찬 하루가 될 것 같아요! \(count)개 일정, 총 \(Int(totalHours))시간이에요."
        ]
        
        return messages.randomElement() ?? "오늘도 힘차게 시작해봐요! 🚀"
    }
}
