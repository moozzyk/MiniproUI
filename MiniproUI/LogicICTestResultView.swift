//
//  LogicICTestResultView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 3/15/25.
//

import SwiftUI

struct LogicICTestResultView: View {
    @Binding var logicICTestResult: LogicICTestResult?

    var body: some View {
        if let testResult = logicICTestResult {
            ScrollView([.horizontal, .vertical]) {
                VStack {
                    Grid {
                        GridRow {
                            HStack {
                                Text(" ")
                                Divider()
                            }
                            ForEach(0..<testResult.testVectors[0].count, id: \.self) { idx in
                                Text("\(idx + 1)")
                                    .frame(width: 20, alignment: .leading)
                            }
                        }
                        ForEach(0..<testResult.testVectors.count, id: \.self) { idx in
                            Divider()
                            GridRow {
                                HStack {
                                    Text("\(idx + 1)")
                                    Divider()
                                }
                                TestVectorView(testVector: testResult.testVectors[idx])
                            }
                        }
                    }
                }
            }
        } else {
            Text("Click the \"Test\" button to start the test")
        }
    }
}

struct TestVectorView: View {
    let testVector: [String]

    var body: some View {
        ForEach(testVector, id: \.self) { result in
            Text(result)
                .frame(width: 20, alignment: .leading)
                .foregroundColor(getResultColor(result))
                .fontWeight(.bold)
        }
    }

    func getResultColor(_ result: String) -> Color {
        if result == "H" || result == "L" || result == "Z" {
            return .green
        }
        if result.last == "-" {
            return .red
        }
        return .primary
    }

}

#Preview {
    LogicICTestResultView(
        logicICTestResult: .constant(
            LogicICTestResult(
                device: "7414",
                numErrors: 10,
                testVectors: [
                    ["1", "0", "0", "1", "0", "1", "1", "G", "1", "1", "X", "X", "X", "X", "X", "V"],
                    ["1", "C", "0", "1", "0", "1", "1", "G", "0", "1", "H", "L-", "H", "L-", "H", "V"],
                    ["1", "C", "X", "X", "X", "X", "0", "G", "1", "0", "H-", "L-", "H-", "H-", "L-", " V"],
                    ["1", "C", "X", "X", "X", "X", "0", "G", "1", "0", "L-", "H-", "L-", "L-", "H-", " V"],
                    ["1", "C", "0", "0", "1", "1", "1", "G", "0", "1", "H", "H", "L-", "L-", "H", "V"],
                    ["1", "C", "X", "X", "X", "X", "0", "G", "1", "0", "H-", "H-", "L-", "H-", "L-", " V"],
                    ["1", "C", "X", "X", "X", "X", "0", "G", "1", "0", "L-", "H-", "L-", "L-", "H-", " V"],
                    ["1", "C", "0", "1", "1", "1", "1", "G", "0", "1", "H", "H", "H", "L-", "H", "V"],
                    ["1", "C", "X", "X", "X", "X", "0", "G", "1", "0", "H-", "H-", "H-", "H-", "L-", " V"],
                    ["1", "C", "X", "X", "X", "X", "0", "G", "1", "0", "L-", "L-", "L-", "L-", "H-", " V"],
                    ["1", "C", "X", "X", "X", "X", "0", "G", "1", "0", "L-", "L-", "L-", "H-", "H-", " V"],
                    ["1", "C", "X", "X", "X", "X", "0", "G", "1", "0", "L-", "L-", "H-", "L-", "H-", " V"],
                    ["1", "C", "X", "X", "X", "X", "0", "G", "1", "0", "L-", "L-", "H-", "H-", "H-", " V"],
                    ["1", "C", "X", "X", "X", "X", "0", "G", "1", "0", "L-", "H-", "L-", "L-", "H-", " V"],
                    ["1", "C", "X", "X", "X", "X", "0", "G", "1", "0", "L-", "H-", "L-", "H-", "H-", " V"],
                    ["1", "C", "X", "X", "X", "X", "0", "G", "1", "0", "L-", "H-", "H-", "L-", "H-", " V"],
                    ["1", "C", "X", "X", "X", "X", "0", "G", "1", "0", "L-", "H-", "H-", "H-", "H-", " V"],
                    ["1", "C", "X", "X", "X", "X", "0", "G", "1", "0", "H-", "L-", "L-", "L-", "H-", " V"],
                    ["1", "C", "X", "X", "X", "X", "0", "G", "1", "0", "H-", "L-", "L-", "H-", "L-", " V"],
                    ["1", "C", "X", "X", "X", "X", "0", "G", "1", "0", "L-", "L-", "L-", "L-", "H-", " V"],
                    ["0", "C", "X", "X", "X", "X", "0", "G", "1", "0", "H-", "L-", "L-", "H-", "H-", " V"],
                    ["0", "C", "X", "X", "X", "X", "0", "G", "1", "0", "H-", "L-", "L-", "L-", "H-", " V"],
                    ["0", "C", "X", "X", "X", "X", "0", "G", "1", "0", "L-", "H-", "H-", "H-", "H-", " V"],
                    ["0", "C", "X", "X", "X", "X", "0", "G", "1", "0", "L-", "H-", "H-", "L-", "H-", " V"],
                    ["0", "C", "X", "X", "X", "X", "0", "G", "1", "0", "L-", "H-", "L-", "H-", "H-", " V"],
                    ["0", "C", "X", "X", "X", "X", "0", "G", "1", "0", "L-", "H-", "L-", "L-", "H-", " V"],
                    ["0", "C", "X", "X", "X", "X", "0", "G", "1", "0", "L-", "L-", "H-", "H-", "H-", " V"],
                    ["0", "C", "X", "X", "X", "X", "0", "G", "1", "0", "L-", "L-", "H-", "L-", "H-", " V"],
                    ["0", "C", "X", "X", "X", "X", "0", "G", "1", "0", "L-", "L-", "L-", "H-", "H-", " V"],
                    ["0", "C", "X", "X", "X", "X", "0", "G", "1", "0", "L-", "L-", "L-", "L-", "L-", " V"],
                    ["0", "C", "1", "1", "1", "1", "1", "G", "0", "1", "H", "H", "H", "H", "H", "V"],
                    ["0", "C", "X", "X", "X", "X", "0", "G", "1", "0", "H-", "H-", "H-", "L-", "H-", " V"],
                    ["0", "C", "X", "X", "X", "X", "0", "G", "1", "0", "L-", "H-", "L-", "H-", "H-", " V"],
                    ["0", "C", "1", "0", "1", "1", "1", "G", "0", "1", "H", "H", "L-", "H", "H", "V"],
                    ["0", "C", "X", "X", "X", "X", "0", "G", "1", "0", "H-", "H-", "L-", "L-", "H-", " V"],
                    ["0", "C", "X", "X", "X", "X", "0", "G", "1", "0", "L-", "L-", "H-", "H-", "H-", " V"],
                    ["0", "C", "1", "1", "0", "1", "1", "G", "0", "1", "H", "L-", "H", "H", "H", "V"],
                    ["0", "C", "X", "X", "X", "X", "0", "G", "1", "0", "H-", "L-", "H-", "L-", "H-", " V"],
                    ["0", "C", "X", "X", "X", "X", "0", "G", "1", "0", "L-", "L-", "L-", "H-", "H-", " V"],
                    ["X", "C", "X", "X", "X", "X", "0", "G", "1", "1", "L-", "L-", "L-", "H-", "H-", " V"],
                    ["X", "C", "X", "X", "X", "X", "1", "G", "1", "0", "L-", "L-", "L-", "H", "H", "V"],
                    ["X", "C", "X", "X", "X", "X", "1", "G", "1", "1", "L-", "L-", "L-", "H", "H", "V"],
                ]
            )

        ))
}
