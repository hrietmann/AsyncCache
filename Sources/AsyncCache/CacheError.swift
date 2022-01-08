//
//  CacheError.swift
//  CacheKit
//
//  Created by Hans Rietmann on 02/12/2021.
//

import Foundation




struct CacheError: LocalizedError {
    
    let message: String
    var errorDescription: String? { message }
    
}
