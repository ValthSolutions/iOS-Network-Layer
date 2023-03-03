//
//  ViewController.swift
//  bbb
//
//  Created by LEMIN DAHOVICH on 01.03.2023.
//

import UIKit
import Network
import Checking
import Combine
import NetworkInterface

class ViewController: UIViewController {
    
    private var bag = Set<AnyCancellable>()

    deinit {
        print("ASGFSAF")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: -
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
        
        //MARK: -
        func testRequest(useCase: CheckUseCase) {
            dataSource.checkList()
                .receive(on: DispatchQueue.main)
                .sink { complition in
                    print(complition)
                } receiveValue: { check in
                    print(check)
                }.store(in: &bag)

        }
        testRequest(useCase: useCase)
        
        //MARK: -
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

