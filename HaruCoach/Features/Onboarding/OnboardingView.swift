import SwiftUI
import ComposableArchitecture

// MARK: - 온보딩 메인 뷰

struct OnboardingView: View {
    @Bindable var store: StoreOf<OnboardingFeature>
    
    var body: some View {
        ZStack {
            // 배경
            HCColors.splashGradient
                .ignoresSafeArea()
            
            // 페이지별 컨텐츠
            switch store.currentPage {
            case .splash:
                SplashView(store: store)
                    .transition(.opacity)
                    
            case .intro1, .intro2, .intro3:
                IntroCarouselView(store: store)
                    .transition(.fadeScale)
                    
            case .quickSetup:
                QuickSetupView(store: store)
                    .transition(.fadeScale)
                    
            case .firstSchedule:
                FirstScheduleView(store: store)
                    .transition(.fadeScale)
            }
        }
        .animation(HCAnimation.smooth, value: store.currentPage)
    }
}

#Preview {
    OnboardingView(
        store: Store(initialState: OnboardingFeature.State()) {
            OnboardingFeature()
        }
    )
}
