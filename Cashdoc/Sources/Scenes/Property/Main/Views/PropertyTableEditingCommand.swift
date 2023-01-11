//
//  PropertyTableEditingCommand.swift
//  Cashdoc
//
//  Created by Oh Sangho on 10/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Foundation
import RxCocoa

enum PropertyTableEditingCommand {
    case MoveItem(sourceIndex: IndexPath, destinationIndex: IndexPath)
}

struct PropertySectionedTableViewState {
    var sections: [PropertySection]
    
    init(sections: [PropertySection]) {
        self.sections = sections
    }
    
    func execute(command: PropertyTableEditingCommand) -> PropertySectionedTableViewState {
        switch command {
        case .MoveItem(let sourceIndex, let destinationIndex):
            var sections = self.sections
            var sourceItems = sections[sourceIndex.section].items
            var destinationItems = sections[destinationIndex.section].items
            
            if sourceIndex.section == destinationIndex.section {
                destinationItems.insert(destinationItems.remove(at: sourceIndex.row), at: destinationIndex.row)
                let destinationSection = PropertySection(original: sections[destinationIndex.section], items: destinationItems)
                sections[sourceIndex.section] = destinationSection
                
                return PropertySectionedTableViewState(sections: sections)
            } else {
                let item = sourceItems.remove(at: sourceIndex.row)
                destinationItems.insert(item, at: destinationIndex.row)
                let sourceSection = PropertySection(original: sections[sourceIndex.section], items: sourceItems)
                let destinationSection = PropertySection(original: sections[destinationIndex.section], items: destinationItems)
                sections[sourceIndex.section] = sourceSection
                sections[destinationIndex.section] = destinationSection
                
                return PropertySectionedTableViewState(sections: sections)
            }
        }
    }
}
