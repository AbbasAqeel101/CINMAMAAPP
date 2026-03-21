import SwiftUI
import AVKit

struct PlayerView: View {
    let media: Media
    @Environment(\.dismiss) private var dismiss
    @State private var player: AVPlayer?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let player = player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
                    .onAppear { player.play() }
                    .onDisappear { player.pause() }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white.opacity(0.5))
                    Text("لا يوجد رابط مشاهدة")
                        .foregroundColor(.gray)
                    Text("أضف رابط الفيديو في streamURL")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.6))
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(media.titleAr ?? media.title)
        .preferredColorScheme(.dark)
        .onAppear {
            if let urlString = media.streamURL, let url = URL(string: urlString) {
                player = AVPlayer(url: url)
            }
        }
    }
}
