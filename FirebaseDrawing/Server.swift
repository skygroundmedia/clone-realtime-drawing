//
//  Firebase.swift
//  FirebaseDrawing
//
//  Created by Tommy Trojan on 11/15/16.
//  Copyright © 2016 Chris Mendez. All rights reserved.
//
//  https://www.raywenderlich.com/139322/firebase-tutorial-getting-started-2
//

import UIKit
import Firebase
import FirebaseDatabase

class Server {

    static let sharedInstance = Server()

    let CALLBACK_NAME = "callbackFromFirebase"
    
    let pathsInLine = NSMutableSet()
    let rootRef = FIRDatabase.database().reference()
    let ref = FIRDatabase.database().reference(withPath: "drawing-paths")
    var refHandle = FIRDatabaseHandle()

    private init(){
        listenToDB()
    }
    
    func listenToDB(){
        //Listen whenever a child has been added
        refHandle = ref.observe(.childAdded, with: { (snapshot) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.CALLBACK_NAME), object: nil, userInfo: ["send":snapshot])
        })
    }
    
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
