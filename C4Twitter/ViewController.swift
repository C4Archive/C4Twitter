//
//  ViewController.swift
//  C4Twitter
//
//  Created by travis on 2015-01-16.
//  Copyright (c) 2015 C4. All rights reserved.
//

import UIKit
import C4Core
import Social
import Accounts
import TwitterKit

class ViewController: UIViewController {
    var tweets = [Tweet]()
    var jsonData : NSMutableArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let twitter = Twitter.sharedInstance()
        
        twitter.logInGuestWithCompletion { (session: TWTRGuestSession!, error: NSError!) in
            // Swift
            let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/user_timeline.json"
            let params = ["screen_name": "cocoafor", "include_rts":"false", "count" : "100"]
            var clientError : NSError?
            
            let request = twitter.APIClient.URLRequestWithMethod(
                "GET", URL: statusesShowEndpoint, parameters: params,
                error: &clientError)
            
            if request != nil {
                Twitter.sharedInstance().APIClient.sendTwitterRequest(request) {
                    (response, data, connectionError) -> Void in
                    if (connectionError == nil) {
                        var jsonError : NSError?
                        self.jsonData =
                        NSJSONSerialization.JSONObjectWithData(data,
                            options: nil,
                            error: &jsonError) as? NSMutableArray
                        println("err: \(jsonError)")
                        self.saveJSON()
                        
                    }
                    else {
                        println("Error: \(connectionError)")
                    }
                }
            }
            else {
                println("Error: \(clientError)")
            }
        }
    }
    
    func saveJSON() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let destinationPath = documentsPath.stringByAppendingPathComponent("/sample.plist")
        println(jsonData!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

public struct Tweet {
    var text : String = ""
    var name : String = ""
    var imgURL : String = ""
    var isRT : Bool = false
    init() {}
}
