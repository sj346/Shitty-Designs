import Foundation
import SwiftUI
import Supabase

@MainActor
class DesignsViewModel: ObservableObject {
    @Published var designs: [Design] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isUploading = false
    
    private let supabase = SupabaseClient.shared
    
    init() {
        fetchDesigns()
    }
    
    func fetchDesigns() {
        isLoading = true
        
        Task {
            do {
                let response: [Design] = try await supabase.database
                    .from("designs")
                    .select()
                    .eq("is_approved", value: true) // Only fetch approved designs
                    .order("created_at", ascending: false)
                    .execute()
                    .value
                
                designs = response
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    func uploadDesign(title: String, description: String?, image: UIImage, tags: [String], needsReview: Bool = false) async {
        isUploading = true
        errorMessage = nil
        
        do {
            // Get current user
            guard let user = try await supabase.auth.session?.user else {
                throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
            }
            
            // Upload image to Supabase Storage
            let imageData = image.jpegData(compressionQuality: 0.8) ?? Data()
            let fileName = "\(UUID().uuidString).jpg"
            
            let storageResponse = try await supabase.storage
                .from("designs")
                .upload(
                    path: fileName,
                    file: imageData,
                    options: FileOptions(contentType: "image/jpeg")
                )
            
            // Get public URL for the uploaded image
            let imageURL = supabase.storage
                .from("designs")
                .getPublicURL(path: fileName)
            
            // Get user profile
            let userResponse: [User] = try await supabase.database
                .from("users")
                .select()
                .eq("id", value: user.id)
                .execute()
                .value
            
            guard let userProfile = userResponse.first else {
                throw NSError(domain: "User", code: 404, userInfo: [NSLocalizedDescriptionKey: "User profile not found"])
            }
            
            // Create design record
            let newDesign = Design(
                title: title,
                description: description,
                imageURL: imageURL,
                userId: user.id,
                userName: userProfile.username,
                userAvatarURL: userProfile.avatarURL,
                tags: tags,
                isApproved: !needsReview,
                needsReview: needsReview
            )
            
            try await supabase.database
                .from("designs")
                .insert(newDesign)
                .execute()
            
            // Refresh designs list
            await fetchDesigns()
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isUploading = false
    }
    
    func likeDesign(_ design: Design) async {
        do {
            guard let user = try await supabase.auth.session?.user else { return }
            
            // Check if already liked
            let existingLike: [Like] = try await supabase.database
                .from("likes")
                .select()
                .eq("design_id", value: design.id)
                .eq("user_id", value: user.id)
                .execute()
                .value
            
            if existingLike.isEmpty {
                // Add like
                let like = Like(
                    designId: design.id,
                    userId: user.id
                )
                
                try await supabase.database
                    .from("likes")
                    .insert(like)
                    .execute()
            } else {
                // Remove like
                try await supabase.database
                    .from("likes")
                    .delete()
                    .eq("design_id", value: design.id)
                    .eq("user_id", value: user.id)
                    .execute()
            }
            
            // Refresh designs to update like counts
            await fetchDesigns()
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func addComment(to design: Design, content: String) async {
        do {
            guard let user = try await supabase.auth.session?.user else { return }
            
            let userResponse: [User] = try await supabase.database
                .from("users")
                .select()
                .eq("id", value: user.id)
                .execute()
                .value
            
            guard let userProfile = userResponse.first else { return }
            
            let comment = Comment(
                designId: design.id,
                userId: user.id,
                userName: userProfile.username,
                userAvatarURL: userProfile.avatarURL,
                content: content
            )
            
            try await supabase.database
                .from("comments")
                .insert(comment)
                .execute()
            
            // Refresh designs to update comment counts
            await fetchDesigns()
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // Report inappropriate content
    func reportDesign(_ design: Design, reason: String) async {
        do {
            guard let user = try await supabase.auth.session?.user else { return }
            
            let report = Report(
                designId: design.id,
                userId: user.id,
                reason: reason,
                status: "pending"
            )
            
            try await supabase.database
                .from("reports")
                .insert(report)
                .execute()
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// Helper struct for likes
struct Like: Identifiable, Codable {
    let id: UUID
    let designId: UUID
    let userId: UUID
    let createdAt: Date
    
    init(id: UUID = UUID(), designId: UUID, userId: UUID, createdAt: Date = Date()) {
        self.id = id
        self.designId = designId
        self.userId = userId
        self.createdAt = createdAt
    }
}

// Helper struct for reports
struct Report: Identifiable, Codable {
    let id: UUID
    let designId: UUID
    let userId: UUID
    let reason: String
    let status: String
    let createdAt: Date
    
    init(id: UUID = UUID(), designId: UUID, userId: UUID, reason: String, status: String, createdAt: Date = Date()) {
        self.id = id
        self.designId = designId
        self.userId = userId
        self.reason = reason
        self.status = status
        self.createdAt = createdAt
    }
} 