import SwiftUI

struct WellbeingView: View {
    @Bindable var viewModel: JournalViewModel
    @State private var energyLevel: Double = 5 {
        didSet {
            updateViewModel()
        }
    }
    @State private var physicalActivity: String = "" {
        didSet {
            updateViewModel()
        }
    }
    @State private var mentalHealth: String = "" {
        didSet {
            updateViewModel()
        }
    }
    
    var body: some View {
        SectionContainer {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Energy Level")
                        .font(.headline)
                    
                    HStack {
                        Text("Low")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                        
                        Slider(value: $energyLevel, in: 1...10, step: 1)
                            .frame(maxWidth: .infinity)
                            .onChange(of: energyLevel) { _, _ in
                                updateViewModel()
                            }
                        
                        Text("High")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                    
                    Text("\(Int(energyLevel))/10")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                JournalTextEditor(
                    title: "Physical Activity",
                    text: $physicalActivity
                )
                .frame(minHeight: 100)
                .onChange(of: physicalActivity) { _, _ in
                    updateViewModel()
                }
                
                JournalTextEditor(
                    title: "Mental Health",
                    text: $mentalHealth
                )
                .frame(minHeight: 150)
                .onChange(of: mentalHealth) { _, _ in
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
        entry.wellbeing.energyLevel = Int(energyLevel)
        entry.wellbeing.physicalActivity = physicalActivity
        entry.wellbeing.mentalHealth = mentalHealth
        
        // Update the viewModel's editedContent with new markdown
        viewModel.updateEntrySection(entry)
    }
    
    private func loadFromViewModel() {
        if let entry = viewModel.currentEntry {
            energyLevel = Double(entry.wellbeing.energyLevel)
            physicalActivity = entry.wellbeing.physicalActivity
            mentalHealth = entry.wellbeing.mentalHealth
        }
    }
}

#Preview {
    WellbeingView(viewModel: JournalViewModel())
        .frame(width: 600)
        .padding()
} 