import Foundation
import SwiftData
import SwiftUI

// MARK: - 할 일 모델

@Model
final class HCTask {
    @Attribute(.unique) var id: String
    var title: String
    var category: TaskCategory
    var startTime: Date
    var duration: TimeInterval
    var status: TaskStatus
    var actualDuration: TimeInterval?
    var wasEdited: Bool
    var editDetails: String?
    var sortOrder: Int
    var createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        title: String,
        category: TaskCategory = .personal,
        startTime: Date,
        duration: TimeInterval = 3600,
        status: TaskStatus = .pending,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.startTime = startTime
        self.duration = duration
        self.status = status
        self.actualDuration = nil
        self.wasEdited = false
        self.editDetails = nil
        self.sortOrder = sortOrder
        self.createdAt = Date()
    }
    
    // MARK: - Computed Properties
    
    var endTime: Date {
        startTime.addingTimeInterval(duration)
    }
    
    var durationMinutes: Int {
        Int(duration / 60)
    }
    
    var durationFormatted: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)시간 \(minutes)분"
        } else if hours > 0 {
            return "\(hours)시간"
        } else {
            return "\(minutes)분"
        }
    }
    
    var timeRangeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: startTime))~\(formatter.string(from: endTime))"
    }
    
    var isCompleted: Bool {
        status == .completed
    }
    
    var isInProgress: Bool {
        status == .inProgress
    }
}

// MARK: - TaskCategory

enum TaskCategory: String, Codable, CaseIterable, Identifiable {
    case work = "work"
    case health = "health"
    case growth = "growth"
    case personal = "personal"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .work: return "업무"
        case .health: return "건강"
        case .growth: return "자기계발"
        case .personal: return "개인"
        }
    }
    
    var emoji: String {
        switch self {
        case .work: return "💼"
        case .health: return "💪"
        case .growth: return "📚"
        case .personal: return "🎯"
        }
    }
    
    var color: SwiftUI.Color {
        switch self {
        case .work: return HCColors.categoryWork
        case .health: return HCColors.categoryHealth
        case .growth: return HCColors.categoryGrowth
        case .personal: return HCColors.categoryPersonal
        }
    }
}

// MARK: - TaskStatus

enum TaskStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case inProgress = "inProgress"
    case completed = "completed"
    case skipped = "skipped"
    
    var displayName: String {
        switch self {
        case .pending: return "대기"
        case .inProgress: return "진행 중"
        case .completed: return "완료"
        case .skipped: return "건너뜀"
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "circle"
        case .inProgress: return "play.circle.fill"
        case .completed: return "checkmark.circle.fill"
        case .skipped: return "forward.circle.fill"
        }
    }
}
