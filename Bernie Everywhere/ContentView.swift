//
//  ContentView.swift
//  Bernie Everywhere
//
//  Created by Amol Kumar on 2021-01-23.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    @State var placeObject = false
    
    var body: some View {
        return ARViewContainer(isPlacementEnabled: $placeObject).edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    print(placeObject)
                }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var isPlacementEnabled: Bool
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.vertical,.horizontal]
        config.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        arView.debugOptions = [ARView.DebugOptions.showSceneUnderstanding]
        arView.session.run(config)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if isPlacementEnabled {
            let plane = try! ModelEntity.loadModel(named: "toy_biplane.usdz")
            let anchor = AnchorEntity(plane: .any)
            anchor.addChild(plane)
            uiView.scene.addAnchor(anchor)
            DispatchQueue.main.async {
                isPlacementEnabled = false
            }
        }
    }
    
    
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
