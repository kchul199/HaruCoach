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

    // MARK: - Live Value (실제 앱)

    static var liveValue: DatabaseClient {
        makeClient(inMemory: false)
    }

    // MARK: - Test Value (단위 테스트 / Preview)

    static var testValue: DatabaseClient {
        makeClient(inMemory: true)
    }

    // MARK: - 팩토리

    /// inMemory: true면 앱 종료 시 데이터 소멸 (테스트/Preview용)
    static func makeClient(inMemory: Bool) -> DatabaseClient {
        let schema = Schema([
            User.self,
            DailyPlan.self,
            HCTask.self,
            DailyReview.self,
            Correction.self
        ])

        // 1차: 영구 저장 시도 → 실패 시 인메모리로 폴백 (프로덕션 크래시 방지)
        let container: ModelContainer
        do {
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            print("⚠️ [DatabaseClient] 영구 저장소 초기화 실패, 인메모리로 폴백합니다: \(error)")
            do {
                let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                container = try ModelContainer(for: schema, configurations: [fallback])
            } catch {
                // 인메모리조차 실패하면 앱 동작 자체가 불가능하므로 크래시 허용
                fatalError("❌ [DatabaseClient] ModelContainer 생성 완전 실패: \(error)")
            }
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
                // 기존 태스크가 있으면 삭제 후 재삽입 (upsert 패턴)
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
                guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
                    return []
                }
                // MVP 규모에서는 전체 fetch 후 로컬 필터링으로 충분
                let descriptor = FetchDescriptor<HCTask>(sortBy: [SortDescriptor(\.startTime)])
                let allTasks = try context.fetch(descriptor)
                return allTasks.filter { $0.startTime >= startOfDay && $0.startTime < endOfDay }
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
