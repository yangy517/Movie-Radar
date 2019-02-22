//
//  objects.swift
//  Movie Radar
//
//  Created by Yang Yang on 11/14/17.
//  Copyright © 2017 Yang Yang. All rights reserved.
//

import Foundation
import Firebase
// user-contacts
// user-posts
// posts
// users
// email-uid


class Message: NSObject{
    var fromId: String?
    var toId: String?
}

class Post: NSObject {
    var uid:String?
    var title: String?
    var author: String?
    var genre: String?
    var comments: String?
    var rating: Int?
    var posterImageUrl: String?
    var timestamp: Int?
}

class User: NSObject {
    var uid: String?
    var email: String?
    var username: String?
    var profileImageUrl: String?
    var contacts: [String:Bool]?
    var bookmarks: [String:Bool]?
}
