import SwiftUI

struct DetailView: View {
    let media: APIMedia
    @State private var appear = false

    var body: some View {
        ZStack { Color.black.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .bottom) {
                        AsyncImage(url: media.backdropURL ?? media.posterURL) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: { Rectangle().fill(Color.gray.opacity(0.3)) }
                        .frame(height: 300).clipped()
                        LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom).frame(height: 150)
                    }.frame(height: 300)

                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(media.displayTitle).font(.system(size: 26, weight: .bold)).foregroundColor(.white)
                                if let title = media.title, media.titleAr != nil {
                                    Text(title).font(.system(size: 14)).foregroundColor(.gray)
                                }
                            }
                            Spacer()
                            if let rating = media.rating {
                                VStack(spacing: 2) {
                                    Image(systemName: "star.fill").foregroundColor(.yellow)
                                    Text(String(format: "%.1f", rating)).font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                                }
                            }
                        }

                        HStack(spacing: 12) {
                            if let year = media.year {
                                Label(year, systemImage: "calendar")
                            }
                            Label(media.type == "series" ? "مسلسل" : "فيلم",
                                  systemImage: media.type == "series" ? "tv" : "film")
                        }
                        .font(.system(size: 13)).foregroundColor(.gray)

                        if let genres = media.genres {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(genres, id: \.self) { genre in
                                        Text(genre).font(.system(size: 12, weight: .medium)).foregroundColor(.white)
                                            .padding(.horizontal, 12).padding(.vertical, 6)
                                            .background(Color.red.opacity(0.7)).cornerRadius(20)
                                    }
                                }
                            }
                        }

                        if let desc = media.description {
                            Text("القصة").font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                            Text(desc).font(.system(size: 15)).foregroundColor(.gray).lineSpacing(6)
                        }

                        NavigationLink { PlayerView(media: media) } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "play.fill")
                                Text("مشاهدة الآن").fontWeight(.bold)
                            }
                            .foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 52)
                            .background(Color.red).cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                    .padding(20)
                    .opacity(appear ? 1 : 0).offset(y: appear ? 0 : 20)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .onAppear { withAnimation(.easeOut(duration: 0.5)) { appear = true } }
    }
}
