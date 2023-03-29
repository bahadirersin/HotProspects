//
//  MeView.swift
//  HotProspects
//
//  Created by Bahadır Ersin on 28.03.2023.
//
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct MeView: View {
    
    @State private var name:String = "Anonymous"
    @State private var emailAdress:String = "you@yoursite.com"
    @State private var qrCode = UIImage()
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        NavigationView{
            Form{
                TextField("Name:",text:$name)
                    .textContentType(.name)
                    .font(.title)
                TextField("Email Address:",text:$emailAdress)
                    .textContentType(.emailAddress)
                    .font(.title)
                Image(uiImage: qrCode)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 200,height:200)
                    .contextMenu{
                        Button{
                            let imageSaver = ImageSaver()
                            imageSaver.writeToPhotoAlbum(image: qrCode)
                        }label:{
                            Label("Save to Photos", systemImage: "square.and.arrow.down")
                        }
                    }
            }
            .navigationTitle("Your code")
            .onAppear(perform:updateCode)
            .onChange(of: name){_ in updateCode()}
            .onChange(of: emailAdress){_ in updateCode()}
            
        }
    }
    
    func generateQRCode(from string:String) -> UIImage{
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage{
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent){
                qrCode = UIImage(cgImage: cgimg)
                return qrCode
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    func updateCode(){
        qrCode = generateQRCode(from: "\(name)\n\(emailAdress)")
    }
}

struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        MeView()
    }
}
