import SwiftUI

struct SocialView: View {
    @Bindable var viewModel: SocialViewModel
    
    var body: some View {
        SectionContainer {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Meaningful Interactions")
                        .font(.headline)
                    
                    if !viewModel.meaningfulInteractions.isEmpty {
                        ForEach(viewModel.meaningfulInteractions, id: \.person) { interaction in
                            InteractionRow(interaction: interaction)
                        }
                    }
                    
                    if viewModel.showingAddInteraction {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Person", text: $viewModel.newInteractionPerson)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Notes", text: $viewModel.newInteractionNotes)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            HStack {
                                Button("Add") {
                                    viewModel.addInteraction()
                                }
                                .disabled(!viewModel.canAddInteraction)
                                
                                Button("Cancel") {
                                    viewModel.showingAddInteraction = false
                                    viewModel.resetNewInteractionFields()
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(8)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                    } else {
                        Button(action: {
                            viewModel.showingAddInteraction = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Interaction")
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                JournalTextEditor(
                    title: "Relationship Updates",
                    text: $viewModel.relationshipUpdates,
                    minHeight: 100
                )
                
                JournalTextEditor(
                    title: "Social Events",
                    text: $viewModel.socialEvents,
                    minHeight: 100
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct InteractionRow: View {
    var interaction: JournalInteraction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(interaction.person)
                .font(.headline)
            
            if !interaction.notes.isEmpty {
                Text(interaction.notes)
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
        .padding(8)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
        .cornerRadius(8)
    }
}

#Preview {
    SocialView(viewModel: SocialViewModel())
        .frame(width: 600)
        .padding()
} 