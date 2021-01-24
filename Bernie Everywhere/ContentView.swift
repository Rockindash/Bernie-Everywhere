//
//  ContentView.swift
//  Bernie Everywhere
//
//  Created by Amol Kumar on 2021-01-23.
//

import ARKit
import SwiftUI
import RealityKit

struct ContentView : View {
    @State var placeObject = false
    
    var body: some View {
        return ARViewContainer(isPlacementEnabled: $placeObject).edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    placeObject = true
                }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var isPlacementEnabled: Bool
    
    // MARK: - View Setup
    func makeUIView(context: Context) -> ARView {
        
        // Plane Detection Configuration
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.vertical,.horizontal]
        config.environmentTexturing = .automatic
        
        // Adding mesh for device with LIDAR support
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        // Addign debug options
        arView.debugOptions = [ARView.DebugOptions.showSceneUnderstanding]
        arView.session.run(config)
        return arView
    }
    
    // MARK: - Adding MVP to the Scene
    func updateUIView(_ uiView: ARView, context: Context) {
        if isPlacementEnabled {
            var material = UnlitMaterial()
            let resource = try? TextureResource.load(named: "Bernie.png")
            let mesh = MeshResource.generatePlane(width: 0.5, height: 1)
            material.baseColor = MaterialColorParameter.texture(resource!)
            material.tintColor = UIColor.white.withAlphaComponent(0.99)
            
            let modelEntity = ModelEntity(mesh: mesh, materials: [material])
            let anchorEntity = AnchorEntity(plane: .any)
            anchorEntity.addChild(modelEntity)
            uiView.scene.addAnchor(anchorEntity)
            
            DispatchQueue.main.async {
                isPlacementEnabled = false
            }
        }
    }
}

struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
