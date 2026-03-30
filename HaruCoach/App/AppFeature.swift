import Foundation
import ComposableArchitecture

// MARK: - 앱 루트 Feature

@Reducer
struct AppFeature {
    
    @ObservableState
    struct State: Equatable {
        var isOnboardingCompleted: Bool = false
        var selectedTab: Tab = .home
        var onboarding = OnboardingFeature.State()
        var home = HomeFeature.State()
        var review = ReviewFeature.State()
        var settings = SettingsFeature.State()
    }
    
    enum Tab: String, CaseIterable, Equatable {
        case home = "home"
        case review = "review"
        case settings = "settings"
        
        var title: String {
            switch self {
            case .home: return "오늘"
            case .review: return "리뷰"
            case .settings: return "설정"
            }
        }
        
        var icon: String {
            switch self {
            case .home: return "calendar"
            case .review: return "chart.bar.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    enum Action: Equatable {
        case selectTab(Tab)
        case completeOnboarding
        case onboarding(OnboardingFeature.Action)
        case home(HomeFeature.Action)
        case review(ReviewFeature.Action)
        case settings(SettingsFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.onboarding, action: \.onboarding) {
            OnboardingFeature()
        }
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
        Scope(state: \.review, action: \.review) {
            ReviewFeature()
        }
        Scope(state: \.settings, action: \.settings) {
            SettingsFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .selectTab(let tab):
                state.selectedTab = tab
                return .none
                
            case .completeOnboarding:
                state.isOnboardingCompleted = true
                // 첫 입력이 있으면 홈에 전달
                if !state.onboarding.firstInput.isEmpty {
                    state.home.inputText = state.onboarding.firstInput
                }
                return .run { _ in
                    await NotificationManager.shared.requestAuthorization()
                }
                
            case .onboarding(.completeOnboarding):
                return .send(.completeOnboarding)
                
            case .onboarding:
                return .none
            case .home:
                return .none
            case .review:
                return .none
            case .settings:
                return .none
            }
        }
    }
}
