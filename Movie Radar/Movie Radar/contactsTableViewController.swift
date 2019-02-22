//
//  contactsTableViewController.swift
//  Movie Radar
//
//  Created by Yang Yang on 11/5/17.
//  Copyright © 2017 Yang Yang. All rights reserved.
//

import UIKit
import Firebase

class contactsTableViewController: UITableViewController,UISearchResultsUpdating,UISearchControllerDelegate  {

    var contacts = [User]()
    var contactsByKeys = [String: [User]]()
    var sectionTitles = [String]()
    
    let userModel = UserModel.sharedInstance
    
    var searchController: UISearchController!
    var resultController=UITableViewController()
    var filteredResults=[User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = self.editButtonItem
        fetchUsers()
        
        
       // resultController.tableView.register(contactsTableViewCell.self, forCellReuseIdentifier: "filteredContactCell")
        resultController.tableView.dataSource=self
        resultController.tableView.delegate=self
        searchController=UISearchController(searchResultsController: resultController)
        self.tableView.tableHeaderView=self.searchController.searchBar
        searchController.searchResultsUpdater=self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true

        
    }
   
    func updateSearchResults(for searchController: UISearchController) {
        filterSearchController(searchBar: searchController.searchBar)
    }
    func filterSearchController(searchBar: UISearchBar){
        
        filteredResults = contacts.filter({(user : User) -> Bool in
            return user.username!.lowercased().contains(searchBar.text!.lowercased())
        })
        
        self.resultController.tableView.reloadData()
    }
    
    func fetchUsers(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let reference = Database.database().reference().child("user-contacts").child(uid)
        
        reference.observe(.childAdded, with: { (snapshot) in
            let contactUid = snapshot.key
            let userReference = Database.database().reference().child("users").child(contactUid).queryOrdered(byChild: "username")
            userReference.observe(.value, with: { (contactSnapshot) in
                if let dictionary = contactSnapshot.value as? [String:AnyObject]{
                    let user = self.userModel.setUserWith(uid: contactUid, dictionary: dictionary)
                    self.fetchContactsValue(user: user)
                }
            
            }, withCancel: nil)
        }, withCancel: nil)
       
    }
    func fetchContactsValue(user: User){
        let key = user.username?.firstLetter()
        if contactsByKeys[key!] == nil{
            contactsByKeys[key!] = [user]
            sectionTitles.append(key!)
            sectionTitles = sectionTitles.sorted()
        }else{
            contactsByKeys[key!]?.append(user)
            contactsByKeys[key!] = contactsByKeys[key!]?.sorted(by: {$0.username! < $1.username!})
        }
        contacts.append(user)
        contacts = contacts.sorted(by: {$0.username! < $1.username!})
        
        let indexPath = IndexPath(row: (contactsByKeys[key!]?.index(of: user))!, section: sectionTitles.index(of: key!)!)
        DispatchQueue.main.async(){
            if let updateCell = self.tableView.cellForRow(at: indexPath) as? contactsTableViewCell{
                updateCell.profileImageView.image = nil
                updateCell.profileImageView.loadImageUsingCacheWith(urlString: user.profileImageUrl!)
            }
            
            self.tableView.reloadData()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableView{
            return sectionTitles.count
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView{
            return (contactsByKeys[sectionTitles[section]]?.count)!
        }
        return filteredResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if tableView == self.tableView{
            let user = contactsByKeys[sectionTitles[indexPath.section]]?[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: contactCellIdentifier, for: indexPath) as! contactsTableViewCell
            
            cell.nameLabel.text = user?.username
            cell.emailLabel.text = user?.email
            if let profileImageUrl = user?.profileImageUrl{
                cell.profileImageView.loadImageUsingCacheWith(urlString: profileImageUrl)
            }
            
            if indexPath.row % 2 == 0 {
                cell.backgroundColor = UIColor.contactCellEvenColor
                
            }else{
                cell.backgroundColor = UIColor.contactCellOddColor
            }
            
            return cell
        }else{
            
            let user = filteredResults[indexPath.row]
            
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "filtered")
            cell.textLabel?.text = user.username
            cell.detailTextLabel?.text = user.email
            return cell
            
        }
    
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = contactsByKeys[sectionTitles[indexPath.section]]?[indexPath.row]
        let postsViewController = self.storyboard?.instantiateViewController(withIdentifier: "allPosts") as! postsTableViewController
        postsViewController.configure(user: user!, isCurrentUser: false)
        show(postsViewController, sender: self)

    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if tableView == self.tableView{
            return sectionTitles
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == self.tableView{
            return sectionTitles[section]
        }
        return nil
    }
    
    @IBAction func prepareForUnwindToContactsTable(segue: UIStoryboardSegue){
        
    }

  

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

}
