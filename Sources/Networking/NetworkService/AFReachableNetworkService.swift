//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 18.07.2023.
//

import Alamofire

open class AFReachableNetworkService {
    let reachabilityManager = NetworkReachabilityManager()

    func isInternetAvailable() -> Bool {
        guard let isReachable = reachabilityManager?.isReachable else {
            return false
        }
        return isReachable
    }
}
