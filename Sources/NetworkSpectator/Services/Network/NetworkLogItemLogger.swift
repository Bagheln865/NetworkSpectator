//
//  NetworkItemLogger.swift
//  NetworkSpectator
//
//  Created by Pankaj Bawane on 29/03/26.
//

import Foundation

protocol NetworkItemLogger: Sendable {
    func logging(_ item: LogItem)
}

struct UIItemLogger: NetworkItemLogger {
    func logging(_ item: LogItem) {
        DebugPrint.log(item)
        Task {
            await NetworkLogStore.shared.add(item)
        }
    }
}

struct TestItemLogger: NetworkItemLogger {
    func logging(_ item: LogItem) {
        guard NetworkSpectator.test.isLoggingEnabled else {
            return
        }
        Task {
            await TestLogStore.shared.add(item)
        }
    }
}
