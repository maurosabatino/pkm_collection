import Foundation

enum ResourceLocator {
    static func url(forResource name: String, withExtension ext: String, subdirectory: String) -> URL? {
        let bundles = [Bundle.main] + Bundle.allBundles + Bundle.allFrameworks

        for bundle in bundles {
            if let url = bundle.url(forResource: name, withExtension: ext, subdirectory: subdirectory) {
                return url
            }
            if let url = bundle.url(forResource: "\(subdirectory)/\(name)", withExtension: ext) {
                return url
            }
            if let url = bundle.url(forResource: name, withExtension: ext) {
                return url
            }
        }

        // Fallback for tests or previews that run from source without bundled resources.
        let repoRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent() // ResourceLocator.swift
            .deletingLastPathComponent() // Support
            .deletingLastPathComponent() // Sources
            .deletingLastPathComponent() // Persistence
            .deletingLastPathComponent() // Modules

        let fileURL = repoRoot
            .appendingPathComponent("App/Resources")
            .appendingPathComponent(subdirectory)
            .appendingPathComponent("\(name).\(ext)")
            .standardizedFileURL

        if FileManager.default.fileExists(atPath: fileURL.path) {
            return fileURL
        }

        // Fallback for raw JSON assets kept alongside scripts (not bundled).
        if subdirectory.hasPrefix("db") {
            let trimmed = subdirectory.hasPrefix("db/") ? String(subdirectory.dropFirst(3)) : ""
            let scriptsURL = repoRoot
                .appendingPathComponent("Scripts/db_sources")
                .appendingPathComponent(trimmed)
                .appendingPathComponent("\(name).\(ext)")
                .standardizedFileURL

            if FileManager.default.fileExists(atPath: scriptsURL.path) {
                return scriptsURL
            }
        }

        let flatFileURL = repoRoot
            .appendingPathComponent("App/Resources")
            .appendingPathComponent("\(name).\(ext)")
            .standardizedFileURL

        if FileManager.default.fileExists(atPath: flatFileURL.path) {
            return flatFileURL
        }

        // Fallback for UI test runner bundles where the main bundle is the runner
        // and the tested app sits as a sibling .app in the build products directory.
        let runnerContainer = Bundle.main.bundleURL
            .deletingLastPathComponent()
            .standardizedFileURL

        if FileManager.default.fileExists(atPath: runnerContainer.path) {
            let apps = (try? FileManager.default.contentsOfDirectory(atPath: runnerContainer.path))?
                .filter { $0.hasSuffix(".app") } ?? []

            for app in apps {
                let baseURL = runnerContainer.appendingPathComponent(app, isDirectory: true)

                let subdirURL = baseURL
                    .appendingPathComponent(subdirectory)
                    .appendingPathComponent("\(name).\(ext)")
                    .standardizedFileURL

                if FileManager.default.fileExists(atPath: subdirURL.path) {
                    return subdirURL
                }

                let flatURL = baseURL
                    .appendingPathComponent("\(name).\(ext)")
                    .standardizedFileURL

                if FileManager.default.fileExists(atPath: flatURL.path) {
                    return flatURL
                }
            }
        }

        return nil
    }
}
