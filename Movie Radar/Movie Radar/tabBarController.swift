//
//  tabBarController.swift
//  Movie Radar
//
//  Created by Yang Yang on 11/9/17.
//  Copyright © 2017 Yang Yang. All rights reserved.
//

import UIKit

class tabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.tintColor = UIColor.white
        self.tabBar.barTintColor = UIColor(red: 0.211, green: 0.238, blue: 0.300, alpha: 1.00)
        self.tabBar.isTranslucent = false
        /*
        let itemWidth = self.view.frame.width / 5
        let itemHeight = self.tabBar.frame.height
        let frame = CGRect(x: itemWidth*2, y: self.view.frame.height - itemHeight, width: itemWidth - 10, height: itemHeight)
        
        let button = UIButton(frame: frame)
        button.setBackgroundImage(UIImage(named: "tab-bar-add-2"), for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(createPost), for: .touchUpInside)
        self.view.addSubview(button)
    
        */
    }/*
    func createPost(){
        self.selectedIndex = 2
    }
*/
    
}
