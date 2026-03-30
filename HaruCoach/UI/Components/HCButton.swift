import SwiftUI

// MARK: - HaruCoach 커스텀 버튼

struct HCButton: View {
    let title: String
    let style: ButtonStyle
    let icon: String?
    let isLoading: Bool
    let action: () -> Void
    
    enum ButtonStyle {
        case primary
        case secondary
        case outline
        case ghost
        case destructive
    }
    
    init(
        _ title: String,
        style: ButtonStyle = .primary,
        icon: String? = nil,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.icon = icon
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: HCSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                        .scaleEffect(0.8)
                } else if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(title)
                    .font(HCTypography.titleMedium)
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: HCRadius.lg))
            .overlay(border)
        }
        .disabled(isLoading)
        .pressEffect()
    }
    
    // MARK: - Style Properties
    
    private var foregroundColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return HCColors.primary
        case .outline: return HCColors.primary
        case .ghost: return HCColors.textPrimary
        case .destructive: return .white
        }
    }
    
    @ViewBuilder
    private var background: some View {
        switch style {
        case .primary:
            HCColors.primaryGradient
        case .secondary:
            HCColors.primary.opacity(0.1)
        case .outline:
            Color.clear
        case .ghost:
            Color.clear
        case .destructive:
            HCColors.error
        }
    }
    
    @ViewBuilder
    private var border: some View {
        switch style {
        case .outline:
            RoundedRectangle(cornerRadius: HCRadius.lg)
                .stroke(HCColors.primary, lineWidth: 1.5)
        default:
            EmptyView()
        }
    }
}

// MARK: - 소형 버튼

struct HCSmallButton: View {
    let title: String
    let icon: String?
    let color: Color
    let action: () -> Void
    
    init(_ title: String, icon: String? = nil, color: Color = HCColors.primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .semibold))
                }
                Text(title)
                    .font(HCTypography.labelMedium)
            }
            .foregroundStyle(color)
            .padding(.horizontal, HCSpacing.sm)
            .padding(.vertical, HCSpacing.xxs)
            .background(color.opacity(0.1))
            .clipShape(Capsule())
        }
        .pressEffect()
    }
}

#Preview {
    VStack(spacing: 16) {
        HCButton("확정하기", style: .primary, icon: "checkmark") {}
        HCButton("수정하기", style: .secondary, icon: "pencil") {}
        HCButton("건너뛰기", style: .outline) {}
        HCButton("로딩 중...", isLoading: true) {}
        
        HStack(spacing: 12) {
            HCSmallButton("업무", icon: "briefcase", color: HCColors.categoryWork) {}
            HCSmallButton("건강", icon: "heart", color: HCColors.categoryHealth) {}
            HCSmallButton("자기계발", icon: "book", color: HCColors.categoryGrowth) {}
        }
    }
    .padding()
}
