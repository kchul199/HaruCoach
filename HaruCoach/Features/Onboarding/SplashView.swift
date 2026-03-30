import SwiftUI
import ComposableArchitecture

// MARK: - 스플래시 화면

struct SplashView: View {
    let store: StoreOf<OnboardingFeature>
    
    @State private var showLogo = false
    @State private var showTagline = false
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: HCSpacing.xl) {
            Spacer()
            
            // 로고 영역
            VStack(spacing: HCSpacing.md) {
                // 앱 아이콘 (기본 디자인)
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .scaleEffect(pulseScale)
                    
                    Circle()
                        .fill(.white.opacity(0.1))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 44, weight: .medium))
                        .foregroundStyle(.white)
                }
                .opacity(showLogo ? 1 : 0)
                .scaleEffect(showLogo ? 1 : 0.5)
                
                // 앱 이름
                Text("하루코치")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .opacity(showLogo ? 1 : 0)
                    .offset(y: showLogo ? 0 : 20)
            }
            
            // 태그라인
            Text("하루를 말하면, AI가\n최적의 하루를 설계합니다")
                .font(HCTypography.bodyLarge)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .opacity(showTagline ? 1 : 0)
                .offset(y: showTagline ? 0 : 15)
            
            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(HCAnimation.slowSpring.delay(0.3)) {
                showLogo = true
            }
            withAnimation(HCAnimation.smooth.delay(0.8)) {
                showTagline = true
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(1)) {
                pulseScale = 1.1
            }
            
            // 2.5초 후 자동 전환
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                store.send(.splashAnimationCompleted)
            }
        }
    }
}

#Preview {
    ZStack {
        HCColors.splashGradient.ignoresSafeArea()
        SplashView(
            store: Store(initialState: OnboardingFeature.State()) {
                OnboardingFeature()
            }
        )
    }
}
