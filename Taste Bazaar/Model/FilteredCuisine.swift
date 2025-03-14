//
//  FilteredCuisine.swift
//  Taste Bazaar
//
//  Created by Deepanshu Bajaj on 12/03/25.
//

import Foundation

struct FilteredCuisine: Decodable {
    let cuisineID: Int  
    let cuisineName: String
    let cuisineImageURL: String
    let items: [FilteredDish]
    
    enum CodingKeys: String, CodingKey {
        case cuisineID = "cuisine_id"
        case cuisineName = "cuisine_name"
        case cuisineImageURL = "cuisine_image_url"
        case items
    }
}
