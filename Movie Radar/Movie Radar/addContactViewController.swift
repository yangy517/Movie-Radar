//
//  addContactViewController.swift
//  Movie Radar
//
//  Created by Yang Yang on 11/8/17.
//  Copyright © 2017 Yang Yang. All rights reserved.
//

import UIKit
import Firebase

class addContactViewController: UIViewController,UITextFieldDelegate {
    
    let messageModel = MessageModel.sharedInstance
    let userModel = UserModel.sharedInstance

    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n"{
            textField.resignFirstResponder()
        }
        
        return true
    }
    @IBAction func sendRequestAndDismiss(_ sender: UIButton) {
        sendRequest()
        performSegue(withIdentifier: "sendRequest", sender: self)
    }
    func sendRequest(){
        let fromId = Auth.auth().currentUser?.uid
        let email = emailTextField.text
        messageModel.sendFriendRequest(fromId: fromId!, toEmail: email!)
        
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
   
}
