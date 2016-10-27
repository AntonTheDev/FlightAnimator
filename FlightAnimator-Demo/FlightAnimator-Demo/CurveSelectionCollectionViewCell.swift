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
    func cell(_ cell : CurveSelectionCollectionViewCell , didSelectEasing easing: FAEasing)
    func cell(_ cell : CurveSelectionCollectionViewCell , didSelectPrimary isPrimary: Bool)
   
    func currentPrimaryValue(_ cell : CurveSelectionCollectionViewCell) -> Bool
    func currentEAsingFuntion(_ cell : CurveSelectionCollectionViewCell) -> FAEasing
}

class CurveSelectionCollectionViewCell : UICollectionViewCell {
    
    weak var delegate : CurveCollectionViewCellDelegate? {
        didSet {
 
        }
    }
    
    var propertyConfigType : PropertyConfigType = PropertyConfigType.bounds {
        didSet {
            switch propertyConfigType {
            case .bounds:
                titleLabel.text = "Bounds"
            case .position:
                titleLabel.text = "Position"
            case .alpha:
                titleLabel.text = "Alpha"
            case .transform:
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
        gradient.colors = [ UIColor(rgba: "#444444").cgColor, UIColor(rgba: "#4B4C51").cgColor]
        gradient.frame = contentView.bounds
        curveSelectionLabel.frame = self.contentView.bounds
        
        titleLabel.alignWithSize(CGSize(width: 200, height: 24),
                                 toFrame: contentView.bounds,
                                 horizontal: HGHorizontalAlign.leftEdge,
                                 vertical: HGVerticalAlign.center,
                                 horizontalOffset:  16,
                                 verticalOffset: 0)
        
        curveSelectionLabel.alignWithSize(CGSize(width: contentView.bounds.width, height: 24),
                                          toFrame: titleLabel.frame,
                                          horizontal: HGHorizontalAlign.leftEdge,
                                          vertical: HGVerticalAlign.below,
                                          verticalOffset: 4)
        primarySwitch.sizeToFit()
        primarySwitch.alignWithSize(primarySwitch.bounds.size,
                                    toFrame: contentView.bounds,
                                    horizontal: HGHorizontalAlign.rightEdge,
                                    vertical: HGVerticalAlign.center,
                                    horizontalOffset: -16,
                                    verticalOffset: 0)
        
        pickerView.sizeToFit()
        pickerView.alignWithSize(CGSize(width: 200, height: contentView.bounds.height),
                                 toFrame: contentView.bounds,
                                 horizontal: HGHorizontalAlign.leftEdge,
                                 vertical: HGVerticalAlign.center,
                                 horizontalOffset : 90)
        
        for subview in pickerView.subviews{
            subview.backgroundColor = UIColor.clear
        }
    }
 
    lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.clear
        label.font = UIFont(name: "Helvetica", size: 15)
        label.textAlignment = .left
        return label
    }()
    
    lazy var gradient: CAGradientLayer = {
        return CAGradientLayer()
    }()
    
    lazy var curveSelectionLabel: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.clear
        label.font = UIFont(name: "Helvetica", size: 15)
        label.textAlignment = .left
        return label
    }()
    
    lazy var pickerView : UIPickerView = {
        var picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        picker.isOpaque = false
        picker.backgroundColor = UIColor.clear
        return picker
    }()
    
    func value_changed(_ sender : UISwitch) {
      self.delegate?.cell(self, didSelectPrimary : sender.isOn)
    }
    
    lazy var primarySwitch: UISwitch = {
        var tempSwitch = UISwitch()
        tempSwitch.backgroundColor = UIColor.clear
        tempSwitch.addTarget(self, action: #selector(CurveSelectionCollectionViewCell.value_changed(_:)), for: UIControlEvents.valueChanged)
        return tempSwitch
    }()
}


extension CurveSelectionCollectionViewCell: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return functionTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.delegate?.cell(self, didSelectEasing : functions[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var pickerLabel = view as? UILabel
        
        if (pickerLabel == nil) {
            pickerLabel = UILabel()
            
            pickerLabel?.font = UIFont(name: "MenloiPhoneiPad", size: 14)
            pickerLabel?.textColor = UIColor.white
            pickerLabel?.textAlignment = NSTextAlignment.center
        }
        
        pickerLabel?.text = functionTypes[row]
        
        return pickerLabel!
    }
    
    func primarySelectionUpdated(_ propertyType : PropertyConfigType,  isPrimary : Bool) {
        self.delegate?.cell(self, didSelectPrimary : isPrimary)
    }
}
