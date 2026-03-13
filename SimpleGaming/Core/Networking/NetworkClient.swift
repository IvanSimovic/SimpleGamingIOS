import Alamofire
import Foundation

final class NetworkClient: Sendable {
    static let shared = NetworkClient()

    let session: Session

    private init() {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 15
        configuration.waitsForConnectivity = true
        session = Session(
            configuration: configuration,
            interceptor: Interceptor(adapters: [RAWGRequestAdapter()])
        )
    }
}
