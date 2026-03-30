import SwiftUI
import ComposableArchitecture

// MARK: - 설정 Feature

@Reducer
struct SettingsFeature {
    
    @ObservableState
    struct State: Equatable {
        var workStartHour: Int = 9
        var workEndHour: Int = 18
        var chronotype: Chronotype = .morning
        var aiPreference: AIPreference = .balanced
        var notificationsEnabled: Bool = true
        var isLoggedIn: Bool = false
        var userName: String = "Mock 사용자"
    }
    
    enum Action: Equatable {
        case setWorkStartHour(Int)
        case setWorkEndHour(Int)
        case setChronotype(Chronotype)
        case setAIPreference(AIPreference)
        case toggleNotifications
        case logout
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .setWorkStartHour(let hour):
                state.workStartHour = hour
                return .none
            case .setWorkEndHour(let hour):
                state.workEndHour = hour
                return .none
            case .setChronotype(let type):
                state.chronotype = type
                return .none
            case .setAIPreference(let pref):
                state.aiPreference = pref
                return .none
            case .toggleNotifications:
                state.notificationsEnabled.toggle()
                return .none
            case .logout:
                state.isLoggedIn = false
                return .none
            }
        }
    }
}

// MARK: - 설정 화면

struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    var body: some View {
        List {
            // 프로필 섹션
            Section {
                HStack(spacing: HCSpacing.md) {
                    Circle()
                        .fill(HCColors.primaryGradient)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text("M")
                                .font(HCTypography.headlineMedium)
                                .foregroundStyle(.white)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.userName)
                            .font(HCTypography.titleLarge)
                        Text("Mock 로그인")
                            .font(HCTypography.caption)
                            .foregroundStyle(HCColors.textTertiary)
                    }
                }
                .padding(.vertical, HCSpacing.xxs)
            }
            
            // 근무 시간 섹션
            Section("근무 시간") {
                Stepper("출근 시간: \(String(format: "%02d:00", store.workStartHour))", value: Binding(
                    get: { store.workStartHour },
                    set: { store.send(.setWorkStartHour($0)) }
                ), in: 5...12)
                
                Stepper("퇴근 시간: \(String(format: "%02d:00", store.workEndHour))", value: Binding(
                    get: { store.workEndHour },
                    set: { store.send(.setWorkEndHour($0)) }
                ), in: 15...23)
            }
            
            // 생활 패턴 섹션
            Section("생활 패턴") {
                Picker("유형", selection: Binding(
                    get: { store.chronotype },
                    set: { store.send(.setChronotype($0)) }
                )) {
                    ForEach(Chronotype.allCases, id: \.rawValue) { type in
                        Text("\(type.emoji) \(type.displayName)").tag(type)
                    }
                }
            }
            
            // AI 설정 섹션
            Section("AI 성향") {
                Picker("코칭 스타일", selection: Binding(
                    get: { store.aiPreference },
                    set: { store.send(.setAIPreference($0)) }
                )) {
                    ForEach(AIPreference.allCases, id: \.rawValue) { pref in
                        Text("\(pref.emoji) \(pref.displayName)").tag(pref)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // 알림 섹션
            Section("알림") {
                Toggle("알림 허용", isOn: Binding(
                    get: { store.notificationsEnabled },
                    set: { _ in store.send(.toggleNotifications) }
                ))
            }
            
            // 정보 섹션
            Section("앱 정보") {
                HStack {
                    Text("버전")
                    Spacer()
                    Text("1.0.0 (MVP)")
                        .foregroundStyle(HCColors.textTertiary)
                }
                
                HStack {
                    Text("빌드")
                    Spacer()
                    Text("Mock Mode")
                        .foregroundStyle(HCColors.secondary)
                }
            }
        }
        .navigationTitle("설정")
    }
}

#Preview {
    NavigationStack {
        SettingsView(
            store: Store(initialState: SettingsFeature.State()) {
                SettingsFeature()
            }
        )
    }
}
