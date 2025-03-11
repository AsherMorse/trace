import SwiftUI

// MARK: - Calendar View
struct CalendarView: View {
    @StateObject private var model = CalendarViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationBar(title: model.monthYearString, leadingAction: model.previousMonth, trailingAction: model.nextMonth)
                .background(Theme.backgroundNav)
            
            Divider().opacity(0.5)
            
            WeekdayHeader(weekdays: model.weekdaySymbols)
                .background(Theme.backgroundSecondary)
            
            CalendarGrid(days: model.days, onDateSelected: model.handleDateSelection)
                .frame(maxHeight: .infinity)
        }
        .background(Theme.backgroundFill)
        .frame(minWidth: 320, maxWidth: 600, minHeight: 340, maxHeight: 340)
    }
}

// MARK: - Preview
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CalendarView()
        }
    }
} 
