import SwiftUI

struct JournalView: View {
    @State private var journalViewModel = JournalViewModel()
    
    var body: some View {
        HSplitView {
            VStack(spacing: 0) {
                CalendarView(
                    selectedDate: journalViewModel.selectedDate,
                    onDateSelected: { date in
                        print("Date selected in calendar: \(date)")
                        journalViewModel.selectedDate = date
                    }
                )
                
                Divider()
                
                JournalActionsView(viewModel: journalViewModel)
            }
            .frame(maxWidth: 600)
            .layoutPriority(1)
            
            JournalEntryView(viewModel: journalViewModel)
                .layoutPriority(2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        JournalView()
    }
}
