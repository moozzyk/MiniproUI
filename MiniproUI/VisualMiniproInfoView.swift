//
//  VisualMiniproInfoView.swift
//  Visual Minipro
//
//  Created by Pawel Kadluczka on 8/30/25.
//

import SwiftUI

struct VisualMiniproInfoView: View {
    @Binding var visualMiniproInfo: VisualMiniproInfo?

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                TabHeaderView(
                    caption: "About Visual Minipro ",
                    secondaryCaption: "Version: \(visualMiniproInfo?.version ?? "")",
                    systemImageName: "macwindow.and.cursorarrow")
                Form {
                    Section(
                        header: HStack {
                            Image("VisualMiniproIconImage")
                            Text("About Visual Minipro")
                        }
                    ) {
                        Section {
                            PropertyRow(label: "Version", value: visualMiniproInfo?.version ?? "Unknown")
                            ForEach(visualMiniproInfo?.visualMiniproDetails ?? [], id: \.self) {
                                PropertyRow(label: $0.key, value: $0.value)
                            }
                        }
                    }
                    Section(
                        header: HStack {
                            Text("Support")
                        }
                    ) {
                        Section {
                            Text("To report issues or request new features, please open an issue on [GitHub](https://github.com/moozzyk/MiniproUI/issues/new).")
                        }
                    }
                }
                .formStyle(.grouped)
            }
        }
        .frame(minWidth: 400, minHeight: 500)
        .task {
            visualMiniproInfo = try? await MiniproAPI.getVisualMiniproInfo()
        }
    }
}

#Preview {
    VisualMiniproInfoView(visualMiniproInfo: .constant(nil))
}

