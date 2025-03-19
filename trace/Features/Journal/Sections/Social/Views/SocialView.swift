import SwiftUI

struct SocialView: View {
    @Bindable var viewModel: SocialViewModel
    
    var body: some View {
        SectionContainer {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Meaningful Interactions")
                            .font(.headline)
                        
                        Spacer()
                        
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
                    }
                    
                    if viewModel.meaningfulInteractions.isEmpty {
                        Text("No meaningful interactions")
                            .foregroundColor(.secondary)
                            .font(.caption)
                            .padding(.top, 4)
                    } else {
                        ForEach(Array(zip(viewModel.meaningfulInteractions.indices, viewModel.meaningfulInteractions)), id: \.0) { index, interaction in
                            InteractionRow(
                                interaction: interaction,
                                onDelete: {
                                    viewModel.journalViewModel?.deleteInteraction(at: index)
                                }
                            )
                        }
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
    var onDelete: () -> Void
    
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(interaction.person)
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .help("Delete interaction")
                .alert(isPresented: $showingDeleteConfirmation) {
                    Alert(
                        title: Text("Delete interaction with \(interaction.person)?"),
                        message: Text("This action cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            onDelete()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            
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