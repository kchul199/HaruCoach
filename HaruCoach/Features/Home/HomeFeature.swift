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
        var isEditingNewTask: Bool = false
        var todayDate: Date = Date()
        var greeting: String = Date().greeting
        
        // 태스크 완료 상태를 completedTaskIds로 별도 관리
        var completedTaskIds: Set<String> = []

        var completionRate: Double {
            guard !confirmedTasks.isEmpty else { return 0 }
            return Double(completedTaskIds.count) / Double(confirmedTasks.count)
        }

        // actualCompletionRate → completionRate와 동일하므로 통합 (HomeView 호환)
        var actualCompletionRate: Double { completionRate }
    }
    
    enum Action: Equatable {
        case setInputText(String)
        case generateSchedule
        case scheduleGenerated(TaskResult<ScheduleResult>)
        case confirmSchedule
        case dismissConfirmation
        case toggleTaskCompletion(String)
        case startEditingTask(String)
        case startAddingNewTask
        case updateTask(TaskData)
        case stopEditing
        case refreshGreeting
        case onAppear
        case tasksLoaded([TaskData])
        
        // TaskResult wrapper for Equatable
        enum TaskResult<T>: Equatable {
            case success([TaskData], String) // tasks, aiMessage
            case failure(String)
        }
    }
    
    @Dependency(\.aiService) var aiService
    @Dependency(\.databaseClient) var databaseClient
    
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
                        let result = try await aiService.generateSchedule(
                            from: input,
                            context: aiContext
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
                
                let confirmed = state.confirmedTasks
                return .run { _ in
                    for taskData in confirmed {
                        let hcTask = HCTask(
                            id: taskData.id,
                            title: taskData.title,
                            category: TaskCategory(rawValue: taskData.category) ?? .personal,
                            startTime: taskData.startTime,
                            duration: taskData.duration,
                            status: .pending
                        )
                        hcTask.wasEdited = taskData.isEdited
                        try? databaseClient.saveTask(hcTask)
                        
                        NotificationManager.shared.scheduleTaskReminder(taskId: taskData.id, title: taskData.title, at: taskData.startTime)
                    }
                    NotificationManager.shared.scheduleEveningReview()
                }
                
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
                
            case .startAddingNewTask:
                state.isEditingNewTask = true
                return .none
                
            case .updateTask(let updatedTask):
                if state.isEditingNewTask {
                    state.confirmedTasks.append(updatedTask)
                    state.confirmedTasks.sort { $0.startTime < $1.startTime }
                    state.isEditingNewTask = false
                } else if let index = state.generatedTasks.firstIndex(where: { $0.id == updatedTask.id }) {
                    var modified = updatedTask
                    modified.isEdited = true
                    state.generatedTasks[index] = modified
                    state.generatedTasks.sort { $0.startTime < $1.startTime }
                } else if let index = state.confirmedTasks.firstIndex(where: { $0.id == updatedTask.id }) {
                    var modified = updatedTask
                    modified.isEdited = true
                    state.confirmedTasks[index] = modified
                    state.confirmedTasks.sort { $0.startTime < $1.startTime }
                }
                
                state.editingTaskId = nil
                
                // DB 저장
                let hcTask = HCTask(
                    id: updatedTask.id,
                    title: updatedTask.title,
                    category: TaskCategory(rawValue: updatedTask.category) ?? .personal,
                    startTime: updatedTask.startTime,
                    duration: updatedTask.duration,
                    status: .pending
                )
                hcTask.wasEdited = true
                return .run { _ in
                    try? databaseClient.saveTask(hcTask)
                }
                
            case .stopEditing:
                state.editingTaskId = nil
                state.isEditingNewTask = false
                return .none
                
            case .refreshGreeting:
                state.greeting = Date().greeting
                return .none
                
            case .onAppear:
                return .run { [date = state.todayDate] send in
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
                    // 임시: 완료 상태 토글 반영을 위해 별도 처리가 필요할 수 있으나 MVP엔 제외
                    await send(.tasksLoaded(domainTasks))
                }
                
            case .tasksLoaded(let tasks):
                state.confirmedTasks = tasks
                return .none
            }
        }
    }
}

// MARK: - AI Service Dependency

struct AIServiceKey: DependencyKey {
    /// API 키가 설정되어 있으면 ClaudeAIService, 없으면 MockAIService 사용
    static var liveValue: any AIServiceProtocol {
        if APIConfig.useMockAI {
            return MockAIService()
        } else {
            return ClaudeAIService(apiKey: APIConfig.claudeAPIKey)
        }
    }
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
