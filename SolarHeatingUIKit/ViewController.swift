 //
 //  ViewController.swift
 //  SolarHeatingUIKit
 //
 //  Created by Greg Hughes on 1/16/21.
 //
 
 import UIKit
 import Combine
 class ViewController: UIViewController {
    
    @IBOutlet weak var lowerPipe: UIView!
    @IBOutlet weak var waterTank: UIView!
    @IBOutlet weak var hotWaterLvl: UIView!
    @IBOutlet weak var solarPanel: UIView!
    @IBOutlet weak var topPipe: UIView!
    @IBOutlet weak var sunnyLabel: UILabel!
    @IBOutlet weak var hotWaterView: UIView!
    @IBOutlet weak var coldWaterView: UIView!
    @IBOutlet weak var homeHotWaterView: UIView!
    @IBOutlet weak var homeColdeWaterView: UIView!
    
    var sunnyLabelText = "Sunny" {
        didSet {
            sunnyLabel.text = sunnyLabelText
            startStopAnimations()
        }
    }
    
    let dayText = "Sunny"
    let nightText = "Not Sunny"
    var isHotEnoughSender = PassthroughSubject<Bool,Never>()
    var isHotEnough = true
    var hotFluidViews = [SolarFluidView]()
    var hotWaterCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func setup() {
        startSunnyTimer()
        sunnyLabel.text = sunnyLabelText
        animateWaterTOBuilding()
        animateWaterFROMBuilding()
        fillWaterTankHot()
    }
    /// Starts and stops animations based on whether dayNightLabelText == "Sunny" or "Not Sunny"
    func startStopAnimations() {
        isHotEnough.toggle()
        if isHotEnough {
            reAnimateViews()
            fillWaterTankHot()
            animateWaterTOBuilding()
            animateWaterFROMBuilding()
        }else {
            hotFluidViews.forEach({$0.isHotEnough.toggle()})
            fillWaterTankCold()
        }
    }
    /// Creates and begins the animation of the Solar Liquid Views
    func createAndAnimate() {
        
        _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {[weak self] (timer) in
            guard let strongSelf = self else {return}
            if strongSelf.hotWaterCounter == 6 {
                timer.invalidate()
                strongSelf.hotWaterCounter = 0
            }
            
            let view = SolarFluidView(width: 25, height: 25, isHotEnoughPublisher: strongSelf.isHotEnoughSender, lowerPipe: strongSelf.lowerPipe, waterTank: strongSelf.waterTank, solarPanel: strongSelf.solarPanel, topPipe: strongSelf.topPipe)
            
            view.backgroundColor = .red
            strongSelf.view.addSubview(view)
            view.center = CGPoint(x: strongSelf.solarPanel.center.x, y: strongSelf.topPipe.center.y)
            
            view.animateSolarFluidView(lowerPipe: strongSelf.lowerPipe, waterTank: strongSelf.waterTank, solarPanel: strongSelf.solarPanel, topPipe: strongSelf.topPipe)
            strongSelf.hotWaterCounter += 1
            strongSelf.hotFluidViews.append(view)
            
        }
    }
    /// Timer which determines whether dayNightLabelText == "Sunny" or "Not Sunny"
    func startSunnyTimer(){
        _ = Timer.scheduledTimer(withTimeInterval: 15, repeats: true, block: { (timer) in
            if self.sunnyLabelText == self.nightText {
                self.sunnyLabelText = self.dayText
            } else {
                self.sunnyLabelText = self.nightText
            }
            
        })
        createAndAnimate()
    }
    
    /// Begins animation of the Solar Fluids when dayNightLabelText is set to "Sunny"
    func reAnimateViews() {
        var viewCounter = 0
        _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {[weak self] (timer) in
            self?.hotFluidViews[viewCounter].isHotEnough.toggle()
            viewCounter += 1
            if viewCounter == self?.hotFluidViews.count {
                timer.invalidate()
            }
        }
    }
    
    /// Animated the hot water going to the building when isHotEnough = true
    func animateWaterTOBuilding() {
        _ = Timer.scheduledTimer(withTimeInterval: 4, repeats: true, block: { (timer) in
            if self.isHotEnough {
                let view = HotWaterToHouseView()
                view.frame.size = CGSize(width: 25, height: 25)
                
                let fromPoint = CGPoint(x: self.waterTank.center.x + (self.waterTank.frame.width / 2), y: self.homeHotWaterView.center.y)
                
                let toPoint = CGPoint(x: fromPoint.x + self.homeHotWaterView.frame.width, y: self.homeHotWaterView.center.y)
                
                view.animateHotWater(superview: self.view, from: fromPoint, to: toPoint)
            }else {
                timer.invalidate()
            }
        })
    }
    /// Animated the cold water going from the building when isHotEnough = true
    func animateWaterFROMBuilding() {
        _ = Timer.scheduledTimer(withTimeInterval: 4, repeats: true, block: { [weak self] (timer) in
            guard let strongseSelf = self else {return}
            if strongseSelf.isHotEnough {
                let view = ColdWaterFromHouseView()
                view.frame.size = CGSize(width: 25, height: 25)
                
                let fromPoint =
                    CGPoint(
                        x: strongseSelf.waterTank.center.x + ((strongseSelf.waterTank.frame.width / 2) + strongseSelf.homeColdeWaterView.frame.width),
                        y: strongseSelf.homeColdeWaterView.center.y)
                
                let toPoint = CGPoint(x: strongseSelf.waterTank.center.x + (strongseSelf.waterTank.frame.width / 2), y: strongseSelf.homeColdeWaterView.center.y)
                
                view.animateColdWater(superview: strongseSelf.view, from: fromPoint, to: toPoint)
            }else {
                timer.invalidate()
            }
        })
    }
    
    /// Turns the Hot water in the water tank blue, if isHotEnough == false
    func fillWaterTankCold() {
        UIView.animate(withDuration: 6, delay: 2) {
            self.hotWaterView.backgroundColor = self.coldWaterView.backgroundColor
        }
        
    }
    /// Turns the Hot water in the water tank red, if isHotEnough == true
    func fillWaterTankHot() {
        UIView.animate(withDuration: 6, delay: 2) {
            self.hotWaterView.backgroundColor = .red
        }
    }
 }
 /// The hot water coming from the building to the water tank
 class HotWaterToHouseView: UIView {
    func animateHotWater(superview: UIView, from: CGPoint, to: CGPoint) {
        self.backgroundColor = .red
        superview.addSubview(self)
        self.center = from
        UIView.animate(withDuration: 2) {
            self.center = to
        } completion: { (_) in
            self.removeFromSuperview()
        }
    }
 }
 /// The cold water coming from the building to the water tank
 class ColdWaterFromHouseView: UIView {
    
    func animateColdWater(superview: UIView, from: CGPoint, to: CGPoint) {
        self.backgroundColor = .blue
        superview.addSubview(self)
        self.center = from
        UIView.animate(withDuration: 2) {
            self.center = to
        } completion: { (_) in
            self.removeFromSuperview()
        }
    }
 }
 
 /// View that represents the solar fluid.. these are the ones that move between the water tank and the solar panel
 class SolarFluidView: UIView {
    
    let lowerPipe: UIView
    let waterTank: UIView
    let solarPanel: UIView
    let topPipe: UIView
    var isHotEnoughPublisher : PassthroughSubject<Bool,Never>
    var cancellable : AnyCancellable?
    ///Used to determine whether the animations should repeat or not
    var isHotEnough = true {
        didSet {
            if isHotEnough {
                animateSolarFluidView(lowerPipe: lowerPipe, waterTank: waterTank, solarPanel: solarPanel, topPipe: topPipe)
            }
        }
    }
    /// Used to make the animations repeat
    var isRunning = true {
        didSet {
            if isRunning {
                animateSolarFluidView(lowerPipe: lowerPipe, waterTank: waterTank, solarPanel: solarPanel, topPipe: topPipe)
            }
        }
    }
    
    init(width: Int, height: Int, isHotEnoughPublisher: PassthroughSubject<Bool,Never>, lowerPipe: UIView,waterTank: UIView,  solarPanel: UIView, topPipe: UIView) {
        
        self.lowerPipe = lowerPipe
        self.waterTank = waterTank
        self.solarPanel = solarPanel
        self.topPipe = topPipe
        self.isHotEnoughPublisher = isHotEnoughPublisher
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        cancellable = isHotEnoughPublisher.sink { (bool) in
            self.isHotEnough.toggle()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// Animated the solar fluid View
    func animateSolarFluidView(lowerPipe: UIView,waterTank: UIView, solarPanel: UIView, topPipe: UIView) {
        
        guard isRunning && isHotEnough else { backgroundColor = .blue; return}
        backgroundColor = .red
        
        UIView.animate(withDuration: 2, delay: 0, options: []) {
            self.center.x = waterTank.center.x
            
        } completion: {[weak self] (done) in
            UIView.animate(withDuration: 5, delay: 0, options: []) {
                self?.center.y =  lowerPipe.center.y
                self?.backgroundColor = .blue
            } completion: { (Bool) in
                UIView.animate(withDuration: 2, delay: 0, options: []) {
                    self?.center.x =  solarPanel.center.x
                    self?.backgroundColor = .blue
                } completion: { (Bool) in
                    UIView.animate(withDuration: 5, delay: 0, options: []) {
                        self?.center.y = topPipe.center.y
                        if self?.isHotEnough ?? false {
                            self?.backgroundColor = .red
                        }
                    } completion: { (Bool) in
                        self?.isRunning = true
                    }
                }
            }
        }
    }
 }
