import SwiftUI

struct TopBar: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showAccountMenu = false
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: { showAccountMenu.toggle() }) {
                if let avatarURL = authViewModel.currentUser?.avatarURL,
                   let url = URL(string: avatarURL) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Image(systemName: "person.crop.circle")
                    }
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 36, height: 36)
                }
            }
            .popover(isPresented: $showAccountMenu) {
                AccountMenuView()
                    .environmentObject(authViewModel)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

struct AccountMenuView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                if let avatarURL = authViewModel.currentUser?.avatarURL,
                   let url = URL(string: avatarURL) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Image(systemName: "person.crop.circle")
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 48, height: 48)
                }
                VStack(alignment: .leading) {
                    Text(authViewModel.currentUser?.username ?? "User")
                        .font(.headline)
                    Text(authViewModel.currentUser?.email ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Divider()
            Button(action: {
                // Navigate to profile
                presentationMode.wrappedValue.dismiss()
                // Add navigation logic here
            }) {
                Label("View Profile", systemImage: "person.fill")
            }
            Button(action: {
                // Navigate to settings
                presentationMode.wrappedValue.dismiss()
                // Add navigation logic here
            }) {
                Label("Settings", systemImage: "gearshape.fill")
            }
            Button(action: {
                Task {
                    await authViewModel.signOut()
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    .foregroundColor(.red)
            }
            Spacer()
        }
        .padding()
        .frame(width: 220)
    }
}

struct TopBar_Previews: PreviewProvider {
    static var previews: some View {
        TopBar()
            .environmentObject(AuthViewModel())
    }
} 