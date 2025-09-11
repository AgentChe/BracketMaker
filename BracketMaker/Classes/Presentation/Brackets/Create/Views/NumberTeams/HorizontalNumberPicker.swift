//
//  HorizontalNumberPicker.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 08.09.2025.
//

import UIKit

final class HorizontalNumberPicker: UIView {
    var onValueChanged: ((Int) -> Void)?
    
    private(set) lazy var selectedValue: Int = numbers.first ?? 1 {
        didSet { if selectedValue != oldValue { onValueChanged?(selectedValue) } }
    }

    private let itemWidth: CGFloat = 66.scale

    private lazy var numbers: [Int] = Array(3...32)
    
    private lazy var collectionView = makeCollectionView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let side = max(0, (bounds.width - itemWidth) / 2)
        
        if collectionView.contentInset.left != side {
            collectionView.contentInset = UIEdgeInsets(horizontal: side)
            collectionView.scrollIndicatorInsets = collectionView.contentInset
            
            scrollToValue(selectedValue, animated: false)
        }
        
        updateAesthetics()
    }
}

// MARK: Public
extension HorizontalNumberPicker {
    func selectValue(_ value: Int, animated: Bool) {
        guard numbers.contains(value) else { return }
        scrollToValue(value, animated: animated)
    }
}

// MARK: UICollectionViewDataSource & Delegate
extension HorizontalNumberPicker: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { numbers.count }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: HorizontalNumberPickerCell.self), for: indexPath) as! HorizontalNumberPickerCell
        cell.setup(text: String(numbers[indexPath.row]))
        cell.setup(isSelected: false)
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension HorizontalNumberPicker: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: itemWidth, height: bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let value = numbers[indexPath.item]
        selectValue(value, animated: true)
    }
}

// MARK: UIScrollViewDelegate
extension HorizontalNumberPicker: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateAesthetics()
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        guard let layout = collectionView.collectionViewLayout as? HorizontalNumberPickerCollectionLayout else { return }
        
        targetContentOffset.pointee = layout.targetContentOffset(
            forProposedContentOffset: targetContentOffset.pointee,
            withScrollingVelocity: velocity,
            in: collectionView
        )
    }
}

// MARK: Private
private extension HorizontalNumberPicker {
    func reloadAndCenter(value: Int) {
        collectionView.reloadData()
        layoutIfNeeded()
        scrollToValue(value, animated: false)
        updateAesthetics()
    }

    func scrollToValue(_ value: Int, animated: Bool) {
        guard let idx = numbers.firstIndex(of: value) else { return }
        
        let indexPath = IndexPath(item: idx, section: 0)
        
        collectionView.layoutIfNeeded()
        
        if let attrs = collectionView.layoutAttributesForItem(at: indexPath) {
            let targetX = attrs.center.x - collectionView.bounds.width / 2
            let clampedX = max(-collectionView.contentInset.left,
                               min(targetX, collectionView.contentSize.width - collectionView.bounds.width + collectionView.contentInset.right))
            collectionView.setContentOffset(CGPoint(x: clampedX, y: 0), animated: animated)
        } else {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
        }
    }
    
    func indexPathClosestToCenter() -> IndexPath? {
        let center = convert(centerPoint(), to: collectionView)
        let visible = collectionView.indexPathsForVisibleItems
        
        guard !visible.isEmpty else { return nil }
        
        return visible.min(by: { lhs, rhs in
            let l = collectionView.layoutAttributesForItem(at: lhs)?.center ?? .zero
            let r = collectionView.layoutAttributesForItem(at: rhs)?.center ?? .zero
            return abs(l.x - center.x) < abs(r.x - center.x)
        })
    }

    func centerPoint() -> CGPoint {
        CGPoint(x: bounds.midX, y: bounds.midY)
    }

    func updateAesthetics() {
        let centerX = convert(centerPoint(), to: collectionView).x
        let halfWidth = collectionView.bounds.width / 2
        
        for cell in collectionView.visibleCells {
            guard let numberCell = cell as? HorizontalNumberPickerCell else { continue }
            
            let dx = abs(cell.center.x - centerX)
            let t = min(dx / halfWidth, 1)
            let alpha = (1 - 0.9 * t)
            numberCell.setup(alpha: alpha)

            let isCenter = dx < (itemWidth / 2)
            numberCell.setup(isSelected: isCenter)
        }

        if let ip = indexPathClosestToCenter() {
            let newValue = numbers[ip.item]
            if newValue != selectedValue { selectedValue = newValue }
        }
    }
}

// MARK: Make constraints
private extension HorizontalNumberPicker {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 60.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension HorizontalNumberPicker {
    func makeCollectionView() -> UICollectionView {
        let layout = HorizontalNumberPickerCollectionLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8.scale
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: itemWidth, height: 60.scale)
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = UIColor.clear
        view.showsHorizontalScrollIndicator = false
        view.decelerationRate = .fast
        view.contentInsetAdjustmentBehavior = .never
        view.dataSource = self
        view.delegate = self
        view.register(HorizontalNumberPickerCell.self, forCellWithReuseIdentifier: String(describing: HorizontalNumberPickerCell.self))
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
