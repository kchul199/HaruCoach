import Foundation

// MARK: - 프롬프트 관리자
/// 서버 사이드 프롬프트를 관리 (현재는 로컬, 추후 Firebase Remote Config 연동)

final class PromptManager {
    static let shared = PromptManager()
    
    private init() {}
    
    // MARK: - 스케줄 생성 프롬프트
    
    func schedulePrompt(input: String, context: AIContext) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        return """
        당신은 한국 직장인을 위한 AI 스케줄 코치입니다.
        
        [사용자 정보]
        - 출근 시간: \(formatter.string(from: context.workStartTime))
        - 퇴근 시간: \(formatter.string(from: context.workEndTime))
        - 생활 패턴: \(context.chronotype)
        - AI 성향: \(context.aiPreference)
        
        [스케줄링 규칙]
        1. 집중 업무는 오전에, 가벼운 작업은 오후에 배치
        2. 점심시간(12:00~13:00) 보호
        3. 일정 사이에 5~15분 버퍼 타임 자동 삽입
        4. 하루 총 일정 16시간 초과 시 경고
        5. 한국 직장 문화 고려 (회의, 야근 패턴)
        
        [사용자 입력]
        \(input)
        
        [출력 형식]
        JSON 배열로 출력:
        [{"title": "할일명", "category": "work|health|growth|personal", "startTime": "HH:mm", "duration": 분단위}]
        """
    }
    
    // MARK: - 리뷰 생성 프롬프트
    
    func reviewPrompt(tasks: [TaskData], context: AIContext) -> String {
        let taskSummary = tasks.map { task in
            "- \(task.title) (\(task.categoryEnum.displayName), \(task.durationFormatted))"
        }.joined(separator: "\n")
        
        return """
        당신은 따뜻하면서도 통찰력 있는 AI 코치입니다.
        
        [오늘의 일정 결과]
        \(taskSummary)
        
        [요청]
        1. 오늘 하루를 분석한 한줄 코멘트 (격려 + 인사이트)
        2. 내일을 위한 제안 2~3개
        
        톤: 친근하고 따뜻하게, 이모지 적절히 사용
        """
    }
    
    // MARK: - 프롬프트 버전
    
    var currentVersion: String { "1.0.0" }
}
