import SwiftUI

// MARK: - 할 일 카드 컴포넌트

struct TaskCard: View {
    let task: TaskData
    let onTap: () -> Void
    let onComplete: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var isShowingActions = false
    
    var body: some View {
        HStack(spacing: HCSpacing.sm) {
            // 카테고리 인디케이터
            categoryIndicator
            
            // 시간
            timeColumn
            
            // 내용
            contentColumn
            
            Spacer()
            
            // 상태 버튼
            statusButton
        }
        .padding(.horizontal, HCSpacing.md)
        .padding(.vertical, HCSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: HCRadius.lg)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: HCRadius.lg)
                        .stroke(task.categoryEnum.color.opacity(0.2), lineWidth: 1)
                )
        )
        .pressEffect()
        .onTapGesture(perform: onTap)
    }
    
    // MARK: - 카테고리 인디케이터
    
    private var categoryIndicator: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(task.categoryEnum.color)
            .frame(width: 4, height: 44)
    }
    
    // MARK: - 시간 열
    
    private var timeColumn: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(task.startTime.timeString)
                .font(HCTypography.labelLarge)
                .foregroundStyle(HCColors.textPrimary)
            
            Text(task.durationFormatted)
                .font(HCTypography.caption)
                .foregroundStyle(HCColors.textTertiary)
        }
        .frame(width: 60, alignment: .leading)
    }
    
    // MARK: - 내용 열
    
    private var contentColumn: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(task.categoryEnum.emoji)
                    .font(.system(size: 14))
                
                Text(task.title)
                    .font(HCTypography.titleMedium)
                    .foregroundStyle(HCColors.textPrimary)
                    .strikethrough(task.categoryEnum.rawValue == "completed", color: HCColors.textTertiary)
            }
            
            if task.isEdited {
                Text("수정됨")
                    .font(HCTypography.caption)
                    .foregroundStyle(HCColors.secondary)
            }
        }
    }
    
    // MARK: - 상태 버튼
    
    private var statusButton: some View {
        Button(action: onComplete) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 24, weight: .light))
                .foregroundStyle(HCColors.textTertiary)
                .symbolRenderingMode(.hierarchical)
        }
    }
}

// MARK: - 완료된 태스크 카드

struct CompletedTaskCard: View {
    let task: TaskData
    
    var body: some View {
        HStack(spacing: HCSpacing.sm) {
            RoundedRectangle(cornerRadius: 2)
                .fill(task.categoryEnum.color.opacity(0.4))
                .frame(width: 4, height: 36)
            
            Text(task.startTime.timeString)
                .font(HCTypography.caption)
                .foregroundStyle(HCColors.textTertiary)
                .frame(width: 50, alignment: .leading)
            
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(HCColors.success)
                
                Text(task.title)
                    .font(HCTypography.bodyMedium)
                    .foregroundStyle(HCColors.textSecondary)
                    .strikethrough(true, color: HCColors.textTertiary)
            }
            
            Spacer()
        }
        .padding(.horizontal, HCSpacing.md)
        .padding(.vertical, HCSpacing.xs)
        .background(
            RoundedRectangle(cornerRadius: HCRadius.md)
                .fill(HCColors.success.opacity(0.05))
        )
    }
}

#Preview {
    VStack(spacing: 12) {
        TaskCard(
            task: TaskData(
                title: "기획서 마무리",
                category: "work",
                startTime: Date.today(hour: 9),
                duration: 7200
            ),
            onTap: {},
            onComplete: {}
        )
        
        TaskCard(
            task: TaskData(
                title: "러닝",
                category: "health",
                startTime: Date.today(hour: 18, minute: 30),
                duration: 1800
            ),
            onTap: {},
            onComplete: {}
        )
        
        CompletedTaskCard(
            task: TaskData(
                title: "팀 미팅",
                category: "work",
                startTime: Date.today(hour: 13),
                duration: 3600
            )
        )
    }
    .padding()
}
