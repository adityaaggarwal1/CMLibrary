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

        let toggleButton = UIButton(frame: CGRect(x: 10, y: 60, width: 200, height: 30))
        toggleButton.setTitle("Webservice Call", forState: .Normal)
        toggleButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        toggleButton.addTarget(self, action: "getTokenService", forControlEvents: .TouchUpInside)
        view.addSubview(toggleButton)


        let toggleButton1 = UIButton(frame: CGRect(x: 10, y: 120, width: 200, height: 30))
        toggleButton1.setTitle("Webservice Call With Auth", forState: .Normal)
        toggleButton1.setTitleColor(UIColor.redColor(), forState: .Normal)
        toggleButton1.addTarget(self, action: "getFromKeyChain", forControlEvents: .TouchUpInside)
        view.addSubview(toggleButton1)
    }

    func callWebservice() {


        let webserviceCall = WebserviceCall(responseType: WebserviceCallResponseJSON, requestType: WebserviceCallRequestTypeJson, cachePolicy: WebserviceCallCachePolicyRequestFromUrlNoCache)
        webserviceCall.isShowLoader = true
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

        webserviceCall.shouldDisableInteraction = false

        webserviceCall.GET(NSURL(string: "http://jsonplaceholder.typicode.com/comments"), parameters: ["postId":"1"], withSuccessHandler: { (response: WebserviceResponse!) -> Void in

            let responseDict = response as WebserviceResponse

            print(responseDict.webserviceResponse)

            }) { (error: NSError!) -> Void in

        }
    }

    func callPatchWebservice() {

        let webserviceCall = WebserviceCall(responseType: WebserviceCallResponseJSON, requestType: WebserviceCallRequestTypeJson, cachePolicy: WebserviceCallCachePolicyRequestFromUrlNoCache)
        webserviceCall.isShowLoader = true
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

        webserviceCall.headerFieldsDict = ["Authorization" : "Bearer PuJq65INyxSipxFDipCXdyhJPBhUws"]
        webserviceCall.shouldDisableInteraction = false

        webserviceCall.DELETE(NSURL(string: "http://172.16.13.206:8009/app/api/delsrvc/20123/"), parameters: ["postId":"1"], withSuccessHandler: { (response: WebserviceResponse!) -> Void in

            let responseDict = response as WebserviceResponse

            print(responseDict.webserviceResponse)

            }) { (error: NSError!) -> Void in

        }
    }

    func uploadFileUsingMultipartUpload() {

        let webserviceCall = WebserviceCall(responseType: WebserviceCallResponseString, requestType: WebserviceCallRequestTypeJson, cachePolicy: WebserviceCallCachePolicyRequestFromUrlNoCache)

        webserviceCall.isShowLoader = true

        let fileData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("iOS Simulator Screen.png", ofType: nil)!)

        webserviceCall.uploadFile(fileData, withFileName: "iOS Simulator Screen.png", withFieldName: "file", mimeType: "image/png", onUrl: NSURL(string: "http://posttestserver.com/post.php?dir=example"), withSuccessHandler: { (response: WebserviceResponse!) -> Void in

                let responseDict = response as WebserviceResponse

                print(responseDict.webserviceResponse)
            }) { (error: NSError!) -> Void in

        }
    }

    @IBAction func btnDummyTapped(sender: AnyObject) {
        print("test >>>>>>>>>>>>>>>>>>>>>>>>>")
        callWebservice()
    }

    func saveInKeyChain() {

        let token = AuthToken()
        token.access_token = "abc123"
        FXKeychain.defaultKeychain().setObject(token, forKey: "Key")
    }

    func getFromKeyChain() {

        let webserviceCall = WebserviceCall(responseType: WebserviceCallResponseJSON, requestType: WebserviceCallRequestTypeJson, cachePolicy: WebserviceCallCachePolicyRequestFromUrlNoCache)
        webserviceCall.isShowLoader = true
        webserviceCall.addAuthTokenInHeaderFromKey("AuthToken")

        webserviceCall.POST(NSURL(string: "http://172.16.13.33:8009/app/api/signup/"), parameters: ["name":"test2", "email":"test21233@gmail.com", "password":"test2", "mobile":"8765657700", "device_id":"123awd1233", "device_token":"23424234sdfsd234234", "device_type":"1"], withSuccessHandler: { (response: WebserviceResponse!) -> Void in

            let responseDict = (response as WebserviceResponse).webserviceResponse as! NSDictionary

            NSLog("responseDict >>>>>>> %@", responseDict.description)

        }) { (error: NSError!) -> Void in

        }
    }

    func getTokenService() {
        let webserviceCall = WebserviceCall(responseType: WebserviceCallResponseJSON, requestType: WebserviceCallRequestTypeFormURLEncoded, cachePolicy: WebserviceCallCachePolicyRequestFromUrlNoCache)
        webserviceCall.isShowLoader = true

        webserviceCall.fetchAuthTokenForClientSecret("lkeg7r@IQDwrFa7NHbNnV?e:oOs=UeHQ0j=83sJWux5mCOV6EX_DJx?vu0uLnwvlk1KM@BXX?.LBRrgWbW:rSF-ll_eCG!BwtkYIGn04JtVoLi=VYE3EAk:A.zS3u0VF", clientId: "qUiOEFk9Uyjw1z2pDUKW8=PMSv9FasXkYpgFa0P2", grantType: "client_credentials", andStoreAtKey: "AuthToken")

        webserviceCall.POST(NSURL(string: "http://172.16.13.33:8009/o/token/"), parameters: nil, withSuccessHandler: { (response: WebserviceResponse!) -> Void in
            let responseDict = (response as WebserviceResponse).webserviceResponse as! NSDictionary

            NSLog("responseDict >>>>>>> %@", responseDict.description)
        }) { (error: NSError!) -> Void in

        }
    }

}
