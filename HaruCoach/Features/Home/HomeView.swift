import SwiftUI
import ComposableArchitecture

// MARK: - 홈 화면 (오늘의 하루)

struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>
    
    var body: some View {
        ZStack {
            // 배경
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: HCSpacing.lg) {
                    // 헤더
                    headerSection
                    
                    // 자연어 입력
                    inputSection
                    
                    // 타임라인 또는 빈 상태
                    if store.confirmedTasks.isEmpty && !store.showConfirmationCard {
                        emptyStateView
                    } else {
                        timelineSection
                    }
                }
                .padding(.bottom, 100)
            }
            
            // AI 확인 카드 (오버레이)
            if store.showConfirmationCard {
                aiConfirmationOverlay
            }
            
            // 수동 추가 플로팅 버튼 (타임라인 모드일 때만 표시)
            if !store.confirmedTasks.isEmpty && !store.showConfirmationCard {
                floatingAddButton
            }
        }
        .sheet(isPresented: Binding(
            get: { store.editingTaskId != nil || store.isEditingNewTask },
            set: { presenting in if !presenting { _ = store.send(.stopEditing) } }
        )) {
            let taskToEdit = store.editingTaskId.flatMap { id in
                store.generatedTasks.first(where: { $0.id == id }) ?? store.confirmedTasks.first(where: { $0.id == id })
            }
            EditTaskView(
                task: taskToEdit,
                onSave: { _ = store.send(.updateTask($0)) },
                onCancel: { _ = store.send(.stopEditing) }
            )
            .presentationDetents([.medium, .large])
        }
        .onAppear {
            _ = store.send(.onAppear)
        }
    }
    
    // MARK: - 헤더
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: HCSpacing.xxs) {
                Text(Date().dateString)
                    .font(HCTypography.labelMedium)
                    .foregroundStyle(HCColors.textTertiary)
                
                Text(store.greeting)
                    .font(HCTypography.headlineMedium)
                    .foregroundStyle(HCColors.textPrimary)
            }
            
            Spacer()
            
            // 진행률 링
            if !store.confirmedTasks.isEmpty {
                ProgressRing(
                    progress: store.actualCompletionRate,
                    size: 50,
                    lineWidth: 5,
                    showPercentage: false
                )
                .overlay(
                    Text("\(store.completedTaskIds.count)/\(store.confirmedTasks.count)")
                        .font(HCTypography.caption)
                        .foregroundStyle(HCColors.textSecondary)
                )
            }
        }
        .hcScreenPadding()
        .padding(.top, HCSpacing.md)
    }
    
    // MARK: - 입력 섹션
    
    private var inputSection: some View {
        HCTextField(
            text: Binding(
                get: { store.inputText },
                set: { store.send(.setInputText($0)) }
            ),
            placeholder: "오늘 할 일을 말해보세요...",
            icon: "sparkles",
            onSubmit: {
                _ = store.send(.generateSchedule)
            }
        )
        .hcScreenPadding()
        .overlay {
            if store.isGeneratingSchedule {
                loadingOverlay
            }
        }
    }
    
    // MARK: - 빈 상태
    
    private var emptyStateView: some View {
        VStack(spacing: HCSpacing.lg) {
            Spacer().frame(height: HCSpacing.huge)
            
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 56))
                .foregroundStyle(HCColors.primary.opacity(0.3))
                .symbolRenderingMode(.hierarchical)
            
            VStack(spacing: HCSpacing.xs) {
                Text("아직 오늘 스케줄이 없어요")
                    .font(HCTypography.titleLarge)
                    .foregroundStyle(HCColors.textSecondary)
                
                Text("위 입력창에 오늘 할 일을 적어보세요\nAI가 최적의 스케줄을 만들어 드릴게요 ✨")
                    .font(HCTypography.bodyMedium)
                    .foregroundStyle(HCColors.textTertiary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            // 빠른 입력 제안
            VStack(spacing: HCSpacing.xs) {
                Text("이렇게 말해보세요")
                    .font(HCTypography.labelMedium)
                    .foregroundStyle(HCColors.textTertiary)
                
                VStack(spacing: HCSpacing.xs) {
                    suggestionBubble("오전에 기획서 마무리, 오후에 팀 미팅 1시간")
                    suggestionBubble("코딩 2시간, 이메일 처리, 저녁에 러닝")
                    suggestionBubble("회의 3개, 보고서 작성, 잠깐 운동")
                }
            }
        }
        .hcScreenPadding()
    }
    
    // MARK: - 타임라인 섹션
    
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: HCSpacing.sm) {
            HStack {
                Text("오늘의 타임라인")
                    .font(HCTypography.headlineSmall)
                    .foregroundStyle(HCColors.textPrimary)
                
                Spacer()
                
                Text("\(store.completedTaskIds.count)개 완료")
                    .font(HCTypography.labelMedium)
                    .foregroundStyle(HCColors.success)
            }
            .hcScreenPadding()
            
            ForEach(store.confirmedTasks) { task in
                let isCompleted = store.completedTaskIds.contains(task.id)
                
                if isCompleted {
                    CompletedTaskCard(task: task)
                        .hcScreenPadding()
                        .transition(.slideUp)
                } else {
                    TaskCard(
                        task: task,
                        onTap: { _ = store.send(.startEditingTask(task.id)) },
                        onComplete: {
                            withAnimation(HCAnimation.bounce) {
                                _ = store.send(.toggleTaskCompletion(task.id))
                            }
                        }
                    )
                    .hcScreenPadding()
                    .transition(.slideUp)
                }
            }
        }
        .animation(HCAnimation.standard, value: store.completedTaskIds)
    }
    
    // MARK: - AI 확인 카드 오버레이
    
    private var aiConfirmationOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    _ = store.send(.dismissConfirmation)
                }
            
            AIConfirmationCard(
                tasks: store.generatedTasks,
                aiMessage: store.aiMessage,
                onConfirm: { _ = store.send(.confirmSchedule) },
                onDismiss: { _ = store.send(.dismissConfirmation) },
                onEditTask: { taskId in _ = store.send(.startEditingTask(taskId)) }
            )
            .padding(.horizontal, HCSpacing.lg)
            .transition(.cardAppear)
        }
        .animation(HCAnimation.gentleSpring, value: store.showConfirmationCard)
    }
    
    // MARK: - 로딩 오버레이
    
    private var loadingOverlay: some View {
        HStack(spacing: HCSpacing.sm) {
            ProgressView()
                .scaleEffect(0.8)
            Text("AI가 스케줄을 만들고 있어요...")
                .font(HCTypography.bodyMedium)
                .foregroundStyle(HCColors.textSecondary)
        }
        .padding(HCSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: HCRadius.lg)
                .fill(.ultraThinMaterial)
        )
        .offset(y: 80)
    }
    
    // MARK: - 제안 버블
    
    @ViewBuilder
    private func suggestionBubble(_ text: String) -> some View {
        Button {
            _ = store.send(.setInputText(text))
        } label: {
            Text("💬 \"\(text)\"")
                .font(HCTypography.bodySmall)
                .foregroundStyle(HCColors.textSecondary)
                .padding(.horizontal, HCSpacing.md)
                .padding(.vertical, HCSpacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: HCRadius.lg)
                        .fill(.ultraThinMaterial)
                )
        }
        .pressEffect()
    }
    
    // MARK: - 플로팅 버튼
    
    private var floatingAddButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    _ = store.send(.startAddingNewTask)
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(HCColors.primary)
                        .clipShape(Circle())
                        .shadow(color: HCColors.primary.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding()
            }
        }
    }
}

#Preview {
    HomeView(
        store: Store(initialState: HomeFeature.State()) {
            HomeFeature()
        }
    )
}
