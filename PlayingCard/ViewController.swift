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
        }
    }
    
    @objc private func flipCard(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let chosenCardView = recognizer.view as? PlayingCardView {
                chosenCardView.isFaceUp = !chosenCardView.isFaceUp
            }
        default:
            break
        }
    }
}

