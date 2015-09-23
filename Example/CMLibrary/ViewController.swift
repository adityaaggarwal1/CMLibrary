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

    var isBlinking = false
    let blinkingLabel = BlinkingLabel(frame: CGRectMake(10, 20, 200, 30))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the BlinkingLabel
        blinkingLabel.text = "I blink!"
        blinkingLabel.font = UIFont.systemFontOfSize(20)
        view.addSubview(blinkingLabel)
        blinkingLabel.startBlinking()
        isBlinking = true
        
        // Create a UIButton to toggle the blinking
        let toggleButton = UIButton(frame: CGRectMake(10, 60, 125, 30))
        toggleButton.setTitle("Toggle Blinking", forState: .Normal)
        toggleButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        toggleButton.addTarget(self, action: "toggleBlinking", forControlEvents: .TouchUpInside)
        view.addSubview(toggleButton)
    }
    
    func toggleBlinking() {
//        if (isBlinking) {
//            blinkingLabel.stopBlinking()
//        } else {
//            blinkingLabel.startBlinking()
//        }
//        isBlinking = !isBlinking
        
        let webserviceCall = WebserviceCall(responseType: WebserviceCallResponseJSON, cachePolicy: WebserviceCallCachePolicyRequestFromCacheFirstAndThenFromUrlAndUpdateInCache)
        
        webserviceCall.GET(NSURL(string: "http://jsonplaceholder.typicode.com/posts"), parameters: nil, withSuccessHandler: { (response: WebserviceResponse!) -> Void in
            
            let responseDict = response as WebserviceResponse
            
            NSLog("%@",responseDict.webserviceResponse.description)
            
            }) { (error: NSError!) -> Void in
                
        }
        
    }

}

