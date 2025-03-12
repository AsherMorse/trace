import SwiftUI

struct MainJournalView: View {
    @State private var journalViewModel = JournalViewModel()
    
    var body: some View {
        HSplitView {
            // Left side with calendar and actions
            leftSideView
                .frame(minWidth: 320, maxHeight: .infinity)
                .layoutPriority(1)

            // Right side with journal content
            JournalContentView(viewModel: journalViewModel)
                .layoutPriority(2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Private Views
    
    private var leftSideView: some View {
        VStack(spacing: 0) {
            // Calendar
            calendarView
            
            Divider()
            
            // Quick Actions
            JournalActionsView(viewModel: journalViewModel)
        }
    }
    
    private var calendarView: some View {
        // TODO: Implement calendar view connection
        CalendarView(onDateSelected: { date in
            journalViewModel.selectedDate = date
        })
    }
}

struct MainJournalView_Previews: PreviewProvider {
    static var previews: some View {
        MainJournalView()
    }
} 