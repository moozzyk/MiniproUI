//
//  ProgrammerModel.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 3/3/26.
//

import Foundation

enum ProgrammerModel: String, Equatable {
    case tl866A = "TL866A"
    case tl866CS = "TL866CS"
    case tl866IIPlus = "TL866II+"
    case t48 = "T48"
    case t56 = "T56"
    case t76 = "T76"

    var isAlgoBased: Bool {
        self == .t56 || self == .t76
    }

    var supportsFirmwareUpdate: Bool {
        self == .tl866IIPlus || self == .t48 || self == .t56 || self == .t76
    }

    static func parse(_ value: String) throws -> ProgrammerModel {
        switch value.uppercased() {
        case "TL866A":
            .tl866A
        case "TL866CS":
            .tl866CS
        case "TL866II+":
            .tl866IIPlus
        case "T48":
            .t48
        case "T56":
            .t56
        case "T76":
            .t76
        default:
            throw MiniproAPIError.programmerInfoUnavailable
        }
    }
}
