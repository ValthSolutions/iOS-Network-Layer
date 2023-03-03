//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 28.02.2023.
//

import UIKit
import Combine
import Network
import NetworkInterface
import Alamofire

public final class CheckDataSource {
    
    private let dataTransferService: AFDataTransferServiceCombine
    private var bag = Set<AnyCancellable>()
    
    public init(dataTransferService: AFDataTransferServiceCombine) {
        self.dataTransferService = dataTransferService
    }
    //MARK: - Check reactive approach
    public func checkList() -> AnyPublisher<CheckListDTO, DataTransferError> {
        let endpoint = Endpoint<CheckListDTO>(
            path: "3/genre/movie/list",
            method: .get, queryParameters: ["language": "en"])
        return dataTransferService.request(endpoint)
    }
    
    public func checkDownload() -> AnyPublisher<CheckListDTO, DataTransferError> {
        let endpoint = Endpoint<CheckListDTO>(
            path: "3/genre/movie/list",
            method: .get,
            queryParameters: [ "language": "en"])
        return dataTransferService.download(endpoint)
    }
    
    public func checkUpload() -> AnyPublisher<Progress, Error> {
        let hell = "Hello world"
        let url = URL(string: "https://google.com")!
        return dataTransferService.upload(hell, url: url)
    }
    
    public func checkUploadMulti(multipartFormData: @escaping (MultipartFormData) -> Void) -> AnyPublisher<Progress, Error> {
        let url = URL(string: "https://google.com")!
        return dataTransferService.upload(multipartFormData: multipartFormData, to: url)
    }
    
    //MARK: - KeyPaths
    public func checkKeyPaths() -> AnyPublisher<[Movie2DTO], DataTransferError> {
        let endpoint = Endpoint<[Movie2DTO]>(
            path: "3/movie/popular",
            method: .get,
            queryParameters: ["language": "en"],
            keyPath: "results")
        return dataTransferService.download(endpoint)
    }

}
