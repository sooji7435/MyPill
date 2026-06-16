import SwiftUI
import UserNotifications

struct ScheduleAddView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var schedulesViewModel: SchedulesViewModel

    var scheduleToEdit: Schedule? = nil

    @State private var title: String
    @State private var selectedDate: Date
    @State private var selectedTime: Date
    @State private var description: String
    @State private var iconName: String
    @State private var repeatType: RepeatType
    @State private var hasEndDate: Bool
    @State private var repeatEndDate: Date
    @State private var showDateSheet         = false
    @State private var showTimeSheet         = false
    @State private var showEndDateSheet      = false
    @State private var showNotificationAlert = false

    private let iconList = ["pill", "vitamin_C", "vitamin_D", "omega3", "doctor"]
    private var isEditing: Bool { scheduleToEdit != nil }
    private var canSave: Bool   { !title.isEmpty && !iconName.isEmpty }

    init(scheduleToEdit: Schedule? = nil) {
        self.scheduleToEdit = scheduleToEdit
        let t = scheduleToEdit?.takeTime ?? Date()
        let defaultEnd = Calendar.current.date(byAdding: .month, value: 1, to: t) ?? t
        _title         = State(initialValue: scheduleToEdit?.title ?? "")
        _selectedDate  = State(initialValue: t)
        _selectedTime  = State(initialValue: t)
        _description   = State(initialValue: scheduleToEdit?.description ?? "")
        _iconName      = State(initialValue: scheduleToEdit?.iconName ?? "")
        _repeatType    = State(initialValue: scheduleToEdit?.repeatType ?? .none)
        _hasEndDate    = State(initialValue: false)
        _repeatEndDate = State(initialValue: defaultEnd)
    }

    var body: some View {
        VStack(spacing: 20) {
            navigationBar
            Form {
                titleSection
                dateSection
                timeSection
                if isEditing {
                    if repeatType != .none { repeatReadOnlySection }
                } else {
                    repeatSection
                }
                memoSection
                iconSection
            }
            .scrollContentBackground(.hidden)
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .sheet(isPresented: $showDateSheet)    { pickerSheet("날짜 선택") {
            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical).tint(Color.TintColor).padding()
        }}
        .sheet(isPresented: $showTimeSheet)    { pickerSheet("시간 선택") {
            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel).labelsHidden().padding()
        }}
        .sheet(isPresented: $showEndDateSheet) { pickerSheet("종료일 선택") {
            DatePicker("", selection: $repeatEndDate, in: selectedDate..., displayedComponents: .date)
                .datePickerStyle(.graphical).tint(Color.TintColor).padding()
        }}
        .alert("알림 권한 없음", isPresented: $showNotificationAlert) {
            Button("설정 열기") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("그냥 저장") { performSave() }
            Button("취소", role: .cancel) {}
        } message: {
            Text("알림 권한이 없어 복용 알림을 받을 수 없습니다.\n설정에서 알림을 허용하거나 그냥 저장할 수 있습니다.")
        }
    }

    // MARK: - Navigation Bar
    private var navigationBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark").font(.title2).foregroundStyle(.gray)
            }
            Spacer()
            Text(isEditing ? "일정 편집" : "새로운 일정 추가")
                .font(.cafe(28)).foregroundStyle(.primary)
            Spacer()
            Button { save() } label: {
                Text("저장").font(.cafe(24))
                    .foregroundStyle(canSave ? Color.MainColor : .gray)
            }
            .disabled(!canSave)
        }
        .padding()
    }

    // MARK: - Sections
    private var titleSection: some View {
        Section(header: sectionHeader("일정 제목")) {
            TextField("예: 아침 약 복용", text: $title).font(.cafe(22))
        }
    }

    private var dateSection: some View {
        Section(header: sectionHeader("날짜")) {
            Button { showDateSheet = true } label: {
                HStack {
                    Text(selectedDate.formatted(date: .numeric, time: .omitted))
                        .font(.cafe(22)).foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "calendar").foregroundStyle(Color.BackGroundColor)
                }
            }
        }
    }

    private var timeSection: some View {
        Section(header: sectionHeader("시간")) {
            Button { showTimeSheet = true } label: {
                HStack {
                    Text(selectedTime.formatted(date: .omitted, time: .shortened))
                        .font(.cafe(22)).foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "clock").foregroundStyle(Color.MainColor)
                }
            }
        }
    }

    private var repeatReadOnlySection: some View {
        Section(header: sectionHeader("반복")) {
            HStack {
                Text(repeatType.rawValue).font(.cafe(22))
                Spacer()
                Text("편집 모드에서는 변경 불가").font(.caption).foregroundStyle(.tertiary)
            }
        }
    }

    private var repeatSection: some View {
        Section(header: sectionHeader("반복")) {
            Picker("반복", selection: $repeatType) {
                ForEach(RepeatType.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)

            if repeatType != .none {
                Toggle("종료일 지정", isOn: $hasEndDate)
                if hasEndDate {
                    Button { showEndDateSheet = true } label: {
                        HStack {
                            Text(repeatEndDate.formatted(date: .numeric, time: .omitted))
                                .font(.cafe(22)).foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "calendar.badge.clock").foregroundStyle(Color.MainColor)
                        }
                    }
                }
            }
        }
    }

    private var memoSection: some View {
        Section(header: sectionHeader("메모")) {
            TextField("예: 식후 복용", text: $description).font(.cafe(20))
        }
    }

    private var iconSection: some View {
        Section(header: sectionHeader("아이콘 선택")) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                ForEach(iconList, id: \.self) { icon in
                    Button { iconName = icon } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(iconName == icon ? Color.MainColor : Color.gray.opacity(0.3),
                                        lineWidth: iconName == icon ? 3 : 1)
                                .frame(height: 70)
                            Image(icon).resizable().scaledToFit().padding(25)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 6)
        }
    }

    // MARK: - 시트 헬퍼 (중복 구조 통합)
    private func pickerSheet(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack {
            Text(title).font(.cafe(28)).foregroundStyle(.primary).padding(.top)
            content()
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text).font(.cafe(20)).foregroundStyle(.primary)
    }

    // MARK: - Save
    private func save() {
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            if settings.authorizationStatus == .denied {
                showNotificationAlert = true
            } else {
                performSave()
            }
        }
    }

    private func performSave() {
        let mergedTime = mergeDateAndTime(date: selectedDate, time: selectedTime)
        if let editing = scheduleToEdit {
            schedulesViewModel.editSchedule(
                old: editing,
                new: Schedule(
                    id: editing.id, title: title,
                    description: description.isEmpty ? nil : description,
                    iconName: iconName, takeTime: mergedTime,
                    isTaken: editing.isTaken, isMissed: editing.isMissed,
                    repeatType: editing.repeatType, repeatGroupID: editing.repeatGroupID
                )
            )
        } else {
            schedulesViewModel.addSchedule(
                title: title, takeTime: mergedTime,
                description: description.isEmpty ? nil : description,
                iconName: iconName, repeatType: repeatType,
                endDate: hasEndDate ? repeatEndDate : nil
            )
        }
        dismiss()
    }

    private func mergeDateAndTime(date: Date, time: Date) -> Date {
        var c = Calendar.current.dateComponents([.year, .month, .day], from: date)
        let t = Calendar.current.dateComponents([.hour, .minute], from: time)
        c.hour = t.hour; c.minute = t.minute
        return Calendar.current.date(from: c) ?? date
    }
}

#Preview {
    ScheduleAddView().environmentObject(SchedulesViewModel())
}
