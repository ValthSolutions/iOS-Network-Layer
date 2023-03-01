//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 01.03.2023.
//

import Combine
import NetworkInterface

final class CheckUseCase {

  private let checkRepository: CheckRepository

  init(checkRepository: CheckRepository) {
    self.checkRepository = checkRepository
  }

  func execute() -> AnyPublisher<CheckListDTO, DataTransferError> {
    return checkRepository.checkList()
  }
}
