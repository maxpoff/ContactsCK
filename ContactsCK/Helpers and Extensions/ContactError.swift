//
//  ContactError.swift
//  ContactsCK
//
//  Created by Maxwell Poffenbarger on 2/7/20.
//  Copyright © 2020 Maxwell Poffenbarger. All rights reserved.
//

import Foundation

enum ContactError: LocalizedError {
    case thrownError(Error)
    case noData
    case unableToDecode
    case unexpectedRecordsFound
}
