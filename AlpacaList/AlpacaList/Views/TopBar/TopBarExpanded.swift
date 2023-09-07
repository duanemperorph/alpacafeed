import SwiftUI

struct ImageTextFieldPairView: View {
    var imageName: String
    @Binding var text: String
    
    var body: some View {
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
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, minHeight: 40)
        .background(Color.white.opacity(0.1).cornerRadius(10))
        .overlay( /// apply a rounded border
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
        )
    }
}

struct ModeSelectorButton: View {
    var body: some View {
        HStack {
            Image(systemName: "chevron.left").font(.system(size: 14)).fontWeight(.bold)
            Text("Your Text")
                .frame(maxWidth: .infinity)
            Image(systemName: "chevron.right").font(.system(size: 14)).fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, minHeight: 30, maxHeight: 30)
        .padding(.horizontal, 15)
        .foregroundColor(.white)
        .font(.system(size: 16)).fontWeight(.semibold)
        .background(Color.white.opacity(0.1)).cornerRadius(15)
        .overlay( /// apply a rounded border
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
        )
    }
}

struct ButtonSubBarView: View {
    var body: some View {
        HStack {
            Button(action: {
                // Action for gear button
            }) {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Button(action: {
                // Action for gear button
            }) {
                Image(systemName: "arrow.clockwise")
            }
            Spacer()
            ModeSelectorButton()
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
    
    var body: some View {
        VStack {
            ImageTextFieldPairView(imageName: "person.circle", text: $userName)
                .frame(maxWidth: .infinity)
            ImageTextFieldPairView(imageName: "globe", text: $communityName)
                .frame(maxWidth: .infinity)
            Spacer().frame(height: 15)
            ButtonSubBarView()
                .padding(.horizontal, 10)
        }
        .padding(.horizontal, 8)
        .padding(.vertical)
    }
}

struct TopBarViewExpanded_Previews: PreviewProvider {
    static var previews: some View {
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
                
            }
            .background(.regularMaterial)
            .environment(\.colorScheme, .dark)
        }
    }
}
