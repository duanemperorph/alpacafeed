import SwiftUI

struct TopBarView: View {
    @Environment(\.colorScheme) var envColorScheme

    var backgroundColorScheme: ColorScheme {
        return envColorScheme == .dark ? ColorScheme.light : ColorScheme.dark
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    // Action for first button
                }) {
                    Text("Button 1")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }.frame(maxWidth: .infinity)

                Button(action: {
                    // Action for second button
                }) {
                    Text("Button 2")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }.frame(maxWidth: .infinity)
            }.frame(maxWidth: .infinity)


            HStack {
                Button(action: {
                    // Action for third button
                }) {
                    Text("Button 3")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }.frame(maxWidth: .infinity)

                Button(action: {
                    // Action for fourth button
                }) {
                    Text("Button 4")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(10)
                }.frame(maxWidth: .infinity)
            }.frame(maxWidth: .infinity)
        }
        .padding()
        .background(.regularMaterial)
        .environment(\.colorScheme, backgroundColorScheme)
    }
}

struct TopBarView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            TopBarView()
        }
    }
}
