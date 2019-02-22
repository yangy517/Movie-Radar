//
//  createPostController.swift
//  Movie Radar
//
//  Created by Yang Yang on 11/6/17.
//  Copyright © 2017 Yang Yang. All rights reserved.
//

import UIKit
import Firebase

class createPostController: UIViewController{
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var movieNameTextField: UITextField!
    @IBOutlet weak var genreTextField: UITextField!
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet var ratingStars: [UIImageView]!

    var genre: String?
    var movieName: String?
    var comments: String?
    var ratingScore:Int = 0
    
    let postModel = PostModel.sharedInstance
    let pickerView = UIPickerView()
    
    let textViewToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(textViewDoneClick))]
        toolbar.sizeToFit()
        return toolbar
    }()   

    override func viewDidLoad() {
        super.viewDidLoad()
        movieNameTextField.delegate = self
        genreTextField.delegate = self
        commentsTextView.delegate = self
        addGestures()

        pickerView.delegate=self
        pickerView.dataSource=self
        genreTextField.inputView=pickerView
        createPickerViewToolbar()
        commentsTextView.inputAccessoryView = textViewToolbar
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    func updateTextView(notification : Notification){
        let userInfo = notification.userInfo!
        let keyboardEndFrameScreenCoordinates = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardEndFrame = self.view.convert(keyboardEndFrameScreenCoordinates, to: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide{
            commentsTextView.contentInset = UIEdgeInsets.zero
        }else{
            commentsTextView.contentInset = UIEdgeInsetsMake(0, 0, keyboardEndFrame.height-textViewToolbar.frame.height-textViewVisibleHeight, 0)
            commentsTextView.scrollIndicatorInsets = commentsTextView.contentInset
        }
        commentsTextView.scrollRangeToVisible(commentsTextView.selectedRange)
    }
    func textViewDoneClick(){
        commentsTextView.resignFirstResponder()
    }
    
    func addGestures(){
        for star in ratingStars{
            star.isUserInteractionEnabled = true
            star.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnStar)))
        }
        posterImageView.isUserInteractionEnabled = true
        posterImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectPosterImageView)))
    }
    
    func tapOnStar(gestureRecognizer: UITapGestureRecognizer){
        let starImageView = gestureRecognizer.view as! UIImageView
        let index = starImageView.tag
        postModel.setRatingStarsWith(ratingStars: ratingStars, rating: index)
        self.ratingScore = index
    }
        
    func selectPosterImageView(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    func createPickerViewToolbar(){
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.pickerViewDoneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.pickerViewCancelClick))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        genreTextField.inputAccessoryView=toolbar
    }
    func pickerViewDoneClick(){
        genreTextField.resignFirstResponder()
    }
    func pickerViewCancelClick(){
        genre = nil
        genreTextField.text = nil
        genreTextField.resignFirstResponder()
    }

    @IBAction func createNewPost(_ sender: UIButton) {
        if let title = self.movieName, let comments = self.comments,let genre = self.genre, let image = posterImageView.image{
            guard image != UIImage(named:"movie-2") else {
                return
            }
            let imageName = NSUUID().uuidString
            let storageReference = Storage.storage().reference().child("posts_images").child("\(imageName).png")
            if let uploadData = UIImagePNGRepresentation(image){
                storageReference.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if let _error = error{
                        print(_error.localizedDescription)
                        return
                    }
                    if let posterImageUrl = metadata?.downloadURL()?.absoluteString{
                        let uid = Auth.auth().currentUser?.uid
                        let timestamp = Int(NSDate().timeIntervalSince1970)
                        print(self.ratingScore)
                        let values = ["title": title, "author": uid!, "genre": genre, "comments": comments, "rating": self.ratingScore, "posterImageUrl": posterImageUrl, "timestamp": timestamp] as [String : Any]
                        let reference = Database.database().reference().child("posts")
                        let childReference = reference.childByAutoId()
                        childReference.updateChildValues(values, withCompletionBlock: { (error, reference) in
                            if let _error = error{
                                print(_error.localizedDescription)
                                return
                            }
                            let userPostsReference = Database.database().reference().child("user-posts").child(uid!)
                            let postId = childReference.key
                            userPostsReference.updateChildValues([postId:1])
                            self.reset()
                        })
                    }
                })
            }
           // self.reset()
        }else{
            print("one or more information is not entered")
        }
        
    }
    
    
    @IBAction func cancelCreatingPost(_ sender: UIButton) {
        reset()
    }
    
    func reset(){
        self.comments = nil
        self.genre = nil
        self.movieName = nil
        self.ratingScore = 0
        self.commentsTextView.text = "Type your comments here"
        self.movieNameTextField.text = nil
        self.genreTextField.text = nil
        self.posterImageView.image = UIImage(named: "movie-2")
        for star in ratingStars{
            star.image = UIImage(named: "star")
        }
        self.tabBarController?.selectedIndex = 0
    }
}


extension createPostController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker{
            posterImageView.image = selectedImage
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension createPostController: UITextFieldDelegate,UITextViewDelegate{
    //textField delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        pickerView.reloadAllComponents()
        pickerView.selectRow(0, inComponent: 0, animated: true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == movieNameTextField{
            movieName = textField.text
        }else{
            //genreTextfield
            genre = genreTextField.text
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n"{
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    //textView delegate
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.text = ""
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        comments = textView.text
    }
}

extension createPostController: UIPickerViewDelegate,UIPickerViewDataSource{
    //pickerView delegate methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Genres.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Genres[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genreTextField.text = Genres[row]
    }
    
}
