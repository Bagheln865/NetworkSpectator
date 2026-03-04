//
//  LogSessionManagerTests.swift
//  NetworkSpectator
//
//  Created by Pankaj Bawane on 03/03/26.
//

import Testing
import Foundation
@testable import NetworkSpectator

// MARK: - LogSessionManager Tests
@Suite("LogSessionManager Tests")
struct LogSessionManagerTests {

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private func makeManager() -> (LogSessionManager, MockFileStorage, URL) {
        let mockFS = MockFileStorage()
        let baseURL = URL(fileURLWithPath: "/tmp/test-session-manager")
        let storage = LogHistoryStorage(fileManager: mockFS, baseURL: baseURL)
        let manager = LogSessionManager(storage: storage, debounceInterval: .milliseconds(100))
        return (manager, mockFS, baseURL)
    }

    private func sampleLogItem(
        url: String = "https://api.example.com/users",
        startTime: Date = Date(),
        finishTime: Date? = nil,
        statusCode: Int = 200,
        isLoading: Bool = true
    ) -> LogItem {
        LogItem(
            startTime: startTime,
            url: url,
            method: "GET",
            headers: ["Content-Type": "application/json"],
            requestBody: "",
            statusCode: statusCode,
            responseBody: isLoading ? "" : "{\"ok\":true}",
            responseHeaders: isLoading ? [:] : ["Content-Type": "application/json"],
            finishTime: finishTime,
            responseTime: finishTime.map { $0.timeIntervalSince(startTime) } ?? 0,
            isLoading: isLoading
        )
    }

    @Test("Session start time is set from first item")
    func testSessionStartTime() async {
        let (manager, mockFS, _) = makeManager()
        let startTime = Date(timeIntervalSince1970: 1709400000)

        let item = sampleLogItem(startTime: startTime)
        await manager.appendItem(item)
        await manager.finalizeSession()

        let expectedStart = dateFormatter.string(from: startTime)

        let storage = LogHistoryStorage(fileManager: mockFS, baseURL: URL(fileURLWithPath: "/tmp/test-session-manager"))
        let keys = storage.listKeys()
        #expect(keys.count == 1)
        #expect(keys.first?.hasPrefix(expectedStart) == true)
    }

    @Test("Session end time updates with each appended item")
    func testEndTimeUpdatesOnAppend() async {
        let (manager, mockFS, _) = makeManager()
        let time1 = Date(timeIntervalSince1970: 1709400000)
        let time2 = Date(timeIntervalSince1970: 1709400010)
        let time3 = Date(timeIntervalSince1970: 1709400020)

        await manager.appendItem(sampleLogItem(url: "https://a.com", startTime: time1))
        await manager.appendItem(sampleLogItem(url: "https://b.com", startTime: time2))
        await manager.appendItem(sampleLogItem(url: "https://c.com", startTime: time3))
        await manager.finalizeSession()

        let storage = LogHistoryStorage(fileManager: mockFS, baseURL: URL(fileURLWithPath: "/tmp/test-session-manager"))
        let keys = storage.listKeys()
        #expect(keys.count == 1)

        let expectedStart = dateFormatter.string(from: time1)
        let expectedEnd = dateFormatter.string(from: time3)
        let expectedKey = "\(expectedStart) - \(expectedEnd)"
        #expect(keys.first == expectedKey)
    }

    @Test("Update item uses finishTime as end time")
    func testUpdateItemUsesFinishTime() async {
        let (manager, mockFS, _) = makeManager()
        let startTime = Date(timeIntervalSince1970: 1709400000)
        let finishTime = Date(timeIntervalSince1970: 1709400005)

        let loadingItem = sampleLogItem(startTime: startTime, isLoading: true)
        await manager.appendItem(loadingItem)

        let completedItem = LogItem(
            id: loadingItem.id,
            startTime: startTime,
            url: loadingItem.url,
            method: "GET",
            statusCode: 200,
            responseBody: "{\"ok\":true}",
            finishTime: finishTime,
            responseTime: 5.0,
            isLoading: false
        )
        await manager.updateItem(completedItem, at: 0)
        await manager.finalizeSession()

        let storage = LogHistoryStorage(fileManager: mockFS, baseURL: URL(fileURLWithPath: "/tmp/test-session-manager"))
        let keys = storage.listKeys()
        #expect(keys.count == 1)

        let expectedEnd = dateFormatter.string(from: finishTime)
        #expect(keys.first?.hasSuffix(expectedEnd) == true)
    }

    @Test("Debounce coalesces writes")
    func testDebounceCoalescesWrites() async {
        let (manager, mockFS, _) = makeManager()

        // Append 10 items rapidly
        for i in 0..<10 {
            let time = Date(timeIntervalSince1970: 1709400000 + Double(i))
            await manager.appendItem(sampleLogItem(url: "https://api.com/\(i)", startTime: time))
        }

        // At this point, the debounce timer hasn't fired yet, so no files should exist
        let filesBeforeDebounce = mockFS.files.filter { $0.key.contains("json") }.count
        #expect(filesBeforeDebounce == 0)

        // Wait for debounce to fire
        try? await Task.sleep(for: .milliseconds(200))

        // Now exactly one file should exist with all 10 items
        let storage = LogHistoryStorage(fileManager: mockFS, baseURL: URL(fileURLWithPath: "/tmp/test-session-manager"))
        let keys = storage.listKeys()
        #expect(keys.count == 1)

        if let key = keys.first {
            let items = storage.retrieve(forKey: key)
            #expect(items.count == 10)
        }
    }

    @Test("Key is renamed when end time changes")
    func testKeyRenameOnEndTimeChange() async {
        let (manager, mockFS, _) = makeManager()
        let time1 = Date(timeIntervalSince1970: 1709400000)
        let time2 = Date(timeIntervalSince1970: 1709400060)

        await manager.appendItem(sampleLogItem(startTime: time1))

        // Wait for first debounce write
        try? await Task.sleep(for: .milliseconds(200))

        let storage = LogHistoryStorage(fileManager: mockFS, baseURL: URL(fileURLWithPath: "/tmp/test-session-manager"))
        let firstKeys = storage.listKeys()
        #expect(firstKeys.count == 1)
        let firstKey = firstKeys.first

        // Append another item with a later time
        await manager.appendItem(sampleLogItem(url: "https://b.com", startTime: time2))

        // Wait for second debounce write
        try? await Task.sleep(for: .milliseconds(200))

        let secondKeys = storage.listKeys()
        #expect(secondKeys.count == 1)
        #expect(secondKeys.first != firstKey)

        let expectedEnd = dateFormatter.string(from: time2)
        #expect(secondKeys.first?.hasSuffix(expectedEnd) == true)
    }

    @Test("Finalize writes immediately bypassing debounce")
    func testFinalizeWritesImmediately() async {
        let (manager, mockFS, _) = makeManager()
        let time = Date(timeIntervalSince1970: 1709400000)

        await manager.appendItem(sampleLogItem(startTime: time))
        await manager.finalizeSession()

        let storage = LogHistoryStorage(fileManager: mockFS, baseURL: URL(fileURLWithPath: "/tmp/test-session-manager"))
        let keys = storage.listKeys()
        #expect(keys.count == 1)

        if let key = keys.first {
            let items = storage.retrieve(forKey: key)
            #expect(items.count == 1)
        }
    }

    @Test("Finalize resets state for new session")
    func testFinalizeResetsState() async {
        let (manager, mockFS, _) = makeManager()
        let time1 = Date(timeIntervalSince1970: 1709400000)
        let time2 = Date(timeIntervalSince1970: 1709500000)

        // First session
        await manager.appendItem(sampleLogItem(url: "https://session1.com", startTime: time1))
        await manager.finalizeSession()

        // Second session
        await manager.appendItem(sampleLogItem(url: "https://session2.com", startTime: time2))
        await manager.finalizeSession()

        let storage = LogHistoryStorage(fileManager: mockFS, baseURL: URL(fileURLWithPath: "/tmp/test-session-manager"))
        let keys = storage.listKeys()
        #expect(keys.count == 2)

        for key in keys {
            let items = storage.retrieve(forKey: key)
            #expect(items.count == 1)
        }
    }

    @Test("Empty session does not write")
    func testEmptySessionDoesNotWrite() async {
        let (manager, mockFS, _) = makeManager()

        await manager.finalizeSession()

        let filesWritten = mockFS.files.filter { $0.key.contains("json") }.count
        #expect(filesWritten == 0)
    }

    @Test("Update with out-of-bounds index recovers by ID lookup")
    func testUpdateRecoversByIdLookup() async {
        let (manager, mockFS, _) = makeManager()
        let time = Date(timeIntervalSince1970: 1709400000)
        let finishTime = Date(timeIntervalSince1970: 1709400005)

        let loadingItem = sampleLogItem(startTime: time, isLoading: true)
        await manager.appendItem(loadingItem)

        let completedItem = LogItem(
            id: loadingItem.id,
            startTime: time,
            url: loadingItem.url,
            method: "GET",
            statusCode: 200,
            responseBody: "{\"ok\":true}",
            finishTime: finishTime,
            responseTime: 5.0,
            isLoading: false
        )

        // Pass an invalid index — should recover by finding the item by ID
        await manager.updateItem(completedItem, at: 999)
        await manager.finalizeSession()

        let storage = LogHistoryStorage(fileManager: mockFS, baseURL: URL(fileURLWithPath: "/tmp/test-session-manager"))
        let keys = storage.listKeys()
        #expect(keys.count == 1)

        if let key = keys.first {
            let items = storage.retrieve(forKey: key)
            #expect(items.count == 1)
            #expect(items.first?.isLoading == false)
            #expect(items.first?.statusCode == 200)
        }
    }

    @Test("Preserves all items through session persistence")
    func testPreservesAllItems() async {
        let (manager, mockFS, _) = makeManager()
        let baseTime = Date(timeIntervalSince1970: 1709400000)

        for i in 0..<5 {
            let time = Date(timeIntervalSince1970: 1709400000 + Double(i * 10))
            await manager.appendItem(sampleLogItem(
                url: "https://api.com/endpoint\(i)",
                startTime: time,
                statusCode: 200 + i
            ))
        }

        await manager.finalizeSession()

        let storage = LogHistoryStorage(fileManager: mockFS, baseURL: URL(fileURLWithPath: "/tmp/test-session-manager"))
        let keys = storage.listKeys()
        #expect(keys.count == 1)

        if let key = keys.first {
            let items = storage.retrieve(forKey: key)
            #expect(items.count == 5)
            #expect(items[0].url == "https://api.com/endpoint0")
            #expect(items[4].url == "https://api.com/endpoint4")
            #expect(items[2].statusCode == 202)

            let expectedStart = dateFormatter.string(from: baseTime)
            let expectedEnd = dateFormatter.string(from: Date(timeIntervalSince1970: 1709400040))
            #expect(key == "\(expectedStart) - \(expectedEnd)")
        }
    }
}
