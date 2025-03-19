import SwiftUI

struct LoadingStateView: View {
    let date: Date?
    let formatDate: (Date) -> String
    
    init(date: Date? = nil, formatDate: @escaping (Date) -> String = { $0.formatted(date: .abbreviated, time: .omitted) }) {
        self.date = date
        self.formatDate = formatDate
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            
            Text("Loading...")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if let date = date {
                Text(formatDate(date))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LoadingStateView(date: Date())
} 
