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

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var layout = UICollectionViewFlowLayout()
    var collectionView : UICollectionView?
    var tweetsView : UITableView?
    var tweets = [Tweet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        grabTweets()
        
        layout.scrollDirection = .Vertical
        tweetsView = UITableView(frame: view.frame)
        tweetsView?.allowsSelection = false
        tweetsView?.registerClass(TweetCell.self, forCellReuseIdentifier: "tweetTableViewCell")
        tweetsView?.dataSource = self
        tweetsView?.delegate = self
        tweetsView?.backgroundColor = .lightGrayColor()
        tweetsView?.separatorStyle = .None
        tweetsView?.rowHeight = 164.0
        view.addSubview(tweetsView!)
    }
    
    func loadTweets() {
//        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
//        let destinationPath = documentsPath.stringByAppendingPathComponent("/sample.plist")
//        let destinationPath = NSBundle.mainBundle().pathForResource("sample", ofType: "plist")!
//
//        if let arr = NSArray(contentsOfFile: destinationPath) {
//            tweets = arr as [NSDictionary]
//        }
    }

//MARK: COLLECTIONVIEW
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var tweetCell : TweetCell
        if let dequeuedCell : TweetCell = tableView.dequeueReusableCellWithIdentifier("tweetTableViewCell") as? TweetCell {
            tweetCell = dequeuedCell
        } else {
            tweetCell = TweetCell(style: UITableViewCellStyle.Default, reuseIdentifier: "tweetTableViewCell")
        }
        
        tweetCell.tvc = self.tweetsView
        
        let tweet = tweets[indexPath.row]
        if let text = tweet.text {
            tweetCell.textLabel?.attributedText = parseText(text)
        }
        
        if let img = tweet.user?.imageURL {
            tweetCell.imageURL = img
        }
        return tweetCell
    }
    
    func parseText(text: String) -> NSAttributedString {
        var components = text.componentsSeparatedByString(" ")
        var rt = false
        if components[0] == "RT" {
            components[1] = "“"+components[1]
            components[components.count-1] = components[components.count-1] + "”"
        }
        var completeString = NSMutableAttributedString()
        for string in components {
            var attributedString = NSMutableAttributedString(string: string+" ")
            
            if string.hasPrefix("@") || string.hasPrefix("#") {
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.darkGrayColor(), range: NSMakeRange(0, countElements(string)))
                attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "Helvetica-Light", size: 16.0)!, range: NSMakeRange(0, countElements(string)))
            }
            
            if string.hasPrefix("http:") || string.hasPrefix("www.") {
                attributedString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleThick.rawValue, range: NSMakeRange(0, countElements(string)))
            }
            
            completeString.appendAttributedString(attributedString)
        }
        
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.alignment = .Center
        
        completeString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, completeString.length))

        
        return completeString as NSAttributedString
    }
        
    func grabTweets() {
        let twitter = Twitter.sharedInstance()
        
        twitter.logInGuestWithCompletion { (session: TWTRGuestSession!, error: NSError!) in
            // Swift
            let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/user_timeline.json"
            let params = ["screen_name": "cocoafor", "include_rts":"true", "count" : "100"]
            
            //use: since_id, to grab all the newest posts
            //save data to a plist
            //on viewDidLoad retrieve the list
            //check for new posts (i.e. by retrieving newest id)
            //append posts (if any)
            //load data
            //save data on background thread to plist

            var clientError : NSError?
            
            let request = twitter.APIClient.URLRequestWithMethod(
                "GET", URL: statusesShowEndpoint, parameters: params,
                error: &clientError)
            
            if request != nil {
                Twitter.sharedInstance().APIClient.sendTwitterRequest(request) {
                    (response, data, connectionError) -> Void in
                    if (connectionError == nil) {
                        var jsonError : NSError?
                        
                        let d : NSArray = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as NSArray
                        
                        var jsonData = NSJSONSerialization.JSONObjectWithData(data,
                            options: nil,
                            error: &jsonError) as? NSMutableArray
                        if jsonError != nil {
                            println("err: \(jsonError)")
                        }
                        if let array = jsonData {
                            self.parseJSON(array)
                            self.saveJSON(array)
                            self.tweetsView?.reloadData()
                        }
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
    
    func parseJSON(jsonData: NSMutableArray) {
        for i in 0..<jsonData.count {
            var tweet = Tweet(json: jsonData[i] as NSDictionary)
            self.tweets.append(tweet)
        }
    }
    
    func parseProfileImage(path: String) -> String {
        var parsedPath = path
        var range = parsedPath.rangeOfString("_normal")
        if range != nil {
            parsedPath = parsedPath.stringByReplacingOccurrencesOfString("_normal", withString: "_bigger")
        } else {
            range = parsedPath.rangeOfString("_mini")
            if range != nil {
                parsedPath = parsedPath.stringByReplacingOccurrencesOfString("_mini", withString: "_bigger")
            }
            else {
                range = parsedPath.rangeOfString("_bigger")
                if range == nil {
                    //do nothing
                } else {
                    parsedPath = parsedPath.stringByReplacingOccurrencesOfString(".png", withString: "_bigger.png")
                }
            }
        }
        return parsedPath
    }
    
    func saveJSON(array: NSMutableArray) {
//        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
//        let destinationPath = documentsPath.stringByAppendingPathComponent("/sample.plist")
//        let arr = self.tweets as NSArray
//        let b = arr.writeToFile(destinationPath, atomically: true)
//        if b { println("done") }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
