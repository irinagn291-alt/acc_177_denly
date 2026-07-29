import SwiftUI

/// Browse starter routine packs and add them to a pet in one tap.
public struct RoutineLibraryView: View {
    @Bindable var viewModel: RoutineLibraryViewModel

    public init(viewModel: RoutineLibraryViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: EnamelMetrics.gutter) {
                Text("STARTER PACKS")
                    .font(EnamelType.badge(11))
                    .foregroundStyle(EnamelPalette.inkDim)
                    .tracking(1.4)
                Text("Hang a whole enamel set on one pet.")
                    .font(EnamelType.body())
                    .foregroundStyle(EnamelPalette.inkDim)

                if viewModel.pets.isEmpty {
                    EnamelEmptyState(
                        title: "No pets yet",
                        detail: "Add a pet first, then apply a pack."
                    )
                } else {
                    Picker("Pet", selection: $viewModel.selectedPetID) {
                        ForEach(viewModel.pets) { pet in
                            Text(pet.name).tag(Optional(pet.id))
                        }
                    }
                    .pickerStyle(.segmented)

                    ForEach(viewModel.packs) { pack in
                        packCard(pack)
                    }
                }

                if let status = viewModel.statusMessage {
                    Text(status)
                        .font(EnamelType.body(14))
                        .foregroundStyle(EnamelPalette.green)
                }
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(EnamelType.body(14))
                        .foregroundStyle(EnamelPalette.redBrown)
                }
            }
            .padding(EnamelMetrics.gutter)
        }
        .enamelTexturedGround()
        .navigationTitle("Routine Library")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private func packCard(_ pack: RoutinePack) -> some View {
        VStack(alignment: .leading, spacing: EnamelMetrics.inset) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(pack.title)
                        .font(EnamelType.title(20))
                        .foregroundStyle(EnamelPalette.ink)
                    Text(pack.detail)
                        .font(EnamelType.body(14))
                        .foregroundStyle(EnamelPalette.inkDim)
                }
                Spacer()
                Button {
                    Task { await viewModel.addPack(pack) }
                } label: {
                    Text(viewModel.isApplying ? "…" : "Add")
                        .font(EnamelType.bodyBold(14))
                        .foregroundStyle(EnamelPalette.cream)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(EnamelPalette.green)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isApplying || viewModel.selectedPetID == nil)
            }

            ForEach(pack.routines) { routine in
                HStack(spacing: 8) {
                    SlotBadge(slot: routine.slot)
                    Text(routine.title)
                        .font(EnamelType.body(14))
                        .foregroundStyle(EnamelPalette.ink)
                }
            }
        }
        .padding(EnamelMetrics.inset)
        .background(Color.white.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: EnamelMetrics.radius, style: .continuous))
        .modifier(EnamelStroke(color: EnamelPalette.mustard.opacity(0.45)))
    }
}

#Preview {
    NavigationStack {
        RoutineLibraryView(viewModel: DenlyContainer.preview().makeRoutineLibraryViewModel())
    }
}
