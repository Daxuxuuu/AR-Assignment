//
//  ContentView.swift
//  AR
//
//  Created by zzy on 2022/5/2.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    @State private var isPlacementEnable = false
    @State private var selectedModel : String?
    @State private var modelConfirmedForPlacement : String?
    
    
    var models : [String] = ["fender_stratocaster","flower_tulip","toy_biplane","slide_stylized"]
    
    let filemanger = FileManager.default
    guard let path = Bundle.main.resourcePath, let files = try?filemanger.contentsOfDirectory(atPath: Path)else{
        
    }
    
    var body: some View {
        ZStack(alignment: .bottom){
            ARViewContainer(modelConfirmedForPlacement: $modelConfirmedForPlacement)
            
            if self.isPlacementEnable{
                PlacementButtonView(isPlacementEnable: self.$isPlacementEnable, selectedModel: $selectedModel, modelCondirmedForPlacement: self.$modelConfirmedForPlacement)
            }else{
                ARViewModel(isPlacementEnable: self.$isPlacementEnable, selectedModel: $selectedModel, models: self.models)
            }
            
           
        }
        .ignoresSafeArea()
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var modelConfirmedForPlacement:String?
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        if
            ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh){
            ARWorldTrackingConfiguration.SceneReconstruction = .mesh
        }
        
        arView.session.run(config)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let modelName = self.modelConfirmedForPlacement{
            
            print("DEBUG: adding model to scene - \(modelName)")
            
            let filename = modelName + ".usdz"
            let modelEntity = try! ModelEntity.loadModel(named: filename)
            let anchorEntity = AnchorEntity(plane: any)
            
            DispatchQueue.main.async {
                self.modelConfirmedForPlacement = nil
            }
            
        }
            
    }
    
    
}

struct ARViewModel: View{
    @Binding var isPlacementEnable: Bool
    @Binding var selectedModel: String?
    
    var models: [String]
    var body: some View{
        ScrollView(.horizontal,showsIndicators: false){
            HStack(spacing:30){
                ForEach( 0 ..< self.models.count){ index in
                    Button {
                        print("DEBUG:select models with name:\(self.models[index])")
                        
                        self.selectedModel = self.models[index]
                        
                        isPlacementEnable = true
                    } label: {
                        Image(uiImage: UIImage(named: self.models[index])!)
                            .resizable()
                            .frame(height: 80)
                            .aspectRatio(1/1, contentMode: .fit)
                            .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())

                }
            }
        }
        
        .padding(20)
        .background(Color.black.opacity(0.5))
    }
}

struct PlacementButtonView: View{
    @Binding var isPlacementEnable: Bool
    @Binding var selectedModel: String?
    @Binding var modelCondirmedForPlacement: String?
    
    var body: some View{
        HStack{
            //cancel button
            Button {
                print("DEBUG: Model placement canceled.")
                
                self.resetPlacementEnable()
            } label: {
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(30)
                    .padding(20)
            }
            //confirm button
            Button {
                print("DEBUG: Model placement confirmed.")
                
                self.modelCondirmedForPlacement = self.selectedModel
                
                self.resetPlacementEnable()
            } label: {
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(30)
                    .padding(20)
            }
        }
    }
    
    func resetPlacementEnable(){
        self.isPlacementEnable = false
        self.selectedModel = nil
    }
}



#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
