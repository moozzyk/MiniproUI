//
//  LogicICTestResultView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 3/15/25.
//

import SwiftUI

struct RowData: Identifiable {
    let id: Int
    let values: [String]
}

struct LogicICTestResultView: View {
    @Binding var logicICTestResult: LogicICTestResult?

    func getResultColor(_ result: String) -> Color {
        if result == "H" || result == "L" || result == "Z" {
            return .green
        }
        if result.last == "-" {
            return .red
        }
        return .primary
    }

    var body: some View {
        if let testResult = logicICTestResult {
            let rows = testResult.testVectors.enumerated().map { idx, value in RowData(id: idx, values: value) }
            let numColumns = testResult.testVectors.first?.count ?? 0
            Table(rows) {
                TableColumnForEach(0..<numColumns, id: \.self) { idx in
                    TableColumn(Text(String(format: "%2d", idx + 1))) { (row: RowData) in
                        Text(row.values[idx])
                            .frame(width: 20, alignment: .leading)
                            .padding(.leading, 5)
                            .foregroundColor(getResultColor(row.values[idx]))
                            .fontWeight(.bold)
                    }.width(ideal: 20, max: 20)
                }
            }
            .frame(maxWidth: CGFloat(rows[0].values.count * 38), maxHeight: CGFloat(28 + (rows.count) * 25))
            .padding(20)
            .tableStyle(.bordered)

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
