import Foundation

/// Runs without launching the audio app or requesting macOS permissions.
@main
struct LocalProfilesChecks {
    @MainActor
    static func main() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let cache = root.appendingPathComponent("AutoEQ/fetched")
        try FileManager.default.createDirectory(at: cache, withIntermediateDirectories: true)
        let store = AutoEQFetcher(directory: root)
        await store.loadCatalog()
        precondition(store.catalog.isEmpty && store.catalogState == .loaded)

        let validText = "Preamp: -3 dB\nFilter 1: ON PK Fc 1000 Hz Gain -2 dB Q 1.41\n"
        let valid = AutoEQCatalogEntry(id: "test-headphones", name: "Test", measuredBy: "Test", relativePath: "unused")
        try validText.write(to: cache.appendingPathComponent("test-headphones.txt"), atomically: true, encoding: .utf8)
        let loaded = try await store.fetchProfile(for: valid)
        precondition(loaded.filters.count == 1 && loaded.preampDB == -3)

        // Valid EQ content outside the profile directory must never be accepted.
        try validText.write(to: root.appendingPathComponent("outside.txt"), atomically: true, encoding: .utf8)
        for id in ["../../outside", "/tmp/outside", "..", "", "test/headphones", "test%2fheadphones"] {
            let malicious = AutoEQCatalogEntry(id: id, name: "Bad", measuredBy: "Test", relativePath: "unused")
            do {
                _ = try await store.fetchProfile(for: malicious)
                fatalError("Accepted unsafe identifier: \(id)")
            } catch AutoEQFetcher.ProfileError.unavailable { }
        }

        let linked = AutoEQCatalogEntry(id: "linked", name: "Link", measuredBy: "Test", relativePath: "unused")
        try FileManager.default.createSymbolicLink(at: cache.appendingPathComponent("linked.txt"), withDestinationURL: root.appendingPathComponent("outside.txt"))
        do {
            _ = try await store.fetchProfile(for: linked)
            fatalError("Accepted symbolic link")
        } catch AutoEQFetcher.ProfileError.unavailable { }

        let oversized = String(repeating: "#", count: 1024 * 1024 + 1) + "\n" + validText
        try oversized.write(to: cache.appendingPathComponent("large.txt"), atomically: true, encoding: .utf8)
        do {
            _ = try await store.fetchProfile(for: .init(id: "large", name: "Large", measuredBy: "Test", relativePath: "unused"))
            fatalError("Accepted oversized profile")
        } catch AutoEQFetcher.ProfileError.unavailable { }

        let missing = AutoEQCatalogEntry(id: "missing", name: "Missing", measuredBy: "Test", relativePath: "unused")
        let traversal = AutoEQCatalogEntry(id: "../../outside", name: "Bad", measuredBy: "Test", relativePath: "unused")
        try JSONEncoder().encode([valid, missing, traversal]).write(to: root.appendingPathComponent("autoeq-catalog.json"))
        await store.loadCatalog()
        precondition(store.catalog == [valid])
        print("PASS: empty offline cache, valid EQ, six unsafe IDs, symlink, size limit, catalog filtering")
    }
}
