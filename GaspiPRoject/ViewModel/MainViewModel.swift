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
        request.addValue("fce0e15738msh6a87c0c9db9505cp14b74fjsn54bc768f3bc7", forHTTPHeaderField: "x-rapidapi-key")
        
        URLSession.shared.dataTaskPublisher(for: request)
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
                var products: [Product] = []
                for itemStack in response.item?.props?.pagePros?.initialData?.searchResult?.itemStacks ?? [] {
                    for item in itemStack.items {
                        if let name = item.name,
                           let priceInfo = item.priceInfo,
                           let price = priceInfo.linePrice,
                           !price.isEmpty {
                            let product = Product(name: name,
                                                  price: price,
                                                  image: item.image ?? "")
                            products.append(product)
                        }
                    }
                }
                
                if reset {
                    self.searchResults = products
                } else {
                    self.searchResults.append(contentsOf: products)
                }
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
