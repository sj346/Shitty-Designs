import SwiftUI

struct MainLayout: View {
    @State private var selectedTab: SidebarTab = .home
    
    var body: some View {
        HStack(spacing: 0) {
            Sidebar(selectedTab: $selectedTab)
            Divider()
            VStack(spacing: 0) {
                TopBar()
                Divider()
                ZStack {
                    switch selectedTab {
                    case .home:
                        FeedView()
                    case .search:
                        SearchView()
                    case .upload:
                        UploadView()
                    case .settings:
                        SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct MainLayout_Previews: PreviewProvider {
    static var previews: some View {
        MainLayout()
            .environmentObject(AuthViewModel())
            .environmentObject(DesignsViewModel())
    }
} 