//
//  PlayingCardView.swift
//  PlayingCard
//
//  Created by YesVladess on 17.09.2019.
//  Copyright © 2019 YesVladess. All rights reserved.
//

import UIKit

@IBDesignable
class PlayingCardView: UIView {

    @IBInspectable
    var rank : Int = 7 { didSet { setNeedsLayout(); setNeedsDisplay() }}
    @IBInspectable
    var suit : String = "♠️" { didSet { setNeedsLayout(); setNeedsDisplay() }}
    @IBInspectable
    var isFaceUp : Bool = true { didSet { setNeedsLayout(); setNeedsDisplay() }}
    
    var faceCardScale : CGFloat = SizeRatio.faceCardImageSizeToBoundsSize { didSet { setNeedsDisplay() }}
    
    @objc func adjustFaceCardScale(byHandlingGestureRecognizerBy recognizeer : UIPinchGestureRecognizer) {
        switch recognizeer.state {
        case .changed, .ended:
            faceCardScale *= recognizeer.scale
            recognizeer.scale = 1.0
        default:
            break
        }
    }
    
    private func centeredAttributedString( _ string: String, fontSize: CGFloat) -> NSAttributedString {
        
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: string, attributes: [.paragraphStyle: paragraphStyle, .font: font])
    }
    
    private var cornerString : NSAttributedString {
        return centeredAttributedString(rankString+"\n"+suit, fontSize: cornerFontSize)
    }
    
    /// The label for the upper-left corner of the card
    private lazy var upperLeftCornerLabel = createCornerLabel()
    
    /// The label for the bottom-right corner of the card
    private lazy var lowerRightCornerLabel = createCornerLabel()
    
    /// The origin point for the upper-left corner label
    private var upperLeftCornerLabelOrigin: CGPoint {
        return bounds.origin.offsetBy(dx: cornerOffset, dy: cornerOffset)
    }
    
    /// The origin point for the lower-right corner label
    private var lowerRightCornerLabelOrigin: CGPoint {
        return CGPoint(x: bounds.maxX, y: bounds.maxY)
            .offsetBy(dx: -cornerOffset, dy: -cornerOffset)
            .offsetBy(dx: -lowerRightCornerLabel.frame.width, dy: -lowerRightCornerLabel.frame.height)
    }
    
    /// When bounds change, we want to keep everything positioned correctly
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Configure corner labels
        configureCornerLabel(upperLeftCornerLabel)
        configureCornerLabel(lowerRightCornerLabel)
        
        // Position corner labels accordingly (using computed vars instead of calculating it here)
        upperLeftCornerLabel.frame.origin = upperLeftCornerLabelOrigin
        lowerRightCornerLabel.frame.origin = lowerRightCornerLabelOrigin
        
        // NOTE: On the lecture, the professor does the transformation first and then sets the label's origin.
        // Because of this, the transformation needs both "translation" and "rotation". We can also set the origin
        // first and then applying a "rotation" only, which I'm doing here.
        
        // We need to rotate the lower-right label
        lowerRightCornerLabel.transform = CGAffineTransform.identity.rotated(by: CGFloat.pi)
        
    }
    
    /// Creates the corner label
    private func createCornerLabel() -> UILabel {
        
        let label = UILabel()
        // Zero means "no-limit"
        label.numberOfLines = 0
        addSubview(label)
        return label
    }
    
    /// Configure the corner labels text, size, etc.
    private func configureCornerLabel(_ label: UILabel) {
        // Set the attributed text
        label.attributedText = cornerString
        
        // Set the label's size to fit the content
        label.frame.size = CGSize.zero // reset it's size first
        label.sizeToFit()
        
        // Only show the label when the card is facing-up
        label.isHidden = !isFaceUp
    }
    
    override func draw(_ rect: CGRect) {
// Drawing with Core Graphics
//        if let context = UIGraphicsGetCurrentContext() {
//            context.addArc(center: CGPoint(x: bounds.midX, y: bounds.midY),
//            radius: 100.0, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: false)
//            context.setLineWidth(5.0)
//            UIColor.green.setStroke()
//            UIColor.blue.setFill()
//            context.strokePath()
//            // it's not filling
//            context.fillPath()
//        }
// Drawing with UIBezierPath
//        let path = UIBezierPath()
//        path.addArc(withCenter: CGPoint(x: bounds.midX, y: bounds.midY),
//                    radius: 100.0, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: false)
//        path.lineWidth = 5.0
//        UIColor.green.setStroke()
//        UIColor.blue.setFill()
//        path.stroke()
//        path.fill()
        
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        roundedRect.addClip()
        UIColor.white.setFill()
        roundedRect.fill()
        if isFaceUp{
        if let faceCardImage = UIImage(named: rankString + suit, in: Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
            faceCardImage.draw(in: bounds.zoom(by: faceCardScale))
        } else {
            drawPips()
        }
        } else {
            if let cardBackImage = UIImage(named: "cardback", in: Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
                cardBackImage.draw(in: bounds)
            }
        }
    }
    
    /// Draw pips based on rank and suit
    private func drawPips()
    {
        let pipsPerRowForRank = [[0], [1], [1,1], [1,1,1], [2,2], [2,1,2], [2,2,2], [2,1,2,2], [2,2,2,2], [2,2,1,2,2], [2,2,2,2,2]]
        
        func createPipString(thatFits pipRect: CGRect) -> NSAttributedString {
            let maxVerticalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.count, $0)})
            let maxHorizontalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.max() ?? 0, $0)})
            let verticalPipRowSpacing = pipRect.size.height / maxVerticalPipCount
            let attemptedPipString = centeredAttributedString(suit, fontSize: verticalPipRowSpacing)
            let probablyOkayPipStringFontSize = verticalPipRowSpacing / (attemptedPipString.size().height / verticalPipRowSpacing)
            let probablyOkayPipString = centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize)
            if probablyOkayPipString.size().width > pipRect.size.width / maxHorizontalPipCount {
                return centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize /
                    (probablyOkayPipString.size().width / (pipRect.size.width / maxHorizontalPipCount)))
            } else {
                return probablyOkayPipString
            }
        }
        
        if pipsPerRowForRank.indices.contains(rank) {
            let pipsPerRow = pipsPerRowForRank[rank]
            var pipRect = bounds.insetBy(dx: cornerOffset, dy: cornerOffset).insetBy(dx: cornerString.size().width, dy: cornerString.size().height / 2)
            let pipString = createPipString(thatFits: pipRect)
            let pipRowSpacing = pipRect.size.height / CGFloat(pipsPerRow.count)
            pipRect.size.height = pipString.size().height
            pipRect.origin.y += (pipRowSpacing - pipRect.size.height) / 2
            for pipCount in pipsPerRow {
                switch pipCount {
                case 1:
                    pipString.draw(in: pipRect)
                case 2:
                    pipString.draw(in: pipRect.leftHalf)
                    pipString.draw(in: pipRect.rightHalf)
                default:
                    break
                }
                pipRect.origin.y += pipRowSpacing
            }
        }
    }
    
    /// Called when the iOS interface environment changes.
    ///
    /// For example, when user changes the system-wide accessibility font size
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection) // NOTE: professor forgot to call super's method
        //updateView()
    }
    
}

// Extension with simple but useful utilities
extension PlayingCardView {
    
    /// Ratios that determine the card's size
    private struct SizeRatio {
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.085
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
        static let cornerOffsetToCornerRadius: CGFloat = 0.33
        static let faceCardImageSizeToBoundsSize: CGFloat = 0.95
    }
    
    /// Corner radius
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    
    /// Corner offset
    private var cornerOffset: CGFloat {
        return cornerRadius * SizeRatio.cornerOffsetToCornerRadius
    }
    
    /// The font size for the corner text
    private var cornerFontSize: CGFloat {
        return bounds.size.height * SizeRatio.cornerFontSizeToBoundsHeight
    }
    
    /// Get the string-representation of the current rank
    private var rankString: String {
        switch rank {
        case 1: return "A"
        case 2...10: return String(rank)
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default: return "?"
        }
    }
}

// Extension with simple but useful utilities
extension CGPoint {
    /// Get a new point with the given offset
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x + dx, y: y + dy)
    }
}

// Extension with simple but useful utilities
extension CGRect {
    
    /// Zoom rect by given factor
    func zoom(by zoomFactor: CGFloat) -> CGRect {
        let zoomedWidth = size.width * zoomFactor
        let zoomedHeight = size.height * zoomFactor
        let originX = origin.x + (size.width - zoomedWidth) / 2
        let originY = origin.y + (size.height - zoomedHeight) / 2
        return CGRect(origin: CGPoint(x: originX,y: originY) , size: CGSize(width: zoomedWidth, height: zoomedHeight))
    }
    
    /// Get the left half of the rect
    var leftHalf: CGRect {
        let width = size.width / 2
        return CGRect(origin: origin, size: CGSize(width: width, height: size.height))
    }
    
    /// Get the right half of the rect
    var rightHalf: CGRect {
        let width = size.width / 2
        return CGRect(origin: CGPoint(x: origin.x + width, y: origin.y), size: CGSize(width: width, height: size.height))
    }
}
