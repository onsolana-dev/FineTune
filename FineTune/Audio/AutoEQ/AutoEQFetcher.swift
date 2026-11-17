// Modified 2026-11-17: local-only profile storage for the onsolana-dev fork.
import Foundation

/// Reads previously cached headphone profiles. Never contacts a server.
/// New profiles can be imported through the file picker.
@Observable
@MainActor
final class AutoEQFetcher {
    enum FetchState: Equatable {
        case idle, loading, loaded, error(String)
    }

    private(set) var catalogState: FetchState = .idle
    private(set) var catalog: [AutoEQCatalogEntry] = []
    private let directory: URL

    init(directory: URL? = nil) {
        self.directory = directory ?? FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first!.appendingPathComponent("FineTune")
    }

    func loadCatalog() async {
        let url = directory.appendingPathComponent("autoeq-catalog.json")
        if let data = readLocalFile(url, maxBytes: 4 * 1024 * 1024),
           let entries = try? JSONDecoder().decode([AutoEQCatalogEntry].self, from: data) {
            // Show only profiles actually available on this Mac.
            catalog = entries.filter { entry in
                guard let file = profileURL(id: entry.id) else { return false }
                return FileManager.default.fileExists(atPath: file.path)
            }
        } else {
            catalog = []
        }
        catalogState = .loaded
    }

    func fetchProfile(for entry: AutoEQCatalogEntry) async throws -> AutoEQProfile {
        guard let file = profileURL(id: entry.id),
              let data = readLocalFile(file, maxBytes: 1024 * 1024),
              let text = String(data: data, encoding: .utf8),
              let profile = AutoEQParser.parse(
                text: text, name: entry.name, source: .fetched, id: entry.id
              ) else {
            throw ProfileError.unavailable
        }
        return AutoEQProfile(
            id: profile.id, name: profile.name, source: profile.source,
            preampDB: profile.preampDB, filters: profile.filters,
            measuredBy: entry.measuredBy, optimizedSampleRate: 48000
        )
    }

    private func profileURL(id: String) -> URL? {
        // Cache metadata cannot turn an identifier into an arbitrary file path.
        guard !id.isEmpty, id.count <= 240,
              id.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "-" }) else { return nil }
        return directory.appendingPathComponent("AutoEQ/fetched")
            .appendingPathComponent("\(id).txt")
    }

    private func readLocalFile(_ url: URL, maxBytes: Int) -> Data? {
        guard url.isFileURL,
              let values = try? url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey]),
              values.isRegularFile == true, values.isSymbolicLink != true,
              let size = values.fileSize, size <= maxBytes else { return nil }
        // Bound the actual read too, in case the file grows after the size check.
        guard let handle = try? FileHandle(forReadingFrom: url) else { return nil }
        defer { try? handle.close() }
        guard let data = try? handle.read(upToCount: maxBytes + 1), data.count <= maxBytes else { return nil }
        return data
    }

    enum ProfileError: LocalizedError {
        case unavailable
        var errorDescription: String? {
            "This profile is not available locally. Import a ParametricEQ.txt file to use it."
        }
    }
}
