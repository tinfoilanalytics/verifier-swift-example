import SwiftUI
import TinfoilVerifier
import UIKit

struct ContentView: View {
    @State private var eifHash: String = ""
    @State private var certFingerprint: String = ""
    @State private var errorMessage: String? = nil
    
    @State private var serverAddress = "inference-enclave.tinfoil.sh"
    @State private var projectPath = "tinfoilanalytics/nitro-enclave-build-demo"

    private func performVerification() {
        errorMessage = nil
        
        let client = TinfoilVerifier.ClientNewSecureClient(
            serverAddress,
            projectPath
        )

        do {
            let enclaveState = try client?.verify()
            
            eifHash = enclaveState?.eifHash ?? "Unknown"
            certFingerprint = enclaveState?.certFingerprint?.map { String(format: "%02x", $0) }.joined() ?? "none"
        } catch {
            print("Error: \(error)")
            errorMessage = error.localizedDescription
            eifHash = "Verification failed"
            certFingerprint = "Verification failed"
        }
    }

    var body: some View {
        ZStack {
            Color(white: 0.95)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                 to: nil,
                                                 from: nil,
                                                 for: nil)
                }
            
            VStack(spacing: 24) {
                Text("TINFOIL VERIFIER")
                    .font(.system(.title, design: .monospaced))
                    .fontWeight(.bold)
                    .tracking(2)
                    .padding(.top, 40)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 16) {
                    // Input fields group
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ENCLAVE HOST")
                                .font(.system(.subheadline, design: .monospaced))
                                .fontWeight(.bold)
                            TextField("", text: $serverAddress)
                                .font(.system(.footnote, design: .monospaced))
                                .padding(12)
                                .background(
                                    Rectangle()
                                        .stroke(Color.primary, lineWidth: 1)
                                )
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("SOURCE REPO")
                                .font(.system(.subheadline, design: .monospaced))
                                .fontWeight(.bold)
                            TextField("", text: $projectPath)
                                .font(.system(.footnote, design: .monospaced))
                                .padding(12)
                                .background(
                                    Rectangle()
                                        .stroke(Color.primary, lineWidth: 1)
                                )
                        }
                    }
                    
                    // Output fields group
                    VStack(alignment: .leading, spacing: 16) {
                        if let error = errorMessage {
                            Text("VERIFICATION RESULT")
                                .font(.system(.subheadline, design: .monospaced))
                                .fontWeight(.bold)
                                .padding(.top, 8)
                                
                            Text(error)
                                .font(.system(.footnote, design: .monospaced))
                                .foregroundColor(.red)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    Rectangle()
                                        .fill(Color(white: 0.97))
                                        .stroke(Color.red, lineWidth: 1)
                                )
                        } else if eifHash != "" {
                            Text("VERIFICATION RESULT")
                                .font(.system(.subheadline, design: .monospaced))
                                .fontWeight(.bold)
                                .padding(.top, 8)
                                
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Verification successful")
                                    .foregroundColor(.green)
                            }
                            .font(.system(.footnote, design: .monospaced))
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                Rectangle()
                                    .fill(Color(white: 0.97))
                                    .stroke(Color.green, lineWidth: 1)
                            )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("EIF HASH")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.secondary)
                                Text(eifHash)
                                    .font(.system(.footnote, design: .monospaced))
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        Rectangle()
                                            .fill(Color(white: 0.97))
                                            .stroke(Color.primary, lineWidth: 1)
                                    )
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("CERT FINGERPRINT")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.secondary)
                                Text(certFingerprint)
                                    .font(.system(.footnote, design: .monospaced))
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        Rectangle()
                                            .fill(Color(white: 0.97))
                                            .stroke(Color.primary, lineWidth: 1)
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("LINKS")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.secondary)
                                
                                Link(destination: URL(string: "https://github.com/\(projectPath)/releases/latest")!) {
                                    HStack {
                                        Image(systemName: "link")
                                        Text("View Source Repository")
                                    }
                                    .font(.system(.footnote, design: .monospaced))
                                    .foregroundColor(.blue)
                                }
                                
                                Link(destination: URL(string: "https://\(serverAddress)/.well-known/tinfoil-attestation")!) {
                                    HStack {
                                        Image(systemName: "link")
                                        Text("View Attestation Document")
                                    }
                                    .font(.system(.footnote, design: .monospaced))
                                    .foregroundColor(.blue)
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()

                HStack(spacing: 12) {
                    Button(action: {
                        performVerification()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.shield")
                            Text("VERIFY")
                        }
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            Rectangle()
                                .fill(Color.white)
                                .shadow(color: .black, radius: 0, x: 4, y: 4)
                        )
                        .overlay(
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                        )
                    }
                    
                    Button(action: {
                        eifHash = ""
                        certFingerprint = ""
                        errorMessage = nil
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("CLEAR")
                        }
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            Rectangle()
                                .fill(Color.white)
                                .shadow(color: .black, radius: 0, x: 4, y: 4)
                        )
                        .overlay(
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
