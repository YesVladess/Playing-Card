//
//  PlayingCard.swift
//  PlayingCard
//
//  Created by YesVladess on 23.08.2019.
//  Copyright © 2019 YesVladess. All rights reserved.
//

import Foundation


struct PlayingCard : CustomStringConvertible {
    
    var description: String {return "\(rank)\(suit)"}
    
    var suit : Suit
    var rank : Rank
    
    
    // Raw value usage example
    enum Suit : String, CustomStringConvertible {
        
        var description: String {return rawValue}
        
        case clubs = "♣️"
        case diamonds = "♦️"
        case spades = "♠️"
        case hearts = "♥️"
        
        static var all = [ Suit.clubs, .diamonds, .hearts, .spades]
    }
    
    enum Rank : CustomStringConvertible {
        
        case ace
        case face(String)
        case numeric(Int)
        
        var order : Int {
            switch self {
            case .ace:
                return 1
            case .numeric(let pips) :
                return pips
            case .face(let kind)
                where kind == "J" :
                return 11
            case .face(let kind)
                where kind == "Q" :
                return 12
            case .face(let kind)
                where kind == "K" :
                return 13
            default:
                return 0
            }
        }
        
        static var all : [Rank] {
            var allRanks = [Rank.ace]
            for pips in 2...10 {
                allRanks.append(Rank.numeric(pips))
            }
            allRanks += [Rank.face("J"), .face("Q"), .face("K")]
            
            return allRanks
        }
        
        var description: String {
            switch self {
            case .ace: return "A"
            case .numeric(let pips): return String(pips)
            case .face(let kind): return kind
            }
            
        }
    }
}
