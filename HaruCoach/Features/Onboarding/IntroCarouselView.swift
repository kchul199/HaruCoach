import SwiftUI
import ComposableArchitecture

// MARK: - 소개 캐러셀 (3장 스와이프)

struct IntroCarouselView: View {
    @Bindable var store: StoreOf<OnboardingFeature>
    
    private var currentIndex: Int {
        let index = store.currentPage.rawValue - 1
        return max(0, min(index, 2)) // intro1=0, intro2=1, intro3=2
    }
    
    private let introPages: [(icon: String, title: String, subtitle: String, description: String)] = [
        (
            "text.bubble.fill",
            "말하듯이 입력",
            "복잡한 입력은 그만!",
            "\"오전에 기획서, 점심 후 미팅, 저녁에 운동\"\n이렇게 편하게 말하면 AI가 알아서 정리해요"
        ),
        (
            "brain.head.profile.fill",
            "AI가 최적 배분",
            "당신의 리듬을 학습해요",
            "집중 업무는 오전에, 가벼운 일은 오후에\n점심시간은 자동으로 보호해드려요"
        ),
        (
            "chart.bar.fill",
            "매일 성장하는 나",
            "하루를 돌아보는 습관",
            "AI가 하루를 분석하고 맞춤 코칭을 드려요\n매일 조금씩 더 나은 하루를 설계합니다"
        )
    ]
    
    var body: some View {
        VStack(spacing: HCSpacing.xxl) {
            Spacer()
            
            // 콘텐츠
            let page = introPages[currentIndex]
            
            VStack(spacing: HCSpacing.xl) {
                // 아이콘
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.1))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: page.icon)
                        .font(.system(size: 40))
                        .foregroundStyle(.white)
                        .symbolRenderingMode(.hierarchical)
                }
                
                // 제목
                VStack(spacing: HCSpacing.xs) {
                    Text(page.title)
                        .font(HCTypography.displayMedium)
                        .foregroundStyle(.white)
                    
                    Text(page.subtitle)
                        .font(HCTypography.titleMedium)
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                // 설명
                Text(page.description)
                    .font(HCTypography.bodyLarge)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, HCSpacing.xl)
            }
            .id(currentIndex) // 페이지 전환 시 애니메이션
            .transition(.fadeScale)
            
            Spacer()
            
            // 페이지 인디케이터
            HStack(spacing: HCSpacing.xs) {
                ForEach(0..<3, id: \.self) { index in
                    Capsule()
                        .fill(.white.opacity(index == currentIndex ? 1 : 0.3))
                        .frame(width: index == currentIndex ? 24 : 8, height: 8)
                        .animation(HCAnimation.standard, value: currentIndex)
                }
            }
            
            // 버튼 영역
            VStack(spacing: HCSpacing.sm) {
                Button {
                    if currentIndex == 2 {
                        store.send(.setPage(.quickSetup))
                    } else {
                        store.send(.nextPage)
                    }
                } label: {
                    Text(currentIndex == 2 ? "시작하기" : "다음")
                        .font(HCTypography.titleMedium)
                        .foregroundStyle(HCColors.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: HCRadius.lg))
                }
                .pressEffect()
                
                if currentIndex < 2 {
                    Button {
                        store.send(.skipToQuickSetup)
                    } label: {
                        Text("건너뛰기")
                            .font(HCTypography.bodyMedium)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
            .padding(.horizontal, HCSpacing.xl)
            .padding(.bottom, HCSpacing.xxxl)
        }
    }
}

#Preview {
    ZStack {
        HCColors.splashGradient.ignoresSafeArea()
        IntroCarouselView(
            store: Store(initialState: OnboardingFeature.State(currentPage: .intro1)) {
                OnboardingFeature()
            }
        )
    }
}
