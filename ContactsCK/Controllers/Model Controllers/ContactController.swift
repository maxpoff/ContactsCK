//
//  ContactController.swift
//  ContactsCK
//
//  Created by Maxwell Poffenbarger on 2/7/20.
//  Copyright © 2020 Maxwell Poffenbarger. All rights reserved.
//

import CloudKit

class ContactController {
    
    //MARK: - Properties
    static let sharedInstance = ContactController()
    var contacts: [Contact] = []
    let privateDB = CKContainer.default().privateCloudDatabase
    
    //MARK: - CloudKit Methods
    func createContact(name: String, phoneNumber: String, emailAddress: String, completion: @escaping (Result<Contact, ContactError>) -> Void) {
        
        let contact = Contact(name: name, phoneNumber: phoneNumber, emailAddress: emailAddress)
        
        let record = CKRecord(contact: contact)
        
        privateDB.save(record) { (record, error) in
            
            if let error = error {
                print(error, error.localizedDescription)
                return completion(.failure(.thrownError(error)))
            }
            
            guard let record = record else {return completion(.failure(.noData))}
            
            guard let contact = Contact(ckRecord: record) else {return completion(.failure(.unableToDecode))}
            
            self.contacts.append(contact)
            completion(.success(contact))
        }
    }
    
    func fetchAllContacts(completion: @escaping (Result<[Contact], ContactError>) -> Void) {
        
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: Constants.contactRecordTypeKey, predicate: predicate)
        
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            
            if let error = error {
                print(error, error.localizedDescription)
                return completion(.failure(.thrownError(error)))
            }
            
            guard let records = records else {return completion(.failure(.noData))}
            
            let contacts = records.compactMap(Contact.init(ckRecord:))
            
            self.contacts = contacts
            completion(.success(contacts))
        }
    }
    
    func update(contact: Contact, name: String, phoneNumber: String, emailAddress: String, completion: @escaping (Result<Contact, ContactError>) -> Void) {
        
        contact.name = name
        contact.phoneNumber = phoneNumber
        contact.emailAddress = emailAddress
        
        let record = CKRecord(contact: contact)
        
        let updateOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        updateOperation.savePolicy = .changedKeys
        updateOperation.modifyRecordsCompletionBlock = { records, _, error in
            
            if let error = error {
                print(error, error.localizedDescription)
                return completion(.failure(.thrownError(error)))
            }
            
            guard let record = records?.first else {return completion(.failure(.noData))}
            
            guard let contact = Contact(ckRecord: record) else {return completion(.failure(.unableToDecode))}
            
            completion(.success(contact))
        }
        privateDB.add(updateOperation)
    }
    
    func delete(contact: Contact, completion: @escaping (Result<Bool, ContactError>) -> Void) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [contact.ckRecordID])
        
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { records, _, error in
            
            if let error = error {
                print(error, error.localizedDescription)
                return completion(.failure(.thrownError(error)))
            }
            
            if records?.count == 0 {
                completion(.success(true))
            } else {
                return completion(.failure(.unexpectedRecordsFound))
            }
        }
        privateDB.add(operation)
    }
}//End of class
