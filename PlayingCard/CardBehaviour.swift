//
//  CardBehaviour.swift
//  PlayingCard
//
//  Created by YesVladess on 12.11.2019.
//  Copyright © 2019 YesVladess. All rights reserved.
//

import UIKit

class CardBehavior: UIDynamicBehavior {
    
    /// Create a new CardBehavior for a PlayingCard
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
    }
    
    /// Create a new CardBehavior for a PlayingCard in the given animator
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
    
    /// Collision behavior
    private lazy var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    
    /// Item behavioor
    lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = false
        behavior.elasticity = 1.0
        behavior.resistance = 0
        return behavior
    }()
    
    /// Make sure the given item is affected by all types of CardBehavior
    func addItem(_ item: UIDynamicItem) {
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        push(item)
    }
    
    /// Remove the give item from all types of CardBehavior
    func removeItem(_ item: UIDynamicItem) {
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
    }
    
    /// Intantly push the item towards the center of the current bounds
    private func push(_ item: UIDynamicItem) {
        
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        
        // Push item towards the center
        if let referenceBounds = dynamicAnimator?.referenceView?.bounds {
            let center = CGPoint(x: referenceBounds.midX, y: referenceBounds.midY)
            switch (item.center.x, item.center.y) {
            case let (x, y) where x < center.x && y < center.y:
                push.angle = (CGFloat.pi/2).randomNumber
            case let (x, y) where x > center.x && y < center.y:
                push.angle = CGFloat.pi-(CGFloat.pi/2).randomNumber
            case let (x, y) where x < center.x && y > center.y:
                push.angle = (-CGFloat.pi/2).randomNumber
            case let (x, y) where x > center.x && y > center.y:
                push.angle = CGFloat.pi+(CGFloat.pi/2).randomNumber
            default:
                push.angle = (CGFloat.pi*2).randomNumber
            }
        }
        
        push.magnitude = CGFloat(1) + CGFloat(2).randomNumber
        
        // After item is pushed, we no longer need it
        push.action = { [unowned push, weak self] in
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
    }
}
