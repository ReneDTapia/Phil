//
//  InitialFormCoreDataModel.swift
//  Phil
//
//  Created by Leonardo García Ledezma on 27/11/23.
//

import CoreData

public class SliderPosition: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var value: Int16
    @NSManaged public var formId: Int
}

extension SliderPosition {
    static func fetchRequest() -> NSFetchRequest<SliderPosition> {
        NSFetchRequest<SliderPosition>(entityName: "SliderPosition")
    }
}

