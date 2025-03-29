//
//  ChipProgrammingView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 3/27/25.
//

import SwiftUI

struct ChipProgrammingView: View {
    @Binding var supportedDevices: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center) {
                Image(systemName: "flask.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .padding(.trailing, 8)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Chip " +  "None")
                        .font(.title)
                        .fontWeight(.semibold)
                }
            }
            .padding([.top, .horizontal])
            HStack {
                Spacer()
                BinaryDataView(data: Data("This is an example text".utf8))
                    .frame(width: 600)
                Spacer()
            }
            Divider()
            Spacer()
        }
    }
}

#Preview {
    ChipProgrammingView(supportedDevices: .constant(["7400", "7404", "PIC16LF505"]))
}
