//
//  FilteredDish.swift
//  Taste Bazaar
//
//  Created by Deepanshu Bajaj on 12/03/25.
//

import Foundation

struct FilteredDish: Decodable {
    let id: Int
    var name: String
    var image_url: String
    var price: String?
    var quantity: Int?
    var rating: String?
}
