//
//  User.swift
//  ToDoFireBase
//
//  Created by Михаил Красильник on 30.04.2021.
//

import Foundation
import Firebase

struct MUser {
    
    let uid: String
    let email: String
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email!
    }
}
