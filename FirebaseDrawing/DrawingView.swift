//
//  DrawingView.swift
//  FirebaseDrawing
//
//  Created by Tommy Trojan on 11/14/16.
//  Copyright © 2016 Chris Mendez. All rights reserved.
//
import UIKit

class DrawingView: UIView {

    var currentTouch:UITouch?
    
    //While you drag your finger, you want to keep a record of all the points
    var currentPath:[CGPoint]?
    
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
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentTouch = nil
        currentPath = nil
        print("touchesCancelled:")
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
        currentTouch = nil
        currentPath = nil
        super.touchesEnded(touches, with: event)
    }
}
