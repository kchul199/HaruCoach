import Foundation
import SwiftData

// MARK: - 하루 리뷰 모델

@Model
final class DailyReview {
    @Attribute(.unique) var id: String
    var completionRate: Float
    var totalTasks: Int
    var completedTasks: Int
    var aiComment: String
    var tomorrowSuggestions: [String]
    var streak: Int
    var shareCardImageURL: String?
    var createdAt: Date
    
    // 카테고리별 시간 분석
    var workMinutes: Int
    var healthMinutes: Int
    var growthMinutes: Int
    var personalMinutes: Int
    
    init(
        id: String = UUID().uuidString,
        completionRate: Float = 0,
        totalTasks: Int = 0,
        completedTasks: Int = 0,
        aiComment: String = "",
        tomorrowSuggestions: [String] = [],
        streak: Int = 0,
        workMinutes: Int = 0,
        healthMinutes: Int = 0,
        growthMinutes: Int = 0,
        personalMinutes: Int = 0
    ) {
        self.id = id
        self.completionRate = completionRate
        self.totalTasks = totalTasks
        self.completedTasks = completedTasks
        self.aiComment = aiComment
        self.tomorrowSuggestions = tomorrowSuggestions
        self.streak = streak
        self.shareCardImageURL = nil
        self.createdAt = Date()
        self.workMinutes = workMinutes
        self.healthMinutes = healthMinutes
        self.growthMinutes = growthMinutes
        self.personalMinutes = personalMinutes
    }
    
    // MARK: - Computed
    
    var completionPercentage: Int {
        Int(completionRate * 100)
    }
    
    var totalMinutes: Int {
        workMinutes + healthMinutes + growthMinutes + personalMinutes
    }
    
    var categoryBreakdown: [(category: TaskCategory, minutes: Int, percentage: Double)] {
        let total = Double(max(totalMinutes, 1))
        return [
            (.work, workMinutes, Double(workMinutes) / total * 100),
            (.health, healthMinutes, Double(healthMinutes) / total * 100),
            (.growth, growthMinutes, Double(growthMinutes) / total * 100),
            (.personal, personalMinutes, Double(personalMinutes) / total * 100)
        ].filter { $0.minutes > 0 }
    }
    
    var summaryText: String {
        "오늘 \(totalTasks)개 중 \(completedTasks)개 완료! 달성률 \(completionPercentage)%"
    }
}
