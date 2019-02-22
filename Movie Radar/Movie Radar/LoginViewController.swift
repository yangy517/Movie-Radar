//
//  LoginViewController.swift
//  Movie Radar
//
//  Created by Yang Yang on 10/31/17.
//  Copyright © 2017 Yang Yang. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController,UITextFieldDelegate {

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var inputsContainerView: UIView!
    
    let seperatorView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.seperatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        drawInterface()
    }
    
    func drawInterface(){
        inputsContainerView.layer.cornerRadius = customCornerRadius
        addSeperatorToInputsContainerView()
    }
    func addSeperatorToInputsContainerView(){
        inputsContainerView.addSubview(seperatorView)
        seperatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        seperatorView.rightAnchor.constraint(equalTo: inputsContainerView.rightAnchor).isActive = true
        seperatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        seperatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        seperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    @IBAction func loginAccount(_ sender: UIButton) {
        handleLogin()
    }
    func handleLogin(){
        guard let email = emailTextField.text, let password = passwordTextField.text else{
            print("Form is not vaild")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let _error = error{
                print(_error.localizedDescription)
                return
            }
            // sucessfully log in the user
            self.performSegue(withIdentifier: "login", sender: self)
        }
        return
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTextField{
            passwordTextField.becomeFirstResponder()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n"{
            textField.resignFirstResponder()
        }
        
        return true
    }
    
}
