//
//  MainViewModel.swift
//  GaspiPRoject
//
//  Created by Daniel Enrique Vergara Cornelio on 5/06/25.
//
import Foundation
import Combine

// MARK: - ViewModel
class MainViewModel {
    @Published var previousSearches: [String] = []
    @Published var searchResults: [Product] = []
    @Published var isSearching: Bool = false
    @Published var searchText: String = ""
    
    private(set) var currentPage: Int = 1
    private var canLoadMorePages = true
    
    private var cancellables = Set<AnyCancellable>()
    private let userDefaultsKey = "PreviousSearches"
    
    init() {
        loadPreviousSearches()
        bindSearch()
    }
}

// MARK: - Public Function
extension MainViewModel {
    
    func clearPreviousSearches() {
        previousSearches.removeAll()
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
    func search(query: String, reset: Bool = true) {
        guard !query.isEmpty else { return }
        isSearching = true
        
        if reset {
            currentPage = 1
            canLoadMorePages = true
            searchResults = []
        }
        
        var components = URLComponents(string: "https://axesso-walmart-data-service.p.rapidapi.com/wlm/walmart-search-by-keyword")
        components?.queryItems = [
            URLQueryItem(name: "keyword", value: query),
            URLQueryItem(name: "page", value: currentPage.description),
            URLQueryItem(name: "sortBy", value: "bestmatch")
        ]
        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("x-rapidapi-key", forHTTPHeaderField: "x-rapidapi-key")
        
        URLSession.shared.dataTaskPublisher(for: url)
            .handleEvents(receiveOutput: { output in
                if let jsonString = String(data: output.data, encoding: .utf8) {
                    print("🔍 JSON Response:\n\(jsonString)")
                }
            })
            .map { $0.data }
            .decode(type: WalmartResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                self.isSearching = false
                if case .failure(let error) = completion {
                    print("Search error: \(error)")
                }
            }, receiveValue: { [weak self] response in
                guard let self else { return }
                if reset {
                    self.searchResults = response.products
                } else {
                    self.searchResults.append(contentsOf: response.products)
                }
                self.canLoadMorePages = response.products.count < 20
                self.currentPage += 1
                self.storeSearch(query: query)
            })
            .store(in: &cancellables)
    }
}

// MARK: - Private Function
private extension MainViewModel {
    
    func bindSearch() {
        $searchText
            .debounce(for: .milliseconds(650), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] text in
                guard let self else { return }
                if text.isEmpty {
                    self.isSearching = false
                    self.searchResults = []
                } else {
                    self.search(query: text)
                }
            }
            .store(in: &cancellables)
    }
    
    func storeSearch(query: String) {
        if !previousSearches.contains(query){
            previousSearches.insert(query, at: 0)
            if previousSearches.count > 10 {
                previousSearches.removeLast()
            }
            UserDefaults.standard.set(previousSearches, forKey: userDefaultsKey)
        }
    }
    
    func loadPreviousSearches() {
        if let saved = UserDefaults.standard.stringArray(forKey: userDefaultsKey) {
            previousSearches = saved
        }
    }
}
