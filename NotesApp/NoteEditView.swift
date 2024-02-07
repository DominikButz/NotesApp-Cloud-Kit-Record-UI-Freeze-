//
//  NoteEditView.swift
//  NotesApp
//
//  Created by Dominik Butz on 5/12/2023.
//

import Foundation
import SwiftUI


struct NoteEditView: View {
    @Environment(\.managedObjectContext) private var viewContext
     var note: Note
    
    @State private var  title: String  = ""
    @State private var text: String = ""
    
    
    var body: some View {
        Form {
            TextField("Title", text: $title)
                .onChange(of: self.title) { newValue in
                    self.note.title = newValue
                    self.saveNote()
                }
            
                
            TextEditor(text: $text)
                .frame(minHeight: 300)
                .onChange(of: self.text) { newValue in
                    self.note.text = newValue
                    self.saveNote()
                }

        }.onAppear {
            self.title = note.title ?? ""
            self.text = note.text ?? ""
        }.padding()
    }
    
    private func saveNote() {
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

#Preview {
    NoteEditView(note: PreviewNote.previewItems.first!.createNote(context: PersistenceController.preview.container.viewContext))
    
}
