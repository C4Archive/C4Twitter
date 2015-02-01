//
//  TweetCell.swift
//  C4Twitter
//
//  Created by travis on 2015-01-31.
//  Copyright (c) 2015 C4. All rights reserved.
//

import Foundation
import UIKit
import C4Core
import C4Animation
import C4UI

public class TweetCell : UITableViewCell {
    internal var shouldAddHeader = true
    public weak var tvc : UITableView?

    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clearColor()
        self.textLabel?.textColor = .whiteColor()
        self.textLabel?.font = UIFont(name: "FreightTextLight", size: 18)
        self.textLabel?.textAlignment = .Center
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.numberOfLines = 10
        textLabel?.sizeToFit()
        var f = textLabel!.frame
        textLabel!.frame = CGRectMake(11, 28, UIScreen.mainScreen().bounds.size.width-44, f.height)
        let contentFrame = CGRectIntersection(contentView.frame, textLabel!.frame)
        contentView.frame = contentFrame
    }
    
    public var imageURL : String = "" {
        didSet {
            if shouldAddHeader {
                self.twitterCellHeader()
                shouldAddHeader = false
            }
        }
    }
    public var userURL : String = ""
    public var name : String = "name" {
        didSet {
            
        }
    }

    public var screenName : String = ""
    public var date : String = "October 21, 1979"
    public var favCount = -1
    public var rtCount = -1
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var bg = C4Rectangle()
    var scrollview = UIScrollView()
    var logo : C4Image?
    
    func twitterCellHeader() {
        if let tvc = self.tvc {
            self.tvc!.addObserver(self, forKeyPath: "contentOffset", options: .New, context: nil)
        }

        bg = C4Rectangle(frame: C4Rect(0,0,Double(UIScreen.mainScreen().bounds.size.width),44))
        bg.lineWidth = 0
        bg.fillColor = darkGray
        
        let retweets = C4TextShape(text: "Retweets", font: C4Font(name: "Helvetica-Light", size: 16))
        retweets.center = C4Point(bg.width - retweets.width/2.0 - 10.0, bg.height / 2.0)
        retweets.fillColor = white
        bg.add(retweets)
        
        let numRT = C4TextShape(text: "4", font: C4Font(name: "Helvetica-Bold", size: 16))
        numRT.origin = C4Point(retweets.origin.x - numRT.width - 6, retweets.origin.y)
        numRT.fillColor = white
        bg.add(numRT)
        
        let dot = C4Ellipse(frame: C4Rect(0,0,6,6))
        dot.lineWidth = 0
        dot.fillColor = C4Blue
        dot.center = C4Point(numRT.origin.x-dot.width-4, numRT.center.y)
        bg.add(dot)
        
        let date = C4TextShape(text: "January 14, 2014", font: C4Font(name: "Helvetica-Light", size: 16))
        date.origin = C4Point(dot.origin.x-6-date.width,numRT.origin.y)
        date.fillColor = white
        bg.add(date)
        
        let fg = C4Rectangle(frame: bg.bounds)
        fg.lineWidth = 0
        fg.fillColor = lightGray
        self.add(bg)
        bg.add(fg)
        
        var circ = C4Ellipse(frame: C4Rect())

    
        logo = C4Image(imageURL)
        logo?.frame = C4Rect(0,0,35,35)
        circ = C4Ellipse(frame: logo!.bounds)
        logo!.layer?.mask = circ.layer
        circ.lineWidth = 0
        logo!.center = C4Point(fg.width / 2.0, 0.0)
        fg.add(logo!)

        fg.interactionEnabled = false
        
        let font = C4Font(name: "Helvetica", size: 16)
        let name = C4TextShape(text: "cocoafor", font: font)
        name.fillColor = white
        name.lineWidth = 0
        name.center = C4Point(name.width / 2 + 10, bg.height / 2)
        bg.add(name)
        
        let a = C4ViewAnimation(duration: 0.15) {
            fg.center = C4Point(self.bg.width / 2.0, self.bg.height / 2.0)
            self.logo!.center = C4Point(fg.width / 2.0, self.logo!.center.y)
            name.opacity = 1.0
        }
        
        bg.addPanGestureRecognizer { (location, translation, velocity, state) -> () in
            if(translation.x < 0 && translation.x >= -(self.bg.width - circ.width - 20) ) {
                fg.center = C4Point(self.bg.width/2 + translation.x, self.bg.height/2.0)
                name.opacity = (self.bg.width / 3.0 + translation.x)/(self.bg.width/3.0)
                self.logo!.center = C4Point(fg.width / 2.0 - translation.x/2.0, self.logo!.center.y)
            }
            
            if state == .Ended {
                a.animate()
            }
        }
        
        self.layoutSubviews()
    }
    
    override public func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject: AnyObject], context: UnsafeMutablePointer<Void>) {
        if keyPath == "contentOffset" {
            if let tv = self.tvc {
                let myPosition = tv.convertPoint(self.frame.origin, toView: tv.superview)
                let offset = myPosition.y / tv.frame.size.height
                if(offset >= 0 && offset <= 1.0) {
                    logo!.center = C4Point(logo!.center.x, self.bg.height * Double(offset) / 4.0 + self.bg.height / 2.0)
                }
            }
            
        }
    }
}