//
//  SimpleAsyncImageView.swift
//  iBeaconTest
//
//  Created by aoisupersix on 2018/04/27.
//

import UIKit

class AsyncImageView: UIImageView {
    let CACHE_SEC : TimeInterval = 5 * 60; //5分キャッシュ
    
    //画像を非同期で読み込む
    func loadImage(urlString: String){
        let req = URLRequest(url: NSURL(string:urlString)! as URL,
                             cachePolicy: .returnCacheDataElseLoad,
                             timeoutInterval: CACHE_SEC);
        let conf =  URLSessionConfiguration.default;
        let session = URLSession(configuration: conf, delegate: nil, delegateQueue: OperationQueue.main);
        
        session.dataTask(with: req, completionHandler:
            { (data, resp, err) in
                if((err) == nil){ //Success
                    let image = UIImage(data:data!)
                    self.image = image;
                    
                }else{ //Error
                    print("AsyncImageView:Error \(String(describing: err?.localizedDescription))");
                }
        }).resume();
    }
}
