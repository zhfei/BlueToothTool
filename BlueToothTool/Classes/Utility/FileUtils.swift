//
//  FileUtils.swift
//  RepReady
//
//  Created by zhoufei on 2025/6/15.
//

import Foundation

/// 文件和目录管理的工具类
class FileUtils {
    
    static let shared = FileUtils()
    
    private let fileManager = FileManager.default
    
    private init() {}
    
    // MARK: - 路径获取
    
    /// 获取文档目录URL
    func getDocumentsDirectory() -> URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    /// 获取缓存目录URL
    func getCacheDirectory() -> URL {
        return fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }
    
    /// 获取临时目录URL
    func getTempDirectory() -> URL {
        return fileManager.temporaryDirectory
    }
    
    /// 拼接路径
    func appendPath(to baseURL: URL, pathComponent: String) -> URL {
        return baseURL.appendingPathComponent(pathComponent)
    }
    
    // MARK: - 目录操作
    
    /// 创建目录
    func createDirectory(at path: URL) -> Bool {
        do {
            try fileManager.createDirectory(at: path, withIntermediateDirectories: true)
            return true
        } catch {
            print("❌ 创建目录失败: \(error.localizedDescription)")
            return false
        }
    }
    
    /// 检查目录是否存在
    func directoryExists(at path: URL) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: path.path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    
    /// 获取目录内容
    func contentsOfDirectory(at path: URL) -> [URL]? {
        do {
            return try fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
        } catch {
            print("❌ 获取目录内容失败: \(error.localizedDescription)")
            return nil
        }
    }

    /// 获取目录下的所有子目录URL
    func directoriesOfDirectory(at path: URL) -> [URL]? {
        do {
            let contents = try fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: [.isDirectoryKey])
            return contents.filter {
                (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
            }
        } catch {
            print("❌ 获取子目录失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - 文件操作
    
    /// 检查文件是否存在
    func fileExists(at path: URL) -> Bool {
        return fileManager.fileExists(atPath: path.path)
    }
    
    /// 创建文件
    @discardableResult
    func createFile(at path: URL, contents: Data?) -> Bool {
        return fileManager.createFile(atPath: path.path, contents: contents)
    }
    
    /// 读取文件内容
    func readFile(at path: URL) -> Data? {
        return fileManager.contents(atPath: path.path)
    }
    
    /// 保存文本到文件
    @discardableResult
    func saveText(_ text: String, to path: URL) -> Bool {
        do {
            try text.write(to: path, atomically: true, encoding: .utf8)
            return true
        } catch {
            print("❌ 保存文本失败: \(error.localizedDescription)")
            return false
        }
    }
    
    /// 读取文件为文本
    func readText(from path: URL) -> String? {
        do {
            return try String(contentsOf: path, encoding: .utf8)
        } catch {
            print("❌ 读取文本失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// 删除文件
    @discardableResult
    func deleteFile(at path: URL) -> Bool {
        do {
            try fileManager.removeItem(at: path)
            return true
        } catch {
            print("❌ 删除文件失败: \(error.localizedDescription)")
            return false
        }
    }
    
    /// 复制文件
    @discardableResult
    func copyFile(from sourcePath: URL, to destinationPath: URL) -> Bool {
        do {
            try fileManager.copyItem(at: sourcePath, to: destinationPath)
            return true
        } catch {
            print("❌ 复制文件失败: \(error.localizedDescription)")
            return false
        }
    }
    
    /// 移动文件
    @discardableResult
    func moveFile(from sourcePath: URL, to destinationPath: URL) -> Bool {
        do {
            try fileManager.moveItem(at: sourcePath, to: destinationPath)
            return true
        } catch {
            print("❌ 移动文件失败: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - JSON操作
    
    /// 保存JSON对象到文件
    @discardableResult
    func saveJSON<T: Encodable>(_ object: T, to path: URL) -> Bool {
        do {
            let data = try JSONEncoder().encode(object)
            return createFile(at: path, contents: data)
        } catch {
            print("❌ 保存JSON失败: \(error.localizedDescription)")
            return false
        }
    }
    
    /// 从JSON文件加载对象
    func loadJSON<T: Decodable>(from path: URL, as type: T.Type) -> T? {
        guard let data = readFile(at: path) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("❌ 加载JSON失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// 保存字典到JSON文件
    @discardableResult
    func saveDictionary(_ dict: [String: Any], to path: URL) -> Bool {
        do {
            let data = try JSONSerialization.data(withJSONObject: dict)
            return createFile(at: path, contents: data)
        } catch {
            print("❌ 保存字典失败: \(error.localizedDescription)")
            return false
        }
    }
    
    /// 从JSON文件加载字典
    func loadDictionary(from path: URL) -> [String: Any]? {
        guard let data = readFile(at: path) else {
            return nil
        }
        
        do {
            guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return nil
            }
            return dict
        } catch {
            print("❌ 加载字典失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - 辅助方法
    
    /// 获取文件大小
    func fileSize(at path: URL) -> UInt64? {
        do {
            let attributes = try fileManager.attributesOfItem(atPath: path.path)
            return attributes[.size] as? UInt64
        } catch {
            print("❌ 获取文件大小失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// 获取文件创建日期
    func fileCreationDate(at path: URL) -> Date? {
        do {
            let attributes = try fileManager.attributesOfItem(atPath: path.path)
            return attributes[.creationDate] as? Date
        } catch {
            print("❌ 获取文件创建日期失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// 获取文件修改日期
    func fileModificationDate(at path: URL) -> Date? {
        do {
            let attributes = try fileManager.attributesOfItem(atPath: path.path)
            return attributes[.modificationDate] as? Date
        } catch {
            print("❌ 获取文件修改日期失败: \(error.localizedDescription)")
            return nil
        }
    }
} 

