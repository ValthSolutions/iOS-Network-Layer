//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 03.03.2023.
//

import Foundation

public struct CheckListDTO: Decodable {
    public let genres: [CheckDTO]
}


public struct CheckDTO: Decodable {
    public let id: Int
    public let name: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}

public struct Movie2DTO: Decodable {
    public let id: Int
    public let name: String
    public let overview: String
    public let posterPath: String?
    public let backDropPath: String?
    public let genreIds: [Int]?
    public let voteAverage: Double
    public let voteCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "original_title"
        case overview
        case posterPath = "poster_path"
        case backDropPath = "backdrop_path"
        case genreIds = "genre_ids"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}
