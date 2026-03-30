import Foundation
import SwiftData

// MARK: - 사용자 모델

@Model
final class User {
    @Attribute(.unique) var uid: String
    var displayName: String
    var workStartTime: Date
    var workEndTime: Date
    var chronotype: Chronotype
    var aiPreference: AIPreference
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(deleteRule: .cascade) var corrections: [Correction]
    @Relationship(deleteRule: .cascade) var dailyPlans: [DailyPlan]
    
    init(
        uid: String = UUID().uuidString,
        displayName: String = "",
        workStartTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0))!,
        workEndTime: Date = Calendar.current.date(from: DateComponents(hour: 18, minute: 0))!,
        chronotype: Chronotype = .morning,
        aiPreference: AIPreference = .balanced
    ) {
        self.uid = uid
        self.displayName = displayName
        self.workStartTime = workStartTime
        self.workEndTime = workEndTime
        self.chronotype = chronotype
        self.aiPreference = aiPreference
        self.createdAt = Date()
        self.updatedAt = Date()
        self.corrections = []
        self.dailyPlans = []
    }
}

// MARK: - Enums

enum Chronotype: String, Codable, CaseIterable {
    case morning = "morning"
    case evening = "evening"
    
    var displayName: String {
        switch self {
        case .morning: return "아침형"
        case .evening: return "저녁형"
        }
    }
    
    var emoji: String {
        switch self {
        case .morning: return "🌅"
        case .evening: return "🌙"
        }
    }
}

enum AIPreference: String, Codable, CaseIterable {
    case strict = "strict"
    case balanced = "balanced"
    case relaxed = "relaxed"
    
    var displayName: String {
        switch self {
        case .strict: return "빡빡하게"
        case .balanced: return "균형잡힌"
        case .relaxed: return "여유롭게"
        }
    }
    
    var emoji: String {
        switch self {
        case .strict: return "🔥"
        case .balanced: return "⚖️"
        case .relaxed: return "🌿"
        }
    }
}
