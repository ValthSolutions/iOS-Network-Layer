import Foundation

extension Encodable {
    func toDictionary(encoder: JSONEncoder) throws -> [String: Any]? {
        let data = try encoder.encode(self)
        let josnData = try JSONSerialization.jsonObject(with: data)
        return josnData as? [String: Any]
    }
}
