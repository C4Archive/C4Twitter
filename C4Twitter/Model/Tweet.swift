import Foundation

class Tweet : UniqueObject {
    var text: String?
    var date: NSDate?
    var user: User?
    var retweet: Tweet?
    var favoriteCount: Int = 0
    var retweetCount: Int = 0
    var entities: Entities?
    
    override init(json: NSDictionary) {
        super.init(json: json)
        
        if let dateString = json["created_at"] as? String {
            date = parseDate(dateString)
        }
        text = json["text"] as? String
        favoriteCount = json["favorite_count"] as Int
        retweetCount = json["retweet_count"] as Int
        
        if let dict = json["user"] as? NSDictionary {
            user = User(json: dict)
        }
        
        if let retweetDict = json["retweeted_status"] as? NSDictionary {
            retweet = Tweet(json: retweetDict)
        }
        
        if let entitiesDictionary = json["entities"] as? NSDictionary {
            entities =  Entities(json: entitiesDictionary)
        }
    }
    
    func parseDate(string: String) -> NSDate? {
        var formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        return formatter.dateFromString(string)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        text = coder.decodeObjectOfClass(NSString.self, forKey: "text") as? NSString
        date = coder.decodeObjectOfClass(NSString.self, forKey: "date") as? NSDate
        user = coder.decodeObjectOfClass(User.self, forKey: "user") as? User
        retweet = coder.decodeObjectOfClass(Tweet.self, forKey: "retweet") as? Tweet
        if let favoriteCountNumber = coder.decodeObjectOfClass(NSNumber.self, forKey: "favoriteCount") as? NSNumber {
            favoriteCount = favoriteCountNumber.integerValue
        }
        if let retweetCountNumber = coder.decodeObjectOfClass(NSNumber.self, forKey: "retweetCount") as? NSNumber {
            retweetCount = retweetCountNumber.integerValue
        }
        entities = coder.decodeObjectOfClass(NSArray.self, forKey: "entities") as? Entities
    }
    
    override func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
        coder.encodeObject(text, forKey: "text")
        coder.encodeObject(date, forKey: "date")
        coder.encodeObject(user, forKey: "user")
        coder.encodeObject(retweet, forKey: "retweet")
        coder.encodeObject(favoriteCount, forKey: "favoriteCount")
        coder.encodeObject(retweetCount, forKey: "retweetCount")
        coder.encodeObject(entities, forKey: "entities")
    }
}
