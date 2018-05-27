//
//  Joke+Persistence.swift
//  ChuckCore
//
//  Created by Guilherme Rambo on 27/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation
import CoreData
import RxDataSources
import RxCoreData
import os.log

extension Joke: IdentifiableType {

    public typealias Identity = String

    public var identity: String {
        return id
    }

}

extension Joke: Persistable {

    public typealias T = NSManagedObject

    public static var entityName: String {
        return "Joke"
    }

    public static var primaryAttributeName: String {
        return "id"
    }

    public init(entity: T) {
        id = entity.value(forKey: CodingKeys.id.stringValue) as! String
        iconUrl = entity.value(forKey: CodingKeys.iconUrl.stringValue) as! URL
        url = entity.value(forKey: CodingKeys.url.stringValue) as! URL
        value = entity.value(forKey: CodingKeys.value.stringValue) as! String

        if let categoryEntities = entity.value(forKey: "categories") as? Set<NSManagedObject> {
            categories = categoryEntities.map(Category.init)
        } else {
            categories = []
        }
    }

    public func update(_ entity: T) {
        entity.setValue(id, forKey: CodingKeys.id.stringValue)
        entity.setValue(iconUrl, forKey: CodingKeys.iconUrl.stringValue)
        entity.setValue(url, forKey: CodingKeys.url.stringValue)
        entity.setValue(value, forKey: CodingKeys.value.stringValue)

        let categoryEntities = categories.compactMap { category -> NSManagedObject? in
            guard let child = entity.managedObjectContext?.rx.getOrCreateEntity(for: category) else {
                return nil
            }

            category.update(child)

            return child
        }

        entity.setValue(Set<NSManagedObject>(categoryEntities), forKey: "categories")

        do {
            try entity.managedObjectContext?.save()
        } catch {
            os_log(
                "Failed to commit changes to MOC: %{public}@",
                log: .default,
                type: .fault,
                String(describing: error)
            )
        }
    }

}
