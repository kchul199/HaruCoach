import Foundation
import ComposableArchitecture

// MARK: - 홈 Feature (오늘의 하루)

@Reducer
struct HomeFeature {
    
    @ObservableState
    struct State: Equatable {
        var inputText: String = ""
        var isGeneratingSchedule: Bool = false
        var showConfirmationCard: Bool = false
        var aiMessage: String = ""
        var generatedTasks: [TaskData] = []
        var confirmedTasks: [TaskData] = []
        var editingTaskId: String? = nil
        var todayDate: Date = Date()
        var greeting: String = Date().greeting
        
        var completedCount: Int {
            confirmedTasks.filter { _ in false }.count // 실제 완료 상태는 별도 관리
        }
        
        var completionRate: Double {
            guard !confirmedTasks.isEmpty else { return 0 }
            return Double(completedCount) / Double(confirmedTasks.count)
        }
        
        // 태스크 완료 상태를 별도로 관리
        var completedTaskIds: Set<String> = []
        
        var actualCompletionRate: Double {
            guard !confirmedTasks.isEmpty else { return 0 }
            return Double(completedTaskIds.count) / Double(confirmedTasks.count)
        }
    }
    
    enum Action: Equatable {
        case setInputText(String)
        case generateSchedule
        case scheduleGenerated(TaskResult<ScheduleResult>)
        case confirmSchedule
        case dismissConfirmation
        case toggleTaskCompletion(String)
        case startEditingTask(String)
        case updateTask(TaskData)
        case stopEditing
        case refreshGreeting
        
        // TaskResult wrapper for Equatable
        enum TaskResult<T>: Equatable {
            case success([TaskData], String) // tasks, aiMessage
            case failure(String)
        }
    }
    
    @Dependency(\.aiService) var aiService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .setInputText(let text):
                state.inputText = text
                return .none
                
            case .generateSchedule:
                guard !state.inputText.isEmpty else { return .none }
                state.isGeneratingSchedule = true
                let input = state.inputText
                
                return .run { send in
                    do {
                        let result = try await aiService.generateSchedule(
                            from: input,
                            context: AIContext()
                        )
                        await send(.scheduleGenerated(.success(result.tasks, result.aiMessage)))
                    } catch {
                        await send(.scheduleGenerated(.failure(error.localizedDescription)))
                    }
                }
                
            case .scheduleGenerated(let result):
                state.isGeneratingSchedule = false
                switch result {
                case .success(let tasks, let message):
                    state.generatedTasks = tasks
                    state.aiMessage = message
                    state.showConfirmationCard = true
                case .failure(let error):
                    state.aiMessage = "스케줄 생성에 실패했어요: \(error)"
                }
                return .none
                
            case .confirmSchedule:
                state.confirmedTasks = state.generatedTasks
                state.showConfirmationCard = false
                state.inputText = ""
                state.generatedTasks = []
                return .none
                
            case .dismissConfirmation:
                state.showConfirmationCard = false
                state.generatedTasks = []
                return .none
                
            case .toggleTaskCompletion(let taskId):
                if state.completedTaskIds.contains(taskId) {
                    state.completedTaskIds.remove(taskId)
                } else {
                    state.completedTaskIds.insert(taskId)
                }
                return .none
                
            case .startEditingTask(let taskId):
                state.editingTaskId = taskId
                return .none
                
            case .updateTask(let updatedTask):
                if let index = state.generatedTasks.firstIndex(where: { $0.id == updatedTask.id }) {
                    var modified = updatedTask
                    modified.isEdited = true
                    state.generatedTasks[index] = modified
                } else if let index = state.confirmedTasks.firstIndex(where: { $0.id == updatedTask.id }) {
                    var modified = updatedTask
                    modified.isEdited = true
                    state.confirmedTasks[index] = modified
                }
                state.editingTaskId = nil
                return .none
                
            case .stopEditing:
                state.editingTaskId = nil
                return .none
                
            case .refreshGreeting:
                state.greeting = Date().greeting
                return .none
            }
        }
    }
}

// MARK: - AI Service Dependency

struct AIServiceKey: DependencyKey {
    static var liveValue: any AIServiceProtocol = MockAIService()
    static var testValue: any AIServiceProtocol = MockAIService()
}

extension DependencyValues {
    var aiService: any AIServiceProtocol {
        get { self[AIServiceKey.self] }
        set { self[AIServiceKey.self] = newValue }
    }
}

// MARK: - ScheduleResult Equatable (for TCA)
extension ScheduleResult: Equatable {
    static func == (lhs: ScheduleResult, rhs: ScheduleResult) -> Bool {
        lhs.tasks == rhs.tasks && lhs.aiMessage == rhs.aiMessage
    }
}

extension ReviewResult: Equatable {
    static func == (lhs: ReviewResult, rhs: ReviewResult) -> Bool {
        lhs.completionRate == rhs.completionRate && lhs.aiComment == rhs.aiComment
    }
}
