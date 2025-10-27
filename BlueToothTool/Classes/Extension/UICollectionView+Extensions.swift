//
//  UICollectionView+Extensions.swift
//  BlueToothTool
//
//  Created by 周飞 on 2025/10/27.
//

import UIKit

extension UICollectionView {
    func register<T: UICollectionViewCell>(nib: UINib?, forCellWithClass name: T.Type) {
        register(nib, forCellWithReuseIdentifier: String(describing: name))
    }

    func register<T: UICollectionViewCell>(cellWithClass name: T.Type) {
        register(T.self, forCellWithReuseIdentifier: String(describing: name))
    }

    func register<T: UICollectionReusableView>(
        nib: UINib?, forSupplementaryViewOfKind kind: String,
        withClass name: T.Type
    ) {
        register(
            nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: String(describing: name))
    }

    func register<T: UICollectionViewCell>(
        nibWithCellClass name: T.Type, at bundleClass: AnyClass? = nil
    ) {
        let identifier = String(describing: name)
        var bundle: Bundle?

        if let bundleName = bundleClass {
            bundle = Bundle(for: bundleName)
        }

        register(UINib(nibName: identifier, bundle: bundle), forCellWithReuseIdentifier: identifier)
    }

    func register<T: UICollectionReusableView>(
        nibWithViewClass name: T.Type, at bundleClass: AnyClass? = nil,
        forSupplementaryViewOfKind kind: String
    ) {
        let identifier = String(describing: name)
        var bundle: Bundle?
        if let bundleName = bundleClass {
            bundle = Bundle(for: bundleName)
        }
        register(
            UINib(nibName: identifier, bundle: bundle), forSupplementaryViewOfKind: kind,
            withReuseIdentifier: identifier)
    }

}
