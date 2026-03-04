//
//  LogSessionManager.swift
//  NetworkSpectator
//
//  Created by Pankaj Bawane on 03/03/26.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Manages session-based persistence of log items to disk.
/// All disk I/O runs on the actor's serial executor, off the main thread.
actor LogSessionManager {

    // MARK: - Dependencies

    private let storage: LogHistoryStorage

    // MARK: - Session State

    private var sessionItems: [LogItem] = []
    private var sessionStartTime: Date?
    private var sessionEndTime: Date?
    private var currentKey: String?

    // MARK: - Debounce State

    private var writeTask: Task<Void, Never>?
    private let debounceInterval: Duration

    // MARK: - Date Formatting

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    // MARK: - Singleton

    static let shared = LogSessionManager()

    init(storage: LogHistoryStorage = LogHistoryStorage(),
         debounceInterval: Duration = .seconds(2)) {
        self.storage = storage
        self.debounceInterval = debounceInterval
        observeAppLifecycle()
    }

    // MARK: - Public API

    /// Called when a new log item is appended (request initiated).
    func appendItem(_ item: LogItem) {
        if sessionStartTime == nil {
            sessionStartTime = item.startTime
        }
        sessionItems.append(item)
        sessionEndTime = item.startTime
        scheduleDebouncedWrite()
    }

    /// Called when an existing log item is updated (response received).
    func updateItem(_ item: LogItem, at index: Int) {
        if index < sessionItems.count, sessionItems[index].id == item.id {
            sessionItems[index] = item
        } else if let existingIndex = sessionItems.firstIndex(where: { $0.id == item.id }) {
            sessionItems[existingIndex] = item
        } else {
            sessionItems.append(item)
        }
        sessionEndTime = item.finishTime ?? item.startTime
        scheduleDebouncedWrite()
    }

    /// Immediately persists the current session and resets state.
    func finalizeSession() {
        writeTask?.cancel()
        writeTask = nil
        persistCurrentSession()
        resetSession()
    }

    // MARK: - Debounce

    private func scheduleDebouncedWrite() {
        writeTask?.cancel()
        let interval = debounceInterval
        writeTask = Task { [weak self] in
            do {
                try await Task.sleep(for: interval)
            } catch {
                return // Cancelled
            }
            await self?.persistCurrentSession()
        }
    }

    // MARK: - Persistence

    private func persistCurrentSession() {
        guard !sessionItems.isEmpty,
              let start = sessionStartTime,
              let end = sessionEndTime else { return }
        
        let data = try? JSONEncoder().encode(sessionItems)
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        formatter.allowedUnits = [.useKB, .useMB, .useBytes]
        formatter.includesUnit = true
        
        let size = formatter.string(fromByteCount: Int64(data?.count ?? 0))

        let newKey = "\(dateFormatter.string(from: start)) - \(dateFormatter.string(from: end)) | Total: \(sessionItems.count) | Size: " + size

        // If key changed, remove the old file
        if let oldKey = currentKey, oldKey != newKey {
            storage.delete(forKey: oldKey)
        }

        storage.save(sessionItems, forKey: newKey)
        currentKey = newKey
    }

    private func resetSession() {
        sessionItems.removeAll()
        sessionStartTime = nil
        sessionEndTime = nil
        currentKey = nil
    }

    // MARK: - App Lifecycle

    private nonisolated func observeAppLifecycle() {
        #if canImport(UIKit)
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            guard let self else { return }
            Task { await self.finalizeSession() }
        }
        NotificationCenter.default.addObserver(
            forName: UIApplication.willTerminateNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            guard let self else { return }
            Task { await self.finalizeSession() }
        }
        #elseif canImport(AppKit)
        NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            guard let self else { return }
            Task { await self.finalizeSession() }
        }
        #endif
    }
}
