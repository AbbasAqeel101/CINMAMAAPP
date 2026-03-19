import Foundation
import Combine

// MARK: - Network Manager
class NetworkManager: ObservableObject {
    static let shared = NetworkManager()

    // ⚠️ غيّر هذا الرابط لرابط API الخاص بك
    private let baseURL = "https://your-api.com/api/v1"

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Generic Fetch
    func fetch<T: Codable>(_ endpoint: String) -> AnyPublisher<T, Error> {
        guard let url = URL(string: baseURL + endpoint) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // MARK: - POST
    func post<T: Codable, B: Codable>(_ endpoint: String, body: B) -> AnyPublisher<T, Error> {
        guard let url = URL(string: baseURL + endpoint) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)

        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Endpoints
extension NetworkManager {
    // الصفحة الرئيسية
    func fetchHome() -> AnyPublisher<[Category], Error> {
        // مؤقتاً نرجع بيانات وهمية - استبدلها بـ API حقيقي
        return Just(MockData.categories)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    // البحث
    func search(query: String) -> AnyPublisher<[Media], Error> {
        return Just(MockData.allMedia.filter {
            $0.title.lowercased().contains(query.lowercased())
        })
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
}

// MARK: - Mock Data (للتطوير - استبدلها بـ API حقيقي)
struct MockData {
    static let allMedia: [Media] = [
        Media(id: 1, title: "Inception", titleAr: "بداية", overview: "فيلم خيال علمي رائع", posterPath: "https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg", backdropPath: "https://image.tmdb.org/t/p/w1280/s3TBrRGB1iav7gFOCNx3H31MoES.jpg", releaseDate: "2010", rating: 8.8, type: .movie, genres: ["خيال علمي", "إثارة"], streamURL: nil),
        Media(id: 2, title: "The Dark Knight", titleAr: "فارس الظلام", overview: "باتمان يواجه الجوكر", posterPath: "https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg", backdropPath: "https://image.tmdb.org/t/p/w1280/hkBaDkMWbLaf8B1lsWsKX7Ew3Xq.jpg", releaseDate: "2008", rating: 9.0, type: .movie, genres: ["أكشن", "جريمة"], streamURL: nil),
        Media(id: 3, title: "Breaking Bad", titleAr: "كسر قواعد اللعبة", overview: "معلم كيمياء يتحول لتاجر مخدرات", posterPath: "https://image.tmdb.org/t/p/w500/ggFHVNu6YYI5L9pCfOacjizRGt.jpg", backdropPath: nil, releaseDate: "2008", rating: 9.5, type: .series, genres: ["دراما", "جريمة"], streamURL: nil),
        Media(id: 4, title: "Interstellar", titleAr: "بين النجوم", overview: "رحلة عبر الزمن والفضاء", posterPath: "https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg", backdropPath: nil, releaseDate: "2014", rating: 8.6, type: .movie, genres: ["خيال علمي", "مغامرة"], streamURL: nil),
        Media(id: 5, title: "Game of Thrones", titleAr: "صراع العروش", overview: "معركة العروش والممالك", posterPath: "https://image.tmdb.org/t/p/w500/u3bZgnGQ9T01sWNhyveQz0wH0Hl.jpg", backdropPath: nil, releaseDate: "2011", rating: 9.2, type: .series, genres: ["فانتازيا", "دراما"], streamURL: nil),
        Media(id: 6, title: "Avatar", titleAr: "أفاتار", overview: "عالم باندورا السحري", posterPath: "https://image.tmdb.org/t/p/w500/jRXYjXNq0Cs2TcJjLkki24MLp7u.jpg", backdropPath: nil, releaseDate: "2009", rating: 7.8, type: .movie, genres: ["خيال علمي", "مغامرة"], streamURL: nil),
    ]

    static let categories: [Category] = [
        Category(title: "🔥 الأكثر مشاهدة", items: Array(allMedia.prefix(4))),
        Category(title: "🎬 أفلام", items: allMedia.filter { $0.type == .movie }),
        Category(title: "📺 مسلسلات", items: allMedia.filter { $0.type == .series }),
        Category(title: "⭐️ الأعلى تقييماً", items: allMedia.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }),
    ]
}
