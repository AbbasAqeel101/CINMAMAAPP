import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var categories: [APICategory] = []
    @Published var featuredMedia: APIMedia?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchResults: [APIMedia] = []
    @Published var searchQuery = ""

    private var cancellables = Set<AnyCancellable>()
    private let network = NetworkManager.shared

    init() {
        loadHome()
        setupSearch()
    }

    func loadHome() {
        isLoading = true
        network.fetchHome()
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    // بيانات احتياطية عند فشل الـ API
                    self?.loadFallback()
                }
            }, receiveValue: { [weak self] response in
                self?.isLoading = false
                if let sections = response.data?.sections {
                    self?.categories = sections.compactMap { section in
                        guard let title = section.title, let items = section.items else { return nil }
                        return APICategory(title: title, items: items)
                    }
                    self?.featuredMedia = response.data?.banners?.first ?? self?.categories.first?.items.first
                } else {
                    self?.loadFallback()
                }
            })
            .store(in: &cancellables)
    }

    private func loadFallback() {
        // بيانات احتياطية إذا فشل الـ API
        self.categories = [
            APICategory(title: "🔥 الأكثر مشاهدة", items: []),
            APICategory(title: "🎬 أفلام", items: []),
            APICategory(title: "📺 مسلسلات", items: []),
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
