//
//  ViewController.swift
//  PlayingCard
//
//  Created by YesVladess on 23.08.2019.
//  Copyright © 2019 YesVladess. All rights reserved.
//

import UIKit

/// Main view controller
class ViewController: UIViewController {
    
    /// The deck of cards (model)
    private var deck = PlayingCardDeck()
    
    /// The playing cards views (view)
    @IBOutlet private var cardViews: [PlayingCardView]!
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
    lazy var cardBehaviour = CardBehavior(in: animator)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var cards = [PlayingCard]()
        for _ in 1...((cardViews.count+1)/2) {
            let card = deck.draw()!
            cards += [card, card]
        }
        for cardView in cardViews {
            cardView.isFaceUp = false
            let card = cards.remove(at: cards.count.randomNumber)
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
            cardBehaviour.addItem(cardView)
        }
    }
    
    private var faceUpCardViews: [PlayingCardView] {
        return cardViews.filter { $0.isFaceUp &&
            !$0.isHidden &&
            $0.transform != CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0) &&
            $0.alpha == 1
        }
    }
    
    private var faceUpCardViewsMatch: Bool {
        return faceUpCardViews.count == 2 &&
            faceUpCardViews[0].rank == faceUpCardViews[1].rank &&
            faceUpCardViews[0].suit == faceUpCardViews[1].suit
    }
    
    var lastChosenCardView: PlayingCardView?
    
    @objc private func flipCard(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let chosenCardView = recognizer.view as? PlayingCardView, faceUpCardViews.count < 2 {
                lastChosenCardView = chosenCardView
                cardBehaviour.removeItem(chosenCardView)
                UIView.transition(
                    with: chosenCardView,
                    duration: 0.6,
                    options: [.transitionFlipFromRight],
                    animations: {
                        chosenCardView.isFaceUp = !chosenCardView.isFaceUp
                },
                    completion: { finished in
                        let cardsToAnimate = self.faceUpCardViews
                        if self.faceUpCardViewsMatch {
                            UIViewPropertyAnimator.runningPropertyAnimator(
                                withDuration: 0.6,
                                delay: 0,
                                options: [],
                                animations: {
                                    cardsToAnimate.forEach {
                                        $0.transform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)
                                    }
                            }, completion: { (position) in
                                UIViewPropertyAnimator.runningPropertyAnimator(
                                    withDuration: 0.75,
                                    delay: 0,
                                    options: [],
                                    animations: {
                                        cardsToAnimate.forEach {
                                            $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                                            $0.alpha = 0
                                        }
                                }, completion: { (position) in
                                    cardsToAnimate.forEach {
                                        $0.transform = .identity
                                        $0.alpha = 1
                                        $0.isHidden = true
                                    }
                                }
                                )
                            }
                            )
                        } else if cardsToAnimate.count == 2 {
                            if chosenCardView == self.lastChosenCardView {
                                cardsToAnimate.forEach { cardView in
                                    UIView.transition(
                                        with: cardView,
                                        duration: 0.6,
                                        options: [.transitionFlipFromLeft],
                                        animations: {
                                            cardView.isFaceUp = false
                                    },
                                        completion: { finished in
                                            self.cardBehaviour.addItem(chosenCardView)
                                    }
                                    )
                                }
                            }
                        } else {
                            if !chosenCardView.isFaceUp {
                                self.cardBehaviour.addItem(chosenCardView)
                            }
                        }
                }
                )
            }
        default:
            break
        }
    }
}

extension CGFloat {
    var randomNumber: CGFloat {
        if self > 0 {
            return CGFloat.random(in: 0..<self)
        }
        else if self < 0 {
            return -CGFloat.random(in: 0..<abs(self))
        }
        else  {
            return 0
        }
    }
}

