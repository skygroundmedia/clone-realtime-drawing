//
//  Firebase.swift
//  FirebaseDrawing
//
//  Created by Tommy Trojan on 11/15/16.
//  Copyright © 2016 Chris Mendez. All rights reserved.
//
//  https://www.raywenderlich.com/139322/firebase-tutorial-getting-started-2

import UIKit
import Firebase
import FirebaseDatabase

class Server {
    //Singleton
    static let sharedInstance = Server()
    private init(){}
    
    let pathsInLine = NSMutableSet()
    let rootRef = FIRDatabase.database().reference()
    let ref = FIRDatabase.database().reference(withPath: "drawing-paths")
    
    func testUnit(text:String){
        ref.setValue(text)
    }
    
    // Listen to Firebase when new paths are edited
    func saveToDB(path:SNSPath) -> String{
        //A. Get the Firebase Key
        let firebaseKey = ref.childByAutoId()
        //B. JSON Data we publish to Firebase
        let jsonData = path.serialize()
        
        pathsInLine.add(firebaseKey)
        
        //C. Save to Firebase Server
        firebaseKey.setValue(jsonData) { (error, ref) in
            if let error = error  {
                print("Error saving to Firebase \(error.localizedDescription)")
            } else {
                self.pathsInLine.remove(firebaseKey)
            }
        }
        //We don't have to worry aout keys anymore
        return firebaseKey.key
    }
}
