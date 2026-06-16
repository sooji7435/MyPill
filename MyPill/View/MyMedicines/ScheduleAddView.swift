import SwiftUI

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
    @State private var showDateSheet = false
    @State private var showTimeSheet = false

    private let iconList = ["pill", "vitamin_C", "vitamin_D", "omega3", "doctor"]
    private var isEditing: Bool { scheduleToEdit != nil }
    private var canSave: Bool { !title.isEmpty && !iconName.isEmpty }

    init(scheduleToEdit: Schedule? = nil) {
        self.scheduleToEdit = scheduleToEdit
        let t = scheduleToEdit?.takeTime ?? Date()
        _title        = State(initialValue: scheduleToEdit?.title ?? "")
        _selectedDate = State(initialValue: t)
        _selectedTime = State(initialValue: t)
        _description  = State(initialValue: scheduleToEdit?.description ?? "")
        _iconName     = State(initialValue: scheduleToEdit?.iconName ?? "")
        _repeatType   = State(initialValue: scheduleToEdit?.repeatType ?? .none)
    }

    var body: some View {
        VStack(spacing: 20) {
            navigationBar
            Form {
                titleSection
                dateSection
                timeSection
                if !isEditing { repeatSection }
                memoSection
                iconSection
            }
            .scrollContentBackground(.hidden)
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .sheet(isPresented: $showDateSheet) { dateSheet }
        .sheet(isPresented: $showTimeSheet) { timeSheet }
    }

    private var navigationBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark").font(.title2).foregroundStyle(.gray)
            }
            Spacer()
            Text(isEditing ? "일정 편집" : "새로운 일정 추가")
                .font(.custom("Cafe24Dongdong", size: 28))
                .foregroundStyle(.primary)
            Spacer()
            Button { save() } label: {
                Text("저장")
                    .font(.custom("Cafe24Dongdong", size: 24))
                    .foregroundStyle(canSave ? Color.MainColor : .gray)
            }
            .disabled(!canSave)
        }
        .padding()
    }

    private var titleSection: some View {
        Section(header: sectionHeader("일정 제목")) {
            TextField("예: 아침 약 복용", text: $title)
                .font(.custom("Cafe24Dongdong", size: 22))
        }
    }

    private var dateSection: some View {
        Section(header: sectionHeader("날짜")) {
            Button { showDateSheet = true } label: {
                HStack {
                    Text(selectedDate.formatted(date: .numeric, time: .omitted))
                        .font(.custom("Cafe24Dongdong", size: 22)).foregroundStyle(.primary)
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
                        .font(.custom("Cafe24Dongdong", size: 22)).foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "clock").foregroundStyle(Color.MainColor)
                }
            }
        }
    }

    private var repeatSection: some View {
        Section(header: sectionHeader("반복")) {
            Picker("반복", selection: $repeatType) {
                ForEach(RepeatType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var memoSection: some View {
        Section(header: sectionHeader("메모")) {
            TextField("예: 식후 복용", text: $description)
                .font(.custom("Cafe24Dongdong", size: 20))
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

    private var dateSheet: some View {
        VStack {
            Text("날짜 선택").font(.custom("Cafe24Dongdong", size: 28)).foregroundStyle(.primary).padding(.top)
            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical).tint(Color.TintColor).padding()
        }
    }

    private var timeSheet: some View {
        VStack {
            Text("시간 선택").font(.custom("Cafe24Dongdong", size: 28)).foregroundStyle(.primary).padding(.top)
            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel).labelsHidden().padding()
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text).font(.custom("Cafe24Dongdong", size: 20)).foregroundStyle(.primary)
    }

    private func save() {
        let mergedTime = mergeDateAndTime(date: selectedDate, time: selectedTime)
        if let editing = scheduleToEdit {
            let updated = Schedule(
                id: editing.id,
                title: title,
                description: description.isEmpty ? nil : description,
                iconName: iconName,
                takeTime: mergedTime,
                isTaken: editing.isTaken,
                isMissed: editing.isMissed,
                repeatType: editing.repeatType,
                repeatGroupID: editing.repeatGroupID
            )
            schedulesViewModel.editSchedule(old: editing, new: updated)
        } else {
            schedulesViewModel.addSchedule(
                title: title,
                takeTime: mergedTime,
                description: description.isEmpty ? nil : description,
                iconName: iconName,
                repeatType: repeatType
            )
        }
        dismiss()
    }

    private func mergeDateAndTime(date: Date, time: Date) -> Date {
        let cal = Calendar.current
        var components = cal.dateComponents([.year, .month, .day], from: date)
        let t = cal.dateComponents([.hour, .minute], from: time)
        components.hour   = t.hour
        components.minute = t.minute
        return cal.date(from: components) ?? date
    }
}

#Preview {
    ScheduleAddView()
        .environmentObject(SchedulesViewModel())
}
