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
    
    public static let shared = DIStorage()
    
    var session = AFSessionManager()
    
    public init() {}
    
    lazy var networkService: AFNetworkServiceCombine = {
        return AFNetworkServiceCombine(session: session)
    }()
    
    lazy var service = AFDataTransferServiceCombine(with: networkService)
    
    deinit {
        print("DEINIT")
    }
    
    public func buildCheck() -> UIViewController{
        let dataSource = CheckDataSource(dataTransferService: service)
        let repo = CheckRepository(remoteDataSource: dataSource)
        let useCase = CheckUseCase(checkRepository: repo)
        var vc = ViewController(useCase: useCase)
        return vc
    }
}
