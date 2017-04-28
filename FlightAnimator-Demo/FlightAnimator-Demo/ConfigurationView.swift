//
//  ConfigCollectionViewCell.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit


enum PropertyConfigType : Int {
    case bounds
    case position
    case alpha
    case transform
}

let timingPrioritySegments = ["MaxTime", "MinTime", "Median", "Average"]
let sequenceTypeSegments = ["Instantly", "Time Progress", "Value Progress"]

var functionTypes : [String] = ["SpringDecay", "SpringCustom",
                                "Linear", "SmoothStep", "SmootherStep",
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

var functions : [FAEasing]    = [.springDecay(velocity : CGPoint.zero), .springCustom(velocity: CGPoint.zero, frequency: 14, ratio: 0.8),
                                 .linear, .smoothStep, .smootherStep,
                                 .inSine, .outSine, .inOutSine, .outInSine,
                                 .inAtan, .outAtan, .inOutAtan,
                                 .inQuadratic, .outQuadratic, .inOutQuadratic, .outInQuadratic,
                                 .inCubic, .outCubic, .inOutCubic, .outInCubic,
                                 .inQuartic, .outQuartic, .inOutQuartic, .outInQuartic,
                                 .inQuintic, .outQuintic, .inOutQuintic, .outInQuintic,
                                 .inExponential, .outExponential, .inOutExponential, .outInExponential,
                                 .inCircular, .outCircular, .inOutCircular, .outInCircular,
                                 .inBack,  .outBack, .inOutBack, .outInBack,
                                 .inElastic, .outElastic, .inOutElastic, .outInElastic,
                                 .inBounce, .outBounce, .inOutBounce, .outInBounce]

protocol ConfigurationViewDelegate {
    func selectedTimingPriority(_ priority : FAPrimaryTimingPriority)
    func didUpdateTriggerProgressPriority(_ progress : CGFloat)
    func didUpdateTriggerType(_ type : Int)

    func toggleSecondaryView(_ enabled : Bool)
    
    func currentPrimaryFlagValue(_ atIndex : Int) -> Bool
    func currentEAsingFuntion(_ atIndex : Int) -> FAEasing
}

class ConfigurationView : UIView {
    
    var interactionDelegate: ConfigurationViewDelegate?
    weak var cellDelegate : CurveCollectionViewCellDelegate?
   
    var selectedIndex: IndexPath = IndexPath(row: 0, section: 0)
    var initialCenter = CGPoint.zero
    var propertyConfigType : PropertyConfigType = PropertyConfigType.bounds {
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
        
        titleLabel.alignWithSize(CGSize(width: self.bounds.width - 32, height: 24),
                                 toFrame: self.bounds,
                                 horizontal: HGHorizontalAlign.leftEdge,
                                 vertical: HGVerticalAlign.top,
                                 horizontalOffset:  16,
                                 verticalOffset: 16)
        
        segnmentedControl.sizeToFit()
        segnmentedControl.alignWithSize(CGSize(width: self.bounds.width - 32, height: segnmentedControl.bounds.height),
                                 toFrame: titleLabel.frame,
                                 horizontal: HGHorizontalAlign.leftEdge,
                                 vertical: HGVerticalAlign.below,
                                 verticalOffset : 10)
  
        secondSeparator.alignWithSize(CGSize(width: self.bounds.width, height: 1),
                                        toFrame: segnmentedControl.frame,
                                        horizontal: HGHorizontalAlign.center,
                                        vertical: HGVerticalAlign.below,
                                        verticalOffset :24)
        
        contentCollectionView.alignWithSize(CGSize(width: self.bounds.width, height: 336),
                                      toFrame: secondSeparator.frame,
                                      horizontal: HGHorizontalAlign.center,
                                      vertical: HGVerticalAlign.below,
                                      verticalOffset : 0)
        
        
        separator.alignWithSize(CGSize(width: self.bounds.width, height: 1),
                                      toFrame: contentCollectionView.frame,
                                      horizontal: HGHorizontalAlign.center,
                                      vertical: HGVerticalAlign.below,
                                      verticalOffset :0)
        
        backgroundView.frame = self.bounds

    
        enableSecondaryViewLabel.alignWithSize(CGSize(width: self.bounds.width - 32, height: 24),
                                 toFrame: separator.frame,
                                 horizontal: HGHorizontalAlign.leftEdge,
                                 vertical: HGVerticalAlign.below,
                                 horizontalOffset:  16,
                                 verticalOffset: 20)
        
        initialCenter = enableSecondaryViewLabel.center
    
        atProgressLabel.alignWithSize(CGSize(width: 180, height: 24),
                                               toFrame: enableSecondaryViewLabel.frame,
                                               horizontal: HGHorizontalAlign.leftEdge,
                                               vertical: HGVerticalAlign.below,
                                               horizontalOffset:  0,
                                               verticalOffset: 4)
        
        progressLabel.alignWithSize(CGSize(width: 60, height: 24),
                                      toFrame: atProgressLabel.frame,
                                      horizontal: HGHorizontalAlign.right,
                                      vertical: HGVerticalAlign.center,
                                      horizontalOffset:  10,
                                      verticalOffset: 0)
        
        secondaryViewSwitch.sizeToFit()
        secondaryViewSwitch.alignWithSize(secondaryViewSwitch.bounds.size,
                                    toFrame: separator.frame,
                                    horizontal: HGHorizontalAlign.rightEdge,
                                    vertical: HGVerticalAlign.below,
                                    horizontalOffset: -16,
                                    verticalOffset:28)
        
        
        delaySegnmentedControl.sizeToFit()
        delaySegnmentedControl.alignWithSize(CGSize(width: self.bounds.width - 32, height: delaySegnmentedControl.bounds.height),
                                        toFrame: atProgressLabel.frame,
                                        horizontal: HGHorizontalAlign.leftEdge,
                                        vertical: HGVerticalAlign.below,
                                        verticalOffset : 22)
        
        
        progressTriggerSlider.alignWithSize(CGSize(width: delaySegnmentedControl.bounds.width, height: progressTriggerSlider.bounds.height),
                                             toFrame: delaySegnmentedControl.frame,
                                             horizontal: HGHorizontalAlign.leftEdge,
                                             vertical: HGVerticalAlign.below,
                                             verticalOffset : 40)
        
        var adjustedPosition = enableSecondaryViewLabel.center
        adjustedPosition.y =  adjustedPosition.y + 14
        
        enableSecondaryViewLabel.center = adjustedPosition
    }
    
    func registerCells() {
         contentCollectionView.register(CurveSelectionCollectionViewCell.self, forCellWithReuseIdentifier: "PropertyCell0")
         contentCollectionView.register(CurveSelectionCollectionViewCell.self, forCellWithReuseIdentifier: "PropertyCell1")
         contentCollectionView.register(CurveSelectionCollectionViewCell.self, forCellWithReuseIdentifier: "PropertyCell2")
         contentCollectionView.register(CurveSelectionCollectionViewCell.self, forCellWithReuseIdentifier: "PropertyCell3")
    }
    
    // MARK: - Lazy Loaded Views
    
    lazy var segnmentedControl : UISegmentedControl = {
        var segmentedControl = UISegmentedControl(items: timingPrioritySegments)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.tintColor = UIColor.white
        segmentedControl.addTarget(self, action: #selector(ConfigurationView.changedPriority(_:)), for: .valueChanged)
        return segmentedControl
    }()
    
    func changedPriority(_ segmentedControl : UISegmentedControl) {
        self.interactionDelegate?.selectedTimingPriority(FAPrimaryTimingPriority(rawValue: segmentedControl.selectedSegmentIndex)!)
    }
    
    lazy var delaySegnmentedControl : UISegmentedControl = {
        var segmentedControl = UISegmentedControl(items: sequenceTypeSegments)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.alpha = 0.5
        segmentedControl.isUserInteractionEnabled = false
        segmentedControl.tintColor = UIColor.white
        segmentedControl.addTarget(self, action: #selector(ConfigurationView.changedTrigger(_:)), for: .valueChanged)
        return segmentedControl
        
    }()
    
    lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.white
        label.text = "Primary Timing Priority"
        label.backgroundColor = UIColor.clear
        label.font = UIFont(name: "Helvetica", size: 15)
        label.textAlignment = .center
        return label
    }()
    
    lazy var backgroundView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor(rgba: "#444444")
        return view
    }()
    
    lazy var separator: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    lazy var secondSeparator: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    lazy var contentCollectionView : UICollectionView = {
        [unowned self] in
        
        var flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 1.0
        flowLayout.minimumLineSpacing = 1.0
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets.zero
        
        var tempCollectionView : UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout :flowLayout)
        tempCollectionView.alpha = 1.0
        tempCollectionView.clipsToBounds = true
        tempCollectionView.backgroundColor = UIColor.white
        tempCollectionView.delegate = self
        tempCollectionView.dataSource = self
        tempCollectionView.isScrollEnabled = false
        tempCollectionView.isPagingEnabled = false
        return tempCollectionView
        }()
    
    lazy var enableSecondaryViewLabel: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.white
        label.text = "Enable Seconday View"
        label.backgroundColor = UIColor.clear
        label.font = UIFont(name: "Helvetica", size: 15)
        label.textAlignment = .left
        return label
    }()
    
    lazy var atProgressLabel: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.white
        label.text = "Trigger at progress : "
        label.backgroundColor = UIColor.clear
        label.font = UIFont(name: "Helvetica", size: 15)
        label.textAlignment = .left
        label.alpha = 0.0
        return label
    }()
    
    lazy var progressLabel: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.white
        label.text = "0.0"
        label.backgroundColor = UIColor.clear
        label.font = UIFont(name: "Helvetica", size: 15)
        label.alpha = 0.0
        label.textAlignment = .left
        return label
    }()
    
    lazy var secondaryViewSwitch: UISwitch = {
        var tempSwitch = UISwitch()
        tempSwitch.isOn = false
        tempSwitch.backgroundColor = UIColor.clear
        tempSwitch.addTarget(self, action: #selector(ConfigurationView.secondary_view_value_changed(_:)), for: UIControlEvents.valueChanged)
        return tempSwitch
    }()
    
    lazy var progressTriggerSlider : UISlider = {
        var slider = UISlider(frame:CGRect(x: 20, y: 260, width: 280, height: 20))
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.tintColor = UIColor.green
        slider.value = 0
        slider.alpha = 0.0
        slider.addTarget(self, action: #selector(ConfigurationView.progress_value_changed(_:)), for: .valueChanged)
        return slider
    }()
    
    func progress_value_changed(_ sender : UISlider) {
        
        let y = round(100 * sender.value) / 100
        progressLabel.text = String(format: "%.2f", y)
        self.interactionDelegate?.didUpdateTriggerProgressPriority(CGFloat(sender.value))
    }
    
    func changedTrigger(_ segmentedControl : UISegmentedControl) {
        
        self.interactionDelegate?.didUpdateTriggerType(segmentedControl.selectedSegmentIndex)
        
        if segmentedControl.selectedSegmentIndex == 0 {
           
            var adjustedPosition = enableSecondaryViewLabel.center
            adjustedPosition.y =  adjustedPosition.y + 16
        
            atProgressLabel.animate { (animator) in
                animator.alpha(0.0).duration(0.5).easing(.outSine)
                
                animator.triggerOnProgress(0.01, onView: self.progressLabel, animator: { (animator) in
                    animator.alpha(0.0).duration(0.5).easing(.outSine)
                })
                
                animator.triggerOnProgress(0.7, onView: self.enableSecondaryViewLabel, animator: { (animator) in
                    animator.position(adjustedPosition).duration(0.5).easing(.inSine)
                })
                
                animator.triggerOnProgress(0.1, onView: self.progressTriggerSlider, animator: { (animator) in
                    animator.alpha(0.0).duration(0.5).easing(.inSine)
                })
            }

        } else  {

            enableSecondaryViewLabel.animate { (animator) in
                animator.position(self.initialCenter).duration(0.5).easing(.outSine)
                
                animator.triggerOnProgress(0.61, onView: self.atProgressLabel, animator: { (animator) in
                    animator.alpha(1.0).duration(0.5).easing(.outSine)
                })
                
                animator.triggerOnProgress(0.6, onView: self.progressLabel, animator: { (animator) in
                    animator.alpha(1.0).duration(0.5).easing(.outSine)
                })
                
                animator.triggerOnProgress(0.7, onView: self.progressTriggerSlider, animator: { (animator) in
                    animator.alpha(1.0).duration(0.5).easing(.outSine)
                })
            }
            
            if segmentedControl.selectedSegmentIndex == 1 {
                atProgressLabel.text = "Trigger @ Time Progress:  "
            } else {
                atProgressLabel.text = "Trigger @ Value Progress: "
            }
        }
        
        self.interactionDelegate?.selectedTimingPriority(FAPrimaryTimingPriority(rawValue: segmentedControl.selectedSegmentIndex)!)
    }
    
    
    func secondary_view_value_changed(_ sender : UISwitch) {
       
        delaySegnmentedControl.animate { (animator) in
            animator.alpha(sender.isOn ? 1.0 : 0.5).duration(0.6).easing(.outSine)
        }
        
        delaySegnmentedControl.isUserInteractionEnabled = sender.isOn
        interactionDelegate?.toggleSecondaryView(sender.isOn)
    }
}

extension ConfigurationView : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 84)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return cellAtIndex(indexPath)
    }
    
    func cellAtIndex(_ indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = contentCollectionView.dequeueReusableCell(withReuseIdentifier: "PropertyCell\((indexPath as NSIndexPath).row)" as String, for: indexPath) as? CurveSelectionCollectionViewCell {
            cell.delegate = cellDelegate
            cell.propertyConfigType = PropertyConfigType(rawValue : (indexPath as NSIndexPath).row)!
            cell.primarySwitch.isOn = interactionDelegate!.currentPrimaryFlagValue((indexPath as NSIndexPath).row)
            cell.pickerView.selectRow(functions.index(of: interactionDelegate!.currentEAsingFuntion((indexPath as NSIndexPath).row))!, inComponent: 0, animated: true)
            
            return cell
        }
        
        return UICollectionViewCell()
    }
}

