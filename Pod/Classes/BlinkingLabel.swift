//
//  BlinkingLabel.swift
//  Pods
//
//  Created by Aditya Aggarwal on 9/23/15.
//
//

import UIKit

public class BlinkingLabel : UILabel {
    public func startBlinking() {
        
//        let options : UIViewAnimationOptions = .Repeat | .Autoreverse
        let options : UIViewAnimationOptions = .Repeat
        UIView.animateWithDuration(0.25, delay:0.0, options:options, animations: {
            self.alpha = 0
            }, completion: nil)
    }
    
    public func stopBlinking() {
        alpha = 1
        layer.removeAllAnimations()
    }
}
