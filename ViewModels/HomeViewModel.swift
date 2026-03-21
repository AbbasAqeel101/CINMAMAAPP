import Foundation
import Combine
 
class HomeViewModel: ObservableObject {
    @Published var categories: [APICategory] = []
    @Published var featuredMedia: APIMedia?
    @Published var isLoading = false
    @Published var searchResults: [APIMedia] = []
    @Published var searchQuery = ""
 
    private var cancellables = Set<AnyCancellable>()
    private let network = NetworkManager.shared
 
    init() {
        // أظهر البيانات التجريبية فوراً
        loadFallback()
        // ثم حاول تحميل البيانات الحقيقية
        loadHome()
        setupSearch()
    }
 
    func loadHome() {
        isLoading = true
        network.fetchHome()
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
            }, receiveValue: { [weak self] response in
                self?.isLoading = false
                if let sections = response.data?.sections, !sections.isEmpty {
                    let cats = sections.compactMap { section -> APICategory? in
                        guard let title = section.title,
                              let items = section.items,
                              !items.isEmpty else { return nil }
                        return APICategory(title: title, items: items)
                    }
                    if !cats.isEmpty {
                        self?.categories = cats
                        self?.featuredMedia = response.data?.banners?.first ?? cats.first?.items.first
                    }
                }
            })
            .store(in: &cancellables)
    }
 
    func loadFallback() {
        let sampleMedia = [
            APIMedia(id: "1", title: "Inception", titleAr: "بداية", cover: "https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg", backdrop: "https://image.tmdb.org/t/p/w1280/s3TBrRGB1iav7gFOCNx3H31MoES.jpg", description: "فيلم خيال علمي رائع", year: "2010", score: 8.8, type: "movie", genres: ["خيال علمي", "إثارة"], playUrl: nil),
            APIMedia(id: "2", title: "The Dark Knight", titleAr: "فارس الظلام", cover: "https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg", backdrop: "https://image.tmdb.org/t/p/w1280/hkBaDkMWbLaf8B1lsWsKX7Ew3Xq.jpg", description: "باتمان يواجه الجوكر", year: "2008", score: 9.0, type: "movie", genres: ["أكشن", "جريمة"], playUrl: nil),
            APIMedia(id: "3", title: "Breaking Bad", titleAr: "كسر قواعد اللعبة", cover: "https://image.tmdb.org/t/p/w500/ggFHVNu6YYI5L9pCfOacjizRGt.jpg", backdrop: nil, description: "معلم كيمياء يتحول لتاجر مخدرات", year: "2008", score: 9.5, type: "series", genres: ["دراما", "جريمة"], playUrl: nil),
            APIMedia(id: "4", title: "Interstellar", titleAr: "بين النجوم", cover: "https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg", backdrop: nil, description: "رحلة عبر الزمن والفضاء", year: "2014", score: 8.6, type: "movie", genres: ["خيال علمي", "مغامرة"], playUrl: nil),
            APIMedia(id: "5", title: "Game of Thrones", titleAr: "صراع العروش", cover: "https://image.tmdb.org/t/p/w500/u3bZgnGQ9T01sWNhyveQz0wH0Hl.jpg", backdrop: nil, description: "معركة العروش والممالك", year: "2011", score: 9.2, type: "series", genres: ["فانتازيا", "دراما"], playUrl: nil),
            APIMedia(id: "6", title: "Avengers: Endgame", titleAr: "نهاية اللعبة", cover: "https://image.tmdb.org/t/p/w500/or06FN3Dka5tukK1e9sl16pB3iy.jpg", backdrop: nil, description: "المعركة النهائية لإنقاذ الكون", year: "2019", score: 8.4, type: "movie", genres: ["أكشن", "مغامرة"], playUrl: nil),
        ]
        self.featuredMedia = sampleMedia.first
        self.categories = [
            APICategory(title: "🔥 الأكثر مشاهدة", items: sampleMedia),
            APICategory(title: "🎬 أفلام", items: sampleMedia.filter { $0.type == "movie" }),
            APICategory(title: "📺 مسلسلات", items: sampleMedia.filter { $0.type == "series" }),
        ]
    }
 
    private func setupSearch() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .flatMap { [weak self] query -> AnyPublisher<[APIMedia], Never> in
                guard let self = self else { return Just([]).eraseToAnyPublisher() }
                return self.network.search(query: query)
                    .map { $0.data?.list ?? [] }
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            }
            .assign(to: &$searchResults)
    }
}
 
struct APICategory: Identifiable {
    let id = UUID()
    let title: String
    let items: [APIMedia]
}
 