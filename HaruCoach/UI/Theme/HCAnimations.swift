import SwiftUI

// MARK: - HaruCoach 애니메이션 시스템

enum HCAnimation {
    /// 빠른 인터랙션 (탭, 토글)
    static let quick = Animation.easeInOut(duration: 0.2)
    
    /// 일반 트랜지션
    static let standard = Animation.easeInOut(duration: 0.3)
    
    /// 부드러운 트랜지션 (카드 확장 등)
    static let smooth = Animation.easeInOut(duration: 0.4)
    
    /// 스프링 바운스 (버튼 탭 피드백)
    static let bounce = Animation.spring(response: 0.4, dampingFraction: 0.6)
    
    /// 부드러운 스프링 (모달, 시트)
    static let gentleSpring = Animation.spring(response: 0.5, dampingFraction: 0.8)
    
    /// 느린 스프링 (온보딩 등)
    static let slowSpring = Animation.spring(response: 0.7, dampingFraction: 0.7)
    
    /// 리뷰 카운트업 애니메이션
    static let countUp = Animation.easeOut(duration: 1.0)
}

// MARK: - Transition Helpers
extension AnyTransition {
    /// 카드 슬라이드 인
    static var slideUp: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        )
    }
    
    /// 페이드 + 스케일
    static var fadeScale: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.9).combined(with: .opacity),
            removal: .scale(scale: 1.1).combined(with: .opacity)
        )
    }
    
    /// 카드 등장
    static var cardAppear: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.95).combined(with: .opacity).animation(HCAnimation.gentleSpring),
            removal: .opacity.animation(HCAnimation.quick)
        )
    }
}

// MARK: - Shimmer Effect (로딩)
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.3), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .onAppear {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        phase = 400
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: HCRadius.md))
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Press Effect
struct PressEffectModifier: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(HCAnimation.quick, value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

extension View {
    func pressEffect() -> some View {
        modifier(PressEffectModifier())
    }
}
