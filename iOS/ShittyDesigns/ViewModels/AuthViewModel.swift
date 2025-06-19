import Foundation
import SwiftUI
import Supabase

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseClient.shared
    
    init() {
        checkAuthState()
    }
    
    func checkAuthState() {
        Task {
            do {
                let session = try await supabase.auth.session
                if session != nil {
                    await fetchCurrentUser()
                    isAuthenticated = true
                }
            } catch {
                print("Error checking auth state: \(error)")
            }
        }
    }
    
    func signUp(email: String, password: String, username: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let authResponse = try await supabase.auth.signUp(
                email: email,
                password: password
            )
            
            if let user = authResponse.user {
                // Create user profile in database
                let newUser = User(
                    id: user.id,
                    username: username,
                    email: email
                )
                
                try await supabase.database
                    .from("users")
                    .insert(newUser)
                    .execute()
                
                await fetchCurrentUser()
                isAuthenticated = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let authResponse = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            if authResponse.user != nil {
                await fetchCurrentUser()
                isAuthenticated = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            isAuthenticated = false
            currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func fetchCurrentUser() async {
        do {
            let user = try await supabase.auth.session?.user
            guard let userId = user?.id else { return }
            
            let response: [User] = try await supabase.database
                .from("users")
                .select()
                .eq("id", value: userId)
                .execute()
                .value
            
            if let user = response.first {
                currentUser = user
            }
        } catch {
            print("Error fetching current user: \(error)")
        }
    }
} 