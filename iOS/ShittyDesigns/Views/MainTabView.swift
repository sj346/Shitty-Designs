import SwiftUI

struct MainTabView: View {
    @StateObject private var designsViewModel = DesignsViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            // Feed Tab
            FeedView()
                .environmentObject(designsViewModel)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Feed")
                }
            
            // Upload Tab
            UploadView()
                .environmentObject(designsViewModel)
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Upload")
                }
            
            // Search Tab
            SearchView()
                .environmentObject(designsViewModel)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            
            // Profile Tab
            ProfileView()
                .environmentObject(designsViewModel)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .accentColor(.purple)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthViewModel())
    }
} 