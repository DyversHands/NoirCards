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
            VStack(spacing: 0){
                HStack{
                    Spacer(minLength: 20)
                    Text("Freeform Story").font(Font.system(.headline, design: .default))
                        .frame(height: 30)
                    Spacer(minLength: 20)
                    /*
                    Button {
                        viewModel.pickRandomImage()
                    } label: {
                        Image(systemName: "camera.metering.spot")
                    }
                     */
                    
                }
                
                TopCardsView(viewModel: viewModel)
                Color.black.frame(height: 3).padding(.vertical,20)
                DropView(viewModel: viewModel)
                    .onDrop(of: [imageType], delegate:  MyDropDelegate(dropImages: $viewModel.droppedImages, stackImages: $viewModel.stackImages))
//                Spacer(minLength: 100)
            }
            Spacer(minLength: 8)
        }
        .onAppear {
            //CoreDataManager.shared.deleteAllData(placement: Placement.dropped.rawValue)
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
    var body: some View {
        
        HStack(spacing: 10) {
            
            ZStack(alignment : .leading) {
                
                HStack(spacing : 16) {
                    EmptyCard()
                    EmptyCard()
                    EmptyCard()
                    EmptyCard()
                    EmptyCard()
                    EmptyCard()
                    EmptyCard()
                }
                
                LazyHStack (spacing : 16) {
                    ForEach(viewModel.stackImages, id: \.self) { model in
                        TopStoryCard(viewModel: viewModel, image: model.image)
                            .onDrag {
                                return NSItemProvider(object: model.imageName as NSItemProviderWriting)
                            }
                    }
                }
            }
            
            Button {
                viewModel.pickRandomImage()
            } label: {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 50, height: 50, alignment: .center)
            }
            .disabled(viewModel.stackImages.count == 7)
            .frame(width: 80, height: 50, alignment: .center)
            
        }
        .padding(.vertical,5)
        .frame(width: UIScreen.main.bounds.width, height: 120, alignment: .top)
        
        
    }
}

struct DropView: UIViewRepresentable {
    //var newImage: StoryModel?
    @ObservedObject var viewModel: StoryViewModel
    func makeUIView(context: Context) -> UIView {
        UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.subviews.filter({type(of: $0) == StoryCard.self}).forEach { subV in
            subV.removeFromSuperview()
        }
        for image in viewModel.droppedImages{
            let storyV = StoryCard(model:image, storyViewModel: viewModel, frame: image.frame)
            storyV.viewUpdated = { storyModel in
                if let index = viewModel.droppedImages.firstIndex(where: {$0.id
                    == storyModel.id }){
                    viewModel.droppedImages.removeAll(where: {$0.id == storyModel.id})
                    viewModel.droppedImages.append(storyModel)
//                    viewModel.droppedImages[index] = storyModel
                }
            }
            storyV.cardReturned = { (cardID, imgName) in
                viewModel.droppedImages.removeAll(where: {$0.id == cardID})
                viewModel.pickImageFromID(imgName: imgName)
            }
            
            storyV.cardRemoved = { cardID in
                viewModel.droppedImages.removeAll(where: {$0.id == cardID})
            }
            
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
                            
                            let cardFrame = CGRect(
                                x: info.location.x - (cardWidth / 2),
                                y: info.location.y - (cardHeight / 2),   ///2) + (cardHeight/2) + 50, //info.location.y - (cardHeight / 2),
                                width: cardWidth + 50,
                                height: cardHeight + 50)
                            print("location" + "\(info.location)")

                            dropImages.append(StoryModel(imageName: imgName, frame: cardFrame))
                        }
                    }
                }
            }
        }
        return true
    }
    
    
}
