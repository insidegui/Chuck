//
//  RecentSearch+Persistence.swift
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

extension RecentSearch: IdentifiableType {

    public typealias Identity = String

    public var identity: String {
        return term
    }

}

extension RecentSearch: Persistable {

    public typealias T = NSManagedObject

    public static var entityName: String {
        return "RecentSearch"
    }

    public static var primaryAttributeName: String {
        return "term"
    }

    public init(entity: T) {
        term = entity.value(forKey: "term") as! String
        createdAt = entity.value(forKey: "createdAt") as! Date
    }

    public func update(_ entity: NSManagedObject) {
        entity.setValue(createdAt, forKey: "createdAt")
        entity.setValue(term, forKey: "term")

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
