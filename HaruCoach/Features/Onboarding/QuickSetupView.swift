import SwiftUI
import ComposableArchitecture

// MARK: - 빠른 설정 (출퇴근 + 아침/저녁형)

struct QuickSetupView: View {
    @Bindable var store: StoreOf<OnboardingFeature>
    
    @State private var showContent = false
    
    var body: some View {
        VStack(spacing: HCSpacing.xxl) {
            Spacer()
            
            // 타이틀
            VStack(spacing: HCSpacing.xs) {
                Text("간단한 설정 ⚡")
                    .font(HCTypography.displaySmall)
                    .foregroundStyle(.white)
                
                Text("딱 2가지만 알려주세요")
                    .font(HCTypography.bodyLarge)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
            
            VStack(spacing: HCSpacing.lg) {
                // 1. 출퇴근 시간
                setupCard {
                    VStack(alignment: .leading, spacing: HCSpacing.md) {
                        Label("출퇴근 시간", systemImage: "briefcase.fill")
                            .font(HCTypography.titleLarge)
                            .foregroundStyle(HCColors.textPrimary)
                        
                        HStack(spacing: HCSpacing.lg) {
                            // 출근
                            VStack(spacing: HCSpacing.xxs) {
                                Text("출근")
                                    .font(HCTypography.labelMedium)
                                    .foregroundStyle(HCColors.textSecondary)
                                
                                timeSelector(
                                    hour: store.workStartHour,
                                    minute: store.workStartMinute,
                                    onHourChange: { store.send(.setWorkStartHour($0)) },
                                    onMinuteChange: { store.send(.setWorkStartMinute($0)) }
                                )
                            }
                            
                            Image(systemName: "arrow.right")
                                .foregroundStyle(HCColors.textTertiary)
                            
                            // 퇴근
                            VStack(spacing: HCSpacing.xxs) {
                                Text("퇴근")
                                    .font(HCTypography.labelMedium)
                                    .foregroundStyle(HCColors.textSecondary)
                                
                                timeSelector(
                                    hour: store.workEndHour,
                                    minute: store.workEndMinute,
                                    onHourChange: { store.send(.setWorkEndHour($0)) },
                                    onMinuteChange: { store.send(.setWorkEndMinute($0)) }
                                )
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                
                // 2. 아침형/저녁형
                setupCard {
                    VStack(alignment: .leading, spacing: HCSpacing.md) {
                        Label("생활 패턴", systemImage: "sun.and.horizon.fill")
                            .font(HCTypography.titleLarge)
                            .foregroundStyle(HCColors.textPrimary)
                        
                        HStack(spacing: HCSpacing.sm) {
                            ForEach(Chronotype.allCases, id: \.rawValue) { type in
                                chronotypeButton(type)
                            }
                        }
                    }
                }
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 30)
            
            Spacer()
            
            // 다음 버튼
            Button {
                store.send(.nextPage)
            } label: {
                Text("다음으로")
                    .font(HCTypography.titleMedium)
                    .foregroundStyle(HCColors.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: HCRadius.lg))
            }
            .pressEffect()
            .padding(.horizontal, HCSpacing.xl)
            .padding(.bottom, HCSpacing.xxxl)
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(HCAnimation.smooth.delay(0.2)) {
                showContent = true
            }
        }
    }
    
    // MARK: - 설정 카드
    
    @ViewBuilder
    private func setupCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(HCSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: HCRadius.xl)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            )
            .padding(.horizontal, HCSpacing.xl)
    }
    
    // MARK: - 시간 선택기
    
    @ViewBuilder
    private func timeSelector(
        hour: Int,
        minute: Int,
        onHourChange: @escaping (Int) -> Void,
        onMinuteChange: @escaping (Int) -> Void
    ) -> some View {
        HStack(spacing: 4) {
            // 시간
            Picker("시", selection: Binding(
                get: { hour },
                set: { onHourChange($0) }
            )) {
                ForEach(0..<24, id: \.self) { h in
                    Text(String(format: "%02d", h)).tag(h)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 50, height: 80)
            .clipped()
            
            Text(":")
                .font(HCTypography.titleLarge)
                .foregroundStyle(HCColors.textPrimary)
            
            // 분
            Picker("분", selection: Binding(
                get: { minute },
                set: { onMinuteChange($0) }
            )) {
                ForEach([0, 30], id: \.self) { m in
                    Text(String(format: "%02d", m)).tag(m)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 50, height: 80)
            .clipped()
        }
    }
    
    // MARK: - 아침/저녁형 버튼
    
    @ViewBuilder
    private func chronotypeButton(_ type: Chronotype) -> some View {
        let isSelected = store.chronotype == type
        
        Button {
            store.send(.setChronotype(type))
        } label: {
            VStack(spacing: HCSpacing.xs) {
                Text(type.emoji)
                    .font(.system(size: 28))
                
                Text(type.displayName)
                    .font(HCTypography.titleSmall)
                    .foregroundStyle(isSelected ? .white : HCColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, HCSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: HCRadius.lg)
                    .fill(isSelected ? HCColors.primary : HCColors.primary.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: HCRadius.lg)
                    .stroke(isSelected ? Color.clear : HCColors.primary.opacity(0.2), lineWidth: 1)
            )
        }
        .pressEffect()
        .animation(HCAnimation.quick, value: isSelected)
    }
}

#Preview {
    ZStack {
        HCColors.splashGradient.ignoresSafeArea()
        QuickSetupView(
            store: Store(initialState: OnboardingFeature.State(currentPage: .quickSetup)) {
                OnboardingFeature()
            }
        )
    }
}
