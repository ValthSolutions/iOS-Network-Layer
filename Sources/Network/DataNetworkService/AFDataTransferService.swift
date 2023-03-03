//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 03.03.2023.
//

import Foundation
import Alamofire
import NetworkInterface

public final class AFDataTransferService {
    
    private let networkService: AFNetworkService
    
    public init(with networkService: AFNetworkService) {
        self.networkService = networkService
    }
    
    private func decode<T: Decodable>(data: Data, decoder: ResponseDecoder) throws -> T {
        do {
            let result: T = try decoder.decode(data)
            return result
        } catch {
            print(error)
            throw DataTransferError.parsing(error)
        }
    }
    
    private func encode<E: Encodable>(_ value: E, encoder: DataEncoder) throws -> Data {
        return try encoder.encode(value)
    }
    
    public func request<T: Decodable, E: ResponseRequestable>(_ endpoint: E) async throws -> T {
        let responseData = try await networkService.request(endpoint: endpoint)
        let decodedData: T = try decode(data: responseData, decoder: endpoint.responseDecoder)
        return decodedData
    }
    
    public func download<T: Decodable, E: ResponseRequestable>(_ endpoint: E) async throws -> T {
        let responseData = try await networkService.download(endpoint: endpoint)
        let decodedData: T = try decode(data: responseData, decoder: endpoint.responseDecoder)
        return decodedData
    }
    
    public func upload(_ value: String, url: URL) async throws -> Progress {
        let encodedData = try encode(value, encoder: JSONEncoderData())
        let progress = try await networkService.upload(encodedData, to: url)
        return progress
    }

    public func upload(multipartFormData: @escaping (MultipartFormData) -> Void,
                       to url: URL) async throws -> Progress {
        let progress = try await networkService.upload(multipartFormData: multipartFormData, to: url)
        return progress
    }
}
