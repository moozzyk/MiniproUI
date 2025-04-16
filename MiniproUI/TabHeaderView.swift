//
//  TabHeaderView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 4/15/25.
//

import SwiftUI

struct TabHeaderView: View {
    let caption: String
    let secondaryCaption: String?
    let systemImageName: String

    init(caption: String, secondaryCaption: String? = nil, systemImageName: String) {
        self.caption = caption
        self.secondaryCaption = secondaryCaption
        self.systemImageName = systemImageName
    }

    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: systemImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .padding(.trailing, 8)

            VStack(alignment: .leading, spacing: 4) {
                Text(caption)
                    .font(.title)
                    .fontWeight(.semibold)
                if let secondaryCaption = secondaryCaption {
                    Text(secondaryCaption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding([.top, .horizontal])
        Divider()
    }
}

#Preview {
    TabHeaderView(caption: "Caption", secondaryCaption: "secondary caption", systemImageName: "flask.fill")
}
