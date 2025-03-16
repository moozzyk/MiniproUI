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
            ScrollView([.horizontal, .vertical]){
                VStack {
                    Grid {
                        GridRow {
                            Text("")
                            ForEach(0..<testResult.testVectors[0].count, id: \.self) { idx in
                                Text("\(idx + 1)")
                            }
                        }
                        ForEach(0..<testResult.testVectors.count, id: \.self) { idx in
                            Divider()
                            GridRow {
                                Text("\(idx + 1)")
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
        }
    }
}

#Preview {
    LogicICTestResultView(
        logicICTestResult: .constant(
            LogicICTestResult(
                device: "7414",
                numErrors: 10,
                testVectors: [
                    ["0", "H-", "0", "H-", "0", "H", "G", "H", "0", "H-", "0", "H-", "0", "V"],
                    ["1", "L-", "1", "L-", "1", "L-", "G", "L-", "1", "L-", "1", "L-", "1", "V"],
                ]
            )

        ))
}
