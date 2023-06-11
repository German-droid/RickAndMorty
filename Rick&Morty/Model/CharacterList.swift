//
//  CharacterList.swift
//  Rick&Morty
//
//  Created by German Fuentes Ripoll on 11/6/23.
//

import Foundation

struct CharacterList: Codable {
    let info: ListInfo
    let results: [Character]
}

struct ListInfo: Codable {
    let next: String?
}
