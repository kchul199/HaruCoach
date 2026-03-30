import SwiftUI

// MARK: - AI 확인 카드 ("이렇게 이해했어요")

struct AIConfirmationCard: View {
    let tasks: [TaskData]
    let aiMessage: String
    let onConfirm: () -> Void
    let onDismiss: () -> Void
    let onEditTask: (String) -> Void
    
    @State private var showTasks = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            headerView
            
            // 태스크 목록
            taskListView
            
            // 버튼 영역
            buttonArea
        }
        .background(
            RoundedRectangle(cornerRadius: HCRadius.xxl)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
        )
        .clipShape(RoundedRectangle(cornerRadius: HCRadius.xxl))
        .onAppear {
            withAnimation(HCAnimation.smooth.delay(0.2)) {
                showTasks = true
            }
        }
    }
    
    // MARK: - 헤더
    
    private var headerView: some View {
        VStack(spacing: HCSpacing.xs) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 20))
                    .foregroundStyle(HCColors.primary)
                
                Text("이렇게 이해했어요")
                    .font(HCTypography.headlineSmall)
                    .foregroundStyle(HCColors.textPrimary)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(HCColors.textTertiary)
                        .symbolRenderingMode(.hierarchical)
                }
            }
            
            Text(aiMessage)
                .font(HCTypography.bodySmall)
                .foregroundStyle(HCColors.textSecondary)
                .multilineTextAlignment(.leading)
                .fillWidth(alignment: .leading)
        }
        .padding(HCSpacing.lg)
        .background(HCColors.primarySoft)
    }
    
    // MARK: - 태스크 목록
    
    private var taskListView: some View {
        VStack(spacing: HCSpacing.xs) {
            ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                confirmationTaskRow(task, index: index)
                    .opacity(showTasks ? 1 : 0)
                    .offset(y: showTasks ? 0 : 20)
                    .animation(
                        HCAnimation.smooth.delay(Double(index) * 0.1),
                        value: showTasks
                    )
                
                if index < tasks.count - 1 {
                    Divider()
                        .padding(.leading, 70)
                }
            }
        }
        .padding(.vertical, HCSpacing.sm)
    }
    
    // MARK: - 개별 태스크 행
    
    @ViewBuilder
    private func confirmationTaskRow(_ task: TaskData, index: Int) -> some View {
        Button {
            onEditTask(task.id)
        } label: {
            HStack(spacing: HCSpacing.sm) {
                // 카테고리 색상 도트
                Circle()
                    .fill(task.categoryEnum.color)
                    .frame(width: 8, height: 8)
                
                // 시간
                Text(task.startTime.timeString)
                    .font(HCTypography.labelLarge)
                    .foregroundStyle(HCColors.textSecondary)
                    .frame(width: 45, alignment: .leading)
                
                // 내용
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(task.categoryEnum.emoji)
                            .font(.system(size: 14))
                        Text(task.title)
                            .font(HCTypography.titleSmall)
                            .foregroundStyle(HCColors.textPrimary)
                    }
                    
                    Text("\(task.durationFormatted) · \(task.categoryEnum.displayName)")
                        .font(HCTypography.caption)
                        .foregroundStyle(HCColors.textTertiary)
                }
                
                Spacer()
                
                // 수정 힌트
                Image(systemName: "pencil.circle")
                    .font(.system(size: 16))
                    .foregroundStyle(HCColors.textTertiary)
                
                if task.isEdited {
                    Text("수정됨")
                        .font(HCTypography.labelSmall)
                        .foregroundStyle(HCColors.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(HCColors.secondary.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, HCSpacing.lg)
            .padding(.vertical, HCSpacing.xs)
        }
    }
    
    // MARK: - 버튼 영역
    
    private var buttonArea: some View {
        VStack(spacing: HCSpacing.sm) {
            Divider()
            
            VStack(spacing: HCSpacing.xs) {
                HCButton("확정하기", style: .primary, icon: "checkmark") {
                    onConfirm()
                }
                
                HCButton("다시 생성", style: .ghost, icon: "arrow.clockwise") {
                    onDismiss()
                }
            }
            .padding(.horizontal, HCSpacing.lg)
            .padding(.bottom, HCSpacing.lg)
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.4).ignoresSafeArea()
        
        AIConfirmationCard(
            tasks: [
                TaskData(title: "기획서 마무리", category: "work", startTime: Date.today(hour: 9), duration: 7200),
                TaskData(title: "팀 미팅", category: "work", startTime: Date.today(hour: 13), duration: 3600),
                TaskData(title: "러닝", category: "health", startTime: Date.today(hour: 18, minute: 30), duration: 1800),
                TaskData(title: "영어 공부", category: "growth", startTime: Date.today(hour: 21), duration: 3600)
            ],
            aiMessage: "4가지 할 일을 6시간으로 정리했어요! 집중 업무는 오전에, 가벼운 활동은 저녁에 배치했습니다.",
            onConfirm: {},
            onDismiss: {},
            onEditTask: { _ in }
        )
        .padding()
    }
}
