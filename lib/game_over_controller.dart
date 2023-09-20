// import 'dart:ui';

// import 'package:flutter/material.dart';

// class GameOverController extends ChangeNotifier {
//   late OverlayState overlayState;
//   late OverlayEntry overlayEntry;

//   static GameOverController of(BuildContext context) {
//     return LookupBoundary.dependOnInheritedWidgetOfExactType<GameOverController>(context)!;
//   }

//   void removeOverlay() => overlayEntry.remove();

//   @override
//   void dispose() {
//     removeOverlay();
//     super.dispose();
//   }

//   void showOverlay(BuildContext context) async {
//     overlayState = Overlay.of(context);
//     overlayEntry = OverlayEntry(builder: (context) {
//       return BackdropFilter(
//         filter: ImageFilter.blur(
//           sigmaX: 3,
//           sigmaY: 3,
//         ),
//         child: Container(
//           color: Colors.black.withOpacity(0),
//           width: MediaQuery.of(context).size.width,
//           height: MediaQuery.of(context).size.height,
//           child: Center(
//             child: ElevatedButton(
//               onPressed: () {
//                 removeOverlay();
//               },
//               child: const Text('Remove Overlay'),
//             ),
//           ),
//         ),
//       );
//     });
//     // inserting overlay entry

//     overlayState.insert(overlayEntry);
//   }
// }
