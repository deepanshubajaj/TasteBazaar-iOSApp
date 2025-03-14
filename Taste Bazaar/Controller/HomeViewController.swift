//
//  HomeViewController.swift
//  Taste Bazaar
//
//  Created by Deepanshu Bajaj on 17/02/25.
//

import UIKit

class HomeViewController: UIViewController {
    
    private var dimmedView: UIView?
    private var bottomSheet: UIView?
    private var ribbonView: UIView?
    
    private let topDishesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // Create a horizontal scroll view for the cuisine categories
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    // Content view to hold all cards
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Cart button
    private let cartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Move to Cart", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.purple.withAlphaComponent(0.5)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        
        return button
    }()
    
    // Language toggle button
    private let languageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Lang: En", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.purple.withAlphaComponent(0.5)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        
        return button
    }()
    
    
    // Cuisine data
    private var cuisines: [Cuisine] = []
    
    // Top dishes data
    private var topDishes: [(Int, String, String, String, String)] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        
        // Ribbon view
        let ribbonView = addRibbonView(withTitle: LanguageManager.shared.localizedString(for: "Home"))
        view.addSubview(ribbonView)
        
        NSLayoutConstraint.activate([
            ribbonView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -40),
            ribbonView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ribbonView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ribbonView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Add the scroll view and content view for cuisine cards
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: ribbonView.bottomAnchor, constant: 16), // Position below the ribbon
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 220)
        ])
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        
        fetchCuisines()
        setupTopDishesSection()
        
        view.addSubview(cartButton)
        view.addSubview(languageButton)
        
        NSLayoutConstraint.activate([
            cartButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            cartButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cartButton.widthAnchor.constraint(equalToConstant: 120),
            cartButton.heightAnchor.constraint(equalToConstant: 50),
            
            languageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            languageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            languageButton.widthAnchor.constraint(equalToConstant: 120),
            languageButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        cartButton.addTarget(self, action: #selector(cartButtonPressed), for: .touchUpInside)
        languageButton.addTarget(self, action: #selector(languageButtonPressed), for: .touchUpInside)
        updateLanguageUI()
        
    }
    
    private func fetchCuisines() {
        let parameters: [String: Any] = [
            "page": 1,
            "count": 10
        ]
        
        APIManager.shared.postRequest(
            endpoint: "get_item_list",
            parameters: parameters,
            proxyAction: "get_item_list"
        ) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    // Print raw JSON for debugging
                    let jsonString = String(data: data, encoding: .utf8) ?? "Invalid JSON"
                    print("Raw API Response:\n\(jsonString)")
                    
                    // Decoding into the model
                    let response = try JSONDecoder().decode(CuisineResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.cuisines = response.cuisines
                        self.updateTopDishes()
                        self.setupCuisineCards()
                        self.setupTopDishesSection()
                    }
                } catch {
                    print("❌ Decoding Error: \(error.localizedDescription)")
                    print(error)
                }
            case .failure(let error):
                print("❌ Error fetching cuisines: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateTopDishes() {
        let allDishes = cuisines.flatMap { $0.items }
        
        let sortedDishes = allDishes.sorted {
            (Double($0.rating) ?? 0) > (Double($1.rating) ?? 0)
        }
        
        let topThreeDishes = sortedDishes.prefix(3)
        
        topDishes = topThreeDishes.map { (Int($0.id) ?? 0, $0.name, $0.image_url, "₹\($0.price)", $0.rating) }
        
        print("✅ Updated Top Dishes:", topDishes)
    }
    
    private func setupCuisineCards() {
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
        
        var previousCard: UIView? = nil
        for (index, cuisine) in cuisines.enumerated() {
            let cardView = createCardView(name: cuisine.cuisineName, imageURL: cuisine.cuisineImageURL)
            contentView.addSubview(cardView)

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cuisineCardTapped(_:)))
            cardView.addGestureRecognizer(tapGesture)
            cardView.isUserInteractionEnabled = true
            
            NSLayoutConstraint.activate([
                cardView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.9),
                cardView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
                cardView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
            
            if let previousCard = previousCard {
                cardView.leadingAnchor.constraint(equalTo: previousCard.trailingAnchor, constant: 16).isActive = true
            } else {
                cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
            }
            
            if index == cuisines.count - 1 {
                cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
            }
            
            previousCard = cardView
        }
        
        let totalWidth = CGFloat(cuisines.count) * 0.9 * view.frame.width + CGFloat(cuisines.count + 1) * 16
        scrollView.contentSize = CGSize(width: totalWidth, height: 220)
    }
    
    
    private func createCardView(name: String, imageURL: String) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.2
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Load image from URL
        if let url = URL(string: imageURL) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }
            }
        }
        
        let label = UILabel()
        label.text = name
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(imageView)
        cardView.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: cardView.heightAnchor, multiplier: 0.75)
        ])
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])
        
        return cardView
    }
    
    private func setupTopDishesSection() {
        topDishesLabel.text = LanguageManager.shared.localizedString(for: "Top Dishes")
        topDishesLabel.font = UIFont.boldSystemFont(ofSize: 24)
        topDishesLabel.textColor = .black
        topDishesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(topDishesLabel)
        
        NSLayoutConstraint.activate([
            topDishesLabel.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 16),
            topDishesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topDishesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        let topDishesStackView = UIStackView()
        topDishesStackView.axis = .horizontal
        topDishesStackView.spacing = 16
        topDishesStackView.alignment = .center
        topDishesStackView.distribution = .fillEqually
        topDishesStackView.translatesAutoresizingMaskIntoConstraints = false
        
        for (index, dish) in topDishes.enumerated() {
            let dishCard = createDishCard(name: dish.1, imageURL: dish.2, price: dish.3, rating: dish.4)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(topDishTapped(_:)))
            dishCard.tag = index // Store index for retrieval
            dishCard.addGestureRecognizer(tapGesture)
            dishCard.isUserInteractionEnabled = true
            
            topDishesStackView.addArrangedSubview(dishCard)
        }
        
        view.addSubview(topDishesStackView)
        
        NSLayoutConstraint.activate([
            topDishesStackView.topAnchor.constraint(equalTo: topDishesLabel.bottomAnchor, constant: 16),
            topDishesStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topDishesStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            topDishesStackView.heightAnchor.constraint(equalToConstant: 180)
        ])
    }
    
    private func createDishCard(name: String, imageURL: String, price: String, rating: String) -> UIView {
        let dishCard = UIView()
        dishCard.backgroundColor = .white
        dishCard.layer.cornerRadius = 12
        dishCard.layer.shadowColor = UIColor.black.cgColor
        dishCard.layer.shadowOpacity = 0.2
        dishCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        dishCard.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Load image from URL
        if let url = URL(string: imageURL) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }
            }
        }
        
        let addButton = UIButton()
        addButton.setTitle("+", for: .normal)
        addButton.setTitleColor(.black, for: .normal)
        addButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        addButton.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 250/255, alpha: 1.0)
        addButton.layer.cornerRadius = 12.5
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addDishToCart), for: .touchUpInside)
        addButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = UIFont.boldSystemFont(ofSize: 14)
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let priceLabel = UILabel()
        priceLabel.text = price
        priceLabel.font = UIFont.systemFont(ofSize: 12)
        priceLabel.textAlignment = .center
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let ratingLabel = UILabel()
        ratingLabel.text = LanguageManager.shared.localizedString(for: "Rating") + ": \(rating)"
        ratingLabel.font = UIFont.systemFont(ofSize: 11)
        ratingLabel.textAlignment = .center
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dishCard.addSubview(imageView)
        dishCard.addSubview(addButton)
        dishCard.addSubview(nameLabel)
        dishCard.addSubview(priceLabel)
        dishCard.addSubview(ratingLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: dishCard.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: dishCard.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: dishCard.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 120),
            
            addButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            addButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor, constant: -45),
            addButton.widthAnchor.constraint(equalToConstant: 50),
            addButton.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: dishCard.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: dishCard.trailingAnchor, constant: -8),
            
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: dishCard.leadingAnchor, constant: 8),
            priceLabel.trailingAnchor.constraint(equalTo: dishCard.trailingAnchor, constant: -8),
            
            ratingLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 4),
            ratingLabel.leadingAnchor.constraint(equalTo: dishCard.leadingAnchor, constant: 8),
            ratingLabel.trailingAnchor.constraint(equalTo: dishCard.trailingAnchor, constant: -8),
            
            dishCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 700)
        ])
        
        return dishCard
    }
    
    private func showDishBottomSheet(name: String, imageURL: String, price: String, rating: String) {
        let dimmedView = UIView()
        dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmedView.frame = view.bounds
        dimmedView.alpha = 0
        view.addSubview(dimmedView)
        self.dimmedView = dimmedView  // Store reference
        
        UIView.animate(withDuration: 0.3) {
            dimmedView.alpha = 1
        }
        
        let bottomSheet = UIView()
        bottomSheet.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 250/255, alpha: 1)
        bottomSheet.layer.cornerRadius = 16
        bottomSheet.layer.shadowColor = UIColor.black.cgColor
        bottomSheet.layer.shadowOpacity = 0.3
        bottomSheet.layer.shadowOffset = CGSize(width: 0, height: -2)
        bottomSheet.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomSheet)
        self.bottomSheet = bottomSheet // Store reference
        
        let bottomSheetHeight: CGFloat = 450
        let bottomSheetBottomConstraint = bottomSheet.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottomSheetHeight)
        
        NSLayoutConstraint.activate([
            bottomSheet.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSheet.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSheet.heightAnchor.constraint(equalToConstant: bottomSheetHeight),
            bottomSheetBottomConstraint
        ])
        
        UIView.animate(withDuration: 0.3) {
            bottomSheetBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        closeButton.addTarget(self, action: #selector(dismissBottomSheet), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        let dishImageView = UIImageView()
        dishImageView.contentMode = .scaleAspectFill
        dishImageView.clipsToBounds = true
        dishImageView.layer.cornerRadius = 10
        dishImageView.layer.borderWidth = 2
        dishImageView.layer.borderColor = UIColor.black.cgColor
        dishImageView.translatesAutoresizingMaskIntoConstraints = false
        
        if let url = URL(string: imageURL) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        dishImageView.image = image
                    }
                }
            }
        }
        
        let dishNameLabel = UILabel()
        dishNameLabel.text = name
        dishNameLabel.font = UIFont.boldSystemFont(ofSize: 25)
        dishNameLabel.textAlignment = .center
        dishNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let priceLabel = UILabel()
        priceLabel.text = LanguageManager.shared.localizedString(for: "Price") + ": \(price)"
        priceLabel.textColor = .darkGray
        priceLabel.font = UIFont.boldSystemFont(ofSize: 20)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let ratingLabel = UILabel()
        ratingLabel.text = "⭐ " + LanguageManager.shared.localizedString(for: "Rating") + ": \(rating)"
        ratingLabel.textColor = .systemOrange
        ratingLabel.font = UIFont.boldSystemFont(ofSize: 20)
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bottomSheet.addSubview(closeButton)
        bottomSheet.addSubview(dishImageView)
        bottomSheet.addSubview(dishNameLabel)
        bottomSheet.addSubview(priceLabel)
        bottomSheet.addSubview(ratingLabel)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: bottomSheet.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: bottomSheet.trailingAnchor, constant: -10),
            
            dishImageView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 10),
            dishImageView.centerXAnchor.constraint(equalTo: bottomSheet.centerXAnchor),
            dishImageView.widthAnchor.constraint(equalToConstant: 250),
            dishImageView.heightAnchor.constraint(equalToConstant: 250),
            
            dishNameLabel.topAnchor.constraint(equalTo: dishImageView.bottomAnchor, constant: 10),
            dishNameLabel.centerXAnchor.constraint(equalTo: bottomSheet.centerXAnchor),
            
            priceLabel.topAnchor.constraint(equalTo: dishNameLabel.bottomAnchor, constant: 5),
            priceLabel.centerXAnchor.constraint(equalTo: bottomSheet.centerXAnchor),
            
            ratingLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 5),
            ratingLabel.centerXAnchor.constraint(equalTo: bottomSheet.centerXAnchor)
        ])
    }
    
    
    @objc private func dismissBottomSheet() {
        guard let bottomSheet = self.bottomSheet else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            bottomSheet.transform = CGAffineTransform(translationX: 0, y: 450)
            bottomSheet.alpha = 0
            self.dimmedView?.alpha = 0
        }) { _ in
            bottomSheet.removeFromSuperview()
            self.bottomSheet = nil  // Clear reference
            
            self.dimmedView?.removeFromSuperview()
            self.dimmedView = nil
        }
    }
    
    @objc private func topDishTapped(_ sender: UITapGestureRecognizer) {
        guard let dishCard = sender.view, dishCard.tag < topDishes.count else { return }
        let selectedDish = topDishes[dishCard.tag]
        
        let itemId = selectedDish.0  // Get `itemId` directly as an Int
        
        print("Fetching details for Item ID: \(itemId)")
        
        LoaderManager.shared.showLoader(in: self.view)
        
        DispatchQueue.global().async {
            sleep(1)
            
            self.fetchItemDetails(itemId: itemId) { itemDetail in
                DispatchQueue.main.async {
                    LoaderManager.shared.hideLoader()
                    
                    guard let item = itemDetail else {
                        print("❌ Failed to fetch item details")
                        return
                    }

                    self.showDishBottomSheet(
                        name: item.itemName,
                        imageURL: item.itemImageURL,
                        price: "₹\(item.itemPrice)",
                        rating: "\(item.itemRating)"
                    )
                }
            }
        }
    }
    
    private func fetchItemDetails(itemId: Int, completion: @escaping (ItemDetailResponse?) -> Void) {
        let parameters: [String: Any] = ["item_id": itemId]
        
        APIManager.shared.postRequest(
            endpoint: "get_item_by_id",
            parameters: parameters,
            proxyAction: "get_item_by_id"
        ) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(ItemDetailResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(response)  // Return response
                    }
                } catch {
                    print("❌ Decoding Error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(nil)  // Return nil on failure
                    }
                }
            case .failure(let error):
                print("❌ API Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)  // Return nil on failure
                }
            }
        }
    }
    
    @objc private func cuisineCardTapped(_ sender: UITapGestureRecognizer) {
        if let cardView = sender.view,
           let label = cardView.subviews.first(where: { $0 is UILabel }) as? UILabel,
           let cuisine = cuisines.first(where: { $0.cuisineName == label.text }) {
            
            print("Cuisine Selected: \(cuisine.cuisineName)")
            
            let cuisineMenuVC = CuisineMenuViewController(cuisineId: cuisine.cuisineID, cuisineName: cuisine.cuisineName, dishes: cuisine.items)
            let backButton = UIBarButtonItem()
            backButton.title = ""
            navigationItem.backBarButtonItem = backButton
            
            navigationController?.pushViewController(cuisineMenuVC, animated: true)
        } else {
            print("❌ Cuisine not found")
        }
    }
    
    @objc func addDishToCart(_ sender: UIButton) {
        guard let dishCard = sender.superview else { return }
        let dishIndex = dishCard.tag
        
        guard dishIndex < topDishes.count else { return }
        
        let selectedDish = topDishes[dishIndex]
        let dishId = String(selectedDish.0)
        let dishName = selectedDish.1
        let price = Double(selectedDish.3.replacingOccurrences(of: "₹", with: "")) ?? 0.0
        
        if let cuisine = cuisines.first(where: { $0.items.contains(where: { $0.id == dishId }) }) {
            let cuisineId = cuisine.cuisineID
        
            CartManager.shared.addToCart(cuisineId: cuisineId, dishId: dishId, dishName: dishName, price: price)
            
            print("Added to Cart: \(dishName) | Cuisine ID: \(cuisineId)")
        } else {
            print("❌ Could not find cuisine for dish: \(dishName)")
        }
    }
    
    @objc func cartButtonPressed() {
        print("🛒 Moving to Cart")
        
        let placeOrderVC = PlaceOrderViewController(cartItems: CartManager.shared.getCartItems())
        navigationController?.pushViewController(placeOrderVC, animated: true)
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
    }
    
    @objc func languageButtonPressed() {
        let newLanguage: LanguageManager.Language = (LanguageManager.shared.currentLanguage == .english) ? .hindi : .english
        LanguageManager.shared.currentLanguage = newLanguage
        
        updateLanguageUI()
        
        notifyOtherViewControllers()
    }
    
    private func notifyOtherViewControllers() {
        NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
    }
    
    private func updateLanguageUI() {
        cartButton.setTitle(LanguageManager.shared.localizedString(for: "Move to Cart"), for: .normal)
        languageButton.setTitle(LanguageManager.shared.currentLanguage == .english ? "Lang: En" : "भाषा: हिंदी", for: .normal)
        topDishesLabel.text = LanguageManager.shared.localizedString(for: "Top Dishes")
        
        // Update the ribbon view text
        ribbonView?.removeFromSuperview() // Remove old ribbon
        let newRibbonView = addRibbonView(withTitle: LanguageManager.shared.localizedString(for: "Home"))
        view.addSubview(newRibbonView)
        
        NSLayoutConstraint.activate([
            newRibbonView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -40),
            newRibbonView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newRibbonView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newRibbonView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        ribbonView = newRibbonView
        refreshTopDishesSection()
    }
    
    private func refreshTopDishesSection() {
        for subview in view.subviews {
            if subview is UIStackView { // Remove old dish stack
                subview.removeFromSuperview()
            }
        }
        
        setupTopDishesSection()
    }
}
