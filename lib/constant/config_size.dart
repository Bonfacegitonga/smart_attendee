// import 'package:flutter/material.dart';

// // class SizeConfig extends StatefulWidget {
// //   const SizeConfig({super.key});

// //   @override
// //   State<SizeConfig> createState() => _SizeConfigState();
// // }

// // class _SizeConfigState extends State<SizeConfig> {
// //   static late MediaQueryData _mediaQueryData;
// //   static  late double  screenWidth;
// //   static late double screenHeight;
// //   static late double defaultSize;
// //   static late Orientation orientation;

// //   @override
// //   void initState() {
// //     _mediaQueryData = MediaQuery.of(context);
// //      screenWidth = _mediaQueryData.size.width;
// //     screenHeight = _mediaQueryData.size.height;
// //     orientation = _mediaQueryData.orientation;
// //     super.initState();
// //   }

// //   @override
// //   void build(BuildContext context) {
// //     return Container();
// //   }
// // }

// class SizeConfig {
//   static MediaQueryData? _mediaQueryData;
//   static double? screenWidth = _mediaQueryData?.size.width;
//   static double? screenHeight = _mediaQueryData?.size.width;
//   static double? defaultSize = _mediaQueryData?.size.width;
//   static Orientation? orientation = _mediaQueryData?.orientation;

//   // void initState(BuildContext context) {
//   //   _mediaQueryData = MediaQuery.of(context);
//   //   //screenWidth = _mediaQueryData.size.width;
//   //   screenHeight = _mediaQueryData.size.height;
//   //   orientation = _mediaQueryData.orientation;
//   // }
// }

// // Get the proportionate height as per screen size
// double getProportionateScreenHeight(double inputHeight) {
//   double? screenHeight = SizeConfig.screenHeight;
//   // 812 is the layout height that designer use
//   return (inputHeight / 812.0) * screenHeight!;
// }

// // Get the proportionate height as per screen size
// double getProportionateScreenWidth(double inputWidth) {
//   double? screenWidth = SizeConfig.screenWidth;
//   // 375 is the layout width that designer use
//   return (inputWidth / 375.0) * screenWidth!;
// }
