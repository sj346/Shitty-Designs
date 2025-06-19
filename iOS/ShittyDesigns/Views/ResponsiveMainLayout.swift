import SwiftUI

struct ResponsiveMainLayout: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var selectedTab: SidebarTab = .home
    @State private var unreadNotifications: Int = 2 // Example
    @State private var unreadMessages: Int = 1 // Example
    
    var body: some View {
        if horizontalSizeClass == .regular {
            // Sidebar layout for iPad/Mac
            HStack(spacing: 0) {
                Sidebar(selectedTab: $selectedTab, unreadNotifications: unreadNotifications, unreadMessages: unreadMessages)
                Divider()
                VStack(spacing: 0) {
                    TopBar()
                    Divider()
                    ZStack {
                        mainContent
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        } else {
            // TabBar layout for iPhone
            VStack(spacing: 0) {
                ZStack {
                    mainContent
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                TabBar(selectedTab: $selectedTab, unreadNotifications: unreadNotifications, unreadMessages: unreadMessages)
            }
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        switch selectedTab {
        case .home:
            FeedView()
        case .search:
            SearchView()
        case .upload:
            UploadView()
        case .notifications:
            NotificationsView()
        case .messages:
            MessagesView()
        case .settings:
            SettingsView()
        }
    }
}

struct ResponsiveMainLayout_Previews: PreviewProvider {
    static var previews: some View {
        ResponsiveMainLayout()
            .environmentObject(AuthViewModel())
            .environmentObject(DesignsViewModel())
    }
} 