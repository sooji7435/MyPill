//
//  StatsView.swift
//  MyPill
//

import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject var schedulesViewModel: SchedulesViewModel
    @StateObject private var statsVM = StatsViewModel()

    @State private var selectedTab: StatTab = .weekly

    enum StatTab: String, CaseIterable {
        case weekly  = "주간"
        case monthly = "월간"
    }

    var currentStats: [DayStat] {
        selectedTab == .weekly ? statsVM.weeklyStats : statsVM.monthlyStats
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - 전체 복용률 링
                    adherenceRing

                    // MARK: - 탭 피커
                    Picker("기간", selection: $selectedTab) {
                        ForEach(StatTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // MARK: - 막대 차트
                    barChart
                        .padding(.horizontal)

                    // MARK: - 요약 카드
                    summaryCards
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("복용 통계")
            .onAppear { statsVM.calculate(from: schedulesViewModel.schedules) }
            .onChange(of: schedulesViewModel.schedules) { _, new in
                statsVM.calculate(from: new)
            }
        }
    }

    // MARK: - 전체 복용률 원형 표시
    private var adherenceRing: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.BackGroundColor.opacity(0.2), lineWidth: 16)
                    .frame(width: 140, height: 140)

                Circle()
                    .trim(from: 0, to: statsVM.overallRate)
                    .stroke(Color.appColor4, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: statsVM.overallRate)

                VStack {
                    Text("\(Int(statsVM.overallRate * 100))%")
                        .font(.custom("Cafe24Dongdong", size: 32))
                        .foregroundStyle(Color.appColor4)
                    Text("전체 복용률")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.top)
    }

    // MARK: - 막대 차트
    private var barChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(selectedTab == .weekly ? "최근 7일" : "이번 달 주별")
                .font(.custom("Cafe24Dongdong", size: 20))

            Chart(currentStats) { stat in
                BarMark(
                    x: .value("날짜", stat.label),
                    y: .value("복용률", stat.adherenceRate)
                )
                .foregroundStyle(
                    stat.adherenceRate >= 0.8 ? Color.MainColor :
                    stat.adherenceRate >= 0.5 ? Color.orange : Color.color4
                )
                .cornerRadius(6)

                // 목표선 (80%)
                RuleMark(y: .value("목표", 0.75))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                    .foregroundStyle(.gray.opacity(0.5))
                    .annotation(position: .top, alignment: .trailing) {
                        Text("목표 75%").font(.caption2).foregroundStyle(.gray)
                    }
            }
            .chartYScale(domain: 0...1)
            .chartYAxis {
                AxisMarks(values: [0, 0.25, 0.5, 0.75, 1.0]) { value in
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text("\(Int(v * 100))%").font(.caption2)
                        }
                    }
                    AxisGridLine()
                }
            }
            .frame(height: 200)
            .animation(.easeInOut, value: selectedTab)
        }
        .padding()
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }

    // MARK: - 요약 카드
    private var summaryCards: some View {
        let stats   = currentStats
        let taken   = stats.reduce(0) { $0 + $1.taken }
        let total   = stats.reduce(0) { $0 + $1.total }
        let missed  = total - taken
        let perfect = stats.filter { $0.total > 0 && $0.taken == $0.total }.count

        return HStack(spacing: 12) {
            StatCard(title: "복용 완료", value: "\(taken)회", color: .MainColor)
            StatCard(title: "누락",     value: "\(missed)회", color: .red)
            StatCard(title: "완벽한 날", value: "\(perfect)일", color: .orange)
        }
    }
}

// MARK: - 요약 카드 컴포넌트
struct StatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.custom("Cafe24Dongdong", size: 24))
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    StatsView()
        .environmentObject(SchedulesViewModel())
}
