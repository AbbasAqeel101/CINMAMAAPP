import SwiftUI

struct SearchView: View {
    @ObservedObject var vm: HomeViewModel
    @Environment(\.dismiss) private var dismiss

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack {
                    if vm.searchQuery.isEmpty {
                        VStack(spacing: 12) {
                            Spacer()
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("ابحث عن فيلم أو مسلسل")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    } else if vm.searchResults.isEmpty {
                        VStack(spacing: 12) {
                            Spacer()
                            Image(systemName: "film.slash")
                                .font(.system(size: 50))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("لا توجد نتائج لـ \"\(vm.searchQuery)\"")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(vm.searchResults) { media in
                                    NavigationLink {
                                        DetailView(media: media)
                                    } label: {
                                        MediaCardView(media: media)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .searchable(text: $vm.searchQuery, prompt: "بحث...")
            .navigationTitle("البحث")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("إغلاق") { dismiss() }
                        .foregroundColor(.red)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
