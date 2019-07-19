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

    func concurrentCompactMap_improbable<B>(numPartitions partitions: Int, _ transform: @escaping (Element) -> B?) -> [B] {
        var result: [B] = []
        let q = DispatchQueue(label: "sync queue")

        // Size of partition is rounded up, so that last iteration may be not full, but will be not empty
        let partitionSize = (count + partitions - 1) / partitions

        DispatchQueue.concurrentPerform(iterations: partitions) { partition in
            let partitionStartIdx = partition * partitionSize
            if partitionStartIdx >= count {
                // partition is empty - possible, when there are very few elements compared to number of partitions
                return
            }
            let elements = self[partitionStartIdx ..< Swift.min(partitionStartIdx + partitionSize, count)]
            let transformed = elements.compactMap(transform)
            q.sync {
                result.append(contentsOf: transformed)
            }
        }
        return result
    }
}

extension Set {
    // Implementation for realativly small sets with costly per-item computation
    func concurrentMap<B>(_ transform: @escaping (Element) -> B) -> [B] {
        return Array(self).concurrentMap(transform)
    }
}
