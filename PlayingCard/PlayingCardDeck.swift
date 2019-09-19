//
//  PlayingCardDeck.swift
//  PlayingCard
//
//  Created by YesVladess on 23.08.2019.
//  Copyright © 2019 YesVladess. All rights reserved.
//

import Foundation

struct PlayingCardDeck {
    
    private(set) var cards = [PlayingCard]()
    
    init() {
        for suit in PlayingCard.Suit.all {
            for rank in PlayingCard.Rank.all {
                cards.append(PlayingCard(suit: suit, rank: rank))
            }
        }
    }
    
    mutating func draw() -> PlayingCard? {
        if cards.count > 0 {
            return cards.remove(at: cards.count.randomNumber)
        } else {
            return nil
        }
    }
}

extension Int {
    var randomNumber: Int {
        if self > 0 {
            return Int.random(in: 0..<self)
        }
        else if self < 0 {
            return -Int.random(in: 0..<abs(self))
        }
        else  {
            return 0
        }
    }
}

