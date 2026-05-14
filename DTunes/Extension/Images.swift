//
//  Images.swift
//  DTunes
//
//  Created by OllyWang on 12/20/25.
//

import SwiftUI
import Combine

final class ImageCache {
    static let shared = NSCache<NSURL, UIImage>()
}

final class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    private let url: URL

    init(url: URL) {
        self.url = url
        load()
    }

    private func load() {
        // ✅ 1. 命中缓存
        if let cached = ImageCache.shared.object(forKey: url as NSURL) {
            self.image = cached
            return
        }

        // ✅ 2. 下载
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard
                let data = data,
                let img = UIImage(data: data)
            else { return }

            // ✅ 3. 写入缓存
            ImageCache.shared.setObject(img, forKey: self.url as NSURL)

            DispatchQueue.main.async {
                self.image = img
            }
        }.resume()
    }
}
