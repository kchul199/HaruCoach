import Foundation
import UserNotifications

// MARK: - 알림 관리자

final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    private init() {}
    
    // MARK: - 권한 요청
    
    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            await MainActor.run {
                isAuthorized = granted
            }
        } catch {
            print("알림 권한 요청 실패: \(error)")
        }
    }
    
    // MARK: - 다음 일정 알림 (5분 전)
    
    func scheduleTaskReminder(taskId: String, title: String, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "⏰ 다음 일정"
        content.body = "\(title) 시작 5분 전이에요"
        content.sound = .default
        content.categoryIdentifier = "TASK_REMINDER"
        
        let reminderDate = date.addingTimeInterval(-5 * 60) // 5분 전
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "task_\(taskId)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - 저녁 리뷰 알림
    
    func scheduleEveningReview(at hour: Int = 21) {
        let content = UNMutableNotificationContent()
        content.title = "🌙 오늘 하루 어땠나요?"
        content.body = "하루 리뷰를 확인해보세요"
        content.sound = .default
        content.categoryIdentifier = "EVENING_REVIEW"
        
        var components = DateComponents()
        components.hour = hour
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "evening_review",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - 알림 제거
    
    func removeAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func removeNotification(for taskId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["task_\(taskId)"]
        )
    }
}
