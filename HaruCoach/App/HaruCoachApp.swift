import SwiftUI
import SwiftData
import ComposableArchitecture
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

// MARK: - 앱 진입점

@main
struct HaruCoachApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            AppRootView(
                store: Store(initialState: AppFeature.State()) {
                    AppFeature()
                }
            )
        }
        .modelContainer(for: [
            User.self,
            DailyPlan.self,
            HCTask.self,
            DailyReview.self,
            Correction.self
        ])
    }
}

// MARK: - 앱 루트 뷰

struct AppRootView: View {
    @Bindable var store: StoreOf<AppFeature>
    
    var body: some View {
        Group {
            if store.isOnboardingCompleted {
                mainTabView
            } else {
                OnboardingView(
                    store: store.scope(state: \.onboarding, action: \.onboarding)
                )
            }
        }
        .animation(HCAnimation.smooth, value: store.isOnboardingCompleted)
    }
    
    // MARK: - 메인 탭 뷰
    
    private var mainTabView: some View {
        TabView(selection: Binding(
            get: { store.selectedTab },
            set: { store.send(.selectTab($0)) }
        )) {
            // 홈 탭
            NavigationStack {
                HomeView(
                    store: store.scope(state: \.home, action: \.home)
                )
                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label(AppFeature.Tab.home.title, systemImage: AppFeature.Tab.home.icon)
            }
            .tag(AppFeature.Tab.home)
            
            // 리뷰 탭
            NavigationStack {
                ReviewView(
                    store: store.scope(state: \.review, action: \.review)
                )
                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label(AppFeature.Tab.review.title, systemImage: AppFeature.Tab.review.icon)
            }
            .tag(AppFeature.Tab.review)
            
            // 설정 탭
            NavigationStack {
                SettingsView(
                    store: store.scope(state: \.settings, action: \.settings)
                )
            }
            .tabItem {
                Label(AppFeature.Tab.settings.title, systemImage: AppFeature.Tab.settings.icon)
            }
            .tag(AppFeature.Tab.settings)
        }
        .tint(HCColors.primary)
    }
}

#Preview {
    AppRootView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}
