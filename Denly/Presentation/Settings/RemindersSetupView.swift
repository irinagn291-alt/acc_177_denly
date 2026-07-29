import SwiftUI

/// Local evening reminder preference (UserDefaults + optional notification).
public struct RemindersSetupView: View {
    @Bindable var viewModel: RemindersSetupViewModel

    public init(viewModel: RemindersSetupViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Form {
            Section {
                Toggle("Evening reminder", isOn: $viewModel.isEnabled)
                if viewModel.isEnabled {
                    DatePicker(
                        "Remind at",
                        selection: $viewModel.reminderDate,
                        displayedComponents: .hourAndMinute
                    )
                }
            } footer: {
                Text("Stored on this device. Denly can nudge you to stamp evening care.")
                    .font(EnamelType.body(13))
            }

            Section {
                Button("Save preference") {
                    Task { await viewModel.save() }
                }
                if let status = viewModel.statusMessage {
                    Text(status)
                        .font(EnamelType.body(14))
                        .foregroundStyle(EnamelPalette.green)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .enamelTexturedGround()
        .navigationTitle("Reminders")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        RemindersSetupView(viewModel: DenlyContainer.preview().makeRemindersSetupViewModel())
    }
}
