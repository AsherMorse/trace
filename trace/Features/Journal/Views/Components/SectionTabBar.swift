import SwiftUI

struct SectionTabBar: View {
    @Binding var selectedTab: JournalSection
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.8))
            
            HStack(spacing: 2) {
                ForEach(JournalSection.allCases) { section in
                    Button(action: {
                        selectedTab = section
                    }) {
                        VStack(spacing: 6) {
                            Image(systemName: section.iconName)
                                .font(.system(size: 16))
                            
                            Text(section.rawValue)
                                .font(.footnote)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedTab == section ? 
                                      Color(NSColor.controlBackgroundColor) : 
                                      Color.clear)
                        )
                        .contentShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .foregroundColor(selectedTab == section ? .primary : .secondary)
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
        }
        .fixedSize(horizontal: true, vertical: false)
        .frame(maxHeight: 70)
    }
}

#Preview {
    VStack(spacing: 0) {
        SectionTabBar(selectedTab: .constant(.dailyCheckIn))
        Divider()
        Text("Content goes here")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
} 
