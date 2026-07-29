import SwiftUI

/// Quick note editor for a care log entry.
public struct CareNoteSheetView: View {
    @Bindable var viewModel: PetDetailViewModel
    let log: CareLog
    let onClose: () -> Void

    @State private var note: String = ""

    public init(viewModel: PetDetailViewModel, log: CareLog, onClose: @escaping () -> Void) {
        self.viewModel = viewModel
        self.log = log
        self.onClose = onClose
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Log") {
                    Text(log.title)
                    Text(log.completedAt.formatted(date: .abbreviated, time: .shortened))
                        .foregroundStyle(.secondary)
                }
                Section("Quick note") {
                    TextField("Optional note", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Care Note")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onClose)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.saveNote(logID: log.id, note: note)
                            onClose()
                        }
                    }
                }
            }
            .onAppear { note = log.notes }
        }
    }
}
