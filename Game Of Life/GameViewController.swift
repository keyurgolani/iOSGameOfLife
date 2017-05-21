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
    fileprivate lazy var gameModel : GameModel = { GameModel(widthOfGrid: self.unitLength, heightOfGrid: self.unitLength) }()
    fileprivate lazy var gameView : GameView = { GameView(gameModel: self.gameModel) }()
    fileprivate var isPlaying = false
    fileprivate var fps : Double = 3
    fileprivate var generationController : Timer?
    fileprivate let generationNumberLabel = UILabel()
    fileprivate let fpsLabel = UILabel()
    fileprivate let gridSizeLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        
        //model will handle view updates
        self.gameModel.generationWasBorn = { generationNumber in
            self.generationNumberLabel.text = "\(generationNumber)"
            self.gameView.setNeedsDisplay()
        }
    }
    
    fileprivate func configureView() {
        
        self.gameView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.backgroundColor = UIColor(rgb: 0xFFFFFF)
        
        self.view.addSubview(self.gameView)
        
        let gameModelViewConstraints : [NSLayoutConstraint] = [
            self.gameView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            self.gameView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.gameView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.gameView.heightAnchor.constraint(equalTo: self.view.widthAnchor)
        ]
        
        self.view.addConstraints(gameModelViewConstraints)
        
        let activitySwich = UISwitch()
        activitySwich.translatesAutoresizingMaskIntoConstraints = false
        
        activitySwich.addTarget(self, action: #selector(GameViewController.toggleActivity(_:)), for: .valueChanged)
        
        self.view.addSubview(activitySwich)
        
        let activitySwitchConstraints : [NSLayoutConstraint] = [
            activitySwich.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            activitySwich.topAnchor.constraint(equalTo: self.gameView.bottomAnchor, constant: 15)
        ]
        
        self.view.addConstraints(activitySwitchConstraints)
        
        let fpsSliderLabel = UILabel()
        
        fpsSliderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        fpsSliderLabel.text = "Frames per second: "
        fpsSliderLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightBold)
        fpsSliderLabel.numberOfLines = 0
        fpsSliderLabel.lineBreakMode = .byWordWrapping
        fpsSliderLabel.textAlignment = .center
        
        self.view.addSubview(fpsSliderLabel)
        
        let fpsSlider = UISlider()
        fpsSlider.translatesAutoresizingMaskIntoConstraints = false
        
        fpsSlider.minimumValue = 1
        fpsSlider.maximumValue = 50
        
        fpsSlider.value = Float(self.fps)
        fpsSlider.addTarget(self, action: #selector(GameViewController.fpsChanged(_:)), for: .valueChanged)
        
        self.view.addSubview(fpsSlider)
        
        self.fpsLabel.translatesAutoresizingMaskIntoConstraints = false
        self.fpsLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightBold)
        self.fpsLabel.textAlignment = .center
        self.fpsLabel.text = "\(Int(self.fps))"
        
        self.view.addSubview(self.fpsLabel)
        
        let fpsSliderLabelConstraints : [NSLayoutConstraint] = [
            fpsSliderLabel.centerYAnchor.constraint(equalTo: fpsSlider.centerYAnchor),
            fpsSliderLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 15),
            fpsSliderLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.2),
            fpsSliderLabel.heightAnchor.constraint(equalToConstant: 60)
        ]
        
        self.view.addConstraints(fpsSliderLabelConstraints)
        
        let fpsLabelConstraints : [NSLayoutConstraint] = [
            self.fpsLabel.centerYAnchor.constraint(equalTo: fpsSlider.centerYAnchor),
            self.fpsLabel.heightAnchor.constraint(equalTo: fpsSlider.heightAnchor),
            self.fpsLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -15),
            self.fpsLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.2)
        ]
        
        self.view.addConstraints(fpsLabelConstraints)
        
        let fpsSliderConstraints : [NSLayoutConstraint] = [
            fpsSlider.leftAnchor.constraint(equalTo: fpsSliderLabel.rightAnchor, constant: 15),
            fpsSlider.topAnchor.constraint(equalTo: activitySwich.bottomAnchor, constant: 15),
            fpsSlider.rightAnchor.constraint(equalTo: self.fpsLabel.leftAnchor, constant: -15),
            fpsSlider.heightAnchor.constraint(equalTo: fpsSliderLabel.heightAnchor)
        ]
        
        self.view.addConstraints(fpsSliderConstraints)
        
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
            sizeOfGridSliderLabel.topAnchor.constraint(equalTo: fpsSlider.bottomAnchor, constant: 15),
            sizeOfGridSliderLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.2)
        ]
        
        self.view.addConstraints(sizeOfGridSliderLabelConstraints)
        
        let sizeOfGridSlider = UISlider()
        sizeOfGridSlider.translatesAutoresizingMaskIntoConstraints = false
        
        sizeOfGridSlider.minimumValue = 10
        sizeOfGridSlider.maximumValue = 50
        
        sizeOfGridSlider.value = Float(self.unitLength)
        sizeOfGridSlider.addTarget(self, action: #selector(GameViewController.sizeOfGridChanged(_:)), for: .valueChanged)
        
        self.gridSizeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.gridSizeLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightBold)
        self.gridSizeLabel.textAlignment = .center
        self.gridSizeLabel.text = "\(self.unitLength)"
        
        self.view.addSubview(self.gridSizeLabel)
        
        let gridSizeLabelConstraints : [NSLayoutConstraint] = [
            self.gridSizeLabel.centerYAnchor.constraint(equalTo: sizeOfGridSliderLabel.centerYAnchor),
            self.gridSizeLabel.heightAnchor.constraint(equalTo: sizeOfGridSliderLabel.heightAnchor),
            self.gridSizeLabel.widthAnchor.constraint(equalTo: sizeOfGridSliderLabel.widthAnchor),
            self.gridSizeLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -15)
        ]
        
        self.view.addConstraints(gridSizeLabelConstraints)
        
        self.view.addSubview(sizeOfGridSlider)
        
        let sizeOfGridSliderConstraints : [NSLayoutConstraint] = [
            
            sizeOfGridSlider.centerYAnchor.constraint(equalTo: sizeOfGridSliderLabel.centerYAnchor),
            sizeOfGridSlider.leftAnchor.constraint(equalTo: sizeOfGridSliderLabel.rightAnchor, constant: 15),
            sizeOfGridSlider.rightAnchor.constraint(equalTo: self.gridSizeLabel.leftAnchor, constant: -15)
        ]
        
        self.view.addConstraints(sizeOfGridSliderConstraints)
        
        //layout subviews to then do bounds dependent configurations
        self.view.layoutIfNeeded()
        
        //rounds reset button
        resetButton.clipsToBounds = true
        resetButton.layer.cornerRadius = resetButton.bounds.height/2
        
    }
    
    func resetModel(_ sender: AnyObject? = nil) {
        
        let resetAlert = UIAlertController(title: "Reset", message: "All live cells will be cleared!", preferredStyle: UIAlertControllerStyle.alert)
        
        resetAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            if self.isPlaying {
                self.toggleActivity()
            }
            self.gameModel.initializeState()
        }))
        
        resetAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            // Do Nothing!
        }))
        
        present(resetAlert, animated: true, completion: nil)
    }
    
    func instantiateController(_ sender: AnyObject? = nil) {
        
        self.generationController = Timer.scheduledTimer(timeInterval: 1/self.fps, target: self, selector: #selector(GameViewController.nextGeneration(_:)), userInfo: nil, repeats: true)
        
    }
    
    func nextGeneration(_ sender: AnyObject? = nil) {
        
        self.gameModel.nextGeneration()
    }
    
    func toggleActivity(_ sender: AnyObject? = nil) {
        
        if self.isPlaying {
            self.generationController?.invalidate()
            self.gameView.enableInput()
            
            for view in self.view.subviews {
                if view is UISwitch {
                    (view as! UISwitch).setOn(false, animated: true)
                }
            }
            
        } else {
            self.instantiateController()
            self.gameView.disableInput()
        }
        
        self.isPlaying = !self.isPlaying
        
    }
    
    func fpsChanged(_ sender: UISlider) {
        
        self.fps = Double(Int(sender.value))
        self.fpsLabel.text = "\(Int(self.fps))"
        if 1/self.fps != self.generationController?.timeInterval && self.isPlaying {
            self.generationController?.invalidate()
            self.generationController = Timer.scheduledTimer(timeInterval: 1/self.fps, target: self, selector: #selector(GameViewController.nextGeneration(_:)), userInfo: nil, repeats: true)
        }
        
    }
    
    func sizeOfGridChanged(_ sender: UISlider) {
        
        if self.isPlaying {
            self.generationController?.invalidate()
            self.toggleActivity()
        }
        
        self.unitLength = Int(sender.value)
        self.gridSizeLabel.text = "\(self.unitLength)"
        
        if self.unitLength != self.gameModel.height || self.unitLength != self.gameModel.width {
            print(self.unitLength)
            self.gameModel.setDimensionsOfGrid(unitLength: unitLength)
            
        }
    }
    
    
}
