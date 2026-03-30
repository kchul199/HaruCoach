import Foundation
import SwiftUI

// MARK: - Date Extensions

extension Date {
    /// 오늘 특정 시간의 Date 객체 생성
    static func today(hour: Int, minute: Int = 0) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
    }
    
    /// "HH:mm" 형식
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    /// "M월 d일 (E)" 형식
    var dateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"
        return formatter.string(from: self)
    }
    
    /// "yyyy년 M월 d일" 형식
    var fullDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: self)
    }
    
    /// 오늘인지 확인
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// 해당 날짜의 시작 (00:00)
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// 해당 날짜의 끝 (23:59:59)
    var endOfDay: Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self) ?? self
    }
    
    /// 시간만 추출 (0~23)
    var hour: Int {
        Calendar.current.component(.hour, from: self)
    }
    
    /// 분만 추출 (0~59)
    var minute: Int {
        Calendar.current.component(.minute, from: self)
    }
    
    /// 인사말 (시간대별)
    var greeting: String {
        switch hour {
        case 5..<12: return "좋은 아침이에요! ☀️"
        case 12..<14: return "점심시간이에요! 🍽️"
        case 14..<18: return "오후도 화이팅! 💪"
        case 18..<22: return "수고한 하루네요! 🌙"
        default: return "늦은 시간이네요! 🌃"
        }
    }
}

// MARK: - TimeInterval Extensions

extension TimeInterval {
    /// 분 단위로 변환
    var minutes: Int { Int(self / 60) }
    
    /// 시간 단위로 변환
    var hours: Double { self / 3600 }
    
    /// "1시간 30분" 형식
    var formatted: String {
        let h = Int(self) / 3600
        let m = (Int(self) % 3600) / 60
        if h > 0 && m > 0 { return "\(h)시간 \(m)분" }
        else if h > 0 { return "\(h)시간" }
        else { return "\(m)분" }
    }
}
