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
        case .unauthenticated: String(localized: "error_unauthenticated")
        case .notFound: String(localized: "error_not_found")
        case .decodingFailed: String(localized: "error_decoding_failed")
        case .firestoreError(let message): message
        case .unknown(let message): message
        }
    }
}
