//
//  Character.swift
//  Rick&Morty
//
//  Created by German Fuentes Ripoll on 10/6/23.
//

import Foundation

struct Character: Codable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let origin: Origin
    let location: Location
    let image: String
    let episode: [String]
    var imageData: Data?
}

struct Origin: Codable {
    let name: String
}

struct Location: Codable {
    let name: String
}
