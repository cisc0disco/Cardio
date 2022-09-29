
import SwiftUI
import ACarousel

struct Card {
    var image: String
    var name: String
    var id: String
}

struct CardView: View {
    @State private var cardImage = UIImage()
    @State private var showSheet = false
    
    var card: Card
    
    var body: some View {
        
        Image(uiImage: UIImage(contentsOfFile: card.image)!).resizable().aspectRatio(contentMode: .fit).frame(width: 320).cornerRadius(5).onTapGesture {
            showSheet = true
        }.sheet(isPresented: $showSheet) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$cardImage)
        }.onChange(of: self.cardImage)
        {
            
            newImage in
            if let data = newImage.pngData()
            {
                do {
                    try data.write(to: URL(fileURLWithPath: "/var/mobile/Library/Passes/Cards/" + card.id + "/cardBackgroundCombined@2x.png"))
                    let fm = FileManager.default

                    try fm.removeItem(atPath: "/var/mobile/Library/Passes/Cards/" + card.id.replacingOccurrences(of: "pkpass", with: "cache") )
                    
                    let helper = ObjcHelper()
                    helper.respring()
                    
                    
                } catch {
                    print(error)
                }
            }
        }
    }
}

struct ContentView: View {
    
    init() {
    }
    
    func getPasses() -> [String]
    {
        let fm = FileManager.default
        let path = "/var/mobile/Library/Passes/Cards/"
        var data = [String]()
        
        do {
            let passes = try fm.contentsOfDirectory(atPath: path).filter {
                $0.hasSuffix("pkpass");
            }
            
            for pass in passes {
                let files = try fm.contentsOfDirectory(atPath: path + pass)
                
                if (files.contains("cardBackgroundCombined.png.urls"))
                {
                    data.append(pass)
                }
            }
            print(data)
            return data
            
        } catch {
            return ["No cards were found in wallet"]
        }
    }
    
    func getData() -> String {
        let fm = FileManager.default

        let path = "/var/mobile/Library/Passes/Cards/" + getPasses()[0]
        
        do {
            return try fm.contentsOfDirectory(atPath: path).joined(separator: "\n")

        } catch {
            return "nothing found"
        }
    }
    
    func getName(id: String) -> String {
        let jsonPath = "/var/mobile/Library/Passes/Cards/" + id + "/pass.json"

        
        do {
            let contents = try String(contentsOfFile: jsonPath)
            let data: Data? = contents.data(using: .utf8)
            
            if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                
                if let name = try json["organizationName"] as? String {
                    return name
                }
            }
            
        } catch {
            return (error.localizedDescription)
        }
    
        return "error"
    }
    
    func getImage(id: String) -> String {
        return "/var/mobile/Library/Passes/Cards/" + id + "/cardBackgroundCombined@2x.png"
    }
        
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text("Tap a card to customize").font(.system(size: 25)).foregroundColor(.white).padding(.bottom, 340 )
            Text("Swipe to view different cards").font(.system(size: 15)).foregroundColor(.white).padding(.bottom, 290 )

            VStack {
                ACarousel(getPasses(), id: \.self)
                {
                    i in CardView(card: Card(image: getImage(id: i), name: getName(id: i), id: i))
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
