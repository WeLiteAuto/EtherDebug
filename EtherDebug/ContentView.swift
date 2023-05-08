//
//  ContentView.swift
//  TRIAL
//
//  Created by Aaron Ge on 2023/4/28.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
//    private var 
//    @FetchRequest(entity: , sortDescriptors: <#T##[NSSortDescriptor]#>)

//    @FetchRequest(entity: IpAddress.entity(), sortDescriptors: [])
//    private var usedIp: FetchRequest<IpAddress>
//    private var items: FetchedResults<Item>

    var body: some View {
      
            NetworkDebugView()
              
                .environment(\.managedObjectContext, viewContext)
        
    }
}

