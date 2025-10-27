//
//  Array+Extensions.swift
//  BlueToothTool
//
//  Created by 周飞 on 2025/10/27.
//

import UIKit

extension Array where Element == UInt8 {
    @inlinable
    init(reserveCapacity: Int) {
        self = [Element]()
        self.reserveCapacity(reserveCapacity)
    }

    public init(hex: String) {
        self.init(reserveCapacity: hex.unicodeScalars.lazy.underestimatedCount)
        var buffer: UInt8?
        var skip = hex.hasPrefix("0x") ? 2 : 0
        for char in hex.unicodeScalars.lazy {
            guard skip == 0 else {
                skip -= 1
                continue
            }
            guard char.value >= 48 && char.value <= 102 else {
                removeAll()
                return
            }
            let v: UInt8
            let c: UInt8 = UInt8(char.value)
            switch c {
            case let c where c <= 57:
                v = c - 48
            case let c where c >= 65 && c <= 70:
                v = c - 55
            case let c where c >= 97:
                v = c - 87
            default:
                removeAll()
                return
            }
            if let b = buffer {
                append(b << 4 | v)
                buffer = nil
            } else {
                buffer = v
            }
        }
        if let b = buffer {
            append(b)
        }
    }

    public func toHexString() -> String {
        `lazy`.reduce(into: "") {
            var s = String($1, radix: 16)
            if s.count == 1 {
                s = "0" + s
            }
            $0 += s
        }
    }
}

extension Array {
    func randomElements(_ n: Int) -> [Element] {
        var elements = self
        var result = [Element]()
        for _ in 0..<Swift.min(n, elements.count) {
            let index = Int(arc4random_uniform(UInt32(elements.count)))
            result.append(elements[index])
            elements.remove(at: index)
        }
        return result
    }

    func firstN(_ n: Int) -> Self {
        return Array(prefix(n))
    }
}
