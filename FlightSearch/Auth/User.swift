import Foundation

struct User: Codable, Equatable {
    let id: UUID
    let email: String
    let name: String
}
