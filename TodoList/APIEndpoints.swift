//
//  APIEndpoints.swift
//  TodoList
//
//  Created by Alex Paterson on 6/06/2016.
//  Copyright © 2016 Alexander Paterson. All rights reserved.
//

import Foundation

class APIEndpoints {
    private static let baseURL = "http://xxx/v1"
    static let signupURL = "\(baseURL)/signup"
    static let signinURL = "\(baseURL)/signin"
    
    static func todosURL (userId: String) -> String {
        return "\(baseURL)/users/\(userId)/todos"
    }
    static func todoURL (userId: String, todoId: String) -> String {
        return "\(baseURL)/users/\(userId)/todos/\(todoId)"
    }
}