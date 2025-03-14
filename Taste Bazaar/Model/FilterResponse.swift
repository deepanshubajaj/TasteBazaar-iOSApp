//
//  FilterResponse.swift
//  Taste Bazaar
//
//  Created by Deepanshu Bajaj on 12/03/25.
//

import Foundation

struct FilterResponse: Decodable {
    let responseCode: Int
    let outcomeCode: Int
    let responseMessage: String
    let cuisines: [FilteredCuisine]
    let timestamp: String
    let requesterIP: String
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case outcomeCode = "outcome_code"
        case responseMessage = "response_message"
        case cuisines
        case timestamp
        case requesterIP = "requester_ip"
    }
}
