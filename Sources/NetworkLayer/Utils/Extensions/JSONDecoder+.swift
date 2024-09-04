import Foundation
import INetwork

extension JSONDecoder: ResponseDecoder {
    public func decode<T: Decodable>(_ data: Data) throws -> T {
        return try decode(T.self, from: data)
    }
}
