import Foundation
import SwiftData

// MARK: - 일일 계획 모델

@Model
final class DailyPlan {
    @Attribute(.unique) var id: String
    var userId: String
    var date: Date
    var rawInput: String
    var aiInterpretation: String
    var completionRate: Float
    var promptVersion: String
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(deleteRule: .cascade) var tasks: [HCTask]
    var review: DailyReview?
    
    init(
        id: String = UUID().uuidString,
        userId: String = "",
        date: Date = Date(),
        rawInput: String = "",
        aiInterpretation: String = ""
    ) {
        self.id = id
        self.userId = userId
        self.date = date
        self.rawInput = rawInput
        self.aiInterpretation = aiInterpretation
        self.completionRate = 0.0
        self.promptVersion = "1.0"
        self.createdAt = Date()
        self.updatedAt = Date()
        self.tasks = []
        self.review = nil
    }
    
    // MARK: - Computed Properties
    
    var completedTaskCount: Int {
        tasks.filter { $0.status == .completed }.count
    }
    
    var totalTaskCount: Int {
        tasks.count
    }
    
    var calculatedCompletionRate: Float {
        guard totalTaskCount > 0 else { return 0 }
        return Float(completedTaskCount) / Float(totalTaskCount)
    }
    
    var sortedTasks: [HCTask] {
        tasks.sorted { $0.startTime < $1.startTime }
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}
