import SwiftUI

/// Seven-day enamel week strip showing which days had care.
public struct CareCalendarStrip: View {
    private let days: [CareCalendarDay]
    private let selectedDay: Date?
    private let onSelect: ((Date) -> Void)?

    public init(
        days: [CareCalendarDay],
        selectedDay: Date? = nil,
        onSelect: ((Date) -> Void)? = nil
    ) {
        self.days = days
        self.selectedDay = selectedDay
        self.onSelect = onSelect
    }

    /// Builds a week strip ending today from completed day starts.
    public init(
        completedDays: Set<Date>,
        referenceDate: Date = Date(),
        calendar: Calendar = .current,
        onSelect: ((Date) -> Void)? = nil
    ) {
        let starts = DenlyCalendar.daysBack(7, from: referenceDate, calendar: calendar)
        self.days = starts.map { day in
            CareCalendarDay(
                day: day,
                hasCare: completedDays.contains(calendar.startOfDay(for: day)),
                isToday: calendar.isDateInToday(day)
            )
        }
        self.selectedDay = calendar.startOfDay(for: referenceDate)
        self.onSelect = onSelect
    }

    public var body: some View {
        HStack(spacing: 8) {
            ForEach(days) { day in
                Button {
                    onSelect?(day.day)
                } label: {
                    VStack(spacing: 6) {
                        Text(day.weekdayLabel)
                            .font(EnamelType.badge(10))
                            .foregroundStyle(EnamelPalette.inkDim)
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(fill(for: day))
                                .frame(width: 36, height: 40)
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .strokeBorder(
                                    day.isToday ? EnamelPalette.ink : EnamelPalette.ink.opacity(0.2),
                                    lineWidth: day.isToday ? 2 : 1
                                )
                                .frame(width: 36, height: 40)
                            Text(day.dayNumber)
                                .font(EnamelType.bodyBold(14))
                                .foregroundStyle(day.hasCare ? EnamelPalette.cream : EnamelPalette.ink)
                        }
                    }
                }
                .buttonStyle(.plain)
                .disabled(onSelect == nil)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Care calendar week")
    }

    private func fill(for day: CareCalendarDay) -> Color {
        if day.hasCare { return EnamelPalette.green }
        if isSelected(day) { return EnamelPalette.mustard.opacity(0.35) }
        return EnamelPalette.cream
    }

    private func isSelected(_ day: CareCalendarDay) -> Bool {
        guard let selectedDay else { return false }
        return Calendar.current.isDate(day.day, inSameDayAs: selectedDay)
    }
}

/// One cell on the care calendar strip.
public struct CareCalendarDay: Identifiable, Hashable, Sendable {
    public let day: Date
    public let hasCare: Bool
    public let isToday: Bool

    public var id: Date { day }

    public init(day: Date, hasCare: Bool, isToday: Bool) {
        self.day = day
        self.hasCare = hasCare
        self.isToday = isToday
    }

    public var weekdayLabel: String {
        day.formatted(.dateTime.weekday(.narrow))
    }

    public var dayNumber: String {
        day.formatted(.dateTime.day())
    }
}
