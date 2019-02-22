//
//  constants.swift
//  Movie Radar
//
//  Created by Yang Yang on 11/1/17.
//  Copyright © 2017 Yang Yang. All rights reserved.
//

import UIKit

extension UIColor{
    static let seperatorColor = UIColor(red:0.823, green:0.823, blue:0.840, alpha:1.00)
    static let mainBackgroundColor = UIColor(red:0.514, green:0.643, blue:0.773, alpha:1.00)
    static let contactCellEvenColor = UIColor(red: 0.635, green: 0.847, blue: 1.000, alpha: 1.00)
    static let contactCellOddColor = UIColor(red: 0.626, green: 0.801, blue: 0.961, alpha: 1.00)
}

extension String {
    func firstLetter()->String?{
        return (self.isEmpty ? nil : self.substring(to: self.characters.index(after: self.startIndex)))
    }
}

let customCornerRadius:CGFloat = 6
let textViewVisibleHeight:CGFloat = 40.0
//ratePosts
let MoveCardOffLimit:CGFloat = 75.0
let cardRotateAngle:CGFloat = 0.61

let contactCellIdentifier = "contactCell"
let postCellIdentifier = "postCell"
let Genres = ["Action","Adventure","Animation","Comedy","Crime","Documentary","Drama","Family","Fantasy","History","Horror","Music","Mystery","Romance","Science Fiction","TV Movie","Thriller","War","Western"]

let postUnwindSegueIdentifier = "unwindToPostsTable"
