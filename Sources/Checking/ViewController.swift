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

class ViewController: UIViewController {
    
    let configuration: APIConfiguration = {
        let config = APIConfiguration(baseURL: URL(string: "https://api.themoviedb.org/")!,
                                      queryParameters: ["api_key": "a5ac3411803536cfb4b1cd90557dc8a7"])
        return config
    }()
    
    let session = AFSessionManager.default
    private var bag = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let networkService = AFNetworkServiceCombine(session: session,
                                                     configuration: configuration)
        let dataService = AFDataTransferServiceCombine(with: networkService)
        let dataSource = CheckDataSource(dataTransferService: dataService)
        
        checkCombine(dataSource: dataSource)
    }
    
    func checkCombine(dataSource: CheckDataSource) {
        dataSource.checkKeyPaths()
            .receive(on: DispatchQueue.main)
            .sink { complition in
                print(complition)
            } receiveValue: { check in
//                print(check)
            }.store(in: &bag)
        
        dataSource.checkList()
            .receive(on: DispatchQueue.main)
            .sink { complition in
                print(complition)
            } receiveValue: { check in
               // print(check)
            }.store(in: &bag)
        
        dataSource.checkDownload()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    print(error)
                case .finished:
                    break
                }
            },receiveValue: { _ in  })
            .store(in: &bag)
        
        dataSource.checkUpload()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    print(error)
                case .finished:
                    break
                }
                
            }) { result in
                print(result)
            }.store(in: &bag)
        
        dataSource.checkUploadMulti(multipartFormData: { multi in
            let data = "Hello, world!".data(using: .utf8)!
            multi.append(data, withName: "check")
        })
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { error in
            print(error)
            
        }) { result in
            print(result)
        }.store(in: &bag)
    }
    
    deinit {
        print("ASGFSAF")
    }
}

