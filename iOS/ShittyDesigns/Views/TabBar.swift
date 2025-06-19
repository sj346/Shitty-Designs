import SwiftUI

struct TabBar: View {
    @Binding var selectedTab: SidebarTab
    var unreadNotifications: Int = 0
    var unreadMessages: Int = 0
    
    var body: some View {
        HStack {
            TabBarButton(icon: "house.fill", tab: .home, selectedTab: $selectedTab)
            TabBarButton(icon: "magnifyingglass", tab: .search, selectedTab: $selectedTab)
            TabBarButton(icon: "plus.circle.fill", tab: .upload, selectedTab: $selectedTab)
            TabBarButton(icon: "bell.fill", tab: .notifications, selectedTab: $selectedTab, badge: unreadNotifications)
            TabBarButton(icon: "bubble.left.and.bubble.right.fill", tab: .messages, selectedTab: $selectedTab, badge: unreadMessages)
            TabBarButton(icon: "gearshape.fill", tab: .settings, selectedTab: $selectedTab)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
}

struct TabBarButton: View {
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
        .frame(maxWidth: .infinity)
    }
}

struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        TabBar(selectedTab: .constant(.home), unreadNotifications: 2, unreadMessages: 1)
    }
} 