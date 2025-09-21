//
//  DoubleEliminationPDFGenerator.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 21.09.2025.
//

import UIKit
import CoreGraphics

final class DoubleEliminationPDFGenerator {
    struct Input {
        let title: String
        let subtitle: String
        let teams: [Team]
        let games: [DoubleEliminationGame]
        let gameResults: [DoubleEliminationGameResult]
        let tournamentResult: DoubleEliminationResult?

        // Геометрия
        var pageInsets: UIEdgeInsets = UIEdgeInsets(top: 48, left: 32, bottom: 48, right: 32)
        var interRoundSpacing: CGFloat = 24
        var dividerWidth: CGFloat = 1
        var winnerGap: CGFloat = 24
        var winnerLabelGap: CGFloat = 16
    }

    func makePDF(_ input: Input) -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).pdf")
        try? makePDFData(input).write(to: url, options: .atomic)
        return url
    }

    func makePDFData(_ input: Input) -> Data {
        // ----- Модель раундов -----
        let byGame = Dictionary(uniqueKeysWithValues: input.gameResults.map { ($0.gameId, $0) })
        let winners = input.games.filter { $0.bracket == .winner }
        let losers  = input.games.filter  { $0.bracket == .loser  }
        let wRounds = Self.buildRounds(from: winners, teams: input.teams, resByGame: byGame)
        let lRounds = Self.buildRounds(from: losers,  teams: input.teams, resByGame: byGame)

        let winnerTeam: DETeam? = input.tournamentResult.map {
            let id = $0.winner
            let name = input.teams.first(where: { $0.id == id })?.name ?? id
            return DETeam(teamId: id, teamName: name, isWinner: true, isBye: false)
        }

        // ----- Константы UI как на экране -----
        let gw = SERoundGamesView.Constants.gameWidth
        let gh = SERoundGamesView.Constants.gameHeight
        let inset = SERoundGamesView.Constants.inset
        let teamH: CGFloat = 56
        let scoreW: CGFloat = 28
        let cornerR: CGFloat = 19

        let winnersHeights = wRounds.map { CGFloat($0.games.count) * gh + CGFloat(max(0, $0.games.count - 1)) * inset }
        let losersHeights  = lRounds.map { CGFloat($0.games.count) * gh + CGFloat(max(0, $0.games.count - 1)) * inset }
        let winnersHeight = winnersHeights.max() ?? 0
        let losersHeight  = losersHeights.max()  ?? 0

        func totalWidth(_ rounds: [DERound]) -> CGFloat {
            guard !rounds.isEmpty else { return 0 }
            var w: CGFloat = 0
            for i in 0..<rounds.count {
                w += gw + input.interRoundSpacing + input.dividerWidth
                if i != rounds.count - 1 { w += input.interRoundSpacing }
            }
            return w
        }
        let usedWidthW = totalWidth(wRounds)
        let usedWidthL = totalWidth(lRounds)

        var contentWidth = max(usedWidthW, usedWidthL)
        var winnerPillWidth: CGFloat = 0
        if winnerTeam != nil {
            winnerPillWidth = gw
            contentWidth += input.winnerGap + winnerPillWidth + input.winnerLabelGap + 2 + 200 // линия + надпись
        }

        // ----- Шапка как в SingleEliminationPDFGenerator -----
        let titleH: CGFloat = 36
        let subtitleH: CGFloat = 22
        let headerGap: CGFloat = 8
        let headerBlockH = titleH + headerGap + subtitleH + 24

        // ----- Высота контента двух сеток -----
        // WinnersTitle(lineHeight) + 12 + winners + 40 + LosersTitle(lineHeight) + 12 + losers
        let winnersTitleFont = UIFont.systemFont(ofSize: 18, weight: .medium)
        let losersTitleFont  = winnersTitleFont
        let winnersTitleLH = winnersTitleFont.lineHeight
        let losersTitleLH  = losersTitleFont.lineHeight

        let bracketBlockH = winnersTitleLH + 12 + winnersHeight + 40 + losersTitleLH + 12 + losersHeight

        let pageSize = CGSize(
            width: input.pageInsets.left + contentWidth + input.pageInsets.right,
            height: input.pageInsets.top + headerBlockH + bracketBlockH + input.pageInsets.bottom
        )

        // ----- Рисование -----
        let fmt = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize), format: fmt)
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            let cg = ctx.cgContext

            // фон
            UIColor(integralRed: 215, green: 222, blue: 231).setFill()
            cg.fill(CGRect(origin: .zero, size: pageSize))

            // Шапка
            let titleStyle = Self.centerStyle(font: .systemFont(ofSize: 28, weight: .semibold), color: Appearance.mono100)
            let subtitleStyle = Self.centerStyle(font: .systemFont(ofSize: 16, weight: .regular), color: Appearance.mono100.withAlphaComponent(0.7))

            let titleRect = CGRect(x: 0, y: input.pageInsets.top, width: pageSize.width, height: titleH)
            (input.title as NSString).draw(in: titleRect, withAttributes: titleStyle)

            let subtitleRect = CGRect(x: 0, y: titleRect.maxY + headerGap, width: pageSize.width, height: subtitleH)
            (input.subtitle as NSString).draw(in: subtitleRect, withAttributes: subtitleStyle)

            // Область бранкетов
            let x = input.pageInsets.left
            var y = subtitleRect.maxY + 24

            // Winners Title
            let winnersTitleAttrs = Self.leftStyle(font: winnersTitleFont, color: Appearance.mono100)
            ("DoubleElimination.WinnersBracket".localized as NSString)
                .draw(in: CGRect(x: x, y: y, width: pageSize.width - x - input.pageInsets.right, height: winnersTitleLH),
                      withAttributes: winnersTitleAttrs)
            y += winnersTitleLH + 12
            let winnersContentTopY = y

            // Winners rounds
            let winnersStartY = y + (winnersHeight - (winnersHeights.first ?? winnersHeight)) / 2.0
            var wx = x
            for (ri, round) in wRounds.enumerated() {
                let rh = winnersHeights[ri]
                let startY = y + (winnersHeight - rh) / 2.0

                for (gi, game) in round.games.enumerated() {
                    let gTop = startY + CGFloat(gi) * (gh + inset)
                    let t1 = CGRect(x: wx, y: gTop, width: gw, height: teamH)
                    let t2 = CGRect(x: wx, y: gTop + gh - teamH, width: gw, height: teamH)
                    Self.drawTeamPill(in: t1, team: game.team1, scoreWidth: scoreW, corner: cornerR)
                    Self.drawTeamPill(in: t2, team: game.team2, scoreWidth: scoreW, corner: cornerR)
                }

                // divider
                let divX = wx + gw + input.interRoundSpacing
                Appearance.main100.withAlphaComponent(0.5).setFill()
                cg.fill(CGRect(x: divX, y: startY, width: input.dividerWidth, height: rh))

                wx = divX + input.dividerWidth + input.interRoundSpacing
            }

            // Losers Title
            y = y + winnersHeight + 40
            let losersTitleAttrs = Self.leftStyle(font: losersTitleFont, color: Appearance.mono100)
            ("DoubleElimination.LosersBracket".localized as NSString)
                .draw(in: CGRect(x: x, y: y, width: pageSize.width - x - input.pageInsets.right, height: losersTitleLH),
                      withAttributes: losersTitleAttrs)
            y += losersTitleLH + 12

            // Losers rounds
            var lx = x
            for (ri, round) in lRounds.enumerated() {
                let rh = losersHeights[ri]
                let startY = y + (losersHeight - rh) / 2.0

                for (gi, game) in round.games.enumerated() {
                    let gTop = startY + CGFloat(gi) * (gh + inset)
                    let t1 = CGRect(x: lx, y: gTop, width: gw, height: teamH)
                    let t2 = CGRect(x: lx, y: gTop + gh - teamH, width: gw, height: teamH)
                    Self.drawTeamPill(in: t1, team: game.team1, scoreWidth: scoreW, corner: cornerR)
                    Self.drawTeamPill(in: t2, team: game.team2, scoreWidth: scoreW, corner: cornerR)
                }

                let divX = lx + gw + input.interRoundSpacing
                Appearance.main100.withAlphaComponent(0.5).setFill()
                cg.fill(CGRect(x: divX, y: startY, width: input.dividerWidth, height: rh))

                lx = divX + input.dividerWidth + input.interRoundSpacing
            }

            // Winner зона
            if let winner = winnerTeam {
                let baseX = max(wx, lx) + input.winnerGap
                let winnersCenterY = winnersContentTopY + winnersHeight / 2.0
                let winRect = CGRect(
                    x: baseX,
                    y: winnersCenterY - teamH / 2.0,   // точный вертикальный центр
                    width: winnerPillWidth,
                    height: teamH
                )
                Self.drawTeamPill(in: winRect, team: winner, scoreWidth: scoreW, corner: cornerR)

                let lineX = winRect.maxX + input.winnerLabelGap
                Appearance.main100.withAlphaComponent(0.5).setFill() // тот же цвет, что у других
                cg.fill(CGRect(x: lineX, y: winRect.minY, width: input.dividerWidth, height: winRect.height))

                let wFont = UIFont.systemFont(ofSize: 16, weight: .regular)
                let wAttrs = Self.leftStyle(font: wFont, color: Appearance.mono100)
                let wH = wFont.lineHeight
                let wRect = CGRect(x: lineX + 8, y: winRect.midY - wH / 2, width: 200, height: wH)
                ("SingleElimination.Winner".localized as NSString).draw(in: wRect, withAttributes: wAttrs)
            }
        }
        return data
    }

    // MARK: - Styles

    private static func centerStyle(font: UIFont, color: UIColor) -> [NSAttributedString.Key: Any] {
        let p = NSMutableParagraphStyle(); p.alignment = .center; p.minimumLineHeight = font.lineHeight; p.maximumLineHeight = font.lineHeight
        return [.font: font, .foregroundColor: color, .paragraphStyle: p]
    }
    private static func leftStyle(font: UIFont, color: UIColor) -> [NSAttributedString.Key: Any] {
        let p = NSMutableParagraphStyle(); p.alignment = .left; p.minimumLineHeight = font.lineHeight; p.maximumLineHeight = font.lineHeight
        return [.font: font, .foregroundColor: color, .paragraphStyle: p]
    }

    // MARK: - Mapping

    private struct DETeam { let teamId: String; let teamName: String; let isWinner: Bool?; let isBye: Bool }
    private struct DEGame { let gameId: String; let team1: DETeam?; let team2: DETeam? }
    private struct DERound { let games: [DEGame]; let round: Int }

    private static func buildRounds(from games: [DoubleEliminationGame], teams: [Team], resByGame: [String: DoubleEliminationGameResult]) -> [DERound] {
        guard !games.isEmpty else { return [] }
        let grouped = Dictionary(grouping: games, by: { $0.round })
        return grouped.keys.sorted().map { r in
            let roundGames = (grouped[r] ?? []).sorted { $0.sort < $1.sort }
            return DERound(games: roundGames.map { mapGame($0, teams: teams, resByGame: resByGame) }, round: r)
        }
    }

    private static func mapGame(_ g: DoubleEliminationGame, teams: [Team], resByGame: [String: DoubleEliminationGameResult]) -> DEGame {
        let cur = resByGame[g.id]
        return DEGame(
            gameId: g.id,
            team1: mapSlot(g.slot1, teams: teams, resByGame: resByGame, current: cur),
            team2: mapSlot(g.slot2, teams: teams, resByGame: resByGame, current: cur)
        )
    }

    private static func mapSlot(_ slot: DoubleEliminationGame.DoubleEliminationSlot, teams: [Team], resByGame: [String: DoubleEliminationGameResult], current: DoubleEliminationGameResult?) -> DETeam? {
        switch slot {
        case .team(let id):
            let name = teams.first(where: { $0.id == id })?.name ?? id
            return DETeam(teamId: id, teamName: name, isWinner: inferIsWinner(current: current, candidate: id), isBye: false)
        case .winnerOf(let gid):
            guard let r = resByGame[gid] else { return nil }
            let id = r.winnerTeamId
            let name = teams.first(where: { $0.id == id })?.name ?? id
            return DETeam(teamId: id, teamName: name, isWinner: inferIsWinner(current: current, candidate: id), isBye: false)
        case .loserOf(let gid):
            guard let r = resByGame[gid], let id = r.loserTeamId else { return nil }
            let name = teams.first(where: { $0.id == id })?.name ?? id
            return DETeam(teamId: id, teamName: name, isWinner: inferIsWinner(current: current, candidate: id), isBye: false)
        case .bye:
            return DETeam(teamId: "bye", teamName: "SingleElimination.Bye".localized, isWinner: nil, isBye: true)
        }
    }

    private static func inferIsWinner(current: DoubleEliminationGameResult?, candidate: String) -> Bool? {
        guard let cur = current else { return nil }
        if cur.winnerTeamId == candidate { return true }
        if cur.loserTeamId == candidate { return false }
        return nil
    }

    // MARK: - Drawing pill (совпадает с логикой UI)

    private static func drawTeamPill(in rect: CGRect, team: DETeam?, scoreWidth: CGFloat, corner: CGFloat) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        // Общий клип, чтобы правый скруглённый край у полосы совпадал с левым. :contentReference[oaicite:5]{index=5}
        let clip = UIBezierPath(roundedRect: rect, cornerRadius: corner)
        ctx.saveGState()
        clip.addClip()

        // Если явный проигрыш — вся пилюля под 0.5, как в SETeamView.alpha. :contentReference[oaicite:6]{index=6}
        if team?.isWinner == false { ctx.setAlpha(0.5) }

        // фон
        Appearance.mono200.setFill()
        UIBezierPath(rect: rect).fill()

        // score- полоса рисуется ВСЕГДА, даже если team == nil
        let stripeRect = CGRect(x: rect.maxX - scoreWidth, y: rect.minY, width: scoreWidth, height: rect.height)
        let isWinner = team?.isWinner ?? false
        (isWinner ? Appearance.main200 : Appearance.main600).setFill()
        UIBezierPath(rect: stripeRect).fill()

        ctx.restoreGState()

        // Текст
        let name: String = {
            guard let t = team else { return "" }
            return t.isBye ? "bye" : t.teamName
        }()

        let font = UIFont.systemFont(ofSize: 16, weight: .regular)
        let p = NSMutableParagraphStyle(); p.alignment = .center; p.lineBreakMode = .byTruncatingTail
        let textColor: UIColor = (team?.isWinner == false) ? Appearance.mono100.withAlphaComponent(0.5) : Appearance.mono100

        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: textColor, .paragraphStyle: p]
        let textRect = rect.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 41))
        let drawRect = CGRect(x: textRect.minX, y: textRect.midY - font.lineHeight / 2, width: textRect.width, height: font.lineHeight)
        (name as NSString).draw(with: drawRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attrs, context: nil)
    }
}
