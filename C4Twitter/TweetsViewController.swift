import UIKit
import C4Core
import Social
import Accounts
import TwitterKit

class TweetsViewController: UITableViewController {
    var tweets = [Tweet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        grabTweets()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var tweetCell = tableView.dequeueReusableCellWithIdentifier("tweetTableViewCell") as TweetCell
        tweetCell.tvc = self.tableView
        
        let tweet = tweets[indexPath.row]
        if let text = tweet.text {
            tweetCell.bodyLabel?.attributedText = parseText(text)
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

            var clientError : NSError?
            
            let request = twitter.APIClient.URLRequestWithMethod(
                "GET", URL: statusesShowEndpoint, parameters: params,
                error: &clientError)
            
            if request == nil {
                println("Error: \(clientError)")
                return
            }
            Twitter.sharedInstance().APIClient.sendTwitterRequest(request) {
                (response, data, connectionError) -> Void in
                if (connectionError != nil) {
                    println("Error: \(connectionError)")
                    return
                }
                
                var jsonError : NSError?
                var jsonData = NSJSONSerialization.JSONObjectWithData(data,
                    options: nil,
                    error: &jsonError) as? NSMutableArray
                
                if jsonError != nil {
                    println("err: \(jsonError)")
                }
                if let array = jsonData {
                    self.parseJSON(array)
                    self.saveJSON(array)
                    self.tableView?.reloadData()
                }
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
}
