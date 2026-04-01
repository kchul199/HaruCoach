import Foundation

// MARK: - API 키 설정
/// APIKeys.plist 파일에서 Claude API 키를 읽어옵니다.
/// APIKeys.plist가 없거나 키가 비어있으면 MockAIService를 자동으로 사용합니다.
///
/// 사용 방법:
///   1. HaruCoach/Resources/APIKeys.plist 파일 열기
///   2. ClaudeAPIKey 항목에 본인의 Claude API 키 입력
///   3. 빌드 & 실행

enum APIConfig {

    // MARK: - Claude API

    /// Claude API 키 (APIKeys.plist에서 로드)
    static var claudeAPIKey: String {
        guard
            let url = Bundle.main.url(forResource: "APIKeys", withExtension: "plist"),
            let dict = NSDictionary(contentsOf: url),
            let key = dict["ClaudeAPIKey"] as? String,
            !key.isEmpty,
            key != "YOUR_CLAUDE_API_KEY_HERE"
        else {
            return ""
        }
        return key
    }

    /// API 키가 없으면 MockAIService를 사용
    static var useMockAI: Bool {
        claudeAPIKey.isEmpty
    }

    // MARK: - 모델 설정

    /// 비용 효율적인 기본 모델 (스케줄 생성·리뷰)
    static let defaultModel = "claude-haiku-4-5-20251001"

    /// Pro 사용자용 고품질 모델 (향후 Freemium 전환 시 활용)
    static let premiumModel = "claude-sonnet-4-6"

    // MARK: - 요청 한도

    /// 스케줄 생성 1회당 최대 토큰
    static let scheduleMaxTokens = 1024

    /// 리뷰 생성 1회당 최대 토큰
    static let reviewMaxTokens = 512
}
