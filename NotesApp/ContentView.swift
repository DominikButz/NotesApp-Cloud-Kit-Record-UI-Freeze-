//
//  ContentView.swift
//  NotesApp
//
//  Created by Dominik Butz on 5/12/2023.
//

import SwiftUI
import CoreData
import CloudStorage
import CloudKit

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.timestamp, ascending: true)],
        animation: .default)
    private var notes: FetchedResults<Note>
    
    @State private var  selectedNote: Note?
    
    
    @CloudStorage("favourites") var favouriteRecordNames: Set<String> = []
    @State private var favouriteNotes: Array<Note> = []
    @State private var path = NavigationPath()

    
    var body: some View {
        layout()
            .task {
                
                self.setFavoriteState(notes: Array(self.notes))
            

            }

    }
    
    
    
    private func layout()-> some View {
        NavigationSplitView {
            List(selection: $selectedNote) {
                listContent
            
            }
            .listStyle(.sidebar)
            .toolbar {
                toolbarContent
            }
        } detail: {
            if let note = self.selectedNote {
                NoteEditView(note: note)
                    .navigationTitle(selectedNote?.title ?? "Untitled")
            } else {
                if #available(macOS 14, iOS 17,  *) {
                    ContentUnavailableView("Select a note or create a new one", systemImage: "note.text")
                } else {
                    Text("Select a note or create a new one")
                }
            }
        }

    }
    
    @ViewBuilder private var listContent: some View {
        
            Section {
                ForEach(self.favouriteNotes) { item in
                    self.itemRow(note: item)
                }
                .onDelete(perform: deleteItems)
                
                if self.favouriteNotes.isEmpty {
                    self.noContent(message: "No favourites yet")
                }
         
            } header: {
                self.header(title: "Favorites")
            }
        
        
            Section {
                ForEach(notes) { item in
                    if !self.favouriteNotes.contains(item) {
                        self.itemRow(note: item)
                    }
                
                }
                .onDelete(perform: deleteItems)
                
                if self.notes.isEmpty {
                    self.noContent(message: "No notes yet")
                }
            } header: {
                self.header(title: "Notes")
            }

        
    }
    
    private func header(title: String) -> some View {
        VStack {
            HStack {
                Text(title).font(.headline)
                Spacer()
            }

            Divider()
        }
    }
    
    private func noContent(message: String) -> some View {
        HStack {
            Text(message).italic().font(.caption)
            Spacer()
        }
        
    }
    
//    private func iPhoneLayout()-> some View {
//        NavigationStack(path: $path) {
//            List {
//                listContent
//                    .navigationDestination(for: Note.self, destination: { note in
//                        NoteEditView(note: note)
//                    })
//              
//            }
//            .listStyle(.sidebar)
//            .toolbar {
//                toolbarContent
//            }
//        }
//    }
    


    
    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
      
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            #endif
             ToolbarItem {
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        
    }
    
    private func itemRow(note: Note)->some View {
        NavigationLink(value: note) {
            VStack(alignment: .leading ) {
                Text(note.title ?? "Untitled").font(.headline)
                Text("Created: \(note.timestamp ?? Date.now, formatter: itemFormatter)").font(.footnote).foregroundStyle(Color.secondary)
            }
        }
        .contextMenu {
            self.favoriteButton(note: note)
        }
        .swipeActions(edge: .leading, content: {
            self.favoriteButton(note: note)
        })

    }
    
    private func favoriteButton(note: Note) -> some View {
        Button {
            
        } label: {
            Label(self.favouriteNotes.contains(note) ? "Remove from Favourites" : "Add to Favourites", systemImage: self.favouriteNotes.contains(note) ? "star.slash" : "star.fill")
        }
    }
    
    private func setFavoriteState(notes: [Note]) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1) {
            let persistence = PersistenceController.shared
            
            for note in notes {
                if let recordName = persistence.container.record(for: note.objectID)?.recordID.recordName {
                    if self.favouriteRecordNames.contains(recordName) {
                        DispatchQueue.main.async {
                            self.favouriteNotes.append(note)
                        }
                    }
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newNote = Note(context: viewContext)
            self.selectedNote = newNote

        }
    }
    
    private func updateFavoriteState(note:Note) {
        DispatchQueue.global(qos: .userInitiated).async {
            let persistence = PersistenceController.shared
            if self.favouriteNotes.contains(note) {
                DispatchQueue.main.async {
                    withAnimation {
                        self.favouriteNotes = self.favouriteNotes.filter({$0 != note})
                    }
                }
                if let recordName = persistence.container.record(for: note.objectID)?.recordID.recordName {
                    DispatchQueue.main.async {
                        self.favouriteRecordNames = self.favouriteRecordNames.filter({$0 != recordName})
                    }
                }
            } else {
                DispatchQueue.main.async {
                    withAnimation {
                        self.favouriteNotes.append(note)
                    }
                }
                if let recordName = persistence.container.record(for: note.objectID)?.recordID.recordName {
                    DispatchQueue.main.async {
                        self.favouriteRecordNames.insert(recordName)
                    }
                }
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { notes[$0] }.forEach(viewContext.delete)

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
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}



