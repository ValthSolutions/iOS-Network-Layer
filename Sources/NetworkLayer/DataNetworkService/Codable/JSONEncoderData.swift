//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 02.03.2023.
//

import Foundation
import INetwork


open class JSONEncoderData: DataEncoder {
    
    private let jsonEncoder = JSONEncoder()
    
    public init() { }
    
    public func encode<T: Encodable>(_ data: T) throws -> Data {
        return try jsonEncoder.encode(data)
    }
}
