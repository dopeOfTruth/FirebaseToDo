//
//  Task.swift
//  ToDoFireBase
//
//  Created by Михаил Красильник on 30.04.2021.
//

import Foundation
import Firebase

struct Task {
    
    let title: String
    let userID: String
    let ref: DatabaseReference?
    var completed: Bool = false
    
    init(title: String, userID: String) {
        self.title = title
        self.userID = userID
        ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        title = snapshotValue["title"] as! String
        userID = snapshotValue["userID"] as! String
        completed = snapshotValue["completed"] as! Bool
        ref = snapshot.ref
    }
    
    func convertToDictionary() -> Any {
        return ["title": title, "userID": userID, "completed": completed]
    }
}
