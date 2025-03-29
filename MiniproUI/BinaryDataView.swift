//
//  BinaryDataView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 3/27/25.
//

import SwiftUI

struct BinaryDataView: View {
    @Binding var data: Data?
    let bytesPerLine: Int = 16

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(alignment: .leading, spacing: 2) {
                if let data = data {
                    ForEach(0..<numberOfLines(for: data), id: \.self) { line in
                        let startIndex = line * bytesPerLine
                        let endIndex = min(startIndex + bytesPerLine, data.count)
                        let lineData = data.subdata(in: startIndex..<endIndex)

                        HStack(spacing: 8) {
                            Text(String(format: "0x%08X", startIndex))
                                .font(.system(.body, design: .monospaced))
                                .frame(width: 88, alignment: .leading)

                            Text(hexString(for: lineData))
                                .font(.system(.body, design: .monospaced))

                            Text(asciiString(for: lineData))
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                }
            }
            .padding()
        }
        .border(Color.gray)
    }

    func numberOfLines(for data: Data) -> Int {
        return (data.count + bytesPerLine - 1) / bytesPerLine
    }

    func hexString(for lineData: Data) -> String {
        var hexStr = ""
        for byte in lineData {
            hexStr += String(format: "%02X ", byte)
        }
        if lineData.count < bytesPerLine {
            let missing = bytesPerLine - lineData.count
            hexStr += String(repeating: "   ", count: missing)
        }
        return hexStr
    }

    func asciiString(for lineData: Data) -> String {
        var asciiStr = ""
        for byte in lineData {
            let c = (byte >= 32 && byte < 127) ? Character(UnicodeScalar(byte)) : "."
            asciiStr.append(c)
        }
        return asciiStr
    }
}

struct BinaryDataView_Previews: PreviewProvider {
    static var previews: some View {
        BinaryDataView(data: .constant("Hello, world! This is a test.".data(using: .utf8)!))
    }
}
