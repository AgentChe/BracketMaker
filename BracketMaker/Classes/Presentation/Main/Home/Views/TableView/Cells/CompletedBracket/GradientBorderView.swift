//
//  GradientBorderView.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 18.09.2025.
//

import UIKit

final class GradientBorderView: UIView {
    private lazy var gradient = CAGradientLayer()
    private lazy var strokeMask = CAShapeLayer()
    private lazy var fillView = UIView()

    private lazy var corner: CGFloat = 24.scale
    private lazy var lineWidth: CGFloat = 4.scale

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isOpaque = false

        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.colors = Appearance.main800.map { $0.cgColor }
        gradient.contentsScale = UIScreen.main.scale
        layer.addSublayer(gradient)

        strokeMask.fillColor = UIColor.clear.cgColor
        strokeMask.strokeColor = UIColor.black.cgColor
        strokeMask.lineWidth = lineWidth
        strokeMask.lineJoin = .round
        strokeMask.lineCap = .round
        strokeMask.contentsScale = UIScreen.main.scale
        gradient.mask = strokeMask

        fillView.backgroundColor = .white
        fillView.isUserInteractionEnabled = false
        addSubview(fillView)

        layer.cornerRadius = corner
        layer.cornerCurve = .continuous
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradient.frame = bounds

        let inset = lineWidth / 2
        let rect = bounds.insetBy(dx: inset, dy: inset)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: max(0, corner - inset))
        strokeMask.path = path.cgPath

        fillView.frame = bounds.insetBy(dx: lineWidth, dy: lineWidth)
        fillView.layer.cornerRadius = max(0, corner - lineWidth)
        fillView.layer.cornerCurve = .continuous
    }
}
