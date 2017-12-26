//
//  GameScene.swift
//  SpaceRun
//
//  Created by Chelsey on 11/22/17.
//  Copyright © 2017 Chelsey Fay. All rights reserved.
//
/*
 */

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    // Constants
    private var SpaceshipNodeName = "ship"
    private let PhotonTorpedoName = "photon"
    private let ObstacleNodeName = "obstacle"
    private let PowerUpNodeName = "powerup"
    private let HealthNodeName = "health"
    private let HUDNodeName = "hudNode"
    private let CoinNodeName = "coin"
    
    var livesArray:[SKSpriteNode]!
    var levelNumber = 0
    
    //Properties to hold sound actions. We will be preloading the sounds into these properties, so there is no delay when they are implemented for the first time.
    
    private let gameSound: SKAction = SKAction.playSoundFileNamed("spaceSound.mp3", waitForCompletion: false)
    private let shootSound: SKAction = SKAction.playSoundFileNamed("laserShot.wav", waitForCompletion: false)
     private let obstacleExplodeSound: SKAction = SKAction.playSoundFileNamed("darkExplosion.wav", waitForCompletion: false)
     private let shipExplode: SKAction = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    private let loseALife: SKAction = SKAction.playSoundFileNamed("lostHealth.mp3", waitForCompletion: false)
    private let collectCoins: SKAction = SKAction.playSoundFileNamed("coins:health.wav", waitForCompletion: false)
    private let collectPowerUps: SKAction = SKAction.playSoundFileNamed("powerUp.wav", waitForCompletion: false)
    // Add a sound when collecting coins
    

    // Add a sound when ship upgrades
    /*
      private let levelUpSound: SKAction = SKAction.playSoundFileNamed(".wav", waitForCompletion: false)
      private let gain: SKAction = SKAction.playSoundFileNamed("laseShot.wav", waitForCompletion: false)
     */
    
    // We will be using the explosion particle emitters over and over. We don't want to load them from the .sks files every time we need them. So instead we'll create properties and load (cache) them for quick reuse.
    private let shipExplodeTemplate: SKEmitterNode = SKEmitterNode.nodeWithFile("shipExplode.sks")!
    private let obstacleExplodeTemplate: SKEmitterNode = SKEmitterNode.nodeWithFile("obstacleExplode.sks")!

    
    private let defaultFireRate: Double = 0.5
    private let powerUpDuration: TimeInterval = 5.0
    
    
    //Variables
    private weak var shipTouch: UITouch?
    private var lastUpdateTime: TimeInterval = 0
    private var lastShotFireTime: TimeInterval = 0
    private var shipFireRate: Double = 0.5
    private var timeInterval = 0.75
    
    
   //Initializer
    override init(size: CGSize) {
        super.init(size: size)
        setupGame(size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        let touchPoint = touch!.location(in: self)
        
        if let ship = self.childNode(withName: SpaceshipNodeName) {
            ship.position = touchPoint
        }
        self.shipTouch = touch
    
    
        
    }

    
    func setupGame(_ size: CGSize) {
        // Creates the sprite and displays on game scene
        let ship = SKSpriteNode(imageNamed: "Spaceship.png")
        ship.position = CGPoint(x: size.width/2.0, y: size.height/4.5)
        ship.size = CGSize(width: 40.0, height: 50.0)
        ship.name = SpaceshipNodeName
        addLives()
        addChild(ship)
        run(gameSound)
        
        
        // Add ship thruster particle effect to our ship
        if let thrust = SKEmitterNode.nodeWithFile("thrust.sks"){
            thrust.position = CGPoint(x: 0.0, y: -20.0)
            
            // Now add thrust as a child of our ship sprite so its position is relative to the ship's position
            ship.addChild(thrust)
        }
        // set up our HUD
        
        let hudNode = HUDNode()
        hudNode.name = HUDNodeName
        hudNode.startGame()
        
        // By default, nodes will overlap (stack) according to the order in which they were added to the scene. If we wish to alter the stacking order. We can use a node's zPosition property to do so.
        hudNode.zPosition = 100.0
        
        // Set position of hudNode to be at the center of the screen (scene).
        // All of the child nodes we will add to the HUD Node will be positioned relative to the HUD node's origin node.
        hudNode.position = CGPoint(x: size.width/2.0 , y: size.height/2.0)
        addChild(hudNode)
        
        hudNode.layoutForScene()
        
        // Start the game already...
        hudNode.startGame()
        
        
        
        // Add the star field parallax effect to the scene by creating an instance of our star field class and adding it as a child of our scene
        addChild(StarField())

    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        // Calculate the time change (delta) since the last frame was rendered
        let timeDelta = currentTime - lastUpdateTime
        
        if let shipTouch = shipTouch {
            
            
         /*   if let ship = self.childNode(withName: SpacehipNodeName) {
                ship.position = shipTouch.location(in: self) //Reposition the ship
                
            } */
            
           moveShipTowardPoint(shipTouch.location(in: self), timeDelta: timeDelta)
            
            if currentTime - lastShotFireTime > shipFireRate {
                shoot()
                
                lastShotFireTime = currentTime
            }
        }
        
        // Release asteroids 1.5% of the time a frame is drawn
        // Note that this number could be increased to make the game difficult.

        
        if arc4random_uniform(1000) <= 15 {
            dropThing()
        }
        
        // Collision Detection
        checkCollisions()
        lastUpdateTime = currentTime
    }
    
    func moveShipTowardPoint(_ point: CGPoint, timeDelta: TimeInterval) {
        
        // Points per second the ship should travel
        let shipSpeed = CGFloat(230)
        
        if let ship = self.childNode(withName: SpaceshipNodeName) {
            
            // Determine the distant between the ships current position and the touch point. using the Pythagorean theorem. (a2 + b2 = c2| square root of c2)
            let distanceLeftToTravel = sqrt(pow(ship.position.x - point.x, 2) + pow(ship.position.y - point.y, 2))
            
            // If distance remaining is greater than 4 points, keep moving the ship.
            // If we don't stop the ship, it may jitter due to the imprrecision in floating numbers
            
            if distanceLeftToTravel > 4 {
            // Calculate how far we should move during the frame
                
                let distanceRemaining = CGFloat(timeDelta) * shipSpeed
            
                //Convert the distance remaining back into (x,y) coordinates
                // Using atan2() to determine the proper angle based on the ship's position and destination
                
                let angle = atan2(point.y - ship.position.y, point.x - ship.position.x)
                
                // Using an angle along with sin() and cos() functions, determine the x and y offset values
                let xOffset = distanceRemaining * cos(angle)
                let yOffset = distanceRemaining * sin(angle)
                
                // Use the offest values to reposition the ship for this frame
                ship.position = CGPoint(x: ship.position.x + xOffset, y: ship.position.y + yOffset)
                
            }
            
        }
        
    }
    
    //
    // Shoot a photon torpedo
    //
    /* Double torpedos when get a maxNode */
    
    func shoot() {
        
        if let ship = self.childNode(withName: SpaceshipNodeName) {

            
            // Create a photon torpedo sprite node
            let photon = SKSpriteNode(imageNamed: PhotonTorpedoName)
            
            photon.name = PhotonTorpedoName
            photon.position = ship.position
            
            self.addChild(photon)
            
            // Setup actions for the photon sprite
            // Setup the sprite to move,
            let fly = SKAction.moveBy(x: 0, y: self.size.height + photon.size.height
                , duration: 0.5)
            
            let remove = SKAction.removeFromParent()
            
            let fireAndRemove = SKAction.sequence([fly, remove])
            
            photon.run(fireAndRemove)
            
            self.run(self.shootSound)
            
            // Create double torpedos when reach level
        }
    }
    
    

    
    // Drop something from top of scene
    // Can add additional items to such as health items, and other enemies
    //
    func dropThing() {
        
        let dieRoll = arc4random_uniform(100)
    
        if dieRoll < 20 {
            dropPowerUp()
        } else if dieRoll < 30 {
            healthPowerUp()
        }else if dieRoll < 25 {
            dropCoins()
        } else if dieRoll < 45 {
            dropEnemyShip()
        } else {
            dropAsteroid()
        }
    }
    
    
    //
    // Drop an Asteroid onto the scene
    //
    func dropAsteroid() {
        
        // Define asteroid size. Random number between 15 and 44
        
        let sideSize = Double(15 + arc4random_uniform(30))
        
        // Maximum x-position for the scene
        let maxX = Double(self.size.width)
        
        let quarterX = maxX / 4.0
        
        // Determine random starting point for Asteroid
        let startX = Double(arc4random_uniform(UInt32(maxX + (quarterX * 2)))) - quarterX
        
        // Above the top edge of scene
        let startY = Double(self.size.height) + sideSize
        
        //Determine ending position of asteroid
        let endX = Double(arc4random_uniform(UInt32(maxX)))
        let endY = 0.0 - sideSize
        
        // Create asteroid sprite
        let asteroid = SKSpriteNode(imageNamed: "asteroidsprite")
        asteroid.size = CGSize(width: sideSize, height: sideSize)
        asteroid.position = CGPoint(x: startX, y: startY)
        asteroid.name = ObstacleNodeName
        
        self.addChild(asteroid)
        
        /* fly = SKAction.moveBy(x: 0, y: self.size.height + photon.size.height
         , duration: 0.5)*/
        
        // Get the astroid moving
      
        let move = SKAction.move(to: CGPoint(x: endX, y: endY), duration: Double(3 + arc4random_uniform(5)))
        
        let remove = SKAction.removeFromParent()
        let travelAndRemove = SKAction.sequence([move, remove])
        
        // rotate the asteroid by 3 radians, just less than 180 degrees over a 1-3 sec duration
        let spin = SKAction.rotate(byAngle: 3, duration: Double(arc4random_uniform(3) + 1))
        
        let spinForever = SKAction.repeatForever(spin)
 
        let all = SKAction.group([spinForever, travelAndRemove])
            
        
        asteroid.run(all)
      
    }
    
    // Drop a weapons powerup
    // Create a powerup sprite that spins and moves from top to bottom of screen
    // Learn how to double the weapons
    func dropPowerUp() {
        
        let sideSize = 30.0
        
        let startX = Double(arc4random_uniform(uint(self.size.width - 60)) + 30)
        
        let startY = Double(self.size.height) + sideSize
        
        // Create a powerup sprite and set its properties
        let powerUp = SKSpriteNode(imageNamed: "powerup")
        
        powerUp.size = CGSize(width: sideSize, height: sideSize)
        powerUp.position = CGPoint(x:startX, y:startY)
        
        powerUp.name = PowerUpNodeName
        
        self.addChild(powerUp)
        
        let powerUpPath = createBezierPath()
        
        // Actions for the sprite
        powerUp.run(SKAction.sequence([SKAction.follow(powerUpPath, asOffset: true, orientToPath: true, duration: 5.0), SKAction.removeFromParent()]))
        
    }
    

    
    // Add points
     func dropCoins() {
     
     let sideSize = 30.0
     
     let startX = Double(arc4random_uniform(uint(self.size.width - 60)) + 30)
     
     let startY = Double(self.size.height) + sideSize
     
     // Create a powerup sprite and set its properties
     let coins = SKSpriteNode(imageNamed: "coin")
     
     coins.size = CGSize(width: sideSize, height: sideSize)
     coins.position = CGPoint(x:startX, y:startY)
     
     coins.name = CoinNodeName
     
     self.addChild(coins)
     
     let coinPath = createBezierPath()
     
     // Actions for the sprite
     coins.run(SKAction.sequence([SKAction.follow(coinPath, asOffset: true, orientToPath: true, duration: 5.0), SKAction.removeFromParent()]))
     
     }
 

    func addLives(){
        livesArray = [SKSpriteNode]()
        
        for live in 1 ... 4 {
            let liveNode = SKSpriteNode(imageNamed: "Spaceship.png")
            liveNode.size = CGSize(width: 20.0, height: 30.0)
            liveNode.position = CGPoint(x: self.frame.size.width - CGFloat(5 - live) * liveNode.size.width, y: self.frame.size.height - 20)
            self.addChild(liveNode)
            livesArray.append(liveNode)
        }
    }
    
    
    
    // Drop a health powerup
    func healthPowerUp(){
        let sideSize = 30.0
        
        let startX = Double(arc4random_uniform(uint(self.size.width - 60)) + 30)
        
        let startY = Double(self.size.height) + sideSize
    
        let healthNode = SKSpriteNode(imageNamed: "healthPowerUp.jpg")
        healthNode.size = CGSize(width: sideSize, height: sideSize)
        healthNode.position = CGPoint(x:startX, y:startY)
        
        healthNode.name = HealthNodeName
        
        self.addChild(healthNode)
        
        let healthPath = createBezierPath()
        
        // Actions for the sprite
        healthNode.run(SKAction.sequence([SKAction.follow(healthPath, asOffset: true, orientToPath: true, duration: 5.0), SKAction.removeFromParent()]))
        
    
    }
    

    
    func dropEnemyShip(){
      
        // Define enemy ship size.
        let sideSize = 30.0
        
        // Determine random starting point for Asteroid
        let startX = Double(arc4random_uniform(UInt32(self.size.width - 40)) + 20)
        
        // Above the top edge of scene
        let startY = Double(self.size.height) + sideSize
        
        // Create enemy sprite
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.size = CGSize(width: sideSize, height: sideSize)
        enemy.position = CGPoint(x: startX, y: startY)
        enemy.name = ObstacleNodeName
        
        self.addChild(enemy)
        /* fly = SKAction.moveBy(x: 0, y: self.size.height + photon.size.height
         , duration: 0.5)*/
        // Get the enemy ship moving
        
        let shipPath = createBezierPath()
        
        // Perform actions to fly our ship along the path
        // asOffset: a true value lets us treat the action point values as offsets from the enemy ships starting point. A false value would treat the path's points as absolute positions on the screen
        // orientToPath: true causes the enemy ship to turn and face the direction of the path automatically
        //
        let followPath = SKAction.follow(shipPath, asOffset: true, orientToPath: true, duration: 7.0)
        
        enemy.run(SKAction.sequence([followPath, SKAction.removeFromParent()]))
    }
    

    
    func createBezierPath() -> CGPath {
        
        let yMax = -1.0 * self.size.height
        
        // Bezier path using two control points along a line to create a curved path. We'll use the UIBezierPath class to build this kind of object.
        // Bezier path produced using the paintcode app (www.paintcodeapp.com)
        let bezierPath = UIBezierPath()
    
        bezierPath.move(to: CGPoint(x: 0.5, y: -0.5))
        
        bezierPath.addCurve(to: CGPoint(x: -2.5, y: -59.5), controlPoint1: CGPoint(x: 0.5, y: -0.5), controlPoint2: CGPoint(x: 4.55, y: -29.48))
        
        bezierPath.addCurve(to: CGPoint(x: -27.5,y: -154.5), controlPoint1: CGPoint(x: -9.55, y: -89.52), controlPoint2: CGPoint(x: -43.32,y: -115.43))
        
        bezierPath.addCurve(to: CGPoint(x: 30.5, y: -243.5), controlPoint1: CGPoint(x: -11.68, y: -193.57), controlPoint2: CGPoint(x: 17.28, y: -186.95))
        
        bezierPath.addCurve(to: CGPoint(x: -52.5, y: -379.5), controlPoint1: CGPoint(x: 43.72, y: -300.05), controlPoint2: CGPoint(x: -47.71, y: -335.76))
        
        bezierPath.addCurve(to: CGPoint(x: 54.5, y: -449.5), controlPoint1: CGPoint(x: -57.29, y: -423.24), controlPoint2: CGPoint(x: -8.14, y: -482.45))
        
        bezierPath.addCurve(to: CGPoint(x: -5.5, y: -348.5), controlPoint1: CGPoint(x: 117.14, y: -416.55), controlPoint2: CGPoint(x: 52.25, y: -308.62))
        
        bezierPath.addCurve(to: CGPoint(x: 10.5, y: -494.5), controlPoint1: CGPoint(x: -63.25, y: -388.38), controlPoint2: CGPoint(x: -14.48, y: -457.43))
        
        bezierPath.addCurve(to: CGPoint(x: 0.5, y: -559.5), controlPoint1: CGPoint(x: 23.74, y: -514.16), controlPoint2: CGPoint(x: 6.93, y: -537.57))
        
        //bezierPath.addCurveToPoint(CGPointMake(-2.5, -644.5), controlPoint1: CGPointMake(-5.2, -578.93), controlPoint2: CGPointMake(-2.5, -644.5))
        
        bezierPath.addCurve(to: CGPoint(x: -2.5, y: yMax), controlPoint1: CGPoint(x: -5.2, y: yMax), controlPoint2: CGPoint(x: -2.5, y: yMax))
        
        return bezierPath.cgPath
    }
    
    
    
    func checkCollisions(){
        
        if let ship = self.childNode(withName: SpaceshipNodeName) {
            
            //Powerups should go up here
            // Set up an if statement for lives
            enumerateChildNodes(withName: CoinNodeName) {
                coins, _ in
                
                if ship.intersects(coins) {
                     self.run(self.collectCoins)
                    
                    coins.removeFromParent()
                    
                    // Update score
                    if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode?
                    {
                        hud.addPoints(20)
                        
                    }
                    
                    
                }
                
                
            }
        
            
            // If ship bumps into a powerup, remove powerup from scene and reset the shipFireRate to 0.1 to increase the ship's firing rate
            enumerateChildNodes(withName: PowerUpNodeName) {
                powerUp, _ in
                if ship.intersects(powerUp) {
                    
                     self.run(self.collectPowerUps)
                    // Ship, obstacle, and touch go away
                    powerUp.removeFromParent()
                    
                    if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                        hud.showPowerupTimer(self.powerUpDuration)
                    }
                    
                    // Increase ship's firing rate
                    self.shipFireRate = 0.1
                    // But, we need to power back down after a short delay
                    // so we are not unbeatable == boring
                    let powerDown = SKAction.run {
                        self.shipFireRate = self.defaultFireRate
                    }
                    
                    // Now, let's set up a delay before the powerDown occurs
                    let wait = SKAction.wait(forDuration: self.powerUpDuration)
                   // ship.run(SKAction.sequence([wait, powerDown]))
                   // If we collect an additional powerup while one is already in progress, we need to stop the one in progress and start a new one so we always get the full duration for the new one.
                    // Sprite kit lets us run actions with a key that we can then use to identify and remove the action before it has a chance to run or before it finishes if it is already running.
                    //
                    // If no key is found, nothing happens...
                    //
                    let powerDownActionKey = "waitAndPowerDown"
                    ship.removeAction(forKey: powerDownActionKey)
                    ship.run(SKAction.sequence([wait, powerDown]), withKey: powerDownActionKey)
                }
            }
            enumerateChildNodes(withName: HealthNodeName) {
                healthNode, _ in
                
                if ship.intersects(healthNode) {
                    if self.livesArray.count < 4 {
            
                        for live in 1 ... 4 {
                            let addHealth = SKSpriteNode(imageNamed: "Spaceship.png")
                            addHealth.size = CGSize(width: 20.0, height: 30.0)
                            addHealth.position = CGPoint(x: self.frame.size.width - CGFloat(5 - live) * addHealth.size.width, y: self.frame.size.height - 20)
                            self.addChild(addHealth)
                            self.livesArray.append(addHealth)
                            
                            
                            self.run(self.collectPowerUps)
                            
                            healthNode.removeFromParent()

                        }
                    }
                    

                }
            } // End HealthPowerUp
            
            
            // Loop through all instances of obstacles in the Scene Graph node tree
            enumerateChildNodes(withName: ObstacleNodeName) {
                obstacle, _ in
                
                if ship.intersects(obstacle) {
                //We need to call the copy method on the shipExplodeTemplate node, because node can only be added to a scene once.
                    // If we try to add a node again that already exists in a scene, the game will crash with an error. We will use the emitternodetemplate in our cache property as a template from which to make copies.
                    //Display a message on screen to show lives left
                    // If statement for end of lives and game over and
                    // register username (3 characters) for high point user
                    // Update score
                    

                    if self.livesArray.count > 0 {
                        
                        let liveNode = self.livesArray.first
                        
                        
                        self.run(self.loseALife)

                        liveNode?.removeFromParent()
                        self.livesArray.removeFirst()
                        obstacle.removeFromParent()
                        
                    }
                      if self.livesArray.count == 0  {
                
                            let explosion = self.shipExplodeTemplate.copy() as! SKEmitterNode
                            explosion.position = ship.position
                            explosion.dieOutInDuration(0.3)
                            self.addChild(explosion)
                            
                            self.run(self.shipExplode)
                            
                            // Ship, obstacle, and touch go away
                            ship.removeFromParent()
                            obstacle.removeFromParent()
                        
                        if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode?
                        {
                            hud.endGame()
                            
                        } // End of hudEndGame
                        
                    }
                }
                
              
                
                //Need to use self to reference our class because we are inside a closure that affects scope.
                self.enumerateChildNodes(withName: self.PhotonTorpedoName) {
                    collide, stop in
                    
                    // Set up a reaction to ship colliding with asteroid
                    if collide.intersects(obstacle) {
                        
                        // Obstabcle goes away
                        collide.removeFromParent()
                        obstacle.removeFromParent()
                        
                        
                        self.run(self.obstacleExplodeSound)
                        
                        let obExplosion = self.obstacleExplodeTemplate.copy() as! SKEmitterNode
                        obExplosion.position = obstacle.position
                        obExplosion.dieOutInDuration(0.1)
                        self.addChild(obExplosion)
                        
                        
                        // Update score
                        if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode?
                        {
                            hud.addPoints(10)
                            
                        }
                
                        // This is similar to a break statement
                       stop.pointee = true
                    }
                    
                    
                }
            }
        }
    
    }
}
