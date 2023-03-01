import Alamofire
import Foundation
import Combine

open class BaseHandler {
    
    private let loger: Log
    
    public init(_ loger: Log) {
        self.loger = loger
    }
    
    open func handle<T>(_ response: AFDataResponse<T>) -> Result<T, Error> {
        loger.log(response)
        
        switch response.result {
        case .success(let value):
            loger.success(value)
            return responseSuccess(response, item: value)
            
        case .failure(let error):
            loger.failure(error)
            return responseError(response, error: error)
        }
    }
    
    open func responseSuccess<T>(_ response: AFDataResponse<T>, item: T) -> Result<T, Error> {
        .success(item)
    }
    
    open func responseError<T>(_ response: AFDataResponse<T>, error: Error) -> Result<T, Error> {
        .failure(error)
    }
}

import Alamofire
import Combine

open class CombineHandler {
    
    private let loger: RLog
    
    public init(_ loger: RLog) {
        self.loger = loger
    }
    
    open func handle<T>(_ response: DataResponsePublisher<T>) -> Result<T, Error> {
        loger.log(response)

    }
    
    open func responseSuccess<T>(_ response: DataResponsePublisher<T>, item: T) -> Result<T, Error> {
        .success(item)
    }
    
    open func responseError<T>(_ response: DataResponsePublisher<T>, error: Error) -> Result<T, Error> {
        .failure(error)
    }
}
