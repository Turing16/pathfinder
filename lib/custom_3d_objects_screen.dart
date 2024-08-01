import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/widgets/ar_view.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector64;

class  Custom3dObjectsScreen extends StatefulWidget {
  const  Custom3dObjectsScreen({super.key});

  @override
  State< Custom3dObjectsScreen> createState() => _Custom3dObjectsScreenState();
}

class _Custom3dObjectsScreenState extends State< Custom3dObjectsScreen> {

  ARSessionManager? sessionManager;
  ARObjectManager? objectManager;
  ARAnchorManager? anchorManager;

  List<ARNode> allNodes = [];
  List<ARAnchor> allAnchors = [];


  whenARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager
      ){
    sessionManager = arSessionManager;
    objectManager = arObjectManager;
    anchorManager = arAnchorManager;

    sessionManager!.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      customPlaneTexturePath: "images/triangle.png",
      showWorldOrigin: true,
      handlePans: true,
      handleRotation: true
    );
    objectManager!.onInitialize();
    sessionManager!.onPlaneOrPointTap = whenPlaneDetectedAndUserTapped;
    objectManager!.onPanStart = whenOnPanStarted;
    objectManager!.onPanChange = whenOnPanChanged;
    objectManager!.onPanEnd = whenOnPanEnded;
    objectManager!.onRotationStart = whenOnRotationStarted;
    objectManager!.onRotationChange = whenOnRotationChanged;
    objectManager!.onRotationEnd = whenOnRotationEnded;
  }

  whenOnPanStarted(String nodeNew3dObject){
    print("Started panning node ${nodeNew3dObject}");
  }

  whenOnPanChanged(String nodeNew3dObject){
    print("Continued panning node ${nodeNew3dObject}");
  }

  whenOnPanEnded(String nodeNew3dObject, vector64.Matrix4 transform){
    print("Ended panning node ${nodeNew3dObject}");
    final pannedNode = allNodes.firstWhere((node) => node.name== nodeNew3dObject);
  }

  whenOnRotationStarted(String nodeNew3dObject){
    print("Rotation started ${nodeNew3dObject}");
  }

  whenOnRotationChanged(String nodeNew3dObject){
    print("Rotation continued ${nodeNew3dObject}");
  }

  whenOnRotationEnded(String nodeNew3dObject, Matrix4 transform){
    print("Rotation ended ${nodeNew3dObject}");
    final rotatedNode = allNodes.firstWhere((node)=>node.name == nodeNew3dObject);
  }


  Future<void> whenPlaneDetectedAndUserTapped(List<ARHitTestResult> tapRsults) async{
    var userHitTestResult = tapRsults.firstWhere((userTap)=>userTap.type ==ARHitTestResultType.plane);

    if(userHitTestResult != null){
      var newPlaneAnchor = ARPlaneAnchor(transformation: userHitTestResult.worldTransform);

      bool? isAnchorAdded = await anchorManager!.addAnchor(newPlaneAnchor);

      if(isAnchorAdded!){
        allAnchors.add(newPlaneAnchor);
        var nodeNew3dObject = ARNode(
            type: NodeType.webGLB,
            uri: "https://firebasestorage.googleapis.com/v0/b/pathfinder-2ea0b.appspot.com/o/puss_in_boots_pocket_shrek.glb?alt=media&token=71047e8f-a56f-497d-92c2-de48e87383f2",
            scale: vector64.Vector3(0.2,0.2,0.2),
            position: vector64.Vector3(0,0,0),
            rotation: vector64.Vector4(1.0,0,0,0)
        );

        bool? isNewNodeAdded = await objectManager!.addNode(nodeNew3dObject, planeAnchor: newPlaneAnchor);
        if(isNewNodeAdded!){
          allNodes.add(nodeNew3dObject);
        }
        else{
          sessionManager!.onError("Attaching node to anchor failed");
        }
      }
      else{
        sessionManager!.onError("Adding  anchor failed");
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Custom 3d Objects"),
      ),
      body: SizedBox(
        child: Stack(
          children: [
            ARView(
              planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
              onARViewCreated: whenARViewCreated,
            )
          ],
        ),
      ),
    );
  }
}
