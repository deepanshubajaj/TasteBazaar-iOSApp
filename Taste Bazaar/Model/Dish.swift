//
//  Dish.swift
//  Taste Bazaar
//
//  Created by Deepanshu Bajaj on 17/02/25.
//

import Foundation

struct Dish: Decodable {
    let id: String
    var name: String
    var image_url: String
    var price: String
    var quantity: Int?
    var rating: String
}


