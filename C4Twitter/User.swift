import Foundation

class User : NSObject, NSCoding {
    var name: String?
    var imageURL: String?
    var screenName: String?
    var userURL: String?
    
    init(json: NSDictionary) {
        name = json["name"] as? String
        imageURL = json["profile_image_url"] as? String
        screenName = json["screen_name"] as? String
        userURL = json["url"] as? String
    }
    
    required init(coder: NSCoder) {
        name = coder.decodeObjectOfClass(NSString.self, forKey: "name") as? NSString
        imageURL = coder.decodeObjectOfClass(NSString.self, forKey: "imageURL") as? NSString
        screenName = coder.decodeObjectOfClass(NSString.self, forKey: "screenName") as? NSString
        userURL = coder.decodeObjectOfClass(NSString.self, forKey: "userURL") as? NSString
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(name, forKey: "name")
        coder.encodeObject(imageURL, forKey: "imageURL")
        coder.encodeObject(screenName, forKey: "screenName")
        coder.encodeObject(userURL, forKey: "userURL")
    }
}
