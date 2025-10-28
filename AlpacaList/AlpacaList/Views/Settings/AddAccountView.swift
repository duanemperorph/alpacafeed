//
//  AddAccountView.swift
//  AlpacaList
//
//  Created by Lucas Nguyen on 10/28/25.
//

import SwiftUI

struct AddAccountView: View {
    @State private var handle: String = ""
    @State private var appPassword: String = ""
    @State private var server: String = "bsky.social"
    @State private var isLoggingIn: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    // Callback to notify parent when login succeeds
    var onLoginSuccess: (String) -> Void
    
    var body: some View {
        ZStack {
            // Background
            Color.clear
                .background(.ultraThinMaterial)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.accentColor)
                            .padding(.top, 20)
                        
                        Text("Add Bluesky Account")
                            .font(.title2)
                            .fontWeight(.bold)
                            .fontDesign(.monospaced)
                        
                        Text("Sign in with your Bluesky credentials")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fontDesign(.monospaced)
                    }
                    .padding(.bottom, 10)
                    
                    // Input Fields
                    VStack(spacing: 16) {
                        // Server Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Server")
                                .font(.system(size: 14))
                                .fontWeight(.semibold)
                                .fontDesign(.monospaced)
                                .foregroundColor(.primary.opacity(0.7))
                            
                            HStack {
                                Image(systemName: "server.rack")
                                    .foregroundColor(.secondary)
                                TextField("bsky.social", text: $server)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .keyboardType(.URL)
                                    .fontDesign(.monospaced)
                            }
                            .padding()
                            .background(Color.primary.opacity(0.08))
                            .cornerRadius(10)
                        }
                        
                        // Handle Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Handle")
                                .font(.system(size: 14))
                                .fontWeight(.semibold)
                                .fontDesign(.monospaced)
                                .foregroundColor(.primary.opacity(0.7))
                            
                            HStack {
                                Image(systemName: "at")
                                    .foregroundColor(.secondary)
                                TextField("username.bsky.social", text: $handle)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .keyboardType(.emailAddress)
                                    .fontDesign(.monospaced)
                            }
                            .padding()
                            .background(Color.primary.opacity(0.08))
                            .cornerRadius(10)
                        }
                        
                        // App Password Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("App Password")
                                .font(.system(size: 14))
                                .fontWeight(.semibold)
                                .fontDesign(.monospaced)
                                .foregroundColor(.primary.opacity(0.7))
                            
                            HStack {
                                Image(systemName: "key")
                                    .foregroundColor(.secondary)
                                SecureField("xxxx-xxxx-xxxx-xxxx", text: $appPassword)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .fontDesign(.monospaced)
                            }
                            .padding()
                            .background(Color.primary.opacity(0.08))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Info Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.accentColor)
                            Text("About App Passwords")
                                .font(.system(size: 14))
                                .fontWeight(.semibold)
                                .fontDesign(.monospaced)
                        }
                        
                        Text("For security, Bluesky uses app-specific passwords. You can create one in your Bluesky app under Settings → Privacy and Security → App Passwords.")
                            .font(.system(size: 13))
                            .fontDesign(.monospaced)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    
                    // Login Button
                    Button(action: handleLogin) {
                        HStack {
                            if isLoggingIn {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Sign In")
                                    .fontWeight(.bold)
                                    .fontDesign(.monospaced)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canLogin ? Color.accentColor : Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!canLogin || isLoggingIn)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle("Add Account")
        .navigationBarTitleDisplayMode(.inline)
        .alpacaListNavigationBar()
        .alert("Login Failed", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var canLogin: Bool {
        !handle.isEmpty && !appPassword.isEmpty && !isLoggingIn
    }
    
    private func handleLogin() {
        isLoggingIn = true
        
        // TODO: Implement actual Bluesky authentication
        // Use the server field to construct the API endpoint
        // e.g., https://bsky.social/xrpc/com.atproto.server.createSession
        
        // For now, simulate a network call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoggingIn = false
            
            // Validate handle format
            let trimmedHandle = handle.trimmingCharacters(in: .whitespaces)
            let trimmedServer = server.trimmingCharacters(in: .whitespaces)
            
            // Validate inputs
            guard !trimmedHandle.isEmpty && !appPassword.isEmpty else {
                errorMessage = "Please enter a valid handle and app password."
                showError = true
                return
            }
            
            guard !trimmedServer.isEmpty else {
                errorMessage = "Please enter a valid server."
                showError = true
                return
            }
            
            // TODO: When implementing real auth, use: https://\(trimmedServer)/xrpc/com.atproto.server.createSession
            // For now, just call success
            onLoginSuccess(trimmedHandle)
        }
    }
}

struct AddAccountView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                AddAccountView { handle in
                    print("Logged in as: \(handle)")
                }
            }
        }
        .tint(Color(red: 0.75, green: 0.25, blue: 0.75))
    }
}

