import SwiftUI

struct PersonalGrowthView: View {
    @Bindable var viewModel: JournalViewModel
    @State private var reflections: String = "" {
        didSet {
            updateViewModel()
        }
    }
    @State private var achievements: String = "" {
        didSet {
            updateViewModel()
        }
    }
    @State private var challenges: String = "" {
        didSet {
            updateViewModel()
        }
    }
    @State private var goals: String = "" {
        didSet {
            updateViewModel()
        }
    }
    
    var body: some View {
        SectionContainer {
            VStack(alignment: .leading, spacing: 16) {
                JournalTextEditor(
                    title: "Reflections",
                    text: $reflections
                )
                .frame(minHeight: 100)
                .onChange(of: reflections) { _, _ in
                    updateViewModel()
                }
                
                JournalTextEditor(
                    title: "Achievements",
                    text: $achievements
                )
                .frame(minHeight: 100)
                .onChange(of: achievements) { _, _ in
                    updateViewModel()
                }
                
                JournalTextEditor(
                    title: "Challenges",
                    text: $challenges
                )
                .frame(minHeight: 100)
                .onChange(of: challenges) { _, _ in
                    updateViewModel()
                }
                
                JournalTextEditor(
                    title: "Goals",
                    text: $goals
                )
                .frame(minHeight: 100)
                .onChange(of: goals) { _, _ in
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
        // Create a JournalEntry with updated values and convert to markdown
        var entry = viewModel.currentEntry ?? JournalEntry(date: viewModel.selectedDate ?? Date())
        entry.personalGrowth.reflections = reflections
        entry.personalGrowth.achievements = achievements
        entry.personalGrowth.challenges = challenges
        entry.personalGrowth.goals = goals
        
        // Update the viewModel's editedContent with new markdown
        viewModel.updateEntrySection(entry)
    }
    
    private func loadFromViewModel() {
        if let entry = viewModel.currentEntry {
            reflections = entry.personalGrowth.reflections
            achievements = entry.personalGrowth.achievements
            challenges = entry.personalGrowth.challenges
            goals = entry.personalGrowth.goals
        }
    }
}

#Preview {
    PersonalGrowthView(viewModel: JournalViewModel())
        .frame(width: 600)
        .padding()
} 
