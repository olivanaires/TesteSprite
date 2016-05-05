//
//  GameScene.swift
//  TesteSprite
//
//  Created by Olivan Aires on 09/12/15.
//  Copyright (c) 2015 Olivan Aires. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var hero: SKSpriteNode!
    let hero_walk = SKTextureAtlas(named: "hero_walk.atlas")
    let hero_walk_fire = SKTextureAtlas(named: "hero_walk_fire.atlas")
    let enemy_walk = SKTextureAtlas(named: "enemy_walk.atlas")
    
    var view_width: CGFloat!
    var view_height: CGFloat!
    var main_view: SKNode!

    var long_press_recognozer:UILongPressGestureRecognizer!
    var fire_animation_timer:NSTimer!
    
    var enemy_animation_time: NSTimer!
    
    var hero_y_position_inicial: CGFloat!
    
    let enemy_category: UInt32 = 0x1 << 1
    let bala_category: UInt32 = 0x1 << 0
    
    var escoreLabel: SKLabelNode!
    var escoreValue: Int = 0
    
    override func didMoveToView(view: SKView) {
        view_width = (self.view?.frame.width)!
        view_height = (self.view?.frame.height)!
        
        main_view = SKNode()
        self.addChild(main_view)
        
        escoreLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        escoreLabel.text = "Kills: \(escoreValue)"
        escoreLabel.fontSize = 30
        escoreLabel.fontColor = UIColor.blackColor()
        escoreLabel.position = CGPoint(x: escoreLabel.frame.width * 0.7, y: (self.view?.bounds.maxY)! - escoreLabel.frame.height * 1.5)
        main_view.addChild(escoreLabel)

        physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
        
        let world_border = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0, y: view_height/7, width: view_width + 100, height: view_height/3))
        world_border.friction = 0
        self.physicsBody = world_border
        self.physicsBody?.friction = 0
        self.physicsWorld.contactDelegate = self
        
        long_press_recognozer = UILongPressGestureRecognizer(target: self, action: #selector(GameScene.playerPressed(_:)))
        long_press_recognozer.minimumPressDuration = 0.001
        self.view?.addGestureRecognizer(long_press_recognozer)
        
        enemy_animation_time = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(2), target: self, selector: #selector(GameScene.addEnemy(_:)), userInfo: nil, repeats: true)
        
        criaBackground()
        criaHero()
    }
    
    func playerPressed(recognizer:UILongPressGestureRecognizer){
        
        if recognizer.state == UIGestureRecognizerState.Ended {
            if fire_animation_timer != nil {
                fire_animation_timer.invalidate()
                runForward()
            }
        } else if recognizer.state == UIGestureRecognizerState.Began{
            let local = recognizer.locationInView(self.view)
            if local.x < view_width / 2 {
                runAndFire()
                fire()
                fire_animation_timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.3), target: self, selector: #selector(GameScene.fireInterval(_:)), userInfo: nil, repeats: true)
            }
        } else if recognizer.state == UIGestureRecognizerState.Changed {
            let local = recognizer.locationInView(self.view)
            if local.x > view_width / 2 && fire_animation_timer != nil && hero.actionForKey("run_firing") != nil {
                runForward()
                fire_animation_timer.invalidate()
            }
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let local = touch.locationInNode(self)
            if local.x > self.size.width / 2 && hero.position.y < hero_y_position_inicial + 1 {
                hero.physicsBody?.velocity = CGVectorMake(0, 0)
                hero.physicsBody?.applyImpulse(CGVectorMake(0, 40))
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {

    }
   
    override func update(currentTime: CFTimeInterval) {
        
    }
    
    func addEnemy(timer:NSTimer) {
        let enemy: SKSpriteNode = SKSpriteNode(texture: enemy_walk.textureNamed("boss_walk01"))
        enemy.position = CGPoint(x: view_width + enemy.size.width, y: (view_height/6) + 5)
        enemy.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: enemy.size.width/5, height: enemy.size.height))
        enemy.physicsBody?.dynamic = true
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.categoryBitMask = enemy_category
        enemy.physicsBody?.contactTestBitMask = bala_category
        enemy.physicsBody?.collisionBitMask = 0
        enemy.xScale = hero.xScale * 1.5
        enemy.yScale = hero.yScale * 1.2
        main_view.addChild(enemy)
        
        runEnemyForward(enemy)
        
        let minDuration = 1
        let maxDuration = 3
        let rangeDuration = maxDuration - minDuration
        let duration = Int(arc4random()) % Int(rangeDuration) + Int(minDuration)
        
        var actionArray: [SKAction] = []
        actionArray.append(SKAction.waitForDuration(NSTimeInterval(duration)))
        actionArray.append(SKAction.moveByX(-view_width, y: 0, duration: NSTimeInterval(0.01 * view_width)))
        actionArray.append(SKAction.removeFromParent())
        enemy.runAction(SKAction.sequence(actionArray))
    }
    
    func fireInterval(timer:NSTimer) {
        self.fire()
    }
    
    func fire() {
        let bala = SKSpriteNode(imageNamed: "bala")
        bala.position = CGPointMake(hero.position.x + 30, hero.position.y - 2)
        bala.physicsBody = SKPhysicsBody(circleOfRadius: bala.size.height/3)
        bala.physicsBody?.dynamic = false
        bala.physicsBody?.categoryBitMask = bala_category
        bala.physicsBody?.contactTestBitMask = enemy_category
        bala.physicsBody?.collisionBitMask = 0
        bala.physicsBody?.usesPreciseCollisionDetection = true
        bala.setScale(0.2)
        
        main_view.addChild(bala)
        var actionArray: [SKAction] = []
        actionArray.append(SKAction.moveByX(view_width, y: 0, duration: NSTimeInterval(0.005 * view_width)))
        actionArray.append(SKAction.removeFromParent())
        bala.runAction(SKAction.sequence(actionArray))
    }
    
    func criaBackground() {
        let moveGroundSprite = SKAction.moveByX(-view_width, y: 0, duration: NSTimeInterval(0.02 * view_width))
        let resetGroundSprite = SKAction.moveByX(view_width, y: 0, duration: 0.0)
        let moveGroundSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveGroundSprite, resetGroundSprite]))
        let limit = 2.0 + view_width / (view_width * 2.0)
        for var i:CGFloat = 0; i < limit; ++i {
            let bg = SKSpriteNode(imageNamed: "bg3")
            bg.size = (self.view?.bounds.size)!
            bg.anchorPoint = CGPointZero
            bg.position = CGPointMake(i * view_width, 0)
            bg.zPosition = -1
            bg.physicsBody?.dynamic = false
            bg.runAction(moveGroundSpritesForever)
            main_view.addChild(bg)
        }
    }

    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & bala_category) != 0 && (secondBody.categoryBitMask & enemy_category) != 0 && firstBody.node != nil && secondBody.node != nil) {
            balaColidiuComInimigo(firstBody.node as! SKSpriteNode, inimigo: secondBody.node as! SKSpriteNode)
        }
    }
    
    func balaColidiuComInimigo(bala: SKSpriteNode, inimigo: SKSpriteNode) {
        bala.removeFromParent()
        inimigo.removeFromParent()
        escoreValue += 1
        escoreLabel.text = " Kills: \(escoreValue)"

    }
    
    func criaHero() {
        hero = SKSpriteNode(texture: hero_walk.textureNamed("bro5_walk0001"))
        hero_y_position_inicial = view_height/4
        hero.position = CGPointMake(view_width/4, view_height/6)
        hero.physicsBody = SKPhysicsBody(circleOfRadius: hero.size.height / 2.75)
        hero.setScale(main_view.xScale / 3)
        hero.physicsBody?.dynamic = true
        main_view.addChild(hero)
        runForward()
    }
    
    func runForward() {
        let hero_run_anim = SKAction.animateWithTextures([
            hero_walk.textureNamed("bro5_walk0001"),
            hero_walk.textureNamed("bro5_walk0002"),
            hero_walk.textureNamed("bro5_walk0003"),
            hero_walk.textureNamed("bro5_walk0004"),
            hero_walk.textureNamed("bro5_walk0005"),
            hero_walk.textureNamed("bro5_walk0006"),
            hero_walk.textureNamed("bro5_walk0007"),
            hero_walk.textureNamed("bro5_walk0008"),
            hero_walk.textureNamed("bro5_walk0009"),
            hero_walk.textureNamed("bro5_walk0010"),
            hero_walk.textureNamed("bro5_walk0011"),
            hero_walk.textureNamed("bro5_walk0012"),
            hero_walk.textureNamed("bro5_walk0013"),
            hero_walk.textureNamed("bro5_walk0014")
            ], timePerFrame: 0.06)
        
        let run = SKAction.repeatActionForever(hero_run_anim)
        hero.runAction(run, withKey: "hero_running")
        hero.removeActionForKey("run_firing")
    }
    
    func runAndFire() {
        let hero_run_fire_anim = SKAction.animateWithTextures([
            hero_walk_fire.textureNamed("bro5_walk_and_fire0001"),
            hero_walk_fire.textureNamed("bro5_walk_and_fire0002"),
            hero_walk_fire.textureNamed("bro5_walk_and_fire0003"),
            hero_walk_fire.textureNamed("bro5_walk_and_fire0004"),
            hero_walk_fire.textureNamed("bro5_walk_and_fire0005"),
            hero_walk_fire.textureNamed("bro5_walk_and_fire0006"),
            hero_walk_fire.textureNamed("bro5_walk_and_fire0007"),
            hero_walk_fire.textureNamed("bro5_walk_and_fire0008"),
            hero_walk_fire.textureNamed("bro5_walk_and_fire0009"),
            hero_walk_fire.textureNamed("bro5_walk_and_fire0010"),
            hero_walk_fire.textureNamed("bro5_walk_and_fire0011"),
            hero_walk_fire.textureNamed("bro5_walk_and_fire0012"),
            hero_walk_fire.textureNamed("bro5_walk_and_fire0013"),
            hero_walk_fire.textureNamed("bro5_walk_and_fire0014")
        ], timePerFrame: 0.1)
        
        let run = SKAction.repeatActionForever(hero_run_fire_anim)
        
        hero.runAction(run, withKey: "run_firing")
        hero.removeActionForKey("hero_running")
    }
    
    func runEnemyForward(enemy: SKSpriteNode) {
        let enemy_run_anim = SKAction.animateWithTextures([
            enemy_walk.textureNamed("boss_walk00"),
            enemy_walk.textureNamed("boss_walk01"),
            enemy_walk.textureNamed("boss_walk02"),
            enemy_walk.textureNamed("boss_walk03"),
            enemy_walk.textureNamed("boss_walk04"),
            enemy_walk.textureNamed("boss_walk05"),
            enemy_walk.textureNamed("boss_walk06"),
            enemy_walk.textureNamed("boss_walk07"),
            enemy_walk.textureNamed("boss_walk08"),
            enemy_walk.textureNamed("boss_walk09"),
            enemy_walk.textureNamed("boss_walk10"),
            enemy_walk.textureNamed("boss_walk11")
            ], timePerFrame: 0.06)

        enemy.runAction(SKAction.repeatActionForever(enemy_run_anim))
    }
    
}
