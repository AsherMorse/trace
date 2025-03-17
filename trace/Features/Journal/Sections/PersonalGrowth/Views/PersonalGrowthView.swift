import SwiftUI

struct PersonalGrowthView: View {
    @Bindable var viewModel: PersonalGrowthViewModel
    
    var body: some View {
        SectionContainer {
            VStack(alignment: .leading, spacing: 16) {
                JournalTextEditor(
                    title: "Reflections",
                    text: $viewModel.reflections,
                    minHeight: 100
                )
                
                JournalTextEditor(
                    title: "Achievements",
                    text: $viewModel.achievements,
                    minHeight: 100
                )
                
                JournalTextEditor(
                    title: "Challenges",
                    text: $viewModel.challenges,
                    minHeight: 100
                )
                
                JournalTextEditor(
                    title: "Goals",
                    text: $viewModel.goals,
                    minHeight: 100
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    PersonalGrowthView(viewModel: PersonalGrowthViewModel())
        .frame(width: 600)
        .padding()
} 