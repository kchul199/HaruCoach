import Testing
@testable import HaruCoach

@Test func mockAIServiceGeneratesSchedule() async throws {
    let service = MockAIService()
    let result = try await service.generateSchedule(
        from: "오전에 기획서 마무리하고, 점심 후에 팀 미팅",
        context: AIContext()
    )
    
    #expect(!result.tasks.isEmpty)
    #expect(!result.aiMessage.isEmpty)
    #expect(result.confidence > 0)
}

@Test func mockAIServiceGeneratesReview() async throws {
    let service = MockAIService()
    let tasks = [
        TaskData(title: "기획서", category: "work", startTime: Date(), duration: 7200),
        TaskData(title: "러닝", category: "health", startTime: Date(), duration: 1800)
    ]
    
    let result = try await service.generateReview(for: tasks, context: AIContext())
    
    #expect(result.totalTasks > 0)
    #expect(!result.aiComment.isEmpty)
    #expect(!result.tomorrowSuggestions.isEmpty)
}

@Test func taskDataFormatting() {
    let task = TaskData(
        title: "테스트",
        category: "work",
        startTime: Date(),
        duration: 5400 // 1시간 30분
    )
    
    #expect(task.durationFormatted == "1시간 30분")
    #expect(task.categoryEnum == .work)
}
