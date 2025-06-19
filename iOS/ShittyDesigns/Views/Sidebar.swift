import SwiftUI

struct Sidebar: View {
    @Binding var selectedTab: SidebarTab
    var unreadNotifications: Int = 0
    var unreadMessages: Int = 0
    
    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "paintbrush.pointed.fill")
                .font(.system(size: 32))
                .padding(.top, 24)
                .foregroundColor(.purple)
            
            SidebarButton(icon: "house.fill", tab: .home, selectedTab: $selectedTab, badge: unreadNotifications)
            SidebarButton(icon: "magnifyingglass", tab: .search, selectedTab: $selectedTab, badge: unreadMessages)
            SidebarButton(icon: "plus.circle.fill", tab: .upload, selectedTab: $selectedTab)
            SidebarButton(icon: "bell.fill", tab: .notifications, selectedTab: $selectedTab, badge: unreadNotifications)
            SidebarButton(icon: "bubble.left.and.bubble.right.fill", tab: .messages, selectedTab: $selectedTab, badge: unreadMessages)
            SidebarButton(icon: "gearshape.fill", tab: .settings, selectedTab: $selectedTab)
            Spacer()
        }
        .frame(width: 60)
        .background(Color(.systemGray6))
    }
}

enum SidebarTab: String, CaseIterable {
    case home, search, upload, notifications, messages, settings
}

struct SidebarButton: View {
    let icon: String
    let tab: SidebarTab
    @Binding var selectedTab: SidebarTab
    var badge: Int = 0
    
    var body: some View {
        Button(action: {
            selectedTab = tab
        }) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(selectedTab == tab ? .purple : .gray)
                    .padding(8)
                    .background(selectedTab == tab ? Color.purple.opacity(0.15) : Color.clear)
                    .clipShape(Circle())
                if badge > 0 {
                    Text("\(badge)")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 10, y: -10)
                }
            }
        }
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar(selectedTab: .constant(.home), unreadNotifications: 2, unreadMessages: 1)
    }
} 