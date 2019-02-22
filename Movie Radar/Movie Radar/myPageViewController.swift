//
//  myPageViewController.swift
//  Movie Radar
//
//  Created by Yang Yang on 11/2/17.
//  Copyright © 2017 Yang Yang. All rights reserved.
//

import UIKit
import Firebase

class myPageViewController: UIViewController  {
    

    @IBOutlet weak var userInfoView: UIView!

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var numberOfPostsLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var messageButton: UIBarButtonItem!
    
    var user: User?
    let userModel = UserModel.sharedInstance
    let postModel = PostModel.sharedInstance
    
    var username=""{
        didSet{
            usernameLabel.text="Username: \(username)"
        }
    }
    var numberOfPosts=0{
        didSet{
            numberOfPostsLabel.text="Total number of posts: \(numberOfPosts)"
        }
    }
    var email=""{
        didSet{
            emailLabel.text="Email: \(email)"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameLabel.text="Username:"
        numberOfPostsLabel.text="Total number of posts: 0"
        emailLabel.text="Email:"
        
        if Auth.auth().currentUser?.uid == nil{
            //user is not logged in
            perform(#selector(handleLogOut), with: nil, afterDelay: 0)
        }else{
            //user logged in
            fetchUser()
        }
        
       
    }

    
    @IBAction func logOutAccount(_ sender: UIButton) {
        handleLogOut()
    }
    
    func handleLogOut(){
        do{
            try Auth.auth().signOut()
            print("user has been logged out")
        }catch let logoutError{
            print(logoutError.localizedDescription)
        }
        performSegue(withIdentifier: "logout", sender: self)
    }
    
    func fetchUser(){
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject]{
                let user = self.userModel.setUserWith(uid: uid!, dictionary: dictionary)
                self.email = user.email!
                self.username = user.username!
                Database.database().reference().child("user-posts").child(uid!).observe(.value, with: { (snapshot) in
                    self.numberOfPosts = Int(snapshot.childrenCount)
                }, withCancel: nil)
                if let profileImageUrl = user.profileImageUrl{
                    self.profileImageView.loadImageUsingCacheWith(urlString: profileImageUrl)
                }
                self.user = user
            }
        })
    }
    
    @IBAction func viewMyPosts(_ sender: UIButton) {
        let postsViewController = self.storyboard?.instantiateViewController(withIdentifier: "allPosts") as! postsTableViewController
        postsViewController.configure(user: user!, isCurrentUser: true)
        show(postsViewController, sender: self)
        
    }
    

}
