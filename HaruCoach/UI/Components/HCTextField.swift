import SwiftUI

// MARK: - 자연어 입력 필드

struct HCTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String?
    let isMultiline: Bool
    let onSubmit: (() -> Void)?
    
    @FocusState private var isFocused: Bool
    
    init(
        text: Binding<String>,
        placeholder: String = "오늘 할 일을 말해보세요...",
        icon: String? = "sparkles",
        isMultiline: Bool = true,
        onSubmit: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.icon = icon
        self.isMultiline = isMultiline
        self.onSubmit = onSubmit
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: isMultiline ? .top : .center, spacing: HCSpacing.sm) {
                // 아이콘
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(
                            isFocused ? HCColors.primary : HCColors.textTertiary
                        )
                        .animation(HCAnimation.quick, value: isFocused)
                        .padding(.top, isMultiline ? 4 : 0)
                }
                
                // 입력 필드
                if isMultiline {
                    ZStack(alignment: .topLeading) {
                        if text.isEmpty {
                            Text(placeholder)
                                .font(HCTypography.bodyLarge)
                                .foregroundStyle(HCColors.textTertiary)
                                .padding(.top, 4)
                        }
                        
                        TextEditor(text: $text)
                            .font(HCTypography.bodyLarge)
                            .foregroundStyle(HCColors.textPrimary)
                            .scrollContentBackground(.hidden)
                            .focused($isFocused)
                            .frame(minHeight: 60, maxHeight: 120)
                    }
                } else {
                    TextField(placeholder, text: $text)
                        .font(HCTypography.bodyLarge)
                        .foregroundStyle(HCColors.textPrimary)
                        .focused($isFocused)
                        .onSubmit { onSubmit?() }
                }
                
                // 전송 버튼
                if !text.isEmpty {
                    Button {
                        onSubmit?()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(HCColors.primary)
                            .symbolRenderingMode(.hierarchical)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(HCSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: HCRadius.xl)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: HCRadius.xl)
                            .stroke(
                                isFocused ? HCColors.primary.opacity(0.5) : Color.clear,
                                lineWidth: 1.5
                            )
                    )
                    .shadow(
                        color: isFocused ? HCColors.primary.opacity(0.1) : HCColors.shadow,
                        radius: isFocused ? 12 : 6,
                        x: 0,
                        y: isFocused ? 6 : 3
                    )
            )
            .animation(HCAnimation.standard, value: isFocused)
            .animation(HCAnimation.standard, value: text.isEmpty)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HCTextField(
            text: .constant(""),
            placeholder: "오늘 할 일을 말해보세요..."
        )
        
        HCTextField(
            text: .constant("오전에 기획서 마무리하고, 점심 후에 팀 미팅 1시간"),
            placeholder: "오늘 할 일을 말해보세요..."
        )
    }
    .padding()
}
