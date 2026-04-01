import SwiftUI

// MARK: - HaruCoach 컬러 시스템
/// 한국 직장인을 위한 차분하면서도 세련된 컬러 팔레트
/// 다크모드/라이트모드 모두 대응

enum HCColors {
    
    // MARK: - Primary (메인 브랜드 컬러 — 따뜻한 인디고)
    static let primary = Color(hex: "4F46E5")        // Indigo-600
    static let primaryLight = Color(hex: "818CF8")    // Indigo-400
    static let primaryDark = Color(hex: "3730A3")     // Indigo-800
    static let primarySoft = Color(hex: "EEF2FF")     // Indigo-50
    
    // MARK: - Secondary (보조 — 따뜻한 앰버)
    static let secondary = Color(hex: "F59E0B")       // Amber-500
    static let secondaryLight = Color(hex: "FCD34D")  // Amber-300
    static let secondaryDark = Color(hex: "D97706")   // Amber-600
    
    // MARK: - Accent (액센트 — 에메랄드)
    static let accent = Color(hex: "10B981")          // Emerald-500
    static let accentLight = Color(hex: "6EE7B7")     // Emerald-300
    static let accentDark = Color(hex: "059669")      // Emerald-600
    
    // MARK: - 카테고리 컬러
    static let categoryWork = Color(hex: "3B82F6")        // Blue — 업무
    static let categoryHealth = Color(hex: "EF4444")      // Red — 건강
    static let categoryGrowth = Color(hex: "8B5CF6")      // Violet — 자기계발
    static let categoryPersonal = Color(hex: "F97316")    // Orange — 개인
    
    // MARK: - 시맨틱 컬러
    static let success = Color(hex: "22C55E")         // Green-500
    static let warning = Color(hex: "EAB308")         // Yellow-500
    static let error = Color(hex: "EF4444")           // Red-500
    static let info = Color(hex: "3B82F6")            // Blue-500
    
    // MARK: - 배경 (다크모드 자동 대응 — UIColor 기반)
    static let background = Color(.systemGroupedBackground)
    static let surface = Color(.systemBackground)
    static let surfaceElevated = Color(.secondarySystemBackground)

    // MARK: - 텍스트 (다크모드 자동 대응)
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)
    static let textInverse = Color.white

    // MARK: - 기타 (다크모드 자동 대응)
    static let border = Color(.separator)
    static let divider = Color(.separator)
    static let shadow = Color.black.opacity(0.08)
    
    // MARK: - 그라디언트
    static let primaryGradient = LinearGradient(
        colors: [primary, Color(hex: "7C3AED")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let warmGradient = LinearGradient(
        colors: [Color(hex: "F59E0B"), Color(hex: "EF4444")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let coolGradient = LinearGradient(
        colors: [Color(hex: "06B6D4"), Color(hex: "3B82F6")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let splashGradient = LinearGradient(
        colors: [Color(hex: "312E81"), Color(hex: "4F46E5"), Color(hex: "7C3AED")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
