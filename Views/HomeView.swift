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
                            // 1. Featured Banner (معدل لثبات الأبعاد)
                            if let featured = vm.featuredMedia {
                                FeaturedBannerView(media: featured)
                            }

                            // 2. Categories (توزيع المسافات بانتظام)
                            VStack(spacing: 30) {
                                ForEach(vm.categories) { category in
                                    CategoryRowView(category: category)
                                }
                            }
                            .padding(.top, 20)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("سينمانا")
                        .font(.system(size: 26, weight: .black))
                        .foregroundStyle(
                            LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing)
                        )
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 20) {
                        Button { showSearch = true } label: {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .bold))
                        }
                        NavigationLink(destination: ProfileView()) {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 22))
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

// MARK: - Featured Banner (تم تحسين معالجة الصور والنصوص)
struct FeaturedBannerView: View {
    let media: Media
    @State private var appear = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Backdrop Image مع معالجة حالات التحميل
            AsyncImage(url: media.backdropURL ?? media.posterURL) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle().fill(Color.gray.opacity(0.2))
                }
            }
            .frame(height: 480)
            .frame(maxWidth: .infinity)
            .clipped()

            // تدرج لوني احترافي لضمان وضوح النصوص
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.4),
                    .init(color: .black.opacity(0.7), location: 0.7),
                    .init(color: .black, location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // تفاصيل العمل
            VStack(spacing: 16) {
                Text(media.titleAr ?? media.title)
                    .font(.system(size: 30, weight: .black))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .shadow(radius: 5)

                if let genres = media.genres {
                    Text(genres.joined(separator: " • "))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }

                HStack(spacing: 15) {
                    // زر المشاهدة
                    NavigationLink(destination: PlayerView(media: media)) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("مشاهدة")
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.white)
                        .cornerRadius(10)
                    }

                    // زر التفاصيل
                    NavigationLink(destination: DetailView(media: media)) {
                        HStack {
                            Image(systemName: "info.circle")
                            Text("التفاصيل")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.gray.opacity(0.4))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 30)
            }
            .padding(.bottom, 30)
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 20)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) { appear = true }
        }
    }
}

// MARK: - Category Row
struct CategoryRowView: View {
    let category: Category

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(category.title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(category.items) { media in
                        NavigationLink(destination: DetailView(media: media)) {
                            MediaCardView(media: media)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Media Card (الحل النهائي لمشكلة التشويه)
struct MediaCardView: View {
    let media: Media

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                // تثبيت أبعاد الصورة مهما كان المصدر
                AsyncImage(url: media.posterURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(Image(systemName: "film").foregroundColor(.gray))
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 115, height: 170)
                .clipped()
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 0.5))

                // التقييم فوق الصورة
                if let rating = media.rating, rating > 0 {
                    Text(String(format: "%.1f", rating))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.orange)
                        .cornerRadius(6)
                        .padding(6)
                }
            }

            // توحيد ارتفاع منطقة النص لمنع تذبذب الأسطر
            Text(media.titleAr ?? media.title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(width: 115, height: 35, alignment: .topLeading)
        }
        .frame(width: 115)
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
                .foregroundColor(.red.opacity(0.2))
                .overlay(
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(LinearGradient(colors: [.red, .orange], startPoint: .top, endPoint: .bottom), lineWidth: 3)
                        .rotationEffect(.degrees(animate ? 360 : 0))
                )
                .frame(width: 45, height: 45)
                .onAppear {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        animate = true
                    }
                }
            Text("يتم تجهيز السينما...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}