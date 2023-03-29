//
//  FileManager-Write.swift
//  HotProspects
//
//  Created by Bahadır Ersin on 29.03.2023.
//

import Foundation

extension FileManager{
    
    static var documentsDirectory: URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func write(message:String,file:String){
        let url = FileManager.documentsDirectory.appendingPathComponent(file)
        
        do{
            try message.write(to: url, atomically: true, encoding: .utf8)
            let input = try String(contentsOf: url)
            if(input != message){
                print("Message corrupted when saving")
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    
}
