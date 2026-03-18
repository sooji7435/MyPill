//
//  UserViewModel.swift
//  PillManager
//
//  Created by 박윤수 on 8/4/25.
//

import Foundation


struct User: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}
