import SwiftUI

struct WeekdayHeader: View {
    let weekdays: [String]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(Theme.secondaryFont)
                    .foregroundColor(Theme.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 10)
    }
} 