import Foundation
import SwiftData
import ComposableArchitecture

// MARK: - SwiftData 데이터베이스 클라이언트

struct DatabaseClient {
    var saveUser: @Sendable (User) throws -> Void
    var fetchUser: @Sendable () throws -> User?
    var saveTask: @Sendable (HCTask) throws -> Void
    var fetchTasks: @Sendable (Date) throws -> [HCTask] // 특정 날짜의 태스크 가져오기
    var deleteTask: @Sendable (String) throws -> Void
}

extension DatabaseClient: DependencyKey {
    static var liveValue: DatabaseClient {
        // 앱의 기본 ModelContainer
        let container: ModelContainer
        do {
            let schema = Schema([
                User.self,
                DailyPlan.self,
                HCTask.self,
                DailyReview.self,
                Correction.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        
        return DatabaseClient(
            saveUser: { user in
                let context = ModelContext(container)
                context.insert(user)
                try context.save()
            },
            fetchUser: {
                let context = ModelContext(container)
                let descriptor = FetchDescriptor<User>()
                return try context.fetch(descriptor).first
            },
            saveTask: { task in
                let context = ModelContext(container)
                // 만약 기존 태스크가 있다면 삭제 후 업데이트 (단순화된 방식, 실제로는 객체 병합이 필요할 수 있음)
                let id = task.id
                let descriptor = FetchDescriptor<HCTask>(predicate: #Predicate { $0.id == id })
                if let existing = try context.fetch(descriptor).first {
                    context.delete(existing)
                }
                context.insert(task)
                try context.save()
            },
            fetchTasks: { date in
                let context = ModelContext(container)
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: date)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                
                // SwiftData Predicate cannot easily deal with Date range properly in some betas,
                // but we will fetch all and filter locally for simplicity if the dataset is small per day.
                let descriptor = FetchDescriptor<HCTask>(sortBy: [SortDescriptor(\.startTime)])
                let allTasks = try context.fetch(descriptor)
                
                return allTasks.filter { task in
                    task.startTime >= startOfDay && task.startTime < endOfDay
                }
            },
            deleteTask: { id in
                let context = ModelContext(container)
                let descriptor = FetchDescriptor<HCTask>(predicate: #Predicate { $0.id == id })
                if let existing = try context.fetch(descriptor).first {
                    context.delete(existing)
                    try context.save()
                }
            }
        )
    }
}

extension DependencyValues {
    var databaseClient: DatabaseClient {
        get { self[DatabaseClient.self] }
        set { self[DatabaseClient.self] = newValue }
    }
}
