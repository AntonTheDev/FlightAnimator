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
    func cell(cell : CurveSelectionCollectionViewCell , didSelectEasing easing: FAEasing)
    func cell(cell : CurveSelectionCollectionViewCell , didSelectPrimary isPrimary: Bool)
   
    func currentPrimaryValue(cell : CurveSelectionCollectionViewCell) -> Bool
    func currentEAsingFuntion(cell : CurveSelectionCollectionViewCell) -> FAEasing
}

class CurveSelectionCollectionViewCell : UICollectionViewCell {
    
    weak var delegate : CurveCollectionViewCellDelegate? {
        didSet {
 
        }
    }
    
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
        contentView.clipsToBounds = true
        contentView.layer.addSublayer(gradient)
        contentView.addSubview(pickerView)
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
                                 vertical: HGVerticalAlign.Center,
                                 horizontalOffset:  16,
                                 verticalOffset: 0)
        
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
        
        pickerView.sizeToFit()
        pickerView.alignWithSize(CGSizeMake(200, contentView.bounds.height),
                                 toFrame: contentView.bounds,
                                 horizontal: HGHorizontalAlign.LeftEdge,
                                 vertical: HGVerticalAlign.Center,
                                 horizontalOffset : 90)
        
        for subview in pickerView.subviews{
            subview.backgroundColor = UIColor.clearColor()
        }
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
    
    lazy var pickerView : UIPickerView = {
        var picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        picker.opaque = false
        picker.backgroundColor = UIColor.clearColor()
        return picker
    }()
    
    func value_changed(sender : UISwitch) {
      self.delegate?.cell(self, didSelectPrimary : sender.on)
    }
    
    lazy var primarySwitch: UISwitch = {
        var tempSwitch = UISwitch()
        tempSwitch.backgroundColor = UIColor.clearColor()
        tempSwitch.addTarget(self, action: #selector(CurveSelectionCollectionViewCell.value_changed(_:)), forControlEvents: UIControlEvents.ValueChanged)
        return tempSwitch
    }()
}


extension CurveSelectionCollectionViewCell: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return functionTypes.count
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

       
        self.delegate?.cell(self, didSelectEasing : functions[row])
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        var pickerLabel = view as? UILabel
        
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            
            pickerLabel?.font = UIFont(name: "MenloiPhoneiPad", size: 14)
            pickerLabel?.textColor = UIColor.whiteColor()
            pickerLabel?.textAlignment = NSTextAlignment.Center
        }
        
        pickerLabel?.text = functionTypes[row]
        
        return pickerLabel!
    }
    
    func primarySelectionUpdated(propertyType : PropertyConfigType,  isPrimary : Bool) {
        self.delegate?.cell(self, didSelectPrimary : isPrimary)
    }
}
