//
//  ResponseBodyLineView.swift
//  NetworkSpectator
//
//  Created by Pankaj Bawane on 20/02/26.
//

import SwiftUI

struct ResponseBodyLineView: View {
    private let responseBody: String
    private let isJSON: Bool

    @State private var isProcessing = true
    @State private var texts: [Text] = []

    
    init (responseBody: String, mimetype: String) {
        self.responseBody = responseBody
        isJSON = mimetype.lowercased().contains("json")
    }

    var body: some View {
        Group {
            if isProcessing {
                HStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.8)
                    Text("Loading...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(Array(texts.enumerated()), id: \.offset) { index, line in
                    line
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                        .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .environment(\.defaultMinListRowHeight, 0)
            }
        }
        .task {
            await processContent()
        }
    }

    private func processContent() async {
        // Process on background task to avoid blocking UI
        let formattedTexts = await Task(priority: .userInitiated) {
            let lines = responseBody.components(separatedBy: .newlines)
            var texts: [Text] = []
            texts.reserveCapacity(lines.count + 1)
            for string in lines {
                let text = isJSON ? styledSegments(from: string) : Text(string)
                texts.append(text)
            }
            return texts
        }.value
        
        texts = formattedTexts
        isProcessing = false
    }
    
    func styledSegments(from input: String) -> Text {
        // Matches: quoted strings, numbers, symbols, or whitespace
        let regex = /"[^"]*"|-?\d+\.?\d*([eE][+-]?\d+)?|[:\[\]{},]|true|false|null|\s+|[^\s":\[\]{},]+/
        let matches = input.matches(of: regex)
        
        var result = Text("")
        var expectValue = false
        
        for match in matches {
            let segment = String(match.output.0)
            
            if segment.hasPrefix("\"") {
                if expectValue {
                    // String value
                    result = result + Text(segment).foregroundColor(.blue)
                    expectValue = false
                } else {
                    // Key — medium
                    result = result + Text(segment).foregroundColor(.orange).fontWeight(.medium)
                }
            } else if segment == ":" {
                // Colon — primary color, bold
                result = result + Text(segment).foregroundColor(.primary).bold()
                expectValue = true
            } else if "[]{}".contains(segment) {
                // Brackets/braces — primary color, bold
                result = result + Text(segment).foregroundColor(.primary).bold()
            } else if segment == "," {
                // Comma — primary color, bold
                result = result + Text(segment).foregroundColor(.primary).bold()
                expectValue = false
            } else if segment.first?.isNumber == true || (segment.first == "-" && segment.count > 1) {
                // Number — distinct color
                result = result + Text(segment).foregroundColor(.indigo)
                expectValue = false
            } else if ["true", "false"].contains(segment) {
                // Boolean — distinct color
                result = result + Text(segment).foregroundColor(.teal.opacity(0.9))
                expectValue = false
            } else if segment == "null" {
                // Null — distinct color
                result = result + Text(segment).foregroundColor(.red)
                expectValue = false
            } else {
                // Whitespace and anything else — keep as-is
                result = result + Text(segment)
            }
        }
        return result
    }
}
