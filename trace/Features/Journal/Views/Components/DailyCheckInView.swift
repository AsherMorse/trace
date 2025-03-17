import SwiftUI

struct DailyCheckInView: View {
    @Bindable var viewModel: JournalViewModel
    @State private var selectedMood: String = "Good" {
        didSet {
            updateViewModel()
        }
    }
    @State private var dailyHighlight: String = "" {
        didSet {
            updateViewModel()
        }
    }
    @State private var dailyOverview: String = "" {
        didSet {
            updateViewModel()
        }
    }
    @FocusState private var isTextFieldFocused: Bool
    
    private let moodOptions = ["Great", "Good", "Neutral", "Tired", "Stressed", "Upset"]
    
    var body: some View {
        SectionContainer {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's Mood")
                        .font(.headline)
                    
                    HStack(spacing: 8) {
                        ForEach(moodOptions, id: \.self) { mood in
                            Button(action: {
                                selectedMood = mood
                            }) {
                                Text(mood)
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                            }
                            .buttonStyle(.plain)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedMood == mood ? 
                                          Color(NSColor.controlBackgroundColor) : 
                                          Color.clear)
                            )
                        }
                        Spacer()
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's Highlight")
                        .font(.headline)
                    
                    TextField("What made today special?", text: $dailyHighlight)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                        .focused($isTextFieldFocused)
                        .onChange(of: dailyHighlight) { _, newValue in
                            updateViewModel()
                        }
                }
                
                JournalTextEditor(
                    title: "Daily Overview",
                    text: $dailyOverview
                )
                .frame(minHeight: 150)
                .onChange(of: dailyOverview) { _, newValue in
                    updateViewModel()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .onAppear {
                loadFromViewModel()
            }
        }
    }
    
    private func updateViewModel() {
        var entry = viewModel.currentEntry ?? JournalEntry(date: viewModel.selectedDate ?? Date())
        entry.dailyCheckIn.mood = selectedMood
        entry.dailyCheckIn.todaysHighlight = dailyHighlight
        entry.dailyCheckIn.dailyOverview = dailyOverview
        
        viewModel.updateEntrySection(entry)
    }
    
    private func loadFromViewModel() {
        if let entry = viewModel.currentEntry {
            selectedMood = entry.dailyCheckIn.mood.isEmpty ? "Good" : entry.dailyCheckIn.mood
            dailyHighlight = entry.dailyCheckIn.todaysHighlight
            dailyOverview = entry.dailyCheckIn.dailyOverview
        }
    }
}

#Preview {
    DailyCheckInView(viewModel: JournalViewModel())
        .frame(width: 600)
        .padding()
} 
