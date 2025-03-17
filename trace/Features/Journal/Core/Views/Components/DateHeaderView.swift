import SwiftUI

struct DateHeaderView: View {
    let date: Date
    let formatDate: (Date) -> String
    let formatDay: (Date) -> String
    
    init(
        date: Date,
        formatDate: @escaping (Date) -> String = { 
            $0.formatted(Date.FormatStyle().month(.wide).day().year()) 
        },
        formatDay: @escaping (Date) -> String = { 
            $0.formatted(Date.FormatStyle().weekday(.wide)) 
        }
    ) {
        self.date = date
        self.formatDate = formatDate
        self.formatDay = formatDay
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(formatDate(date))
                .font(.title)
                .fontWeight(.bold)
            
            Text(formatDay(date))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    VStack(spacing: 20) {
        DateHeaderView(date: Date())
        
        Divider()
        
        Text("Journal content would appear here")
            .font(.body)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding()
} 
