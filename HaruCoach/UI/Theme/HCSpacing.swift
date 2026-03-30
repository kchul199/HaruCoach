import SwiftUI

// MARK: - HaruCoach 간격 시스템
/// 4px 기반 간격 시스템

enum HCSpacing {
    /// 2pt
    static let xxxs: CGFloat = 2
    /// 4pt
    static let xxs: CGFloat = 4
    /// 8pt
    static let xs: CGFloat = 8
    /// 12pt
    static let sm: CGFloat = 12
    /// 16pt
    static let md: CGFloat = 16
    /// 20pt
    static let lg: CGFloat = 20
    /// 24pt
    static let xl: CGFloat = 24
    /// 32pt
    static let xxl: CGFloat = 32
    /// 40pt
    static let xxxl: CGFloat = 40
    /// 48pt
    static let huge: CGFloat = 48
    /// 64pt
    static let massive: CGFloat = 64
}

// MARK: - Corner Radius
enum HCRadius {
    /// 4pt
    static let xs: CGFloat = 4
    /// 8pt
    static let sm: CGFloat = 8
    /// 12pt
    static let md: CGFloat = 12
    /// 16pt
    static let lg: CGFloat = 16
    /// 20pt
    static let xl: CGFloat = 20
    /// 24pt
    static let xxl: CGFloat = 24
    /// Full circle
    static let full: CGFloat = 999
}

// MARK: - Padding Shortcut
extension View {
    func hcPadding(_ edges: Edge.Set = .all, _ size: CGFloat = HCSpacing.md) -> some View {
        padding(edges, size)
    }
    
    func hcCardPadding() -> some View {
        padding(.horizontal, HCSpacing.md)
            .padding(.vertical, HCSpacing.sm)
    }
    
    func hcScreenPadding() -> some View {
        padding(.horizontal, HCSpacing.lg)
    }
}
