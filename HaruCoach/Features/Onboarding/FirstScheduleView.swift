import SwiftUI
import ComposableArchitecture

// MARK: - 첫 스케줄 생성 화면

struct FirstScheduleView: View {
    @Bindable var store: StoreOf<OnboardingFeature>
    
    @State private var showContent = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: HCSpacing.xl) {
            Spacer()
            
            // 타이틀
            VStack(spacing: HCSpacing.xs) {
                Text("🎉")
                    .font(.system(size: 48))
                
                Text("준비 완료!")
                    .font(HCTypography.displaySmall)
                    .foregroundStyle(.white)
                
                Text("오늘 할 일을 말해보세요")
                    .font(HCTypography.bodyLarge)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
            
            // 입력 영역
            VStack(spacing: HCSpacing.sm) {
                ZStack(alignment: .topLeading) {
                    if store.firstInput.isEmpty {
                        Text("예: 오전에 기획서 마무리하고, 점심 후에 팀 미팅 1시간, 저녁에 러닝 30분이랑 영어 공부 좀 하고 싶어")
                            .font(HCTypography.bodyMedium)
                            .foregroundStyle(.white.opacity(0.4))
                            .padding(.horizontal, HCSpacing.md)
                            .padding(.vertical, HCSpacing.sm)
                    }
                    
                    TextEditor(text: Binding(
                        get: { store.firstInput },
                        set: { store.send(.setFirstInput($0)) }
                    ))
                    .font(HCTypography.bodyLarge)
                    .foregroundStyle(.white)
                    .scrollContentBackground(.hidden)
                    .focused($isInputFocused)
                    .frame(minHeight: 100, maxHeight: 150)
                    .padding(.horizontal, HCSpacing.xs)
                    .padding(.vertical, HCSpacing.xxs)
                }
                .padding(HCSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: HCRadius.xl)
                        .fill(.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: HCRadius.xl)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                )
                
                // 빠른 입력 예시 버튼들
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: HCSpacing.xs) {
                        quickInputButton("오전에 기획서, 오후 미팅")
                        quickInputButton("회의 2개, 보고서, 운동")
                        quickInputButton("어제와 같은 일정")
                    }
                }
            }
            .padding(.horizontal, HCSpacing.xl)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 30)
            
            Spacer()
            
            // 시작 버튼
            VStack(spacing: HCSpacing.sm) {
                Button {
                    store.send(.completeOnboarding)
                } label: {
                    HStack(spacing: HCSpacing.xs) {
                        Image(systemName: "sparkles")
                        Text(store.firstInput.isEmpty ? "건너뛰고 시작" : "AI로 스케줄 만들기")
                    }
                    .font(HCTypography.titleMedium)
                    .foregroundStyle(HCColors.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: HCRadius.lg))
                }
                .pressEffect()
            }
            .padding(.horizontal, HCSpacing.xl)
            .padding(.bottom, HCSpacing.xxxl)
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(HCAnimation.smooth.delay(0.2)) {
                showContent = true
            }
        }
        .onTapGesture {
            isInputFocused = false
        }
    }
    
    // MARK: - 빠른 입력 버튼
    
    @ViewBuilder
    private func quickInputButton(_ text: String) -> some View {
        Button {
            store.send(.setFirstInput(text))
        } label: {
            Text(text)
                .font(HCTypography.labelMedium)
                .foregroundStyle(.white.opacity(0.8))
                .padding(.horizontal, HCSpacing.sm)
                .padding(.vertical, HCSpacing.xxs)
                .background(
                    Capsule()
                        .fill(.white.opacity(0.15))
                        .overlay(
                            Capsule()
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                )
        }
        .pressEffect()
    }
}

#Preview {
    ZStack {
        HCColors.splashGradient.ignoresSafeArea()
        FirstScheduleView(
            store: Store(initialState: OnboardingFeature.State(currentPage: .firstSchedule)) {
                OnboardingFeature()
            }
        )
    }
}
