//
//  messageTableViewController.swift
//  Movie Radar
//
//  Created by Yang Yang on 11/8/17.
//  Copyright © 2017 Yang Yang. All rights reserved.
//

import UIKit
import Firebase

class messageTableViewController: UITableViewController {

    let messageModel = MessageModel.sharedInstance
    let userModel = UserModel.sharedInstance
    var requestUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Friend Requests"
        guard let uid = Auth.auth().currentUser?.uid else {return}
        friendRequestsUsersToUserWith(userId:uid)
    }

    func friendRequestsUsersToUserWith(userId:String){
 
        let reference = Database.database().reference().child("friendRequestTo").child(userId)
        reference.observe(.childAdded, with: { (snapshot) in
            let uid = snapshot.key
            let userReference = Database.database().reference().child("users").child(uid)
            userReference.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String:AnyObject]{
                    let user = self.userModel.setUserWith(uid: uid, dictionary: dictionary)

                    user.setValuesForKeys(dictionary)
                    self.requestUsers.append(user)
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
        
        return requestUsers.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! messageTableViewCell

        // Configure the cell...
        let user = requestUsers[indexPath.row]
        cell.emailLabel.text = user.email
        cell.usernameLabel.text = user.username
        if let profileImageUrl = user.profileImageUrl{
            cell.profileImageView.loadImageUsingCacheWith(urlString: profileImageUrl)
        }
        
        cell.acceptButton.addTarget(self, action: #selector(acceptContact(sender:)), for: .touchUpInside)
        cell.rejectButton.addTarget(self, action: #selector(rejectContact(sender:)), for: .touchUpInside)
        cell.acceptButton.tag = indexPath.row
        cell.rejectButton.tag = indexPath.row

        return cell
    }
    func acceptContact(sender: UIButton){
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let user = requestUsers[indexPath.row]
        let reference = Database.database().reference().child("email-user").child(messageModel.encodeUserEmailToKey(email: user.email!))
        reference.observe(.childAdded, with: { (snapshot) in
            let uid = snapshot.key
            let currentUid = Auth.auth().currentUser?.uid
            Database.database().reference().child("user-contacts").child(currentUid!).updateChildValues([uid:1])
            Database.database().reference().child("user-contacts").child(uid).updateChildValues([currentUid!:1])
            self.messageModel.deleteFriendRequest(toId: (Auth.auth().currentUser?.uid)!, FromId: uid)
            self.requestUsers.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            DispatchQueue.main.async(){
                self.tableView.reloadData()
            }
        })
        
    }
    func rejectContact(sender: UIButton){
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let user = requestUsers[indexPath.row]
        let reference = Database.database().reference().child("email-user").child(messageModel.encodeUserEmailToKey(email: user.email!))
        reference.observe(.childAdded, with: { (snapshot) in
            let uid = snapshot.key
            self.messageModel.deleteFriendRequest(toId: (Auth.auth().currentUser?.uid)!, FromId: uid)
            self.requestUsers.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            DispatchQueue.main.async(){
                self.tableView.reloadData()
            }
        })
    }
    
}
