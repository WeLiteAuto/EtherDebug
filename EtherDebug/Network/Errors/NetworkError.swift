//
//  NetworkError.swift
//  TRIAL
//
//  Created by Aaron Ge on 2023/4/28.
//

import SwiftUI

enum NetworkError: Error{
    case ServerError(reason: String)
}
