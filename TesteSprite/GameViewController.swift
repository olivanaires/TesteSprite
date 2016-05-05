//
//  GameViewController.swift
//  TesteSprite
//
//  Created by Olivan Aires on 09/12/15.
//  Copyright (c) 2015 Olivan Aires. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let scene = GameScene( size: view.bounds.size )
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .AspectFill
        skView.presentScene(scene)
    }
   
}