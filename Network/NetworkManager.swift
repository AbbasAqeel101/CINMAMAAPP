import Foundation
import Combine

// MARK: - Network Manager
class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    // الرابط الأساسي للسيرفر
    private let baseURL = "https://h5-api.aoneroom.com/wefeed-h5api-bff"
    
    private init() {} // منع إنشاء نسخ أخرى (Singleton Pattern)

    // MARK: - Generic Fetch (محرك جلب البيانات)
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
        request.setValue("ar", forHTTPHeaderField: "i18n_lang") // لطلب البيانات باللغة العربية

        // جلب توكن المستخدم إذا كان مسجلاً
        if let token = UserDefaults.standard.string(forKey: "mb_token") {
            request.setValue(token, forHTTPHeaderField: "mb_token")
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data) // نأخذ البيانات فقط
            .decode(type: T.self, decoder: JSONDecoder()) // تحويل الـ JSON إلى Model
            .receive(on: DispatchQueue.main) // العودة للواجهة لتحديث الـ UI
            .eraseToAnyPublisher()
    }
}

// MARK: - Endpoints (جميع الطلبات التي يحتاجها تطبيق سينمانا)
extension NetworkManager {
    
    func fetchHome() -> AnyPublisher<HomeResponse, Error> {
        return fetch("/home")
    }

    func search(query: String, page: Int = 1) -> AnyPublisher<SearchResponse, Error> {
        return fetch("/subject/search", params: ["keyword": query, "page": "\(page)", "size": "20"])
    }

    func fetchDetail(id: String) -> AnyPublisher<DetailResponse, Error> {
        return fetch("/subject/detail", params: ["id": id])
    }
}

// MARK: - الـ Models اللازمة لفك تشفير البيانات (لازم تكون موجودة ليعمل الكود)

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

struct DetailResponse: Codable {
    let code: Int?
    let data: APIMedia?
}

struct SearchResponse: Codable {
    let code: Int?
    let data: SearchData?
}

struct SearchData: Codable {
    let list: [APIMedia]?
}