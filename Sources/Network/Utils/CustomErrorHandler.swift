//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 28.02.2023.
//

import Foundation
import Alamofire

enum ParentViewError: Error, LocalizedError {
    case serverError(message: String)
    
    var errorDescription: String? {
        switch self {
        case .serverError(let message):
            return message
        }
    }
}

public final class CustomErrorHandler: BaseHandler {
    
    private enum Constants {
        static let resultKey = "result"
        static let errorValue = "error"
        static let messageKey = "message"
    }

    public override func responseSuccess<T>(_ response: AFDataResponse<T>, item: T) -> Result<T, Error> {
        if  let data = response.data,
            let json = try? JSONSerialization.jsonObject(with: data,
                                                        options: .mutableContainers) as? [String: Any] {
            if let result = json[Constants.resultKey] as? String,
               let message = json[Constants.messageKey] as? String,
               result == Constants.errorValue {
                
                return .failure(ParentViewError.serverError(message: message))
            }
        }
        
        return .success(item)
    }
    
    public override func responseError<T>(_ response: AFDataResponse<T>, error: Error) -> Result<T, Error> {
        if  let data = response.data,
            let json = try? JSONSerialization.jsonObject(with: data,
                                                        options: .mutableContainers) as? [String: Any] {
            if let result = json[Constants.resultKey] as? String,
               let message = json[Constants.messageKey] as? String,
               result == Constants.errorValue {
                
                return .failure(ParentViewError.serverError(message: message))
            }
        }
        
        return .failure(error)
    }
}
