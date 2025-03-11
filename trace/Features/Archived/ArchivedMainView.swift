import SwiftUI

struct ArchivedMainView: View {
    var body: some View {
        HSplitView {
            VStack(spacing: 0) {
                CalendarView()
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    Text("Quick Actions")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    Button(action: {
                        print("Record New Entry")
                    }) {
                        Label("Record New Entry", systemImage: "square.and.pencil")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: {
                        print("Today's Entry")
                    }) {
                        Label("Today's Entry", systemImage: "calendar.badge.clock")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: {
                        print("Recent Entries")
                    }) {
                        Label("Recent Entries", systemImage: "clock")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: {
                        print("Search Journal")
                    }) {
                        Label("Search Journal", systemImage: "magnifyingglass")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                }
                .padding()
                .background(Theme.backgroundSecondary)
            }
            .frame(minWidth: 320, maxHeight: .infinity)
            .layoutPriority(1)

            PlaceholderView()
                .layoutPriority(2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ArchivedMainView_Previews: PreviewProvider {
    static var previews: some View {
        ArchivedMainView()
    }
}

// Placeholder view extracted to the bottom of the file
struct PlaceholderView: View {
    var body: some View {
        VStack {
            Text("Placeholder Content")
                .font(.title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("Select a date in the calendar to see details")
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color(NSColor.textBackgroundColor))
    }
} 
