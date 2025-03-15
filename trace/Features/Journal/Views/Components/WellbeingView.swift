import SwiftUI

struct WellbeingView: View {
    @State private var energyLevel: Double = 5
    @State private var physicalActivity: String = ""
    @State private var mentalHealth: String = ""
    
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
                
                JournalTextEditor(
                    title: "Mental Health",
                    text: $mentalHealth
                )
                .frame(minHeight: 150)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    WellbeingView()
        .frame(width: 600)
        .padding()
} 