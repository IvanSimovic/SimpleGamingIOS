import Foundation

struct FavouriteGame: Sendable, Equatable, Identifiable {
    let id: Int
    let name: String
    let imageUrl: String?
    let addedAt: Date
}
