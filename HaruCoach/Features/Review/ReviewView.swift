import SwiftUI
import ComposableArchitecture

// MARK: - 리뷰 화면

struct ReviewView: View {
    @Bindable var store: StoreOf<ReviewFeature>
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: HCSpacing.lg) {
                // 헤더
                headerSection
                
                if store.isLoading {
                    loadingView
                } else if store.hasReview {
                    // 달성률 카드
                    completionCard
                    
                    // AI 코멘트
                    aiCommentCard
                    
                    // 내일 제안
                    tomorrowSuggestionCard
                } else {
                    emptyReviewView
                }
            }
            .padding(.bottom, 100)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            if !store.hasReview {
                store.send(.loadReview)
            }
        }
    }
    
    // MARK: - 헤더
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: HCSpacing.xxs) {
            Text("하루 리뷰")
                .font(HCTypography.headlineLarge)
                .foregroundStyle(HCColors.textPrimary)
            
            Text(Date().dateString)
                .font(HCTypography.bodyMedium)
                .foregroundStyle(HCColors.textSecondary)
        }
        .fillWidth(alignment: .leading)
        .hcScreenPadding()
        .padding(.top, HCSpacing.md)
    }
    
    // MARK: - 달성률 카드
    
    private var completionCard: some View {
        VStack(spacing: HCSpacing.lg) {
            ProgressRing(
                progress: Double(store.completionRate),
                size: 140,
                lineWidth: 14
            )
            
            VStack(spacing: HCSpacing.xxs) {
                Text("오늘 \(store.totalTasks)개 중 \(store.completedTasks)개 완료!")
                    .font(HCTypography.titleLarge)
                    .foregroundStyle(HCColors.textPrimary)
                
                if store.streak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(HCColors.secondary)
                        Text("\(store.streak)일 연속 달성 중")
                            .font(HCTypography.labelMedium)
                            .foregroundStyle(HCColors.secondary)
                    }
                }
            }
        }
        .padding(HCSpacing.xl)
        .fillWidth()
        .hcGlassCard()
        .hcScreenPadding()
    }
    
    // MARK: - AI 코멘트 카드
    
    private var aiCommentCard: some View {
        VStack(alignment: .leading, spacing: HCSpacing.sm) {
            HStack(spacing: HCSpacing.xs) {
                Image(systemName: "sparkles")
                    .foregroundStyle(HCColors.primary)
                Text("AI 코치 코멘트")
                    .font(HCTypography.titleMedium)
                    .foregroundStyle(HCColors.textPrimary)
            }
            
            Text(store.aiComment)
                .font(HCTypography.bodyLarge)
                .foregroundStyle(HCColors.textPrimary)
                .lineSpacing(6)
        }
        .padding(HCSpacing.lg)
        .fillWidth(alignment: .leading)
        .hcGlassCard()
        .hcScreenPadding()
    }
    
    // MARK: - 내일 제안 카드
    
    private var tomorrowSuggestionCard: some View {
        VStack(alignment: .leading, spacing: HCSpacing.sm) {
            HStack(spacing: HCSpacing.xs) {
                Image(systemName: "sun.and.horizon.fill")
                    .foregroundStyle(HCColors.secondary)
                Text("내일을 위한 제안")
                    .font(HCTypography.titleMedium)
                    .foregroundStyle(HCColors.textPrimary)
            }
            
            ForEach(store.tomorrowSuggestions, id: \.self) { suggestion in
                HStack(alignment: .top, spacing: HCSpacing.sm) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(HCColors.secondary)
                        .padding(.top, 2)
                    
                    Text(suggestion)
                        .font(HCTypography.bodyMedium)
                        .foregroundStyle(HCColors.textPrimary)
                    
                    Spacer()
                    
                    Button {
                        store.send(.acceptTomorrowSuggestion(suggestion))
                    } label: {
                        Text("수락")
                            .font(HCTypography.labelSmall)
                            .foregroundStyle(HCColors.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(HCColors.primary.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
                .padding(.vertical, HCSpacing.xxs)
            }
        }
        .padding(HCSpacing.lg)
        .fillWidth(alignment: .leading)
        .hcGlassCard()
        .hcScreenPadding()
    }
    
    // MARK: - 빈 상태
    
    private var emptyReviewView: some View {
        VStack(spacing: HCSpacing.md) {
            Spacer().frame(height: HCSpacing.huge)
            
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 48))
                .foregroundStyle(HCColors.textTertiary)
            
            Text("아직 리뷰가 없어요")
                .font(HCTypography.titleLarge)
                .foregroundStyle(HCColors.textSecondary)
            
            Text("하루를 마무리하면 AI가 리뷰를 생성해드려요")
                .font(HCTypography.bodyMedium)
                .foregroundStyle(HCColors.textTertiary)
            
            HCButton("리뷰 생성하기", style: .secondary, icon: "sparkles") {
                store.send(.loadReview)
            }
            .padding(.horizontal, HCSpacing.huge)
        }
    }
    
    // MARK: - 로딩
    
    private var loadingView: some View {
        VStack(spacing: HCSpacing.lg) {
            Spacer().frame(height: HCSpacing.huge)
            
            ProgressView()
                .scaleEffect(1.2)
            
            Text("AI가 하루를 분석하고 있어요...")
                .font(HCTypography.bodyMedium)
                .foregroundStyle(HCColors.textSecondary)
        }
    }
}

#Preview {
    ReviewView(
        store: Store(initialState: ReviewFeature.State()) {
            ReviewFeature()
        }
    )
}
