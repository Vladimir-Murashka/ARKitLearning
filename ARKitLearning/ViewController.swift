//
//  ViewController.swift
//  ARKitLearning
//
//  Created by Swift Learning on 10.06.2022.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    var planes = [Plane]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
      
        sceneView.autoenablesDefaultLighting = true
        
        let scene = SCNScene()
       
        sceneView.scene = scene
        
        sceneView.scene.physicsWorld.contactDelegate = self
    }
    
    func setupGestures() {
        
        let tapGesureRecognizer = UITapGestureRecognizer(target: self, action: #selector(placeBox))
        tapGesureRecognizer.numberOfTapsRequired = 1
        self.sceneView.addGestureRecognizer(tapGesureRecognizer)
    }
    
    @objc func placeBox(tapGesture: UITapGestureRecognizer) {
        
        let sceneView = tapGesture.view as! ARSCNView
        let location = tapGesture.location(in: sceneView)
        
        let hitTestResult = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
        guard let hitResult = hitTestResult.first else { return }
        
        createBox(hitResult: hitResult)
    }
    
    func createBox(hitResult: ARHitTestResult) {
        
        let position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                  hitResult.worldTransform.columns.3.y + 0.1 + 0.5,
                                  hitResult.worldTransform.columns.3.z)
        
        let box = Box(atPosition: position)
        sceneView.scene.rootNode.addChildNode(box)
       
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard anchor is ARPlaneAnchor else { return }
        
        let plane = Plane(anchor: anchor as! ARPlaneAnchor)
        self.planes.append(plane)
        node.addChildNode(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        let plane = self.planes.filter { plane in
            return plane.anchor.identifier == anchor.identifier
        }.first
        
        guard plane != nil else { return }
        plane?.update(anchor: anchor as! ARPlaneAnchor)
        
    }
    
}

extension ViewController: SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        if nodeB.physicsBody?.contactTestBitMask == BitMaskCategory.box {
            nodeA.geometry?.materials.first?.diffuse.contents = UIColor.red
        } else {
            nodeB.geometry?.materials.first?.diffuse.contents = UIColor.red
        }
    }
}
