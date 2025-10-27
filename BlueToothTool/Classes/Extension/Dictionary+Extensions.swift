//
//  DictionaryExtensions.swift
//  RepReady
//
//  Created by Jim Learning on 2025/6/21.
//

import Foundation

extension Dictionary {
    mutating func merge(_ other: [Key: Value]) {
        for (key, value) in other {
            self[key] = value
        }
    }
}

extension Dictionary {
    func string(for key: Key) -> String? {
        if let value = self[key] as? String {
            return value
        }
        return nil
    }
    func bool(for key: Key) -> Bool? {
        if let value = self[key] as? Bool {
            return value
        }
        return false
    }
}

extension Dictionary where Key == String, Value == Any {
    /**
     * 将一个 [String: Any] 类型的字典安全地转换为一个指定的 Codable 模型。
     *
     * - Parameter type: 要转换成的目标模型的类型 (例如 `User.self`)。
     * - Returns: 一个可选的、转换后的模型实例。如果转换失败，则返回 `nil`。
     *
     * 该方法是通用的，适用于任何遵循 `Decodable` 协议的 struct 或 class。
     */
    func toModel<T: Decodable>(
        _ type: T.Type, strategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
    ) -> T? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []) else {
            print("❌ Error: Could not serialize dictionary to Data.")
            return nil
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = strategy
        guard let model = try? decoder.decode(T.self, from: data) else {
            print("❌ Error: Could not decode Data to model of type \(T.self).")
            print("   - Check if all required properties of \(T.self) exist in the dictionary.")
            print("   - Check if data types match the model's properties.")
            return nil
        }

        return model
    }
}



extension Dictionary where Key == String, Value == Any {
    
    /// Subscript access to safely retrieve a value with fallback and type conversion support.
    /// Internally calls `get(_:default:)`.
    ///
    /// - Parameters:
    ///   - path: Dot-separated key path (e.g. `"settings.theme.color"`).
    ///   - defaultValue: Fallback if value is missing or type mismatch.
    /// - Returns: Value of type `T` or default value.
    ///
    /// ### Supported conversions:
    /// - `NSNumber` to `Int`, `Double`, `Bool`
    /// - `String` to `Int`, `Double`, `Bool`
    /// - `NSString` to `String`
    ///
    /// ### Example:
    /// ```swift
    /// let themeColor: String = json[safe: "settings.theme.color", default: "blue"]
    /// ```
    subscript<T>(safe path: String, default defaultValue: @autoclosure () -> T) -> T {
        return get(path, default: defaultValue())
    }
    
    /// Safely retrieves a value from a `[String: Any]` dictionary using a dot-separated key path,
    /// with support for type casting, number/string/bool conversion, and a default fallback value.
    ///
    /// - Parameters:
    ///   - path: The dot-separated key path (e.g. `"user.profile.age"`).
    ///   - defaultValue: A fallback value to return if the key path is missing or value type mismatch.
    /// - Returns: The converted value of expected type `T`, or the default value if conversion fails.
    ///
    /// ### Supported conversions:
    /// - `NSNumber` to `Int`, `Double`, `Bool`
    /// - `String` to `Int`, `Double`, `Bool`
    /// - `NSString` to `String`
    ///
    /// ### Example:
    /// ```swift
    /// let json: [String: Any] = [
    ///     "user": [
    ///         "profile": [
    ///             "name": "Jim",
    ///             "age": "28"
    ///         ],
    ///         "active": "true"
    ///     ]
    /// ]
    ///
    /// let name: String = json.get("user.profile.name", default: "Anonymous")
    /// let age: Int = json.get("user.profile.age", default: 0)
    /// let active: Bool = json.get("user.active", default: false)
    /// ```
    func get<T>(_ path: String, default defaultValue: @autoclosure () -> T) -> T {
        let keys = path.split(separator: ".").map(String.init)
        var current: Any? = self
        
        for key in keys {
            if let dict = current as? [String: Any] {
                current = dict[key]
            } else {
                current = nil
                break
            }
        }
        
        guard let raw = current else {
            return defaultValue()
        }

        return Dictionary.convert(raw, to: T.self) ?? defaultValue()
    }
    
    /// Sets a value at the specified dot-separated key path inside a `[String: Any]` dictionary.
    /// Automatically creates intermediate nested dictionaries as needed.
    ///
    /// - Parameters:
    ///   - path: Dot-separated key path (e.g. `"user.profile.name"`).
    ///   - newValue: The value to set at the specified path.
    ///
    /// ### Example:
    /// ```swift
    /// var dict: [String: Any] = [:]
    /// dict.set("user.profile.name", to: "Jim")
    /// dict.set("user.profile.age", to: 28)
    /// dict.set("user.active", to: true)
    ///
    /// print(dict)
    /// // [
    /// //   "user": [
    /// //     "profile": [
    /// //       "name": "Jim",
    /// //       "age": 28
    /// //     ],
    /// //     "active": true
    /// //   ]
    /// // ]
    /// ```
    mutating func set(_ path: String, to newValue: Any) {
        var keys = path.split(separator: ".").map(String.init)
        guard let first = keys.first else { return }
        
        // The last key
        if keys.count == 1 {
            self[first] = newValue
            return
        }
        
        // Going deeper recursively
        var subDict = self[first] as? [String: Any] ?? [:]
        keys.removeFirst()
        subDict.set(keys.joined(separator: "."), to: newValue)
        self[first] = subDict
    }
    
    private static func convert<T>(_ raw: Any, to targetType: T.Type) -> T? {
        // Direct type matching
        if let casted = raw as? T {
            return casted
        }

        if let number = raw as? NSNumber {
            switch targetType {
            case is Int.Type: return number.intValue as? T
            case is Double.Type: return number.doubleValue as? T
            case is Float.Type: return number.floatValue as? T
            case is Bool.Type: return number.boolValue as? T
            default: break
            }
        }

        if let nsStr = raw as? NSString, targetType == String.self {
            return nsStr as String as? T
        }

        if let string = raw as? String {
            switch targetType {
            case is Int.Type: return Int(string) as? T
            case is Double.Type: return Double(string) as? T
            case is Float.Type: return Float(string) as? T
            case is Bool.Type:
                let lower = string.lowercased()
                if lower == "true" || lower == "1" { return true as? T }
                if lower == "false" || lower == "0" { return false as? T }
            case is String.Type: return string as? T
            default: break
            }
        }

        return nil
    }
}
