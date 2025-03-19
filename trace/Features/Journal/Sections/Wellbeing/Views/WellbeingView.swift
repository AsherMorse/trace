import SwiftUI

struct WellbeingView: View {
    @Bindable var viewModel: WellbeingViewModel
    
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
                        
                        Slider(value: Binding(
                            get: { Double(viewModel.energyLevel) },
                            set: { viewModel.energyLevel = Int($0) }
                        ), in: 1...10, step: 1)
                            .frame(maxWidth: .infinity)
                        
                        Text("High")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                    
                    Text("\(viewModel.energyLevel)/10")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                JournalTextEditor(
                    title: "Physical Activity",
                    text: $viewModel.physicalActivity,
                    minHeight: 100
                )
                
                JournalTextEditor(
                    title: "Mental Health",
                    text: $viewModel.mentalHealth,
                    minHeight: 150
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    WellbeingView(viewModel: WellbeingViewModel())
        .frame(width: 600)
        .padding()
} 
