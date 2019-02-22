//
//  ratePostsViewController.swift
//  Movie Radar
//
//  Created by Yang Yang on 11/8/17.
//  Copyright © 2017 Yang Yang. All rights reserved.
//

import UIKit

class ratePostsViewController: UIViewController {

    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var heartImageView: UIImageView!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var buttonCircleView: UIView!
    @IBOutlet weak var showInfoButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawInterface()
        
    }

    func drawInterface(){
        buttonCircleView.layer.cornerRadius = buttonCircleView.frame.width / 2
        infoView.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant:  -(self.tabBarController?.tabBar.frame.height)! - 10).isActive = true
    }

    @IBAction func panCard(_ sender: UIPanGestureRecognizer) {
        let card = sender.view!
        let point = sender.translation(in: view)
        card.center = CGPoint(x: view.center.x + point.x, y: view.center.y + point.y)
        
        let xMoved = card.center.x - view.center.x
        let divisor = (view.frame.width / 2) / cardRotateAngle
        let scale = min(100/abs(xMoved),1)
        card.transform = CGAffineTransform(rotationAngle: xMoved/divisor).scaledBy(x: scale, y: scale)
        
        if xMoved > 0 {
            heartImageView.image = UIImage(named: "like")
        }else if xMoved < 0 {
            heartImageView.image = UIImage(named: "dislike")
        }
        heartImageView.alpha = abs(xMoved) / view.center.x
        
        
        if sender.state == .ended{
            
            if card.center.x < MoveCardOffLimit{
                //move off to the left
                UIView.animate(withDuration: 0.2, animations: {
                    card.center = CGPoint(x: card.center.x - 200, y: card.center.y + MoveCardOffLimit)
                    card.alpha = 0
                    
                })
                return
            }else if card.center.x > view.frame.width - MoveCardOffLimit{
                //move off to the right
                UIView.animate(withDuration: 0.2, animations: {
                    card.center = CGPoint(x: card.center.x + 200, y: card.center.y + MoveCardOffLimit)
                    card.alpha = 0
                    
                })
                return
            }
            
            restCard()
        }
        
       
    }
    @IBAction func reset(_ sender: UIButton) {
        restCard()
    }
    func restCard(){
        UIView.animate(withDuration: 0.2) { 
            self.cardView.center = self.view.center
            self.heartImageView.alpha = 0
            self.cardView.alpha = 1
            self.cardView.transform = CGAffineTransform.identity
        }
    }
    @IBAction func showInfo(_ sender: UIButton) {
        let hiddenSpaceHeight = infoView.frame.height - 10 - buttonCircleView.frame.height
        if buttonCircleView.transform == CGAffineTransform.identity{
            UIView.animate(withDuration: 1) {
                self.buttonCircleView.transform = CGAffineTransform(scaleX: 15, y: 15)
                self.infoView.transform = CGAffineTransform(translationX: 0, y: -hiddenSpaceHeight)
                self.showInfoButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            }
        }else{
            UIView.animate(withDuration: 1) {
                self.buttonCircleView.transform = .identity
                self.infoView.transform = .identity
                self.showInfoButton.transform = .identity
            }
        }
    }

}
