//
//  MediaPickerComponents.swift
//  AlpacaList
//
//  Reusable view modifiers for handling PhotosPicker interactions
//

import SwiftUI
import PhotosUI

// MARK: - Managed Photo Picker

/// A view modifier that manages photo picker state and handles selection automatically
struct ManagedPhotoPicker: ViewModifier {
    @Binding var isPresented: Bool
    let maxSelectionCount: Int
    let onPhotosSelected: ([PhotosPickerItem]) async -> Void
    
    @State private var selectedItems: [PhotosPickerItem] = []
    
    func body(content: Content) -> some View {
        content
            .photosPicker(
                isPresented: $isPresented,
                selection: $selectedItems,
                maxSelectionCount: maxSelectionCount,
                matching: .images
            )
            .onChange(of: selectedItems) { oldItems, newItems in
                guard !newItems.isEmpty else { return }
                Task {
                    await onPhotosSelected(newItems)
                    // Clear selection after processing
                    selectedItems = []
                }
            }
    }
}

extension View {
    /// Attach a photo picker that handles selection automatically
    func managedPhotoPicker(
        isPresented: Binding<Bool>,
        maxSelectionCount: Int,
        onPhotosSelected: @escaping ([PhotosPickerItem]) async -> Void
    ) -> some View {
        self.modifier(ManagedPhotoPicker(
            isPresented: isPresented,
            maxSelectionCount: maxSelectionCount,
            onPhotosSelected: onPhotosSelected
        ))
    }
}

// MARK: - Managed Video Picker

/// A view modifier that manages video picker state and handles selection automatically
struct ManagedVideoPicker: ViewModifier {
    @Binding var isPresented: Bool
    let onVideoSelected: (PhotosPickerItem) async -> Void
    
    @State private var selectedItem: PhotosPickerItem? = nil
    
    func body(content: Content) -> some View {
        content
            .photosPicker(
                isPresented: $isPresented,
                selection: $selectedItem,
                matching: .videos
            )
            .onChange(of: selectedItem) { oldItem, newItem in
                guard let newItem = newItem else { return }
                Task {
                    await onVideoSelected(newItem)
                    // Clear selection after processing
                    selectedItem = nil
                }
            }
    }
}

extension View {
    /// Attach a video picker that handles selection automatically
    func managedVideoPicker(
        isPresented: Binding<Bool>,
        onVideoSelected: @escaping (PhotosPickerItem) async -> Void
    ) -> some View {
        self.modifier(ManagedVideoPicker(
            isPresented: isPresented,
            onVideoSelected: onVideoSelected
        ))
    }
}

