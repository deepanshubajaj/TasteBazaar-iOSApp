//
//  CuisineMenuViewController.swift
//  Taste Bazaar
//
//  Created by Deepanshu Bajaj on 17/02/25.
//

import UIKit

class CuisineMenuViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate  {
    
    var dishes: [Dish] = []
    var cuisineChosen: String = ""
    var cuisineId: String = ""
    private var dimmedBackgroundView: UIView?
    private let ratingLabel = UILabel()
    let minPriceTextField = UITextField()
    let maxPriceTextField = UITextField()
    let ratingSlider = UISlider()
    
    // Collection view to display the dishes
    private var collectionView: UICollectionView!
    
    private let cartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Move to Cart", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        
        return button
    }()
    
    // Update the initializer to accept dishes
    init(cuisineId: String, cuisineName: String, dishes: [Dish]) {
        self.cuisineId = cuisineId
        self.cuisineChosen = cuisineName
        self.dishes = dishes
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("LanguageChanged"), object: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // Customize navigation bar appearance
        navigationController?.navigationBar.tintColor = .black
        
        // Ribbon view
        let ribbonView = self.addRibbonView(withTitle: "\(cuisineChosen) " + LanguageManager.shared.localizedString(for: "Cuisine"))
        view.addSubview(ribbonView)
        
        NSLayoutConstraint.activate([
            ribbonView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -40),
            ribbonView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ribbonView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ribbonView.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        let filterButton = UIButton(type: .custom)
        if let filterImage = UIImage(named: "filterImage") {
            filterButton.setImage(filterImage, for: .normal)
        } else {
            print("⚠️ Warning: filterImage not found in assets.")
        }
        
        filterButton.frame = CGRect(x: 0, y: 5, width: 50, height: 50)
        filterButton.contentMode = .scaleAspectFit
        filterButton.addTarget(self, action: #selector(filterImageTapped), for: .touchUpInside)
        

        customView.addSubview(filterButton)

        let customBarButton = UIBarButtonItem(customView: customView)
        navigationItem.rightBarButtonItem = customBarButton
        
        filterButton.layer.shadowColor = UIColor.white.cgColor
        filterButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        filterButton.layer.shadowRadius = 3
        filterButton.layer.shadowOpacity = 0.8

        setupCollectionView(below: ribbonView)
        view.addSubview(cartButton)
        
        NSLayoutConstraint.activate([
            cartButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cartButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            cartButton.widthAnchor.constraint(equalToConstant: 200),
            cartButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        cartButton.addTarget(self, action: #selector(cartButtonPressed), for: .touchUpInside)
        
        // Listen for language change notifications
        NotificationCenter.default.addObserver(self, selector: #selector(updateLanguageUI), name: NSNotification.Name("LanguageChanged"), object: nil)
        
        updateLanguageUI()
    }
    
    @objc func filterImageTapped() {
        print("Filter image clicked")

        let dimmedView = UIView(frame: view.bounds)
        dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent
        dimmedView.alpha = 0
        view.addSubview(dimmedView)
        self.dimmedBackgroundView = dimmedView
        
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
        
        let bottomSheetBottomConstraint = bottomSheet.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 500)
        NSLayoutConstraint.activate([
            bottomSheet.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSheet.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSheet.heightAnchor.constraint(equalToConstant: 300),
            bottomSheetBottomConstraint
        ])
        
        UIView.animate(withDuration: 0.3) {
            bottomSheetBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        closeButton.addTarget(self, action: #selector(dismissFilterBottomSheet), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        let cuisineLabel = UILabel()
        cuisineLabel.text = "\(cuisineChosen) 🔻"
        cuisineLabel.font = UIFont.boldSystemFont(ofSize: 22)
        cuisineLabel.textAlignment = .center
        cuisineLabel.translatesAutoresizingMaskIntoConstraints = false
        
        minPriceTextField.placeholder = LanguageManager.shared.localizedString(for: "Min Price")
        minPriceTextField.borderStyle = .roundedRect
        minPriceTextField.keyboardType = .numberPad
        minPriceTextField.translatesAutoresizingMaskIntoConstraints = false
        
        maxPriceTextField.placeholder = LanguageManager.shared.localizedString(for: "Max Price")
        maxPriceTextField.borderStyle = .roundedRect
        maxPriceTextField.keyboardType = .numberPad
        maxPriceTextField.translatesAutoresizingMaskIntoConstraints = false

        ratingLabel.text = LanguageManager.shared.localizedString(for: "Min Rating") + ": 0"
        ratingLabel.font = UIFont.systemFont(ofSize: 16)
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false

        ratingSlider.minimumValue = 0
        ratingSlider.maximumValue = 5
        ratingSlider.value = 0
        ratingSlider.addTarget(self, action: #selector(ratingChanged(_:)), for: .valueChanged)
        ratingSlider.translatesAutoresizingMaskIntoConstraints = false

        let applyButton = UIButton(type: .system)
        applyButton.setTitle(LanguageManager.shared.localizedString(for: "Apply Filters"), for: .normal)
        applyButton.backgroundColor = .systemOrange
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        applyButton.layer.cornerRadius = 8
        applyButton.addTarget(self, action: #selector(applyFilters), for: .touchUpInside)
        applyButton.translatesAutoresizingMaskIntoConstraints = false

        bottomSheet.addSubview(closeButton)
        bottomSheet.addSubview(cuisineLabel)
        bottomSheet.addSubview(minPriceTextField)
        bottomSheet.addSubview(maxPriceTextField)
        bottomSheet.addSubview(ratingLabel)
        bottomSheet.addSubview(ratingSlider)
        bottomSheet.addSubview(applyButton)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: bottomSheet.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: bottomSheet.trailingAnchor, constant: -10),
            
            cuisineLabel.topAnchor.constraint(equalTo: bottomSheet.topAnchor, constant: 20),
            cuisineLabel.centerXAnchor.constraint(equalTo: bottomSheet.centerXAnchor),
            
            minPriceTextField.topAnchor.constraint(equalTo: cuisineLabel.bottomAnchor, constant: 20),
            minPriceTextField.leadingAnchor.constraint(equalTo: bottomSheet.leadingAnchor, constant: 20),
            minPriceTextField.widthAnchor.constraint(equalToConstant: 120),
            
            maxPriceTextField.topAnchor.constraint(equalTo: cuisineLabel.bottomAnchor, constant: 20),
            maxPriceTextField.trailingAnchor.constraint(equalTo: bottomSheet.trailingAnchor, constant: -20),
            maxPriceTextField.widthAnchor.constraint(equalToConstant: 120),
            
            ratingLabel.topAnchor.constraint(equalTo: minPriceTextField.bottomAnchor, constant: 20),
            ratingLabel.leadingAnchor.constraint(equalTo: bottomSheet.leadingAnchor, constant: 20),
            
            ratingSlider.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 10),
            ratingSlider.leadingAnchor.constraint(equalTo: bottomSheet.leadingAnchor, constant: 20),
            ratingSlider.trailingAnchor.constraint(equalTo: bottomSheet.trailingAnchor, constant: -20),
            
            applyButton.topAnchor.constraint(equalTo: ratingSlider.bottomAnchor, constant: 20),
            applyButton.centerXAnchor.constraint(equalTo: bottomSheet.centerXAnchor),
            applyButton.widthAnchor.constraint(equalToConstant: 200),
            applyButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func dismissFilterBottomSheet() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.subviews.last?.transform = CGAffineTransform(translationX: 0, y: 300)
            self.dimmedBackgroundView?.alpha = 0
        }) { _ in
            self.view.subviews.last?.removeFromSuperview()
            self.dimmedBackgroundView?.removeFromSuperview()
            self.dimmedBackgroundView = nil
        }
    }
    
    @objc private func ratingChanged(_ sender: UISlider) {
        let roundedValue = round(sender.value * 10) / 10.0
        ratingLabel.text = LanguageManager.shared.localizedString(for: "Min Rating") + ": \(roundedValue)"
    }
    
    @objc private func applyFilters() {
        print("Applying Filters...")

        guard let minPriceText = minPriceTextField.text, let minPrice = Int(minPriceText),
              let maxPriceText = maxPriceTextField.text, let maxPrice = Int(maxPriceText) else {
            print("⚠️ Invalid price range input")
            return
        }
        
        let minRating = round(ratingSlider.value * 10) / 10.0

        let parameters: [String: Any] = [
            "cuisine_type": [cuisineChosen],
            "price_range": [
                "min_amount": minPrice,
                "max_amount": maxPrice
            ],
            "min_rating": minRating
        ]
        
        // Call API using APIManager
        APIManager.shared.postRequest(
            endpoint: "get_item_by_filter",
            parameters: parameters,
            proxyAction: "get_item_by_filter"
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    do {
                        // Print raw JSON for debugging
                        let jsonString = String(data: data, encoding: .utf8) ?? "Invalid JSON"
                        print("📝 Raw API Response:\n\(jsonString)")
                        
                        // Decode API response
                        let response = try JSONDecoder().decode(FilterResponse.self, from: data)
                        
                        if response.responseCode == 200 {
                            let filteredDishes = response.cuisines.first?.items ?? []

                            self.dishes = filteredDishes.map { filteredDish in
                                let matchingDish = self.dishes.first(where: { $0.id == String(filteredDish.id) })
                                return Dish(
                                    id: String(filteredDish.id),
                                    name: filteredDish.name,
                                    image_url: filteredDish.image_url,
                                    price: matchingDish?.price ?? "0",
                                    quantity: nil,
                                    rating: matchingDish?.rating ?? ""
                                )
                            }
                            
                            self.collectionView.reloadData()
                            self.dismissFilterBottomSheet()
                            print("Filters applied successfully")
                        } else {
                            print("❌ API Error: \(response.responseMessage)")
                        }
                    } catch {
                        print("❌ Decoding Error: \(error.localizedDescription)")
                        print(error)
                    }
                    
                case .failure(let error):
                    print("❌ API Request Failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func fetchItemDetails(itemId: String, completion: @escaping (ItemDetailResponse) -> Void) {
        let parameters: [String: Any] = ["item_id": itemId]
        
        APIManager.shared.postRequest(
            endpoint: "get_item_by_id",
            parameters: parameters,
            proxyAction: "get_item_by_id"
        ) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    // Print raw JSON response
                    let jsonString = String(data: data, encoding: .utf8) ?? "Invalid JSON"
                    print("Raw API Response:\n\(jsonString)")
                    
                    let response = try JSONDecoder().decode(ItemDetailResponse.self, from: data)
                    completion(response)
                } catch {
                    print("❌ Decoding Error: \(error.localizedDescription)")
                    print("❌ Full Error: \(error)")
                }
            case .failure(let error):
                print("❌ Error fetching item details: \(error.localizedDescription)")
            }
        }
    }

    private func setupCollectionView(below ribbonView: UIView) {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width - 20, height: 150)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(DishCell.self, forCellWithReuseIdentifier: "DishCell")
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: ribbonView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dishes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DishCell", for: indexPath) as! DishCell
        let dish = dishes[indexPath.row]
        cell.configure(with: dish)
        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.purple.withAlphaComponent(0.5) : UIColor(red: 230/255, green: 230/255, blue: 250/255, alpha: 1)
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        
        cell.updateQuantityAction = { [weak self] newQuantity in
            self?.dishes[indexPath.row].quantity = newQuantity
            print("Updated quantity for \(self?.dishes[indexPath.row].name ?? ""): \(newQuantity)")
        }
        
        cell.addToCartActionFromMenu = { [weak self] in
            guard let self = self else { return }
            
            let selectedDish = self.dishes[indexPath.row]
            let dishId = selectedDish.id
            let dishName = selectedDish.name
            let price = Double(selectedDish.price) ?? 0.0
            let quantity = selectedDish.quantity ?? 0

            if quantity > 0 {
                CartManager.shared.addToCartFromMenu(cuisineId: self.cuisineId, dishId: dishId, dishName: dishName, price: price, quantity: quantity)
                print("Added to Cart: \(dishName) | Quantity: \(quantity) | CuisineId: \(cuisineId)")
            } else {
                CartManager.shared.deleteFromCart(cuisineId: self.cuisineId, dishId: dishId, dishName: dishName, price: price, quantity: quantity)
                print("⚠️ Cannot add zero and negative quantity item to cart")
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedDish = dishes[indexPath.row]
  
        LoaderManager.shared.showLoader(in: self.view)

        DispatchQueue.global().async {
            sleep(1)
            
            DispatchQueue.main.async {
                LoaderManager.shared.hideLoader()
                self.showDishDetails(dish: selectedDish)
            }
        }
    }
    
    private func showDishDetails(dish: Dish) {
        collectionView.isUserInteractionEnabled = false
        cartButton.isUserInteractionEnabled = false

        let dimmedView = UIView()
        dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmedView.frame = view.bounds
        dimmedView.alpha = 0
        view.addSubview(dimmedView)
        self.dimmedBackgroundView = dimmedView
        
        UIView.animate(withDuration: 0.3) {
            dimmedView.alpha = 1
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ignoreTap))
        dimmedView.addGestureRecognizer(tapGesture)
        
        let bottomSheet = UIView()
        bottomSheet.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 250/255, alpha: 1)
        bottomSheet.layer.cornerRadius = 16
        bottomSheet.layer.shadowColor = UIColor.black.cgColor
        bottomSheet.layer.shadowOpacity = 0.3
        bottomSheet.layer.shadowOffset = CGSize(width: 0, height: -2)
        bottomSheet.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(bottomSheet)
        
        let bottomSheetBottomConstraint = bottomSheet.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 500)
        NSLayoutConstraint.activate([
            bottomSheet.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSheet.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSheet.heightAnchor.constraint(equalToConstant: 500),
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
        dishImageView.layer.cornerRadius = 15
        dishImageView.layer.borderWidth = 3
        dishImageView.layer.borderColor = UIColor.black.cgColor
        dishImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let dishNameLabel = UILabel()
        dishNameLabel.font = UIFont.boldSystemFont(ofSize: 22)
        dishNameLabel.textAlignment = .center
        dishNameLabel.translatesAutoresizingMaskIntoConstraints = false

        let priceLabel = UILabel()
        priceLabel.textColor = .darkGray
        priceLabel.font = UIFont.systemFont(ofSize: 20)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let ratingLabel = UILabel()
        ratingLabel.textColor = .systemOrange
        ratingLabel.font = UIFont.boldSystemFont(ofSize: 20)
        ratingLabel.layer.cornerRadius = 5
        ratingLabel.clipsToBounds = true
        ratingLabel.textAlignment = .center
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false

        bottomSheet.addSubview(closeButton)
        bottomSheet.addSubview(dishImageView)
        bottomSheet.addSubview(dishNameLabel)
        bottomSheet.addSubview(priceLabel)
        bottomSheet.addSubview(ratingLabel)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: bottomSheet.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: bottomSheet.trailingAnchor, constant: -10),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30)
        ])

        NSLayoutConstraint.activate([
            dishImageView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 15),
            dishImageView.centerXAnchor.constraint(equalTo: bottomSheet.centerXAnchor),
            dishImageView.widthAnchor.constraint(equalToConstant: 300),
            dishImageView.heightAnchor.constraint(equalToConstant: 300)
        ])

        NSLayoutConstraint.activate([
            dishNameLabel.topAnchor.constraint(equalTo: dishImageView.bottomAnchor, constant: 15),
            dishNameLabel.centerXAnchor.constraint(equalTo: bottomSheet.centerXAnchor)
        ])

        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: dishNameLabel.bottomAnchor, constant: 10),
            priceLabel.centerXAnchor.constraint(equalTo: bottomSheet.centerXAnchor)
        ])

        NSLayoutConstraint.activate([
            ratingLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 10),
            ratingLabel.centerXAnchor.constraint(equalTo: bottomSheet.centerXAnchor),
            ratingLabel.widthAnchor.constraint(equalToConstant: 150),
            ratingLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        // Fetch item details from API
        fetchItemDetails(itemId: dish.id) { fetchedDish in
            DispatchQueue.main.async {
                dishNameLabel.text = fetchedDish.itemName
                priceLabel.text = LanguageManager.shared.localizedString(for: "Price") + ": ₹\(fetchedDish.itemPrice)"
                ratingLabel.text = "⭐ " + LanguageManager.shared.localizedString(for: "Rating") + ": \(fetchedDish.itemRating)"
                
                if let url = URL(string: fetchedDish.itemImageURL) {
                    DispatchQueue.global().async {
                        if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                dishImageView.image = image
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func cartButtonPressed() {
        print("I am in Cart")

        let placeOrderVC = PlaceOrderViewController(cartItems: CartManager.shared.getCartItems())
        navigationController?.pushViewController(placeOrderVC, animated: true)
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
    }

    @objc private func ignoreTap() {
        // Do nothing, just prevent touches from reaching other views
    }
    
    @objc private func dismissBottomSheet() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.subviews.last?.transform = CGAffineTransform(translationX: 0, y: 300)
            self.dimmedBackgroundView?.alpha = 0
        }) { _ in
            self.view.subviews.last?.removeFromSuperview()
            self.dimmedBackgroundView?.removeFromSuperview()
            self.dimmedBackgroundView = nil
            
            // Re-enable interaction
            self.collectionView.isUserInteractionEnabled = true
            self.cartButton.isUserInteractionEnabled = true
        }
    }
    
    @objc private func updateLanguageUI() {
        cartButton.setTitle(LanguageManager.shared.localizedString(for: "Move to Cart"), for: .normal)
    }
}
