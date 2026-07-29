import SwiftUI

/// Search care history by title, note, or date text.
public struct HistorySearchView: View {
    @Bindable var viewModel: PetDetailViewModel

    public init(viewModel: PetDetailViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(EnamelPalette.inkDim)
                TextField("Search title or date", text: $viewModel.historyQuery)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .padding(EnamelMetrics.inset)
            .background(Color.white.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: EnamelMetrics.radius, style: .continuous))
            .modifier(EnamelStroke(color: EnamelPalette.ink.opacity(0.2)))
            .padding(EnamelMetrics.gutter)

            ScrollView {
                CareHistoryView(
                    logs: viewModel.filteredLogs,
                    emptyDetail: viewModel.historyQuery.isEmpty
                        ? "Complete a routine to start the ledger."
                        : "No logs match that search."
                )
                .padding(.horizontal, EnamelMetrics.gutter)
                .padding(.bottom, 40)
            }
        }
        .enamelTexturedGround()
        .navigationTitle("Care History")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }
}

#Preview {
    NavigationStack {
        HistorySearchView(
            viewModel: DenlyContainer.preview().makePetDetailViewModel(petID: UUID())
        )
    }
}
