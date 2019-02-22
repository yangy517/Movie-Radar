//
//  cache.swift
//  Movie Radar
//
//  Created by Yang Yang on 11/7/17.
//  Copyright © 2017 Yang Yang. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView{
    func loadImageUsingCacheWith(urlString : String){
        self.image = nil
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage{
            self.image = cachedImage
            return
        }
        // if not in cache
        let url = NSURL(string: urlString) as URL?
        let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if let _error = error{
                print(_error.localizedDescription)
                return
            }
            DispatchQueue.main.async() {
                if let downloadImage = UIImage(data: data!){
                    imageCache.setObject(downloadImage, forKey: urlString as AnyObject)
                    self.image = downloadImage
                }
            }
            
        })
        task.resume()
    }
}
