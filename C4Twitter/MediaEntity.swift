import Foundation

class MediaEntity : UniqueObject {
    var indices: [Int]?
    var mediaURL: NSURL?
    var URL: NSURL?
    var type: String?

    override init(json: NSDictionary) {
        super.init(json: json)

        if let indicesArray = json["indices"] as? [AnyObject] {
            indices = [Int]()
            for i in indicesArray {
                indices!.append(i as Int)
            }
        }

        if let mediaURLString = json["media_url"] as? String {
            mediaURL = NSURL(string: mediaURLString)
        }
        if let URLString = json["url"] as? String {
            URL = NSURL(string: URLString)
        }
        type = json["type"] as? String
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        indices = coder.decodeObjectOfClass(NSArray.self, forKey: "indices") as? [Int]
        mediaURL = coder.decodeObjectOfClass(NSURL.self, forKey: "mediaURL") as? NSURL
        URL = coder.decodeObjectOfClass(NSURL.self, forKey: "URL") as? NSURL
        type = coder.decodeObjectOfClass(NSString.self, forKey: "type") as? String
    }

    override func encodeWithCoder(coder: NSCoder) {
        super.encodeWithCoder(coder)
        coder.encodeObject(indices, forKey: "indices")
        coder.encodeObject(mediaURL, forKey: "mediaURL")
        coder.encodeObject(URL, forKey: "URL")
        coder.encodeObject(type, forKey: "type")
    }
}
