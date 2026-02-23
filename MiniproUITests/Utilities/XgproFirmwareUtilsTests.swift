//
//  XgproFirmwareUtilsTests.swift
//  MiniproUITests
//

import Testing

@testable import Visual_Minipro

struct XgproFirmwareUtilsTests {
    @Test func getSoftwareNameReturnsExpectedValueForKnownFirmware() {
        #expect(
            XgproFirmwareUtils.getSoftwareName(programmerType: "T76", firmwareVersion: 0x10f)
                == "xgpro_T76_V1311.rar")
        #expect(
            XgproFirmwareUtils.getSoftwareName(programmerType: "t56", firmwareVersion: 0x149)
                == "xgproV1310_T48_T56_T866II_Setup.rar")
        #expect(
            XgproFirmwareUtils.getSoftwareName(programmerType: "T76", firmwareVersion: 0x9999)
                == nil)
    }
}
