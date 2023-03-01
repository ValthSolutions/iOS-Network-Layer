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
    
    init(dataTransferService: AFDataTransferServiceCombine) {
        self.dataTransferService = dataTransferService
    }

    func checkList() -> AnyPublisher<CheckListDTO, DataTransferError> {
      let endpoint = Endpoint<CheckListDTO>(
        path: "3/genre/movie/list",
        method: .get
      )
      return dataTransferService.request(endpoint)
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
