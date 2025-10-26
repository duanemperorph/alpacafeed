//
//  LinkInputSheet.swift
//  AlpacaList
//
//  Link input sheet for adding external link embeds to posts
//

import SwiftUI

struct LinkInputSheet: View {
    @Binding var urlInput: String
    @Binding var isPresented: Bool
    
    let isLoading: Bool
    let onAdd: (String) async -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enter URL")
                        .font(.headline)
                    
                    TextField("https://example.com", text: $urlInput)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                        .textContentType(.URL)
                }
                .padding()
                
                if isLoading {
                    ProgressView("Loading preview...")
                        .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Add Link")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        urlInput = ""
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        Task {
                            await onAdd(urlInput)
                            urlInput = ""
                            isPresented = false
                        }
                    }
                    .disabled(urlInput.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Preview

struct LinkInputSheet_Previews: PreviewProvider {
    static var previews: some View {
        LinkInputSheet(
            urlInput: .constant(""),
            isPresented: .constant(true),
            isLoading: false,
            onAdd: { _ in }
        )
    }
}

