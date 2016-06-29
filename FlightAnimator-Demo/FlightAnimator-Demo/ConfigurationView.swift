//
//  ConfigCollectionViewCell.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit
// import FlightAnimator

enum PropertyConfigType : Int {
    case Bounds
    case Position
    case Alpha
    case Transform
}

var functionTypes : [String] = ["SpringDecay", "SpringCustom",
                                "Linear", "LinearSmooth", "LinearSmoother",
                                "EaseInSine", "EaseOutSine", "EaseInOutSine", "EaseOutInSine",
                                "EaseInQuadratic", "EaseOutQuadratic", "EaseInOutQuadratic", "EaseOutInQuadratic",
                                "EaseInCubic", "EaseOutCubic", "EaseInOutCubic", "EaseOutInCubic",
                                "EaseInQuartic",  "EaseOutQuartic", "EaseInOutQuartic", "EaseOutInQuartic",
                                "EaseInQuintic", "EaseOutQuintic", "EaseInOutQuintic", "EaseOutInQuintic",
                                "EaseInExponential", "EaseOutExponential", "EaseInOutExponential", "EaseOutInExponential",
                                "EaseInCircular", "EaseOutCircular", "EaseInOutCircular", "EaseOutInCircular",
                                "EaseInBack",  "EaseOutBack", "EaseInOutBack", "EaseOutInBack",
                                "EaseInElastic", "EaseOutElastic", "EaseInOutElastic", "EaseOutInElastic",
                                "EaseInBounce", "EaseOutBounce", "EaseInOutBounce", "EaseOutInBounce"]

var functions : [FAEasing]    = [.SpringDecay(velocity : CGPointZero), .SpringCustom(velocity: CGPointZero, frequency: 21, ratio: 0.99),
                                 .Linear, .LinearSmooth, .LinearSmoother,
                                 .EaseInSine, .EaseOutSine, .EaseInOutSine, .EaseOutInSine,
                                 .EaseInQuadratic, .EaseOutQuadratic, .EaseInOutQuadratic, .EaseOutInQuadratic,
                                 .EaseInCubic, .EaseOutCubic, .EaseInOutCubic, .EaseOutInCubic,
                                 .EaseInQuartic, .EaseOutQuartic, .EaseInOutQuartic, .EaseOutInQuartic,
                                 .EaseInQuintic, .EaseOutQuintic, .EaseInOutQuintic, .EaseOutInQuintic,
                                 .EaseInExponential, .EaseOutExponential, .EaseInOutExponential, .EaseOutInExponential,
                                 .EaseInCircular, .EaseOutCircular, .EaseInOutCircular, .EaseOutInCircular,
                                 .EaseInBack,  .EaseOutBack, .EaseInOutBack, .EaseOutInBack,
                                 .EaseInElastic, .EaseOutElastic, .EaseInOutElastic, .EaseOutInElastic,
                                 .EaseInBounce, .EaseOutBounce, .EaseInOutBounce, .EaseOutInBounce]


protocol ConfigurationViewDelegate {
    func configCellDidSelectEasingFuntion(function: FAEasing, propertyType : PropertyConfigType, functionTitle: String)
    func selectedEasingFunctionTitleFor(propertyType : PropertyConfigType) -> String
    func selectedTimingPriority(priority : FAPrimaryTimingPriority)
    
    func primarySelectionUpdated(propertyType : PropertyConfigType,  isPrimary : Bool)
    func primaryValueFor(propertyType : PropertyConfigType) -> Bool
}

class ConfigurationView : UIView {
    
    var interactionDelegate: ConfigurationViewDelegate?
    var selectedIndex: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    
    var propertyConfigType : PropertyConfigType = PropertyConfigType.Bounds {
        didSet {
            self.contentCollectionView.reloadData()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        registerCells()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func setup() {
        clipsToBounds = true
        backgroundColor = UIColor(rgba: "#444444")
        
        addSubview(backgroundView)
        addSubview(pickerView)
        addSubview(contentCollectionView)
        addSubview(separator)
        addSubview(titleLabel)
        addSubview(segnmentedControl)
        addSubview(secondSeparator)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.alignWithSize(CGSizeMake(self.bounds.width - 32, 24),
                                 toFrame: self.bounds,
                                 horizontal: HGHorizontalAlign.LeftEdge,
                                 vertical: HGVerticalAlign.Top,
                                 horizontalOffset:  16,
                                 verticalOffset: 16)
        
        segnmentedControl.sizeToFit()
        segnmentedControl.alignWithSize(CGSizeMake(self.bounds.width - 32, segnmentedControl.bounds.height),
                                 toFrame: titleLabel.frame,
                                 horizontal: HGHorizontalAlign.LeftEdge,
                                 vertical: HGVerticalAlign.Below,
                                 verticalOffset : 10)
  
        secondSeparator.alignWithSize(CGSizeMake(self.bounds.width, 1),
                                        toFrame: segnmentedControl.frame,
                                        horizontal: HGHorizontalAlign.Center,
                                        vertical: HGVerticalAlign.Below,
                                        verticalOffset :18)
        
        contentCollectionView.alignWithSize(CGSizeMake(self.bounds.width, 336),
                                      toFrame: secondSeparator.frame,
                                      horizontal: HGHorizontalAlign.Center,
                                      vertical: HGVerticalAlign.Below,
                                      verticalOffset : 0)
        
        
        separator.alignWithSize(CGSizeMake(self.bounds.width, 1),
                                      toFrame: contentCollectionView.frame,
                                      horizontal: HGHorizontalAlign.Center,
                                      vertical: HGVerticalAlign.Below,
                                      verticalOffset :0)


        
        backgroundView.frame = self.bounds
        pickerView.sizeToFit()
        pickerView.alignWithSize(pickerView.bounds.size,
                                 toFrame: bounds,
                                 horizontal: HGHorizontalAlign.Center,
                                 vertical: HGVerticalAlign.Base,
                                 verticalOffset : -36)
    }
    
    func registerCells() {
        contentCollectionView.registerClass(CurveSelectionCollectionViewCell.self, forCellWithReuseIdentifier: "PropertyCell0")
         contentCollectionView.registerClass(CurveSelectionCollectionViewCell.self, forCellWithReuseIdentifier: "PropertyCell1")
         contentCollectionView.registerClass(CurveSelectionCollectionViewCell.self, forCellWithReuseIdentifier: "PropertyCell2")
         contentCollectionView.registerClass(CurveSelectionCollectionViewCell.self, forCellWithReuseIdentifier: "PropertyCell3")
    }
    
    func setupAnimation() {
        if let cell = contentCollectionView.cellForItemAtIndexPath(selectedIndex) as? CurveSelectionCollectionViewCell {
            cell.startFade()
        }
    }
    
    // MARK: - Lazy Loaded Views
    
    lazy var pickerView : UIPickerView = {
        var picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        picker.opaque = false
        picker.backgroundColor = UIColor(rgba: "#444444")
        return picker
    }()
    
    lazy var segnmentedControl : UISegmentedControl = {
        let items = ["MaxTime", "MinTime", "Median", "Average"]
        
        var segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.tintColor = UIColor.whiteColor()
        segmentedControl.addTarget(self, action: #selector(ConfigurationView.changedPriority(_:)), forControlEvents: .ValueChanged)
        return segmentedControl

    }()
    
    func changedPriority(segmentedControl : UISegmentedControl) {
        self.interactionDelegate?.selectedTimingPriority(FAPrimaryTimingPriority(rawValue: segmentedControl.selectedSegmentIndex)!)
    }
    
    lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.whiteColor()
        label.text = "Primary Timing Priority"
        label.backgroundColor = UIColor.clearColor()
        label.font = UIFont(name: "Helvetica", size: 15)
        label.textAlignment = .Center
        return label
    }()
    
    lazy var backgroundView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor(rgba: "#444444")
        return view
    }()
    
    lazy var separator: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        return view
    }()
    
    lazy var secondSeparator: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        return view
    }()
    
    lazy var contentCollectionView : UICollectionView = {
        [unowned self] in
        
        var flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 1.0
        flowLayout.minimumLineSpacing = 1.0
        flowLayout.scrollDirection = .Vertical
        flowLayout.sectionInset = UIEdgeInsetsZero
        
        var tempCollectionView : UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout :flowLayout)
        tempCollectionView.alpha = 1.0
        tempCollectionView.clipsToBounds = true
        tempCollectionView.backgroundColor = UIColor.whiteColor()
        tempCollectionView.delegate = self
        tempCollectionView.dataSource = self
        tempCollectionView.scrollEnabled = false
        tempCollectionView.pagingEnabled = false
        return tempCollectionView
        }()
}

extension ConfigurationView : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.bounds.size.width, 84)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath
        propertyConfigType = PropertyConfigType(rawValue:indexPath.row)!
        let title = interactionDelegate?.selectedEasingFunctionTitleFor(PropertyConfigType(rawValue : indexPath.row)!)
        pickerView.selectRow(functionTypes.indexOf(title!)!, inComponent: 0, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return cellAtIndex(indexPath)
    }
    
    func cellAtIndex(indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = contentCollectionView.dequeueReusableCellWithReuseIdentifier("PropertyCell\(indexPath.row)" as String, forIndexPath: indexPath) as? CurveSelectionCollectionViewCell {
            cell.delegate = self
            cell.propertyConfigType = PropertyConfigType(rawValue : indexPath.row)!
            cell.primarySwitch.on = (interactionDelegate?.primaryValueFor(PropertyConfigType(rawValue : indexPath.row)!))!
            cell.curveSelectionLabel.text =  "Easing Curve : " + (interactionDelegate?.selectedEasingFunctionTitleFor(PropertyConfigType(rawValue : indexPath.row)!))!
            
            if selectedIndex.row == indexPath.row {
                cell.startFade()
            } else {
                cell.stopFade()
            }
            return cell
        }
        
        return UICollectionViewCell()
    }
}

extension ConfigurationView: UIPickerViewDataSource, UIPickerViewDelegate, CurveCollectionViewCellDelegate {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return functionTypes.count
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let string = functionTypes[row]
        return NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        interactionDelegate?.configCellDidSelectEasingFuntion(functions[row], propertyType : propertyConfigType, functionTitle: functionTypes[row])
    
        if let cell = contentCollectionView.cellForItemAtIndexPath(NSIndexPath(forRow : propertyConfigType.rawValue , inSection: 0)) as? CurveSelectionCollectionViewCell {
            cell.curveSelectionLabel.text = "Easing Curve : " + (interactionDelegate?.selectedEasingFunctionTitleFor(propertyConfigType))!
        }
    }
    
    func primarySelectionUpdated(propertyType : PropertyConfigType,  isPrimary : Bool) {
        self.interactionDelegate?.primarySelectionUpdated(propertyType, isPrimary: isPrimary)
    }
}

