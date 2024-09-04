//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 03.03.2023.
//

import Foundation
import Alamofire
import INetwork

open class AFDataTransferService: DataTransferService, AFDataTransferServiceProtocol {
    
    public var decoder: ResponseDecoder
    private let networkService: AFNetworkServiceProtocol
    
    public init(with networkService: AFNetworkServiceProtocol,
                decoder: ResponseDecoder
    ) {
        self.networkService = networkService
        self.decoder = decoder
    }
    
    @MainActor
    open func streamRequest<E, T>(_ endpoint: E, parser: DataParsingClosure? = nil, onData: @escaping StreamDataHandler<T>) async throws where T: Decodable, T == E.Response, E: ResponseRequestable {
        
        do {
            let streamRequest = try await networkService.streamRequest(endpoint: endpoint)
            streamRequest.responseStreamString { [weak self] stream in
                guard let self else { return }
                
                switch stream.event {
                case .stream(let result):
                    switch result {
                    case .success(let string):
                        let parsedStrings = parser?(string) ?? []
                        for parsedString in parsedStrings {
                            if let jsonData = parsedString.data(using: .utf8) {
                                do {
                                    let decodedData: T = try self.decode(data: jsonData, decoder: self.decoder)
                                    onData(.data(.success(decodedData)))
                                    
                                } catch {
                                    onData(.completed(nil))
                                }
                            }
                        }
                    case .failure(_):
                        onData(.completed(nil))
                    }
                case .complete(let completion):
                    onData(.completed(completion.error))
                }
            }
        } catch {
            onData(.completed(error))
        }
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
    
    open func upload<T>(multipartFormData: @escaping (Alamofire.MultipartFormData) -> Void,
                        to url: URL) async throws -> T where T : Decodable {
        do {
            let responseData = try await networkService.upload(multipartFormData: multipartFormData, to: url)

            let decodedData: T = try self.decode(data: responseData ?? Data(), decoder: self.decoder)
            
            return decodedData
        } catch let error {
            throw DataTransferError.resolvedNetworkFailure(error)
        }
    }
}
