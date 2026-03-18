//
//  ScheduleAddView.swift
//  PillManager
//

import SwiftUI

struct ScheduleAddView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var schedulesViewModel: SchedulesViewModel

    @State private var title: String = ""
    @State private var selectedDate: Date = Date()
    @State private var selectedTime: Date = Date()
    @State private var description: String = ""
    @State private var iconName: String = ""
    @State private var showDateSheet = false
    @State private var showTimeSheet = false

    private let iconList = ["pill", "vitamin_C", "vitamin_D", "omega3", "doctor"]
    private var canSave: Bool { !title.isEmpty && !iconName.isEmpty }

    var body: some View {
        VStack(spacing: 20) {
            navigationBar
            Form {
                titleSection
                dateSection
                timeSection
                memoSection
                iconSection
            }
            .scrollContentBackground(.hidden)
        }
        .background(Color.white)
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
            Text("새로운 일정 추가")
                .font(.custom("Cafe24Dongdong", size: 28))
                .foregroundStyle(.black)
            Spacer()
            Button {
                schedulesViewModel.addSchedule(
                    title: title,
                    takeTime: mergeDateAndTime(date: selectedDate, time: selectedTime),
                    description: description.isEmpty ? nil : description,
                    iconName: iconName
                )
                dismiss()
            } label: {
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
                        .font(.custom("Cafe24Dongdong", size: 22)).foregroundStyle(.black)
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
                        .font(.custom("Cafe24Dongdong", size: 22)).foregroundStyle(.black)
                    Spacer()
                    Image(systemName: "clock").foregroundStyle(Color.MainColor)
                }
            }
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
            Text("날짜 선택").font(.custom("Cafe24Dongdong", size: 28)).foregroundStyle(.black).padding(.top)
            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical).tint(Color.TintColor).padding()
        }
    }

    private var timeSheet: some View {
        VStack {
            Text("시간 선택").font(.custom("Cafe24Dongdong", size: 28)).foregroundStyle(.black).padding(.top)
            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel).labelsHidden().padding()
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text).font(.custom("Cafe24Dongdong", size: 20)).foregroundStyle(.black)
    }

    private func mergeDateAndTime(date: Date, time: Date) -> Date {
        let cal = Calendar.current
        var components = cal.dateComponents([.year, .month, .day], from: date)
        let t = cal.dateComponents([.hour, .minute], from: time)
        components.hour = t.hour
        components.minute = t.minute
        return cal.date(from: components) ?? date
    }
}

#Preview {
    ScheduleAddView()
        .environmentObject(SchedulesViewModel())
}
