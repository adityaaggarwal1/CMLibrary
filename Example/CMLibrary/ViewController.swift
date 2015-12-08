//
//  ViewController.swift
//  CMLibrary
//
//  Created by adityaaggarwal1 on 09/23/2015.
//  Copyright (c) 2015 adityaaggarwal1. All rights reserved.
//

import UIKit
import CMLibrary

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let toggleButton = UIButton(frame: CGRectMake(10, 60, 125, 30))
        toggleButton.setTitle("Webservice Call", forState: .Normal)
        toggleButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        toggleButton.addTarget(self, action: "callWebservice", forControlEvents: .TouchUpInside)
        view.addSubview(toggleButton)
    }
    
    func callWebservice() {
        
        let webserviceCall = WebserviceCall(responseType: WebserviceCallResponseJSON, cachePolicy: WebserviceCallCachePolicyRequestFromCacheFirstAndThenFromUrlAndUpdateInCache)
        
//        http://jsonplaceholder.typicode.com/comments?postId=1
        
//        webserviceCall.GET(NSURL(string: "http://jsonplaceholder.typicode.com/posts"), parameters: nil, withSuccessHandler: { (response: WebserviceResponse!) -> Void in
//            
//            let responseDict = response as WebserviceResponse
//            
//            print(responseDict.webserviceResponse)
//            
//            }) { (error: NSError!) -> Void in
//                
//        }
        
        webserviceCall.GET(NSURL(string: "http://jsonplaceholder.typicode.com/comments"), parameters: ["postId":"1"], withSuccessHandler: { (response: WebserviceResponse!) -> Void in
            
            let responseDict = response as WebserviceResponse
            
            print(responseDict.webserviceResponse)
            
            }) { (error: NSError!) -> Void in
                
        }
        
    }
    
    func uploadFileUsingMultipartUpload(){
        
        let webserviceCall = WebserviceCall(responseType: WebserviceCallResponseString, cachePolicy: WebserviceCallCachePolicyRequestFromUrlNoCache)
        
        let fileData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("iOS Simulator Screen.png", ofType: nil)!)
        
        webserviceCall.uploadFile(fileData, withFileName: "iOS Simulator Screen.png", withFieldName: "file", mimeType: "image/png", onUrl: NSURL(string: "http://posttestserver.com/post.php?dir=example"), withSuccessHandler: { (response: WebserviceResponse!) -> Void in
            
                let responseDict = response as WebserviceResponse
                
                print(responseDict.webserviceResponse)
            }) { (error: NSError!) -> Void in
                
        }
    }

}

