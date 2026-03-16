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
The following screenshots demonstrate NetworkSpectator running on iOS.

| List of Requests | Filters | URL Search | Details |
|---------|---------|------------|------------|
| <img width="300" height="652" alt="landing" src="https://github.com/user-attachments/assets/892fd276-8753-447e-b0c7-8a76158d1862" /> | <img width="300" height="652" alt="filters_ios" src="https://github.com/user-attachments/assets/48151149-087f-4e1b-8512-4f0cd21cfde5" /> | <img width="300" height="652" alt="url_search_ios" src="https://github.com/user-attachments/assets/6b21220a-5827-49da-b640-6c689dd290fb" /> | <img width="300" height="652" alt="basic_ios" src="https://github.com/user-attachments/assets/8c10a744-f910-408f-8c6a-bb67e3c5bc80" /> |

| Headers | Response | Tools | History |
|---------|----------|----------|-------|
| <img width="300" height="652" alt="headers_ios" src="https://github.com/user-attachments/assets/60053303-ccef-4e2d-9aaa-0dffe2937e92" /> | <img width="300" height="652" alt="response_response" src="https://github.com/user-attachments/assets/08fd4cd8-abf5-4e34-b0cb-5646961de148" /> | <img width="300" height="652" alt="settings_ios" src="https://github.com/user-attachments/assets/0a7c54bc-a1ff-49c9-8dde-856e25d2178f" /> | <img width="300" height="652" alt="share_ios" src="https://github.com/user-attachments/assets/8de5d34a-caa8-426e-b09f-ca1ef0558651" /> |

| Insights | Insights - Timeline | Insights - Status code | Insights - Performance |
|---------|---------|----------|-----------|
| <img width="300" height="652" alt="insights_ios" src="https://github.com/user-attachments/assets/44ed2592-d237-4d9e-a963-6acc7219252d" /> | <img width="300" height="652" alt="timeline_ios" src="https://github.com/user-attachments/assets/0b099e24-e392-4d53-a346-7261ef89c555" /> | <img width="300" height="652" alt="status_code_ios" src="https://github.com/user-attachments/assets/6261c815-e579-4c45-8ff0-309ac70836de" /> | <img width="300" height="652" alt="perf_ios" src="https://github.com/user-attachments/assets/8879251a-fb74-4944-984d-e18742bb6860" /> |

## NetworkSpectator on macOS
The following screenshots demonstrate NetworkSpectator running on macOS.

| List of Requests | Filters | Details |
|------------------|---------|---------------|
| <img width="1169" height="620" alt="landing_mac" src="https://github.com/user-attachments/assets/0f9c04e5-ccd2-42aa-8aff-a5c7f0111fd9" /> | <img width="1152" height="609" alt="filters_mac" src="https://github.com/user-attachments/assets/93bc10f9-68a2-4d9d-bc6b-5cabf89c7306" /> | <img width="1152" height="833" alt="basic_details_mac" src="https://github.com/user-attachments/assets/d3f4f9a4-8f3f-4606-b5d0-c1bf32dfd2f5" /> |

| Headers | Response | Tools |
|---------|----------|-----------|
| <img width="1152" height="833" alt="headers_mac" src="https://github.com/user-attachments/assets/7aabd28b-0374-4fcd-817b-63c82d6478a1" /> | <img width="1152" height="833" alt="response_mac" src="https://github.com/user-attachments/assets/64be7c60-c61c-4735-887d-80cb16d4f116" /> | <img width="1152" height="949" alt="analytics_mac" src="https://github.com/user-attachments/assets/598b8967-2633-4441-a768-83e4adcec602" /> |

| Insights | Timeline | Performance |
|----------|----------|--------------|
| <img width="1169" height="620" alt="settings_mac" src="https://github.com/user-attachments/assets/7fdea5e8-99a8-41b7-837d-f50ca061ca42" /> | <img width="1169" height="632" alt="add_mock_mac" src="https://github.com/user-attachments/assets/70337b2b-407b-4f37-9a32-9262cda18d9d" /> | <img width="1169" height="632" alt="skip_logging_mac" src="https://github.com/user-attachments/assets/70c64f35-2445-453a-a31f-fd2af2925640" /> |

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
