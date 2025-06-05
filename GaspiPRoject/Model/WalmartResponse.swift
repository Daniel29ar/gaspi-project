//
//  WalmartResponse.swift
//  GaspiPRoject
//
//  Created by Daniel Enrique Vergara Cornelio on 5/06/25.
//

// MARK: - WalmartResponse Model
struct WalmartResponse: Decodable {
    let item: Item?
}

struct Item: Decodable {
    let props: Props?
}

struct Props: Decodable {
    let pagePros: PageProps?
    
    enum CodingKeys: String, CodingKey {
        case pagePros = "pageProps"
    }
}

struct PageProps: Decodable {
    let initialData: InitialData?
    
    enum CodingKeys: String, CodingKey {
        case initialData = "initialData"
    }
}

struct InitialData: Decodable {
    let searchResult: SearchResult?
    
    enum CodingKeys: String, CodingKey {
        case searchResult = "searchResult"
    }
}

struct SearchResult: Decodable {
    let itemStacks: [ItemStacks]
    
    enum CodingKeys: String, CodingKey {
        case itemStacks = "itemStacks"
    }
}

struct ItemStacks: Decodable {
    let items: [ItemProduct]
}

struct ItemProduct: Decodable {
    let name: String?
    let image: String?
    let priceInfo: PriceInfo?
    
    enum CodingKeys: String, CodingKey {
        case name
        case priceInfo = "priceInfo"
        case image
    }
}

struct PriceInfo: Decodable {
    let linePrice: String?
    
    enum CodingKeys: String, CodingKey {
        case linePrice = "linePrice"
    }
}
