//
//  GameScene.swift
//  firstgame
//
//  Created by Sávio Resende on 14/10/15.
//  Copyright (c) 2015 Sávio Resende. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let _gridWidth = 780
    let _gridHeight = 560
    let _numRows = 8
    let _numCols = 10
    let _gridLowerLeftCorner:CGPoint = CGPoint(x: 228, y:100)
    
    let _populationLabel:SKLabelNode = SKLabelNode(text: "Population")
    let _generationLabel:SKLabelNode = SKLabelNode(text: "Generation")
    var _populationValueLabel:SKLabelNode = SKLabelNode(text: "0")
    var _generationValueLabel:SKLabelNode = SKLabelNode(text: "0")
    var _playButton:Tile = Tile(imageNamed:"play.png")
    var _pauseButton:Tile = Tile(imageNamed:"pause.png")
    
    var _tiles:[[Tile]] = []
    var _margin = 4
    
    var _isPlaying = false
    
    var _prevTime:CFTimeInterval = 0
    var _timeCounter:CFTimeInterval = 0
    
    var _population:Int = 0 {
        didSet {
            _populationValueLabel.text = "\(_population)"
        }
    }
    var _generation:Int = 0 {
        didSet {
            _generationValueLabel.text = "\(_generation)"
        }
    }
    
    override func didMoveToView(view: SKView) {
        
        let background = Tile(imageNamed: "background.png")
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.size = self.size
        background.zPosition = -2
        self.addChild(background)
        
        let gridBackground = Tile(imageNamed: "grid.png")
        gridBackground.size = CGSize(width: _gridWidth, height: _gridHeight)
//        print(self.size.width)
//        print(self.size.height)
        gridBackground.zPosition = -1
        gridBackground.anchorPoint = CGPoint(x:0, y:0)
        gridBackground.position = _gridLowerLeftCorner
        self.addChild(gridBackground)
        
        _playButton.position = CGPoint(x: 105, y: 610)
        _playButton.setScale(1)
        self.addChild(_playButton)
        _pauseButton.position = CGPoint(x: 105, y: 520)
        _pauseButton.setScale(1)
        self.addChild(_pauseButton)
        // add a balloon background for the stats
        let balloon = Tile(imageNamed: "balloon.png")
        balloon.position = CGPoint(x: 105, y: 370)
        balloon.setScale(1)
        balloon.zPosition = -1
        self.addChild(balloon)
        // add a microscope image as a decoration
        let microscope = Tile(imageNamed: "microscope.png")
        microscope.position = CGPoint(x: 105, y: 185)
        microscope.setScale(0.7)
        self.addChild(microscope)
        // dark green labels to keep track of number of living tiles
        // and number of steps the simulation has gone through
        _populationLabel.position = CGPoint(x: 105, y: 400)
        _populationLabel.fontName = "Courier"
        _populationLabel.fontSize = 17
        _populationLabel.fontColor = UIColor(red: 0, green: 0.2, blue: 0, alpha: 1)
        self.addChild(_populationLabel)
        _generationLabel.position = CGPoint(x: 105, y: 340)
        _generationLabel.fontName = "Courier"
        _generationLabel.fontSize = 17
        _generationLabel.fontColor = UIColor(red: 0, green: 0.2, blue: 0, alpha: 1)
        self.addChild(_generationLabel)
        _populationValueLabel.position = CGPoint(x: 105, y: 380)
        _populationValueLabel.fontName = "Courier"
        _populationValueLabel.fontSize = 17
        _populationValueLabel.fontColor = UIColor(red: 0, green: 0.2, blue: 0, alpha: 1)
        self.addChild(_populationValueLabel)
        _generationValueLabel.position = CGPoint(x: 105, y: 320)
        _generationValueLabel.fontName = "Courier"
        _generationValueLabel.fontSize = 17
        _generationValueLabel.fontColor = UIColor(red: 0, green: 0.2, blue: 0, alpha: 1)
        self.addChild(_generationValueLabel)
        
        // initialize the 2d array of tiles
        let tileSize = calculateTileSize()
        for r in 0..._numRows-1 {
            var tileRow:[Tile] = []
            for c in 0..._numCols-1 {
                let tile = Tile(imageNamed: "bubble.png")
                tile.isAlive = false;
                tile.size = CGSize(width: tileSize.width, height: tileSize.height)
                tile.anchorPoint = CGPoint(x: 0, y: 0)
                tile.position = getTilePosition(row: r, column: c)
                self.addChild(tile)
                tileRow.append(tile)
            }
            _tiles.append(tileRow)
        }
    }
    
    func calculateTileSize() -> CGSize {
        
        let tileWidth = _gridWidth / _numCols - _margin
        let tileHeight = _gridHeight / _numRows - _margin
        return CGSize(width: tileWidth, height: tileHeight)
    }
    
    func getTilePosition(row r:Int, column c:Int) -> CGPoint {
        
        let tileSize = calculateTileSize()
        let x = Int(_gridLowerLeftCorner.x) + _margin + (c * (Int(tileSize.width) + _margin))
        let y = Int(_gridLowerLeftCorner.y) + _margin + (r * (Int(tileSize.height) + _margin))
        return CGPoint(x: x, y: y)
    }
    
    func isValidTile(row r: Int, column c:Int) -> Bool {
        return r >= 0 && r < _numRows-1 && c >= 0 && c < _numCols-1
    }
    
    func getTileAtPosition(xPos x: Int, yPos y: Int) -> Tile? {
        let r:Int = Int( CGFloat(y - (Int(_gridLowerLeftCorner.y) + _margin)) / CGFloat(_gridHeight) * CGFloat(_numRows))
        let c:Int = Int( CGFloat(x - (Int(_gridLowerLeftCorner.x) + _margin)) / CGFloat(_gridWidth) * CGFloat(_numCols))
        if isValidTile(row: r, column: c) {
            return _tiles[r][c]
        } else {
            return nil
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let selectedTile:Tile? = getTileAtPosition(xPos: Int(touch.locationInNode(self).x), yPos: Int(touch.locationInNode(self).y))
            
            if let tile = selectedTile {
                tile.isAlive = !tile.isAlive
                if tile.isAlive {
                    _population++
                } else {
                    _population--
                }
            }
            
            if CGRectContainsPoint(_playButton.frame, touch.locationInNode(self)) {
                playButtonPressed()
            }
            if CGRectContainsPoint(_pauseButton.frame, touch.locationInNode(self)) {
                pauseButtonPressed()
            }
        }
    }
    
    func playButtonPressed(){
        _isPlaying = true
    }
    func pauseButtonPressed(){
        _isPlaying = false
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if _prevTime == 0 {
            _prevTime = currentTime
        }
        if _isPlaying
        {
            _timeCounter += currentTime - _prevTime
            if _timeCounter > 0.5 {
                _timeCounter = 0
                timeStep()
            }
        }
        _prevTime = currentTime
    }
    
    func timeStep(){
        countLivingNeighbors()
        updateCreatures()
        _generation++
    }
    
    func countLivingNeighbors(){
        for r in 0..._numRows-1 {
            for c in 0..._numCols-1
            {
                var numLivingNeighbors:Int = 0
                for i in (r-1)...(r+1) {
                    for j in (c-1)...(c+1)
                    {
                        if ( !((r == i) && (c == j)) && isValidTile(row: i, column: j)) {
                            if _tiles[i][j].isAlive {
                                numLivingNeighbors++
                            }
                        }
                    }
                }
                _tiles[r][c].numLivingNeighbors = numLivingNeighbors
            }
        }
    }
    
    func updateCreatures(){
        var numAlive = 0
        for r in 0..._numRows-1 {
            for c in 0..._numCols-1
            {
                let tile:Tile = _tiles[r][c]
                if tile.numLivingNeighbors == 3 {
                    tile.isAlive = true
                } else if tile.numLivingNeighbors < 2 || tile.numLivingNeighbors > 3 {
                    tile.isAlive = false
                }
                if tile.isAlive {
                    numAlive++
                }
            }
        }
        _population = numAlive
    }
}
