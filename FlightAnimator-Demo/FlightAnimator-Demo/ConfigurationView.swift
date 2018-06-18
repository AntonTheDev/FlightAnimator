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

var functions : [FAEasing]    = [.springDecay(velocity : [0.0, 0.0]), .springCustom(velocity:  [0.0, 0.0], frequency: 14, ratio: 0.8),
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

protocol ConfigurationViewDelegate
{
    func selectedTimingPriority(_ priority : FAPrimaryTimingPriority)
    func didUpdateTriggerProgressPriority(_ progress : CGFloat)
    func didUpdateTriggerType(_ type : Int)

    func toggleSecondaryView(_ enabled : Bool)
    
    func currentPrimaryFlagValue(_ atIndex : Int) -> Bool
    func currentEAsingFuntion(_ atIndex : Int) -> FAEasing
}

let openConfigFrame = CGRect(x: 20, y: (UIScreen.main.bounds.height == 812.0 ? 40 : 20), width: screenBounds.width - 40, height: screenBounds.height - (UIScreen.main.bounds.height == 812.0 ? 80 : 40))
let closedConfigFrame = CGRect(x: 20, y: screenBounds.height + 20, width: screenBounds.width - 40, height: screenBounds.height - 40)

class ConfigurationView : UIViewController {
    
    var interactionDelegate: ConfigurationViewDelegate?
    weak var cellDelegate : CurveCollectionViewCellDelegate?
   
    var selectedIndex: IndexPath = IndexPath(row: 0, section: 0)
    var initialCenter = CGPoint.zero
    
    var propertyConfigType : PropertyConfigType = PropertyConfigType.bounds {
        didSet {
            self.contentCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         modalPresentationStyle = .overCurrentContext
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        setupInterface()
        registerCells()
        layoutInterface()
        registerConfigViewAnimations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tappedShowConfig()
    }
    
    func setupInterface()
    {
        view.backgroundColor = UIColor.clear
        containerView.clipsToBounds = true
        containerView.backgroundColor = UIColor(rgba: "#444444")
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.layer.borderWidth = 1.0
        containerView.layer.cornerRadius = 4.0
        containerView.alpha = 1.0
   
        view.addSubview(dimmerView)
        view.addSubview(containerView)
        containerView.addSubview(backgroundView)
        containerView.addSubview(contentCollectionView)
        containerView.addSubview(separator)
        containerView.addSubview(titleLabel)
        containerView.addSubview(segnmentedControl)
        containerView.addSubview(secondSeparator)
        containerView.addSubview(enableSecondaryViewLabel)
        containerView.addSubview(secondaryViewSwitch)
        containerView.addSubview(delaySegnmentedControl)
        containerView.addSubview(progressTriggerSlider)
        containerView.addSubview(atProgressLabel)
        containerView.addSubview(progressLabel)
        
        containerView.addSubview(closeButton)
    }
    
    
    @objc func tappedShowConfig() {
        containerView.applyAnimation(forKey: AnimationKeys.ShowConfigAnimation)
    }
    
    @objc func tappedCloseConfig() {
        containerView.applyAnimation(forKey: AnimationKeys.HideConfigAnimation)
    }
    
    /**
     Called on viewDidLoad, preloads the animation states into memory
     */
    func registerConfigViewAnimations() {
        
        containerView.registerAnimation(forKey : AnimationKeys.ShowConfigAnimation,
                               timingPriority: .maxTime) { [unowned self] (animator) in
            
            let toBounds = CGRect(x: 0,y: 0, width: openConfigFrame.width, height: openConfigFrame.height)
            let toPosition = CGPoint(x: openConfigFrame.midX, y: openConfigFrame.midY)
            
            animator.bounds(toBounds).duration(0.8).easing(.outExponential)
            animator.position(toPosition).duration(0.8).easing(.outExponential).primary(true)
            
            animator.triggerOnValueProgress(0.4, onView: self.dimmerView, animator: {  (animator) in
                animator.alpha(0.5).duration(0.7).easing(.outExponential)
                animator.backgroundColor(UIColor.black.cgColor).duration(0.6).easing(.linear)
            })
 
        }
        
        containerView.registerAnimation(forKey : AnimationKeys.HideConfigAnimation,
                               timingPriority: .maxTime) { [unowned self] (animator) in
            
            let toBounds = CGRect(x: 0,y: 0, width: closedConfigFrame.width, height: closedConfigFrame.height)
            let toPosition = CGPoint(x: closedConfigFrame.midX, y: closedConfigFrame.midY)
            
            animator.bounds(toBounds).duration(0.8).easing(.inOutExponential)
            animator.position(toPosition).duration(0.8).easing(.inOutExponential).primary(true)
            
            animator.triggerOnProgress(0.2, onView: self.dimmerView, animator: {  (animator) in
                animator.alpha(0.0).duration(0.8).easing(.inOutExponential)
                animator.backgroundColor(UIColor.clear.cgColor).duration(0.6).easing(.linear)
                
                animator.setDidStopCallback({ (animation) in
                    self.presentingViewController?.dismiss(animated: false, completion: { })
                })
            })
                              
        }
    }
    
    func layoutInterface() {
        dimmerView.frame = view.bounds
        
        containerView.frame = CGRect(x: 20, y:  self.view.bounds.height + (UIScreen.main.bounds.height == 812.0 ? 40 : 20),
                                       width: self.view.bounds.width - 40,
                                       height: self.view.bounds.height - (UIScreen.main.bounds.height == 812.0 ? 80 : 40))
        
        titleLabel.alignWithSize(CGSize(width: self.containerView.bounds.width - 32, height: 24),
                                 toFrame:  self.containerView.bounds,
                                 horizontal: HGHorizontalAlign.leftEdge,
                                 vertical: HGVerticalAlign.top,
                                 horizontalOffset:  16,
                                 verticalOffset: 10)
        
        segnmentedControl.sizeToFit()
        segnmentedControl.alignWithSize(CGSize(width:  self.containerView.bounds.width - 32, height: segnmentedControl.bounds.height),
                                 toFrame: titleLabel.frame,
                                 horizontal: HGHorizontalAlign.leftEdge,
                                 vertical: HGVerticalAlign.below,
                                 verticalOffset : 10)
  
        secondSeparator.alignWithSize(CGSize(width:  self.containerView.bounds.width, height: 1),
                                        toFrame: segnmentedControl.frame,
                                        horizontal: HGHorizontalAlign.center,
                                        vertical: HGVerticalAlign.below,
                                        verticalOffset :14)
        
        contentCollectionView.alignWithSize(CGSize(width:  self.containerView.bounds.width, height: 296),
                                      toFrame: secondSeparator.frame,
                                      horizontal: HGHorizontalAlign.center,
                                      vertical: HGVerticalAlign.below,
                                      verticalOffset : 0)
        
        
        separator.alignWithSize(CGSize(width:  self.containerView.bounds.width, height: 1),
                                      toFrame: contentCollectionView.frame,
                                      horizontal: HGHorizontalAlign.center,
                                      vertical: HGVerticalAlign.below,
                                      verticalOffset :0)
        
        backgroundView.frame =  self.containerView.bounds

    
        enableSecondaryViewLabel.alignWithSize(CGSize(width:  self.containerView.bounds.width - 32, height: 24),
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
        delaySegnmentedControl.alignWithSize(CGSize(width:  self.containerView.bounds.width - 32, height: delaySegnmentedControl.bounds.height),
                                        toFrame: atProgressLabel.frame,
                                        horizontal: HGHorizontalAlign.leftEdge,
                                        vertical: HGVerticalAlign.below,
                                        verticalOffset : 16)
        
        
        progressTriggerSlider.alignWithSize(CGSize(width: delaySegnmentedControl.bounds.width, height: progressTriggerSlider.bounds.height),
                                             toFrame: delaySegnmentedControl.frame,
                                             horizontal: HGHorizontalAlign.leftEdge,
                                             vertical: HGVerticalAlign.below,
                                             verticalOffset : 30)
        
        var adjustedPosition = enableSecondaryViewLabel.center
        adjustedPosition.y =  adjustedPosition.y + 14
        
        enableSecondaryViewLabel.center = adjustedPosition
        
        closeButton.alignWithSize(CGSize(width: 200, height: 44),
                                  toFrame: containerView.bounds,
                                  horizontal: HGHorizontalAlign.center,
                                  vertical: HGVerticalAlign.base,
                                  verticalOffset : (UIScreen.main.bounds.height == 812.0 ? -20 : -6.0))
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
    
    @objc func changedPriority(_ segmentedControl : UISegmentedControl) {
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
        flowLayout.itemSize = CGSize(width: 340, height: 74)
        var tempCollectionView : UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout :flowLayout)
     //   tempCollectionView.isAccessibilityElement = true
        tempCollectionView.accessibilityLabel = "CollectionView"
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
    
    lazy var closeButton: UIButton = {
        var button = UIButton()
        button.imageEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20)
        button.setTitle("▼", for: UIControlState())
        button.backgroundColor = UIColor.clear
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.addTarget(self, action: #selector(ConfigurationView.tappedCloseConfig), for: .touchUpInside)
        return button
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
        tempSwitch.isAccessibilityElement = true
        tempSwitch.isOn = false
        tempSwitch.accessibilityLabel = "EnableSecondarySwitch"
        tempSwitch.isAccessibilityElement = true
        tempSwitch.backgroundColor = UIColor.clear
        tempSwitch.addTarget(self, action: #selector(ConfigurationView.secondary_view_value_changed(_:)), for: UIControlEvents.valueChanged)
        return tempSwitch
    }()
    
    lazy var progressTriggerSlider : UISlider = {
        var slider = UISlider(frame:CGRect(x: 20, y: 260, width: 280, height: 20))
         slider.accessibilityLabel = "SecondaryProgressSlider"
        slider.isAccessibilityElement = true
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.tintColor = UIColor.green
        slider.value = 0
        slider.alpha = 0.0
        slider.addTarget(self, action: #selector(ConfigurationView.progress_value_changed(_:)), for: .valueChanged)
        return slider
    }()
    
    lazy var dimmerView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.black
        view.alpha = 0.0
        return view
    }()
    
    lazy var containerView: UIView = {
        var view = UIView()
        return view
    }()
    
    @objc func progress_value_changed(_ sender : UISlider) {
        
        let y = round(100 * sender.value) / 100
        progressLabel.text = String(format: "%.2f", y)
        self.interactionDelegate?.didUpdateTriggerProgressPriority(CGFloat(sender.value))
    }
    
    @objc func changedTrigger(_ segmentedControl : UISegmentedControl) {
        
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
    
    
    @objc func secondary_view_value_changed(_ sender : UISwitch) {
       
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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

