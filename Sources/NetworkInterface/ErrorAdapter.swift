//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 22.05.2023.
//

import Foundation

public protocol IErrorAdapter {
    func adapt(_ error: Error) -> Error
}
