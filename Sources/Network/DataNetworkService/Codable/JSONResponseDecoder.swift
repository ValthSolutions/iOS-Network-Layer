//
//  File.swift
//
//
//  Created by LEMIN DAHOVICH on 19.01.2023.
//

import Foundation
import NetworkInterface

open class JSONResponseDecoder: ResponseDecoder {
    
    private let jsonDecoder = JSONDecoder()
    private let keyPathDecoder: KeyPathDecoder?
    
    public init(_ keyPath: String? = nil) {
        if let keyPath = keyPath {
            self.keyPathDecoder = KeyPathDecoder(keyPath)
        } else {
            self.keyPathDecoder = nil
        }
    }
    
    public func decode<T: Decodable>(_ data: Data) throws -> T {
        if let keyPathDecoder = keyPathDecoder {
            return try keyPathDecoder.decode(T.self, from: data)
        } else {
            return try jsonDecoder.decode(T.self, from: data)
        }
    }
}
