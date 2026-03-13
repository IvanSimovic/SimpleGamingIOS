import SwiftUI

struct AuthView: View {
    @State private var viewModel: AuthViewModel

    init(signIn: @escaping @Sendable (String, String) async throws -> Void) {
        _viewModel = State(initialValue: AuthViewModel(signIn: signIn))
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 32) {
                Text("SimpleGaming")
                    .font(AppFont.head1)
                    .foregroundStyle(Color.brandPrimary)

                VStack(spacing: 16) {
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding()
                        .background(Color.appSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    SecureField("Password", text: $viewModel.password)
                        .textContentType(.password)
                        .padding()
                        .background(Color.appSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                if case .failed(let message) = viewModel.state {
                    Text(message)
                        .font(AppFont.body3)
                        .foregroundStyle(Color.appError)
                        .multilineTextAlignment(.center)
                }

                Button {
                    Task { await viewModel.signInTapped() }
                } label: {
                    Group {
                        if viewModel.state == .loading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Sign In")
                                .font(AppFont.body1)
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                }
                .background(Color.brandPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(viewModel.state == .loading)
            }
            .padding(.horizontal, 24)
        }
    }
}
