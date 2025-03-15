import SwiftUI

struct DailyCheckInView: View {
    @State private var selectedMood: String = "Good"
    @State private var dailyHighlight: String = ""
    @State private var dailyOverview: String = ""
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
                }
                
                JournalTextEditor(
                    title: "Daily Overview",
                    text: $dailyOverview
                )
                .frame(minHeight: 150)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    DailyCheckInView()
        .frame(width: 600)
        .padding()
} 
