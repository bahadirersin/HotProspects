//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Bahadır Ersin on 28.03.2023.
//

import CodeScanner
import SwiftUI
import UserNotifications

struct ProspectsView: View {
    
    enum FilterType{
        case none,contacted,uncontacted
    }
    
    enum SortType{
        case none,name,recent
    }
    
    @EnvironmentObject var prospects: Prospects
    @State private var isShowingScanner = false
    @State private var isShowingSort = false
    @State private var sort:SortType = .none
    let filter:FilterType
    
    var body: some View {
        NavigationView{
            List{
                ForEach(sortedProspects){ prospect in
                    HStack(alignment:.center){
                        if(filter == .none && prospect.isContacted){
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }else if(filter == .none && !prospect.isContacted){
                            Image(systemName: "x.circle.fill")
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment:.leading){
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                        }
                    }.swipeActions{
                        if(prospect.isContacted){
                            Button{
                                prospects.toggle(prospect)
                            }label:{
                                Label("Mark Uncontacted",systemImage: "person.crop.circle.badge.xmark")
                            }
                            .tint(.blue)
                        }else{
                            Button{
                                prospects.toggle(prospect)
                            }label:{
                                Label("Mark Contacted",systemImage: "person.crop.circle.fill.badge.checkmark")
                            }
                            .tint(.green)
                            
                            Button{
                                addNotification(for: prospect)
                            }label:{
                                Label("Remind Me",systemImage: "bell")
                            }
                            .tint(.orange)
                        }
                    }
                }
            }
                .navigationTitle(title)
                .toolbar{
                    ToolbarItem(placement: .navigationBarTrailing){
                        
                        Button{
                            isShowingScanner = true
                        }label:{
                            Label("Scan",systemImage: "qrcode.viewfinder")
                        }
                    }
                    ToolbarItem(placement:.navigationBarLeading){
                        Button{
                            isShowingSort = true
                        }label:{
                            Label("Sort",systemImage: "arrow.up.and.down.text.horizontal")
                        }
                    }
                }
                .sheet(isPresented:$isShowingScanner){
                    CodeScannerView(codeTypes:[.qr],simulatedData: "Leo Ersin\nleoersin@gmail.com",completion: handleScan)
                }
                .confirmationDialog("Sort People", isPresented: $isShowingSort){
                    Button("By Name"){sort = .name}
                    Button("Most Recent"){sort = .recent}
                }
        }
    }
    
    var title:String{
        switch filter{
        case .none:
            return "Everyone"
        case .uncontacted:
            return "Uncontacted People"
        case .contacted:
            return "Contacted People"
        }
    }
    
    var filteredProspects:[Prospect]{
        switch filter{
        case .none:
            return prospects.people
        case .uncontacted:
            return prospects.people.filter{!$0.isContacted}
        case .contacted:
            return prospects.people.filter{$0.isContacted}
        }
    }
    
    var sortedProspects:[Prospect]{
        switch sort{
        case .none:
            return filteredProspects
        case .name:
            return filteredProspects.sorted{$0.name < $1.name}
        case .recent:
            return filteredProspects.reversed()
        }
    }
    
    func handleScan(result: Result<ScanResult,ScanError>){
        isShowingScanner = false
        
        switch result{
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else {return}
            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]
            prospects.add(person)
        case .failure(let error):
            print("Scanning failure: \(error.localizedDescription)")
        }
    }
    
    func addNotification(for prospect:Prospect){
        let center  = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            
//            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        
        center.getNotificationSettings{ settings in
            if settings.authorizationStatus == .authorized{
                addRequest()
            }else{
                center.requestAuthorization(options: [.alert,.badge,.sound]){ success, error in
                    if success{
                        addRequest()
                    }else{
                        print("Setting a notification didn't work")
                    }
                }
            }
        }
        
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter:.none)
            .environmentObject(Prospects())
    }
}
