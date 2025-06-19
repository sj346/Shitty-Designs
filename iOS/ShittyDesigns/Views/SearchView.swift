import SwiftUI

struct SearchView: View {
    @EnvironmentObject var designsViewModel: DesignsViewModel
    @State private var searchText = ""
    @State private var selectedTag: String?
    
    private var filteredDesigns: [Design] {
        if searchText.isEmpty && selectedTag == nil {
            return designsViewModel.designs
        }
        
        return designsViewModel.designs.filter { design in
            let matchesSearch = searchText.isEmpty || 
                design.title.localizedCaseInsensitiveContains(searchText) ||
                design.description?.localizedCaseInsensitiveContains(searchText) == true
            
            let matchesTag = selectedTag == nil || design.tags.contains(selectedTag!)
            
            return matchesSearch && matchesTag
        }
    }
    
    private var allTags: [String] {
        Array(Set(designsViewModel.designs.flatMap { $0.tags })).sorted()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                SearchBar(text: $searchText)
                    .padding()
                
                // Tags filter
                if !allTags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            TagButton(
                                title: "All",
                                isSelected: selectedTag == nil
                            ) {
                                selectedTag = nil
                            }
                            
                            ForEach(allTags, id: \.self) { tag in
                                TagButton(
                                    title: tag,
                                    isSelected: selectedTag == tag
                                ) {
                                    selectedTag = selectedTag == tag ? nil : tag
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)
                }
                
                // Results
                if filteredDesigns.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No designs found")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        Text("Try adjusting your search or browse all designs")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 8),
                            GridItem(.flexible(), spacing: 8)
                        ], spacing: 8) {
                            ForEach(filteredDesigns) { design in
                                DesignCard(design: design)
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search designs...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct TagButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.purple : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(DesignsViewModel())
    }
} 