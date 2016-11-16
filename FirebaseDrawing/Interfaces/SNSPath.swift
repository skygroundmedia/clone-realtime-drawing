//
//  SNSPath.swift
//  FirebaseDrawing
//
//  Created by Tommy Trojan on 11/15/16.
//  Copyright © 2016 Chris Mendez. All rights reserved.
//
//  Create an Object File
//  Then serialize this file
//  The Objects are generic NSObject so that they can 
//      interface with Firebase without any issues

import UIKit

//MARK: - Drawing Points
class SNSPoint:NSObject {
    var x:CGFloat?
    var y:CGFloat?
    
    init(point:CGPoint) {
        x = point.x
        y = point.y
        print("SNSPoint: created")
    }
}

//MARK: - Drawing Paths are a collection of Drawing Points
class SNSPath: NSObject {
    var points:[SNSPoint]
    var color:UIColor
    
    init(point:CGPoint, color:UIColor) {
        self.color = color
        self.points = Array<SNSPoint>()

        super.init()
        addPoint(point: point)
    }
    
    func addPoint(point:CGPoint){
        //Start tracking SNSPoint paths
        let newPoint = SNSPoint(point: point)
        //Append the new point
        points.append(newPoint)
    }
    
    //MARK: Serialize to JSON
    func serialize() -> NSDictionary{
        //A. Create a dictionary of x/y coordinates
        let coordinates = NSMutableArray()
        for point in points {
            let position = NSMutableDictionary()
                position["x"] = Int(point.x!)
                position["y"] = Int(point.y!)
            coordinates.add(position)
        }
        //B. Create a dictionary of color and coordinates
        let dictionary = NSMutableDictionary()
            dictionary["color"] = "\(color)"
            dictionary["points"] = coordinates
        
        //print("SNSPath::serialize: \(dictionary)")
        return dictionary
    }
}
