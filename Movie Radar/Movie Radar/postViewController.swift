//
//  postViewController.swift
//  Movie Radar
//
//  Created by Yang Yang on 11/8/17.
//  Copyright © 2017 Yang Yang. All rights reserved.
//

import UIKit

class postViewController: UIViewController {

    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet var ratingStars: [UIImageView]!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var posterImageView: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    var currentPost:Post?
    var indexPath:IndexPath?
    let postModel = PostModel.sharedInstance
    
    var deleteButtonIsHidden=false{
        didSet{
            if let button = self.deleteButton{
                button.isHidden = self.deleteButtonIsHidden
            }
        }
    }
    var bookMarkButtonIsHidden=false{
        didSet{
            if let button = self.bookmarkButton{
                button.isHidden = self.bookMarkButtonIsHidden
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        deleteButton.isHidden = deleteButtonIsHidden
        bookmarkButton.isHidden = bookMarkButtonIsHidden
        commentTextView.isEditable = false
        
        deleteButton.addTarget(self, action: #selector(deletePost(sender:)), for: .touchUpInside)
        
        if let post = currentPost{
            movieNameLabel.text = "Movie Name: \(post.title!)"
            genreLabel.text = "Genre: \(post.genre!)"
            postModel.setRatingStarsWith(ratingStars: ratingStars, rating: post.rating!)
            commentTextView.text = post.comments!
            posterImageView.loadImageUsingCacheWith(urlString: post.posterImageUrl!)
            dateLabel.text = "Created at \(postModel.setDate(timestamp: post.timestamp!))"
        }
        
    }
        
    func configure(post:Post,indexPath:IndexPath){
        self.currentPost = post
        self.indexPath = indexPath
    }
    func deletePost(sender: UIButton){
        postModel.deletePost(postUid: (self.currentPost?.uid)!, userUid: (self.currentPost?.author)!)
        performSegue(withIdentifier: postUnwindSegueIdentifier, sender: self)
    }
    
    
    
}
