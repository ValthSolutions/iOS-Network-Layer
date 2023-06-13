//
//  File.swift
//
//
//  Created by LEMIN DAHOVICH on 28.02.2023.
//

import Foundation

public class KeyPathDecoder: JSONDecoder {
    
    private let keyPath: String?
    
    public init(_ keyPath: String?) {
        self.keyPath = keyPath
        super.init()
    }
    
    public override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        if let keyPath = keyPath {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            if let nestedJson = (jsonObject as AnyObject).value(forKeyPath: keyPath) {
                let nestedJsonData = try JSONSerialization.data(withJSONObject: nestedJson)
                return try super.decode(type, from: nestedJsonData)
            } else {
                throw DecodingError.dataCorrupted(.init(codingPath: [],
                                                        debugDescription: "Nested JSON not found for key path \"\(keyPath)\""))
            }
        } else {
            return try super.decode(type, from: data)
        }
    }
}
