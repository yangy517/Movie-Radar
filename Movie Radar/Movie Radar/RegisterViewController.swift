//
//  RegisterViewController.swift
//  Movie Radar
//
//  Created by Yang Yang on 10/31/17.
//  Copyright © 2017 Yang Yang. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate{

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var inputsContainerView: UIView!
    
    let messageModel = MessageModel.sharedInstance
    //seperator views
    let emailSeperatorView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.seperatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let _emailSeperatorView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.seperatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let usernameSeperatorView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.seperatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let passwordSeperatorView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.seperatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        drawInterface()
    }
    func drawInterface(){
        inputsContainerView.layer.cornerRadius = customCornerRadius
        addSeperatorToInputsContainerView(seperatorView: _emailSeperatorView, under: emailTextField)
        addSeperatorToInputsContainerView(seperatorView: usernameSeperatorView, under: usernameTextField)
        addSeperatorToInputsContainerView(seperatorView: passwordSeperatorView, under: passwordTextField)
        
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectProfileImageView)))
        profileImageView.isUserInteractionEnabled=true
    }
    func addSeperatorToInputsContainerView(seperatorView:UIView, under textfield:UITextField){
        inputsContainerView.addSubview(seperatorView)
        seperatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive=true
        seperatorView.rightAnchor.constraint(equalTo: inputsContainerView.rightAnchor).isActive=true
        seperatorView.topAnchor.constraint(equalTo: textfield.bottomAnchor).isActive=true
        seperatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive=true
        seperatorView.heightAnchor.constraint(equalToConstant: 1).isActive=true
    }
    // profileImageView picker delegate
    func selectProfileImageView(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            selectedImageFromPicker = editedImage
        }else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker{
            profileImageView.image = selectedImage
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func createAccount(_ sender: UIButton) {
        handleRegister()
    }
    func handleRegister(){
        
        guard let email = emailTextField.text,let password = passwordTextField.text,let username = usernameTextField.text
        else{
            print("Form is not vaild")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let _error = error {
                print(_error.localizedDescription)
                return
            }
            guard let uid = user?.uid else{return}
            
            //successfully authenticated user
            let imageName = NSUUID().uuidString
            let storageReference = Storage.storage().reference().child("profile_images").child("\(imageName).png")
            if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!){
                storageReference.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if let _error = error{
                        print(_error.localizedDescription)
                        return
                    }
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString{
                        let values = ["username":username,"email":email,"profileImageUrl":profileImageUrl]
                        
                        
                        self.registerUserIntoDatabaseWithUid(uid: uid, values: values as [String : AnyObject],email: email)
                        
                        
                    }
                })
            }
            
        }
    }
    private func registerUserIntoDatabaseWithUid(uid: String, values: [String:AnyObject], email:String){
        
        let reference = Database.database().reference(fromURL: "https://movie-radar-81c9a.firebaseio.com")
        let userRreference = reference.child("users").child(uid)
        
        userRreference.updateChildValues(values, withCompletionBlock: { (err, reference) in
            if let _err = err{
                print(_err.localizedDescription)
                return
            }
            print("saved user successfully into Firebase databse")
            let emailKey = self.messageModel.encodeUserEmailToKey(email: email)
            Database.database().reference().child("email-user").child(emailKey).updateChildValues([uid:1])
            self.performSegue(withIdentifier: "newlogin", sender: self)
        })

    }
    //textfield delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case emailTextField:
            usernameTextField.becomeFirstResponder()
        case usernameTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        default:
            break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n"{
            textField.resignFirstResponder()
        }
        
        return true
    }


}
