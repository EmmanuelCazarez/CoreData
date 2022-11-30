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

    @State var mostrarAlerta: Bool = false
    
    @State var idPedido = 0
    @State var cliente = ""
    @State var articulo = ""
    @State var estado = ""
    @State var direccion = ""
    @State var total = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(pedidos) { pedido in
                    NavigationLink {
                        Form {
                            Group {
                                Text("Cliente: \(pedido.cliente ?? "")")
                                TextField("Nombre del cliente", text: $cliente)
                                Text("Artículo: \(pedido.articulo ?? "")")
                                TextField("Nombre del artículo", text: $articulo)
                                Text("Estado: \(pedido.estado ?? "")")
                                TextField("Nombre del estado", text: $estado)
                                Text("Dirección: \(pedido.direccion ?? "")")
                                TextField("Indicar domicilio", text: $direccion)
                                Text("Total: \(pedido.total ?? "")")
                                TextField("Cantidad total", text: $total)
                            }
                            Button("Guardar") {
                                updateItems(pedido: pedido)
                                mostrarAlerta = true
                            }
                            .alert("El pedido fue actualizado con éxito", isPresented: $mostrarAlerta) {
                                Button("Aceptar") {}
                            }
                        }
                    } label: {
                        Text("Pedido \(pedido.idPedido)")
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Lista de Pedidos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        NavigationLink("Agregar pedido") {
                            Form {
                                Group {
                                    Text("Cliente")
                                    TextField("Nombre del cliente", text: $cliente)
                                    Text("Artículo")
                                    TextField("Nombre del artículo", text: $articulo)
                                    Text("Estado")
                                    TextField("Nombre del estado", text: $estado)
                                    Text("Dirección")
                                    TextField("Indicar domicilio", text: $direccion)
                                    Text("Total")
                                    TextField("Cantidad total", text: $total)
                                }
                                Button("Guardar") {
                                    addItems(cliente: cliente, articulo: articulo, estado: estado, direccion: direccion, total: total)
                                    mostrarAlerta = true
                                }
                                .alert("El pedido fue guardado con éxito", isPresented: $mostrarAlerta) {
                                    Button("Aceptar") {}
                                }
                            }
                        }
                    }
                }
            }
            Text("Select an item")
        }
    }
    
    private func addItems(cliente: String, articulo: String, estado: String, direccion: String, total: String) {
        withAnimation {
            let newPedido = PedidoEntity(context: viewContext)
            newPedido.cliente = cliente
            newPedido.articulo = articulo
            newPedido.estado = estado
            newPedido.direccion = direccion
            newPedido.total = total
            newPedido.idPedido = getLastId()! + 1

            saveItems()
            vaciarDatos()
        }
    }

    private func updateItems(pedido: PedidoEntity) {
        withAnimation {
            pedido.cliente = cliente
            pedido.articulo = articulo
            pedido.estado = estado
            pedido.direccion = direccion
            pedido.total = total
            
            saveItems()
            vaciarDatos()
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
    
    private func vaciarDatos() {
        cliente = ""
        articulo = ""
        estado = ""
        direccion = ""
        total = ""
    }
    
    
    private func getLastId() -> Int64? {

        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        request.entity = NSEntityDescription.entity(forEntityName: "PedidoEntity", in: viewContext)
        request.resultType = NSFetchRequestResultType.dictionaryResultType

        let keypathExpression = NSExpression(forKeyPath: "idPedido")
        let maxExpression = NSExpression(forFunction: "max:", arguments: [keypathExpression])

        let key = "maxId"

        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = key
        expressionDescription.expression = maxExpression
        expressionDescription.expressionResultType = .integer64AttributeType

        request.propertiesToFetch = [expressionDescription]

        var maxId: Int64? = nil

        do {

            if let result = try viewContext.fetch(request) as? [[String: Int64]], let dict = result.first {
               maxId = dict[key]
            }

        } catch {
            assertionFailure("Failed to fetch max timestamp with error = \(error)")
            return nil
        }

        return maxId
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
