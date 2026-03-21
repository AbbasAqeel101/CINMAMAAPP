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

    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: path)
    }

    var backdropURL: URL? {
        guard let path = backdropPath else { return nil }
        return URL(string: path)
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
