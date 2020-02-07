//
//  ContactListTableViewController.swift
//  ContactsCK
//
//  Created by Maxwell Poffenbarger on 2/7/20.
//  Copyright © 2020 Maxwell Poffenbarger. All rights reserved.
//

import UIKit

class ContactListTableViewController: UITableViewController {
    
    //MARK: - Properties
    var resultsArray: [SearchableRecord] = []
    var isSearching: Bool = false
    var dataSource: [SearchableRecord] {
        return isSearching ? resultsArray : ContactController.sharedInstance.contacts
    }
    
    //MARK: - Outlets
    @IBOutlet weak var contactSearchBar: UISearchBar!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        contactSearchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resultsArray = ContactController.sharedInstance.contacts
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
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        
        guard let contact = dataSource[indexPath.row] as? Contact else {return UITableViewCell()}
        
        cell.textLabel?.text = contact.name
        
        return cell
    }
    
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

//MARK: - Extensions
extension ContactListTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if !searchText.isEmpty {
            resultsArray = ContactController.sharedInstance.contacts.filter { $0.matches(searchTerm: searchText) }
            tableView.reloadData()
        } else {
            resultsArray = ContactController.sharedInstance.contacts
            tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resultsArray = ContactController.sharedInstance.contacts
        tableView.reloadData()
        searchBar.resignFirstResponder()
        searchBar.text = ""
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.text = ""
        isSearching = false
    }
}//End of extension
