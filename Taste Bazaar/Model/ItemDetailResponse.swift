//
//  ItemDetailResponse.swift
//  Taste Bazaar
//
//  Created by Deepanshu Bajaj on 26/02/25.
//

import Foundation

struct ItemDetailResponse: Codable {
    let responseCode: Int
    let outcomeCode: Int
    let responseMessage: String
    let cuisineId: String
    let cuisineName: String
    let cuisineImageURL: String
    let itemId: Int
    let itemName: String
    let itemPrice: Double
    let itemRating: Double
    let itemImageURL: String
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case outcomeCode = "outcome_code"
        case responseMessage = "response_message"
        case cuisineId = "cuisine_id"
        case cuisineName = "cuisine_name"
        case cuisineImageURL = "cuisine_image_url"
        case itemId = "item_id"
        case itemName = "item_name"
        case itemPrice = "item_price"
        case itemRating = "item_rating"
        case itemImageURL = "item_image_url"
    }
}


