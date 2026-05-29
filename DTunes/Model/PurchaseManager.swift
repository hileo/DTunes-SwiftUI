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

private enum ProductLoadError: Error {
    case timeout
}

@MainActor
final class PurchaseManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var isPro: Bool = false
    @Published var counter:Int = 0
    @Published var isPurchasing: Bool = false
    @Published var isLoadingProducts: Bool = false
    @Published var productsLoadFailed: Bool = false
    
    private let productLoadTimeoutNanoseconds: UInt64 = 8_000_000_000
    
    var productIDs = [
        ProductID.lifetimeV2.rawValue,
        ProductID.lifetime.rawValue,
        ProductID.yearly.rawValue
    ]
    
    init() {
        Task {
            await loadProducts()
            await updateCustomerStatus()
            listenForTransactions()
        }
    }
    
    func loadProducts(force: Bool = false) async {
        if isLoadingProducts && !force {
            return
        }
        
        isLoadingProducts = true
        productsLoadFailed = false
        defer {
            isLoadingProducts = false
        }
        
        do {
            products = try await productsWithTimeout(for: productIDs)
            productsLoadFailed = products.isEmpty
        } catch {
            productsLoadFailed = true
            print("加载商品失败: \(error)")
        }
    }
    
    private func productsWithTimeout(for ids: [String]) async throws -> [Product] {
        try await withThrowingTaskGroup(of: [Product].self) { group in
            group.addTask {
                try await Product.products(for: ids)
            }
            
            group.addTask { [productLoadTimeoutNanoseconds] in
                try await Task.sleep(nanoseconds: productLoadTimeoutNanoseconds)
                throw ProductLoadError.timeout
            }
            
            guard let products = try await group.next() else {
                throw ProductLoadError.timeout
            }
            
            group.cancelAll()
            return products
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
    
    var yearlyProduct: Product? {
        product(for: ProductID.yearly.rawValue)
    }
    
    var lifetimeProduct: Product? {
        product(for: ProductID.lifetimeV2.rawValue) ?? product(for: ProductID.lifetime.rawValue)
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
