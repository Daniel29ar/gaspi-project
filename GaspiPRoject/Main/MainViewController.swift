//
//  MainViewController.swift
//  GaspiPRoject
//
//  Created by Daniel Enrique Vergara Cornelio on 5/06/25.
//

import UIKit
import Combine

// MARK: - ViewController
class MainViewController: UIViewController {
    
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private var viewModel = MainViewModel()
    private var dataSource: [AnyHashable] = []
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
}

// MARK: - Private functions
private extension MainViewController {
    
    func setupUI() {
        title = "Buscar productos"
        view.backgroundColor = .white

        searchBar.placeholder = "Buscar..."
        searchBar.delegate = self
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.delegate = self
            textField.returnKeyType = .done
            textField.enablesReturnKeyAutomatically = false
        }
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupBindings() {
        viewModel.$searchText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                guard let self else { return }
                if text.isEmpty {
                    self.dataSource = self.viewModel.previousSearches
                    self.tableView.reloadData()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$searchResults
            .receive(on: DispatchQueue.main)
            .sink { [weak self] products in
                guard let self else { return }
                if !self.viewModel.searchText.isEmpty {
                    self.dataSource = products
                    self.tableView.reloadData()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$previousSearches
            .receive(on: DispatchQueue.main)
            .sink { [weak self] searches in
                guard let self else { return }
                if self.viewModel.searchText.isEmpty {
                    self.dataSource = searches
                    self.tableView.reloadData()
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - UITextFieldDelegate
extension MainViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

// MARK: - UISearchBarDelegate
extension MainViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText = searchText
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate
extension MainViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = dataSource[indexPath.row]
        if let search = item as? String {
            cell.textLabel?.text = "\(search)"
        } else if let product = item as? Product {
            cell.textLabel?.text = "\(product.name)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let search = dataSource[indexPath.row] as? String {
            searchBar.text = search
            viewModel.searchText = search
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        if offsetY > contentHeight - frameHeight * 1.5,
           !viewModel.isSearching,
           !viewModel.searchText.isEmpty {
            viewModel.search(query: viewModel.searchText, reset: false)
        }
    }
}
