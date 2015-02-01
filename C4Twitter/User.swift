import Foundation

class User {
    var name: String?
    var imageURL: String?
    var screenName: String?
    var userURL: String?
    
    init() {
        
    }
    
    init(json: NSDictionary) {
        name = json["name"] as? String
        imageURL = json["profile_image_url"] as? String
        screenName = json["screen_name"] as? String
        userURL = json["url"] as? String
    }
}
