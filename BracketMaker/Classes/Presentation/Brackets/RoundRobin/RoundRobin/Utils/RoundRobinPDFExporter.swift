//
//  RoundRobinPDFExporter.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 18.09.2025.
//

import UIKit

struct RoundRobinPDFRenderer {
    enum Constants {
        static let pageSideInset: CGFloat = 0
        static let blockInset: CGFloat = 16
        static let sideInset: CGFloat  = 16
        static let ptsRowHeight: CGFloat = 36
        static let ptsBottomInset: CGFloat = 24
        static let cardHeight: CGFloat = 56
        static let rowTopPadding: CGFloat = 8
        static let rowBottomPadding: CGFloat = 8
        static let gameRowHeight: CGFloat = rowTopPadding + cardHeight + rowBottomPadding
        static let teamCardCorner: CGFloat = 19
        static let scoreWidth: CGFloat = 28
        static let vsGap: CGFloat = 16
    }
    
    private let roundRobinName: String
    private let elements: [RoundRobinTableElement]
    
    init(roundRobinName: String, elements: [RoundRobinTableElement]) {
        self.roundRobinName = roundRobinName
        self.elements = elements
    }
}

// MARK: Public
extension RoundRobinPDFRenderer {
    func makePDF() -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(roundRobinName).pdf")
        try? makePDFData().write(to: url, options: .atomic)
        return url
    }
}

// MARK: Private
private extension RoundRobinPDFRenderer {
    func makePDFData() -> Data {
        let width: CGFloat = 595
        let pageSize = CGSize(width: width, height: contentHeight(width: width))
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        return renderer.pdfData { ctx in
            ctx.beginPage()
            drawBackgroundFill(in: ctx.cgContext, rect: CGRect(origin: .zero, size: pageSize))
            var y = drawHeader(contentWidth: width)
            y += 24

            var sawPTS = false
            var addedPtsBottomInset = false

            for element in elements {
                switch element {
                case .ptsHeader:
                    y = drawPtsHeader(atY: y, contentWidth: width)
                    sawPTS = true
                case .ptsTeam(let row):
                    y = drawPtsRow(row, atY: y, contentWidth: width)
                    sawPTS = true
                case .game(let game):
                    if sawPTS && !addedPtsBottomInset {
                        y += Constants.ptsBottomInset
                        addedPtsBottomInset = true
                    }
                    y = drawGameRow(game, atY: y, contentWidth: width)
                }
            }
        }
    }
    
    func drawBackgroundFill(in ctx: CGContext, rect: CGRect) {
        UIColor(integralRed: 215, green: 222, blue: 231).setFill()
        ctx.fill(rect)
    }

    @discardableResult
    func drawHeader(contentWidth: CGFloat) -> CGFloat {
        var y: CGFloat = 24
        let textWidth = contentWidth - (2 * Constants.blockInset)

        let titleAttr = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.bold(size: 36))
            .lineHeight(44)
            .textAlignment(.center)
            .lineBreakMode(.byWordWrapping)

        let subtitleAttr = TextAttributes()
            .textColor(Appearance.mono100.withAlphaComponent(0.7))
            .font(Fonts.Inter.semiBold(size: 18))
            .lineHeight(24)
            .textAlignment(.center)
            .lineBreakMode(.byWordWrapping)

        y += draw(
            string: roundRobinName.attributed(with: titleAttr),
            in: CGRect(x: Constants.blockInset, y: y, width: textWidth, height: .greatestFiniteMagnitude),
            keepWidth: true
        ).height

        y += 4

        y += draw(
            string: "RoundRobin.PDF.SubTitle".localized.attributed(with: subtitleAttr),
            in: CGRect(x: Constants.blockInset, y: y, width: textWidth, height: .greatestFiniteMagnitude),
            keepWidth: true
        ).height

        return y
    }
    
    struct PtsColumns {
        let xW, xWDColon, xD, xDLColon, xL, xF, xA, xPts: CGFloat
        let teamTextRect: CGRect
    }

    func makePtsColumns(container: CGRect) -> PtsColumns {
        let trailing = container.maxX - 16
        let step: CGFloat = 44

        let xPts = trailing
        let xA   = xPts - step
        let xF   = xA   - step
        let xL   = xF   - step
        let xD   = xL   - step
        let xW   = xD   - step

        let xWDColon = xW + (xD - xW)/2
        let xDLColon = xD + (xL - xD)/2

        let teamRect = CGRect(x: container.minX + 12,
                              y: container.minY + (container.height - 24)/2,
                              width: (xW - 12) - (container.minX + 12),
                              height: 24)
        return .init(xW: xW, xWDColon: xWDColon, xD: xD, xDLColon: xDLColon, xL: xL, xF: xF, xA: xA, xPts: xPts, teamTextRect: teamRect)
    }

    @discardableResult
    func drawPtsHeader(atY y0: CGFloat, contentWidth: CGFloat) -> CGFloat {
        let container = CGRect(x: Constants.pageSideInset + Constants.blockInset,
                               y: y0,
                               width: contentWidth - 2*(Constants.pageSideInset + Constants.blockInset),
                               height: Constants.ptsRowHeight)

        let path = UIBezierPath(roundedRect: container,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: 8, height: 8))
        Appearance.main100.setFill()
        path.fill()

        let labelAttr = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.regular(size: 16))
            .lineHeight(24)
            .textAlignment(.center)

        let titleAttr = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.regular(size: 16))
            .lineHeight(24)
            .textAlignment(.left)

        let cols = makePtsColumns(container: container)

        draw(string: "RoundRobin.Pts.Title".localized.attributed(with: titleAttr),
             in: cols.teamTextRect)

        center("W", atX: cols.xW, midY: container.midY, attrs: labelAttr)
        center(":", atX: cols.xWDColon, midY: container.midY, attrs: labelAttr)
        center("D", atX: cols.xD, midY: container.midY, attrs: labelAttr)
        center(":", atX: cols.xDLColon, midY: container.midY, attrs: labelAttr)
        center("L", atX: cols.xL, midY: container.midY, attrs: labelAttr)
        center("F", atX: cols.xF, midY: container.midY, attrs: labelAttr)
        center("A", atX: cols.xA, midY: container.midY, attrs: labelAttr)
        center("Pts", atX: cols.xPts, midY: container.midY, attrs: labelAttr)

        return y0 + Constants.ptsRowHeight
    }

    @discardableResult
    func drawPtsRow(_ row: RoundRobinTablePtsTeamElement, atY y0: CGFloat, contentWidth: CGFloat) -> CGFloat {
        let container = CGRect(x: Constants.pageSideInset + Constants.blockInset,
                               y: y0,
                               width: contentWidth - 2*(Constants.pageSideInset + Constants.blockInset),
                               height: Constants.ptsRowHeight)

        let bg = (row.style == .white) ? Appearance.main600 : Appearance.main700
        bg.setFill()
        UIBezierPath(rect: container).fill()

        let nameAttr = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.regular(size: 16))
            .lineHeight(24)
            .textAlignment(.left)
            .lineBreakMode(.byTruncatingTail)

        let valAttr = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.regular(size: 16))
            .lineHeight(24)
            .textAlignment(.center)

        let cols = makePtsColumns(container: container)

        draw(string: row.team.name.attributed(with: nameAttr), in: cols.teamTextRect)

        func txt(_ v: Int?) -> String { v.map(String.init) ?? "-" }
        center(txt(row.w),   atX: cols.xW,  midY: container.midY, attrs: valAttr)
        center(":",          atX: cols.xWDColon, midY: container.midY, attrs: valAttr)
        center(txt(row.d),   atX: cols.xD,  midY: container.midY, attrs: valAttr)
        center(":",          atX: cols.xDLColon, midY: container.midY, attrs: valAttr)
        center(txt(row.l),   atX: cols.xL,  midY: container.midY, attrs: valAttr)
        center(txt(row.f),   atX: cols.xF,  midY: container.midY, attrs: valAttr)
        center(txt(row.a),   atX: cols.xA,  midY: container.midY, attrs: valAttr)
        center(txt(row.pts), atX: cols.xPts,midY: container.midY, attrs: valAttr)

        return y0 + Constants.ptsRowHeight
    }

    @discardableResult
    func drawGameRow(_ e: RoundRobinTableGameElement, atY y0: CGFloat, contentWidth: CGFloat) -> CGFloat {
        let top = y0 + Constants.rowTopPadding

        let vsAttr = TextAttributes()
            .textColor(Appearance.mono100.withAlphaComponent(0.5))
            .font(Fonts.Inter.semiBold(size: 14))
            .lineHeight(21)
        let vsStr = "RoundRobin.VS".localized.attributed(with: vsAttr)
        let vsSize = vsStr.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 21),
                                        options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).size
        let vsRect = CGRect(x: (contentWidth - vsSize.width)/2,
                            y: top + (Constants.cardHeight - vsSize.height)/2,
                            width: vsSize.width, height: vsSize.height)
        vsStr.draw(in: vsRect)

        let leftFrame  = CGRect(x: Constants.sideInset, y: top,
                                width: max(0, vsRect.minX - Constants.vsGap - Constants.sideInset), height: Constants.cardHeight)
        let rightFrame = CGRect(x: vsRect.maxX + Constants.vsGap, y: top,
                                width: max(0, contentWidth - Constants.sideInset - (vsRect.maxX + Constants.vsGap)), height: Constants.cardHeight)

        drawTeamCard(team: e.team1, frame: leftFrame,  alignment: .left)
        drawTeamCard(team: e.team2, frame: rightFrame, alignment: .right)

        return y0 + Constants.gameRowHeight
    }

    enum Align { case left, right }

    func drawTeamCard(team: RoundRobinTeamView.Team, frame: CGRect, alignment: Align) {
        let cardPath = UIBezierPath(roundedRect: frame, cornerRadius: Constants.teamCardCorner)
        Appearance.mono200.setFill()
        cardPath.fill()

        let scoreRect: CGRect = (alignment == .left)
        ? CGRect(x: frame.maxX - Constants.scoreWidth, y: frame.minY, width: Constants.scoreWidth, height: frame.height)
        : CGRect(x: frame.minX, y: frame.minY, width: Constants.scoreWidth, height: frame.height)

        let ctx = UIGraphicsGetCurrentContext()
        ctx?.saveGState()
        cardPath.addClip()

        switch team.state {
        case .winner: Appearance.main200.setFill()
        case .loser, .none: Appearance.main600.setFill()
        case .draw: Appearance.main500.setFill()
        }
        UIBezierPath(rect: scoreRect).fill()
        ctx?.restoreGState()

        let baseAttr = TextAttributes().textColor(Appearance.mono100).font(Fonts.Inter.regular(size: 16)).lineHeight(24).textAlignment(.center)
        let winAttr  = TextAttributes().textColor(Appearance.mono200).font(Fonts.Inter.regular(size: 16)).lineHeight(24).textAlignment(.center)
        let scoreStr: NSAttributedString = {
            switch team.state {
            case .winner(let g): return String(g).attributed(with: winAttr)
            case .loser(let g), .draw(let g): return String(g).attributed(with: baseAttr)
            case .none: return "+".attributed(with: baseAttr)
            }
        }()
        let size = scoreStr.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude),
                                         options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).size
        let centered = CGRect(x: scoreRect.midX - size.width/2,
                              y: scoreRect.midY - size.height/2,
                              width: size.width, height: size.height)
        scoreStr.draw(in: centered)

        let nameAttr = TextAttributes().textColor(Appearance.mono100).font(Fonts.Inter.regular(size: 16)).lineHeight(24).textAlignment(.center).lineBreakMode(.byTruncatingTail)
        let nameInsets = UIEdgeInsets(top: 0, left: alignment == .left ? 16 : (Constants.scoreWidth + 13),
                                      bottom: 0, right: alignment == .left ? (Constants.scoreWidth + 13) : 16)
        let nameRect = frame.inset(by: UIEdgeInsets(top: (frame.height - 24)/2,
                                                    left: nameInsets.left, bottom: (frame.height - 24)/2,
                                                    right: nameInsets.right))
        draw(string: team.name.attributed(with: nameAttr), in: nameRect)
    }
    
    @discardableResult
    func draw(string: NSAttributedString, in rect: CGRect, keepWidth: Bool = false) -> CGRect {
        let size = string.boundingRect(
            with: CGSize(width: rect.width, height: rect.height),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).integral.size

        let drawRect = CGRect(
            x: rect.minX,
            y: rect.minY,
            width: keepWidth ? rect.width : min(size.width, rect.width),
            height: size.height
        )
        string.draw(in: drawRect)
        return drawRect
    }

    func center(_ text: String, atX x: CGFloat, midY: CGFloat, attrs: TextAttributes) {
        let s = text.attributed(with: attrs)
        let size = s.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 24),
                                  options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).size
        s.draw(in: CGRect(x: x - size.width/2, y: midY - size.height/2, width: size.width, height: size.height))
    }

    func contentHeight(width: CGFloat) -> CGFloat {
        var h: CGFloat = 0
        let tAttr = TextAttributes().font(Fonts.Inter.bold(size: 36)).lineHeight(44).textAlignment(.center).lineBreakMode(.byWordWrapping)
        let sAttr = TextAttributes().font(Fonts.Inter.semiBold(size: 18)).lineHeight(24).textAlignment(.center).lineBreakMode(.byWordWrapping)

        let textWidth = width - 2*Constants.blockInset
        h += 24
        h += roundRobinName.attributed(with: tAttr).boundingRect(
                with: CGSize(width: textWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height
        h += 4
        h += "RoundRobin.PDF.SubTitle".localized.attributed(with: sAttr).boundingRect(
                with: CGSize(width: textWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height
        h += 24
        
        var sawPTS = false
        var addedPtsBottomInset = false
        
        for e in elements {
            switch e {
            case .ptsHeader:
                h += Constants.ptsRowHeight
                sawPTS = true
            case .ptsTeam:
                h += Constants.ptsRowHeight
                sawPTS = true
            case .game:
                if sawPTS && !addedPtsBottomInset {
                    h += Constants.ptsBottomInset
                    addedPtsBottomInset = true
                }
                h += Constants.gameRowHeight
            }
        }
        
        return ceil(h)
    }
}
