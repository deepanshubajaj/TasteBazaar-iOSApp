//
//  CuisineResponse.swift
//  Taste Bazaar
//
//  Created by Deepanshu Bajaj on 25/02/25.
//

import Foundation

struct CuisineResponse: Decodable {
    let responseCode: Int
    let outcomeCode: Int
    let responseMessage: String
    let page: Int
    let count: Int
    let totalPages: Int
    let totalItems: Int
    let cuisines: [Cuisine]
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case outcomeCode = "outcome_code"
        case responseMessage = "response_message"
        case page
        case count
        case totalPages = "total_pages"
        case totalItems = "total_items"
        case cuisines
    }
}
