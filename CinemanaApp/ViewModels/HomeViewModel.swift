import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var featuredMedia: Media?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchResults: [Media] = []
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
                }
            }, receiveValue: { [weak self] categories in
                self?.categories = categories
                self?.featuredMedia = categories.first?.items.first
            })
            .store(in: &cancellables)
    }

    private func setupSearch() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .flatMap { [weak self] query -> AnyPublisher<[Media], Never> in
                guard let self = self else { return Just([]).eraseToAnyPublisher() }
                return self.network.search(query: query)
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            }
            .assign(to: &$searchResults)
    }
}
