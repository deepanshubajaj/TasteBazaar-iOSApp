//
//  CartManager.swift
//  Taste Bazaar
//
//  Created by Deepanshu Bajaj on 13/03/25.
//

import Foundation

class CartManager {
    static let shared = CartManager()
    
    private init() {}
    
    struct CartItem {
        let cuisineId: String
        let dishId: String
        let dishName: String
        let price: Double
        var quantity: Int
    }
    
    private var cartItems: [CartItem] = []
    
    func addToCart(cuisineId: String, dishId: String, dishName: String, price: Double) {
        if let index = cartItems.firstIndex(where: { $0.dishId == dishId }) {
            cartItems[index].quantity += 1
        } else {
            let newItem = CartItem(cuisineId: cuisineId, dishId: dishId, dishName: dishName, price: price, quantity: 1)
            cartItems.append(newItem)
        }
    }
    
    func addToCartFromMenu(cuisineId: String, dishId: String, dishName: String, price: Double, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.dishId == dishId }) {
            cartItems[index].quantity = quantity
        } else {
            let newItem = CartItem(cuisineId: cuisineId, dishId: dishId, dishName: dishName, price: price, quantity: quantity)
            cartItems.append(newItem)
        }
    }
    
    func deleteFromCart(cuisineId: String, dishId: String, dishName: String, price: Double, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.dishId == dishId }) {
            if quantity <= 0 {
                cartItems.remove(at: index)
            }
        } else {
            print("not removed")
        }
    }
    
    func getCartItems() -> [CartItem] {
        return cartItems
    }
    
    func clearCart() {
        cartItems.removeAll()
        print("🛒 Cart cleared successfully!")
    }
}

