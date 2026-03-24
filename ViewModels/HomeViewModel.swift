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
        // إظهار البيانات الوهمية كبداية (Placeholders)
        loadFallback()
        // جلب البيانات الحقيقية
        loadHome()
        // إعداد البحث
        setupSearch()
    }

    func loadHome() {
        // لا نغير isLoading إلى true إذا كانت هناك بيانات fallback لكي لا تظهر دائرة التحميل فوق البيانات
        if categories.isEmpty { isLoading = true }
        
        network.fetchHome()
            .receive(on: DispatchQueue.main) // التأكد من التحديث على الخيط الرئيسي
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("❌ API Error: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] response in
                guard let self = self, 
                      let sections = response.data?.sections, 
                      !sections.isEmpty else { return }
                
                let cats = sections.compactMap { section -> APICategory? in
                    guard let title = section.title,
                          let items = section.items,
                          !items.isEmpty else { return nil }
                    return APICategory(title: title, items: items)
                }
                
                // تحديث البيانات الحقيقية ومسح الـ Fallback
                self.categories = cats
                self.featuredMedia = response.data?.banners?.first ?? cats.first?.items.first
            })
            .store(in: &cancellables)
    }

    private func setupSearch() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .map { query -> AnyPublisher<[APIMedia], Never> in
                if query.isEmpty {
                    return Just([]).eraseToAnyPublisher()
                }
                return self.network.search(query: query)
                    .map { $0.data?.list ?? [] }
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            }
            .switchToLatest() // 🔥 سحر سويفت: يلغي طلب البحث القديم إذا كتب المستخدم حرفاً جديداً
            .sink { [weak self] results in
                self?.searchResults = results
            }
            .store(in: &cancellables)
    }

    func loadFallback() {
        // كود الـ sampleMedia الخاص بك (يبقى كما هو كمرحلة مؤقتة)
        let sampleMedia = [
            APIMedia(id: "1", title: "Inception", titleAr: "بداية", cover: "https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg", backdrop: "https://image.tmdb.org/t/p/w1280/s3TBrRGB1iav7gFOCNx3H31MoES.jpg", description: "فيلم خيال علمي رائع", year: "2010", score: 8.8, type: "movie", genres: ["خيال علمي", "إثارة"], playUrl: nil)
        ]
        self.featuredMedia = sampleMedia.first
        self.categories = [
            APICategory(title: "🔥 مقترح لك", items: sampleMedia)
        ]
    }
}