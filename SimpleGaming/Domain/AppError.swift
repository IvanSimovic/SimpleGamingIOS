import Foundation

enum AppError: Error, Sendable, Equatable {
    case networkError(statusCode: Int?, message: String)
    case authFailed(String)
    case unauthenticated
    case notFound
    case decodingFailed
    case firestoreError(String)
    case unknown(String)
}

extension AppError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .networkError(_, let message): message
        case .authFailed(let message): message
        case .unauthenticated: "You are not signed in."
        case .notFound: "The requested resource was not found."
        case .decodingFailed: "The response could not be read."
        case .firestoreError(let message): message
        case .unknown(let message): message
        }
    }
}
