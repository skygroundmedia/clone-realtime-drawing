//
//  Firebase.swift
//  FirebaseDrawing
//
//  Created by Tommy Trojan on 11/15/16.
//  Copyright © 2016 Chris Mendez. All rights reserved.
//
//  https://www.raywenderlich.com/139322/firebase-tutorial-getting-started-2

import UIKit
import FirebaseDatabase

class Server {
    
    static let sharedInstance = Server()
    private init(){}
    
    let pathsInLine = NSMutableSet()

    
    let rootRef = FIRDatabase.database().reference()
    
    let ref = FIRDatabase.database().reference(withPath: "drawing-paths")
    
    func testUnit(text:String){
        ref.setValue(text)
    }
    
    func addPathToSend(path:SNSPath){
        //A. Get the Firebase Key
        let key = ref.childByAutoId()
        
        
        pathsInLine.add(key)
    }
}
