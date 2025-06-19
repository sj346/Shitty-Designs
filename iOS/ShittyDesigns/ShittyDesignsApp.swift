import SwiftUI
import Supabase

@main
struct ShittyDesignsApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .onAppear {
                    setupSupabase()
                }
        }
    }
    
    private func setupSupabase() {
        // Configure Supabase client
        // You'll need to add your Supabase URL and anon key here
        let supabaseURL = "YOUR_SUPABASE_URL"
        let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"
        
        SupabaseClient.shared.configure(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseAnonKey
        )
    }
} 