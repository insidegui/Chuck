//
//  Category+Persistence.swift
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

extension Category: IdentifiableType {

    public typealias Identity = String

    public var identity: String {
        return name
    }

}

extension Category: Persistable {

    public typealias T = NSManagedObject

    public static var entityName: String {
        return "Category"
    }

    public static var primaryAttributeName: String {
        return "name"
    }

    public init(entity: T) {
        name = entity.value(forKey: "name") as! String
    }

    public func update(_ entity: T) {
        entity.setValue(name, forKey: "name")

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
