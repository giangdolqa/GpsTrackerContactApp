// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



class HomeView extends StatefulWidget {
  HomeView();

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  // Global key
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  Timer myTimer;
  Timer occupiedCheckTimer;


  WidgetsBinding widgetsBinding;
  Color _statusbarColor = Colors.white;

  // user name
  String _userName = "";

  // phone number
  String _phoneNumber = "";

  @override
  void dispose() {
    // tabController.dispose();

    if (myTimer != null) {
      myTimer.cancel();
    }
    if (occupiedCheckTimer != null) {
      occupiedCheckTimer.cancel();
    }
//    if (positionStream != null) {
//      positionStream.cancel();
//    }

    super.dispose();
  }

  //
  // void updateDrawerInfo() async {
  //   _userName = "";
  //   _phoneNumber = "";
  //   String tempName = await mapService.GetUserName();
  //   String tempPhn = await mapService.GetPhoneNumber();
  //   setState(() {
  //     _userName = tempName;
  //     _phoneNumber = tempPhn;
  //   });
  // }
//
//   Future<bool> _onWillPop() async {
//     return (await showDialog(
//       context: context,
//       builder: (context) => new AlertDialog(
//         titlePadding: EdgeInsets.all(12),
//         contentPadding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
//         backgroundColor: MyTheme.DialogBackgroundColor,
//         title: Text(S.of(context).cmn_sure_to_quit_title),
//         content: Text(S.of(context).cmn_sure_to_quit_content),
//         actions: <Widget>[
//           new RaisedButton(
//             onPressed: () {
//               // Play click sound
//               SoundUtil.playAssetSound(null);
//               Navigator.of(context).pop(false);
//             },
//             child: new Text(S.of(context).cmn_cancel),
//           ),
//           new RaisedButton(
// //                onPressed: () => Navigator.of(context).pop(true),
//             onPressed: () {
//               // Play click sound
//               SoundUtil.playAssetSound(null);
//               exit(0);
//             },
//             child: new Text(S.of(context).cmn_ok),
//           ),
//         ],
//       ),
//     )) ??
//         false;
//   }
//
//   Widget _buildDrawer(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         dragStartBehavior: DragStartBehavior.down,
//         children: <Widget>[
//           DrawerHeader(
//             child: Row(
//               children: <Widget>[
//                 Container(
//                   padding: EdgeInsets.all(10),
//                   decoration: new BoxDecoration(
//                     color: MyTheme.GreyAccent,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     FontAwesomeIcons.userTie,
//                     color: Colors.grey[800],
//                     size: 40,
//                   ),
//                 ),
//                 Expanded(
//                   child: Container(
//                     padding: EdgeInsets.only(left: 20),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         Container(
//                           padding: EdgeInsets.only(bottom: 5),
//                           child: Text(
//                             _userName == null ? "" : _userName,
//                             style: TextStyle(fontSize: MyTheme.FontSizeBigger),
//                           ),
//                         ),
//                         Container(
//                           child: Text(
//                             _phoneNumber == null ? "" : _phoneNumber,
//                             style: TextStyle(
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Personal Info
//           ListTile(
//             leading: Icon(Icons.account_circle),
//             title: Text(S.of(context).personal_title),
//             onTap: _handlePersonalInfo,
//             // selected: true,
//           ),
//           // License Info
//           ListTile(
//             leading: Icon(FontAwesomeIcons.idBadge),
//             title: Text(S.of(context).license_edit_title),
//             onTap: _handleLicenseInfo,
//             // selected: true,
//           ),
//           Divider(
// //            color: Colors.grey[500],
//           ),
//           // Logout
//           ListTile(
//             leading: Icon(FontAwesomeIcons.signOutAlt),
//             title: Text(S.of(context).logout_title),
//             onTap: _handleLogout,
//           ),
//           // About
//           ListTile(
//             leading: Icon(Icons.help),
//             title: Text(S.of(context).about_title),
//             onTap: _handleShowAbout,
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _timeOut() async {
//     Position position = await positionUtil.GetCurrentPos();
//     _driverPositionNotify(position);
//   }
//
//   void _timeOutOccupiedCheck() async {
//     _occupiedCheck();
//   }
//
//   void _occupiedCheck() async {
//     try {
//       Map<String, dynamic> paraMap = {
//         "pageSize": "10",
//         "pageNo": "1",
//       };
//       List<OrderItemContent> tempList = await mapService.GetAcceptedHistoryList(paraMap);
//       bool isOccupied = false;
//       if (tempList != null) {
//         tempList.forEach((orderItemContent) async {
//           if (!isOccupied) {
//             if (orderItemContent.status == "2") {
//               // Accepted
//               DateTime orderTS = DateTime.parse(orderItemContent.orderTime);
//               DateTime currentTS = DateTime.now();
// //              print(currentTS.toIso8601String());
// //              print(orderItemContent.orderTime);
//               if (!orderTS.isAfter(currentTS)) {
//                 isOccupied = true;
//                 bool oState = await spUtil.GetOccupyState();
//                 if (!oState) {
//                   if (orderItemContent.orderNo != null) {
//                     Map<String, dynamic> dataMap = {"orderNo": orderItemContent.orderNo};
//                     mapService.OccupiedNotice(dataMap);
//                   }
//                   spUtil.SetOccupyState(true);
//                   bool popRlst = await PopupUtil.showConfirmOKDialog(context, S.of(context).map_occupied_title, S.of(context).map_occupied_content);
//                   if (popRlst == null) {
//                     eventBus.fire(OrderUpdateEvent(orderItemContent));
//                     tabController.animateTo(MapTabs.Map.index);
//                   } else {
//                     eventBus.fire(OrderUpdateEvent(orderItemContent));
//                     tabController.animateTo(MapTabs.Map.index);
//                   }
//                 }
//                 return;
//               }
//             }
//           }
//         });
//       }
//       if (!isOccupied) {
//         spUtil.SetOccupyState(false);
// //        _setOccupied(false);
//       }
//     } catch (e) {
//       print(e.toString());
//     }
//   }
//
// //
// //  void _setOccupied(bool isOccupied) async {
// //    // Set Occupied
// //    spUtil.SetOccupyState(isOccupied);
// //    return;
// //  }
//
//   Position lastPosition;
//
//   void _driverPositionNotify(Position position) async {
//     if (position == null) return;
//     double curDirection;
//     if (lastPosition == null) {
//       curDirection = 0.0;
//     } else {
//       double xVal = position.latitude - lastPosition.latitude;
//       double yVal = position.longitude - lastPosition.longitude;
//       curDirection = atan2(xVal, yVal) / pi * 180.00;
//     }
//     Map<String, dynamic> dataMap = {
// //      "longitude": position.longitude.toString(),
// //      "latitude": position.latitude.toString(),
// //      "direction": curDirection,
// //      "speed": position.speed.toString(),
//     };
//     //print("_driverPositionNotify:" + curDirection.toString());
//     mapService.DriverPositionNotify(dataMap);
//     lastPosition = position;
//   }
//
//   void _handlePersonalInfo() async {
//     var tempVar = await Navigator.of(context).pushNamed("PersonalInfo");
//     updateDrawerInfo();
//   }
//
//   void _handleLicenseInfo() {
//     Navigator.of(context).pushNamed("LicenseInfo");
//   }
//
//   void _handleLogout() async {
//     bool bRlst = true;
//     bRlst = await PopupUtil.showConfirmDialog(context, S.of(context).cmn_sure_to_do_title, S.of(context).cmn_sure_to_do_content);
//     if (!bRlst ?? true) {
//       return;
//     }
//     mapService.DoLogout();
// //    Navigator.of(context).popUntil(ModalRoute.withName('Login'));
//     Navigator.of(context).popUntil((route) => route.isFirst);
//   }
//
//   void _handleShowAbout() {
//     showAboutDialog(
//       context: context,
//       applicationName: S.of(context).title,
//       applicationLegalese: S.of(context).about_content,
//       applicationVersion: S.of(context).version,
//     );
//   }
//
//   TabController tabController;
//
//   Widget buildAppBar() {
//     return PreferredSize(
//       child: TabBar(
//         controller: tabController,
//         tabs: <Widget>[
//           Tab(text: S.of(context).order),
//           Tab(text: S.of(context).map),
//           Tab(text: S.of(context).history),
//         ],
//         labelColor: Colors.amber[900],
//         labelStyle: TextStyle(
//           fontSize: MyTheme.FontSizeNormal,
//           fontWeight: FontWeight.bold,
//           shadows: [
//             Shadow(color: Color(0x33000000), blurRadius: 3, offset: Offset(1, 1)),
//           ],
//         ),
//       ),
//       preferredSize: Size.fromHeight(50),
//     );
//   }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
//      onWillPop: _onWillPop,
      child: Container(
        color: _statusbarColor,
        child: SafeArea(
//          maintainBottomViewPadding: true,
          child: new Scaffold(
            body: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
            // floatingActionButton: FloatingActionButton.extended(
            //   onPressed: _goToTheLake,
            //   label: Text('To the lake!'),
            //   icon: Icon(Icons.directions_boat),
            // ),
          ),
        ),
      ),
    );
  }
}
