//
//  Contact.swift
//  ContactsCK
//
//  Created by Maxwell Poffenbarger on 2/7/20.
//  Copyright © 2020 Maxwell Poffenbarger. All rights reserved.
//

import CloudKit

struct Constants {
    fileprivate static let nameKey = "name"
    fileprivate static let phoneNumberKey = "phoneNumber"
    fileprivate static let emailAddressKey = "emailAddress"
    static let contactRecordTypeKey = "Contact"
}

class Contact {
    var name: String
    var phoneNumber: String?
    var emailAddress: String?
    var ckRecordID: CKRecord.ID
    
    init(name:String, phoneNumber: String?, emailAddress: String?, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.emailAddress = emailAddress
        self.ckRecordID = ckRecordID
    }
}//End of class

extension Contact {
    
    convenience init?(ckRecord: CKRecord) {
        guard let name = ckRecord[Constants.nameKey] as? String else {return nil}
        
        let phoneNumber = ckRecord[Constants.phoneNumberKey] as? String
        
        let emailAddress = ckRecord[Constants.emailAddressKey] as? String
        
        self.init(name: name, phoneNumber: phoneNumber, emailAddress: emailAddress, ckRecordID: ckRecord.recordID)
    }
}//End of extension

extension CKRecord {
    
    convenience init(contact: Contact) {
        self.init(recordType: Constants.contactRecordTypeKey, recordID: contact.ckRecordID)
        
        setValuesForKeys([Constants.nameKey : contact.name])
        
        if let phoneNumber = contact.phoneNumber {
            self.setValue(phoneNumber, forKey: Constants.phoneNumberKey)
        }
        
        if let emailAddress = contact.emailAddress {
            self.setValue(emailAddress, forKey: Constants.emailAddressKey)
        }
    }
}//End of extension

extension Contact: Equatable {
    
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        lhs.ckRecordID == rhs.ckRecordID
    }
}//End of extension

extension Contact: SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        if name.lowercased().contains(searchTerm.lowercased()) {
            return true
        }
        return false
    }
}//End of extension
