//
//  JSONFileStore.swift
//  TaskManager
//
//  Created by Admin on 27/8/2026.
//

import Foundation

// MARK: - Generic JSON-file persistence for any Codable value.
// One small, inspectable mechanism — used by ProjectsStore now,
// and by session history later, instead of scattering File I/O
// logic across multiple stores.
enum JSONFileStore {

    private static func url(for filename: String) -> URL {
        let appSupport = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
        let folder = appSupport.appendingPathComponent("TaskManager", isDirectory: true)

        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder.appendingPathComponent(filename)
    }

    static func load<T: Decodable>(_ type: T.Type, from filename: String) -> T? {
        let fileURL = url(for: filename)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    static func save<T: Encodable>(_ value: T, to filename: String) {
        let fileURL = url(for: filename)
        guard let data = try? JSONEncoder().encode(value) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
