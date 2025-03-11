import SwiftUI

struct CalendarGrid: View {
    let days: [CalendarDay]
    let onDateSelected: (Date) -> Void
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(days) { day in
                if let date = day.date {
                    DayCell(day: day) { onDateSelected(date) }
                } else {
                    EmptyView()
                }
            }
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
    }
} 
