import Foundation
import UIKit
import C4Core
import C4Animation
import C4UI

public class TweetCell : UITableViewCell {
    let tagColor = UIColor(red: 0.510, green: 0.541, blue: 0.561, alpha: 1.0)
    
    @IBOutlet weak var headerView : UIView?
    @IBOutlet weak var userLabel : UILabel?
    @IBOutlet weak var dateLabel : UILabel?
    @IBOutlet weak var userImageView : UIImageView?
    @IBOutlet weak var bodyLabel : UILabel?

    public override func awakeFromNib() {
        userImageView?.layer.cornerRadius = userImageView!.bounds.width/2
        userImageView?.layer.masksToBounds = true
    }
    
    var tweet : Tweet? {
        didSet {
            updateContents()
        }
    }
    
    func updateContents() {
        userLabel?.text = tweet?.user?.name
        dateLabel?.text = tweet?.date
        bodyLabel?.attributedText = attributedText()
        
        // FIXME: this is really inefficient when scrolling, we need to load the images on the background
        if let imageURLString = tweet?.user?.imageURL {
            if let url = NSURL(string: imageURLString) {
                var image = C4Image(url: url)
                userImageView?.image = image.uiimage
            } else {
                userImageView?.image = nil
            }
        } else {
            userImageView?.image = nil
        }
    }
    
    func attributedText() -> NSAttributedString? {
        if let text = tweet?.text {
            var words = text.componentsSeparatedByString(" ")
            
            var rt = words[0] == "RT"
            
            var attributedString = NSMutableAttributedString()
            for word in words {
                let attributedWord = NSMutableAttributedString(string: word + " ")
                let range = NSMakeRange(0, countElements(word))
                
                if word.hasPrefix("@") || word.hasPrefix("#") {
                    attributedWord.addAttribute(NSForegroundColorAttributeName, value: tagColor, range: range)
                    attributedWord.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Medium", size: 26.0)!, range: range)
                }
                
                if word.hasPrefix("http:") || word.hasPrefix("www.") {
                    attributedWord.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleThick.rawValue, range: range)
                }
                
                attributedString.appendAttributedString(attributedWord)
            }
            
            if rt {
                let prefix = NSAttributedString(string: "“")
                attributedString.insertAttributedString(prefix, atIndex: 3)
                let postfix = NSAttributedString(string: "”")
                attributedString.insertAttributedString(postfix, atIndex: attributedString.length)
            }
            
            var paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 6
            paragraphStyle.alignment = .Center
            attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
            
            
            return attributedString
        }
        
        return nil
    }
}