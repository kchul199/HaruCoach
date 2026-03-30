import Foundation

// MARK: - AI 서비스 프로토콜

/// AI 서비스의 핵심 인터페이스
/// Claude API, OpenAI, Mock 등 다양한 구현체를 교체 가능
protocol AIServiceProtocol {
    /// 자연어 입력을 스케줄로 변환
    func generateSchedule(from input: String, context: AIContext) async throws -> ScheduleResult
    
    /// 하루 리뷰 생성
    func generateReview(for tasks: [TaskData], context: AIContext) async throws -> ReviewResult
    
    /// 내일 일정 추천
    func generateSuggestion(history: [TaskData], context: AIContext) async throws -> [String]
}

// MARK: - AI Context (사용자 컨텍스트)

struct AIContext {
    let workStartTime: Date
    let workEndTime: Date
    let chronotype: String
    let aiPreference: String
    let correctionHistory: [CorrectionData]
    
    init(
        workStartTime: Date = Calendar.current.date(from: DateComponents(hour: 9))!,
        workEndTime: Date = Calendar.current.date(from: DateComponents(hour: 18))!,
        chronotype: String = "morning",
        aiPreference: String = "balanced",
        correctionHistory: [CorrectionData] = []
    ) {
        self.workStartTime = workStartTime
        self.workEndTime = workEndTime
        self.chronotype = chronotype
        self.aiPreference = aiPreference
        self.correctionHistory = correctionHistory
    }
}

// MARK: - 결과 모델

struct ScheduleResult {
    let tasks: [TaskData]
    let aiMessage: String // "이렇게 이해했어요"
    let confidence: Double // 0~1 AI 확신도
}

struct TaskData: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var category: String      // work, health, growth, personal
    var startTime: Date
    var duration: TimeInterval // 초 단위
    var isEdited: Bool
    
    init(
        id: String = UUID().uuidString,
        title: String,
        category: String = "personal",
        startTime: Date,
        duration: TimeInterval = 3600,
        isEdited: Bool = false
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.startTime = startTime
        self.duration = duration
        self.isEdited = isEdited
    }
    
    var endTime: Date {
        startTime.addingTimeInterval(duration)
    }
    
    var durationFormatted: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 && minutes > 0 { return "\(hours)시간 \(minutes)분" }
        else if hours > 0 { return "\(hours)시간" }
        else { return "\(minutes)분" }
    }
    
    var categoryEnum: TaskCategory {
        TaskCategory(rawValue: category) ?? .personal
    }
}

struct ReviewResult {
    let completionRate: Float
    let totalTasks: Int
    let completedTasks: Int
    let aiComment: String
    let tomorrowSuggestions: [String]
    let categoryMinutes: [String: Int]
}

struct CorrectionData: Codable {
    let originalAI: String
    let userEdit: String
    let inputContext: String
}

// MARK: - AI 에러

enum AIServiceError: LocalizedError {
    case networkError
    case invalidResponse
    case rateLimited
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError: return "네트워크 연결을 확인해주세요."
        case .invalidResponse: return "AI 응답을 처리할 수 없습니다."
        case .rateLimited: return "잠시 후 다시 시도해주세요."
        case .serverError(let msg): return "서버 오류: \(msg)"
        }
    }
}
