import SwiftUI

@main
struct SimpleGamingApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    private let environment: AppEnvironment

    init() {
        let isTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        environment = isTesting ? .stub() : .live()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .environment(\.appEnvironment, environment)
    }
}
