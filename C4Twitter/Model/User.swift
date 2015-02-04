import Foundation

class User : UniqueObject {
    var name: String?
    var imageURL: String?
    var screenName: String?
    var userURL: String?
    
    override init(json: NSDictionary) {
        super.init(json: json)
        
        name = json["name"] as? String
        imageURL = json["profile_image_url"] as? String
        screenName = json["screen_name"] as? String
        userURL = json["url"] as? String
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)

        name = coder.decodeObjectOfClass(NSString.self, forKey: "name") as? NSString
        imageURL = coder.decodeObjectOfClass(NSString.self, forKey: "imageURL") as? NSString
        screenName = coder.decodeObjectOfClass(NSString.self, forKey: "screenName") as? NSString
        userURL = coder.decodeObjectOfClass(NSString.self, forKey: "userURL") as? NSString
    }
    
    override func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
        coder.encodeObject(name, forKey: "name")
        coder.encodeObject(imageURL, forKey: "imageURL")
        coder.encodeObject(screenName, forKey: "screenName")
        coder.encodeObject(userURL, forKey: "userURL")
    }
}
