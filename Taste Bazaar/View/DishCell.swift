//
//  DishCell.swift
//  Taste Bazaar
//
//  Created by Deepanshu Bajaj on 17/02/25.
//

import UIKit

class DishCell: UICollectionViewCell {
    
    private var updatedQuantity: Int = 0
    
    // UI Components
    private let dishImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50 // Circular border
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.text = "0"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let minusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("−", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle( LanguageManager.shared.localizedString(for: "Add"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var addToCartActionFromMenu: (() -> Void)?
    var updateQuantityAction: ((Int) -> Void)?
    
    private var quantity: Int = 0 {
        didSet {
            quantityLabel.text = "\(quantity)"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(dishImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(minusButton)
        contentView.addSubview(quantityLabel)
        contentView.addSubview(plusButton)
        contentView.addSubview(addButton)
        
        setupConstraints()
        
        minusButton.addTarget(self, action: #selector(didTapMinusButton), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(didTapPlusButton), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Configure the cell with dish data
    func configure(with dish: Dish) {
        if let url = URL(string: dish.image_url) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.dishImageView.image = image
                    }
                }
            }
        }
        
        nameLabel.text = "\(dish.name)"
        priceLabel.text = "₹\(dish.price)"
        quantity = dish.quantity ?? 0 // Set initial quantity
        
    }
    
    // Set up constraints for UI components
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ImageView constraints
            dishImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            dishImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dishImageView.widthAnchor.constraint(equalToConstant: 100),
            dishImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // NameLabel constraints
            nameLabel.leadingAnchor.constraint(equalTo: dishImageView.trailingAnchor, constant: 15),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            
            // PriceLabel constraints
            priceLabel.leadingAnchor.constraint(equalTo: dishImageView.trailingAnchor, constant: 15),
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            
            // MinusButton constraints
            minusButton.leadingAnchor.constraint(equalTo: dishImageView.trailingAnchor, constant: 15),
            minusButton.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 10),
            minusButton.widthAnchor.constraint(equalToConstant: 30),
            minusButton.heightAnchor.constraint(equalToConstant: 30),
            
            // QuantityLabel constraints
            quantityLabel.leadingAnchor.constraint(equalTo: minusButton.trailingAnchor, constant: 10),
            quantityLabel.centerYAnchor.constraint(equalTo: minusButton.centerYAnchor),
            
            // PlusButton constraints
            plusButton.leadingAnchor.constraint(equalTo: quantityLabel.trailingAnchor, constant: 10),
            plusButton.centerYAnchor.constraint(equalTo: minusButton.centerYAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 30),
            plusButton.heightAnchor.constraint(equalToConstant: 30),
            
            // AddButton constraints
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
            addButton.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 10),
            addButton.widthAnchor.constraint(equalToConstant: 60),
            addButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    @objc private func didTapMinusButton() {
        if quantity > 0 {
            quantity -= 1
            updateQuantityAction?(quantity)
        }
    }
    
    @objc private func didTapPlusButton() {
        quantity += 1
        updateQuantityAction?(quantity)
    }
    
    @objc private func didTapAddButton() {
        addToCartActionFromMenu?()
        updatedQuantity = quantity
        updateQuantityAction?(quantity)
    }
}
