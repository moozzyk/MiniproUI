//
//  InfoICUtils.swift
//  MiniproUI
//

import Foundation

class InfoICUtils {
    static func resolveInfoICPath(for programmerModel: ProgrammerModel) -> URL {
        let name = UserDefaults.standard.useLegacyInfoIC && programmerModel != .t76
            ? "infoic_0.7.4"
            : "infoic"
        return Bundle.main.url(forResource: name, withExtension: "xml")!
    }
}
