//
//  ViewController.swift
//  bbb
//
//  Created by LEMIN DAHOVICH on 01.03.2023.
//

import UIKit
import Checking
import Network
import Combine
import NetworkInterface

private var bag = Set<AnyCancellable>()


class ViewController: UIViewController {

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
        
        func testKeypath() {
            dataSource.checkKeyPaths()
                .receive(on: DispatchQueue.main)
                .sink { complition in
                    print(complition)
                } receiveValue: { check in
                    print(check)
                }.store(in: &bag)

        }
        testKeypath()
        
        func testRequest() {
            dataSource.checkList()
                .receive(on: DispatchQueue.main)
                .sink { complition in
                    print(complition)
                } receiveValue: { check in
                    print(check)
                }.store(in: &bag)

        }
        testRequest()
        
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

            })
            .store(in: &bag)
        }
        
        testDownload(useCase: useCase)
        dataSource.checkUpload()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }) { result in
                print(result)
            }
    }

}

