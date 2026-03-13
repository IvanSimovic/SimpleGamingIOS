import Alamofire
import Foundation

struct RAWGRequestAdapter: RequestAdapter, Sendable {
    private let apiKey: String

    init() {
        guard
            let key = Bundle.main.infoDictionary?["RAWG_API_KEY"] as? String,
            !key.isEmpty,
            key != "YOUR_RAWG_API_KEY_HERE"
        else {
            preconditionFailure("RAWG_API_KEY missing from Info.plist — see Config.xcconfig setup in README")
        }
        apiKey = key
    }

    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var request = urlRequest
        guard
            let url = request.url,
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            completion(.success(request))
            return
        }
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "key", value: apiKey))
        components.queryItems = queryItems
        request.url = components.url
        completion(.success(request))
    }
}
