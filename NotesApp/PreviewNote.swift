//
//  PreviewItem.swift
//  NotesApp
//
//  Created by Dominik Butz on 5/12/2023.
//

import Foundation
import CoreData

struct PreviewNote {
    
    let title: String
    let text: String
    let timestamp: Date
    
    init(title: String, text: String, timestamp: Date = .now) {
        self.title = title
        self.text = text
        self.timestamp = timestamp
    }
    
    static var previewItems: [PreviewNote] {
        return [PreviewNote(title: "Title 1", text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua"),
                PreviewNote(title: "Title 2", text: " Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."),
                PreviewNote(title: "Title 3", text: "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."),
                PreviewNote(title: "Title 4", text: "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."),
                PreviewNote(title: "Title 5", text: "Sed ut perspiciatis, unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam eaque ipsa, quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt, explicabo. Nemo enim ipsam voluptatem, quia voluptas sit, aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos, qui ratione voluptatem sequi nesciunt, neque porro quisquam est.")
           ]
    }
    
    func createNote(context: NSManagedObjectContext)-> Note {
      
        let note = Note(context: context)
        note.title = self.title
        note.text = self.text
        note.timestamp = self.timestamp
        return note
    }
    
}
