import SwiftUI

public struct RootView: View {
    @State private var coordinator = DenlyCoordinator()
    @State private var showOnboarding: Bool?

    private let container: DenlyContainer

    public init(container: DenlyContainer) {
        self.container = container
    }

    public var body: some View {
        Group {
            if showOnboarding == true {
                OnboardingDeckView(viewModel: container.makeOnboardingViewModel()) {
                    showOnboarding = false
                }
            } else if showOnboarding == false {
                mainTabs
            } else {
                Color.clear.enamelGround()
            }
        }
        .task { await decideFirstScreen() }
    }

    private var mainTabs: some View {
        NavigationStack(path: $coordinator.path) {
            ZStack(alignment: .bottomTrailing) {
                TabView(selection: $coordinator.selectedTab) {
                    TodayView(
                        viewModel: container.makeTodayViewModel(),
                        coordinator: coordinator
                    )
                    .tabItem { Label("Today", systemImage: "checkmark.circle") }
                    .tag(DenlyTab.today)

                    InsightsView(
                        viewModel: container.makeInsightsViewModel(),
                        coordinator: coordinator
                    )
                    .tabItem { Label("Insights", systemImage: "chart.bar") }
                    .tag(DenlyTab.insights)

                    PetsView(
                        viewModel: container.makePetsViewModel(),
                        coordinator: coordinator
                    )
                    .tabItem { Label("Pets", systemImage: "pawprint") }
                    .tag(DenlyTab.pets)
                }

                Button {
                    coordinator.presentFabMenu()
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(EnamelPalette.cream)
                        .frame(width: EnamelMetrics.fabSize, height: EnamelMetrics.fabSize)
                        .background(EnamelPalette.green)
                        .clipShape(Circle())
                        .modifier(EnamelStroke())
                        .shadow(color: EnamelPalette.ink.opacity(0.15), radius: 4, y: 2)
                }
                .padding(.trailing, EnamelMetrics.gutter)
                .padding(.bottom, EnamelMetrics.tabBarHeight + 8)
                .accessibilityLabel("Quick actions")
            }
            .navigationDestination(for: DenlyRoute.self, destination: destination)
        }
        .tint(EnamelPalette.green)
        .sheet(item: $coordinator.sheet, content: sheet)
    }

    @ViewBuilder
    private func destination(_ route: DenlyRoute) -> some View {
        switch route {
        case .gallery:
            EnamelGalleryView()
        case .petDetail(let id):
            PetDetailView(
                viewModel: container.makePetDetailViewModel(petID: id),
                coordinator: coordinator
            )
        case .weeklyRecap:
            WeeklyRecapView(viewModel: container.makeWeeklyRecapViewModel())
        case .streakMilestones:
            StreakMilestonesView(viewModel: container.makeStreakMilestonesViewModel())
        case .routineLibrary:
            RoutineLibraryView(viewModel: container.makeRoutineLibraryViewModel())
        case .remindersSetup:
            RemindersSetupView(viewModel: container.makeRemindersSetupViewModel())
        case .historySearch(let id):
            HistorySearchView(viewModel: container.makePetDetailViewModel(petID: id))
        }
    }

    @ViewBuilder
    private func sheet(_ sheet: DenlySheet) -> some View {
        switch sheet {
        case .export:
            ExportSheetView(
                viewModel: container.makeExportViewModel(),
                onClose: { coordinator.dismissSheet() }
            )
        case .addRoutine:
            AddRoutineSheetView(
                viewModel: container.makeAddRoutineViewModel(),
                onClose: { coordinator.dismissSheet() },
                onSaved: {}
            )
        case .editRoutine(let id):
            EditRoutineSheetView(
                viewModel: container.makeEditRoutineViewModel(routineID: id),
                onClose: { coordinator.dismissSheet() },
                onSaved: {}
            )
        case .addPet:
            AddPetSheetView(
                viewModel: container.makePetsViewModel(),
                onClose: { coordinator.dismissSheet() }
            )
        case .fabMenu:
            FabMenuSheetView(
                coordinator: coordinator,
                onClose: { coordinator.dismissSheet() }
            )
        case .careNote(let petID, let logID):
            let vm = container.makePetDetailViewModel(petID: petID)
            CareNoteSheetHost(
                viewModel: vm,
                logID: logID,
                onClose: { coordinator.dismissSheet() }
            )
        }
    }

    private func decideFirstScreen() async {
        guard showOnboarding == nil else { return }
        #if targetEnvironment(simulator)
        try? await SimulatorPetSeeder(
            petRepository: container.petRepository,
            routineRepository: container.routineRepository
        ).seedIfEmpty()
        #endif
        if container.onboardingStore.hasCompletedOnboarding() {
            showOnboarding = false
        } else {
            let empty = (try? await container.journalIsEmpty()) ?? true
            showOnboarding = empty
        }
    }
}

/// Loads the pet detail VM then presents the note sheet for a log id.
private struct CareNoteSheetHost: View {
    @Bindable var viewModel: PetDetailViewModel
    let logID: UUID
    let onClose: () -> Void

    var body: some View {
        Group {
            if let log = viewModel.log(id: logID) ?? viewModel.recentLogs.first(where: { $0.id == logID }) {
                CareNoteSheetView(viewModel: viewModel, log: log, onClose: onClose)
            } else {
                ProgressView()
                    .task { await viewModel.load() }
            }
        }
    }
}

#Preview("Root") {
    RootView(container: DenlyContainer.preview())
}
