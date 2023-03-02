//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 02.03.2023.
//

import Foundation

class ProgressWrapper: Decodable {
    let fractionCompleted: Double
    
    init(fractionCompleted: Double) {
        self.fractionCompleted = fractionCompleted
    }
    
    enum CodingKeys: String, CodingKey {
        case fractionCompleted = "fraction_completed"
    }
}
