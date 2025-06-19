import SwiftUI

struct MessagesView: View {
    var body: some View {
        VStack {
            Text("Messages")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            Spacer()
            Text("No messages yet. Start a conversation!")
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
    }
} 