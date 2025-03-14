//
//  Cuisine.swift
//  Taste Bazaar
//
//  Created by Deepanshu Bajaj on 25/02/25.
//

import Foundation

struct Cuisine: Decodable {
    let cuisineID: String
    let cuisineName: String
    let cuisineImageURL: String
    let items: [Dish]
    
    enum CodingKeys: String, CodingKey {
        case cuisineID = "cuisine_id"
        case cuisineName = "cuisine_name"
        case cuisineImageURL = "cuisine_image_url"
        case items
    }
}
