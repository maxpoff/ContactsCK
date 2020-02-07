//
//  ContactListTableViewController.swift
//  ContactsCK
//
//  Created by Maxwell Poffenbarger on 2/7/20.
//  Copyright © 2020 Maxwell Poffenbarger. All rights reserved.
//

import UIKit

class ContactListTableViewController: UITableViewController {
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    //MARK: - Class Methods
    func loadData() {
        ContactController.sharedInstance.fetchAllContacts { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.tableView.reloadData()
                    
                case .failure(let error):
                    self.presentErrorToUser(localizedError: error)
                }
            }
        }
    }
    
    // MARK: - Table view data source
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        return 0
    //    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ContactController.sharedInstance.contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        
        let contact = ContactController.sharedInstance.contacts[indexPath.row]
        
        cell.textLabel?.text = contact.name
        
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let contactToDelete = ContactController.sharedInstance.contacts[indexPath.row]
        
        if editingStyle == .delete {
            
            guard let index = ContactController.sharedInstance.contacts.firstIndex(of: contactToDelete) else {return}
            
            ContactController.sharedInstance.delete(contact: contactToDelete) { (result) in
                switch result {
                case .success(let success):
                    if success {
                        ContactController.sharedInstance.contacts.remove(at: index)
                        DispatchQueue.main.async {
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                    }
                case .failure(let error):
                    print(error, error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC",
            let indexPath = tableView.indexPathForSelectedRow,
            let destinationVC = segue.destination as? ContactDetailViewController {
            let contact = ContactController.sharedInstance.contacts[indexPath.row]
            destinationVC.contact = contact
        }
    }
}//End of class
