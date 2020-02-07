//
//  ContactDetailViewController.swift
//  ContactsCK
//
//  Created by Maxwell Poffenbarger on 2/7/20.
//  Copyright © 2020 Maxwell Poffenbarger. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var contactNameTextField: UITextField!
    @IBOutlet weak var contactPhoneNumberTextField: UITextField!
    @IBOutlet weak var contactEmailAddressTextField: UITextField!
    
    //MARK: - Properties
    var contact: Contact?

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    //MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        guard let name = contactNameTextField.text, !name.isEmpty,
            let phoneNumber = contactPhoneNumberTextField.text, !phoneNumber.isEmpty,
            let emailAddress = contactEmailAddressTextField.text, !emailAddress.isEmpty else {return}
        
        if let contact = contact {
            ContactController.sharedInstance.update(contact: contact, name: name, phoneNumber: phoneNumber, emailAddress: emailAddress) { (result) in
                self.switchOnResult(result)
            }
        } else {
            ContactController.sharedInstance.createContact(name: name, phoneNumber: phoneNumber, emailAddress: emailAddress) { (result) in
                self.switchOnResult(result)
            }
        }
    }
    
    //MARK: - Class Methods
    func updateUI() {
        contactNameTextField.text = contact?.name
        contactPhoneNumberTextField.text = contact?.phoneNumber
        contactEmailAddressTextField.text = contact?.emailAddress
    }
    
    func switchOnResult(_ result: Result<Contact, ContactError>) {
        DispatchQueue.main.async {
            switch result {
            case .success(_):
                self.navigationController?.popViewController(animated: true)
                
            case .failure(let error):
                self.presentErrorToUser(localizedError: error)
            }
        }
    }
}//End of class
