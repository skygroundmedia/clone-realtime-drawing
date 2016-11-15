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

//MARK: - Drawing Paths triggered by DrawingView::touchesBegan
class SNSPath: NSObject {
    var points:[SNSPoint]
    var color:UIColor
    
    init(point:CGPoint, color:UIColor) {
        self.color = color
        self.points = []
        
        super.init()

        //Start tracking SNSPoint paths
        addPoint(point: point)
    }
    
    func addPoint(point:CGPoint){
        let newPoint = SNSPoint(point: point)
        points.append(newPoint)
    }
    
    //Convert the drawing data to serialized JSON
    func serialize() -> NSDictionary{
        //Add each point within points to dict
        let coordinates = NSMutableArray()
        for point in points {
            let position = NSMutableDictionary()
                position["x"] = point.x
                position["y"] = point.y
            coordinates.add(position)
        }
        //This is the master dictionary you will send to DB
        let dictionary = NSDictionary()
            dictionary.setValue(color, forKey: "color")
            dictionary.setValue(coordinates, forKey: "coordinates")
     
        print(dictionary)
        return dictionary
    }
}
