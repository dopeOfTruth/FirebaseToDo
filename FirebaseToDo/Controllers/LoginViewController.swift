//
//  LoginViewController.swift
//  ToDoFireBase
//
//  Created by Михаил Красильник on 30.04.2021.
//

import UIKit
import FirebaseAuth
import Firebase

class LoginViewController: UIViewController {

    let segueIdentifier = "tasksSegue"
    var ref: DatabaseReference!
    
    @IBOutlet var mainStackView: UIStackView!
    
    @IBOutlet var warnLabel: UILabel!
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    var kbFrameSize = CGRect(x: 0, y: 0, width: 0, height: 0)
    var isUp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database(url: "https://todo-91a63-default-rtdb.europe-west1.firebasedatabase.app").reference(withPath: "users")
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                self.performSegue(withIdentifier: self.segueIdentifier, sender: nil)
            }
        }
        
        warnLabel.alpha = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(kbDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.text = nil
        passwordTextField.text = nil
    }
    
    @objc func kbDidShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        kbFrameSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        if isUp == false {
            view.frame.origin.y -= (kbFrameSize.height / 2)
            isUp = true
        }

    }
    
    @objc func kbDidHide() {
        if isUp {
            view.frame.origin.y += (kbFrameSize.height / 2)
            isUp = false
        }
    }
    
    func displayWarningLabel(text: String) {
        warnLabel.text = text
        
        UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: []) { [weak self] in
            self?.warnLabel.alpha = 1
        } completion: { [weak self] complete in
            self?.warnLabel.alpha = 0
        }

    }

    @IBAction func loginTapped(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
            displayWarningLabel(text: "Info is incorrect!")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            if error != nil {
                self?.displayWarningLabel(text: "Error occured")
            }
            
            if user != nil {
                self?.performSegue(withIdentifier: (self?.segueIdentifier)!, sender: nil)
                return
            }
            
            self?.displayWarningLabel(text: "No such user")
        }
        
    }
    
    @IBAction func registerTapped(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
            displayWarningLabel(text: "Info is incorrect!")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] responce, error in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
            }
            
            let userRef = self.ref.child((responce?.user.uid)!)
            userRef.setValue(["email": responce?.user.email])
        }
    }
    

}

