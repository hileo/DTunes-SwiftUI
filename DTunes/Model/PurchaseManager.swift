//
//  PurchaseManager.swift
//  DTunes
//
//  Created by OllyWang on 4/1/26.
//

import StoreKit
import Combine

enum ProductID: String {
    case yearly     = "com.gogoapp.dtunes.year"
    case lifetime   =  "com.gogoapp.dtunes.lifetime"
    case lifetimeV2 = "com.gogoapp.dtunes.lifetimeV2"
}

@MainActor
final class PurchaseManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var isPro: Bool = false
    @Published var counter:Int = 0
    @Published var isPurchasing: Bool = false
    
    var productIDs = [
        ProductID.lifetimeV2.rawValue,
        ProductID.yearly.rawValue
    ]
    
    init() {
        Task {
            await loadProducts()
            await updateCustomerStatus()
            listenForTransactions()
        }
    }
    
    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            print("加载商品失败: \(error)")
        }
    }
    
    func updateCustomerStatus() async {
        var hasLifetime = false
        var hasSubscription = false
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
//            print("加载商品 : \(transaction.productID)")
            
            switch transaction.productID {
            case ProductID.lifetime.rawValue, ProductID.lifetimeV2.rawValue:
                hasLifetime = true
                
            case ProductID.yearly.rawValue:
                if transaction.revocationDate == nil {
                    hasSubscription = true
                }
                
            default:
                break
            }
        }
        
        if hasLifetime {
            isPro = true
            updateProStatus(to: isPro)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.counter += 1
            }
        } else if hasSubscription {
            isPro = true
            updateProStatus(to: isPro)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.counter += 1
            }
        } else {
            isPro = false
            updateProStatus(to: isPro)
        }
    }
    
    func product(for id: String) -> Product? {
        products.first { $0.id == id }
    }
    
    func purchase(_ product: Product) async {
        isPurchasing = true
        defer {
            isPurchasing = false
        }
        
        do {
            let result = try await product.purchase()
            
            switch result {
                
            case .success(let verification):
                switch verification {
                    
                case .verified(let transaction):
                    await transaction.finish()
                    
                    await updateCustomerStatus()
                    
                case .unverified:
                    print("交易未验证")
                }
                
            case .userCancelled:
                print("用户取消")
                
            case .pending:
                print("等待中（例如家长批准）")
                
            @unknown default:
                break
            }
            
        } catch {
            print("购买失败: \(error)")
        }
    }
    
    func restore() async {
        isPurchasing = true
        defer {
            isPurchasing = false
        }
        do {
            try await AppStore.sync()
            await updateCustomerStatus()
        } catch {
            print("恢复失败: \(error)")
        }
    }
    
    func listenForTransactions() {
        Task {
            for await result in Transaction.updates {
                if case .verified(_) = result {
                    await updateCustomerStatus()
                }
            }
        }
    }
    
    func updateProStatus(to value: Bool) {
        UserDefaults.standard.set(value, forKey: "player.appIsPro")
    }
    
}
