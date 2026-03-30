import Foundation
import ComposableArchitecture

// MARK: - 리뷰 Feature

@Reducer
struct ReviewFeature {
    
    @ObservableState
    struct State: Equatable {
        var isLoading: Bool = false
        var hasReview: Bool = false
        var completionRate: Float = 0
        var totalTasks: Int = 0
        var completedTasks: Int = 0
        var aiComment: String = ""
        var tomorrowSuggestions: [String] = []
        var streak: Int = 0
        var categoryBreakdown: [(category: String, minutes: Int)] = []
        var showShareCard: Bool = false
        
        static func == (lhs: State, rhs: State) -> Bool {
            lhs.isLoading == rhs.isLoading &&
            lhs.hasReview == rhs.hasReview &&
            lhs.completionRate == rhs.completionRate &&
            lhs.aiComment == rhs.aiComment
        }
    }
    
    enum Action: Equatable {
        case loadReview
        case reviewLoaded(Float, Int, Int, String, [String])
        case reviewFailed(String)
        case toggleShareCard
        case acceptTomorrowSuggestion(String)
    }
    
    @Dependency(\.aiService) var aiService
    @Dependency(\.databaseClient) var databaseClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadReview:
                state.isLoading = true
                return .run { [date = Date()] send in
                    // DB에서 오늘 태스크 로드
                    let hcTasks = (try? databaseClient.fetchTasks(date)) ?? []
                    let domainTasks = hcTasks.map { hcTask in
                        TaskData(
                            id: hcTask.id,
                            title: hcTask.title,
                            category: hcTask.category.rawValue,
                            startTime: hcTask.startTime,
                            duration: hcTask.duration,
                            isEdited: hcTask.wasEdited
                        )
                    }
                    
                    var aiContext = AIContext()
                    if let user = try? databaseClient.fetchUser() {
                        aiContext = AIContext(
                            workStartTime: user.workStartTime,
                            workEndTime: user.workEndTime,
                            chronotype: user.chronotype.rawValue,
                            aiPreference: user.aiPreference.rawValue,
                            correctionHistory: []
                        )
                    }
                    
                    do {
                        let result = try await aiService.generateReview(
                            for: domainTasks,
                            context: aiContext
                        )
                        await send(.reviewLoaded(
                            result.completionRate,
                            result.totalTasks,
                            result.completedTasks,
                            result.aiComment,
                            result.tomorrowSuggestions
                        ))
                    } catch {
                        await send(.reviewFailed(error.localizedDescription))
                    }
                }
                
            case .reviewLoaded(let rate, let total, let completed, let comment, let suggestions):
                state.isLoading = false
                state.hasReview = true
                state.completionRate = rate
                state.totalTasks = total
                state.completedTasks = completed
                state.aiComment = comment
                state.tomorrowSuggestions = suggestions
                state.streak = 5 // Mock
                return .none
                
            case .reviewFailed:
                state.isLoading = false
                return .none
                
            case .toggleShareCard:
                state.showShareCard.toggle()
                return .none
                
            case .acceptTomorrowSuggestion:
                return .none
            }
        }
    }
}
