import SwiftUI

/// Sheet for editing or deleting a routine.
public struct EditRoutineSheetView: View {
    @Bindable var viewModel: EditRoutineViewModel
    let onClose: () -> Void
    let onSaved: () -> Void

    public init(
        viewModel: EditRoutineViewModel,
        onClose: @escaping () -> Void,
        onSaved: @escaping () -> Void = {}
    ) {
        self.viewModel = viewModel
        self.onClose = onClose
        self.onSaved = onSaved
    }

    public var body: some View {
        NavigationStack {
            Form {
                if !viewModel.petName.isEmpty {
                    Section {
                        Text(viewModel.petName)
                            .font(EnamelType.body())
                            .foregroundStyle(EnamelPalette.inkDim)
                    } header: {
                        Text("Pet")
                    }
                }
                Section("Routine") {
                    TextField("Title", text: $viewModel.title)
                    Picker("Time slot", selection: $viewModel.slot) {
                        ForEach(RoutineSlot.allCases, id: \.self) { slot in
                            Text(slot.badge).tag(slot)
                        }
                    }
                    Toggle("Active", isOn: $viewModel.isActive)
                }
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .font(EnamelType.body(14))
                            .foregroundStyle(EnamelPalette.redBrown)
                    }
                }
                Section {
                    Button("Delete routine", role: .destructive) {
                        Task {
                            if await viewModel.remove() {
                                onSaved()
                                onClose()
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(EnamelPalette.cream)
            .navigationTitle("Edit routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onClose)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            if await viewModel.save() {
                                onSaved()
                                onClose()
                            }
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
            .task { await viewModel.load() }
        }
    }
}

#Preview {
    EditRoutineSheetView(
        viewModel: DenlyContainer.preview().makeEditRoutineViewModel(routineID: UUID()),
        onClose: {}
    )
}
