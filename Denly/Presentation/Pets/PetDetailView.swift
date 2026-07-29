import PhotosUI
import SwiftUI

/// Full enamel plaque for one pet: badge, streak, routines, care ledger.
public struct PetDetailView: View {
    @Bindable var viewModel: PetDetailViewModel
    @Bindable var coordinator: DenlyCoordinator
    @Environment(\.dismiss) private var dismiss
    @State private var confirmDelete = false

    public init(viewModel: PetDetailViewModel, coordinator: DenlyCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: EnamelMetrics.gutter) {
                if viewModel.isLoading && viewModel.pet == nil {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else if let pet = viewModel.pet {
                    headerPlaque(pet)
                    CareCalendarStrip(completedDays: viewModel.completedDays)
                    streakPanel
                    routinesPanel
                    historyPanel
                    destructiveRow
                } else if let error = viewModel.errorMessage {
                    EnamelEmptyState(title: "Pet not found", detail: error)
                }
            }
            .padding(EnamelMetrics.gutter)
            .padding(.bottom, 80)
        }
        .enamelTexturedGround()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(viewModel.pet?.name ?? "Pet")
                    .font(EnamelType.title())
                    .foregroundStyle(EnamelPalette.ink)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(viewModel.isEditing ? "Done" : "Edit") {
                    if viewModel.isEditing {
                        Task { await viewModel.saveEdits() }
                    } else {
                        viewModel.isEditing = true
                    }
                }
                .font(EnamelType.bodyBold(14))
            }
        }
        .task { await viewModel.load() }
        .onChange(of: viewModel.didDelete) { _, deleted in
            if deleted { dismiss() }
        }
        .onChange(of: viewModel.selectedPhoto) { _, _ in
            Task { await viewModel.applySelectedPhoto() }
        }
        .alert("Remove this pet?", isPresented: $confirmDelete) {
            Button("Cancel", role: .cancel) {}
            Button("Remove", role: .destructive) {
                Task { await viewModel.removePet() }
            }
        } message: {
            Text("Routines and care logs for this pet stay on device until you clear them.")
        }
        .alert("Something went wrong", isPresented: Binding(
            get: { viewModel.errorMessage != nil && viewModel.pet != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private func headerPlaque(_ pet: Pet) -> some View {
        VStack(alignment: .leading, spacing: EnamelMetrics.inset) {
            HStack(alignment: .center, spacing: EnamelMetrics.gutter) {
                PetAvatarBadge(
                    name: pet.name,
                    species: pet.species,
                    size: 72,
                    avatarRelativePath: pet.avatarRelativePath,
                    usePlaqueFallback: true
                )
                VStack(alignment: .leading, spacing: 6) {
                    if viewModel.isEditing {
                        TextField("Name", text: $viewModel.editName)
                            .font(EnamelType.title(22))
                            .foregroundStyle(EnamelPalette.ink)
                        TextField("Species", text: $viewModel.editSpecies)
                            .font(EnamelType.body())
                            .foregroundStyle(EnamelPalette.inkDim)
                        PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
                            Text("Choose photo")
                                .font(EnamelType.bodyBold(13))
                                .foregroundStyle(EnamelPalette.green)
                        }
                        if pet.avatarRelativePath != nil {
                            Button("Use plaque art") {
                                Task { await viewModel.clearAvatar() }
                            }
                            .font(EnamelType.body(13))
                            .foregroundStyle(EnamelPalette.inkDim)
                        }
                    } else {
                        Text(pet.name)
                            .font(EnamelType.title(24))
                            .foregroundStyle(EnamelPalette.ink)
                        if !pet.species.isEmpty {
                            SpeciesChip(pet.species)
                        }
                    }
                }
                Spacer(minLength: 0)
            }

            HStack(spacing: EnamelMetrics.gutter) {
                metric("Routines", value: "\(viewModel.routines.count)")
                metric("Logs", value: "\(viewModel.allLogs.count)")
                metric("Streak", value: "\(viewModel.streak.currentStreak)")
            }
        }
        .padding(EnamelMetrics.gutter)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: EnamelMetrics.radius, style: .continuous))
        .modifier(EnamelStroke(color: EnamelPalette.ink))
        .modifier(EnamelMisregister())
    }

    private func metric(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(EnamelType.badge(10))
                .foregroundStyle(EnamelPalette.inkDim)
                .tracking(0.8)
            Text(value)
                .font(EnamelType.streak(22))
                .foregroundStyle(EnamelPalette.green)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var streakPanel: some View {
        VStack(alignment: .leading, spacing: EnamelMetrics.inset) {
            HStack {
                Text("STREAK RAIL")
                    .font(EnamelType.badge(11))
                    .foregroundStyle(EnamelPalette.inkDim)
                    .tracking(1.2)
                Spacer()
                Button("Milestones") {
                    coordinator.openStreakMilestones()
                }
                .font(EnamelType.bodyBold(13))
                .foregroundStyle(EnamelPalette.green)
            }
            StreakRailView(rail: viewModel.streak)
        }
        .padding(EnamelMetrics.inset)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(EnamelPalette.green.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: EnamelMetrics.radius, style: .continuous))
        .modifier(EnamelStroke(color: EnamelPalette.green.opacity(0.5)))
    }

    private var routinesPanel: some View {
        VStack(alignment: .leading, spacing: EnamelMetrics.inset) {
            HStack {
                Text("ROUTINES")
                    .font(EnamelType.badge(11))
                    .foregroundStyle(EnamelPalette.inkDim)
                    .tracking(1.2)
                Spacer()
                Button {
                    coordinator.openRoutineLibrary()
                } label: {
                    Text("Library")
                        .font(EnamelType.bodyBold(13))
                        .foregroundStyle(EnamelPalette.mustard)
                }
                .buttonStyle(.plain)
                Button {
                    coordinator.presentAddRoutine()
                } label: {
                    Label("Add", systemImage: "plus")
                        .font(EnamelType.bodyBold(13))
                        .foregroundStyle(EnamelPalette.green)
                }
                .buttonStyle(.plain)
            }

            if viewModel.routines.isEmpty {
                Text("No routines yet. Add one or open the library.")
                    .font(EnamelType.body(14))
                    .foregroundStyle(EnamelPalette.inkDim)
            } else {
                ForEach(viewModel.routines) { routine in
                    Button {
                        coordinator.presentEditRoutine(routine.id)
                    } label: {
                        HStack(spacing: EnamelMetrics.inset) {
                            SlotBadge(slot: routine.slot)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(routine.title)
                                    .font(EnamelType.bodyBold())
                                    .foregroundStyle(routine.isActive ? EnamelPalette.ink : EnamelPalette.inkFaint)
                                Text(routine.isActive ? "Active" : "Paused")
                                    .font(EnamelType.body(12))
                                    .foregroundStyle(EnamelPalette.inkDim)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(EnamelPalette.inkFaint)
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            Task { await viewModel.removeRoutine(routine) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    if routine.id != viewModel.routines.last?.id {
                        Rectangle()
                            .fill(EnamelPalette.ink.opacity(0.08))
                            .frame(height: 1)
                    }
                }
            }
        }
        .padding(EnamelMetrics.inset)
        .background(Color.white.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: EnamelMetrics.radius, style: .continuous))
        .modifier(EnamelStroke(color: EnamelPalette.mustard.opacity(0.55)))
    }

    private var historyPanel: some View {
        VStack(alignment: .leading, spacing: EnamelMetrics.inset) {
            HStack {
                Spacer()
                Button("Search all") {
                    coordinator.openHistorySearch(viewModel.petID)
                }
                .font(EnamelType.bodyBold(13))
                .foregroundStyle(EnamelPalette.green)
            }
            CareHistoryView(
                logs: viewModel.recentLogs,
                onTapNote: { log in
                    coordinator.presentCareNote(petID: viewModel.petID, logID: log.id)
                }
            )
        }
    }

    private var destructiveRow: some View {
        Button(role: .destructive) {
            confirmDelete = true
        } label: {
            Text("Remove pet")
                .font(EnamelType.bodyBold())
                .foregroundStyle(EnamelPalette.redBrown)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(EnamelPalette.redBrown.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: EnamelMetrics.radius, style: .continuous))
                .modifier(EnamelStroke(color: EnamelPalette.redBrown.opacity(0.45)))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        PetDetailView(
            viewModel: DenlyContainer.preview().makePetDetailViewModel(petID: UUID()),
            coordinator: DenlyCoordinator()
        )
    }
}
