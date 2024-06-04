//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 18.07.2023.
//

import Alamofire

open class AFReachableNetworkService {
    let reachabilityManager = NetworkReachabilityManager()
    
    public init() { }
    
    public func isInternetAvailable() -> Bool {
        return ((reachabilityManager?.isReachable) != nil)
    }
}
