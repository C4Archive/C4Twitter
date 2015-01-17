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
import SwifteriOS

class ViewController: UIViewController {
    
    var swifter : Swifter?
    
    override func viewDidLoad() {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func fetchTwitterHomeStream() {
        let failureHandler: ((NSError) -> Void) = {
            error in
            self.alertWithTitle("Error", message: error.localizedDescription)
        }
        
        self.swifter!.getStatusesHomeTimelineWithCount(20, sinceID: nil, maxID: nil, trimUser: true, contributorDetails: false, includeEntities: true, success: {
            (statuses: [JSONValue]?) in
            
            // Successfully fetched timeline, so lets create and push the table view
//            let tweetsViewController = self.storyboard!.instantiateViewControllerWithIdentifier("TweetsViewController") as TweetsViewController
            
            if statuses != nil {
//                tweetsViewController.tweets = statuses!
//                self.presentViewController(tweetsViewController, animated: true, completion: nil)
                C4Log("\(statuses)")
            }
            
            }, failure: failureHandler)
        
    }
    
    func alertWithTitle(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

