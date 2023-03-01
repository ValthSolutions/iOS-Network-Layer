//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 01.03.2023.
//

import Foundation
import Alamofire

open class CombineHandler {
    
    private var logger: RLog
    
    public init(_ loger: RLog) {
        self.logger = loger
    }
    
    open func handle<T>(_ publisher: DataResponsePublisher<T>, item: T) {
        logger.log(publisher)
    }
    
    open func responseSuccess<T>(_ publisher: DataResponsePublisher<T>, item: T) -> Result<T, Error> {
        .success(item)
    }
    
    open func responseError<T>(_ publisher: DataResponsePublisher<T>, error: Error) -> Result<T, Error> {
        .failure(error)
    }
}
//p { value -> Result<T, Error> in
//    self.responseSuccess(publisher, item: item)
//}
//.mapError { error -> Result<T, Error> in
//    self.responseError(publisher, error: error)
//}
//.sink(receiveCompletion: { _ in }, receiveValue: { _ in })
//.store(in: &logger.bag)
