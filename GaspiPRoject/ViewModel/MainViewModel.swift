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
    @Published var searchResults: [Product] = []
    @Published var isSearching: Bool = false
    @Published var searchText: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        bindSearch()
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
    
    func search(query: String) {
        guard !query.isEmpty else { return }
        isSearching = true
        
        var components = URLComponents(string: "https://axesso-walmart-data-service.p.rapidapi.com/wlm/walmart-search-by-keyword")
        components?.queryItems = [
            URLQueryItem(name: "keyword", value: query),
            URLQueryItem(name: "page", value: "1"),
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
                self.searchResults.append(contentsOf: response.products)
            })
            .store(in: &cancellables)

    }
}
