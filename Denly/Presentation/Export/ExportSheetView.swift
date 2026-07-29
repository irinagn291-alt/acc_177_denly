import SwiftUI

public struct ExportSheetView: View {
    @Bindable var viewModel: ExportViewModel
    let onClose: () -> Void

    public init(viewModel: ExportViewModel, onClose: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onClose = onClose
    }

    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if let csv = viewModel.csvText {
                    ScrollView {
                        Text(csv)
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                            .padding()
                    }
                } else {
                    EnamelEmptyState(title: "Nothing to export", detail: "Log some care first.")
                }
            }
            .enamelGround()
            .navigationTitle("CSV Export")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: onClose)
                }
                if let csv = viewModel.csvText {
                    ToolbarItem(placement: .primaryAction) {
                        ShareLink(item: csv, preview: SharePreview("Denly export.csv"))
                    }
                }
            }
            .task { await viewModel.load() }
        }
    }
}

public struct AddRoutineSheetView: View {
    @Bindable var viewModel: AddRoutineViewModel
    let onClose: () -> Void
    let onSaved: () -> Void

    public init(
        viewModel: AddRoutineViewModel,
        onClose: @escaping () -> Void,
        onSaved: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onClose = onClose
        self.onSaved = onSaved
    }

    public var body: some View {
        NavigationStack {
            Form {
                Picker("Pet", selection: $viewModel.selectedPetID) {
                    ForEach(viewModel.pets) { pet in
                        Text(pet.name).tag(Optional(pet.id))
                    }
                }
                TextField("Routine title", text: $viewModel.title)
                Picker("Time slot", selection: $viewModel.slot) {
                    ForEach(RoutineSlot.allCases, id: \.self) { slot in
                        Text(slot.badge).tag(slot)
                    }
                }
            }
            .navigationTitle("Add routine")
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
                }
            }
            .task { await viewModel.load() }
        }
    }
}

public struct AddPetSheetView: View {
    @Bindable var viewModel: PetsViewModel
    let onClose: () -> Void

    @State private var name = ""
    @State private var species = ""

    public init(viewModel: PetsViewModel, onClose: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onClose = onClose
    }

    public var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("Species", text: $species)
            }
            .navigationTitle("Add pet")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onClose)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.addPet(name: name, species: species)
                            onClose()
                        }
                    }
                }
            }
        }
    }
}
