//
//  GameView.swift
//  Game Of Life
//
//  Created by Keyur Golani on 4/29/17.
//  Copyright © 2017 Keyur Golani. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

class GameView : UIView {
    
    fileprivate var model : GameModel!
    
    init(gameModel model : GameModel) {
        self.model = model
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor(rgb: 0x3B3E43)
        self.enableInteraction()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        let unitWidth = rect.width / CGFloat(self.model.width)
        let unitHeight = rect.height / CGFloat(self.model.height)
//        let recentDeadGeneration = UIColor(rgb: 0xB746AE)  // Pinkish
        let newGenerationDotColor = UIColor(rgb: 0x22D88F)  // Greenish
        let oldGenerationDotColor = UIColor(rgb: 0x1081F9) //Blueish
//        let recentDeadGeneration = UIColor(rgb: 0xF47841) // Orangish
        
        for i in 0..<self.model.width {
            for j in 0..<self.model.height {
                
                let x = CGFloat(i) * unitWidth
                let y = CGFloat(j) * unitHeight
                
                let cellPath = UIBezierPath(arcCenter: CGPoint(x: x+(unitWidth/2),y: y+(unitWidth/2)), radius: (unitWidth/2)-1, startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
                if self.model.presentState[i][j] {
                    
                    if !self.model.previousState[i][j] {
                        newGenerationDotColor.setFill()
                    } else {
                        oldGenerationDotColor.setFill()
                    }
                    cellPath.fill()
                }
                
                if self.model.previousState[i][j] && !self.model.presentState[i][j] {
                    
//                    recentDeadGeneration.setFill()
//                    cellPath.fill()
                }
            }
        }
        
        for i in 1..<self.model.width {
            
            let x = CGFloat(i) * unitWidth
            
            let linePath = UIBezierPath(rect: CGRect(x: x, y: 0, width: 1, height: rect.height))
            UIColor.black.setFill()
            linePath.fill()
        }
        
        for i in 1..<self.model.height {
            
            let y = CGFloat(i) * unitHeight
            
            let linePath = UIBezierPath(rect: CGRect(x: 0, y: y, width: rect.width, height: 1))
            UIColor.black.setFill()
            linePath.fill()
        }
        
        
    }
    
    func enableInteraction() {
        if self.gestureRecognizers == nil {
            self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GameView.didTapCell(_:))))
            self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(GameView.didPanOverCell(_:))))
        }
    }
    
    func disableInteraction() {
        self.gestureRecognizers?.removeAll()
        self.gestureRecognizers = nil
    }
    
    func didTapCell(_ sender: UITapGestureRecognizer) {
        
        let unitWidth = self.bounds.width / CGFloat(self.model.width)
        let unitHeight = self.bounds.height / CGFloat(self.model.height)
        
        let x = Int(sender.location(in: self).x / unitWidth)
        let y = Int(sender.location(in: self).y / unitHeight)
        
        self.model.toggleCell(x, y: y)
        self.setNeedsDisplay()
    }
    
    func didPanOverCell(_ sender: UIPanGestureRecognizer) {
        
        let unitWidth = self.bounds.width / CGFloat(self.model.width)
        let unitHeight = self.bounds.height / CGFloat(self.model.height)
        
        let x = Int(sender.location(in: self).x / unitWidth)
        let y = Int(sender.location(in: self).y / unitHeight)
        
        //if panning goes beyond view and thus produces faulty coordinates
        if x < 0 || x > self.model.width - 1 || y < 0 || y > self.model.height - 1 {
            return
        }
        
        if !self.model.presentState[x][y] {
            self.model.toggleCell(x, y: y)
            self.setNeedsDisplay()
        }
        
    }
}
