//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 03.03.2023.
//

import Foundation
import NetworkInterface

open class DataTransferService {
    
    func decode<T: Decodable>(data: Data, decoder: ResponseDecoder) throws -> T {
        do {
            let result: T = try decoder.decode(data)
            return result
        } catch {
            print(error)
            throw DataTransferError.parsing(error)
        }
    }
    
    func encode<E: Encodable>(_ value: E, encoder: DataEncoder) throws -> Data {
        return try encoder.encode(value)
    }
}
