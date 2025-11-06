import SwiftUI

struct ImageTextFieldPairView: View {
    var imageName: String
    @Binding var text: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: imageName)
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                    .frame(width: 20, height: 20)
                Text(text)
                    .font(.system(size: 18))
                    .padding(.horizontal, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .tint(.primary)
        .buttonStyle(.borderless)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, minHeight: 40)
        .background(Color.white.opacity(0.1).cornerRadius(10))
        .overlay( /// apply a rounded border
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
        )
    }
}

struct ButtonSubBarView: View {
    @Environment(NavigationCoordinator.self) private var navigationCoordinator
    
    @ViewBuilder
    var centerContent: some View {
        if case .thread = navigationCoordinator.navigationStack.last {
            // Thread mode - show simple "Thread" label
            Text("Thread")
                .feedSelectorPillStyle()
        } else {
            // Timeline mode - show feed selector
            BlueskyFeedSelector()
        }
    }
    
    var body: some View {
        let isBackButtonDisabled = !navigationCoordinator.canPop
        HStack(spacing: 24) {
            // Back button
            Button(action: {
                navigationCoordinator.pop()
            }) {
                Image(systemName: "chevron.left")
            }
            .disabled(isBackButtonDisabled)
            .opacity(isBackButtonDisabled ? 0.5 : 1)
            
            // Context-aware center content
            centerContent
            
            // Compose button
            Button(action: {
                navigationCoordinator.presentComposeContextAware()
            }) {
                Image(systemName: "plus")
            }
        }
        .foregroundColor(.white)
        .font(.system(size: 22)).fontWeight(.semibold)
        .frame(maxWidth: .infinity, minHeight: 20)
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let refreshTimeline = Notification.Name("refreshTimeline")
}

struct TopBarExpanded: View {
    @Binding var userName: String
    @Environment(NavigationCoordinator.self) private var navigationCoordinator
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @ViewBuilder var userSettingsButton: some View {
        ImageTextFieldPairView(imageName: "person.circle", text: $userName) {
            navigationCoordinator.presentSettings()
        }
        .frame(maxWidth: .infinity)
    }
    
    var body: some View {
        VStack {
            userSettingsButton
                
            Spacer().frame(height: 15)
            ButtonSubBarView()
                .padding(.horizontal, 10)
        }
        .padding(.horizontal, 8)
        .padding(.vertical)
    }
}

struct TopBarViewExpanded_Previews: PreviewProvider {
    static let appState = AppState()
    static let navigationCoordinator = NavigationCoordinator(appState: appState)
    
    @ViewBuilder static var createPreview: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            VStack {
                TopBarExpanded(
                    userName: .constant("alice.bsky.social")
                )
                .environment(appState)
                .environment(navigationCoordinator)
            }
            .background(.regularMaterial)
            .environment(\.colorScheme, .dark)
        }
    }
    
    
    static var previews: some View {
            createPreview
            createPreview
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (4th generation)"))
                .previewDisplayName("iPad Pro 11\"")
    }
}
