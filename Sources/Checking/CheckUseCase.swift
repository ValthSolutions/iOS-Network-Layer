//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 01.03.2023.
//

import Combine
import NetworkInterface

public final class CheckUseCase {
    
    private let checkRepository: CheckRepository
    
    public init(checkRepository: CheckRepository) {
        self.checkRepository = checkRepository
    }
    
    public func executeDownload() -> AnyPublisher<CheckListDTO, DataTransferError> {
        return checkRepository.checkDownload()
    }
    
}
