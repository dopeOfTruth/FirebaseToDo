//
//  TasksViewController.swift
//  ToDoFireBase
//
//  Created by Михаил Красильник on 30.04.2021.
//

import UIKit
import FirebaseAuth
import Firebase

class TasksViewController: UIViewController {

    @IBOutlet var myTableView: UITableView!
    
    var user: MUser!
    var ref: DatabaseReference!
    var tasks = [Task]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let currentUser = Auth.auth().currentUser else { return }
        user = MUser(user: currentUser)
        ref = Database.database(url: "https://todo-91a63-default-rtdb.europe-west1.firebasedatabase.app").reference(withPath: "users").child(String(user.uid)).child("tasks")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ref.observe(.value) { [weak self] snapshot in
            var _tasks = [Task]()
            for item in snapshot.children {
                let task = Task(snapshot:  item as! DataSnapshot)
                _tasks.append(task)
            }
            
            self?.tasks = _tasks
            self?.myTableView.reloadData()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ref.removeAllObservers()
    }
    
    @IBAction func addTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "New Task", message: "Add new task", preferredStyle: .alert)
        alert.addTextField()
        let save = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            
            guard let textField = alert.textFields?.first, textField.text != "" else { return }
            let task = Task(title: textField.text!, userID: (self?.user.uid)!)
            let taskRef = self?.ref.child(task.title.lowercased())
            taskRef?.setValue(task.convertToDictionary())
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addAction(save)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func signOutTapped(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        
        dismiss(animated: true, completion: nil)
    }
}


extension TasksViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        
        let task = tasks[indexPath.row]
        
        cell.backgroundColor = .clear
        cell.textLabel?.text = task.title
        cell.textLabel?.textColor = .white
        toggleCompletion(cell: cell, isCompleted: task.completed)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            task.ref?.removeValue()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let task = tasks[indexPath.row]
        let isCompleted = !task.completed
        toggleCompletion(cell: cell, isCompleted: isCompleted)
        task.ref?.updateChildValues(["completed": isCompleted])
    }
    
    func toggleCompletion(cell: UITableViewCell, isCompleted: Bool) {
        cell.accessoryType = isCompleted ? .checkmark : .none
    }
}
