//
//  postsTableViewController.swift
//  Movie Radar
//
//  Created by Yang Yang on 11/7/17.
//  Copyright © 2017 Yang Yang. All rights reserved.
//

import UIKit
import Firebase

class postsTableViewController: UITableViewController {

    var user: User?
    var isCurrentUser: Bool!
    var posts = [Post]()
    let postModel = PostModel.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
       //self.navigationItem.rightBarButtonItem = self.editButtonItem
        if let user = self.user{
            self.title = "\(user.username!)'s posts"
            fetchPosts()
        }
    }
    func configure(user:User,isCurrentUser:Bool){
        self.user = user
        self.isCurrentUser = isCurrentUser
    }
    func fetchPosts(){
        let uid = self.user?.uid
        let userPostsReference = Database.database().reference().child("user-posts").child(uid!)
        userPostsReference.observe(.childAdded, with: { (snapshot) in
            let postKey = snapshot.key
            let postReference = Database.database().reference().child("posts").child(postKey)
            postReference.observe(.value, with: { (postSnapshot) in
                if let dictionary = postSnapshot.value as? [String:AnyObject]{
                    let post = self.postModel.setPostWith(uid: postKey, dictionary: dictionary)
                    self.posts.append(post)
                    DispatchQueue.main.async(){
                        self.tableView.reloadData()
                    }
                }
            }, withCancel: nil)
            
        }, withCancel: nil)
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: postCellIdentifier, for: indexPath) as! postsTableViewCell

        // Configure the cell...
        let post = posts[indexPath.row]
        cell.genreLabel.text = post.genre
        cell.movieNameLabel.text = post.title
        cell.dateLabel.text = postModel.setDate(timestamp: post.timestamp!)
        postModel.setRatingStarsWith(ratingStars: cell.ratingStars, rating: post.rating!)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postViewController = self.storyboard?.instantiateViewController(withIdentifier: "postViewController") as! postViewController
        
        if isCurrentUser{
            postViewController.deleteButtonIsHidden = false
            postViewController.bookMarkButtonIsHidden = true
        }else{
            postViewController.deleteButtonIsHidden = true
            postViewController.bookMarkButtonIsHidden = false
        }
        postViewController.configure(post: posts[indexPath.row], indexPath: indexPath)
        show(postViewController, sender: self)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }*/
    @IBAction func prepareForUnwindToPostsTable(segue: UIStoryboardSegue){
        let postViewController = segue.source as! postViewController
        let indexPath = postViewController.indexPath!
        posts.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .fade)
    }
}
