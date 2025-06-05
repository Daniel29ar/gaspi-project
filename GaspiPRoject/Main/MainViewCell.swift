//
//  MainViewCell.swift
//  GaspiPRoject
//
//  Created by Daniel Enrique Vergara Cornelio on 5/06/25.
//
import UIKit
import Foundation

// MARK: - MainViewCell
class MainViewCell: UITableViewCell {
    private let pImageView = UIImageView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let labelStack = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        pImageView.translatesAutoresizingMaskIntoConstraints = false
        pImageView.layer.cornerRadius = 20
        pImageView.clipsToBounds = true
        pImageView.contentMode = .scaleAspectFill
        contentView.addSubview(pImageView)
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        priceLabel.font = .systemFont(ofSize: 14, weight: .regular)
        priceLabel.textColor = .gray
        
        labelStack.axis = .vertical
        labelStack.spacing = 4
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        labelStack.addArrangedSubview(titleLabel)
        labelStack.addArrangedSubview(priceLabel)
        contentView.addSubview(labelStack)
        
        NSLayoutConstraint.activate([
            pImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            pImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            pImageView.widthAnchor.constraint(equalToConstant: 40),
            pImageView.heightAnchor.constraint(equalToConstant: 40),
            
            labelStack.leadingAnchor.constraint(equalTo: pImageView.trailingAnchor, constant: 12),
            labelStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            labelStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with title: String, price: String? = nil, imageURL: String? = nil) {
        titleLabel.text = title
        priceLabel.text = price
        pImageView.image = nil
        
        if let imageURL = imageURL,
           var urlComponents = URLComponents(string: imageURL) {
            var queryItems: [URLQueryItem] = urlComponents.queryItems ?? []
            queryItems.append(URLQueryItem(name: "s", value: "60"))
            urlComponents.queryItems = queryItems
            
            if let url = urlComponents.url {
                let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                    guard let self else { return }
                    guard let data = data,
                          let image = UIImage(data: data) else {
                        self.setImage(nil)
                        return
                    }
                    DispatchQueue.global().async {
                        DispatchQueue.main.async {
                            self.setImage(image)
                        }
                    }
                }
                task.resume()
            } else {
                self.setImage(nil)
            }
        } else {
            self.setImage(nil)
        }
    }
    
    private func setImage(_ image: UIImage?) {
        if let image = image {
            self.pImageView.image = image
        } else {
            self.pImageView.image = UIImage(systemName: "magnifyingglass")
            self.pImageView.tintColor = .black
        }
    }
}
