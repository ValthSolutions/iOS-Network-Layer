import Foundation

public enum RepositoryError: LocalizedError {
    
    case notFound
    case notUpdate
    case notSave
    case notDelete
    case notExists
    case unknown
    
    case error(Error)
    case message(String)

    case serialize

    case invalidStringURL(string: String)
    case invalidURL(url: URL)
    case jsonEncodingFailed(error: Error)
}

public protocol Repository {

}
