import SwiftUI

/// Recent care logs as enamel ledger rows.
public struct CareHistoryView: View {
    private let logs: [CareLog]
    private let emptyDetail: String
    private let onTapNote: ((CareLog) -> Void)?

    public init(
        logs: [CareLog],
        emptyDetail: String = "Complete a routine to start the ledger.",
        onTapNote: ((CareLog) -> Void)? = nil
    ) {
        self.logs = logs
        self.emptyDetail = emptyDetail
        self.onTapNote = onTapNote
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: EnamelMetrics.inset) {
            HStack {
                Text("CARE LEDGER")
                    .font(EnamelType.badge(11))
                    .foregroundStyle(EnamelPalette.inkDim)
                    .tracking(1.2)
                Spacer()
                Text("^[\(logs.count) entry](inflect: true)")
                    .font(EnamelType.body(13))
                    .foregroundStyle(EnamelPalette.inkFaint)
            }

            if logs.isEmpty {
                VStack(spacing: EnamelMetrics.inset) {
                    Image("EnamelEmptyCare")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 120, maxHeight: 90)
                        .accessibilityHidden(true)
                    Text(emptyDetail)
                        .font(EnamelType.body(14))
                        .foregroundStyle(EnamelPalette.inkDim)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 8)
            } else {
                ForEach(logs) { log in
                    Button {
                        onTapNote?(log)
                    } label: {
                        HStack(alignment: .top, spacing: EnamelMetrics.inset) {
                            VStack(spacing: 2) {
                                Text(log.completedAt.formatted(.dateTime.day()))
                                    .font(EnamelType.bodyBold(16))
                                    .foregroundStyle(EnamelPalette.green)
                                Text(log.completedAt.formatted(.dateTime.month(.abbreviated)))
                                    .font(EnamelType.badge(10))
                                    .foregroundStyle(EnamelPalette.inkDim)
                            }
                            .frame(width: 40)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(log.title)
                                    .font(EnamelType.bodyBold())
                                    .foregroundStyle(EnamelPalette.ink)
                                Text(log.completedAt.formatted(date: .omitted, time: .shortened))
                                    .font(EnamelType.body(13))
                                    .foregroundStyle(EnamelPalette.inkDim)
                                if log.notes.isEmpty {
                                    if onTapNote != nil {
                                        Text("Add note")
                                            .font(EnamelType.body(12))
                                            .foregroundStyle(EnamelPalette.mustard)
                                    }
                                } else {
                                    Text(log.notes)
                                        .font(EnamelType.body(13))
                                        .foregroundStyle(EnamelPalette.inkFaint)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                    .disabled(onTapNote == nil)

                    if log.id != logs.last?.id {
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
        .modifier(EnamelStroke(color: EnamelPalette.green.opacity(0.35)))
        .modifier(EnamelMisregister())
    }
}

#Preview {
    CareHistoryView(logs: [
        CareLog(petID: UUID(), title: "Feed", completedAt: Date(), notes: "Half portion"),
        CareLog(petID: UUID(), title: "Walk", completedAt: Date().addingTimeInterval(-86_400))
    ])
    .padding()
    .enamelTexturedGround()
}
