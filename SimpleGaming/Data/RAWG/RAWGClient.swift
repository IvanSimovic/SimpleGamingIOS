@preconcurrency import Alamofire
import Foundation

struct RAWGClient: Sendable {
    private let baseURL = "https://api.rawg.io/api"
    private let session: Session

    init(session: Session = NetworkClient.shared.session) {
        self.session = session
    }

    func searchGames(query: String) async throws -> [Game] {
        let data = try await fetchData("\(baseURL)/games", parameters: ["search": query, "page_size": 20])
        let response = try decodeOrThrow(data, as: RAWGGameListResponse.self)
        return RAWGMappers.toGames(response)
    }

    func fetchGame(id: Int) async throws -> ReelGame {
        let data = try await fetchData("\(baseURL)/games/\(id)")
        let response = try decodeOrThrow(data, as: RAWGGameDetailResponse.self)
        guard let game = RAWGMappers.toReelGame(response) else {
            throw AppError.decodingFailed
        }
        return game
    }

    func fetchScreenshots(gameId: Int) async throws -> [String] {
        let data = try await fetchData("\(baseURL)/games/\(gameId)/screenshots")
        let response = try decodeOrThrow(data, as: RAWGScreenshotsResponse.self)
        return RAWGMappers.toScreenshotUrls(response)
    }

    private nonisolated func fetchData(_ url: String, parameters: Parameters? = nil) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            session.request(url, parameters: parameters)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        continuation.resume(returning: data)
                    case .failure(let afError):
                        continuation.resume(throwing: Self.toAppError(afError))
                    }
                }
        }
    }

    private func decodeOrThrow<T: Decodable>(_ data: Data, as type: T.Type) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw AppError.decodingFailed
        }
    }

    private nonisolated static func toAppError(_ error: AFError) -> AppError {
        switch error {
        case .responseValidationFailed(reason: .unacceptableStatusCode(code: let code)):
            return code == 404 ? .notFound : .networkError(statusCode: code, message: error.localizedDescription)
        case .responseSerializationFailed:
            return .decodingFailed
        default:
            return .networkError(statusCode: error.responseCode, message: error.localizedDescription)
        }
    }
}
