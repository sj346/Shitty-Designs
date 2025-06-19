import SwiftUI
import PhotosUI

struct UploadView: View {
    @EnvironmentObject var designsViewModel: DesignsViewModel
    @StateObject private var contentModerator = ContentModerator()
    @State private var selectedImage: UIImage?
    @State private var title = ""
    @State private var description = ""
    @State private var tags = ""
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingActionSheet = false
    @State private var showingModerationAlert = false
    @State private var moderationMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "paintbrush.pointed.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.purple)
                        
                        Text("Share Your Design")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("No matter how \"shitty\" it is, we want to see it!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // Content Guidelines
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Community Guidelines")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("• Keep it family-friendly and appropriate")
                            Text("• No explicit, violent, or adult content")
                            Text("• No hate speech or harassment")
                            Text("• Respect copyright and intellectual property")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Image selection
                    VStack(spacing: 16) {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 300)
                                .cornerRadius(12)
                                .overlay(
                                    Button(action: {
                                        self.selectedImage = nil
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title)
                                            .foregroundColor(.white)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(Circle())
                                    }
                                    .padding(8),
                                    alignment: .topTrailing
                                )
                        } else {
                            Button(action: {
                                showingActionSheet = true
                            }) {
                                VStack(spacing: 12) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.purple)
                                    
                                    Text("Add Your Design")
                                        .font(.headline)
                                        .foregroundColor(.purple)
                                    
                                    Text("Tap to select from gallery or take a photo")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.purple.opacity(0.3), lineWidth: 2)
                                )
                            }
                        }
                    }
                    
                    // Form fields
                    VStack(spacing: 16) {
                        TextField("Design Title", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Description (optional)", text: $description, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                        
                        TextField("Tags (comma separated)", text: $tags)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Upload button
                    Button(action: {
                        uploadDesign()
                    }) {
                        HStack {
                            if designsViewModel.isUploading || contentModerator.isAnalyzing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            
                            Text(uploadButtonText)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(uploadButtonColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(selectedImage == nil || title.isEmpty || designsViewModel.isUploading || contentModerator.isAnalyzing)
                    
                    // Error message
                    if let errorMessage = designsViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
            }
            .navigationTitle("Upload")
            .navigationBarTitleDisplayMode(.inline)
            .actionSheet(isPresented: $showingActionSheet) {
                ActionSheet(
                    title: Text("Select Image"),
                    buttons: [
                        .default(Text("Camera")) {
                            showingCamera = true
                        },
                        .default(Text("Photo Library")) {
                            showingImagePicker = true
                        },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
            }
            .sheet(isPresented: $showingCamera) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
            }
            .alert("Content Moderation", isPresented: $showingModerationAlert) {
                Button("OK") {
                    showingModerationAlert = false
                }
            } message: {
                Text(moderationMessage)
            }
        }
    }
    
    private var uploadButtonText: String {
        if contentModerator.isAnalyzing {
            return "Analyzing Content..."
        } else if designsViewModel.isUploading {
            return "Uploading..."
        } else {
            return "Upload Design"
        }
    }
    
    private var uploadButtonColor: Color {
        if contentModerator.isAnalyzing || designsViewModel.isUploading {
            return .gray
        } else if selectedImage != nil && !title.isEmpty {
            return .purple
        } else {
            return .gray
        }
    }
    
    private func uploadDesign() {
        guard let image = selectedImage else { return }
        
        Task {
            // First, moderate the content
            let moderationResult = await contentModerator.moderateContent(
                image: image,
                title: title,
                description: description.isEmpty ? nil : description
            )
            
            await MainActor.run {
                switch moderationResult {
                case .approved:
                    // Proceed with upload
                    proceedWithUpload(image: image)
                    
                case .rejected(let reason):
                    moderationMessage = reason
                    showingModerationAlert = true
                    
                case .needsReview(let reason):
                    moderationMessage = "\(reason)\n\nYour design will be reviewed by our team before being published."
                    showingModerationAlert = true
                    // Optionally, you could still upload but mark it for review
                    // proceedWithUpload(image: image, needsReview: true)
                }
            }
        }
    }
    
    private func proceedWithUpload(image: UIImage, needsReview: Bool = false) {
        let tagArray = tags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        Task {
            await designsViewModel.uploadDesign(
                title: title,
                description: description.isEmpty ? nil : description,
                image: image,
                tags: tagArray,
                needsReview: needsReview
            )
            
            if designsViewModel.errorMessage == nil {
                // Reset form on successful upload
                selectedImage = nil
                title = ""
                description = ""
                tags = ""
            }
        }
    }
}

// Helper extension for placeholder text
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct UploadView_Previews: PreviewProvider {
    static var previews: some View {
        UploadView()
            .environmentObject(DesignsViewModel())
    }
} 