//
//  ListDetailView.swift
//  AssignmentOne
//
//  Created by jennifer-wei lin on 17/3/2023.
//

import SwiftUI
import CoreData

///The ListDetailView struct is the Detail View for the items within each checklist

struct ListDetailView: View {
    
    @Environment(\.managedObjectContext) var ctx
    var favouritePlace: FavouritePlace
    
    ///image (or its URL when in editing mode), the name, the location, and notes
    @State var details: [Detail]?
    @State var name = ""
    @State var url = ""
    @State var latitude = ""
    @State var longitude = ""
    @State var notes = ""
    
    @State var image = defaultImage
    
    @State var loading = false /// State variable to indicate loading status
    
    var body: some View {
        Group {
            if loading { /// Show ProgressView if loading is true
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else { /// Show List if loading is false
                VStack{
                    TextField("New Place:", text: $name)
                    TextField("Enter Image URL:", text: $url)
                    TextField("Latitude:", text: $latitude)
                    TextField("Longitude:", text: $longitude)
                    TextField("Notes:", text: $notes)
                }
                Button("Add or Edit Place Details"){
                    addNewPlaceDetails()
                    fetchDetails()
                }
                
                List{
                    ForEach(details ?? []){
                        detail in
                        Text("Latitude: \(detail.latitude ?? ""), Longitude: \(detail.longitude ?? ""), Notes: \(detail.notes ?? "")")
                        image.scaledToFit()
                    }
                    .onDelete{
                        idx in deleteDetails(idx)
                    }
                }
                
                .navigationTitle(favouritePlace.place ?? "Details")
                .task{
                    fetchDetails()
                }
                
                            .navigationBarItems(
                                leading: EditButton()
                        
                            )
            }
        
        }
        .onAppear {
            /// start loading
            loading = true
            /// simulate loading delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                /// stop loading after delay
                loading = false
            }
            Task{
                image = await favouritePlace.getImage()
            }
        }
    }
    
    func addNewPlaceDetails(){
        guard name != "", url != "", latitude != "", longitude != "", notes != ""
        else{
            return
        }
        let placeDetails = Detail(context: ctx)
        favouritePlace.place = name
        favouritePlace.strUrl = url
        placeDetails.latitude = latitude
        placeDetails.longitude = longitude
        placeDetails.notes = notes
        placeDetails.belongto = favouritePlace
        saveData()
        name = ""
        url = ""
        latitude = ""
        longitude = ""
        notes = ""
        Task{
            image = await favouritePlace.getImage()
        }

    }
    
    func fetchDetails(){
        let fetchRequest = Detail.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "belongto = %@", favouritePlace)
        details = try? ctx.fetch(fetchRequest)
    }
    
    func deleteDetails(_ idx: IndexSet){
        guard let arr = details else {
            return
        }
        idx.map{arr[$0]}.forEach{ detail in
            ctx.delete(detail)
        }
            
        image = defaultImage
        
        saveData()
    }
     
}
