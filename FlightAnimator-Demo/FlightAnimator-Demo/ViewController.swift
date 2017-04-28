import Foundation
import UIKit

class ViewController: UIViewController {
    
    var animConfig = AnimationConfiguration()
    
    static let quareEdgeLength = (UIScreen.main.bounds.width / 3.0) //- 102.0) / 4.0
    let buttonSize = CGSize(width: quareEdgeLength, height: quareEdgeLength)
    
    var panRecognizer : UIPanGestureRecognizer?
    var initialCenter : CGPoint = CGPoint.zero
    var lastToFrame  = CGRect.zero
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupInterface()
        layoutInterface()
    }
    
    func setupInterface() {
        panRecognizer = UIPanGestureRecognizer(target:self, action: #selector(ViewController.respondToPanRecognizer(_:)))
        dragView.addGestureRecognizer(panRecognizer!)
        
        gradient.colors = [ UIColor(rgba: "#007368").cgColor, UIColor(rgba: "#00a781").cgColor]
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
        configView.frame = CGRect(x: 20, y: self.view.bounds.height + 20, width: self.view.bounds.width - 40, height: self.view.bounds.height - 40)
        closeButton.alignWithSize(CGSize(width: 200, height: 50),
                                  toFrame: configView.bounds,
                                  horizontal: HGHorizontalAlign.center,
                                  vertical: HGVerticalAlign.base,
                                  verticalOffset : 0)
        
        let animateTopButtonSize = CGSize(width: UIScreen.main.bounds.width - 100, height: 50)
        
        topLeftButton.alignWithSize(buttonSize,
                                    toFrame: view.bounds,
                                    horizontal: HGHorizontalAlign.leftEdge,
                                    vertical: HGVerticalAlign.top)
        
        topCenterButton.alignWithSize(buttonSize,
                                      toFrame: view.bounds,
                                      horizontal: HGHorizontalAlign.center,
                                      vertical: HGVerticalAlign.top)
        topRightButton.alignWithSize(buttonSize,
                                     toFrame: view.bounds,
                                     horizontal: HGHorizontalAlign.rightEdge,
                                     vertical: HGVerticalAlign.top)
        
        centerLeftButton.alignWithSize(buttonSize,
                                       toFrame: topLeftButton.frame,
                                       horizontal: HGHorizontalAlign.center,
                                       vertical: HGVerticalAlign.below)
        
        centerCenterButton.alignWithSize(buttonSize,
                                         toFrame: topCenterButton.frame,
                                         horizontal: HGHorizontalAlign.center,
                                         vertical: HGVerticalAlign.below)
        
        centerRightButton.alignWithSize(buttonSize,
                                        toFrame: topRightButton.frame,
                                        horizontal: HGHorizontalAlign.center,
                                        vertical: HGVerticalAlign.below)
        
        bottomLeftButton.alignWithSize(buttonSize,
                                       toFrame: centerLeftButton.frame,
                                       horizontal: HGHorizontalAlign.center,
                                       vertical: HGVerticalAlign.below)
        
        bottomCenterButton.alignWithSize(buttonSize,
                                         toFrame: centerCenterButton.frame,
                                         horizontal: HGHorizontalAlign.center,
                                         vertical: HGVerticalAlign.below)
        
        bottomRightButton.alignWithSize(buttonSize,
                                        toFrame: centerRightButton.frame,
                                        horizontal: HGHorizontalAlign.center,
                                        vertical: HGVerticalAlign.below)
        
        animateToBottomButton.alignWithSize(animateTopButtonSize,
                                            toFrame:view.bounds,
                                            horizontal: HGHorizontalAlign.leftEdge,
                                            vertical: HGVerticalAlign.base,
                                            horizontalOffset: 0)
        
        animateToTopButton.alignWithSize(animateTopButtonSize,
                                         toFrame: animateToBottomButton.frame,
                                         horizontal: HGHorizontalAlign.leftEdge,
                                         vertical: HGVerticalAlign.above,
                                         horizontalOffset: 0)
        
        let bottomBottomSize = CGSize(width: 212, height: 212)
        
        bottomBottomCenterButton.alignWithSize(bottomBottomSize,
                                               toFrame: animateToTopButton.frame,
                                               horizontal: HGHorizontalAlign.center,
                                               vertical: HGVerticalAlign.above,
                                               horizontalOffset: 50)
        
        bottomBottomLeftButton.alignWithSize(buttonSize,
                                             toFrame: animateToTopButton.frame,
                                             horizontal: HGHorizontalAlign.leftEdge,
                                             vertical: HGVerticalAlign.above,
                                             horizontalOffset:0)
        
        
        
        settingsButton.alignWithSize(CGSize(width: 100, height: 100),
                                     toFrame: animateToTopButton.frame,
                                     horizontal: HGHorizontalAlign.right,
                                     vertical: HGVerticalAlign.top)
        
        bottomBottomRightButton.alignWithSize(buttonSize,
                                              toFrame: settingsButton.frame,
                                              horizontal: HGHorizontalAlign.rightEdge,
                                              vertical: HGVerticalAlign.above,
                                              horizontalOffset: 0)
        
        dragView.frame = topCenterButton.frame
        dragView2.frame = bottomCenterButton.frame
        
        lastToFrame = dragView.frame
        separator.alignWithSize(CGSize(width: view.bounds.width, height: 1),
                                toFrame: bottomCenterButton.frame,
                                horizontal: HGHorizontalAlign.center,
                                vertical: HGVerticalAlign.below,
                                verticalOffset :0)
        
        titleLabel.alignWithSize(CGSize(width: 300, height: 50),
                                 toFrame: separator.frame,
                                 horizontal: HGHorizontalAlign.center,
                                 vertical: HGVerticalAlign.center,
                                 verticalOffset : 120)
        
        
        
    }
    
    func respondToPanRecognizer(_ recognizer : UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            self.initialCenter = self.dragView.center
            dragView.layer.removeAllAnimations()
        case .changed:
            let translationPoint = recognizer.translation(in: view)
            var adjustedCenter = self.initialCenter
            adjustedCenter.y += translationPoint.y
            adjustedCenter.x += translationPoint.x
            self.dragView.center = adjustedCenter
        case .ended:
            let finalFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 240)
            let currentVelocity = recognizer.velocity(in: view)
            
            finalizePanAnimation(finalFrame, velocity: currentVelocity)
            lastToFrame = finalFrame
        default:
            break
        }
    }
    
    lazy var separator: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    lazy var dragView: UIView = {
        var view = UIView(frame : CGRect.zero)
        view.alpha = 1.0
        view.backgroundColor = UIColor(rgba: "#006258")
        return view
    }()
    
    lazy var dragView2: UIView = {
        var view = UIView(frame : CGRect.zero)
        view.alpha = 0.0
        view.isHidden =  true
        view.backgroundColor = UIColor(rgba: "#006258")
        return view
    }()
    
    lazy var settingsButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(named:"settingsIcon"), for: UIControlState())
        button.imageEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20)
        button.backgroundColor = UIColor(rgba: "#2364c6")
        button.addTarget(self, action: #selector(ViewController.tappedShowConfig), for: .touchUpInside)
        return button
    }()
    
    lazy var closeButton: UIButton = {
        var button = UIButton()
        button.imageEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20)
        button.setTitle("▼", for: UIControlState())
        button.backgroundColor = UIColor.clear
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.addTarget(self, action: #selector(ViewController.tappedCloseConfig), for: .touchUpInside)
        return button
    }()
    
    lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.white
        label.text = "Panable Area\n\nTap here to pan view"
        label.backgroundColor = UIColor.clear
        label.font = UIFont(name: "Helvetica", size: 13)
        label.textAlignment = .center
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
        let button = UIButton(type: .custom)
        button.setTitle("   ▲      Top and Expand                  ".uppercased(), for: UIControlState())
        
        button.backgroundColor = UIColor(rgba: "#2364c6")
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont(name: "Helvetica", size: 11)
        button.titleLabel?.numberOfLines = 3
        button.titleLabel?.textAlignment = .left
        button.showsTouchWhenHighlighted = true
        button.addTarget(self, action:  #selector(ViewController.animateToTop), for: .touchUpInside)
        return button
    }()
    
    lazy var animateToBottomButton: UIButton = {
        
        let button = UIButton(type: .custom)
        button.setTitle("   ▼      Bottom and Expand          ".uppercased(), for: UIControlState())
        
        button.backgroundColor = UIColor(rgba: "#2364c6")
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont(name: "Helvetica", size: 11)
        button.titleLabel?.numberOfLines = 3
        button.titleLabel?.textAlignment = .left
        button.showsTouchWhenHighlighted = true
        button.addTarget(self, action:  #selector(ViewController.animateToBottom), for: .touchUpInside)
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
    
    func newButton(withTitle title : String , action: Selector, backgroundColor : UIColor = UIColor.clear, textColor : UIColor = UIColor.white) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: UIControlState())
        
        button.backgroundColor = backgroundColor
        button.setTitleColor(textColor, for: UIControlState())
        button.titleLabel?.font = UIFont(name: "Helvetica", size: 11)
        button.titleLabel?.numberOfLines = 3
        button.titleLabel?.textAlignment = .center
        button.showsTouchWhenHighlighted = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    lazy var gradient: CAGradientLayer = {
        return CAGradientLayer()
    }()
    
    lazy var configView: ConfigurationView = {
        var view = ConfigurationView()
        view.interactionDelegate = self
        view.cellDelegate = self
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 4.0
        view.alpha = 1.0
        return view
    }()
    
    lazy var dimmerView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.black
        view.alpha = 0.0
        return view
    }()
}

extension ViewController {
    
    func animateToTop() {
        let finalFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 240)
        animateView(finalFrame)
    }
    
    func animateToBottom() {
        let bottomButtonOffset : CGFloat = 100.0
        let finalFrame = CGRect(x: 0, y: UIScreen.main.bounds.height - 240.0 - bottomButtonOffset, width: UIScreen.main.bounds.width, height: 240)
        animateView(finalFrame)
    }
    
    func degree2radian(_ a:CGFloat)->CGFloat {
        let b = CGFloat(Double.pi) * a/180
        return b
    }
    
    func toButtonRect(_ sender : UIButton) {
        animateView(sender.frame)
    }
    
    func topRight(_ sender : UIButton) {
        animateView(sender.frame)
    }
    
    func topLeft(_ sender : UIButton) {
        animateView(sender.frame, toAlpha : 0.0)
    }
    
    func topCenter(_ sender : UIButton) {
        animateView(sender.frame)
    }
    
    func centerRight(_ sender : UIButton) {
        animateView(sender.frame)
    }
    
    func centerLeft(_ sender : UIButton) {
        animateView(sender.frame)
    }
    
    func centerCenter(_ sender : UIButton) {
        let initialFrame = sender.frame
        
        let initialTransform = CATransform3DIdentity
        let scaledTransform  = CATransform3DScale(initialTransform, 0.5, 0.5, 1.0)
        let rotateTransform  =  CATransform3DRotate(scaledTransform, degree2radian(45), 0.0, 0.0, 1.0)
        
        animateView(initialFrame, transform : rotateTransform)
    }
    
    func bottomRight(_ sender : UIButton) {
        animateView(sender.frame)
    }
    
    func bottomLeft(_ sender : UIButton) {
        animateView(sender.frame)
    }
    
    func bottomCenter(_ sender : UIButton) {
        animateView(sender.frame)
    }
    
}

extension ViewController : ConfigurationViewDelegate, CurveCollectionViewCellDelegate {
    
    func didUpdateTriggerType(_ type : Int) {
        animConfig.triggerType = type
    }
    
    func didUpdateTriggerProgressPriority(_ progress : CGFloat) {
        animConfig.triggerProgress = progress
    }
    
    func selectedTimingPriority(_ priority : FAPrimaryTimingPriority) {
        animConfig.primaryTimingPriority = priority
    }
    
    func cell(_ cell : CurveSelectionCollectionViewCell , didSelectEasing function: FAEasing) {
        if let index = self.configView.contentCollectionView.indexPath(for: cell) {
            switch (index as NSIndexPath).row {
            case 0:
                // size
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
    
    func currentPrimaryValue(_ cell : CurveSelectionCollectionViewCell) -> Bool {
        if let index = self.configView.contentCollectionView.indexPath(for: cell) {
            switch (index as NSIndexPath).row {
            case 0:
                // size
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
    
    
    func currentEAsingFuntion(_ cell : CurveSelectionCollectionViewCell) -> FAEasing {
        if let index = self.configView.contentCollectionView.indexPath(for: cell) {
            switch (index as NSIndexPath).row {
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
        
        return .linear
    }
    
    
    func cell(_ cell : CurveSelectionCollectionViewCell , didSelectPrimary isPrimary : Bool) {
        if let index = self.configView.contentCollectionView.indexPath(for: cell) {
            switch (index as NSIndexPath).row {
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
    
    
    func currentPrimaryFlagValue(_ atIndex : Int) -> Bool {
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
    
    func currentEAsingFuntion(_ atIndex : Int) -> FAEasing {
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
    
    func configCellDidSelectEasingFuntion(_ function: FAEasing, propertyType : PropertyConfigType, functionTitle: String) {
        
        switch propertyType {
        case .bounds:
            animConfig.sizeFunction = function
        case .position:
            animConfig.positionFunction = function
        case .alpha:
            animConfig.alphaFunction = function
        case .transform:
            animConfig.transformFunction = function
        }
    }
    
    func toggleSecondaryView(_ enabled : Bool) {
        self.animConfig.enableSecondaryView = enabled
        
        self.dragView2.alpha = enabled ? 1.0 : 0.0
        self.dragView2.isHidden = !enabled
    }
    
    func primaryValueFor(_ propertyType : PropertyConfigType) -> Bool {
        switch propertyType {
        case .bounds:
            return animConfig.sizePrimary
        case .position:
            return animConfig.positionPrimary
        case .alpha:
            return animConfig.alphaPrimary
        case .transform:
            return animConfig.transformPrimary
        }
    }
}
