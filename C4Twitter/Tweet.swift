import Foundation

class Tweet {
    var text : String?
    var date: String?
    var user: User?
    var retweet: Tweet?
    var favcount: Int = 0
    var retweetCount: Int = 0
    
    init() {
    }
    
    init(json: NSDictionary) {
        date = json["created_at"] as? String
        text = json["text"] as? String
        favcount = json["favorite_count"] as Int
        retweetCount = json["retweet_count"] as Int
        
        if let dict = json["user"] as? NSDictionary {
            user = User(json: dict)
        }
        
        if let retweetDict = json["retweeted_status"] as? NSDictionary {
            retweet = Tweet(json: retweetDict)
        }
    }
}
