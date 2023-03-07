//
//  ViewController.swift
//  bbb
//
//  Created by LEMIN DAHOVICH on 01.03.2023.
//

import UIKit
import iOS_Demo
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
        let networkServiceCombine = AFNetworkServiceCombine(session: session,
                                                            configuration: configuration)
        let dataServiceCombine = AFDataTransferServiceCombine(with: networkServiceCombine)
        let dataSourceCombine = CheckCombineDataSource(dataTransferService: dataServiceCombine)
        
        let networkServiceAsync = AFNetworkService(session: session,
                                                   configuration: configuration)
        let dataServiceAsync = AFDataTransferService(with: networkServiceAsync)
        let dataSourceAsync = CheckAsyncDataSource(dataTransferService: dataServiceAsync)
        
        checkCombine(dataSourceCombine: dataSourceCombine)
        checkAsync(dataSourceAsync: dataSourceAsync)
    }
    
    deinit {
        print("ASGFSAF")
    }
}

extension ViewController{
    
    func checkAsync(dataSourceAsync: CheckAsyncDataSource) {
        Task {
            do {
                let checkList = try await dataSourceAsync.checkList()
                print(checkList)
            } catch {
                print(error)
            }
        }
        Task {
            do {
                let movies = try await dataSourceAsync.checkKeyPaths()
                print(movies)
            } catch {
                print(error)
            }
        }
        Task {
            do {
                let progress = try await dataSourceAsync.checkUpload()
                print(progress)
            } catch {
                print(error)
            }
        }
        Task {
            do {
                let result = try await dataSourceAsync.checkUploadMulti { multi in
                    let data = "Hello, world!".data(using: .utf8)!
                    multi.append(data, withName: "check")
                }
                print(result)
            } catch {
                print(error)
            }
        }
        Task {
            do {
                let downloadResult = try await dataSourceAsync.checkDownload()
                print(downloadResult)
            } catch {
                print(error)
            }
        }
    }
    
    func checkCombine(dataSourceCombine: CheckCombineDataSource) {
        dataSourceCombine.checkKeyPaths()
            .receive(on: DispatchQueue.main)
            .sink { complition in
                print(complition)
            } receiveValue: { check in
                print(check)
            }.store(in: &bag)
        
        dataSourceCombine.checkList()
            .receive(on: DispatchQueue.main)
            .sink { complition in
                print(complition)
            } receiveValue: { check in
                print(check)
            }.store(in: &bag)
        
        dataSourceCombine.checkDownload()
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
        
        dataSourceCombine.checkUpload()
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
        
        dataSourceCombine.checkUploadMulti(multipartFormData: { multi in
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
}

