import SwiftUI

// MARK: - HaruCoach 타이포그래피 시스템
/// SF Pro Display/Text 기반 (iOS 네이티브)
/// 한국어 최적화된 font weight와 line height

enum HCTypography {
    
    // MARK: - Display (대형 타이틀)
    static let displayLarge = Font.system(size: 34, weight: .bold, design: .rounded)
    static let displayMedium = Font.system(size: 28, weight: .bold, design: .rounded)
    static let displaySmall = Font.system(size: 24, weight: .semibold, design: .rounded)
    
    // MARK: - Headline
    static let headlineLarge = Font.system(size: 22, weight: .bold)
    static let headlineMedium = Font.system(size: 20, weight: .semibold)
    static let headlineSmall = Font.system(size: 18, weight: .semibold)
    
    // MARK: - Title
    static let titleLarge = Font.system(size: 17, weight: .semibold)
    static let titleMedium = Font.system(size: 16, weight: .medium)
    static let titleSmall = Font.system(size: 15, weight: .medium)
    
    // MARK: - Body
    static let bodyLarge = Font.system(size: 17, weight: .regular)
    static let bodyMedium = Font.system(size: 15, weight: .regular)
    static let bodySmall = Font.system(size: 14, weight: .regular)
    
    // MARK: - Label
    static let labelLarge = Font.system(size: 14, weight: .medium)
    static let labelMedium = Font.system(size: 12, weight: .medium)
    static let labelSmall = Font.system(size: 11, weight: .medium)
    
    // MARK: - Caption
    static let caption = Font.system(size: 12, weight: .regular)
    static let captionBold = Font.system(size: 12, weight: .semibold)
    
    // MARK: - Special
    static let timer = Font.system(size: 48, weight: .ultraLight, design: .rounded)
    static let percentage = Font.system(size: 36, weight: .bold, design: .rounded)
    static let emoji = Font.system(size: 32)
}

// MARK: - Text Style Modifier
struct HCTextStyle: ViewModifier {
    let font: Font
    let color: Color
    let lineSpacing: CGFloat
    
    init(font: Font, color: Color = HCColors.textPrimary, lineSpacing: CGFloat = 4) {
        self.font = font
        self.color = color
        self.lineSpacing = lineSpacing
    }
    
    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundStyle(color)
            .lineSpacing(lineSpacing)
    }
}

extension View {
    func hcTextStyle(_ font: Font, color: Color = HCColors.textPrimary) -> some View {
        modifier(HCTextStyle(font: font, color: color))
    }
}
