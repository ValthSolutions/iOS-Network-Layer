//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 03.03.2023.
//

import Foundation
import Alamofire
import NetworkInterface

open class AFDataTransferService: DataTransferService, AFDataTransferServiceProtocol {
    
    public var decoder: ResponseDecoder
    private let networkService: AFNetworkServiceProtocol
    
    public init(with networkService: AFNetworkServiceProtocol,
                decoder: ResponseDecoder
    ) {
        self.networkService = networkService
        self.decoder = decoder
    }
    
    open func request<T, E>(_ endpoint: E) async throws -> T where T: Decodable, T == E.Response, E: ResponseRequestable {
        let responseData = try await networkService.request(endpoint: endpoint)
        do {
            let decodedData: T = try decode(data: responseData, decoder: decoder)
            return decodedData
        } catch let error {
            throw DataTransferError.parsing(error)
        }
    }
    
    open func download<T: Decodable, E: ResponseRequestable>(_ endpoint: E) async throws -> T {
        let responseData = try await networkService.download(endpoint: endpoint)
        do {
            let decodedData: T = try decode(data: responseData, decoder: decoder)
            return decodedData
        } catch let error {
            throw DataTransferError.parsing(error)
        }
    }
    
    open func upload(_ value: String, url: URL) async throws -> Progress {
        let encodedData = try encode(value, encoder: JSONEncoderData())
        do {
            let progress = try await networkService.upload(encodedData, to: url)
            return progress
        } catch let error {
            throw DataTransferError.resolvedNetworkFailure(error)
        }
    }
    
    open func upload(multipartFormData: @escaping (MultipartFormData) -> Void,
                     to url: URL) async throws -> Progress {
        do {
            let progress = try await networkService.upload(multipartFormData: multipartFormData, to: url)
            return progress
        } catch let error {
            throw DataTransferError.resolvedNetworkFailure(error)
        }
    }
}
