//
//  CurveSelectionCollectionViewCell.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

protocol CurveCollectionViewCellDelegate : class {
    func primarySelectionUpdated(propertyType : PropertyConfigType,  isPrimary : Bool)
}

class CurveSelectionCollectionViewCell : UICollectionViewCell {
    
    weak var delegate : CurveCollectionViewCellDelegate?
    
    var propertyConfigType : PropertyConfigType = PropertyConfigType.Bounds {
        didSet {
            switch propertyConfigType {
            case .Bounds:
                titleLabel.text = "Bounds"
            case .Position:
                titleLabel.text = "Position"
            case .Alpha:
                titleLabel.text = "Alpha"
            case .Transform:
                titleLabel.text = "Transform"
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.addSublayer(gradient)
        contentView.addSubview(curveSelectionLabel)
        contentView.addSubview(primarySwitch)
        contentView.addSubview(titleLabel)
        layoutInterface()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutInterface()
    }
    
    func layoutInterface() {
        gradient.colors = [ UIColor(rgba: "#444444").CGColor, UIColor(rgba: "#4B4C51").CGColor]
        gradient.frame = contentView.bounds
        curveSelectionLabel.frame = self.contentView.bounds
        
        titleLabel.alignWithSize(CGSizeMake(200, 24),
                                 toFrame: contentView.bounds,
                                 horizontal: HGHorizontalAlign.LeftEdge,
                                 vertical: HGVerticalAlign.Top,
                                 horizontalOffset:  16,
                                 verticalOffset: 16)
        
        curveSelectionLabel.alignWithSize(CGSizeMake(contentView.bounds.width, 24),
                                          toFrame: titleLabel.frame,
                                          horizontal: HGHorizontalAlign.LeftEdge,
                                          vertical: HGVerticalAlign.Below,
                                          verticalOffset: 4)
        primarySwitch.sizeToFit()
        primarySwitch.alignWithSize(primarySwitch.bounds.size,
                                    toFrame: contentView.bounds,
                                    horizontal: HGHorizontalAlign.RightEdge,
                                    vertical: HGVerticalAlign.Center,
                                    horizontalOffset: -16,
                                    verticalOffset: 0)
    }
    
    func startFade() {
        UIView.animateWithDuration(0.5, delay:0, options: [.Repeat, .Autoreverse], animations: {
            self.titleLabel.alpha = 0.4
            }, completion: nil)
    }
    
    func stopFade() {
        titleLabel.layer.removeAllAnimations()
        titleLabel.alpha = 1.0
    }
        
    lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.whiteColor()
        label.backgroundColor = UIColor.clearColor()
        label.font = UIFont(name: "Helvetica", size: 15)
        label.textAlignment = .Left
        return label
    }()
    
    lazy var gradient: CAGradientLayer = {
        return CAGradientLayer()
    }()
    
    lazy var curveSelectionLabel: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.whiteColor()
        label.backgroundColor = UIColor.clearColor()
        label.font = UIFont(name: "Helvetica", size: 15)
        label.textAlignment = .Left
        return label
    }()
    
    func value_changed(sender : UISwitch) {
        self.delegate?.primarySelectionUpdated(self.propertyConfigType, isPrimary: sender.on)
    }
    
    lazy var primarySwitch: UISwitch = {
        var tempSwitch = UISwitch()
        tempSwitch.backgroundColor = UIColor.clearColor()
        tempSwitch.addTarget(self, action: #selector(CurveSelectionCollectionViewCell.value_changed(_:)), forControlEvents: UIControlEvents.ValueChanged)
        return tempSwitch
    }()
}