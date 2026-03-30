import SwiftUI
import ComposableArchitecture

// MARK: - 온보딩 Feature

@Reducer
struct OnboardingFeature {
    
    @ObservableState
    struct State: Equatable {
        var currentPage: OnboardingPage = .splash
        var workStartHour: Int = 9
        var workStartMinute: Int = 0
        var workEndHour: Int = 18
        var workEndMinute: Int = 0
        var chronotype: Chronotype = .morning
        var isAnimating: Bool = false
        var firstInput: String = ""
    }
    
    enum OnboardingPage: Int, CaseIterable, Equatable {
        case splash = 0
        case intro1 = 1
        case intro2 = 2
        case intro3 = 3
        case quickSetup = 4
        case login = 5
        case firstSchedule = 6
    }
    
    enum Action: Equatable {
        case splashAnimationCompleted
        case nextPage
        case previousPage
        case setPage(OnboardingPage)
        case setWorkStartHour(Int)
        case setWorkStartMinute(Int)
        case setWorkEndHour(Int)
        case setWorkEndMinute(Int)
        case setChronotype(Chronotype)
        case setFirstInput(String)
        case completeOnboarding
        case skipToQuickSetup
    }
    
    @Dependency(\.databaseClient) var databaseClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .splashAnimationCompleted:
                state.currentPage = .intro1
                return .none
                
            case .nextPage:
                if let nextIndex = OnboardingPage(rawValue: state.currentPage.rawValue + 1) {
                    state.currentPage = nextIndex
                }
                return .none
                
            case .previousPage:
                if let prevIndex = OnboardingPage(rawValue: state.currentPage.rawValue - 1),
                   prevIndex != .splash {
                    state.currentPage = prevIndex
                }
                return .none
                
            case .setPage(let page):
                state.currentPage = page
                return .none
                
            case .setWorkStartHour(let hour):
                state.workStartHour = hour
                return .none
                
            case .setWorkStartMinute(let minute):
                state.workStartMinute = minute
                return .none
                
            case .setWorkEndHour(let hour):
                state.workEndHour = hour
                return .none
                
            case .setWorkEndMinute(let minute):
                state.workEndMinute = minute
                return .none
                
            case .setChronotype(let type):
                state.chronotype = type
                return .none
                
            case .setFirstInput(let input):
                state.firstInput = input
                return .none
                
            case .completeOnboarding:
                let start = Date.today(hour: state.workStartHour, minute: state.workStartMinute)
                let end = Date.today(hour: state.workEndHour, minute: state.workEndMinute)
                let user = User(
                    workStartTime: start,
                    workEndTime: end,
                    chronotype: state.chronotype
                )
                return .run { send in
                    try? databaseClient.saveUser(user)
                }
                
            case .skipToQuickSetup:
                state.currentPage = .quickSetup
                return .none
            }
        }
    }
}
