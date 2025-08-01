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
    @EnvironmentObject var navigationRootController: NavigationRootController
    
    var body: some View {
        let isBackButtonDisabled = !navigationRootController.canPop
        HStack {
            Button(action: {
                navigationRootController.pop()
            }) {
                Image(systemName: "chevron.left")
            }
            .disabled(isBackButtonDisabled)
            .opacity(isBackButtonDisabled ? 0.5 : 1)
            Spacer()
            Button(action: {
                // Action for gear button
            }) {
                Image(systemName: "arrow.clockwise")
            }
            Spacer()
            TopBarModeSelector()
                .frame(width: 150)
            Spacer()
            Button(action: {
                // Add your button action here
            }) {
                Image(systemName: "chevron.up.chevron.down")
            }
            Spacer()
            Button(action: {
                // Action for plus button
            }) {
                Image(systemName: "plus")
            }
        }
        .foregroundColor(.white)
        .font(.system(size: 22)).fontWeight(.semibold)
        .frame(maxWidth: .infinity, minHeight: 20)
    }
}

struct TopBarExpanded: View {
    @Binding var communityName: String
    @Binding var userName: String
    @EnvironmentObject var navigationRootController: NavigationRootController
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @ViewBuilder var instanceSettingsButton: some View {
        ImageTextFieldPairView(imageName: "globe", text: $communityName) {
            navigationRootController.push(.instanceSettings)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder var userSettingsButton: some View {
        ImageTextFieldPairView(imageName: "person.circle", text: $userName) {
            navigationRootController.push(.userSettings)
        }
        .frame(maxWidth: .infinity)
    }
    
    var body: some View {
        VStack {
            if horizontalSizeClass == .compact {
                instanceSettingsButton
                userSettingsButton
            }
            else {
                HStack {
                    instanceSettingsButton
                    userSettingsButton
                }
            }
                
            Spacer().frame(height: 15)
            ButtonSubBarView()
                .padding(.horizontal, 10)
        }
        .padding(.horizontal, 8)
        .padding(.vertical)
    }
}

struct TopBarViewExpanded_Previews: PreviewProvider {
    static let navigationRootController = NavigationRootController()
    
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
                    communityName: .constant("lemmyworld@lemmy.world"),
                    userName: .constant("dog@kbin.social")
                )
                .environmentObject(navigationRootController)
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
