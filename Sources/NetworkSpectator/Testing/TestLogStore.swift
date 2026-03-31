//
//  TestLogStore.swift
//  NetworkSpectator
//
//  Created by Pankaj Bawane on 29/03/26.
//

import Foundation

/// Persists test network logs incrementally to disk using append-only JSONL.
/// Each completed request is written immediately so logs survive crashes
/// or unexpected test termination without requiring a finalize call.
///
/// The JSONL file can be read by an external CI tool for processing,
/// grouping, and artifact generation.
///
/// Output path defaults to `/tmp/NetworkSpectator/unit_test_logs.jsonl`
/// (outside the XCTest sandbox, stable across CI steps).
/// Can be overridden via the `NETWORK_SPECTATOR_TESTS_OUTPUT_DIR` environment variable.
actor TestLogStore {
    
    static let shared = TestLogStore()
    
    /// Default output directory — `/tmp/NetworkSpectator/`.
    /// Lives outside the XCTest sandbox so the file persists between CI steps.
    private static let defaultDirectory = URL(fileURLWithPath: "/tmp/NetworkSpectator", isDirectory: true)
    
    /// Tracks in-flight requests by ID so we can pair request → response.
    private var pending: [UUID: LogItem] = [:]
    
    /// File handle for append-only writes.
    private var fileHandle: FileHandle?
    
    /// Encoder reused across writes.
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return encoder
    }()
    
    private init() {
        self.fileHandle = Self.setupFile()
    }
    
    // MARK: - File Setup
    
    /// Output directory, configurable via environment variable.
    private static var outputDirectory: URL {
        if let envPath = ProcessInfo.processInfo.environment["NETWORK_SPECTATOR_TESTS_OUTPUT_DIR"] {
            return URL(fileURLWithPath: envPath, isDirectory: true)
        }
        return defaultDirectory
    }
    
    static var jsonlFileURL: URL {
        outputDirectory.appendingPathComponent("unit_test_logs.jsonl")
    }
    
    /// Creates the output directory and JSONL file, returning the file handle.
    private static func setupFile() -> FileHandle? {
        let dir = outputDirectory
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        
        let fileURL = jsonlFileURL
        // Clear any previous run's data.
        if FileManager.default.fileExists(atPath: fileURL.path()) {
            try? FileManager.default.removeItem(at: fileURL)
        }
        FileManager.default.createFile(atPath: fileURL.path(), contents: nil)
        do {
            let handle = try FileHandle(forWritingTo: fileURL)
            handle.seekToEndOfFile()
            return handle
        } catch {
            DebugPrint.log(error.localizedDescription)
            return nil
        }
    }
    
    // MARK: - Recording
    
    /// Called twice per request: once for initiation (isLoading == true),
    /// once for completion (isLoading == false).
    func add(_ item: LogItem) {
        if item.isLoading {
            pending[item.id] = item
        } else {
            pending.removeValue(forKey: item.id)
            appendToDisk(item)
        }
    }
    
    // MARK: - Disk Writes
    
    private func appendToDisk(_ item: LogItem) {
        guard let data = try? encoder.encode(item),
              var line = String(data: data, encoding: .utf8) else {
            return
        }
        line.append("\n")
        if let lineData = line.data(using: .utf8) {
            fileHandle?.write(lineData)
        }
    }
}

