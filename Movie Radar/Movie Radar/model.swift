//
//  model.swift
//  Movie Radar
//
//  Created by Yang Yang on 11/2/17.
//  Copyright © 2017 Yang Yang. All rights reserved.
//

import Foundation
import Firebase



class UserModel{
    static let sharedInstance = UserModel()
   
    init(){
        
    }
    func setUserWith(uid: String, dictionary: [String:AnyObject])->User{
        let user = User()
        user.uid = uid
        user.email = dictionary["email"] as? String
        user.username = dictionary["username"] as? String
        user.profileImageUrl = dictionary["profileImageUrl"] as? String
        user.contacts = dictionary["contacts"] as? [String : Bool]
        user.bookmarks = dictionary["bookmarks"] as? [String : Bool]
        return user
    }   
}
class MessageModel{
    static let sharedInstance = MessageModel()
    
    
    init(){
        
    }
    
    func messagesOfUserWith(uid: String)->[Message]?{
        return nil
    }
    func encodeUserEmailToKey(email: String)->String {
        return email.replacingOccurrences(of: ".", with: ",")
    }
    func decodeKeyToUserEmail(key: String)->String {
        return key.replacingOccurrences(of: ",", with: ".")
    }

    
    func sendFriendRequest(fromId: String, toEmail: String){
        let reference = Database.database().reference().child("email-user").child(encodeUserEmailToKey(email: toEmail))
        reference.observe(.childAdded, with: { (snapshot) in
            let toId = snapshot.key
            let fromReference = Database.database().reference().child("friendRequestFrom").child(fromId)
            let values = [toId:1]
            fromReference.updateChildValues(values)
            let toReference = Database.database().reference().child("friendRequestTo").child(toId)
            toReference.updateChildValues([fromId:1])
            print("successfully sent request")
            return
        }, withCancel: nil)
    }
    
    func deleteFriendRequest(toId: String, FromId:String){
        Database.database().reference().child("friendRequestTo").child(toId).child(FromId).removeValue()
        Database.database().reference().child("friendRequestFrom").child(FromId).child(toId).removeValue()
    }
    
}

class PostModel{
    static let sharedInstance = PostModel()
    init(){
        
    }
    func setPostWith(uid: String, dictionary: [String:AnyObject])->Post{
        let post = Post()
        post.uid = uid
        post.title = dictionary["title"] as? String
        post.author = dictionary["author"] as? String
        post.comments = dictionary["comments"] as? String
        post.genre = dictionary["genre"] as? String
        post.posterImageUrl = dictionary["posterImageUrl"] as? String
        post.rating = dictionary["rating"] as? Int
        post.timestamp = dictionary["timestamp"] as? Int
        return post
        
    }
    
    func setRatingStarsWith(ratingStars:[UIImageView], rating:Int){
        for star in ratingStars{
            if star.tag > rating{
                star.image = UIImage(named: "star")
            }else{
                star.image = UIImage(named: "star-filled")
            }
        }
    }
    func setDate(timestamp: Int)->String{
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "EST")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }

    
    func deletePost(postUid: String, userUid:String){
        Database.database().reference().child("posts").child(postUid).removeValue()
        Database.database().reference().child("user-posts").child(userUid).child(postUid).removeValue()
    }
    
}






