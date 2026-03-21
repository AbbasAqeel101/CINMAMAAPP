import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    @State private var showSearch = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.black.ignoresSafeArea()

                if vm.isLoading {
                    LoadingView()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Featured Banner
                            if let featured = vm.featuredMedia {
                                FeaturedBannerView(media: featured)
                            }

                            // Categories
                            VStack(spacing: 24) {
                                ForEach(vm.categories) { category in
                                    CategoryRowView(category: category)
                                }
                            }
                            .padding(.top, 16)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("سينمانا")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing)
                        )
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button { showSearch = true } label: {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                                .font(.system(size: 18))
                        }
                        NavigationLink {
                            ProfileView()
                        } label: {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        }
                    }
                }
            }
            .sheet(isPresented: $showSearch) {
                SearchView(vm: vm)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Featured Banner
struct FeaturedBannerView: View {
    let media: Media
    @State private var appear = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Backdrop Image
            AsyncImage(url: media.backdropURL ?? media.posterURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle().fill(Color.gray.opacity(0.3))
            }
            .frame(height: 500)
            .clipped()

            // Gradient overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.3), .black],
                startPoint: .top,
                endPoint: .bottom
            )

            // Info
            VStack(spacing: 12) {
                Text(media.titleAr ?? media.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                if let genres = media.genres {
                    Text(genres.joined(separator: " • "))
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }

                HStack(spacing: 12) {
                    // زر مشاهدة
                    NavigationLink {
                        PlayerView(media: media)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "play.fill")
                            Text("مشاهدة")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.black)
                        .frame(width: 130, height: 44)
                        .background(Color.white)
                        .cornerRadius(8)
                    }

                    // زر تفاصيل
                    NavigationLink {
                        DetailView(media: media)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "info.circle")
                            Text("التفاصيل")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(width: 130, height: 44)
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 20)
        }
        .frame(height: 500)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { appear = true }
        }
    }
}

// MARK: - Category Row
struct CategoryRowView: View {
    let category: Category

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category.title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(category.items) { media in
                        NavigationLink {
                            DetailView(media: media)
                        } label: {
                            MediaCardView(media: media)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Media Card
struct MediaCardView: View {
    let media: Media

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: media.posterURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "film")
                                .foregroundColor(.gray)
                                .font(.system(size: 30))
                        )
                }
                .frame(width: 120, height: 180)
                .clipped()
                .cornerRadius(10)

                // Rating badge
                if let rating = media.rating {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9))
                        Text(String(format: "%.1f", rating))
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(6)
                    .padding(6)
                }
            }

            Text(media.titleAr ?? media.title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(2)
                .frame(width: 120, alignment: .leading)
        }
        .frame(width: 120)
    }
}

// MARK: - Loading View
struct LoadingView: View {
    @State private var animate = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Circle()
                .stroke(lineWidth: 3)
                .foregroundColor(.red.opacity(0.3))
                .overlay(
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(Color.red, lineWidth: 3)
                        .rotationEffect(.degrees(animate ? 360 : 0))
                )
                .frame(width: 50, height: 50)
                .onAppear {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        animate = true
                    }
                }
            Text("جاري التحميل...")
                .foregroundColor(.gray)
            Spacer()
        }
    }
}

#Preview {
    HomeView()
}
