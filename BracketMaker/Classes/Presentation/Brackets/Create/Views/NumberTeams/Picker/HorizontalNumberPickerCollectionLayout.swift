//
//  HorizontalNumberPickerCollectionLayout.swift
//  BracketMaker
//
//  Created by Андрей Чернышев on 08.09.2025.
//

import UIKit

final class HorizontalNumberPickerCollectionLayout: UICollectionViewFlowLayout {
    func targetContentOffset(
        forProposedContentOffset proposed: CGPoint,
        withScrollingVelocity velocity: CGPoint,
        in collectionView: UICollectionView) -> CGPoint
    {
        let cvBounds = collectionView.bounds
        let halfWidth = cvBounds.size.width / 2
        let proposedCenterX = proposed.x + halfWidth

        let inRect = CGRect(
            origin: CGPoint(x: proposed.x, y: 0),
            size: cvBounds.size
        )
        
        guard let attrs = layoutAttributesForElements(in: inRect), !attrs.isEmpty else { return proposed }

        let closest = attrs.min { abs($0.center.x - proposedCenterX) < abs($1.center.x - proposedCenterX) }
        guard let closest else { return proposed }
        
        var targetX = closest.center.x - halfWidth
        
        targetX = max(-collectionView.contentInset.left,
                      min(targetX,
                          collectionView.contentSize.width - cvBounds.size.width + collectionView.contentInset.right))
        return CGPoint(x: targetX, y: proposed.y)
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let cv = collectionView else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity) }
        return targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity, in: cv)
    }
}
