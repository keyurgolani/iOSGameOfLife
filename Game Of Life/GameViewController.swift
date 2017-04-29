//
//  ViewController.swift
//  Game Of Life
//
//  Created by Keyur Golani on 4/29/17.
//  Copyright © 2017 Keyur Golani. All rights reserved.
//

import UIKit

class GameViewController : UIViewController {
    
    fileprivate var unitLength : Int = 20
    fileprivate lazy var gameOfLife : GameModel = { GameModel(widthOfGrid: self.unitLength, heightOfGrid: self.unitLength) }()
    fileprivate lazy var gameView : GameView = { GameView(gameModel: self.gameOfLife) }()
    fileprivate var isPlaying = false
    fileprivate var framesPerSecond : Double = 3
    fileprivate var generationController : Timer?
    fileprivate let generationNumberLabel = UILabel()
    fileprivate let framesPerSecondLabel = UILabel()
    fileprivate let sizeOfGridLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        
        //model will handle view updates
        self.gameOfLife.generationWasBorn = { generationNumber in
            self.generationNumberLabel.text = "\(generationNumber)"
            self.gameView.setNeedsDisplay()
        }
    }
    
    fileprivate func configureView() {
        
        self.gameView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.backgroundColor = UIColor(rgb: 0xFFFFFF)
        
        self.view.addSubview(self.gameView)
        
        let gameOfLifeViewConstraints : [NSLayoutConstraint] = [
            self.gameView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            self.gameView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.gameView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.gameView.heightAnchor.constraint(equalTo: self.view.widthAnchor)
        ]
        
        self.view.addConstraints(gameOfLifeViewConstraints)
        
        let activitySwich = UISwitch()
        activitySwich.translatesAutoresizingMaskIntoConstraints = false
        
        activitySwich.addTarget(self, action: #selector(GameViewController.toggleActivity(_:)), for: .valueChanged)
        
        self.view.addSubview(activitySwich)
        
        let activitySwitchConstraints : [NSLayoutConstraint] = [
            activitySwich.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            activitySwich.topAnchor.constraint(equalTo: self.gameView.bottomAnchor, constant: 15)
        ]
        
        self.view.addConstraints(activitySwitchConstraints)
        
        let framesPerSecondSliderLabel = UILabel()
        
        framesPerSecondSliderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        framesPerSecondSliderLabel.text = "Frames per second: "
        framesPerSecondSliderLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightBold)
        framesPerSecondSliderLabel.numberOfLines = 0
        framesPerSecondSliderLabel.lineBreakMode = .byWordWrapping
        framesPerSecondSliderLabel.textAlignment = .center
        
        self.view.addSubview(framesPerSecondSliderLabel)
        
        let framesPerSecondSlider = UISlider()
        framesPerSecondSlider.translatesAutoresizingMaskIntoConstraints = false
        
        framesPerSecondSlider.minimumValue = 1
        framesPerSecondSlider.maximumValue = 50
        
        framesPerSecondSlider.value = Float(self.framesPerSecond)
        framesPerSecondSlider.addTarget(self, action: #selector(GameViewController.framesPerSecondChanged(_:)), for: .valueChanged)
        
        self.view.addSubview(framesPerSecondSlider)
        
        self.framesPerSecondLabel.translatesAutoresizingMaskIntoConstraints = false
        self.framesPerSecondLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightBold)
        self.framesPerSecondLabel.textAlignment = .center
        self.framesPerSecondLabel.text = "\(Int(self.framesPerSecond))"
        
        self.view.addSubview(self.framesPerSecondLabel)
        
        let framesPerSecondSliderLabelConstraints : [NSLayoutConstraint] = [
            framesPerSecondSliderLabel.centerYAnchor.constraint(equalTo: framesPerSecondSlider.centerYAnchor),
            framesPerSecondSliderLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 15),
            framesPerSecondSliderLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.2),
            framesPerSecondSliderLabel.heightAnchor.constraint(equalToConstant: 60)
        ]
        
        self.view.addConstraints(framesPerSecondSliderLabelConstraints)
        
        let framesPerSecondLabelConstraints : [NSLayoutConstraint] = [
            self.framesPerSecondLabel.centerYAnchor.constraint(equalTo: framesPerSecondSlider.centerYAnchor),
            self.framesPerSecondLabel.heightAnchor.constraint(equalTo: framesPerSecondSlider.heightAnchor),
            self.framesPerSecondLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -15),
            self.framesPerSecondLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.2)
        ]
        
        self.view.addConstraints(framesPerSecondLabelConstraints)
        
        let framesPerSecondSliderConstraints : [NSLayoutConstraint] = [
            framesPerSecondSlider.leftAnchor.constraint(equalTo: framesPerSecondSliderLabel.rightAnchor, constant: 15),
            framesPerSecondSlider.topAnchor.constraint(equalTo: activitySwich.bottomAnchor, constant: 15),
            framesPerSecondSlider.rightAnchor.constraint(equalTo: self.framesPerSecondLabel.leftAnchor, constant: -15),
            framesPerSecondSlider.heightAnchor.constraint(equalTo: framesPerSecondSliderLabel.heightAnchor)
        ]
        
        self.view.addConstraints(framesPerSecondSliderConstraints)
        
        let generationLabel = UILabel()
        generationLabel.translatesAutoresizingMaskIntoConstraints = false
        generationLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightBold)
        generationLabel.text = "Generation: "
        generationLabel.textAlignment = .center
        
        self.view.addSubview(generationLabel)
        
        self.generationNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        self.generationNumberLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightBold)
        self.generationNumberLabel.text = "0"
        self.generationNumberLabel.textAlignment = .center
        
        self.view.addSubview(self.generationNumberLabel)
        
        let generationNumberLabelConstraints : [NSLayoutConstraint] = [
            self.generationNumberLabel.leftAnchor.constraint(equalTo: generationLabel.rightAnchor),
            self.generationNumberLabel.rightAnchor.constraint(equalTo: activitySwich.leftAnchor, constant: -15),
            self.generationNumberLabel.topAnchor.constraint(equalTo: self.gameView.bottomAnchor, constant: 15),
            self.generationNumberLabel.bottomAnchor.constraint(equalTo: activitySwich.bottomAnchor)
        ]
        
        self.view.addConstraints(generationNumberLabelConstraints)
        
        let generationLabelConstraints : [NSLayoutConstraint] = [
            generationLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 15),
            generationLabel.centerYAnchor.constraint(equalTo: self.generationNumberLabel.centerYAnchor),
            generationLabel.widthAnchor.constraint(equalToConstant: 90)
        ]
        
        self.view.addConstraints(generationLabelConstraints)
        
        let resetButton = UIButton()
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.addTarget(self, action: #selector(GameViewController.resetModel(_:)), for: .touchUpInside)
        resetButton.setTitle("Reset", for: UIControlState())
        resetButton.titleLabel?.textColor = UIColor.white
        resetButton.titleLabel?.textAlignment = .center
        resetButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightBold)
        resetButton.backgroundColor = UIColor.darkGray
        
        self.view.addSubview(resetButton)
        
        let resetButtonConstraints : [NSLayoutConstraint] = [
            resetButton.topAnchor.constraint(equalTo: self.gameView.bottomAnchor, constant: 15),
            resetButton.leftAnchor.constraint(equalTo: activitySwich.rightAnchor, constant: 45),
            resetButton.bottomAnchor.constraint(equalTo: activitySwich.bottomAnchor),
            resetButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -45)
        ]
        
        self.view.addConstraints(resetButtonConstraints)
        
        let sizeOfGridSliderLabel = UILabel()
        sizeOfGridSliderLabel.translatesAutoresizingMaskIntoConstraints = false
        sizeOfGridSliderLabel.text = "Size of grid:  "
        sizeOfGridSliderLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightBold)
        sizeOfGridSliderLabel.numberOfLines = 0
        sizeOfGridSliderLabel.lineBreakMode = .byWordWrapping
        sizeOfGridSliderLabel.textAlignment = .center
        
        self.view.addSubview(sizeOfGridSliderLabel)
        
        let sizeOfGridSliderLabelConstraints : [NSLayoutConstraint] = [
            sizeOfGridSliderLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 15),
            sizeOfGridSliderLabel.heightAnchor.constraint(equalToConstant: 60),
            sizeOfGridSliderLabel.topAnchor.constraint(equalTo: framesPerSecondSlider.bottomAnchor, constant: 15),
            sizeOfGridSliderLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.2)
        ]
        
        self.view.addConstraints(sizeOfGridSliderLabelConstraints)
        
        let sizeOfGridSlider = UISlider()
        sizeOfGridSlider.translatesAutoresizingMaskIntoConstraints = false
        
        sizeOfGridSlider.minimumValue = 10
        sizeOfGridSlider.maximumValue = 50
        
        sizeOfGridSlider.value = Float(self.unitLength)
        sizeOfGridSlider.addTarget(self, action: #selector(GameViewController.sizeOfGridChanged(_:)), for: .valueChanged)
        
        self.sizeOfGridLabel.translatesAutoresizingMaskIntoConstraints = false
        self.sizeOfGridLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightBold)
        self.sizeOfGridLabel.textAlignment = .center
        self.sizeOfGridLabel.text = "\(self.unitLength)"
        
        self.view.addSubview(self.sizeOfGridLabel)
        
        let sizeOfGridLabelConstraints : [NSLayoutConstraint] = [
            self.sizeOfGridLabel.centerYAnchor.constraint(equalTo: sizeOfGridSliderLabel.centerYAnchor),
            self.sizeOfGridLabel.heightAnchor.constraint(equalTo: sizeOfGridSliderLabel.heightAnchor),
            self.sizeOfGridLabel.widthAnchor.constraint(equalTo: sizeOfGridSliderLabel.widthAnchor),
            self.sizeOfGridLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -15)
        ]
        
        self.view.addConstraints(sizeOfGridLabelConstraints)
        
        self.view.addSubview(sizeOfGridSlider)
        
        let sizeOfGridSliderConstraints : [NSLayoutConstraint] = [
            
            sizeOfGridSlider.centerYAnchor.constraint(equalTo: sizeOfGridSliderLabel.centerYAnchor),
            sizeOfGridSlider.leftAnchor.constraint(equalTo: sizeOfGridSliderLabel.rightAnchor, constant: 15),
            sizeOfGridSlider.rightAnchor.constraint(equalTo: self.sizeOfGridLabel.leftAnchor, constant: -15)
        ]
        
        self.view.addConstraints(sizeOfGridSliderConstraints)
        
        //layout subviews to then do bounds dependent configurations
        self.view.layoutIfNeeded()
        
        //rounds reset button
        resetButton.clipsToBounds = true
        resetButton.layer.cornerRadius = resetButton.bounds.height/2
        
    }
    
    func resetModel(_ sender: AnyObject? = nil) {
        
        if self.isPlaying {
            self.toggleActivity()
        }
        self.gameOfLife.initializeState()
    }
    
    func instantiateController(_ sender: AnyObject? = nil) {
        
        self.generationController = Timer.scheduledTimer(timeInterval: 1/self.framesPerSecond, target: self, selector: #selector(GameViewController.updateGeneration(_:)), userInfo: nil, repeats: true)
        
    }
    
    func updateGeneration(_ sender: AnyObject? = nil) {
        
        self.gameOfLife.updateGeneration()
    }
    
    func toggleActivity(_ sender: AnyObject? = nil) {
        
        if self.isPlaying {
            self.generationController?.invalidate()
            self.gameView.enableInteraction()
            
            for view in self.view.subviews {
                if view is UISwitch {
                    (view as! UISwitch).setOn(false, animated: true)
                }
            }
            
        } else {
            self.instantiateController()
            self.gameView.disableInteraction()
        }
        
        self.isPlaying = !self.isPlaying
        
    }
    
    func framesPerSecondChanged(_ sender: UISlider) {
        
        self.framesPerSecond = Double(Int(sender.value))
        self.framesPerSecondLabel.text = "\(Int(self.framesPerSecond))"
        if 1/self.framesPerSecond != self.generationController?.timeInterval && self.isPlaying {
            self.generationController?.invalidate()
            self.generationController = Timer.scheduledTimer(timeInterval: 1/self.framesPerSecond, target: self, selector: #selector(GameViewController.updateGeneration(_:)), userInfo: nil, repeats: true)
        }
        
    }
    
    func sizeOfGridChanged(_ sender: UISlider) {
        
        if self.isPlaying {
            self.generationController?.invalidate()
            self.toggleActivity()
        }
        
        self.unitLength = Int(sender.value)
        self.sizeOfGridLabel.text = "\(self.unitLength)"
        
        if self.unitLength != self.gameOfLife.height || self.unitLength != self.gameOfLife.width {
            print(self.unitLength)
            self.gameOfLife.setDimensionsOfGrid(unitLength: unitLength)
            
        }
    }
    
    
}
