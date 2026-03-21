import Foundation
import Combine
 
// MARK: - Network Manager
class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
 
    private let baseURL = "https://h5-api.aoneroom.com/wefeed-h5api-bff"
 
    // MARK: - Generic Fetch
    func fetch<T: Codable>(_ endpoint: String, params: [String: String] = [:]) -> AnyPublisher<T, Error> {
        var components = URLComponents(string: baseURL + endpoint)
        if !params.isEmpty {
            components?.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
 
        guard let url = components?.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
 
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("ar", forHTTPHeaderField: "i18n_lang")
 
        if let token = UserDefaults.standard.string(forKey: "mb_token") {
            request.setValue(token, forHTTPHeaderField: "mb_token")
        }
 
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
 
// MARK: - Endpoints
extension NetworkManager {
 
    func fetchHome() -> AnyPublisher<HomeResponse, Error> {
        return fetch("/home")
    }
 
    func search(query: String, page: Int = 1) -> AnyPublisher<SearchResponse, Error> {
        return fetch("/subject/search", params: ["keyword": query, "page": "\(page)", "size": "20"])
    }
 
    func fetchTrending(page: Int = 1) -> AnyPublisher<MediaListResponse, Error> {
        return fetch("/subject/trending", params: ["page": "\(page)", "size": "20"])
    }
 
    func fetchDetail(id: String) -> AnyPublisher<DetailResponse, Error> {
        return fetch("/subject/detail", params: ["id": id])
    }
 
    func fetchRanking(type: String = "movie") -> AnyPublisher<MediaListResponse, Error> {
        return fetch("/ranking-list/content", params: ["type": type])
    }
 
    func fetchFiltered(type: String = "movie", page: Int = 1) -> AnyPublisher<MediaListResponse, Error> {
        return fetch("/subject/filter", params: ["type": type, "page": "\(page)", "size": "20"])
    }
}
 
// MARK: - Response Models
struct HomeResponse: Codable {
    let code: Int?
    let data: HomeData?
}
 
struct HomeData: Codable {
    let banners: [APIMedia]?
    let sections: [HomeSection]?
}
 
struct HomeSection: Codable {
    let title: String?
    let items: [APIMedia]?
}
 
struct SearchResponse: Codable {
    let code: Int?
    let data: SearchData?
}
 
struct SearchData: Codable {
    let total: Int?
    let list: [APIMedia]?
}
 
struct MediaListResponse: Codable {
    let code: Int?
    let data: MediaListData?
}
 
struct MediaListData: Codable {
    let total: Int?
    let list: [APIMedia]?
}
 
struct DetailResponse: Codable {
    let code: Int?
    let data: APIMedia?
}
 
// MARK: - API Media Model
struct APIMedia: Codable, Identifiable, Hashable {
    let id: String?
    let title: String?
    let titleAr: String?
    let cover: String?
    let backdrop: String?
    let description: String?
    let year: String?
    let score: Double?
    let type: String?
    let genres: [String]?
    let playUrl: String?
 
    enum CodingKeys: String, CodingKey {
        case id, title, cover, backdrop, description, year, score, type, genres
        case titleAr = "title_ar"
        case playUrl = "play_url"
    }
 
    var posterURL: URL? {
        guard let cover = cover else { return nil }
        if cover.hasPrefix("http") { return URL(string: cover) }
        return URL(string: "https://h5-static.aoneroom.com" + cover)
    }
 
    var backdropURL: URL? {
        guard let backdrop = backdrop else { return nil }
        if backdrop.hasPrefix("http") { return URL(string: backdrop) }
        return URL(string: "https://h5-static.aoneroom.com" + backdrop)
    }
 
    var displayTitle: String { titleAr ?? title ?? "" }
    var rating: Double? { score }
}
 
// MARK: - Mock Data (احتياطي)
struct MockData {
    static let allMedia: [APIMedia] = []
}
 