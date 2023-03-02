//
//  ViewController.swift
//  bbb
//
//  Created by LEMIN DAHOVICH on 01.03.2023.
//

import UIKit
import Network
import Combine
import NetworkInterface

class ViewController: UIViewController {
    
    private var bag = Set<AnyCancellable>()

    deinit {
        print("ASGFSAF")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let session = AFSessionManager.default { token in
            token["bearer"] = "1jbdi1df"
        }
        let networkService: AFNetworkServiceCombine = {
            return AFNetworkServiceCombine(session: session)
        }()
        let service = AFDataTransferServiceCombine(with: networkService)
        
        
        let dataSource = CheckDataSource(dataTransferService: service)
        let repo = CheckRepository(remoteDataSource: dataSource)
        let useCase = CheckUseCase(checkRepository: repo)
        
        func testRequest(useCase: CheckUseCase) {
            useCase.executeRequest().receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    print(error)
                case .finished:
                    break
                }
            },
            receiveValue: { checks in
//                print(checks)
            })
            .store(in: &bag)
        }
        testRequest(useCase: useCase)
        
        func testDownload(useCase: CheckUseCase) {
            useCase.executeDownload().receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    print(error)
                case .finished:
                    break
                }
            },
            receiveValue: { checks in
                print(checks)
            })
            .store(in: &bag)
        }
        testDownload(useCase: useCase)
        
    }
    
    
}

