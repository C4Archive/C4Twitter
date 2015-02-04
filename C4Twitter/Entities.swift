import Foundation

class Entities : NSObject, NSCoding {
    var media: [MediaEntity]?

    init(json: NSDictionary) {
        if let mediaArray = json["media"] as? [NSDictionary] {
            media = [MediaEntity]()
            for mediaDictionary in mediaArray {
                let mediaEntity = MediaEntity(json: mediaDictionary)
                media!.append(mediaEntity)
            }
        }
    }

    required init(coder: NSCoder) {
        media = coder.decodeObjectOfClass(NSArray.self, forKey: "media") as? [MediaEntity]
    }

    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(media, forKey: "media")
    }
}
