//
//  PlaceOrderViewController.swift
//  Taste Bazaar
//
//  Created by Deepanshu Bajaj on 17/02/25.
//

import UIKit

class PlaceOrderViewController: UIViewController {
    
    private var orderedDishes: [CartManager.CartItem] = []
    
    private var totalAmount: Double = 0.0
    private var grandTotal: Double = 0.0
    
    private let segmentControl: UISegmentedControl = {
        let control = UISegmentedControl(items: [LanguageManager.shared.localizedString(for: "Order Summary"), LanguageManager.shared.localizedString(for: "Payment")])
        control.selectedSegmentIndex = 0 // Default to Order Summary
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    init(cartItems: [CartManager.CartItem]) {
        self.orderedDishes = cartItems
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let orderDetailsLabel = PlaceOrderViewController.createLabel(text: "Order Details:\n")
    private let netTotalLabel = PlaceOrderViewController.createLabel(text: "Net Total: ₹0.00")
    private let taxLabel = PlaceOrderViewController.createLabel(text: "CGST 2.5%: ₹0.00 | SGST 2.5%: ₹0.00")
    private let grandTotalLabel = PlaceOrderViewController.createLabel(text: "Grand Total: ₹0.00", textColor: UIColor.red)
    
    // Payment Section
    private let paymentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let paymentMethodSegment: UISegmentedControl = {
        let control = UISegmentedControl(items: [LanguageManager.shared.localizedString(for: "Card"), LanguageManager.shared.localizedString(for: "UPI"), LanguageManager.shared.localizedString(for: "COD")])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let placeOrderButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Do Payment", for: .normal)
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
    
    private let paymentStatusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .black
        label.text = LanguageManager.shared.localizedString(for: "Card") + " " + LanguageManager.shared.localizedString(for: "payment done, press the buton below to place this order to get it delivered")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Warning Label when Cart is Empty
    private let cartEmptyWarningLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .red
        label.text = LanguageManager.shared.localizedString(for: "⚠️ You cannot place this order as the cart is empty.")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true // Hide initially
        return label
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("LanguageChanged"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .black
        
        // Add ribbon view
        let ribbonView = addRibbonView(withTitle: LanguageManager.shared.localizedString(for: "Order to be Placed!"))
        view.addSubview(ribbonView)
        
        NSLayoutConstraint.activate([
            ribbonView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -40),
            ribbonView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ribbonView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ribbonView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Adding UI Elements
        view.addSubview(segmentControl)
        view.addSubview(orderDetailsLabel)
        view.addSubview(netTotalLabel)
        view.addSubview(taxLabel)
        view.addSubview(grandTotalLabel)
        view.addSubview(cartEmptyWarningLabel)
        view.addSubview(paymentView)
        view.addSubview(placeOrderButton)
        
        // Segment Control Constraints
        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: ribbonView.bottomAnchor, constant: 10),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Order Details Constraints
        let summaryViews = [orderDetailsLabel, netTotalLabel, taxLabel, grandTotalLabel]
        for (index, label) in summaryViews.enumerated() {
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: index == 0 ? segmentControl.bottomAnchor : summaryViews[index-1].bottomAnchor, constant: 10),
                label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            ])
        }

        NSLayoutConstraint.activate([
            cartEmptyWarningLabel.topAnchor.constraint(equalTo: grandTotalLabel.bottomAnchor, constant: 10),
            cartEmptyWarningLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cartEmptyWarningLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        setupPaymentView()

        NSLayoutConstraint.activate([
            placeOrderButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeOrderButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            placeOrderButton.widthAnchor.constraint(equalToConstant: 200),
            placeOrderButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Adding Targets for Segmented Control and Place Order Button
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        placeOrderButton.addTarget(self, action: #selector(placeOrderTapped), for: .touchUpInside)
        
        updateOrderSummary()
        
        // Listen for language change notifications
        NotificationCenter.default.addObserver(self, selector: #selector(updateLanguageUI), name: NSNotification.Name("LanguageChanged"), object: nil)

        updateLanguageUI()
    }
    
    private func setupPaymentView() {
        view.addSubview(paymentView)
        paymentView.addSubview(paymentMethodSegment)
        paymentView.addSubview(paymentStatusLabel)
        
        NSLayoutConstraint.activate([
            paymentView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 20),
            paymentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            paymentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            paymentView.bottomAnchor.constraint(equalTo: placeOrderButton.topAnchor, constant: -20),
            
            paymentMethodSegment.centerXAnchor.constraint(equalTo: paymentView.centerXAnchor),
            paymentMethodSegment.topAnchor.constraint(equalTo: paymentView.topAnchor, constant: 10),
            paymentMethodSegment.widthAnchor.constraint(equalToConstant: 250),
            paymentMethodSegment.heightAnchor.constraint(equalToConstant: 40),
            
            paymentStatusLabel.topAnchor.constraint(equalTo: paymentMethodSegment.bottomAnchor, constant: 15),
            paymentStatusLabel.leadingAnchor.constraint(equalTo: paymentView.leadingAnchor, constant: 20),
            paymentStatusLabel.trailingAnchor.constraint(equalTo: paymentView.trailingAnchor, constant: -20),
        ])
        
        paymentMethodSegment.addTarget(self, action: #selector(paymentMethodChanged), for: .valueChanged)
    }
    
    // Update payment status label based on the selected payment method
    @objc private func paymentMethodChanged() {
        let selectedIndex = paymentMethodSegment.selectedSegmentIndex
        let paymentMethods = [LanguageManager.shared.localizedString(for: "Card"), LanguageManager.shared.localizedString(for: "UPI"), LanguageManager.shared.localizedString(for: "COD")]
        let selectedMethod = paymentMethods[selectedIndex]
        
        if selectedIndex == 2 {
            paymentStatusLabel.text = "\(selectedMethod) " + LanguageManager.shared.localizedString(for: "payment mode selected, press the button below to place this order and pay the total amount of this order after delivery to the delivery person.")
        } else {
            paymentStatusLabel.text = "\(selectedMethod) " + LanguageManager.shared.localizedString(for: "payment done, press the buton below to place this order to get it delivered")
        }
    }
    
    private func updateOrderSummary() {
        totalAmount = orderedDishes.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
        
        let cgst = totalAmount * 0.025
        let sgst = totalAmount * 0.025
        grandTotal = totalAmount + cgst + sgst
        
        orderDetailsLabel.text = LanguageManager.shared.localizedString(for: "Order Details") + ":\n" + orderedDishes.map {
            "\($0.dishName) - ₹\($0.price) x \($0.quantity) = ₹\(String(format: "%.2f", $0.price * Double($0.quantity)))"
        }.joined(separator: "\n")
        
        netTotalLabel.text = LanguageManager.shared.localizedString(for: "Net Total") + ": ₹\(String(format: "%.2f", totalAmount))"
        taxLabel.text = LanguageManager.shared.localizedString(for: "CGST 2.5%") + ": ₹\(String(format: "%.2f", cgst)) | " + LanguageManager.shared.localizedString(for: "SGST 2.5%") + ": ₹\(String(format: "%.2f", sgst))"
        grandTotalLabel.text = LanguageManager.shared.localizedString(for: "Grand Total") + ": ₹\(String(format: "%.2f", grandTotal))"

        cartEmptyWarningLabel.isHidden = !orderedDishes.isEmpty
    }
    
    
    // Handle segment change
    @objc private func segmentChanged() {
        
        if segmentControl.selectedSegmentIndex == 1 && orderedDishes.isEmpty {
            showCartEmptyAlert() // Show alert if cart is empty
            segmentControl.selectedSegmentIndex = 0 // Prevent navigation to Payment
            return
        }
        
        let isPaymentSelected = segmentControl.selectedSegmentIndex == 1
        orderDetailsLabel.isHidden = isPaymentSelected
        netTotalLabel.isHidden = isPaymentSelected
        taxLabel.isHidden = isPaymentSelected
        grandTotalLabel.isHidden = isPaymentSelected
        paymentView.isHidden = !isPaymentSelected
        
        placeOrderButton.setTitle(LanguageManager.shared.localizedString(for: isPaymentSelected ? "Place Order" : "Do Payment"), for: .normal)
    }
    
    @objc private func placeOrderTapped() {
        if orderedDishes.isEmpty {
            showCartEmptyAlert() // Show alert if cart is empty
            return
        }
        
        if segmentControl.selectedSegmentIndex == 0 {
            segmentControl.selectedSegmentIndex = 1
            segmentChanged()
        } else {
            placeOrderAPIRequest()
        }
    }
    
    private func showCartEmptyAlert() {
        let alert = UIAlertController(title: LanguageManager.shared.localizedString(for: "Cart is Empty"), message: LanguageManager.shared.localizedString(for: "Please add items to your cart before proceeding to payment."), preferredStyle: .alert)
        let okAction = UIAlertAction(title: LanguageManager.shared.localizedString(for: "OK"), style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    private func placeOrderAPIRequest() {
        let orderData: [[String: Any]] = orderedDishes.map { dish in
            [
                "cuisine_id": Int(dish.cuisineId) ?? 0,
                "item_id": Int(dish.dishId) ?? 0,
                "item_price": dish.price,
                "item_quantity": dish.quantity
            ]
        }
        
        let parameters: [String: Any] = [
            "total_amount": String(format: "%.2f", grandTotal),
            "total_items": orderedDishes.count,
            "data": orderData
        ]
        
        LoaderManager.shared.showLoader(in: self.view)
        
        // API Call
        APIManager.shared.postRequest(
            endpoint: "make_payment",
            parameters: parameters,
            proxyAction: "make_payment"
        ) { [weak self] (result: Result<Data, Error>) in
            DispatchQueue.main.async {
                LoaderManager.shared.hideLoader() // Hide loader after API response
                
                switch result {
                case .success(let data):
                    do {
                        
                        // Raw JSON for debugging
                        let jsonString = String(data: data, encoding: .utf8) ?? "Invalid JSON"
                        print("📝 Raw API Response:\n\(jsonString)")
                        
                        let response = try JSONDecoder().decode(PaymentResponse.self, from: data)
                        
                        if response.responseCode == 200 {
                            self?.showOrderConfirmationAlert() // Show success alert only on API success
                        } else {
                            self?.showErrorAlert(message: response.responseMessage)
                        }
                    } catch {
                        self?.showErrorAlert(message: "Failed to process the order.")
                        print("❌ Decoding Error: \(error)")
                    }
                    
                case .failure(let error):
                    self?.showErrorAlert(message: "Network error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: LanguageManager.shared.localizedString(for: "Order Failed"), message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: LanguageManager.shared.localizedString(for: "OK"), style: .default)
        alert.addAction(dismissAction)
        present(alert, animated: true)
    }
    
    private func showOrderConfirmationAlert() {
        let alert = UIAlertController(title: nil, message: "\n\n\n\n" + LanguageManager.shared.localizedString(for: "Order Confirmed Successfully !!"), preferredStyle: .alert)
        
        if let backgroundView = alert.view.subviews.first?.subviews.first?.subviews.first {
            backgroundView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 250/255, alpha: 1)
        }
        
        let imageView = UIImageView(frame: CGRect(x: 80, y: 10, width: 100, height: 100))
        imageView.image = UIImage(named: "successThumb")
        imageView.contentMode = .scaleAspectFit
        alert.view.addSubview(imageView)
        
        let dismissAction = UIAlertAction(title: LanguageManager.shared.localizedString(for: "Dismiss"), style: .default) { _ in
            self.showOrderDetailsAlert()
        }

        dismissAction.setValue(UIColor.black, forKey: "titleTextColor")
        
        alert.addAction(dismissAction)
        present(alert, animated: true)
    }
    
    private func showOrderDetailsAlert() {
        let orderDetails = orderedDishes.map { "\($0.dishName): ₹\($0.price)" }.joined(separator: "\n")
        let total = grandTotalLabel.text ?? "Total: ₹0.00"
        let alert = UIAlertController(title: LanguageManager.shared.localizedString(for: "Your successful order consists") + ": \n", message: "\(orderDetails)\n\n\(total)", preferredStyle: .alert)
        
        if let backgroundView = alert.view.subviews.first?.subviews.first?.subviews.first {
            backgroundView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 250/255, alpha: 1)
        }
        
        let dismissAction = UIAlertAction(title: LanguageManager.shared.localizedString(for: "Dismiss"), style: .default) { _ in
            CartManager.shared.clearCart()
            self.navigationController?.popToRootViewController(animated: true)
        }

        dismissAction.setValue(UIColor.black, forKey: "titleTextColor")
        
        alert.addAction(dismissAction)
        present(alert, animated: true)
    }
    
    static func createLabel(text: String, textColor: UIColor = .black) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = text
        label.textColor = textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    @objc private func updateLanguageUI() {
        segmentControl.setTitle(LanguageManager.shared.localizedString(for: "Order Summary"), forSegmentAt: 0)
        segmentControl.setTitle(LanguageManager.shared.localizedString(for: "Payment"), forSegmentAt: 1)
        
        // Update button title dynamically based on selected segment
        let isPaymentSelected = segmentControl.selectedSegmentIndex == 1
        placeOrderButton.setTitle(LanguageManager.shared.localizedString(for: isPaymentSelected ? "Place Order" : "Do Payment"), for: .normal)

        view.setNeedsLayout()
    }
}
