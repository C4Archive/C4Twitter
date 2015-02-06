import Foundation
import UIKit
import C4Core
import C4Animation
import C4UI

public class TweetCell : UITableViewCell, UIScrollViewDelegate {
    struct Constants {
        static let tagColor = UIColor(red: 0.510, green: 0.541, blue: 0.561, alpha: 1.0)
    }

    @IBOutlet weak var scrollView: UIScrollView?
    @IBOutlet weak var slidingHeaderView : UIView?
    @IBOutlet weak var userNameLabel : UILabel?
    @IBOutlet weak var userScreenNameLabel : UILabel?
    @IBOutlet weak var dateLabel : UILabel?
    @IBOutlet weak var userImageView : UIImageView?
    @IBOutlet weak var tweetsLabel : UILabel?
    @IBOutlet weak var starsLabel : UILabel?
    @IBOutlet weak var retweetsLabel : UILabel?
    @IBOutlet weak var bodyLabel : UILabel?
    @IBOutlet weak var mediaImageView : UIImageView?
    @IBOutlet weak var mediaHeightConstraint : NSLayoutConstraint?
    @IBOutlet weak var spacingConstraint : NSLayoutConstraint?
    
    public override func awakeFromNib() {
        userImageView?.layer.cornerRadius = userImageView!.bounds.width/2
        userImageView?.layer.masksToBounds = true
    }
    
    var tweet : Tweet? {
        didSet {
            updateContents()
        }
    }

    public override func prepareForReuse() {
        scrollView?.setContentOffset(CGPoint(x: 160, y: 0), animated: false)
    }
    
    func updateContents() {
        if let tweet = tweet {
            updateContents(tweet)
        }
    }
    
    func updateContents(tweet: Tweet) {
        if let name = tweet.user?.name {
            userNameLabel?.text = name
        } else {
            userNameLabel?.text = ""
        }
        if let screenName = tweet.user?.screenName {
            userScreenNameLabel?.text = screenName
        } else {
            userScreenNameLabel?.text = ""
        }
        
        if let date = tweet.date {
            dateLabel?.text = NSDateFormatter.localizedStringFromDate(date, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.NoStyle)
        } else {
            dateLabel?.text = ""
        }

        starsLabel?.text = tweet.favoriteCount.description
        retweetsLabel?.text = tweet.retweetCount.description

        if let text = tweet.text {
            bodyLabel?.attributedText = TweetCell.buildAttributedText(text)
        } else {
            bodyLabel?.attributedText = nil
        }
        
        // FIXME: this is really inefficient when scrolling, we need to load the images on the background
        userImageView?.image = nil
        if let imageURLString = tweet.user?.imageURL {
            if let url = NSURL(string: imageURLString) {
                var image = C4Image(url: url)
                userImageView?.image = image.uiimage
            }
        }

        mediaImageView?.image = nil
        mediaHeightConstraint?.constant = 0
        spacingConstraint?.constant = 0
        if let media = tweet.entities?.media {
            if let url = media.first?.mediaURL {
                var image = C4Image(url: url)
                mediaImageView?.image = image.uiimage

                let maxWidth = mediaImageView!.bounds.size.width
                if CGFloat(image.size.width) > maxWidth {
                    let height = CGFloat(image.size.height) * maxWidth / CGFloat(image.size.width)
                    mediaHeightConstraint?.constant = CGFloat(height)
                } else {
                    mediaHeightConstraint?.constant = CGFloat(image.size.height)
                }
                spacingConstraint?.constant = 20
                layoutIfNeeded()
            }
        }
    }

    class func buildAttributedText(text: String) -> NSAttributedString? {
        var words = text.componentsSeparatedByString(" ")
        
        var attributedString = NSMutableAttributedString()
        for word in words {
            let attributedWord = NSMutableAttributedString(string: word + " ")
            let range = NSMakeRange(0, countElements(word))
            
            if word.hasPrefix("@") || word.hasPrefix("#") {
                attributedWord.addAttribute(NSForegroundColorAttributeName, value: Constants.tagColor, range: range)
                attributedWord.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Medium", size: 26.0)!, range: range)
            }
            
            if word.hasPrefix("http:") || word.hasPrefix("www.") {
                attributedWord.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleThick.rawValue, range: range)
            }
            
            attributedString.appendAttributedString(attributedWord)
        }
        
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.alignment = .Center
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        
        
        return attributedString
    }

    public func scrollViewDidScroll(scrollView: UIScrollView) {

    }
    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollView.setContentOffset(CGPoint(x: 160, y: 0), animated: true)
    }

    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollView.setContentOffset(CGPoint(x: 160, y: 0), animated: true)
    }
}
