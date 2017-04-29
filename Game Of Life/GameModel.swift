//
//  GameModel.swift
//  Game Of Life
//
//  Created by Keyur Golani on 4/29/17.
//  Copyright © 2017 Keyur Golani. All rights reserved.
//

import Foundation

protocol AGame {
    
    var height : Int { get }
    var width : Int { get }
    var previousState : [[Bool]] { get }
    var presentState : [[Bool]] { get}
    var nextState : [[Bool]] { get }
    var generationNumber : Int { get }
    var generationWasBorn : ((Int)->Void)? { get set }
}

class GameModel : NSObject, AGame {
    
    var height : Int
    var width : Int
    var previousState : [[Bool]] = []
    var presentState : [[Bool]] = []
    var nextState : [[Bool]] = []
    var generationNumber : Int = 0
    var generationWasBorn : ((Int)->Void)?
    
    init(widthOfGrid width : Int, heightOfGrid height : Int) {
        
        self.width = width
        self.height = height
        super.init()
        self.initializeState()
        
    }
    
    func initializeState() {
        self.previousState = Array(repeating: Array(repeating: false, count: self.height), count: self.width)
        self.presentState = Array(repeating: Array(repeating: false, count: self.height), count: self.width)
        self.nextState = Array(repeating: Array(repeating: false, count: self.height), count: self.width)
        self.generationNumber = 0
        self.generationWasBorn?(self.generationNumber)
    }
    
    func setDimensionsOfGrid(unitLength length : Int) {
        self.height = length
        self.width = length
        self.initializeState()
    }
    
    func toggleCell(_ x: Int, y: Int) {
        
        if x < 0 || x > self.width || y < 0 || y > self.height {
            return
        }
        
        self.presentState[x][y] = !self.presentState[x][y]
        self.previousState[x][y] = !self.previousState[x][y]
        
    }
    
    fileprivate func countNeighborsForCell(_ x: Int, y: Int) -> Int {
        
        if x < 0 || x > self.width || y < 0 || y > self.height {
            return 0
        }
        
        var neighbors = 0
        
        //left
        if x > 0 && self.presentState[x-1][y] {
            neighbors += 1
        } else if x == 0 {
            if self.presentState[self.width - 1][y] {
                neighbors += 1
            }
        }
        
        //right
        if x < self.width - 1 && self.presentState[x+1][y] {
            neighbors += 1
        } else if x == self.width - 1 {
            if self.presentState[0][y] {
                neighbors += 1
            }
        }
        
        //top
        if y > 0 && self.presentState[x][y-1] {
            neighbors += 1
        } else if y == 0 {
            if self.presentState[x][self.height - 1] {
                neighbors += 1
            }
        }
        
        //bottom
        if y < self.height - 1 && self.presentState[x][y+1] {
            neighbors += 1
        } else if y == self.height - 1 {
            if self.presentState[x][0] {
                neighbors += 1
            }
        }
        
        //top-left
        if x > 0 && y > 0 && self.presentState[x-1][y-1] {
            neighbors += 1
        } else if y == 0 && x == 0 {
            if self.presentState[self.width - 1][self.height - 1] {
                neighbors += 1
            }
        } else if x == 0 {
            if y > 0 {
                if self.presentState[self.width - 1][y-1] {
                    neighbors += 1
                }
            }
        } else if y == 0 {
            if x > 0 {
                if self.presentState[x-1][self.height - 1] {
                    neighbors += 1
                }
            }
        }
        
        //top-right
        if x < self.width - 1 && y > 0 && self.presentState[x+1][y-1] {
            neighbors += 1
        } else if x == self.width - 1 && y == 0 {
            if self.presentState[0][self.height - 1] {
                neighbors += 1
            }
        } else if x == self.width - 1 {
            if y > 0 {
                if self.presentState[0][y-1] {
                    neighbors += 1
                }
            }
        } else if y == 0 {
            if x < self.width - 1 {
                if self.presentState[x+1][self.height - 1] {
                    neighbors += 1
                }
            }
        }
        
        //bottom-left
        if x > 0 && y < self.width - 1 && self.presentState[x-1][y+1] {
            neighbors += 1
        } else if x == 0 && y == self.width - 1 {
            if self.presentState[self.width - 1][0] {
                neighbors += 1
            }
        } else if x == 0 {
            if y < self.width - 1 {
                if self.presentState[self.width - 1][y+1] {
                    neighbors += 1
                }
            }
        } else if y == self.width - 1 {
            if x > 0 {
                if self.presentState[x-1][0] {
                    neighbors += 1
                }
            }
        }
        
        //bottom-right
        if x < self.width - 1 && y < self.height - 1 && self.presentState[x+1][y+1] {
            neighbors += 1
        } else if x == self.width - 1 && y == self.height - 1 {
            if self.presentState[0][0] {
                neighbors += 1
            }
        } else if x == self.width - 1 {
            if y < self.height - 1 {
                if self.presentState[0][y+1] {
                    neighbors += 1
                }
            }
        } else if y == self.height - 1 {
            if x < self.width - 1 {
                if self.presentState[x+1][0] {
                    neighbors += 1
                }
            }
        }
        
        return neighbors
    }
    
    func decide(_ x: Int, y: Int) -> Bool {
        
        if x < 0 || x > self.width || y < 0 || y > self.height {
            return false
        }
        
        let neighbors = self.countNeighborsForCell(x, y: y)
        
        //rule 1
        if self.presentState[x][y] && neighbors < 2 {
            return false
        }
        
        //rule 2
        if self.presentState[x][y] && neighbors == 2 || neighbors == 3 {
            return true
        }
        
        //rule 3
        if self.presentState[x][y]  && neighbors > 3 {
            return false
        }
        
        //rule 4
        if !self.presentState[x][y] && neighbors == 3 {
            return true
        }
        
        return false
    }
    
    func updateGeneration() {
        
        for i in 0..<self.width {
            for j in 0..<self.height {
                self.nextState[i][j] = self.decide(i, y: j)
            }
        }
        
        for i in 0..<self.width {
            for j in 0..<self.height {
                self.previousState[i][j] = self.presentState[i][j]
            }
        }
        
        for i in 0..<self.width {
            for j in 0..<self.height {
                self.presentState[i][j] = self.nextState[i][j]
            }
        }
        
        self.generationNumber += 1
        self.generationWasBorn?(self.generationNumber)
    }
}
