//
//  HUDNode.swift
//  SpaceRun
//
//  Created by Chelsey on 12/11/17.
//  Copyright © 2017 Chelsey Fay. All rights reserved.
//

import SpriteKit


class HUDNode: SKNode {
    // Create a Heads-up-Display (HUD) that will hold all of our display areas
    //
    // Once the node is added to the scene, we'll tell it to lay out it's child nodes. The child nodes will not contain labels as we will use the blank nodes as group containers and lay out the label nodes inside of them.
    //
    // We will left align our Score and right-align the elapsed game time.
    // Build two parent nodes (containers) as group containers that will hold the score and value labels.
    
    // Properties
    private let ScoreGroupName = "scoreGroup"
    private let ScoreValueName = "scoreValue"
    private let HighScoreValue = "highScore"
        
    private let LevelUpGroupName = "levelUp"
    private let LevelUpValueName = "levelUpValueName"
    private let LevelUpActionName = "LevelUpActionName"
    
    private let ElapsedGroupName = "elapsedGroup"
    private let ElapsedValueName = "elapsedValue"
    private let TimerActionName = "elapsedGameTimer"
    
    private let PowerUpGroupName = "powerUpGroup"
    private let PowerUpValueName = "powerUpValue"
    private let PowerUpActionName = "showPowerUpTimer"
    

    var elapsedTime: TimeInterval = 0.0
    var score: Int = 0
    var lives = [SKSpriteNode]()
    var recordData: String!
    
    lazy private var scoreFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    lazy private var timeFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    override init() {
        super.init()
        createScoreGroup()
        createElapsedGroup()
        createPowerUpGroup()
        createLevelUpGroup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //
    // Our labels are properly layed out within their parent group nodes,
    // but the group nodes are centered on the screen (scene).  We need
    // to create a layout method that will properly position the groups.
    //
    func layoutForScene() {
        
        // When a node exists in the Scene Graph, it can get access to the scene
        // via its scene property.  That property is nil if the node doesn't belong
        // to a scene yet, so this method is useless if the node is not yet added to the scene.
        if let scene = scene {
            
            let sceneSize = scene.size
            
            
            // the following will be used to calculate position of each group
            var groupSize = CGSize.zero
            
            if let scoreGroup = childNode(withName: ScoreGroupName) {
                
                // Get size of scoreGroup container (box)
                groupSize = scoreGroup.calculateAccumulatedFrame().size
                
                scoreGroup.position = CGPoint(x: 0.0 - sceneSize.width/2.0 + 40.0, y: 0.0 - sceneSize.height/2.0 + groupSize.height)
                
            } else {
                assert(false, "No score group node was found in the Scene Graph node tree")
                
            }
            
                if let levelUpGroup = childNode(withName: LevelUpGroupName) {
                
                // Get size of scoreGroup container (box)
                groupSize = levelUpGroup.calculateAccumulatedFrame().size
                
                levelUpGroup.position = CGPoint(x: sceneSize.width/2.0 + 40.0, y: sceneSize.height/2.0 - groupSize.height)
                
            } else {
                assert(false, "No level group node was found in the Scene Graph node tree")
            }
            
            if let elapsedGroup = childNode(withName: ElapsedGroupName) {
                
                // Get size of elapsedGroup container (box)
                groupSize = elapsedGroup.calculateAccumulatedFrame().size
                
                elapsedGroup.position = CGPoint(x: sceneSize.width/2.0 - 30.0, y: 0.0 - sceneSize.height/2.0 + groupSize.height)
                
            } else {
                assert(false, "No elapsed group node was found in the Scene Graph node tree")
            }
            
            
            if let powerUpGroup = childNode(withName: PowerUpGroupName) {
                
                groupSize = powerUpGroup.calculateAccumulatedFrame().size
                
                powerUpGroup.position = CGPoint(x: 0.0, y: sceneSize.height/2.0 - groupSize.height)
                
            } else {
                assert(false, "No powerup group node was found in the Scene Graph node tree")
            }
            
         
            
        }
        
    }
    
    func createScoreGroup() {
        
        let scoreGroup = SKNode()
        scoreGroup.name = ScoreGroupName
        
        // Create an SKLabelNode for our title
        let scoreTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        
        scoreTitle.fontSize = 12.0
        scoreTitle.fontColor = SKColor.white
        
        // Set the vertical and horizontal alignment modes in a way that will help
        // use layout for the labels inside this group node.
        scoreTitle.horizontalAlignmentMode = .center
        scoreTitle.verticalAlignmentMode = .bottom
        scoreTitle.text = "SCORE"
        scoreTitle.position = CGPoint(x: 0.0, y: 4.0)
        scoreGroup.addChild(scoreTitle)

        
        // Set the vertical and horizontal alignment modes in a way that will help
        // use layout for the labels inside this group node.
        let scoreValue = SKLabelNode(fontNamed: "AvenirNext-Bold")

        scoreValue.fontSize = 20.0
        scoreValue.fontColor = SKColor.white
      
        
        // Set the vertical and horizontal alignment modes in a way that will help
        // use layout for the labels inside this group node.
        scoreValue.horizontalAlignmentMode = .center
        scoreValue.verticalAlignmentMode = .top
        scoreValue.name = ScoreValueName
        scoreValue.text = "0"
        scoreValue.position = CGPoint(x: 0.0, y: -4.0)
    
        scoreGroup.addChild(scoreValue)
        
        
        // Add scoreGroup as a child of our HUD node
        addChild(scoreGroup)
        
    } // End of ScoreGroup
    

    func createLevelUpGroup() {
        
        let levelUpGroup = SKNode()
        levelUpGroup.name = LevelUpGroupName
        
        // Create an SKLabelNode for our title
        let levelUpTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        
        levelUpTitle.fontSize = 12.0
        levelUpTitle.fontColor = SKColor.white
        
        // Set the vertical and horizontal alignment modes in a way that will help
        // use layout for the labels inside this group node.
        levelUpTitle.horizontalAlignmentMode = .center
        levelUpTitle.verticalAlignmentMode = .bottom
        levelUpTitle.text = "LEVEL:"
        levelUpTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        levelUpGroup.addChild(levelUpTitle)
        
        
        let levelUpValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        levelUpValue.fontSize = 20.0
        levelUpValue.fontColor = SKColor.white
        
        // Set the vertical and horizontal alignment modes in a way that will help
        // use layout for the labels inside this group node.
        levelUpValue.horizontalAlignmentMode = .center
        levelUpValue.verticalAlignmentMode = .top
        levelUpValue.name = LevelUpValueName
        levelUpValue.text = "0"
        levelUpValue.position = CGPoint(x: 0.0, y: -4.0)
        
        levelUpGroup.addChild(levelUpValue)
        
        // Add scoreGroup as a child of our HUD node
        addChild(levelUpGroup)
        
    } // End of LevelUpGroup
    
    
    func createElapsedGroup() {
        
        let elapsedGroup = SKNode()
        elapsedGroup.name = ElapsedGroupName
        
        // Create an SKLabelNode for our title
        let elapsedTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        
        elapsedTitle.fontSize = 12.0
        elapsedTitle.fontColor = SKColor.white
        
        // Set the vertical and horizontal alignment modes in a way that will help
        // use layout for the labels inside this group node.
        elapsedTitle.horizontalAlignmentMode = .center
        elapsedTitle.verticalAlignmentMode = .bottom
        elapsedTitle.text = "TIME"
        elapsedTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        elapsedGroup.addChild(elapsedTitle)
        
        
        let elapsedValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        elapsedValue.fontSize = 20.0
        elapsedValue.fontColor = SKColor.white
        
        // Set the vertical and horizontal alignment modes in a way that will help
        // use layout for the labels inside this group node.
        elapsedValue.horizontalAlignmentMode = .center
        elapsedValue.verticalAlignmentMode = .top
        elapsedValue.name = ElapsedValueName
        elapsedValue.text = "0.0s"
        elapsedValue.position = CGPoint(x: 0.0, y: -4.0)
        
        elapsedGroup.addChild(elapsedValue)
        
        // Add scoreGroup as a child of our HUD node
        addChild(elapsedGroup)
        
    } // End of Elapsed Group
    
    
    func createPowerUpGroup() {
        
        let powerUpGroup = SKNode()
        powerUpGroup.name = PowerUpGroupName
        
        // Create an SKLabelNode for our title
        let powerupTitle = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        powerupTitle.fontSize = 14.0
        powerupTitle.fontColor = SKColor.red
        
        // Set the vertical and horizontal alignment modes in a way that will help
        // use layout for the labels inside this group node.
        powerupTitle.verticalAlignmentMode = .bottom
        powerupTitle.text = "Power-up!"
        powerupTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        // set up actions to make our title pulse
        powerupTitle.run(SKAction.repeatForever(SKAction.sequence([SKAction.scale(to: 1.3, duration: 0.3), SKAction.scale(to: 1.0, duration: 0.3)])))
        powerUpGroup.addChild(powerupTitle)
        let powerUpValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        powerUpValue.fontSize = 20.0
        powerUpValue.fontColor = SKColor.red
        
        // Set the vertical and horizontal alignment modes in a way that will help
        // use layout for the labels inside this group node.
        powerUpValue.verticalAlignmentMode = .top
        powerUpValue.name = PowerUpValueName
        powerUpValue.text = "0s left"
        powerUpValue.position = CGPoint(x: 0.0, y: -4.0)
        
        powerUpGroup.addChild(powerUpValue)
        
        // Add scoreGroup as a child of our HUD node
        addChild(powerUpGroup)
        
        powerUpGroup.alpha = 0.0   // make it invisible to start
        
    }
    
    
    /// Function to update ScoreValue label in HUD
    ///
    /// - parameter points: Integer
    func addPoints(_ points: Int) {
        score += points

        // Update HUD by looking up scoreValue label and updating it
        if let scoreValue = childNode(withName: "\(ScoreGroupName)/\(ScoreValueName)") as! SKLabelNode? {
            
            // Format our score value using the thousands separator by using our
            // cached self.scoreFormatter property
            scoreValue.text = scoreFormatter.string(from: NSNumber(value: score))
            
            // Scale the node up for brief period of time and then scale it back down
            scoreValue.run(SKAction.sequence([SKAction.scale(to: 1.1, duration: 0.02), SKAction.scale(to: 1.0, duration: 0.07)]))
            
        }
        
    }
    

    func showPowerupTimer(_ time: TimeInterval) {
        
        if let powerUpGroup = childNode(withName: PowerUpGroupName) {
            
            powerUpGroup.removeAction(forKey: PowerUpActionName)
            
            if let powerUpValue = powerUpGroup.childNode(withName: PowerUpValueName) as! SKLabelNode? {
                
                // Run the countdown sequence
                let start = Date.timeIntervalSinceReferenceDate
                
                let block = SKAction.run {
                    [weak self] in
                    
                    if let weakSelf = self {
                        
                        let elapsedTime = Date.timeIntervalSinceReferenceDate - start
                        
                        let timeLeft = max(time - elapsedTime, 0)
                        
                        let timeLeftFormat = weakSelf.timeFormatter.string(from: NSNumber(value: timeLeft))
                        
                        powerUpValue.text = "\(timeLeftFormat ?? "0")s left"
                        
                    }
                }
                
                let countDownSequence = SKAction.sequence([block, SKAction.wait(forDuration: 0.05)])
                
                let countDown = SKAction.repeatForever(countDownSequence)
                
                let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
                let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 1.0)
                
                let stopAction = SKAction.run({ () -> Void in
                    
                    powerUpGroup.removeAction(forKey: self.PowerUpActionName)
                    
                })
                
                let visuals = SKAction.sequence([fadeIn, SKAction.wait(forDuration: time), fadeOut, stopAction])
                
                powerUpGroup.run(SKAction.group([countDown, visuals]), withKey: self.PowerUpActionName)
            }
        }
        
    }
    
    func startGame() {
        
        
        // Calculate the timestamp when starting the game.
        let startTime = Date.timeIntervalSinceReferenceDate
 
        if let elapsedValue = childNode(withName: "\(ElapsedGroupName)/\(ElapsedValueName)") as! SKLabelNode? {
            
            // Use a code block to update the elapsedTime property to be the
            // difference between the startTime and the current timeStamp
            let update = SKAction.run({
                [weak self] in
                
                if let weakSelf = self {
                    
                    let currentTime = Date.timeIntervalSinceReferenceDate
                    
                    weakSelf.elapsedTime = currentTime - startTime
                    
                    elapsedValue.text = weakSelf.timeFormatter.string(from: NSNumber(value: weakSelf.elapsedTime))
                }
                
            })
            
            let updateAndDelay = SKAction.sequence([update, SKAction.wait(forDuration: 0.05)])
            
            let timer = SKAction.repeatForever(updateAndDelay)
            
            run(timer, withKey: TimerActionName)
            
        }
        
    }
    

    func endGame() {
        
        let highScore = SKNode()
        highScore.name = HighScoreValue
        
        let highScoreTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        
        highScoreTitle.fontSize = 28.0
        highScoreTitle.fontColor = SKColor.red
        
        highScoreTitle.text = "HIGH SCORE"
        highScoreTitle.position = CGPoint(x: 0.0, y: -60.0)
            //-58.0, y: -60.0)
        
        highScore.addChild(highScoreTitle)
        
        let highScoreValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        highScoreValue.fontSize = 25.0
        highScoreValue.fontColor = SKColor.red
        
        highScoreValue.horizontalAlignmentMode = .center
        highScoreValue.verticalAlignmentMode = .bottom
        highScoreValue.name = HighScoreValue
        highScoreValue.text = "0"
        highScoreValue.position = CGPoint(x: 0.0, y: -90.0)
        
        highScore.addChild(highScoreValue)
        addChild(highScore)
        
        if self.score == 0 {
            highScoreValue.text = "0"
        } else {
            highScoreValue.text = "\(self.score)"
        }
        
        // Stop the timer sequence
        removeAction(forKey: TimerActionName)
        
        if let powerUpGroup = childNode(withName: PowerUpGroupName) {
            
            powerUpGroup.removeAction(forKey: PowerUpActionName)
            powerUpGroup.run(SKAction.fadeAlpha(to: 0.0, duration: 0.3))
            
        }
        
        let gameOverLabel = SKLabelNode(text: "Game Over!")
        gameOverLabel.fontColor = UIColor.yellow
        gameOverLabel.fontName = "AvenirNext-Bold"
        gameOverLabel.position = CGPoint(x: 0.0, y: -4.0)
        gameOverLabel.fontSize = 50.0
        addChild(gameOverLabel)
        
    /*    let restartLevel = SKNode()
        
        restartLabel.text = "Play Again?"
        restartLabel.fontSize = 30.0
        restartLabel.fontColor = SKColor.yellow
        restartLabel.zPosition = 1
        restartLabel.position = CGPoint(x: 0.0, y: -150.0)
        self.addChild(restartLabel)
        */
    }
    
  

    
    
    

}// End Of Code
