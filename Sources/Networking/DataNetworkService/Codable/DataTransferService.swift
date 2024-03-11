//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 03.03.2023.
//

import Foundation
import OSLog
import NetworkInterface

open class DataTransferService {
    func decode<T: Decodable>(data: Data, decoder: ResponseDecoder) throws -> T {
        do {
            let result: T = try decoder.decode(data)
            return result
        } catch {
            let typeName = String(describing: T.self)
            let dataSnippet = String(data: data.prefix(100), encoding: .utf8) ?? "Data not representable in UTF-8"
            os_log("Failed to decode type: %@, \nError: %@, \nData snippet: %@", typeName, error.localizedDescription, dataSnippet)
            throw DataTransferError.parsing(error)
        }
    }
    
    func encode<E: Encodable>(_ value: E, encoder: DataEncoder) throws -> Data {
        return try encoder.encode(value)
    }
}
