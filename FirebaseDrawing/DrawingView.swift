//
//  DrawingView.swift
//  FirebaseDrawing
//
//  Created by Tommy Trojan on 11/14/16.
//  Copyright © 2016 Chris Mendez. All rights reserved.
//
// http://stackoverflow.com/questions/37401102/binary-operator-cannot-be-applied-to-operands-of-type-int-and-cgfloat
import UIKit

class DrawingView: UIView {
    
    var currentTouch:UITouch?
    
    //While you drag your finger, you want to keep a record of all the points
    var currentPath:[CGPoint]?
    
    //MARK: - Drawing Functions
    //Tell the UI it needs to be refreshed for all the different cases
    func refreshDisplay(){
        setNeedsDisplay()
    }
    
    //Mark: Draw
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        //A. Check if there's something that needs to be drawn
        if currentPath != nil {
            //B. With this context, we need to creat a variable
            if let context = UIGraphicsGetCurrentContext(){
                //C. Use the context. Passs the context onto the functions
                context.setLineWidth(0.5)
                context.beginPath()
                context.setStrokeColor(UIColor.black.cgColor)
                //D. Pass the CG Color we want
                if let firstPoint = currentPath?.first {
                    //E. Move to the first point
                    context.move(to: CGPoint(x: firstPoint.x, y: firstPoint.y))
                    //F. Since we have the firstPoint, let's find the subsequent points
                    let startPoint = 1
                    //G. ONce you have the first point, you can look to other points
                    print("\(startPoint), \((currentPath?.count)! - 1)")
                    /*
                    for i in startPoint...Int((currentPath?.count)!) - 1 {
                        let currentPoint = currentPath![i]
                        //H.  Adding new points in the array to the screen
                        context.addLine(to: CGPoint(x: currentPoint.x, y: currentPoint.y))
                    }
                     */
                    for i in stride(from: startPoint, to: ((currentPath?.count)! - 1), by: 1) {
                        let currentPoint = currentPath![i]
                        //H.  Adding new points in the array to the screen
                        context.addLine(to: CGPoint(x: currentPoint.x, y: currentPoint.y))
                    }
                    
                    //Now that we've added the points to the array, let's draw them
                    context.drawPath(using: CGPathDrawingMode.stroke)
                    print("draw: Did Draw Lines")
                }
            }
        }
    }
    
    
    //MARK: - Touch Functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentPath == nil {
            currentTouch = UITouch()
            //If three fingers touch simultaneously, we want to capture the first finger
            currentTouch = touches.first
            let currentPoint = currentTouch?.location(in: self)
            //This is how we can work around a force unwrap
            if let currentPoint = currentPoint{
                currentPath = []
                currentPath?.append(currentPoint)
                print("touchesBegan: A new path with \(currentPoint)")
            } else {
                print("Fount an Empty touch")
            }
        }
        refreshDisplay()
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
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
                        print("touchesMoved: A new path with \(currentPoint)")
                    } else {
                        print("Fount an Empty touch")
                    }
                }
            }
        }
        refreshDisplay()
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentTouch = nil
        currentPath = nil
        print("touchesCancelled:")
        refreshDisplay()
        super.touchesCancelled(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentPath != nil {
            //Look thorugh all the touches
            for touch in touches {
                //Check if touch is == currentTouch
                if touch == currentTouch {
                    //A. Get Location
                    let currentPoint = currentTouch?.location(in: self)
                    //B. Check if it exist
                    if let currentPoint = currentPoint{
                        //C. Append to path
                        currentPath?.append(currentPoint)
                        print("touchesEnded: A new path with \(currentPoint)")
                    } else {
                        print("Fount an Empty touch")
                    }
                }
            }
        }
        refreshDisplay()
        currentTouch = nil
        currentPath = nil
        super.touchesEnded(touches, with: event)
    }
}


extension DrawingView {
    func randomInRange(range: ClosedRange<Int>) -> Int {
        let count = UInt32(range.upperBound - range.lowerBound)
        return  Int(arc4random_uniform(count)) + range.lowerBound
    }
}
