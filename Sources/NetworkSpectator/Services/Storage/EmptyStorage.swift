//
//  EmptyStorage.swift
//  NetworkSpectator
//
//  Created by Pankaj Bawane on 30/03/26.
//

import Foundation

struct EmptyStorage: Storeable {
    func set(_ value: Any?, forKey defaultName: String) {
        // Intentionally do nothing.
    }
    
    func data(forKey defaultName: String) -> Data? {
        // Intentionally do nothing.
        nil
    }
    
    func removeObject(forKey defaultName: String) {
        // Intentionally do nothing.
    }
    
    func value(forKey defaultName: String) -> Any? {
        // Intentionally do nothing.
        nil
    }
    
    func synchronize() -> Bool {
        // Intentionally do nothing.
        true
    }
}


