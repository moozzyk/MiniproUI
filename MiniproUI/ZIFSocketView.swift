//
//  ZifSocketView.swift
//  MiniproUI
//
//  Created by Pawel Kadluczka on 9/24/26.
//

import SwiftUI

/// Socket/chip rendering traits derived from the physical programmer model.
extension ProgrammerModel {
    /// Number of ZIF contacts per side (T48/TL866 = ZIF40, T76/T56 = ZIF48).
    var slotsPerSide: Int {
        switch self {
        case .t48, .tl866A, .tl866CS, .tl866IIPlus: return 20
        case .t76, .t56: return 24
        }
    }

    /// true: chip is pushed to the end of the socket away from the lever.
    /// false: chip sits at the lever end.
    var chipAtFarEnd: Bool {
        switch self {
        case .t48, .t76, .t56: return true
        case .tl866A, .tl866CS, .tl866IIPlus: return false
        }
    }

    /// true: the chip's notch points toward the lever; false: away from it.
    var notchTowardLever: Bool {
        switch self {
        case .t48: return false
        case .t76, .t56, .tl866A, .tl866CS, .tl866IIPlus: return true
        }
    }

    /// Chip-insertion diagram printed on the device.
    fileprivate var guide: InsertGuide {
        switch self {
        case .t48, .tl866A, .tl866CS, .tl866IIPlus: return .simple
        case .t76, .t56: return .split
        }
    }

    /// Draw the insertion diagram rotated 180° (TL866 uses the T48 diagram upside down).
    fileprivate var guideUpsideDown: Bool {
        switch self {
        case .tl866A, .tl866CS, .tl866IIPlus: return true
        case .t48, .t76, .t56: return false
        }
    }
}

fileprivate enum InsertGuide { case simple, split }

/// Socket measurements. Everything else about the socket is derived from these.
fileprivate enum SocketMetrics {
    static let pitch: CGFloat = 10            // distance between contact rows
    static let centerX: CGFloat = 91.5        // vertical axis of the socket
    static let bodyTop: CGFloat = 74
    static let bodyWidth: CGFloat = 110
    static let bodyStroke: CGFloat = 4
    static let rowMargin: CGFloat = 22.5      // body edge → center of first/last row

    static let slotLength: CGFloat = 32
    static let slotHeight: CGFloat = 4
    static let slotGap: CGFloat = 14          // centerX → inner end of a slot
    static let slotStroke: CGFloat = 1

    static let channelWidth: CGFloat = 9
    static let channelInset: CGFloat = 2      // gap between body edge and channel ends
    static let holeRadius: CGFloat = 4.5
    static let holeFromBottom: CGFloat = 42.5 // body bottom → release-hole center

    static let tabHeight: CGFloat = 16
    static let topTabWidth: CGFloat = 31
    static let bottomTabWidth: CGFloat = 36
    static let tabGap: CGFloat = 10.5         // centerX → inner edge of a tab

    static let leverInset: CGFloat = 6        // body left edge → lever axis
    static let leverRing = CGSize(width: 10, height: 13)
    static let leverStroke: CGFloat = 3.5
    static let leverStemWidth: CGFloat = 4
    static let leverStemLength: CGFloat = 17

    // Empty space around the socket inside its bounding box
    static let sidePadding: CGFloat = 7
    static let topPadding: CGFloat = 36       // above body top (lever lives here)
    static let bottomPadding: CGFloat = 20    // below body bottom (bottom tabs live here)
}

/// DIP chip measurements.
fileprivate enum ChipMetrics {
    static let wideWidth: CGFloat = 40        // 600 mil package
    static let narrowWidth: CGFloat = 24      // 300 mil package
    static let overhang: CGFloat = 2.5        // body extends this far past the first/last pin center
    static let pinLength: CGFloat = 7
    static let pinHeight: CGFloat = 3
    static let edgeStroke: CGFloat = 2
    static let notchRadius: CGFloat = 5
    static let notchStroke: CGFloat = 1.5
    static let dotRatio: CGFloat = 0.1        // pin-1 dot radius as a fraction of chip width

    static let idMaxFontWide: CGFloat = 11
    static let idMaxFontNarrow: CGFloat = 9
    static let idMinFont: CGFloat = 5
    static let idCharWidth: CGFloat = 0.62    // approx. monospaced glyph width / font size
    static let idReserved: CGFloat = 20       // chip length kept free for notch + dot
    static let idShift: CGFloat = 5           // move text away from the notch end
}

/// Insertion-guide measurements. Guide shapes are positioned relative to their outlines.
fileprivate enum GuideMetrics {
    static let frame = CGRect(x: 20, y: 20, width: 60, height: 260)   // area both guides occupy
    static let inset: CGFloat = 5             // outer outline → inner rim
    static let outerStroke: CGFloat = 3
    static let innerStroke: CGFloat = 1.2
    static let dotRadius: CGFloat = 5
    static let icFontSize: CGFloat = 20

    static let gap: CGFloat = 12              // socket → guide
    static let heightRatio: CGFloat = 0.33    // guide height relative to socket height
}

/// Draws a ZIF programmer socket with a DIP chip inserted as the device requires,
/// plus the device's chip-insertion diagram to the right of the socket.
/// All drawing uses fixed "design units"; the view scales them uniformly to its size.
struct ZIFSocketView: View {
    var device: ProgrammerModel
    var pins: Int                 // even number, 4 ... 2 * slotsPerSide
    var chipID: String? = nil

    private var wide: Bool { pins > 24 }   // true = 600 mil DIP, false = 300 mil DIP

    @Environment(\.colorScheme) private var colorScheme

    // Palette (light-mode value, dark-mode value)
    private var bg: Color        { adaptive(240, 70) }
    private var bodyColor: Color { adaptive(120, 165) }
    private var slot: Color      { adaptive(80, 140) }
    private var channel: Color   { adaptive(200, 100) }
    private var hole: Color      { adaptive(210, 130) }
    private var chipFill: Color  { adaptive(110, 60) }
    private var chipEdge: Color  { adaptive(150, 110) }
    private var chipDot: Color   { adaptive(190, 150) }
    private var chipText: Color  { Color(white: 0.92) }
    private var guideText: Color { adaptive(80, 170) }

    private func adaptive(_ light: Double, _ dark: Double) -> Color {
        Color(white: (colorScheme == .dark ? dark : light) / 255)
    }

    private var bodyHeight: CGFloat { 2 * SocketMetrics.rowMargin + CGFloat(device.slotsPerSide - 1) * SocketMetrics.pitch }
    private var bodyLeft: CGFloat { SocketMetrics.centerX - SocketMetrics.bodyWidth / 2 }
    private var bodyBottom: CGFloat { SocketMetrics.bodyTop + bodyHeight }
    private var bodyRect: CGRect { CGRect(x: bodyLeft, y: SocketMetrics.bodyTop, width: SocketMetrics.bodyWidth, height: bodyHeight) }

    /// Vertical center of contact row `k` (0 = lever end).
    private func rowY(_ k: Int) -> CGFloat { SocketMetrics.bodyTop + SocketMetrics.rowMargin + CGFloat(k) * SocketMetrics.pitch }

    /// Socket area: lever, tabs and body.
    private var socketBox: CGRect {
        CGRect(x: bodyLeft - SocketMetrics.sidePadding, y: SocketMetrics.bodyTop - SocketMetrics.topPadding,
               width: SocketMetrics.bodyWidth + 2 * SocketMetrics.sidePadding,
               height: SocketMetrics.topPadding + bodyHeight + SocketMetrics.bottomPadding)
    }

    private var guideHeight: CGFloat { socketBox.height * GuideMetrics.heightRatio }
    private var guideScale: CGFloat { guideHeight / GuideMetrics.frame.height }
    private var guideOrigin: CGPoint {
        CGPoint(x: socketBox.maxX + GuideMetrics.gap,
                y: bodyRect.midY - guideHeight / 2)          // vertically centered on the socket body
    }

    private var viewBox: CGRect {
        CGRect(x: socketBox.minX, y: socketBox.minY,
               width: socketBox.width + GuideMetrics.gap + GuideMetrics.frame.width * guideScale,
               height: socketBox.height)
    }

    var body: some View {
        Canvas { ctx, size in
            // Fit the viewBox into the view, keep aspect ratio, center it.
            let vb = viewBox
            let s = min(size.width / vb.width, size.height / vb.height)
            ctx.translateBy(x: (size.width  - vb.width  * s) / 2,
                            y: (size.height - vb.height * s) / 2)
            ctx.scaleBy(x: s, y: s)
            ctx.translateBy(x: -vb.minX, y: -vb.minY)

            drawSocket(ctx)
            drawChip(ctx)

            // Guide diagram: its own coordinate space, scaled down next to the socket.
            var g = ctx
            g.translateBy(x: guideOrigin.x, y: guideOrigin.y)
            g.scaleBy(x: guideScale, y: guideScale)
            g.translateBy(x: -GuideMetrics.frame.minX, y: -GuideMetrics.frame.minY)
            if device.guideUpsideDown {
                rotate180(&g, around: CGPoint(x: GuideMetrics.frame.midX, y: GuideMetrics.frame.midY))
            }
            switch device.guide {
            case .split: drawSplitGuide(g)
            case .simple: drawSimpleGuide(g)
            }
        }
        .aspectRatio(viewBox.size, contentMode: .fit)
    }

    private func drawSocket(_ ctx: GraphicsContext) {
        // Lever (ring + stem above the body's top-left corner)
        let leverX = bodyLeft + SocketMetrics.leverInset
        let stemTop = SocketMetrics.bodyTop - SocketMetrics.leverStemLength
        let ringCenter = CGPoint(x: leverX, y: stemTop - SocketMetrics.leverRing.height / 2)
        ctx.stroke(Path(ellipseIn: CGRect(x: ringCenter.x - SocketMetrics.leverRing.width / 2,
                                          y: ringCenter.y - SocketMetrics.leverRing.height / 2,
                                          width: SocketMetrics.leverRing.width, height: SocketMetrics.leverRing.height)),
                   with: .color(bodyColor), lineWidth: SocketMetrics.leverStroke)
        ctx.fill(rect(leverX - SocketMetrics.leverStemWidth / 2, stemTop, SocketMetrics.leverStemWidth, SocketMetrics.leverStemLength),
                 with: .color(bodyColor))

        // Tabs (mirrored around the center line)
        for (width, y) in [(SocketMetrics.topTabWidth, SocketMetrics.bodyTop - SocketMetrics.tabHeight), (SocketMetrics.bottomTabWidth, bodyBottom)] {
            ctx.fill(rect(SocketMetrics.centerX - SocketMetrics.tabGap - width, y, width, SocketMetrics.tabHeight), with: .color(bodyColor))
            ctx.fill(rect(SocketMetrics.centerX + SocketMetrics.tabGap, y, width, SocketMetrics.tabHeight), with: .color(bodyColor))
        }

        // Body
        let outline = Path(bodyRect)
        ctx.fill(outline, with: .color(bg))
        ctx.stroke(outline, with: .color(bodyColor), lineWidth: SocketMetrics.bodyStroke)

        // Center channel + release hole
        let ch = rect(SocketMetrics.centerX - SocketMetrics.channelWidth / 2, SocketMetrics.bodyTop + SocketMetrics.channelInset,
                      SocketMetrics.channelWidth, bodyHeight - 2 * SocketMetrics.channelInset)
        ctx.fill(ch, with: .color(channel))
        ctx.stroke(ch, with: .color(bodyColor), lineWidth: SocketMetrics.slotStroke)
        let holePath = circle(SocketMetrics.centerX, bodyBottom - SocketMetrics.holeFromBottom, SocketMetrics.holeRadius)
        ctx.fill(holePath, with: .color(hole))
        ctx.stroke(holePath, with: .color(bodyColor), lineWidth: SocketMetrics.slotStroke)

        // Contact slots
        for k in 0..<device.slotsPerSide {
            let y = rowY(k) - SocketMetrics.slotHeight / 2
            for x in [SocketMetrics.centerX - SocketMetrics.slotGap - SocketMetrics.slotLength, SocketMetrics.centerX + SocketMetrics.slotGap] {
                let r = rect(x, y, SocketMetrics.slotLength, SocketMetrics.slotHeight)
                ctx.fill(r, with: .color(bg))
                ctx.stroke(r, with: .color(slot), lineWidth: SocketMetrics.slotStroke)
            }
        }
    }

    private func drawChip(_ ctx: GraphicsContext) {
        let rows = min(max(pins, 4), device.slotsPerSide * 2) / 2
        let firstRow = device.chipAtFarEnd ? device.slotsPerSide - rows : 0

        // Chip body spans its pin rows plus a small overhang at both ends.
        let chipW = wide ? ChipMetrics.wideWidth : ChipMetrics.narrowWidth
        let chipTop = rowY(firstRow) - ChipMetrics.overhang
        let chipH = CGFloat(rows - 1) * SocketMetrics.pitch + 2 * ChipMetrics.overhang
        let chipRect = CGRect(x: SocketMetrics.centerX - chipW / 2, y: chipTop, width: chipW, height: chipH)

        // The code below draws the chip with its notch toward the lever; rotate 180° around
        // the chip's center if the notch must point away. The chip is symmetric, so pins stay on their slots.
        var ctx = ctx
        if !device.notchTowardLever {
            rotate180(&ctx, around: CGPoint(x: chipRect.midX, y: chipRect.midY))
        }

        // Pins
        for k in firstRow..<(firstRow + rows) {
            let y = rowY(k) - ChipMetrics.pinHeight / 2
            ctx.fill(rect(chipRect.minX - ChipMetrics.pinLength, y, ChipMetrics.pinLength, ChipMetrics.pinHeight), with: .color(bodyColor))
            ctx.fill(rect(chipRect.maxX, y, ChipMetrics.pinLength, ChipMetrics.pinHeight), with: .color(bodyColor))
        }

        // Body
        let chip = Path(chipRect)
        ctx.fill(chip, with: .color(chipFill))
        ctx.stroke(chip, with: .color(chipEdge), lineWidth: ChipMetrics.edgeStroke)

        // Notch: semicircular cut-out in the middle of the top edge (the channel shows through)
        let notchCenter = CGPoint(x: chipRect.midX, y: chipTop)
        let r = ChipMetrics.notchRadius
        var notchArc = Path()
        notchArc.move(to: CGPoint(x: notchCenter.x - r, y: chipTop))
        notchArc.addRelativeArc(center: notchCenter, radius: r,
                                startAngle: .degrees(180), delta: .degrees(-180))   // dips down into the chip
        var notchFill = notchArc
        let aboveEdge = chipTop - ChipMetrics.edgeStroke / 2   // also cover the top border
        notchFill.addLine(to: CGPoint(x: notchCenter.x + r, y: aboveEdge))
        notchFill.addLine(to: CGPoint(x: notchCenter.x - r, y: aboveEdge))
        notchFill.closeSubpath()
        ctx.fill(notchFill, with: .color(channel))
        ctx.stroke(notchArc, with: .color(chipEdge), lineWidth: ChipMetrics.notchStroke)

        // Pin-1 dot, sized and placed relative to the chip width
        let dotR = chipW * ChipMetrics.dotRatio
        ctx.fill(circle(chipRect.minX + 2 * dotR, chipTop + 2.5 * dotR, dotR), with: .color(chipDot))

        // Chip ID, rotated 90° clockwise (reads correctly when the notch is on the left)
        if let id = chipID, !id.isEmpty {
            let maxSize = wide ? ChipMetrics.idMaxFontWide : ChipMetrics.idMaxFontNarrow
            let fitted = (chipH - ChipMetrics.idReserved) / (CGFloat(id.count) * ChipMetrics.idCharWidth)
            let fontSize = max(ChipMetrics.idMinFont, min(maxSize, fitted))

            var c = ctx                                     // copy so the rotation stays local
            c.translateBy(x: chipRect.midX, y: chipRect.midY + ChipMetrics.idShift)
            c.rotate(by: .degrees(90))
            c.draw(Text(id)
                    .font(.system(size: fontSize, weight: .semibold, design: .monospaced))
                    .foregroundColor(chipText),
                   at: .zero, anchor: .center)
        }
    }

    /// Split guide (T76/T56): long chip notch-up, with a marked section for a shorter chip at the bottom.
    private func drawSplitGuide(_ ctx: GraphicsContext) {
        let outer = GuideMetrics.frame
        let inner = outer.insetBy(dx: GuideMetrics.inset, dy: GuideMetrics.inset)
        let notchR: CGFloat = 7
        stroke(ctx, notchedRect(outer, corner: 6, topNotch: notchR), GuideMetrics.outerStroke)
        stroke(ctx, notchedRect(inner, corner: 4, topNotch: 10), GuideMetrics.innerStroke)

        // Divider marking where the shorter chip starts (55% down the outline)
        let dividerY = outer.minY + outer.height * 0.55
        var divider = Path()
        divider.move(to: CGPoint(x: inner.minX, y: dividerY))
        divider.addLine(to: CGPoint(x: outer.midX - notchR, y: dividerY))
        divider.addRelativeArc(center: CGPoint(x: outer.midX, y: dividerY), radius: notchR,
                               startAngle: .degrees(180), delta: .degrees(-180))
        divider.addLine(to: CGPoint(x: inner.maxX, y: dividerY))
        stroke(ctx, divider, 2)

        // Pin-1 dots for the long chip and for the short chip
        let dotX = outer.minX + 15
        ctx.fill(circle(dotX, outer.minY + 25, GuideMetrics.dotRadius), with: .color(bodyColor))
        ctx.fill(circle(dotX, dividerY + 27, GuideMetrics.dotRadius), with: .color(bodyColor))
        drawIC(ctx, at: CGPoint(x: outer.midX, y: outer.minY + 85))
    }

    /// Simple guide (T48; TL866 upside down): chip rotated 180° — notch at the bottom, arrow pointing to it.
    private func drawSimpleGuide(_ ctx: GraphicsContext) {
        let outer = CGRect(x: GuideMetrics.frame.minX, y: GuideMetrics.frame.minY, width: GuideMetrics.frame.width, height: 250)
        let inner = outer.insetBy(dx: GuideMetrics.inset, dy: GuideMetrics.inset)
        stroke(ctx, notchedRect(outer, bottomNotch: 10.5), GuideMetrics.outerStroke)
        stroke(ctx, notchedRect(inner, bottomNotch: 15), GuideMetrics.innerStroke)

        // Solid down arrow: shaft + triangular head
        let cx = outer.midX
        let top = outer.minY + 136
        let shaftHalf: CGFloat = 6, shaftLength: CGFloat = 19
        let headHalf: CGFloat = 16, headLength: CGFloat = 19
        let headY = top + shaftLength
        var arrow = Path()
        arrow.addLines([CGPoint(x: cx - shaftHalf, y: top), CGPoint(x: cx + shaftHalf, y: top),
                        CGPoint(x: cx + shaftHalf, y: headY), CGPoint(x: cx + headHalf, y: headY),
                        CGPoint(x: cx, y: headY + headLength),
                        CGPoint(x: cx - headHalf, y: headY), CGPoint(x: cx - shaftHalf, y: headY)])
        arrow.closeSubpath()
        ctx.fill(arrow, with: .color(bodyColor))
        stroke(ctx, arrow, 1.5)

        // Pin-1 dot near the notch end
        ctx.fill(circle(outer.maxX - 15, outer.maxY - 30, GuideMetrics.dotRadius), with: .color(bodyColor))
        drawIC(ctx, at: CGPoint(x: outer.midX, y: outer.minY + 65))
    }

    private func drawIC(_ ctx: GraphicsContext, at p: CGPoint) {
        var c = ctx
        c.translateBy(x: p.x, y: p.y)
        c.rotate(by: .degrees(-90))
        c.draw(Text("IC").font(.system(size: GuideMetrics.icFontSize, weight: .bold)).foregroundColor(guideText),
               at: .zero, anchor: .center)
    }

    /// Rectangle with optional rounded corners and a semicircular notch
    /// cut into the middle of the top and/or bottom edge.
    private func notchedRect(_ rect: CGRect, corner r: CGFloat = 0,
                             topNotch nt: CGFloat = 0, bottomNotch nb: CGFloat = 0) -> Path {
        let cx = rect.midX
        let tl = CGPoint(x: rect.minX, y: rect.minY), tr = CGPoint(x: rect.maxX, y: rect.minY)
        let br = CGPoint(x: rect.maxX, y: rect.maxY), bl = CGPoint(x: rect.minX, y: rect.maxY)

        var p = Path()
        p.move(to: CGPoint(x: rect.minX + r, y: rect.minY))

        // Top edge (left → right); the notch dips down into the shape
        if nt > 0 {
            p.addLine(to: CGPoint(x: cx - nt, y: rect.minY))
            p.addRelativeArc(center: CGPoint(x: cx, y: rect.minY), radius: nt,
                             startAngle: .degrees(180), delta: .degrees(-180))
        }
        addCorner(&p, tr, towards: br, r)

        // Right edge, then bottom edge (right → left); the notch bulges up into the shape
        addCorner(&p, br, towards: bl, r)
        if nb > 0 {
            p.addLine(to: CGPoint(x: cx + nb, y: rect.maxY))
            p.addRelativeArc(center: CGPoint(x: cx, y: rect.maxY), radius: nb,
                             startAngle: .degrees(0), delta: .degrees(-180))
        }

        // Left edge back to the start
        addCorner(&p, bl, towards: tl, r)
        addCorner(&p, tl, towards: tr, r)
        p.closeSubpath()
        return p
    }

    /// Adds a (rounded, if r > 0) corner at `c`, continuing toward `next`.
    private func addCorner(_ p: inout Path, _ c: CGPoint, towards next: CGPoint, _ r: CGFloat) {
        if r > 0 {
            p.addArc(tangent1End: c, tangent2End: next, radius: r)
        } else {
            p.addLine(to: c)
        }
    }

    private func rotate180(_ ctx: inout GraphicsContext, around c: CGPoint) {
        ctx.translateBy(x: c.x, y: c.y)
        ctx.rotate(by: .degrees(180))
        ctx.translateBy(x: -c.x, y: -c.y)
    }

    private func stroke(_ ctx: GraphicsContext, _ path: Path, _ width: CGFloat) {
        ctx.stroke(path, with: .color(bodyColor), style: StrokeStyle(lineWidth: width, lineJoin: .round))
    }

    private func rect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> Path {
        Path(CGRect(x: x, y: y, width: w, height: h))
    }

    private func circle(_ x: CGFloat, _ y: CGFloat, _ r: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2))
    }
}

#Preview {
    HStack(spacing: 32) {
        ZIFSocketView(device: .t48, pins: 28, chipID: "27C256")
        ZIFSocketView(device: .t76, pins: 32, chipID: "AM29F040")
        ZIFSocketView(device: .tl866IIPlus, pins: 8, chipID: "24C02")
    }
    .frame(height: 400)
    .padding()
}
