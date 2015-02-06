import UIKit
import C4Core
import Social
import Accounts
import TwitterKit

class TweetsViewController: UITableViewController {
    var tweets = [Tweet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(20, 0, 0, 0)
        self.tableView.estimatedRowHeight = 200.0;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.refreshControl?.addTarget(self, action: Selector("refresh"), forControlEvents:.ValueChanged)
        loadTweets()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
    func refresh() {
        fetchTweets()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("tweetTableViewCell") as TweetCell
        cell.tweet = tweets[indexPath.row]
        return cell
    }
        
    func fetchTweets() {
        let twitter = Twitter.sharedInstance()
        
        twitter.logInGuestWithCompletion { (session: TWTRGuestSession!, error: NSError!) in
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
                    self.tweets = []
                    self.parseJSON(array)
                    self.saveTweets()
                    self.tableView?.reloadData()
                    self.refreshControl?.endRefreshing()
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
    
    func saveTweets() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let tweetsPath = documentsPath.stringByAppendingPathComponent("/tweets.archive")
        NSKeyedArchiver.archiveRootObject(tweets, toFile: tweetsPath)
    }
    
    func loadTweets() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let tweetsPath = documentsPath.stringByAppendingPathComponent("/tweets.archive")
        let newTweets = NSKeyedUnarchiver.unarchiveObjectWithFile(tweetsPath) as? [Tweet]
        if let newTweets = newTweets {
            tweets = newTweets
            self.tableView?.reloadData()
        } else {
            fetchTweets()
        }
    }
}
