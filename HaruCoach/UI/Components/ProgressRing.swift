import SwiftUI

// MARK: - 진행률 링 차트

struct ProgressRing: View {
    let progress: Double // 0.0 ~ 1.0
    let size: CGFloat
    let lineWidth: CGFloat
    let showPercentage: Bool
    let gradientColors: [Color]
    
    @State private var animatedProgress: Double = 0
    
    init(
        progress: Double,
        size: CGFloat = 120,
        lineWidth: CGFloat = 12,
        showPercentage: Bool = true,
        gradientColors: [Color] = [HCColors.primary, HCColors.primaryLight]
    ) {
        self.progress = progress
        self.size = size
        self.lineWidth = lineWidth
        self.showPercentage = showPercentage
        self.gradientColors = gradientColors
    }
    
    var body: some View {
        ZStack {
            // 배경 링
            Circle()
                .stroke(
                    HCColors.primary.opacity(0.15),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
            
            // 진행 링
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: gradientColors),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(HCAnimation.countUp, value: animatedProgress)
            
            // 퍼센트 텍스트
            if showPercentage {
                VStack(spacing: 2) {
                    Text("\(Int(animatedProgress * 100))")
                        .font(HCTypography.percentage)
                        .foregroundStyle(HCColors.primary)
                        .contentTransition(.numericText())
                    
                    Text("%")
                        .font(HCTypography.labelMedium)
                        .foregroundStyle(HCColors.textSecondary)
                }
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(HCAnimation.countUp) {
                animatedProgress = max(0, min(progress, 1.0))
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(HCAnimation.countUp) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - 소형 진행률 링 (인라인용)
struct MiniProgressRing: View {
    let progress: Double
    let size: CGFloat
    let color: Color
    
    init(progress: Double, size: CGFloat = 24, color: Color = HCColors.primary) {
        self.progress = progress
        self.size = size
        self.color = color
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 3)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 30) {
        ProgressRing(progress: 0.75)
        ProgressRing(progress: 0.45, size: 80, lineWidth: 8)
        HStack(spacing: 16) {
            MiniProgressRing(progress: 0.8, color: HCColors.categoryWork)
            MiniProgressRing(progress: 0.5, color: HCColors.categoryHealth)
            MiniProgressRing(progress: 0.3, color: HCColors.categoryGrowth)
        }
    }
    .padding()
}
