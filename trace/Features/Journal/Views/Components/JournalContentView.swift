import SwiftUI

struct JournalContentView: View {
    @Bindable var viewModel: JournalViewModel
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        contentView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(Color(NSColor.textBackgroundColor))
    }
    
    private var contentView: some View {
        Group {
            if viewModel.selectedDate == nil {
                emptyStateView
            } else if viewModel.isLoading {
                loadingView
            } else if viewModel.hasError {
                errorView
            } else {
                journalEntryView
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
                .padding()
            
            Text("No Date Selected")
                .font(.title)
                .fontWeight(.medium)
            
            Text("Select a date from the calendar to view or create a journal entry.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button("Create Today's Entry") {
                viewModel.openTodaysEntry()
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            
            Text("Loading...")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if let date = viewModel.selectedDate {
                Text(viewModel.formatDate(date))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
                .padding()
            
            Text("Error loading entry")
                .font(.title)
                .fontWeight(.medium)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
            HStack(spacing: 16) {
                Button("Try Again") {
                    if let date = viewModel.selectedDate {
                        viewModel.loadContent(for: date)
                    }
                }
                .buttonStyle(.bordered)
                
                if let date = viewModel.selectedDate {
                    Button("Create New Entry") {
                        viewModel.createEntry(for: date)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var journalEntryView: some View {
        VStack(alignment: .leading, spacing: 16) {
            dateHeaderView
            
            Divider()
            
            if viewModel.isEditing {
                editView
            } else {
                displayView
            }
        }
        .padding()
    }
    
    private var displayView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                Text(viewModel.fileContent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 30)
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            HStack {
                Spacer()
                Button("Edit") {
                    viewModel.startEditing()
                }
                .keyboardShortcut("e", modifiers: [.command])
                .buttonStyle(.bordered)
            }
            .padding(.top, 8)
        }
    }
    
    private var editView: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextEditor(text: $viewModel.editedContent)
                .font(.body)
                .focused($isTextFieldFocused)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scrollContentBackground(.hidden)
                .background(Color(NSColor.textBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
                .padding(.bottom, 8)
            
            HStack {
                Button("Cancel") {
                    viewModel.cancelEditing()
                    isTextFieldFocused = false
                }
                .keyboardShortcut(.escape, modifiers: [])
                
                Spacer()
                
                Button("Save") {
                    saveChanges()
                }
                .keyboardShortcut("s", modifiers: [.command])
                .buttonStyle(.borderedProminent)
            }
            .padding(.top, 8)
        }
    }
    
    private var dateHeaderView: some View {
        HStack {
            if let date = viewModel.selectedDate {
                VStack(alignment: .leading) {
                    Text(viewModel.formatDate(date))
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(viewModel.formatDay(date))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("No Date Selected")
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: {
                    viewModel.openTodaysEntry()
                }) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 16))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .help("Go to today's entry")
                
                if let date = viewModel.selectedDate, Calendar.current.isDateInToday(date) == false {
                    Button(action: {
                        viewModel.createEntry(for: date)
                    }) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 16))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .help("Create new entry for this date")
                }
            }
        }
    }
    
    /// Handles saving changes using the view model
    private func saveChanges() {
        Task {
            do {
                try await viewModel.saveEdits()
                isTextFieldFocused = false
            } catch {
                // Error is already handled by the view model
            }
        }
    }
}
