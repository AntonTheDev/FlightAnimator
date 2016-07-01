import Foundation
import UIKit

class ViewController: UIViewController {
    
    var animConfig = AnimationConfiguration()
    
    static let quareEdgeLength = (UIScreen.mainScreen().bounds.width / 3.0) //- 102.0) / 4.0
    let buttonSize = CGSizeMake(quareEdgeLength, quareEdgeLength)
    
    var panRecognizer : UIPanGestureRecognizer?
    var initialCenter : CGPoint = CGPointZero
    var lastToFrame  = CGRectZero
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupInterface()
        layoutInterface()
    }
    
    func setupInterface() {
        panRecognizer = UIPanGestureRecognizer(target:self, action: #selector(ViewController.respondToPanRecognizer(_:)))
        dragView.addGestureRecognizer(panRecognizer!)
        
        gradient.colors = [ UIColor(rgba: "#007368").CGColor, UIColor(rgba: "#00a781").CGColor]
        gradient.frame = view.bounds
        
        view.layer.addSublayer(gradient)
   
        view.addSubview(bottomBottomLeftButton)
        view.addSubview(bottomBottomCenterButton)
        view.addSubview(bottomBottomRightButton)
        view.addSubview(separator)
        view.addSubview(titleLabel)
        view.addSubview(dragView)
        view.addSubview(dragView2)
        view.addSubview(animateToTopButton)
        view.addSubview(animateToBottomButton)
        view.addSubview(bottomCenterButton)
        view.addSubview(topLeftButton)
        view.addSubview(topRightButton)
        view.addSubview(centerLeftButton)
        view.addSubview(centerRightButton)
        view.addSubview(bottomLeftButton)
        view.addSubview(bottomRightButton)
        view.addSubview(centerCenterButton)
        view.addSubview(topCenterButton)
        view.addSubview(settingsButton)
        view.addSubview(dimmerView)
        view.addSubview(configView)
        configView.addSubview(closeButton)
        dimmerView.alpha = 0.0
        registerConfigViewAnimations()
    }
    
    func layoutInterface() {
 
        dimmerView.frame = view.bounds
        configView.frame = CGRectMake(20, self.view.bounds.height + 20, self.view.bounds.width - 40, self.view.bounds.height - 40)
        closeButton.alignWithSize(CGSizeMake(200, 50),
                                  toFrame: configView.bounds,
                                  horizontal: HGHorizontalAlign.Center,
                                  vertical: HGVerticalAlign.Base,
                                  verticalOffset : 0)
        
        let animateTopButtonSize = CGSizeMake(UIScreen.mainScreen().bounds.width - 100, 50)
        
        topLeftButton.alignWithSize(buttonSize,
                                    toFrame: view.bounds,
                                    horizontal: HGHorizontalAlign.LeftEdge,
                                    vertical: HGVerticalAlign.Top)
        
        topCenterButton.alignWithSize(buttonSize,
                                      toFrame: view.bounds,
                                      horizontal: HGHorizontalAlign.Center,
                                      vertical: HGVerticalAlign.Top)
        topRightButton.alignWithSize(buttonSize,
                                     toFrame: view.bounds,
                                     horizontal: HGHorizontalAlign.RightEdge,
                                     vertical: HGVerticalAlign.Top)
        
        centerLeftButton.alignWithSize(buttonSize,
                                       toFrame: topLeftButton.frame,
                                       horizontal: HGHorizontalAlign.Center,
                                       vertical: HGVerticalAlign.Below)
        
        centerCenterButton.alignWithSize(buttonSize,
                                         toFrame: topCenterButton.frame,
                                         horizontal: HGHorizontalAlign.Center,
                                         vertical: HGVerticalAlign.Below)
        
        centerRightButton.alignWithSize(buttonSize,
                                        toFrame: topRightButton.frame,
                                        horizontal: HGHorizontalAlign.Center,
                                        vertical: HGVerticalAlign.Below)
        
        bottomLeftButton.alignWithSize(buttonSize,
                                       toFrame: centerLeftButton.frame,
                                       horizontal: HGHorizontalAlign.Center,
                                       vertical: HGVerticalAlign.Below)
        
        bottomCenterButton.alignWithSize(buttonSize,
                                         toFrame: centerCenterButton.frame,
                                         horizontal: HGHorizontalAlign.Center,
                                         vertical: HGVerticalAlign.Below)
        
        bottomRightButton.alignWithSize(buttonSize,
                                        toFrame: centerRightButton.frame,
                                        horizontal: HGHorizontalAlign.Center,
                                        vertical: HGVerticalAlign.Below)
        
        animateToBottomButton.alignWithSize(animateTopButtonSize,
                                            toFrame:view.bounds,
                                            horizontal: HGHorizontalAlign.LeftEdge,
                                            vertical: HGVerticalAlign.Base,
                                            horizontalOffset: 0)
        
        animateToTopButton.alignWithSize(animateTopButtonSize,
                                         toFrame: animateToBottomButton.frame,
                                         horizontal: HGHorizontalAlign.LeftEdge,
                                         vertical: HGVerticalAlign.Above,
                                         horizontalOffset: 0)
        
        let bottomBottomSize = CGSizeMake(212, 212)
        
        bottomBottomCenterButton.alignWithSize(bottomBottomSize,
                                               toFrame: animateToTopButton.frame,
                                               horizontal: HGHorizontalAlign.Center,
                                               vertical: HGVerticalAlign.Above,
                                               horizontalOffset: 50)
        
        bottomBottomLeftButton.alignWithSize(buttonSize,
                                             toFrame: animateToTopButton.frame,
                                             horizontal: HGHorizontalAlign.LeftEdge,
                                             vertical: HGVerticalAlign.Above,
                                             horizontalOffset:0)
        
     
 
        settingsButton.alignWithSize(CGSizeMake(100, 100),
                                     toFrame: animateToTopButton.frame,
                                     horizontal: HGHorizontalAlign.Right,
                                     vertical: HGVerticalAlign.Top)
        
        bottomBottomRightButton.alignWithSize(buttonSize,
                                              toFrame: settingsButton.frame,
                                              horizontal: HGHorizontalAlign.RightEdge,
                                              vertical: HGVerticalAlign.Above,
                                              horizontalOffset: 0)
        
        dragView.frame = topCenterButton.frame
        dragView2.frame = bottomCenterButton.frame
        
        lastToFrame = dragView.frame
        separator.alignWithSize(CGSizeMake(view.bounds.width, 1),
                                toFrame: bottomCenterButton.frame,
                                horizontal: HGHorizontalAlign.Center,
                                vertical: HGVerticalAlign.Below,
                                verticalOffset :0)
        
        titleLabel.alignWithSize(CGSizeMake(300, 50),
                                  toFrame: separator.frame,
                                  horizontal: HGHorizontalAlign.Center,
                                  vertical: HGVerticalAlign.Center,
                                  verticalOffset : 120)
        

        
    }
    
    func respondToPanRecognizer(recognizer : UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            self.initialCenter = self.dragView.center
            dragView.layer.removeAllAnimations()
        case .Changed:
            let translationPoint = recognizer.translationInView(view)
            var adjustedCenter = self.initialCenter
            adjustedCenter.y += translationPoint.y
            adjustedCenter.x += translationPoint.x
            self.dragView.center = adjustedCenter
        case .Ended:
            let finalFrame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 240)
            let currentVelocity = recognizer.velocityInView(view)
            
            finalizePanAnimation(finalFrame, velocity: currentVelocity)
            lastToFrame = finalFrame
        default:
            break
        }
    }
    
    lazy var separator: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        return view
    }()
    
    lazy var dragView: UIView = {
        var view = UIView(frame : CGRectZero)
        view.alpha = 1.0
        view.backgroundColor = UIColor(rgba: "#006258")
        return view
    }()
    
    lazy var dragView2: UIView = {
        var view = UIView(frame : CGRectZero)
        view.alpha = 1.0
        view.backgroundColor = UIColor(rgba: "#006258")
        return view
    }()
    
    lazy var settingsButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(named:"settingsIcon"), forState: .Normal)
        button.imageEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20)
        button.backgroundColor = UIColor(rgba: "#2364c6")
        button.addTarget(self, action: #selector(ViewController.tappedShowConfig), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var closeButton: UIButton = {
        var button = UIButton()
        button.imageEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20)
        button.setTitle("▼", forState: .Normal)
        button.backgroundColor = UIColor.clearColor()
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.addTarget(self, action: #selector(ViewController.tappedCloseConfig), forControlEvents: .TouchUpInside)
        return button
    }()
        
    lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.whiteColor()
        label.text = "Panable Area\n\nTap here to pan view"
        label.backgroundColor = UIColor.clearColor()
        label.font = UIFont(name: "Helvetica", size: 13)
        label.textAlignment = .Center
        label.numberOfLines = 3
        return label
    }()
    
    lazy var topRightButton: UIButton = {
        return self.newButton(withTitle: "Top\nRight", action: #selector(ViewController.topRight))
    }()
    
    lazy var topCenterButton: UIButton = {
        return self.newButton(withTitle: "Top\nCenter", action: #selector(ViewController.toButtonRect))
    }()
    
    lazy var topLeftButton: UIButton = {
        return self.newButton(withTitle: "Top Left\n+\nAlpha", action: #selector(ViewController.topLeft))
    }()
    
    lazy var centerRightButton: UIButton = {
        return self.newButton(withTitle: "Center\nRight", action: #selector(ViewController.toButtonRect))
    }()
    
    lazy var centerCenterButton: UIButton = {
        return self.newButton(withTitle: "Center Center\n+\nTransform", action: #selector(ViewController.centerCenter))
    }()
    
    lazy var centerLeftButton: UIButton = {
        return self.newButton(withTitle: "Center\nLeft", action: #selector(ViewController.toButtonRect))
    }()
    
    lazy var bottomRightButton: UIButton = {
        return self.newButton(withTitle: "Bottom\nRight", action: #selector(ViewController.toButtonRect))
    }()
    
    lazy var bottomCenterButton: UIButton = {
        return self.newButton(withTitle: "Bottom\nCenter", action: #selector(ViewController.toButtonRect))
    }()
    
    lazy var bottomLeftButton: UIButton = {
        return self.newButton(withTitle: "Bottom\nLeft", action: #selector(ViewController.toButtonRect))
    }()
    
    lazy var animateToTopButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.setTitle("   ▲      Top and Expand                  ".uppercaseString, forState: .Normal)
        
        button.backgroundColor = UIColor(rgba: "#2364c6")
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = UIFont(name: "Helvetica", size: 11)
        button.titleLabel?.numberOfLines = 3
        button.titleLabel?.textAlignment = .Left
        button.showsTouchWhenHighlighted = true
        button.addTarget(self, action:  #selector(ViewController.animateToTop), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var animateToBottomButton: UIButton = {
        
        let button = UIButton(type: .Custom)
        button.setTitle("   ▼      Bottom and Expand          ".uppercaseString, forState: .Normal)
        
        button.backgroundColor = UIColor(rgba: "#2364c6")
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = UIFont(name: "Helvetica", size: 11)
        button.titleLabel?.numberOfLines = 3
        button.titleLabel?.textAlignment = .Left
        button.showsTouchWhenHighlighted = true
        button.addTarget(self, action:  #selector(ViewController.animateToBottom), forControlEvents: .TouchUpInside)
        return button
    }()

    
    lazy var bottomBottomCenterButton: UIButton = {
        return self.newButton(withTitle: "", action: #selector(ViewController.bottomCenter))
    }()
    
    lazy var bottomBottomLeftButton: UIButton = {
        return self.newButton(withTitle: "", action: #selector(ViewController.bottomCenter))
    }()
    
    lazy var bottomBottomRightButton: UIButton = {
        return self.newButton(withTitle: "", action: #selector(ViewController.bottomCenter))
    }()
    
    func newButton(withTitle title : String , action: Selector, backgroundColor : UIColor = UIColor.clearColor(), textColor : UIColor = UIColor.whiteColor()) -> UIButton {
        let button = UIButton(type: .Custom)
        button.setTitle(title, forState: .Normal)
        
        button.backgroundColor = backgroundColor
        button.setTitleColor(textColor, forState: .Normal)
        button.titleLabel?.font = UIFont(name: "Helvetica", size: 11)
        button.titleLabel?.numberOfLines = 3
        button.titleLabel?.textAlignment = .Center
        button.showsTouchWhenHighlighted = true
        button.addTarget(self, action: action, forControlEvents: .TouchUpInside)
        return button
    }
    
    lazy var gradient: CAGradientLayer = {
        return CAGradientLayer()
    }()
    
    lazy var configView: ConfigurationView = {
        var view = ConfigurationView()
        view.interactionDelegate = self
        view.cellDelegate = self
        view.layer.borderColor = UIColor.lightGrayColor().CGColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 4.0
        view.alpha = 1.0
        return view
    }()
    
    lazy var dimmerView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.blackColor()
        view.alpha = 0.0
        return view
    }()
}

extension ViewController {
    
    func animateToTop() {
        let finalFrame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 240)
        animateView(finalFrame)
    }
    
    func animateToBottom() {
        let bottomButtonOffset : CGFloat = 100.0
        let finalFrame = CGRectMake(0, UIScreen.mainScreen().bounds.height - 240.0 - bottomButtonOffset, UIScreen.mainScreen().bounds.width, 240)
        animateView(finalFrame)
    }
    
    func degree2radian(a:CGFloat)->CGFloat {
        let b = CGFloat(M_PI) * a/180
        return b
    }
    
    func toButtonRect(sender : UIButton) {
        animateView(sender.frame)
    }
    
    func topRight(sender : UIButton) {
        animateView(sender.frame)
    }
    
    func topLeft(sender : UIButton) {
        animateView(sender.frame, toAlpha : 0.0)
    }
    
    func topCenter(sender : UIButton) {
        animateView(sender.frame)
    }
    
    func centerRight(sender : UIButton) {
        animateView(sender.frame)
    }
    
    func centerLeft(sender : UIButton) {
        animateView(sender.frame)
    }
    
    func centerCenter(sender : UIButton) {
        let initialFrame = sender.frame
        
        let initialTransform = CATransform3DIdentity
        let scaledTransform  = CATransform3DScale(initialTransform, 0.5, 0.5, 1.0)
        let rotateTransform  =  CATransform3DRotate(scaledTransform, degree2radian(45), 0.0, 0.0, 1.0)
        
        animateView(initialFrame, transform : rotateTransform)
    }
    
    func bottomRight(sender : UIButton) {
        animateView(sender.frame)
    }
    
    func bottomLeft(sender : UIButton) {
        animateView(sender.frame)
    }
    
    func bottomCenter(sender : UIButton) {
        animateView(sender.frame)
    }
    
}


extension ViewController : ConfigurationViewDelegate, CurveCollectionViewCellDelegate {
    
    func selectedTimingPriority(priority : FAPrimaryTimingPriority) {
        animConfig.primaryTimingPriority = priority
    }
    
    func cell(cell : CurveSelectionCollectionViewCell , didSelectEasing function: FAEasing) {
        if let index = self.configView.contentCollectionView.indexPathForCell(cell) {
            switch index.row {
            case 0:
                //size
                animConfig.sizeFunction = function
            case 1:
                // position
                animConfig.positionFunction = function
            case 2:
                // alpha
                animConfig.alphaFunction = function
            default:
                // transform
                animConfig.transformFunction = function
            }
        }
    }
    
    func currentPrimaryValue(cell : CurveSelectionCollectionViewCell) -> Bool {
        if let index = self.configView.contentCollectionView.indexPathForCell(cell) {
            switch index.row {
            case 0:
                //size
                return animConfig.sizePrimary
            case 1:
                // position
                return animConfig.positionPrimary
            case 2:
                // alpha
                return animConfig.alphaPrimary
            default:
                // transform
                return animConfig.transformPrimary
            }
        }
        
        return false
    }
    
    
    func currentEAsingFuntion(cell : CurveSelectionCollectionViewCell) -> FAEasing {
        if let index = self.configView.contentCollectionView.indexPathForCell(cell) {
            switch index.row {
            case 0:
                //size
                return animConfig.sizeFunction
            case 1:
                // position
                return animConfig.positionFunction
            case 2:
                // alpha
                return animConfig.alphaFunction
            default:
                // transform
                return animConfig.transformFunction
            }
        }
        
        return .Linear
    }
    
    
    
    func cell(cell : CurveSelectionCollectionViewCell , didSelectPrimary isPrimary : Bool) {
        if let index = self.configView.contentCollectionView.indexPathForCell(cell) {
            switch index.row {
            case 0:
                //size
                animConfig.sizePrimary = isPrimary
            case 1:
                // position
                animConfig.positionPrimary = isPrimary
            case 2:
                // alpha
                animConfig.alphaPrimary = isPrimary
            default:
                // transform
                animConfig.transformPrimary = isPrimary
            }
        }
    }
    
    
    func currentPrimaryFlagValue(atIndex : Int) -> Bool {
        switch atIndex {
        case 0:
            //size
            return animConfig.sizePrimary
        case 1:
            // position
            return animConfig.positionPrimary
        case 2:
            // alpha
            return animConfig.alphaPrimary
        default:
            // transform
            return animConfig.transformPrimary
        }
    }
    func currentEAsingFuntion(atIndex : Int) -> FAEasing {
       switch atIndex {
            case 0:
                //size
                return animConfig.sizeFunction
            case 1:
                // position
                return animConfig.positionFunction
            case 2:
                // alpha
                return animConfig.alphaFunction
            default:
                // transform
                return animConfig.transformFunction
            }

    }
    
 
    func configCellDidSelectEasingFuntion(function: FAEasing, propertyType : PropertyConfigType, functionTitle: String) {
        
        switch propertyType {
        case .Bounds:
            animConfig.sizeFunction = function
        case .Position:
            animConfig.positionFunction = function
        case .Alpha:
            animConfig.alphaFunction = function
        case .Transform:
            animConfig.transformFunction = function
        }
    }
    
    func primaryValueFor(propertyType : PropertyConfigType) -> Bool {
        switch propertyType {
        case .Bounds:
            return animConfig.sizePrimary
        case .Position:
            return animConfig.positionPrimary
        case .Alpha:
            return animConfig.alphaPrimary
        case .Transform:
            return animConfig.transformPrimary
        }
    }
}