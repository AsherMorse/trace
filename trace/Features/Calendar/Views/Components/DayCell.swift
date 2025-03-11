import SwiftUI

struct DayCell: View {
    let day: CalendarDay
    let onSelect: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onSelect) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.clear)
                
                if day.isSelected {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.accentColor)
                        .shadow(color: Color.accentColor.opacity(0.3), radius: 2, x: 0, y: 1)
                } else if day.isToday {
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(Color.accentColor, lineWidth: 1.5)
                } else if isHovered {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Theme.primary.opacity(0.05))
                }
                
                if let date = day.date {
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(day.isSelected || day.isToday ? Theme.bodyFont.weight(.semibold) : Theme.bodyFont)
                        .foregroundColor(textColor)
                }
            }
        }
        .buttonStyle(.plain)
        .frame(height: 36)
        .contentShape(Rectangle())
        .onHover { isHovered = day.isInCurrentMonth ? $0 : false }
    }
    
    private var textColor: Color {
        day.isSelected ? .white :
        !day.isInCurrentMonth ? Theme.tertiary :
        day.isToday ? .accentColor : Theme.primary
    }
} 