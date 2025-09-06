//
//  SupportedDevicesProcessor.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 2/9/25.
//

import Foundation

struct SupportedDevices {
    var logicICs: [String]
    var eepromICs: [String]
}

class SupportedDevicesProcessor {
    private static let logicICs: Set<String> = {
        let infoicPath = Bundle.main.url(forResource: "logicic", withExtension: "xml")
        return getICNames(from: infoicPath!)
    }()

    private static let eepromICs: Set<String> = {
        let infoicPath = Bundle.main.url(forResource: "infoic", withExtension: "xml")
        return getICNames(from: infoicPath!)
    }()

    private static func getICNames(from path: URL) -> Set<String> {
        var icNames = Set<String>()
        let xmlDoc = try? XMLDocument(contentsOf: path)
        if let nodes = try? xmlDoc?.nodes(forXPath: "//ic") as? [XMLElement] {
            for n in nodes {
                let nameList = n.attribute(forName: "name")?.stringValue ?? ""
                for name in nameList.split(separator: ",") {
                    // XML handles entities like &#9; correctly but minipro returns devices like this "MT28FW512ABA1HPN-0AAT&#9;(RB158)@BGA64"
                    icNames.insert(
                        name.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(
                            of: "\t", with: "&#9;"))
                    // Custom chips have "(custom)" appended to their names:
                    // https://gitlab.com/DavidGriffith/minipro/-/blob/master/src/database.c#L516
                    icNames.insert(name.trimmingCharacters(in: .whitespacesAndNewlines) + "(custom)")
                }
            }
        }
        return icNames
    }

    public static func run(_ result: InvocationResult) throws -> SupportedDevices {
        try ensureNoError(invocationResult: result)

        let lines = result.stdOutString.components(separatedBy: .newlines)
        return SupportedDevices(
            logicICs: getLogicICs(lines),
            eepromICs: getEepromICs(lines))
    }

    private static func getLogicICs(_ lines: [String]) -> [String] {
        var seen: Set<String> = []
        return
            lines
            .filter { seen.insert($0).inserted }
            .filter { logicICs.contains($0) || !eepromICs.contains($0) }
    }

    private static func getEepromICs(_ lines: [String]) -> [String] {
        var seen: Set<String> = []
        return
            lines
            .filter { seen.insert($0).inserted }
            .filter { eepromICs.contains($0) || !logicICs.contains($0) }
    }
}
