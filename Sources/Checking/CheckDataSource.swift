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

public final class CheckDataSource {
    
    private let dataTransferService: AFDataTransferServiceCombine
    
    public init(dataTransferService: AFDataTransferServiceCombine) {
        self.dataTransferService = dataTransferService
    }

    func checkList() -> AnyPublisher<CheckListDTO, DataTransferError> {
        let endpoint = Endpoint<CheckListDTO>(
            path: "https://api.themoviedb.org/3/genre/movie/list",
            method: .get, queryParameters:
                [ "language": "en",
                  "api_key": "a5ac3411803536cfb4b1cd90557dc8a7"])
      return dataTransferService.request(endpoint)
    }
    func checkDownload() -> AnyPublisher<CheckListDTO, DataTransferError> {
        let endpoint = Endpoint<CheckListDTO>(
            path: "https://api.themoviedb.org/3/genre/movie/list",
            method: .get, queryParameters:
                [ "language": "en",
                  "api_key": "a5ac3411803536cfb4b1cd90557dc8a7"])
      return dataTransferService.download(endpoint)
    }
    func checkUpload() -> AnyPublisher<String, DataTransferError> {

        return dataTransferService.upload(<#T##value: Encodable##Encodable#>, to: <#T##URL#>)
    }
}


public struct CheckListDTO: Decodable {
  public let genres: [CheckDTO]
}


public struct CheckDTO: Decodable {
  public let id: Int
  public let name: String

  enum CodingKeys: String, CodingKey {
    case id
    case name
  }
}
