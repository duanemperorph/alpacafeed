//
//  BlueskySettings.swift
//  AlpacaList
//
//  Bluesky account and feed configuration settings
//

import SwiftUI

/// Bluesky account and configuration settings
struct BlueskySettings: View {
    @AppStorage("bluesky_enabled") private var blueskyEnabled = false
    @AppStorage("bluesky_pds_host") private var pdsHost = "https://bsky.social"
    
    @State private var accounts: [BlueskyAccount] = []
    @State private var showingAddAccount = false
    @State private var showingAccountDetail: BlueskyAccount?
    
    var body: some View {
        Form {
            // Enable/Disable Section
            Section {
                Toggle("Enable Bluesky", isOn: $blueskyEnabled)
            } header: {
                Text("Bluesky Integration")
            } footer: {
                Text("Enable Bluesky AT Protocol integration for decentralized social networking.")
            }
            
            if blueskyEnabled {
                // Accounts Section
                Section {
                    if accounts.isEmpty {
                        Button(action: {
                            showingAddAccount = true
                        }) {
                            Label("Add Account", systemImage: "plus.circle")
                        }
                    } else {
                        ForEach(accounts) { account in
                            Button(action: {
                                showingAccountDetail = account
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(account.displayName ?? account.handle)
                                            .font(.headline)
                                        Text("@\(account.handle)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    if account.isActive {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        }
                        .onDelete(perform: deleteAccounts)
                        
                        Button(action: {
                            showingAddAccount = true
                        }) {
                            Label("Add Another Account", systemImage: "plus.circle")
                        }
                    }
                } header: {
                    Text("Accounts")
                } footer: {
                    Text("Add one or more Bluesky accounts. The active account will be used for posting and interactions.")
                }
                
                // PDS Configuration Section
                Section {
                    HStack {
                        Text("PDS Host")
                        Spacer()
                        TextField("https://bsky.social", text: $pdsHost)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .frame(width: 200)
                    }
                } header: {
                    Text("Personal Data Server")
                } footer: {
                    Text("The AT Protocol PDS host. Use https://bsky.social for the main Bluesky network, or enter your own PDS URL for self-hosting.")
                }
                
                // Feed Preferences Section
                Section {
                    NavigationLink(destination: FeedPreferencesView()) {
                        Label("Feed Preferences", systemImage: "list.bullet")
                    }
                    
                    NavigationLink(destination: ContentFilteringView()) {
                        Label("Content Filtering", systemImage: "eye.slash")
                    }
                } header: {
                    Text("Feed Settings")
                }
                
                // Advanced Section
                Section {
                    Toggle("Show Quote Posts", isOn: .constant(true))
                    Toggle("Show Reposts", isOn: .constant(true))
                    Toggle("Show Replies", isOn: .constant(true))
                } header: {
                    Text("Timeline Display")
                }
            }
        }
        .navigationTitle("Bluesky Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddAccount) {
            AddBlueskyAccountView(accounts: $accounts)
        }
        .sheet(item: $showingAccountDetail) { account in
            AccountDetailView(account: account, accounts: $accounts)
        }
        .onAppear {
            loadAccounts()
        }
    }
    
    // MARK: - Account Management
    
    private func loadAccounts() {
        // TODO: Load from secure storage (Keychain)
        // For now, show mock accounts if enabled
        if blueskyEnabled && accounts.isEmpty {
            accounts = []
        }
    }
    
    private func deleteAccounts(at offsets: IndexSet) {
        accounts.remove(atOffsets: offsets)
        // TODO: Delete from secure storage
    }
}

// MARK: - Bluesky Account Model

struct BlueskyAccount: Identifiable {
    let id = UUID()
    let did: String
    let handle: String
    let displayName: String?
    var isActive: Bool
    
    // Stored securely in Keychain (not in this struct)
    // - accessJwt
    // - refreshJwt
}

// MARK: - Add Account View

struct AddBlueskyAccountView: View {
    @Binding var accounts: [BlueskyAccount]
    @Environment(\.dismiss) var dismiss
    
    @State private var handle = ""
    @State private var appPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Handle or Email", text: $handle)
                        .textContentType(.username)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("App Password", text: $appPassword)
                        .textContentType(.password)
                } header: {
                    Text("Account Credentials")
                } footer: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Enter your Bluesky handle (e.g., alice.bsky.social) or email address.")
                        Text("Use an App Password, not your main password. Generate one in your Bluesky app settings.")
                            .foregroundColor(.orange)
                    }
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: login) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Sign In")
                        }
                    }
                    .disabled(handle.isEmpty || appPassword.isEmpty || isLoading)
                }
            }
            .navigationTitle("Add Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func login() {
        isLoading = true
        errorMessage = nil
        
        // TODO: Implement actual Bluesky authentication
        // 1. Call com.atproto.server.createSession
        // 2. Store accessJwt, refreshJwt, did in Keychain
        // 3. Add account to list
        
        // Mock success for now
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let newAccount = BlueskyAccount(
                did: "did:plc:\(UUID().uuidString.prefix(8))",
                handle: handle,
                displayName: nil,
                isActive: accounts.isEmpty // First account is active
            )
            accounts.append(newAccount)
            isLoading = false
            dismiss()
        }
    }
}

// MARK: - Account Detail View

struct AccountDetailView: View {
    let account: BlueskyAccount
    @Binding var accounts: [BlueskyAccount]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("Handle")
                        Spacer()
                        Text("@\(account.handle)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("DID")
                        Spacer()
                        Text(account.did)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Section {
                    if account.isActive {
                        Text("This is your active account")
                            .foregroundColor(.secondary)
                    } else {
                        Button("Set as Active Account") {
                            setActive()
                        }
                    }
                }
                
                Section {
                    Button("Sign Out", role: .destructive) {
                        signOut()
                    }
                }
            }
            .navigationTitle(account.displayName ?? account.handle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func setActive() {
        // Set all accounts to inactive, then activate this one
        for i in accounts.indices {
            accounts[i].isActive = accounts[i].id == account.id
        }
        dismiss()
    }
    
    private func signOut() {
        accounts.removeAll { $0.id == account.id }
        // TODO: Clear tokens from Keychain
        dismiss()
    }
}

// MARK: - Feed Preferences View

struct FeedPreferencesView: View {
    var body: some View {
        Form {
            Section {
                Text("Home feed algorithm selection")
                // TODO: List available algorithms
            } header: {
                Text("Feed Algorithm")
            }
            
            Section {
                Text("Custom feed management")
                // TODO: Add/remove custom feeds
            } header: {
                Text("Custom Feeds")
            }
        }
        .navigationTitle("Feed Preferences")
    }
}

// MARK: - Content Filtering View

struct ContentFilteringView: View {
    var body: some View {
        Form {
            Section {
                Toggle("Hide Sensitive Content", isOn: .constant(false))
                Toggle("Hide Posts with No Alt Text", isOn: .constant(false))
            } header: {
                Text("Content Filters")
            }
            
            Section {
                Text("Muted words and tags")
                // TODO: Muted words list
            } header: {
                Text("Muted Content")
            }
        }
        .navigationTitle("Content Filtering")
    }
}

// MARK: - Previews

struct BlueskySettings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BlueskySettings()
        }
    }
}

