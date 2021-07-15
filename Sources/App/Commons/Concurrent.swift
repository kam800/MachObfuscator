//
//  Concurrent.swift
//  MachObfuscator
//

import Foundation

extension Array {
    // Building block for concurrent operations
    // This implementation is best for realativly small arrays with costly per-item computation
    //
    // Insipired by https://talk.objc.io/episodes/S01E90-concurrent-map
    fileprivate func concurrentMap_impl<B>(_ transform: @escaping (Element) -> B?) -> [B?] {
        var result = [B?](repeating: nil, count: count)
        let q = DispatchQueue(label: "sync queue")
        DispatchQueue.concurrentPerform(iterations: count) { idx in
            let element = self[idx]
            let transformed = transform(element)
            q.sync {
                result[idx] = transformed
            }
        }
        return result
    }

    func concurrentMap<B>(_ transform: @escaping (Element) -> B) -> [B] {
        return concurrentMap_impl(transform).map { $0! }
    }

    func concurrentCompactMap<B>(_ transform: @escaping (Element) -> B?) -> [B] {
        return concurrentMap_impl(transform).compactMap { $0 }
    }
}

extension Set {
    // Implementation for realativly small sets with costly per-item computation
    func concurrentMap<B>(_ transform: @escaping (Element) -> B) -> [B] {
        return Array(self).concurrentMap(transform)
    }
}
