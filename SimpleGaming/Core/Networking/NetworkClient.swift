import Alamofire

final class NetworkClient: Sendable {
    static let shared = NetworkClient()

    let session: Session

    private init() {
        session = Session(interceptor: Interceptor(adapters: [RAWGRequestAdapter()]))
    }
}
