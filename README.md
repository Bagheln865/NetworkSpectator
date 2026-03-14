# NetworkSpectator: Monitor/Intercept HTTP Traffic on iOS and macOS

![Swift 6.0+](https://img.shields.io/badge/Swift-6.0%2B-orange?logo=swift)
![Platforms](https://img.shields.io/badge/Platforms-iOS%2016.0%2B%20%7C%20macOS%2013.0%2B-blue)
![SPM Compatible](https://img.shields.io/badge/SPM-Compatible-brightgreen?logo=swift)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/pankajbawane/NetworkSpectator/blob/main/LICENSE)
[![Build](https://github.com/Pankajbawane/NetworkSpectator/actions/workflows/ci.yml/badge.svg)](https://github.com/Pankajbawane/NetworkSpectator/actions/workflows/ci.yml)

A Swift framework for monitoring and inspecting your app's HTTP traffic during development and testing. NetworkSpectator captures requests and responses, provides a clean UI for browsing and mocking them, and allows you to export logs for sharing.

## Features

- **Real-time network monitoring**
  - Capture URL, method, status code, response time, headers, request body, and response body
  - Live updates with in-progress indicators for pending requests
  - Start immediately or use **on-demand mode** to enable monitoring from the UI when needed
  - Color-coded list view with method badges, status indicators, and response metrics
 
- **Filtering and search**
  - Filter by status code ranges and HTTP methods
  - Combine multiple filters with visual filter chips
  - Full-text URL search across all captured requests

- **Detailed request inspection**
  - Tabbed detail view: Overview, Request, Headers, and Response
  - Smart response rendering — pretty-printed JSON, inline image previews, and plain text
  - Copy any request or response data to clipboard
  - Create a mock or skip rule directly from a captured request

- **Export in multiple formats**
  - **CSV** — bulk or single request export for spreadsheets and analysis
  - **Plain text** — human-readable format for quick sharing
  - **Postman Collection** — import directly into Postman for API testing

- **Mock responses**
  - Intercept requests and return custom responses without a backend
  - Flexible matching: hostname, URL, path, endPath, subPath
  - Configure status codes, headers, JSON/raw body, and response delay
  - **Programmatic mocking** — register mocks via code for unit tests and development
  - **UI-based mocking** — let QA testers create and manage mocks on the fly without Xcode
  - **Persist mocks** across app sessions with local storage

- **Skip request logging**
  - Exclude noisy or sensitive requests using the same flexible matching rules
  - Configure skip rules programmatically or from the UI
  - Persist rules across app launches

- **Insights dashboard**
  - Summary cards: total requests, success rate, and unique hosts
  - Interactive charts for status code distribution, HTTP methods, host traffic, and request timeline

- **Log history**
  - Automatically save session logs to disk for later review
  - Browse past sessions from Tools
  - Enable or disable history persistence from settings

- **Lightweight and easy to integrate**
  - One-line setup to start monitoring
  - No XIB/Storyboards, no external dependencies
  - Works with SwiftUI, UIKit, and AppKit
  - Toggle debug console logging on or off
  - Supports both light and dark mode

- **Cross-platform**
  - iOS 16.0+ / macOS 13.0+


## Installation

### Swift Package Manager

Add NetworkSpectator to your project using Swift Package Manager:

1. In Xcode, select **File > Add Package Dependencies...**
2. Enter the package repository URL - https://github.com/Pankajbawane/NetworkSpectator.git

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/pankajbawane/NetworkSpectator.git", branch: "main")
]
```

## Usage

### Example App
The NetworkSpectatorExample app demonstrates basic usage of the library: https://github.com/Pankajbawane/NetworkSpectatorExample

### Basic Setup

1. **Enable NetworkSpectator** in your app's entry point (AppDelegate or App struct):

Call `NetworkSpectator.start()` to begin listening to HTTP requests. This will automatically log all HTTP traffic.
```swift
import NetworkSpectator

@main
struct MyApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
                    .task {
                        #if DEBUG
                        NetworkSpectator.start()
                        #endif
                      }
        }
    }
}
```

2. **Present the NetworkSpectator UI**:

#### SwiftUI
```swift
import NetworkSpectator

ContentView() {
}
  .sheet(isPresented: $showLogs) {
      NetworkSpectator.rootView
  }

```

#### UIKit (iOS)
```swift
import NetworkSpectator

let networkVC = NetworkSpectator.rootViewController
present(networkVC, animated: true)
```

#### AppKit (macOS)
```swift
import NetworkSpectator

let networkVC = NetworkSpectator.rootViewController
presentAsSheet(networkVC)
```

### Configuration

Customize NetworkSpectator behavior with the configuration methods:

```swift
// Enable or disable printing logs to the debug console
NetworkSpectator.debugLogsPrint(isEnabled: Bool)

// Register a mock response
NetworkSpectator.registerMock(for mock: Mock)

// Remove all registered mocks
NetworkSpectator.stopMocking()

// Skip logging for specific requests
NetworkSpectator.ignoreLogging(for rule: MatchRule)

// Remove all skip logging rules
NetworkSpectator.stopIgnoringLog()
```

### On-Demand Monitoring

Start NetworkSpectator in on-demand mode to let users enable monitoring from the UI:

```swift
NetworkSpectator.start(onDemand: true)
```

### Disabling NetworkSpectator

If enabled, then, to stop network monitoring:

```swift
NetworkSpectator.stop()
```

## NetworkSpectator on iOS
The following screenshots demonstrate NetworkSpectator running on iOS in light mode.

| List of Requests | Filters | URL Search | Details |
|---------|---------|------------|------------|
| <img width="300" height="652" alt="landing" src="https://github.com/user-attachments/assets/e58d675a-1ab7-4a8f-8232-f45323b61b20" /> | <img width="300" height="652" alt="filters_ios" src="https://github.com/user-attachments/assets/32087e71-0c66-4204-aa4e-873a1a28cf67" /> | <img width="300" height="652" alt="url_search_ios" src="https://github.com/user-attachments/assets/5db9d07e-d311-49e6-b1c1-3bf8a2da0a2d" /> | <img width="300" height="652" alt="basic_ios" src="https://github.com/user-attachments/assets/d6d86fc3-eece-4bae-b557-519966040815" /> |

| Headers | Response | Settings | Export & Share |
|---------|----------|----------|-------|
| <img width="300" height="652" alt="headers_ios" src="https://github.com/user-attachments/assets/1fc211e9-382e-4491-af7d-0f590dad5a9d" /> | <img width="300" height="652" alt="response_response" src="https://github.com/user-attachments/assets/9623b659-a0b5-4414-bf59-cd91c600047d" /> | <img width="300" height="652" alt="settings_ios" src="https://github.com/user-attachments/assets/c3f4e364-aa95-4d65-955d-4a35c8a94d68" /> | <img width="300" height="652" alt="share_ios" src="https://github.com/user-attachments/assets/96b0fc82-dcfe-4159-8458-00b815466802" /> |

## NetworkSpectator on macOS
The following screenshots demonstrate NetworkSpectator running on macOS in dark mode.

| List of Requests | Filters | Details |
|------------------|---------|---------------|
| <img width="1169" height="620" alt="landing_mac" src="https://github.com/user-attachments/assets/2006355b-7a6a-47f4-89e2-14f7cf76e8df" /> | <img width="1152" height="609" alt="filters_mac" src="https://github.com/user-attachments/assets/2007cc11-672e-420d-9f13-7110e8b95a2d" /> | <img width="1152" height="833" alt="basic_details_mac" src="https://github.com/user-attachments/assets/65f946ff-90da-4815-b27f-8d02c8bd06f2" /> |

| Headers | Response | Analytics |
|---------|----------|-----------|
| <img width="1152" height="833" alt="headers_mac" src="https://github.com/user-attachments/assets/72a63e17-de57-4218-ab90-5fd2935e0468" /> | <img width="1152" height="833" alt="response_mac" src="https://github.com/user-attachments/assets/0507e4a5-4c24-4a70-838c-4a2802620218" /> | <img width="1152" height="949" alt="analytics_mac" src="https://github.com/user-attachments/assets/152e8e49-7dbb-41f4-9bf8-2e5d3ce6c1af" /> |

| Settings | Add Mock | Skip Logging |
|----------|----------|--------------|
| <img width="1169" height="620" alt="settings_mac" src="https://github.com/user-attachments/assets/e6a7ebee-cd44-415a-910d-ef0273d57495" /> | <img width="1169" height="632" alt="add_mock_mac" src="https://github.com/user-attachments/assets/8353ae97-69b1-46ec-bc32-273463f2c95c" /> | <img width="1169" height="632" alt="skip_logging_mac" src="https://github.com/user-attachments/assets/04400e4b-0e59-4dd1-827f-257c9eda131f" /> |

## Safety and Release Builds

Because NetworkSpectator captures and displays network information, you should **limit it to debug/test builds only**. Wrap your integration points with `#if DEBUG` to ensure nothing leaks into release builds.

### Recommendations:

- Always guard with `#if DEBUG` and/or internal feature flags
- Ensure NetworkSpectator is not initialized in release configurations

### Example:

```swift
// Monitoring will start only for a debug build.
#if DEBUG
NetworkSpectator.start()
#endif
```

## Requirements

- Swift 6+
- iOS 16.0+ / macOS 13.0+
- Xcode 16.0+

## LICENSE
MIT license. View LICENSE for more details.
