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
        
        // People Occlusions
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            config.frameSemantics.insert(.personSegmentationWithDepth)
        }
        
        // Addign debug options
//        arView.debugOptions = [ARView.DebugOptions.showSceneUnderstanding]
        arView.session.run(config)
        
        return arView
    }
    
    // MARK: - Adding MVP to the Scene
    func updateUIView(_ uiView: ARView, context: Context) {
        if isPlacementEnabled {
            let plane = try! ModelEntity.loadModel(named: "Bernie.usdz")
            let anchor = AnchorEntity(plane: .any)
            anchor.addChild(plane)
            uiView.scene.addAnchor(anchor)
            
            let light = Lighting()
            light.orientation = simd_quatf(angle: .pi/8, axis: [0, 1, 0])
            
            let directLightAnchor = AnchorEntity()
            directLightAnchor.addChild(light)
            uiView.scene.addAnchor(directLightAnchor)
            
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

class Lighting: Entity, HasDirectionalLight, HasAnchoring {

    required init() {
        super.init()

        self.light = DirectionalLightComponent(color: .white,
                                           intensity: 1000,
                                    isRealWorldProxy: true)
    }
}
