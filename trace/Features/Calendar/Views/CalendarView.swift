import SwiftUI

// MARK: - Calendar View
struct CalendarView: View {
    @StateObject private var model = CalendarViewModel()
    var onDateSelected: ((Date) -> Void)?
    var selectedDate: Date?
    
    init(selectedDate: Date? = nil, onDateSelected: ((Date) -> Void)? = nil) {
        self.selectedDate = selectedDate
        self.onDateSelected = onDateSelected
        // Initialize a state object with the selectedDate
        _model = StateObject(wrappedValue: CalendarViewModel(externalSelectedDate: selectedDate))
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
        .onChange(of: selectedDate) { _, newValue in
            model.updateWithExternalDate(newValue)
        }
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
