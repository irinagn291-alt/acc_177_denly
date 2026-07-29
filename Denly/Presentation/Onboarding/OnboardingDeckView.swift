import SwiftUI

public struct OnboardingDeckView: View {
    @Bindable var viewModel: OnboardingDeckViewModel
    let onComplete: () -> Void

    @State private var offset: CGSize = .zero
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(viewModel: OnboardingDeckViewModel, onComplete: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onComplete = onComplete
    }

    public var body: some View {
        VStack(spacing: EnamelMetrics.gutter) {
            EnamelHabitatPlaqueImage(height: 120)

            Text("Pick your routines")
                .font(EnamelType.title(28))
                .foregroundStyle(EnamelPalette.ink)

            VStack(spacing: EnamelMetrics.inset) {
                TextField("Pet name", text: $viewModel.petName)
                    .font(EnamelType.body())
                TextField("Species (optional)", text: $viewModel.petSpecies)
                    .font(EnamelType.body())
            }
            .padding(EnamelMetrics.inset)
            .enamelCard()

            if let card = viewModel.currentCard {
                routineCard(card)
                    .offset(offset)
                    .rotationEffect(.degrees(Double(offset.width / 20)))
                    .gesture(dragGesture)
            } else {
                VStack(spacing: EnamelMetrics.inset) {
                    Text("^[\(viewModel.kept.count) routine](inflect: true) selected")
                        .font(EnamelType.bodyBold())
                    EnamelButton(viewModel.isSaving ? "Saving…" : "Start journal") {
                        Task {
                            if await viewModel.finish() { onComplete() }
                        }
                    }
                    .disabled(viewModel.isSaving)
                }
                .enamelCard()
            }

            HStack {
                Label("Discard", systemImage: "xmark")
                    .foregroundStyle(EnamelPalette.redBrown)
                Spacer()
                Text("\(viewModel.deck.count) left")
                    .font(EnamelType.body(14))
                    .foregroundStyle(EnamelPalette.inkDim)
                Spacer()
                Label("Keep", systemImage: "checkmark")
                    .foregroundStyle(EnamelPalette.green)
            }
            .font(EnamelType.body(14))
            .padding(.horizontal)
        }
        .padding(EnamelMetrics.gutter)
        .enamelGround()
    }

    private func routineCard(_ card: StarterRoutine) -> some View {
        VStack(spacing: EnamelMetrics.inset) {
            SlotBadge(slot: card.slot)
            Text(card.title)
                .font(EnamelType.title(24))
                .foregroundStyle(EnamelPalette.ink)
            Text("Swipe right to keep, left to skip")
                .font(EnamelType.body(14))
                .foregroundStyle(EnamelPalette.inkDim)
        }
        .frame(maxWidth: .infinity)
        .padding(EnamelMetrics.gutter * 2)
        .enamelBadge(fill: .white.opacity(0.6))
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in offset = value.translation }
            .onEnded { value in
                let threshold: CGFloat = 80
                withAnimation(EnamelMotion.rowSlide(reduceMotion: reduceMotion)) {
                    if value.translation.width > threshold {
                        viewModel.keepCurrent()
                    } else if value.translation.width < -threshold {
                        viewModel.discardCurrent()
                    }
                    offset = .zero
                }
            }
    }
}

#Preview {
    OnboardingDeckView(
        viewModel: DenlyContainer.preview().makeOnboardingViewModel(),
        onComplete: {}
    )
}
