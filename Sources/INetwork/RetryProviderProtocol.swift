//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 18.07.2023.
//

public protocol RetryProviderProtocol {
    func retry(statusCode: Int, completion: @escaping (Bool) -> Void)
}
