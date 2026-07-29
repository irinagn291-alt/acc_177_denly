import SwiftUI
import UIKit

/// Procedural enamel badge coloured from the pet name, or a photo / plaque.
public struct PetAvatarBadge: View {
    private let name: String
    private let species: String
    private let size: CGFloat
    private let avatarRelativePath: String?
    private let usePlaqueFallback: Bool

    public init(
        name: String,
        species: String = "",
        size: CGFloat = 56,
        avatarRelativePath: String? = nil,
        usePlaqueFallback: Bool = false
    ) {
        self.name = name
        self.species = species
        self.size = size
        self.avatarRelativePath = avatarRelativePath
        self.usePlaqueFallback = usePlaqueFallback
    }

    public var body: some View {
        ZStack {
            if let uiImage = PetAvatarStore().loadImage(relativePath: avatarRelativePath) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else if usePlaqueFallback {
                Image("EnamelHabitatPlaque")
                    .resizable()
                    .scaledToFill()
            } else {
                Circle().fill(fill)
                Text(monogram)
                    .font(EnamelType.bodyBold(size * 0.38))
                    .foregroundStyle(EnamelPalette.cream)
                    .offset(x: -0.5, y: -0.5)
                Text(monogram)
                    .font(EnamelType.bodyBold(size * 0.38))
                    .foregroundStyle(EnamelPalette.cream.opacity(0.55))
                    .offset(x: 0.5, y: 0.5)
                    .blendMode(.multiply)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay {
            Circle()
                .strokeBorder(EnamelPalette.ink, lineWidth: EnamelMetrics.stroke)
        }
        .accessibilityLabel(species.isEmpty ? name : "\(name), \(species)")
    }

    private var monogram: String {
        let parts = name.split(separator: " ").prefix(2)
        if parts.count >= 2 {
            return parts.map { String($0.prefix(1)).uppercased() }.joined()
        }
        return String(name.prefix(2)).uppercased()
    }

    private var fill: Color {
        let palette = [
            EnamelPalette.green,
            EnamelPalette.redBrown,
            EnamelPalette.mustard,
            EnamelPalette.ink
        ]
        var hash = 0
        for scalar in name.unicodeScalars {
            hash = (hash &* 31 &+ Int(scalar.value)) & 0x7FFF_FFFF
        }
        return palette[hash % palette.count]
    }
}

/// Compact species chip.
public struct SpeciesChip: View {
    private let species: String

    public init(_ species: String) {
        self.species = species
    }

    public var body: some View {
        HStack(spacing: 6) {
            Image("EnamelSpeciesMark")
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
            Text(species.uppercased())
                .font(EnamelType.badge())
                .foregroundStyle(EnamelPalette.cream)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(EnamelPalette.redBrown)
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .strokeBorder(EnamelPalette.ink, lineWidth: 1)
        }
    }
}
