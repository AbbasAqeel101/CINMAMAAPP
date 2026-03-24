import Foundation

// MARK: - Movie & Series Model
struct Media: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let titleAr: String?
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let rating: Double?
    let type: MediaType
    let genres: [String]?
    let streamURL: String?

    enum MediaType: String, Codable {
        case movie = "movie"
        case series = "series"
    }

    // 🔥 حل التشوه 1: دمج الرابط الأساسي مع المسار
    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        
        // إذا كان الرابط يأتي كاملاً من الـ API استخدمه مباشرة
        if path.contains("http") {
            return URL(string: path)
        }
        
        // إذا كان الرابط يحتاج سيرفر (مثل TMDB)، أضفه هنا، مثال:
        // let baseURL = "https://image.tmdb.org/t/p/w500"
        // return URL(string: baseURL + path)
        
        return URL(string: path) 
    }

    var backdropURL: URL? {
        guard let path = backdropPath else { return nil }
        if path.contains("http") { return URL(string: path) }
        return URL(string: path)
    }
    
    // 🔥 حل التشوه 2: معالجة القيم الفارغة برمجياً لتأمين الـ UI
    var displayTitle: String {
        return titleAr ?? title // يعرض العربي إذا وجد، وإلا الإنجليزي
    }
    
    var displayOverview: String {
        return overview ?? "الوصف غير متاح حالياً لهذا العمل."
    }
    
    var ratingString: String {
        if let rating = rating {
            return String(format: "%.1f ★", rating)
        }
        return "N/A"
    }
}

// MARK: - Category
struct Category: Identifiable {
    let id = UUID()
    let title: String
    let items: [Media]
}

// MARK: - User
struct User: Codable {
    let id: String
    let name: String
    let email: String
    let avatar: String?
    var subscriptionType: SubscriptionType

    enum SubscriptionType: String, Codable {
        case free = "free"
        case premium = "premium"
    }
}

// MARK: - API Response
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let message: String?
}