//
//  ContentView.swift
//  Pedidos
//
//  Created by Emmanuel on 23/11/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: PedidoEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \PedidoEntity.idPedido, ascending: true)])
        var pedidos: FetchedResults<PedidoEntity>

    @State var textFieldText: String = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(pedidos) { pedido in
                    Text("Pedido \(pedido.idPedido)")
                        .onTapGesture {
                            updateItems(pedido: pedido)
                        }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Lista de Pedidos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addItems) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }

    private func addItems() {
        withAnimation {
            let newPedido = PedidoEntity(context: viewContext)
            newPedido.articulo = "Hola"

            saveItems()
        }
    }

    private func updateItems(pedido: PedidoEntity) {
        withAnimation {
            let currentPedido = pedido.idPedido
            let newPedido = currentPedido + 1
            pedido.idPedido = newPedido
            
            saveItems()
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            guard let index = offsets.first else { return }
            let pedidoEntity = pedidos[index]
            viewContext.delete(pedidoEntity)
                
            saveItems()
        }
    }
    
    private func saveItems() {
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

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
