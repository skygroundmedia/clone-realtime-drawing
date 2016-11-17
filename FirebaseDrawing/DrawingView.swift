//
//  DrawingView.swift
//  FirebaseDrawing
//
//  Created by Tommy Trojan on 11/14/16.
//  Copyright © 2016 Chris Mendez. All rights reserved.
//
//  http://stackoverflow.com/questions/37401102/binary-operator-cannot-be-applied-to-operands-of-type-int-and-cgfloat
//
//  Create an arrary with all the paths but when a new firebase path get's added, let's only transfer that new data path.
import UIKit
import Firebase

class DrawingView: UIView {
    
    let strokeThickness:CGFloat = 1.5
    
    //While you drag your finger, you want to keep a record of all the points
    var currentPath:[CGPoint]?
    var currentTouch:UITouch?
    var currentColor:UIColor?
    var currentSNSPath:SNSPath?

    //Used when we add our own values and when we get an update from Firebase
    var allPaths:[SNSPath] = []
    //Each key represents a differnt user publish a path
    var allKeys:[String]?
    //Instance of Firebase DB
    var server = Server.sharedInstance

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        listenToNotifications()
    }
    
    //MARK: - Notifications
    func listenToNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification), name: NSNotification.Name(rawValue: server.CALLBACK_NAME), object: nil)
    }
    
    func onNotification(sender:Notification){
        //Dictionary of Return data
        if let info = sender.userInfo {
            print(info)
        }
    }
    
    //MARK: - Firebase Related Data
    //Start preparing the data to send to Firebase
    func initSNSPath(point:CGPoint, color:UIColor){
        currentSNSPath = SNSPath(point: point, color: color)
    }
    
    func addToSNSPath(point:CGPoint){
        currentSNSPath?.addPoint(point: point)
    }
    
    //MARK: - Drawing Functions
    //Tell the UI it needs to be refreshed for all the different cases
    func clearDisplay(){
        setNeedsDisplay()
    }
    
    func resetPaths(){
        print("DrawingView::resetPaths")
        currentTouch = nil
        currentPath = nil
    }
    
    func sendDataToServer(){
        if let path = currentSNSPath {
            //Send to Firebase Server
            let returnKey = server.saveToDB(path: path)
            //This is the key from firebase. When firebase announces an update / change
            //  this will simply say, sure, send the update
            allKeys?.append(returnKey)
            //Send to All Paths Array
            allPaths.append(path)
        }
    }
    
    //Mark: Draw
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        //A. Prepare to draw by first getting the draw context
        let context = UIGraphicsGetCurrentContext()
            context?.setLineWidth( strokeThickness )
            context?.beginPath()
            context?.setStrokeColor(UIColor.black.cgColor)

        //B. On Touch Up
        for path in allPaths {
            //1. Get all the paths
            let points = path.points
            //2. Identify the first one
            if let firstPoint = points.first {
                //3. Draw line
                context?.move(to: CGPoint(x: firstPoint.x!, y: firstPoint.y!))
                //D. Move past index(0) and go to subsequent points
                if points.count > 1 {
                    //5.  Adding new points in the array to the screen
                    for index in stride(from: 1, to: (points.count - 1), by: 1) {
                        let currentPoint = points[index]
                        //6. Add line
                        context?.addLine(to: CGPoint(x: currentPoint.x!, y: currentPoint.y!))
                    }
                }
                context?.drawPath(using: CGPathDrawingMode.stroke)
            }
        }

        //C. On Touch Down
        if let firstPoint = currentPath?.first {
            //A. Pick and move to first point
            context?.move(to: CGPoint(x: firstPoint.x, y: firstPoint.y))
            //C. Now that you have this first point, find the subsequent points
            if (currentPath?.count)! > 1 {
                //D. Move past index(0) and go to subsequent points
                for i in stride(from: 1, to: ((currentPath?.count)! - 1), by: 1) {
                    let currentPoint = currentPath![i]
                    //H.  Adding new points in the array to the screen
                    context?.addLine(to: CGPoint(x: currentPoint.x, y: currentPoint.y))
                }
            }
            context?.drawPath(using: CGPathDrawingMode.stroke)
        }
    }
    
    //When a user touches the screen, it will begin drawing
    func addTouch(touches:Set<UITouch>){
        if currentPath != nil {
            for touch in touches {
                //Check if touch is == currentTouch
                if touch == currentTouch {
                    //A. Get Location
                    let currentPoint = currentTouch?.location(in: self)
                    //B. Check if it exist
                    if let currentPoint = currentPoint{
                        //C. Append to path
                        currentPath?.append(currentPoint)
                        //D. Collect data to send to Firebase
                        addToSNSPath(point: currentPoint)
                        print("DrawingView::addTouch: A new path with \(currentPoint)")
                    } else {
                        print("Found an Empty touch")
                    }
                }
            }
        }
        clearDisplay()
    }
    
    //MARK: - Touch Functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //A. User touches for the first time
        if currentPath == nil {
            currentTouch = UITouch()
            //1. If three fingers touch simultaneously, only target the first finger
            currentTouch = touches.first
            let currentPoint = currentTouch?.location(in: self)
            //2. Check if it exists
            if let currentPoint = currentPoint{
                //3. Create a an array of points
                currentPath = Array<CGPoint>()
                //4. Add the first point
                currentPath?.append(currentPoint)
                //print("touchesBegan: A new path with \(currentPoint)")
                //5. Add the first point to Firebase
                initSNSPath(point: currentPoint, color: UIColor.black)
            } else {
                print("Found an Empty touch")
            }
        }
        //B. Clear the data
        clearDisplay()
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        addTouch(touches: touches)
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("DrawingView::touchesEnded:")
        addTouch(touches: touches)
        resetPaths()
        sendDataToServer()
        super.touchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetPaths()
        sendDataToServer()
        print("DrawingView::touchesCancelled:")
        clearDisplay()
        super.touchesCancelled(touches, with: event)
    }
}


extension DrawingView {
    func randomInRange(range: ClosedRange<Int>) -> Int {
        let count = UInt32(range.upperBound - range.lowerBound)
        return  Int(arc4random_uniform(count)) + range.lowerBound
    }
}
