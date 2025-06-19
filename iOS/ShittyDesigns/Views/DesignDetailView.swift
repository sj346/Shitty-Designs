import SwiftUI

struct DesignDetailView: View {
    let design: Design
    @EnvironmentObject var designsViewModel: DesignsViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var commentText = ""
    @State private var showingReportSheet = false
    @State private var selectedReportReason = ""
    
    private let reportReasons = [
        "Inappropriate content",
        "Violence or gore",
        "Hate speech",
        "Copyright violation",
        "Spam",
        "Other"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Design image
                    AsyncImage(url: URL(string: design.imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                ProgressView()
                                    .scaleEffect(1.2)
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Title and author
                        VStack(alignment: .leading, spacing: 8) {
                            Text(design.title)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            HStack {
                                if let avatarURL = design.userAvatarURL {
                                    AsyncImage(url: URL(string: avatarURL)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Image(systemName: "person.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                }
                                
                                Text("by \(design.userName)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text(design.createdAt, style: .relative)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Description
                        if let description = design.description {
                            Text(description)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        
                        // Tags
                        if !design.tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(design.tags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.purple.opacity(0.1))
                                            .foregroundColor(.purple)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        
                        // Interaction buttons
                        HStack(spacing: 20) {
                            Button(action: {
                                Task {
                                    await designsViewModel.likeDesign(design)
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                    Text("\(design.likesCount)")
                                        .fontWeight(.medium)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Spacer()
                            
                            Button(action: {
                                showingReportSheet = true
                            }) {
                                Image(systemName: "flag.fill")
                                    .foregroundColor(.orange)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                // Share functionality
                                let activityVC = UIActivityViewController(
                                    activityItems: [design.title, URL(string: design.imageURL)!],
                                    applicationActivities: nil
                                )
                                
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let window = windowScene.windows.first {
                                    window.rootViewController?.present(activityVC, animated: true)
                                }
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.primary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.vertical, 8)
                        
                        Divider()
                        
                        // Add comment section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Add a comment")
                                .font(.headline)
                            
                            HStack {
                                TextField("Write a comment...", text: $commentText, axis: .vertical)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .lineLimit(1...3)
                                
                                Button(action: {
                                    if !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        Task {
                                            await designsViewModel.addComment(to: design, content: commentText)
                                            commentText = ""
                                        }
                                    }
                                }) {
                                    Text("Post")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.purple)
                                        .cornerRadius(8)
                                }
                                .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Design")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingReportSheet) {
                ReportView(
                    design: design,
                    reasons: reportReasons,
                    selectedReason: $selectedReportReason
                ) {
                    Task {
                        await designsViewModel.reportDesign(design, reason: selectedReportReason)
                        showingReportSheet = false
                    }
                }
            }
        }
    }
}

struct ReportView: View {
    let design: Design
    let reasons: [String]
    @Binding var selectedReason: String
    let onSubmit: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Image(systemName: "flag.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    
                    Text("Report Design")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Help us keep ShittyDesigns safe and appropriate for everyone.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reason for reporting:")
                        .font(.headline)
                    
                    ForEach(reasons, id: \.self) { reason in
                        Button(action: {
                            selectedReason = reason
                        }) {
                            HStack {
                                Image(systemName: selectedReason == reason ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedReason == reason ? .purple : .gray)
                                
                                Text(reason)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer()
                
                Button(action: {
                    onSubmit()
                }) {
                    Text("Submit Report")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedReason.isEmpty ? Color.gray : Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(selectedReason.isEmpty)
            }
            .padding()
            .navigationTitle("Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct DesignDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DesignDetailView(design: Design(
            title: "Sample Design",
            description: "This is a sample design description",
            imageURL: "https://example.com/image.jpg",
            userId: UUID(),
            userName: "Artist",
            tags: ["doodle", "sketch"]
        ))
        .environmentObject(DesignsViewModel())
    }
} 