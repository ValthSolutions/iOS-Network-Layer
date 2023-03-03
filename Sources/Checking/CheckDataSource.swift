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
            path: "https://api.themoviedb.org/3/movie/popular",
            method: .get,
            queryParameters:
                [ "language": "en",
                  "api_key": "a5ac3411803536cfb4b1cd90557dc8a7"],
            keyPath: "results")
        return dataTransferService.download(endpoint)
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

//public struct MoviePageDTO: Decodable {
//  public let page: Int
//  public let results: [Movie2DTO]
//  public let totalPages: Int
//  public let totalResults: Int
//
//  enum CodingKeys: String, CodingKey {
//    case page
//    case results = "results"
//    case totalPages = "total_pages"
//    case totalResults = "total_results"
//  }
//}

public struct Movie2DTO: Decodable {
  public let id: Int
  public let name: String
  public let overview: String
  public let posterPath: String?
  public let backDropPath: String?
  public let genreIds: [Int]?
  public let voteAverage: Double
  public let voteCount: Int

  enum CodingKeys: String, CodingKey {
    case id
    case name = "original_title"
    case overview
    case posterPath = "poster_path"
    case backDropPath = "backdrop_path"
    case genreIds = "genre_ids"
    case voteAverage = "vote_average"
    case voteCount = "vote_count"
  }
}
