import SwiftUI
import AuthenticationServices

// MARK: - Mock Apple 로그인 버튼

struct AppleLoginButton: View {
    let onLogin: () -> Void
    
    var body: some View {
        Button(action: {
            // Mock Login Action
            onLogin()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "applelogo")
                    .font(.system(size: 20))
                Text("Apple ID로 계속하기")
                    .font(HCTypography.titleMedium)
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: HCRadius.lg))
        }
        .pressEffect()
    }
}
