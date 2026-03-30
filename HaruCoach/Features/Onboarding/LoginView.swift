import SwiftUI
import ComposableArchitecture

// MARK: - 애플 로그인 화면 (온보딩)

struct LoginView: View {
    @Bindable var store: StoreOf<OnboardingFeature>
    
    var body: some View {
        VStack(spacing: HCSpacing.xxl) {
            Spacer()
            
            // 타이틀
            VStack(spacing: HCSpacing.md) {
                ZStack {
                    Circle()
                        .fill(HCColors.primary.opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(HCColors.primary)
                }
                
                VStack(spacing: HCSpacing.xs) {
                    Text("시작하기")
                        .font(HCTypography.displaySmall)
                        .foregroundStyle(HCColors.textPrimary)
                    
                    Text("안전하게 로그인하고 하루코치를 시작하세요")
                        .font(HCTypography.bodyMedium)
                        .foregroundStyle(HCColors.textSecondary)
                }
            }
            
            Spacer()
            
            // 로그인 버튼 (Mock)
            VStack(spacing: HCSpacing.md) {
                // SwiftUI 내장 SignInWithAppleButton 대신 Mock 커스텀 버튼 사용
                AppleLoginButton {
                    // 로그인 성공 트리거 -> 다음 페이지 (첫 스케줄)
                    store.send(.nextPage)
                }
                .shadow(color: HCColors.shadow, radius: 4, y: 2)
                
                Button("나중에 하기") {
                    store.send(.nextPage)
                }
                .font(HCTypography.bodyMedium)
                .foregroundStyle(HCColors.textTertiary)
            }
            .padding(.horizontal, HCSpacing.xl)
            .padding(.bottom, HCSpacing.xxxl)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

#Preview {
    LoginView(
        store: Store(initialState: OnboardingFeature.State()) {
            OnboardingFeature()
        }
    )
}
