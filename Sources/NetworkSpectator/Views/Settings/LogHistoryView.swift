//
//  LogHistoryView.swift
//  NetworkSpectator
//
//  Created by Pankaj Bawane on 03/03/26.
//

import SwiftUI

struct LogHistoryView: View {
    
    let storage: LogHistoryStorage
    @State var logs: [HistoryItem]
    
    init() {
        storage = LogHistoryStorage()
        logs = storage.listKeys()
    }
    
    var body: some View {
        
        List(logs, id: \.key) { log in
            NavigationLink(log.key) {
                let items = storage.retrieve(forKey: log.key)
                RootView(isLoggingLive: false, logsHistory: items)
            }
        }
    }
}
