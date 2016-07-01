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

let timingPrioritySegments = ["MaxTime", "MinTime", "Median", "Average"]
let sequenceTypeSegments = ["Instantly", "Time Progress", "Value Progress"]


var functionTypes : [String] = ["SpringDecay", "SpringCustom",
                                "Linear", "LinearSmooth", "LinearSmoother",
                                "InSine", "OutSine", "InOutSine", "OutInSine",
                                "InAtan", "OutAtan", "InOutAtan",
                                "InQuadratic", "OutQuadratic", "InOutQuadratic", "OutInQuadratic",
                                "InCubic", "OutCubic", "InOutCubic", "OutInCubic",
                                "InQuartic",  "OutQuartic", "InOutQuartic", "OutInQuartic",
                                "InQuintic", "OutQuintic", "InOutQuintic", "OutInQuintic",
                                "InExponential", "OutExponential", "InOutExponential", "OutInExponential",
                                "InCircular", "OutCircular", "InOutCircular", "OutInCircular",
                                "InBack",  "OutBack", "InOutBack", "OutInBack",
                                "InElastic", "OutElastic", "InOutElastic", "OutInElastic",
                                "InBounce", "OutBounce", "InOutBounce", "OutInBounce"]

var functions : [FAEasing]    = [.SpringDecay(velocity : CGPointZero), .SpringCustom(velocity: CGPointZero, frequency: 21, ratio: 0.99),
                                 .Linear, .LinearSmooth, .LinearSmoother,
                                 .InSine, .OutSine, .InOutSine, .OutInSine,
                                 .InAtan, .OutAtan, .InOutAtan,
                                 .InQuadratic, .OutQuadratic, .InOutQuadratic, .OutInQuadratic,
                                 .InCubic, .OutCubic, .InOutCubic, .OutInCubic,
                                 .InQuartic, .OutQuartic, .InOutQuartic, .OutInQuartic,
                                 .InQuintic, .OutQuintic, .InOutQuintic, .OutInQuintic,
                                 .InExponential, .OutExponential, .InOutExponential, .OutInExponential,
                                 .InCircular, .OutCircular, .InOutCircular, .OutInCircular,
                                 .InBack,  .OutBack, .InOutBack, .OutInBack,
                                 .InElastic, .OutElastic, .InOutElastic,
                                 .InBounce, .OutBounce, .InOutBounce, .OutInBounce]

protocol ConfigurationViewDelegate {
    func selectedTimingPriority(priority : FAPrimaryTimingPriority)
    func toggleSecondaryView(enabled : Bool)
    
    func currentPrimaryFlagValue(atIndex : Int) -> Bool
    func currentEAsingFuntion(atIndex : Int) -> FAEasing
}

class ConfigurationView : UIView {
    
    var interactionDelegate: ConfigurationViewDelegate?
    weak var cellDelegate : CurveCollectionViewCellDelegate?
   
    var selectedIndex: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    var initialCenter = CGPointZero
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
        addSubview(contentCollectionView)
        addSubview(separator)
        addSubview(titleLabel)
        addSubview(segnmentedControl)
        addSubview(secondSeparator)
        addSubview(enableSecondaryViewLabel)
        addSubview(secondaryViewSwitch)
        addSubview(delaySegnmentedControl)
        addSubview(progressTriggerSlider)
        addSubview(atProgressLabel)
        addSubview(progressLabel)
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

    
        enableSecondaryViewLabel.alignWithSize(CGSizeMake(self.bounds.width - 32, 24),
                                 toFrame: separator.frame,
                                 horizontal: HGHorizontalAlign.LeftEdge,
                                 vertical: HGVerticalAlign.Below,
                                 horizontalOffset:  16,
                                 verticalOffset: 20)
        
        initialCenter = enableSecondaryViewLabel.center
    
        atProgressLabel.alignWithSize(CGSizeMake(180, 24),
                                               toFrame: enableSecondaryViewLabel.frame,
                                               horizontal: HGHorizontalAlign.LeftEdge,
                                               vertical: HGVerticalAlign.Below,
                                               horizontalOffset:  0,
                                               verticalOffset: 4)
        
        secondaryViewSwitch.sizeToFit()
        secondaryViewSwitch.alignWithSize(secondaryViewSwitch.bounds.size,
                                    toFrame: separator.frame,
                                    horizontal: HGHorizontalAlign.RightEdge,
                                    vertical: HGVerticalAlign.Below,
                                    horizontalOffset: -16,
                                    verticalOffset:28)
        
        
        delaySegnmentedControl.sizeToFit()
        delaySegnmentedControl.alignWithSize(CGSizeMake(self.bounds.width - 32, delaySegnmentedControl.bounds.height),
                                        toFrame: atProgressLabel.frame,
                                        horizontal: HGHorizontalAlign.LeftEdge,
                                        vertical: HGVerticalAlign.Below,
                                        verticalOffset : 22)
        
        
        progressTriggerSlider.alignWithSize(CGSizeMake(delaySegnmentedControl.bounds.width, progressTriggerSlider.bounds.height),
                                             toFrame: delaySegnmentedControl.frame,
                                             horizontal: HGHorizontalAlign.LeftEdge,
                                             vertical: HGVerticalAlign.Below,
                                             verticalOffset : 32)
        
        var adjustedPosition = enableSecondaryViewLabel.center
        adjustedPosition.y =  adjustedPosition.y + 16
        
        enableSecondaryViewLabel.center = adjustedPosition
    }
    
    func registerCells() {
         contentCollectionView.registerClass(CurveSelectionCollectionViewCell.self, forCellWithReuseIdentifier: "PropertyCell0")
         contentCollectionView.registerClass(CurveSelectionCollectionViewCell.self, forCellWithReuseIdentifier: "PropertyCell1")
         contentCollectionView.registerClass(CurveSelectionCollectionViewCell.self, forCellWithReuseIdentifier: "PropertyCell2")
         contentCollectionView.registerClass(CurveSelectionCollectionViewCell.self, forCellWithReuseIdentifier: "PropertyCell3")
    }
    
    // MARK: - Lazy Loaded Views
    
    lazy var segnmentedControl : UISegmentedControl = {
        var segmentedControl = UISegmentedControl(items: timingPrioritySegments)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.tintColor = UIColor.whiteColor()
        segmentedControl.addTarget(self, action: #selector(ConfigurationView.changedPriority(_:)), forControlEvents: .ValueChanged)
        return segmentedControl
    }()
    
    func changedPriority(segmentedControl : UISegmentedControl) {
        self.interactionDelegate?.selectedTimingPriority(FAPrimaryTimingPriority(rawValue: segmentedControl.selectedSegmentIndex)!)
    }
    
    lazy var delaySegnmentedControl : UISegmentedControl = {
        var segmentedControl = UISegmentedControl(items: sequenceTypeSegments)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.tintColor = UIColor.whiteColor()
        segmentedControl.addTarget(self, action: #selector(ConfigurationView.changedTrigger(_:)), forControlEvents: .ValueChanged)
        return segmentedControl
        
    }()
    
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
    
    lazy var enableSecondaryViewLabel: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.whiteColor()
        label.text = "Enable Seconday View"
        label.backgroundColor = UIColor.clearColor()
        label.font = UIFont(name: "Helvetica", size: 15)
        label.textAlignment = .Left
        return label
    }()
    
    lazy var atProgressLabel: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.whiteColor()
        label.text = "Trigger at progress : "
        label.backgroundColor = UIColor.clearColor()
        label.font = UIFont(name: "Helvetica", size: 15)
        label.textAlignment = .Left
        label.alpha = 0.0
        return label
    }()
    
    lazy var progressLabel: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.whiteColor()
        label.text = "Trigger at progress : "
        label.backgroundColor = UIColor.clearColor()
        label.font = UIFont(name: "Helvetica", size: 15)
        label.alpha = 0.0
        label.textAlignment = .Left
        return label
    }()
    
    lazy var secondaryViewSwitch: UISwitch = {
        var tempSwitch = UISwitch()
        tempSwitch.on = true
        tempSwitch.backgroundColor = UIColor.clearColor()
        tempSwitch.addTarget(self, action: #selector(ConfigurationView.secondary_view_value_changed(_:)), forControlEvents: UIControlEvents.ValueChanged)
        return tempSwitch
    }()
    
    lazy var progressTriggerSlider : UISlider = {
        var slider = UISlider(frame:CGRectMake(20, 260, 280, 20))
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.continuous = true
        slider.tintColor = UIColor(rgba: "#444444")
        slider.value = 0
        slider.alpha = 0.0
        slider.addTarget(self, action: #selector(ConfigurationView.progress_value_changed(_:)), forControlEvents: .ValueChanged)
        return slider
    }()
    
    func progress_value_changed(sender : UISlider) {
        

    }
    
    func changedTrigger(segmentedControl : UISegmentedControl) {
    
        if segmentedControl.selectedSegmentIndex == 0 {
           
            progressTriggerSlider.animate { (animator) in
                animator.alpha(0.0).duration(0.5).easing(.OutSine)
            }
            
            var adjustedPosition = enableSecondaryViewLabel.center
            adjustedPosition.y =  adjustedPosition.y + 16
        
            atProgressLabel.animate { (animator) in
                animator.alpha(0.0).duration(0.5).easing(.OutSine)
                
                animator.triggerAtTimeProgress(atProgress: 0.7, onView: self.enableSecondaryViewLabel, animator: { (animator) in
                    animator.position(adjustedPosition).duration(0.5).easing(.OutSine)
                })
                
                animator.triggerAtTimeProgress(atProgress: 0.0, onView: self.progressTriggerSlider, animator: { (animator) in
                    animator.alpha(0.0).duration(0.5).easing(.OutSine)
                })
            }

        } else  {

            
            enableSecondaryViewLabel.animate { (animator) in
                animator.position(initialCenter).duration(0.5).easing(.OutSine)
                
                animator.triggerAtTimeProgress(atProgress: 0.6, onView: self.atProgressLabel, animator: { (animator) in
                    animator.alpha(1.0).duration(0.5).easing(.OutSine)
                })
                
                animator.triggerAtTimeProgress(atProgress: 0.7, onView: self.progressTriggerSlider, animator: { (animator) in
                    animator.alpha(1.0).duration(0.5).easing(.OutSine)
                })
            }
        }
        
        self.interactionDelegate?.selectedTimingPriority(FAPrimaryTimingPriority(rawValue: segmentedControl.selectedSegmentIndex)!)
    }
    
    
    func secondary_view_value_changed(sender : UISwitch) {
       
        delaySegnmentedControl.animate { (animator) in
            animator.alpha(sender.on ? 1.0 : 0.5).duration(0.6).easing(.OutSine)
        }
        
        delaySegnmentedControl.userInteractionEnabled = sender.on
        self.interactionDelegate?.toggleSecondaryView(sender.on)
    }
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
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) { }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return cellAtIndex(indexPath)
    }
    
    func cellAtIndex(indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = contentCollectionView.dequeueReusableCellWithReuseIdentifier("PropertyCell\(indexPath.row)" as String, forIndexPath: indexPath) as? CurveSelectionCollectionViewCell {
            cell.delegate = cellDelegate
            cell.propertyConfigType = PropertyConfigType(rawValue : indexPath.row)!
            cell.primarySwitch.on = interactionDelegate!.currentPrimaryFlagValue(indexPath.row)
            cell.pickerView.selectRow(functions.indexOf(interactionDelegate!.currentEAsingFuntion(indexPath.row))!, inComponent: 0, animated: true)
            
            return cell
        }
        
        return UICollectionViewCell()
    }
}

