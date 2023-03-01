//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 28.02.2023.
//

import UIKit
import Combine
import Network

public final class Check: UIViewController {
    
    private let dataTransferService: AFDataTransferServiceCombine
    private var cancellables = Set<AnyCancellable>()
    
    init(dataTransferService: AFDataTransferServiceCombine) {
        self.dataTransferService = dataTransferService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        print("ASFAS")
    }
    
}

public class DIStorage {
    var config = ApiDataNetworkConfig(baseURL: URL(string: "https://google.com/")!)
    
    var session = AFSessionManager()
    
    public init() {}
    
    lazy var networkService: AFNetworkServiceCombine = {
        return AFNetworkServiceCombine(config: config, session: session)
    }()
    
    lazy var service = AFDataTransferServiceCombine(with: networkService)
    
    
    public func buildCheck(){

        print(Check(dataTransferService: service).viewDidLoad())
    }
    
}
