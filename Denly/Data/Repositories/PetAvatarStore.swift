import Foundation
import UIKit

/// Saves pet avatar images under Documents/PetAvatars.
public final class PetAvatarStore: @unchecked Sendable {
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func absoluteURL(for relativePath: String) -> URL? {
        documentsDirectory()?.appendingPathComponent(relativePath)
    }

    public func saveJPEG(_ data: Data, petID: UUID) throws -> String {
        guard let root = documentsDirectory() else {
            throw DenlyError.storeFailure("Documents directory unavailable.")
        }
        let folder = root.appendingPathComponent("PetAvatars", isDirectory: true)
        try fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        let relative = "PetAvatars/\(petID.uuidString).jpg"
        let url = root.appendingPathComponent(relative)
        try data.write(to: url, options: .atomic)
        return relative
    }

    public func loadImage(relativePath: String?) -> UIImage? {
        guard let relativePath,
              let url = absoluteURL(for: relativePath),
              let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    private func documentsDirectory() -> URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}
