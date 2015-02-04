import Foundation

/**
  UniqueObject contains an id that is unique between all objects.
 */
class UniqueObject : NSObject, NSCoding {
    var id: UInt64 = 0

    init(json: NSDictionary) {
        let idNumber = json["id"] as NSNumber
        id = idNumber.unsignedLongLongValue
    }

    required init(coder: NSCoder) {
        if let idNumber = coder.decodeObjectOfClass(NSNumber.self, forKey: "id") as? NSNumber {
            id = idNumber.unsignedLongLongValue
        }
    }

    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(NSNumber(unsignedLongLong: id), forKey: "id")
    }
}
