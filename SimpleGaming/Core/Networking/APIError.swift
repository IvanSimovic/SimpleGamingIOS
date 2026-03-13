// Network-level error. Lives in Core — never exposed above the Data layer.
// Maps to AppError at the repository boundary.
enum APIError: Error, Sendable {
    case invalidURL
    case requestFailed(statusCode: Int, message: String?)
    case decodingFailed(String)
    case noData
    case unknown(String)
}
