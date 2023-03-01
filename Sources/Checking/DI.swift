//
//  File.swift
//
//
//  Created by LEMIN DAHOVICH on 01.03.2023.
//

import Foundation
import Network
import NetworkInterface
import UIKit

public class DIStorage {
    var config = ApiDataNetworkConfig(baseURL: URL(string: "https://google.com/")!)
    
    var session = AFSessionManager()
    
    public init() {}
    
    lazy var networkService: AFNetworkServiceCombine = {
        return AFNetworkServiceCombine(config: config, session: session)
    }()
    
    lazy var service = AFDataTransferServiceCombine(with: networkService)
    
    
    public func buildCheck() {
        let dataSource = CheckDataSource(dataTransferService: service)
        let repo = CheckRepository(remoteDataSource: dataSource)
        let useCase = CheckUseCase(checkRepository: repo)
        ViewController(useCase: useCase).test(useCase: useCase)
    }
}
