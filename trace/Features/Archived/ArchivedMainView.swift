import SwiftUI

struct ArchivedMainView: View {
    @StateObject private var journalViewModel = JournalViewModel()
    
    var body: some View {
        HSplitView {
            VStack(spacing: 0) {
                CalendarView(onDateSelected: { date in
                    journalViewModel.selectedDate = date
                })
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    Text("Quick Actions")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    Button(action: {
                        if let date = journalViewModel.selectedDate {
                            journalViewModel.createEntry(for: date)
                        } else {
                            journalViewModel.createEntry(for: Date())
                        }
                    }) {
                        Label("Record New Entry", systemImage: "square.and.pencil")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: {
                        journalViewModel.openTodaysEntry()
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
                    
                    Button(action: {
                        FolderManager.shared.resetFolderSelection()
                    }) {
                        Label("Reset Folder Selection", systemImage: "folder.badge.minus")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                    
                    Spacer()
                }
                .padding()
                .background(Theme.backgroundSecondary)
            }
            .frame(minWidth: 320, maxHeight: .infinity)
            .layoutPriority(1)

            JournalContentView(viewModel: journalViewModel)
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

struct JournalContentView: View {
    @ObservedObject var viewModel: JournalViewModel
    
    var body: some View {
        VStack {
            if viewModel.selectedDate == nil {
                // No date selected state
                Text("No Date Selected")
                    .font(.title)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Select a date in the calendar to see journal entries")
                    .foregroundColor(.secondary)
                
                Spacer()
            } else if viewModel.isLoading {
                // Loading state
                ProgressView("Loading journal entry...")
            } else if viewModel.hasError {
                // Error state
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    
                    Text("No journal entry found for this date")
                        .multilineTextAlignment(.center)
                    
                    Button("Create New Entry") {
                        if let date = viewModel.selectedDate {
                            viewModel.createEntry(for: date)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top)
                }
                .padding()
            } else {
                // Content state
                ScrollView {
                    VStack(alignment: .leading) {
                        if let date = viewModel.selectedDate {
                            HStack {
                                Text(dateFormatter.string(from: date))
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button("Edit") {
                                    // Edit action for future implementation
                                }
                            }
                            .padding(.bottom)
                        }
                        
                        Text(viewModel.fileContent)
                            .textSelection(.enabled)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color(NSColor.textBackgroundColor))
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
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
