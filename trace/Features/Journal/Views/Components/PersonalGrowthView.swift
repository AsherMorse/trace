import SwiftUI

struct PersonalGrowthView: View {
    @State private var reflections: String = ""
    @State private var achievements: String = ""
    @State private var challenges: String = ""
    @State private var goals: String = ""
    
    var body: some View {
        SectionContainer {
            VStack(alignment: .leading, spacing: 16) {
                JournalTextEditor(
                    title: "Reflections",
                    text: $reflections
                )
                .frame(minHeight: 100)
                
                JournalTextEditor(
                    title: "Achievements",
                    text: $achievements
                )
                .frame(minHeight: 100)
                
                JournalTextEditor(
                    title: "Challenges",
                    text: $challenges
                )
                .frame(minHeight: 100)
                
                JournalTextEditor(
                    title: "Goals",
                    text: $goals
                )
                .frame(minHeight: 100)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    PersonalGrowthView()
        .frame(width: 600)
        .padding()
} 
