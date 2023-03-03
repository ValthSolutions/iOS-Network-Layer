//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 03.03.2023.
//

import Foundation
import Combine
import Network
import NetworkInterface
import Alamofire

public final class CheckAsyncDataSource {
    
    private let dataTransferService: AFDataTransferService
    private let jsonDecoder = JSONDecoder()
    
    public init(dataTransferService: AFDataTransferService) {
        self.dataTransferService = dataTransferService
    }
    
    public func checkList() async throws -> CheckListDTO {
        let endpoint = Endpoint<CheckListDTO>(
            path: "3/genre/movie/list",
            method: .get, queryParameters: ["language": "en"])
        return try await dataTransferService.request(endpoint)
    }
    
    public func checkDownload() async throws -> CheckListDTO {
        let endpoint = Endpoint<CheckListDTO>(
            path: "3/genre/movie/list",
            method: .get,
            queryParameters: [ "language": "en"])
        return try await dataTransferService.download(endpoint)
    }
    
    public func checkUpload() async throws -> Progress {
        let hell = "Hello world"
        let url = URL(string: "https://google.com")!
        return try await dataTransferService.upload(hell, url: url)
    }
    
    public func checkUploadMulti(multipartFormData: @escaping (MultipartFormData) -> Void) async throws -> Progress {
        let url = URL(string: "https://google.com")!
        return try await dataTransferService.upload(multipartFormData: multipartFormData, to: url)
    }
    
    public func checkKeyPaths() async throws -> [Movie2DTO] {
        let endpoint = Endpoint<[Movie2DTO]>(
            path: "3/movie/popular",
            method: .get,
            queryParameters: ["language": "en"],
            keyPath: "results")
        let response = try await dataTransferService.request(endpoint)
        return response
    }
}
