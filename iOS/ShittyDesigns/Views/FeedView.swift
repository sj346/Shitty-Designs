import SwiftUI

struct FeedView: View {
    @EnvironmentObject var designsViewModel: DesignsViewModel
    @State private var selectedDesign: Design?
    @State private var showingDetail = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                if designsViewModel.isLoading {
                    ProgressView("Loading designs...")
                        .scaleEffect(1.2)
                } else if designsViewModel.designs.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "paintbrush.pointed")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No designs yet!")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        Text("Be the first to upload your masterpiece!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(designsViewModel.designs) { design in
                                DesignCard(design: design)
                                    .onTapGesture {
                                        selectedDesign = design
                                        showingDetail = true
                                    }
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                    .refreshable {
                        await Task {
                            designsViewModel.fetchDesigns()
                        }
                    }
                }
            }
            .navigationTitle("ShittyDesigns")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingDetail) {
                if let design = selectedDesign {
                    DesignDetailView(design: design)
                        .environmentObject(designsViewModel)
                }
            }
        }
    }
}

struct DesignCard: View {
    let design: Design
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Design image
            AsyncImage(url: URL(string: design.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.8)
                    )
            }
            .frame(height: 200)
            .clipped()
            .cornerRadius(12)
            
            // Design info
            VStack(alignment: .leading, spacing: 4) {
                Text(design.title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                Text("by \(design.userName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                        Text("\(design.likesCount)")
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "message.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text("\(design.commentsCount)")
                            .font(.caption)
                    }
                }
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
            .environmentObject(DesignsViewModel())
    }
} 