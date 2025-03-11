import SwiftUI

// MARK: - Calendar View
struct CalendarView: View {
    @StateObject private var model = CalendarViewModel()
    var onDateSelected: ((Date) -> Void)?
    
    init(onDateSelected: ((Date) -> Void)? = nil) {
        self.onDateSelected = onDateSelected
    }
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationBar(title: model.monthYearString, leadingAction: model.previousMonth, trailingAction: model.nextMonth)
                .background(Theme.backgroundNav)
            
            Divider().opacity(0.5)
            
            WeekdayHeader(weekdays: model.weekdaySymbols)
                .background(Theme.backgroundSecondary)
            
            CalendarGrid(days: model.days, onDateSelected: { date in
                model.selectedDate = date
                
                if let callback = onDateSelected {
                    callback(date)
                }
            })
                .frame(maxHeight: .infinity)
        }
        .background(Theme.backgroundFill)
        .frame(
            minWidth: 320,
            idealWidth: 320,
            maxWidth: 600,
            minHeight: 300,
            maxHeight: 300
        )
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
