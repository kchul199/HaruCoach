import Foundation
import FirebaseAuth
import ComposableArchitecture

struct AuthClient {
    /// Firebase 인증 (Apple idToken 및 rawNonce 기반)
    var signInWithApple: @Sendable (String, String) async throws -> String
}

extension AuthClient: DependencyKey {
    static var liveValue: AuthClient {
        AuthClient(
            signInWithApple: { idToken, rawNonce in
                let credential = OAuthProvider.credential(
                    withProviderID: "apple.com",
                    idToken: idToken,
                    rawNonce: rawNonce
                )
                
                let authResult = try await Auth.auth().signIn(with: credential)
                return authResult.user.uid
            }
        )
    }
    
    static var testValue: AuthClient {
        AuthClient(
            signInWithApple: { _, _ in
                // 테스팅 용 Mock UID
                "mock_user_uid_12345"
            }
        )
    }
}

extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}
