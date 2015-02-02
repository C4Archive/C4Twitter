import Foundation

class Tweet : NSObject, NSCoding {
    var text : String?
    var date: String?
    var user: User?
    var retweet: Tweet?
    var favcount: Int = 0
    var retweetCount: Int = 0
    
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
    
    required init(coder: NSCoder) {
        text = coder.decodeObjectOfClass(NSString.self, forKey: "text") as? NSString
        date = coder.decodeObjectOfClass(NSString.self, forKey: "date") as? NSString
        user = coder.decodeObjectOfClass(User.self, forKey: "user") as? User
        retweet = coder.decodeObjectOfClass(Tweet.self, forKey: "retweet") as? Tweet
        favcount = (coder.decodeObjectOfClass(NSNumber.self, forKey: "favcount") as NSNumber).integerValue
        retweetCount = (coder.decodeObjectOfClass(NSNumber.self, forKey: "retweetCount") as NSNumber).integerValue
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(text, forKey: "text")
        coder.encodeObject(date, forKey: "date")
        coder.encodeObject(user, forKey: "user")
        coder.encodeObject(retweet, forKey: "retweet")
        coder.encodeObject(favcount, forKey: "favcount")
        coder.encodeObject(retweetCount, forKey: "retweetCount")
    }
}
