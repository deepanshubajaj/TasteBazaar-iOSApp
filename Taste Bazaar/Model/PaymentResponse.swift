//
//  PaymentResponse.swift
//  Taste Bazaar
//
//  Created by Deepanshu Bajaj on 13/03/25.
//

import Foundation

struct PaymentResponse: Decodable {
    let responseCode: Int
    let outcomeCode: Int
    let responseMessage: String
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case outcomeCode = "outcome_code"
        case responseMessage = "response_message"
    }
}
