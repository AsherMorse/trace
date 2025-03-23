import SwiftUI

struct DailyCheckInView: View {
    @Bindable var viewModel: DailyCheckInViewModel
    private let moodOptions = ["Great", "Good", "Neutral", "Tired", "Stressed", "Upset"]
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        SectionContainer {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's Mood")
                        .font(.headline)
                    
                    HStack(spacing: 8) {
                        ForEach(moodOptions, id: \.self) { mood in
                            Button(action: {
                                viewModel.mood = mood
                            }) {
                                Text(mood)
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .foregroundColor(viewModel.mood == mood ? .white : Theme.primary)
                            }
                            .buttonStyle(.plain)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(viewModel.mood == mood ? 
                                          Color.accentColor : 
                                          Color.clear)
                            )
                        }
                        Spacer()
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's Highlight")
                        .font(.headline)
                    
                    TextField("What made today special?", text: $viewModel.todaysHighlight)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                        .focused($isTextFieldFocused)
                }
                
                JournalTextEditor(
                    title: "Daily Overview",
                    text: $viewModel.dailyOverview,
                    minHeight: 150
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    DailyCheckInView(viewModel: DailyCheckInViewModel())
        .frame(width: 600)
        .padding()
} 
