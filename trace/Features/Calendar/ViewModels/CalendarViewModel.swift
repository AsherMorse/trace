import SwiftUI

final class CalendarViewModel: ObservableObject {
    @Published var selectedDate = Date()
    @Published var displayedMonth = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter().with { $0.dateFormat = "MMMM yyyy" }
    
    init(externalSelectedDate: Date? = nil) {
        if let externalDate = externalSelectedDate {
            self.selectedDate = externalDate
            self.displayedMonth = externalDate
        }
    }
    
    func updateWithExternalDate(_ date: Date?) {
        guard let date = date else { return }
        
        if !calendar.isDate(selectedDate, inSameDayAs: date) {
            print("📅 CalendarViewModel: Updating selected date from external source: \(date)")
            selectedDate = date
            
            if !calendar.isDate(displayedMonth, equalTo: date, toGranularity: .month) {
                displayedMonth = date
            }
        }
    }
    
    var monthYearString: String { dateFormatter.string(from: displayedMonth) }
    
    var weekdaySymbols: [String] {
        let formatter = DateFormatter().with { $0.dateFormat = "EEE" }
        
        let weekdays = (1...7).compactMap { weekday -> String? in
            guard let date = calendar.date(from: DateComponents(weekday: weekday)) else {
                return nil
            }
            return formatter.string(from: date)
        }
        
        let firstWeekday = calendar.firstWeekday
        return firstWeekday > 1 ? Array(weekdays[(firstWeekday - 1)...] + weekdays[..<(firstWeekday - 1)]) : weekdays
    }
    
    var days: [CalendarDay] {
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let firstDayOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let offset = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        var days = (0..<offset).map { CalendarDay.empty(at: $0) }
        var position = offset
        
        days += (1...range.count).map { day -> CalendarDay in
            guard let date = calendar.date(from: DateComponents(year: components.year, month: components.month, day: day)) else {
                defer { position += 1 }
                return .empty(at: position)
            }
            
            defer { position += 1 }
            return CalendarDay(
                date: date,
                isInCurrentMonth: true,
                isToday: calendar.isDateInToday(date),
                isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                position: position
            )
        }
        
        days += (0..<(42 - days.count)).map { .empty(at: position + $0) }
        return days
    }
    
    func previousMonth() { changeMonth(by: -1) }
    func nextMonth() { changeMonth(by: 1) }
    
    func changeMonth(by value: Int) {
        displayedMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) ?? displayedMonth
    }
}

extension DateFormatter {
    func with(_ configure: (DateFormatter) -> Void) -> DateFormatter {
        configure(self)
        return self
    }
} 
