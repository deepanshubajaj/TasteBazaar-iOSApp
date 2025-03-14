//
//  LanguageManager.swift
//  Taste Bazaar
//
//  Created by Deepanshu Bajaj on 13/03/25.
//

import Foundation

class LanguageManager {
    static let shared = LanguageManager()
    
    enum Language: String {
        case english = "en"
        case hindi = "hnd"
    }
    
    var currentLanguage: Language {
        get {
            let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
            return Language(rawValue: lang) ?? .english
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: "appLanguage")
        }
    }
    
    func localizedString(for key: String) -> String {
        let translations: [String: [Language: String]] = [
            "Home": [.english: "Home", .hindi: "होम"],
            "Top Dishes": [.english: "Top Dishes", .hindi: "प्रमुख व्यंजन"],
            "Move to Cart": [.english: "Move to Cart", .hindi: "कार्ट में जोड़ें"],
            "Rating": [.english: "Rating", .hindi: "रेटिंग"],
            "Cuisine": [.english: "Cuisine", .hindi: "व्यंजन"],
            "Order to be Placed!": [.english: "Order to be Placed!", .hindi: "आर्डर करना!"],
            "Order Summary": [.english: "Order Summary", .hindi: "आर्डर सारांश"],
            "Payment": [.english: "Payment", .hindi: "भुगतान"],
            "Do Payment": [.english: "Do Payment", .hindi: "भुगतान करें"],
            "Place Order": [.english: "Place Order", .hindi: "आर्डर दें"],
            "Order Confirmed Successfully !!": [.english: "Order Confirmed Successfully !!", .hindi: "ऑर्डर सफलतापूर्वक पुष्टि हो गया !!"],
            "Dismiss": [.english: "Dismiss", .hindi: "बंद करें"],
            "Your successful order consists": [.english: "Your successful order consists", .hindi: "आपके सफल ऑर्डर में शामिल हैं"],
            "⚠️ You cannot place this order as the cart is empty.": [.english: "⚠️ You cannot place this order as the cart is empty.", .hindi: "⚠️ आप इस ऑर्डर को नहीं दे सकते क्योंकि कार्ट खाली है।"],
            "Cart is Empty": [.english: "Cart is Empty !", .hindi: "कार्ट खाली है !"],
            "Please add items to your cart before proceeding to payment.": [.english: "Please add items to your cart before proceeding to payment.", .hindi: "कृपया भुगतान से पहले अपने कार्ट में आइटम जोड़ें।"],
            "OK": [.english: "OK", .hindi: "ठीक है"],
            "Order Failed": [.english: "Order Failed !", .hindi: "आर्डर विफल हो गया !"],
            "Card": [.english: "Card", .hindi: "कार्ड"],
            "UPI": [.english: "UPI", .hindi: "यूपीआई"],
            "COD": [.english: "COD", .hindi: "डिलीवरी पर भुगतान"],
            "payment mode selected, press the button below to place this order and pay the total amount of this order after delivery to the delivery person.": [.english: "payment mode selected, press the button below to place this order and pay the total amount of this order after delivery to the delivery person.", .hindi: "भुगतान का तरीका चुना गया है, इस आर्डर को देने के लिए नीचे दिए गए बटन को दबाएं और डिलीवरी के बाद डिलीवरी व्यक्ति को इस आर्डर की कुल राशि भुगतान करें।"],
            "payment done, press the buton below to place this order to get it delivered": [.english: "payment done, press the buton below to place this order to get it delivered.", .hindi: "भुगतान हो चुका है, इस आर्डर को देने के लिए नीचे दिए गए बटन को दबाएं और इसे डिलीवर करवाएं।"],
            "Order Details": [.english: "Order Details", .hindi: "आर्डर विवरण"],
            "Net Total": [.english: "Net Total", .hindi: "कुल योग"],
            "Grand Total": [.english: "Grand Total", .hindi: "कुल राशि"],
            "CGST 2.5%": [.english: "CGST 2.5%", .hindi: "सीजीएसटी 2.5%"],
            "SGST 2.5%": [.english: "SGST 2.5%", .hindi: "एसजीएसटी 2.5%"],
            "Price": [.english: "Price", .hindi: "कीमत"],
            "Min Price": [.english: "Min Price", .hindi: "न्यूनतम कीमत"],
            "Max Price": [.english: "Max Price", .hindi: "अधिकतम कीमत"],
            "Min Rating": [.english: "Min Rating", .hindi: "न्यूनतम रेटिंग"],
            "Apply Filters": [.english: "Apply Filters", .hindi: "फ़िल्टर लागू करें"],
            "Add": [.english: "Add", .hindi: "जोड़ें"],
        ]
        
        return translations[key]?[currentLanguage] ?? key
    }
}

