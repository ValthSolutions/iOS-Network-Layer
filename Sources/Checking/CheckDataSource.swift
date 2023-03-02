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
    private var bag = Set<AnyCancellable>()
    
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
        checkUpload()
        return dataTransferService.download(endpoint)
    }
    
    func checkUpload() {
        let hell = "Hello world"
        let url = URL(string: "http://example.com/uploadText/")!
        do {
            let progress = try dataTransferService.upload(hell, to: url)
            print(progress)
        } catch let error {
            print("Error uploading data: \(error)")
        }
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
