import Foundation

struct User: Codable, Equatable, Identifiable {
    let id: UUID
    let email: String
    let name: String
}