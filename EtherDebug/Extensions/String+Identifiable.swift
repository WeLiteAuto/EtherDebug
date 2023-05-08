//
//  String+Identifiable.swift
//  TRIAL
//
//  Created by Aaron Ge on 2023/5/4.
//

import SwiftUI

extension String : Identifiable{
    public var id: Int {
        self.hashValue
    }
}
