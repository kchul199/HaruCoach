import SwiftUI
import ComposableArchitecture
import AuthenticationServices

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
            
            // 로그인 버튼
            VStack(spacing: HCSpacing.md) {
                if store.isAuthenticating {
                    ProgressView("안전하게 로그인 중...")
                } else {
                    SignInWithAppleButton(
                        .signIn,
                        onRequest: { request in
                            let nonce = AppleAuthHelper.randomNonceString()
                            store.send(.setNonce(nonce))
                            request.requestedScopes = [.fullName, .email]
                            request.nonce = AppleAuthHelper.sha256(nonce)
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authorization):
                                if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                                    guard !store.currentNonce.isEmpty else {
                                        store.send(.authenticationFailure("세션이 만료되었습니다. 다시 시도해주세요."))
                                        return
                                    }
                                    guard let appleIDToken = appleIDCredential.identityToken,
                                          let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                                        store.send(.authenticationFailure("Apple 인증 토큰을 읽을 수 없습니다."))
                                        return
                                    }
                                    // Firebase 연동을 위해 Token과 원본 Nonce값 전달
                                    store.send(.appleLoginResult(idTokenString, store.currentNonce))
                                }
                            case .failure(let error):
                                if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                                    store.send(.authenticationFailure(error.localizedDescription))
                                }
                            }
                        }
                    )
                    .frame(height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: HCRadius.lg))
                    .shadow(color: HCColors.shadow, radius: 4, y: 2)
                    
                    if let error = store.authenticationError {
                        Text(error)
                            .font(HCTypography.labelSmall)
                            .foregroundStyle(HCColors.error)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button("나중에 하기") {
                        store.send(.nextPage)
                    }
                    .font(HCTypography.bodyMedium)
                    .foregroundStyle(HCColors.textTertiary)
                }
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
