import SwiftUI
import ComposableArchitecture

// MARK: - 할 일 편집/추가 모달 뷰

struct EditTaskView: View {
    let task: TaskData? // nil이면 새 할 일 추가
    let onSave: (TaskData) -> Void
    let onCancel: () -> Void
    
    @State private var title: String
    @State private var category: TaskCategory
    @State private var startTime: Date
    @State private var durationHours: Int
    @State private var durationMinutes: Int
    
    init(task: TaskData?, onSave: @escaping (TaskData) -> Void, onCancel: @escaping () -> Void) {
        self.task = task
        self.onSave = onSave
        self.onCancel = onCancel
        
        let initialTask = task ?? TaskData(
            title: "",
            category: "work",
            startTime: Date.today(hour: 9),
            duration: 3600
        )
        
        _title = State(initialValue: initialTask.title)
        _category = State(initialValue: initialTask.categoryEnum)
        _startTime = State(initialValue: initialTask.startTime)
        
        let totalMins = Int(initialTask.duration / 60)
        _durationHours = State(initialValue: totalMins / 60)
        _durationMinutes = State(initialValue: totalMins % 60)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // 내용
                Section("할 일") {
                    TextField("예: 기획서 작성", text: $title)
                        .font(HCTypography.bodyLarge)
                }
                
                // 카테고리
                Section("카테고리") {
                    Picker("선택", selection: $category) {
                        ForEach(TaskCategory.allCases) { cat in
                            Text("\(cat.emoji) \(cat.displayName)").tag(cat)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // 시간
                Section("일정") {
                    DatePicker("시작 시간", selection: $startTime, displayedComponents: .hourAndMinute)
                    
                    HStack {
                        Text("소요 시간")
                        Spacer()
                        
                        Picker("시간", selection: $durationHours) {
                            ForEach(0..<13) { h in Text("\(h)시간").tag(h) }
                        }
                        .labelsHidden()
                        .frame(width: 80)
                        .clipped()
                        
                        Picker("분", selection: $durationMinutes) {
                            ForEach([0, 15, 30, 45], id: \.self) { m in Text("\(m)분").tag(m) }
                        }
                        .labelsHidden()
                        .frame(width: 80)
                        .clipped()
                    }
                }
            }
            .navigationTitle(task == nil ? "새 할 일" : "할 일 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        save()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || (durationHours == 0 && durationMinutes == 0))
                }
            }
        }
    }
    
    private func save() {
        let duration = TimeInterval((durationHours * 3600) + (durationMinutes * 60))
        let newTaskData = TaskData(
            id: task?.id ?? UUID().uuidString,
            title: title.trimmingCharacters(in: .whitespaces),
            category: category.rawValue,
            startTime: startTime,
            duration: duration,
            isEdited: task != nil // 수정하는 경우 편집 상태로 마크
        )
        onSave(newTaskData)
    }
}

#Preview {
    EditTaskView(task: nil, onSave: { _ in }, onCancel: {})
}
