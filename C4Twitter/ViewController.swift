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
//    var tweets = [Tweet]()
    var jsonData : NSMutableArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        grabTweets()
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
                        
                        self.jsonData =
                            NSJSONSerialization.JSONObjectWithData(data,
                                options: nil,
                                error: &jsonError) as? NSMutableArray
                        println("err: \(jsonError)")
                        self.parseJSON()
//                        self.printJSON()
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
    
    var tweets = [NSDictionary]()
    
    func parseJSON() {
        if let rawTweets = self.jsonData {
            for i in 0..<rawTweets.count {
                let rawTweet = rawTweets[i] as NSDictionary
                var tweet = NSMutableDictionary()
                let date : String = rawTweet.objectForKey("created_at") as String
                tweet["date"] = date
                
                let text = rawTweet.objectForKey("text") as String
                tweet["text"] = text
                
                if let status : NSDictionary = rawTweet.objectForKey("retweeted_status") as? NSDictionary {
                    //if it's a retweet, get all the info from retweeted_status
                    let favcount = status.objectForKey("favorite_count") as Int
                    tweet["favcount"] = favcount
                    
                    let rtcount = status.objectForKey("retweet_count") as Int
                    tweet["rtcount"] = rtcount
                    
                    if let user = status.objectForKey("user") as? NSDictionary {
                        let userImageURL = user.objectForKey("profile_image_url") as String
                        tweet["userImageURL"] = parseProfileImage(userImageURL)
                        
                        let screenName = user.objectForKey("screen_name") as String
                        tweet["screenName"] = screenName
                        
                        let name = user.objectForKey("name") as String
                        tweet["name"] = name
                        
                        if let userURL = user.objectForKey("url") as? String {
                            tweet["userURL"] = userURL
                        }
                    }
                } else {
                    //otherwise get all the info from the normal tweet
                    if let favcount = rawTweet.objectForKey("favorite_count") as? Int {
                        tweet["favcount"] = favcount
                    }
                    
                    if let rtcount = rawTweet.objectForKey("retweet_count") as? Int {
                        tweet["rtcount"] = rtcount
                    }

                    if let user = rawTweet.objectForKey("user") as? NSDictionary {
                        let userImageURL = user.objectForKey("profile_image_url") as String
                        tweet["userImageURL"] = parseProfileImage(userImageURL)
                        
                        let screenName = user.objectForKey("screen_name") as String
                        tweet["screenName"] = screenName
                        
                        let name = user.objectForKey("name") as String
                        tweet["name"] = name
                        
                        if let userURL = user.objectForKey("url") as? String {
                            tweet["userURL"] = userURL
                        }
                    }
                }
                self.tweets.append(tweet as NSDictionary)
            }
        }
    }
    
    func printJSON() {
        if let tweets = self.jsonData {
            let tweet = tweets[0] as NSDictionary
            println(tweet)
            let date : String = tweet.objectForKey("created_at") as String
            println(date)
            
            let source = tweet.objectForKey("source") as String
            println(source)
            
            let text = tweet.objectForKey("text") as String
            println(text)
            
            let status = tweet.objectForKey("retweeted_status") as NSDictionary
            
            let favcount = status.objectForKey("favorite_count") as Int
            println(favcount)
            
            let rtcount = status.objectForKey("retweet_count") as Int
            println(rtcount)

            let user = status.objectForKey("user") as NSDictionary
            
            let userImageURL = user.objectForKey("profile_image_url") as String
            println(parseProfileImage(userImageURL))
            
            let screenName = user.objectForKey("screen_name") as String
            println(screenName)
            
            let name = user.objectForKey("name") as String
            println(name)
            
            let userURL = user.objectForKey("url") as String
            
            println(userURL)
            
        } else {
            println("couldn't parse tweet")
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
    
    func saveJSON() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let destinationPath = documentsPath.stringByAppendingPathComponent("/sample.plist")
        let arr = self.tweets as NSArray
        let b = arr.writeToFile(destinationPath, atomically: true)
        if b { println("done") }
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
