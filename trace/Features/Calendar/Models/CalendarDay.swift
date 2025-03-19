import SwiftUI

struct CalendarDay: Identifiable {
    var id: Int { position }
    let date: Date?
    let isInCurrentMonth: Bool
    let isToday: Bool
    let isSelected: Bool
    let position: Int
    
    static func empty(at position: Int) -> CalendarDay {
        CalendarDay(date: nil, isInCurrentMonth: false, isToday: false, isSelected: false, position: position)
    }
    
    var isEmpty: Bool { date == nil }
} 
