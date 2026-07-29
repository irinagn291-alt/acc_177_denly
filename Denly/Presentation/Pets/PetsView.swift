import SwiftUI

/// Pet roster as enamel badges — tap opens the detail plaque.
public struct PetsView: View {
    @Bindable var viewModel: PetsViewModel
    @Bindable var coordinator: DenlyCoordinator

    public init(viewModel: PetsViewModel, coordinator: DenlyCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: EnamelMetrics.gutter) {
                header
                if viewModel.isLoading && viewModel.pets.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else if viewModel.pets.isEmpty {
                    EnamelEmptyState(
                        title: "No pets yet",
                        detail: "Tap + to hang the first enamel badge on the wall."
                    )
                } else {
                    ForEach(viewModel.pets) { pet in
                        petBadge(pet)
                    }
                }
            }
            .padding(EnamelMetrics.gutter)
            .padding(.bottom, 88)
        }
        .enamelTexturedGround()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Pets")
                    .font(EnamelType.title())
                    .foregroundStyle(EnamelPalette.ink)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    coordinator.presentAddPet()
                } label: {
                    Image(systemName: "plus")
                        .font(.body.weight(.bold))
                        .foregroundStyle(EnamelPalette.green)
                }
                .accessibilityLabel("Add pet")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.refresh() }
        .refreshable { await viewModel.refresh() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("COMPANIONS")
                .font(EnamelType.badge(11))
                .foregroundStyle(EnamelPalette.inkDim)
                .tracking(1.4)
            Text("^[\(viewModel.pets.count) pet](inflect: true) on the wall")
                .font(EnamelType.body())
                .foregroundStyle(EnamelPalette.inkDim)
                .contentTransition(.numericText())
        }
    }

    private func petBadge(_ pet: Pet) -> some View {
        let petRoutines = viewModel.routines(for: pet)
        return Button {
            coordinator.openPet(pet.id)
        } label: {
            VStack(alignment: .leading, spacing: EnamelMetrics.inset) {
                HStack(spacing: EnamelMetrics.gutter) {
                    PetAvatarBadge(
                        name: pet.name,
                        species: pet.species,
                        size: 60,
                        avatarRelativePath: pet.avatarRelativePath,
                        usePlaqueFallback: true
                    )
                    VStack(alignment: .leading, spacing: 6) {
                        Text(pet.name)
                            .font(EnamelType.title(22))
                            .foregroundStyle(EnamelPalette.ink)
                        if !pet.species.isEmpty {
                            SpeciesChip(pet.species)
                        }
                        Text("^[\(petRoutines.count) routine](inflect: true)")
                            .font(EnamelType.body(13))
                            .foregroundStyle(EnamelPalette.inkDim)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(EnamelPalette.inkFaint)
                }

                if petRoutines.isEmpty {
                    Text("No routines — open to add one.")
                        .font(EnamelType.body(13))
                        .foregroundStyle(EnamelPalette.inkFaint)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(petRoutines.prefix(6)) { routine in
                                HStack(spacing: 6) {
                                    SlotBadge(slot: routine.slot)
                                    Text(routine.title)
                                        .font(EnamelType.body(13))
                                        .foregroundStyle(EnamelPalette.ink)
                                        .lineLimit(1)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(EnamelPalette.cream)
                                .clipShape(Capsule())
                                .overlay {
                                    Capsule().strokeBorder(EnamelPalette.ink.opacity(0.15), lineWidth: 1)
                                }
                            }
                        }
                    }
                }
            }
            .padding(EnamelMetrics.gutter)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: EnamelMetrics.radius, style: .continuous))
            .modifier(EnamelStroke(color: EnamelPalette.ink.opacity(0.55)))
            .modifier(EnamelMisregister())
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                Task { await viewModel.removePet(pet) }
            } label: {
                Label("Remove pet", systemImage: "trash")
            }
        }
        .accessibilityHint("Opens pet detail")
    }
}

#Preview {
    NavigationStack {
        PetsView(
            viewModel: DenlyContainer.preview().makePetsViewModel(),
            coordinator: DenlyCoordinator()
        )
    }
}
