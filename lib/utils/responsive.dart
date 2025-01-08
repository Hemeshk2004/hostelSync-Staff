import 'package:flutter/widgets.dart';

class Responsive {
  final BuildContext context;

  Responsive(this.context);

  // Get the width of the screen
  double get screenWidth => MediaQuery.of(context).size.width;

  // Get the height of the screen
  double get screenHeight => MediaQuery.of(context).size.height;

  // Get the device pixel ratio (for scaling)
  double get pixelRatio => MediaQuery.of(context).devicePixelRatio;

  // Scale width based on the screen size
  double scaleWidth(double inputWidth) {
    double screenWidth = MediaQuery.of(context).size.width;
    return inputWidth *
        (screenWidth / 375); // Assuming 375 as base screen width
  }

  // Scale height based on the screen size
  double scaleHeight(double inputHeight) {
    double screenHeight = MediaQuery.of(context).size.height;
    return inputHeight *
        (screenHeight / 667); // Assuming 667 as base screen height
  }
}
