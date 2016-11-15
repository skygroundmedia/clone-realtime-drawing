//
//  DrawingView.swift
//  FirebaseDrawing
//
//  Created by Tommy Trojan on 11/14/16.
//  Copyright © 2016 Chris Mendez. All rights reserved.
//
//  http://stackoverflow.com/questions/37401102/binary-operator-cannot-be-applied-to-operands-of-type-int-and-cgfloat
//
import UIKit

class DrawingView: UIView {
    
    let strokeThickness:CGFloat = 1.5
    
    var currentTouch:UITouch?
    var currentColor:UIColor?
    var currentSNSPath:SNSPath?
    
    //While you drag your finger, you want to keep a record of all the points
    var currentPath:[CGPoint]?

    //MARK: - SNS Path data is an interface for Firebase
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
        //SHow off what has been collected
        currentSNSPath?.serialize()
    }
    
    //Mark: Draw
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        //A. Check if there's something that needs to be drawn
        if currentPath != nil {
            //B. With this context, we need to creat a variable
            if let context = UIGraphicsGetCurrentContext(){
                //C. Use the context. Passs the context onto the functions
                context.setLineWidth( strokeThickness )
                context.beginPath()
                context.setStrokeColor(UIColor.black.cgColor)
                //D. Pass the CG Color we want
                if let firstPoint = currentPath?.first {
                    //E. Move to the first point
                    context.move(to: CGPoint(x: firstPoint.x, y: firstPoint.y))
                    //F. Since we have the firstPoint, let's find the subsequent points
                    let startPoint = 1
                    //G. ONce you have the first point, you can look to other points
                    //print("\(startPoint), \((currentPath?.count)! - 1)")
                    if (currentPath?.count)! > 1 {
                        for i in stride(from: startPoint, to: ((currentPath?.count)! - 1), by: 1) {
                            let currentPoint = currentPath![i]
                            //H.  Adding new points in the array to the screen
                            context.addLine(to: CGPoint(x: currentPoint.x, y: currentPoint.y))
                        }
                    }
                    //Now that we've added the points to the array, let's draw them
                    context.drawPath(using: CGPathDrawingMode.stroke)
                    print("DrawingView::draw: Did Draw Lines")
                }
            }
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
        super.touchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetPaths()
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
