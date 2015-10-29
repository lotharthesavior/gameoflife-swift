//
//  Tile.swift
//  firstgame
//
//  Created by Sávio Resende on 29/10/15.
//  Copyright © 2015 Sávio Resende. All rights reserved.
//

import UIKit
import SpriteKit

class Tile: SKSpriteNode {
    
    var isAlive:Bool = false {
        didSet {
            self.hidden = !isAlive
        }
    }
    
    var numLivingNeighbors = 0
    
}
