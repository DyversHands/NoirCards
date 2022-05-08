//
//  StoryView.swift
//  Collaborative Cinematic Storytelling
//
//  Created by Hasan Tahir on 26/04/2022.
//

import SwiftUI

let imageType = "public.utf8-plain-text"

struct StoryView: View {
    
    
    @ObservedObject var viewModel: StoryViewModel
    @State var dropdelegate : MyDropDelegate? = nil
    
    var body: some View {
        
        HStack{
            Spacer(minLength: 8)
            VStack(spacing: 12){
                HStack{
                    Spacer(minLength: 20)
                    Text("Freeform Story").font(Font.system(.headline, design: .default))
                    Spacer(minLength: 20)
                    Button {
                        viewModel.pickRandomImage()
                    } label: {
                        Image(systemName: "camera.metering.spot")
                    }
                    
                }
                
                TopCardsView(viewModel: viewModel)
                Color.black.frame(height: 3)
                DropView(newImage: viewModel.droppedImages.last)
                    .onDrop(of: [imageType], delegate:  MyDropDelegate(dropImages: $viewModel.droppedImages, stackImages: $viewModel.stackImages))
                Spacer(minLength: 100)
            }
            Spacer(minLength: 8)
        }
    }
}



struct StoryView_Previews: PreviewProvider {
    static var previews: some View {
        StoryView(viewModel: StoryViewModel())
            .previewDevice("iPad Pro (12.9-inch) (5th generation)")
            .previewInterfaceOrientation(.landscapeLeft)
    }
}

struct TopCardsView : View{
    @ObservedObject var viewModel: StoryViewModel
    var body: some View{
        ZStack(alignment : .leading){
            HStack(spacing : 16){
                EmptyCard()
                EmptyCard()
                EmptyCard()
                EmptyCard()
                EmptyCard()
                EmptyCard()
                EmptyCard()
            }
            LazyHStack (spacing : 16){
                ForEach(viewModel.stackImages, id: \.self) { model in
                    TopStoryCard(image: model.image)
                        .onDrag {
                            return NSItemProvider(object: model.imageName as NSItemProviderWriting)
                        }
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: 120, alignment: .top)
        
        
    }
}

struct DropView: UIViewRepresentable {
    var newImage: StoryModel?
    func makeUIView(context: Context) -> UIView {
        UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let newImage = newImage {
            print("Location \(newImage.location)")
            let storyV = StoryCard(model: newImage, frame: .init(x: newImage.location.x - 87.5, y: newImage.location.y - 62.5, width: 175, height: 125))
            uiView.addSubview(storyV)
        }
    }
}

struct MyDropDelegate: DropDelegate {
    @Binding var dropImages : [StoryModel]
    @Binding var stackImages : [StoryModel]
    func performDrop(info: DropInfo) -> Bool {
        if let item = info.itemProviders(for: [imageType]).first {
            item.loadItem(forTypeIdentifier: imageType, options: nil) { data, error in
                DispatchQueue.main.async {
                    if let imgData = data as? Data {
                        if let imgName = String(data: imgData, encoding: .utf8) {
                            stackImages.removeAll(where: {$0.imageName == imgName})
                            dropImages.append(StoryModel(imageName: imgName, location: info.location))
                        }
                    }
                }
            }
        }
        return true
    }
    
    
}




