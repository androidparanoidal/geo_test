import 'dart:math';

class FuncTile {
  List<double> getPixelCoord(double lat, double long, int z) {
    const eccentricity = 0.0818191908426;
    final rho = pow(2, z + 8) / 2;
    final beta = lat * pi / 180;
    final phi = (1 - eccentricity * sin(beta)) / (1 + eccentricity * sin(beta));
    final theta = tan(pi / 4 + beta / 2) * pow(phi, eccentricity / 2);

    final xP = rho * (1 + long / 180);
    final yP = rho * (1 - log(theta) / pi);

    return [xP, yP];
  }

  List<int> getTileNumbers(double x, double y) {
    var x_coord = (x / 256).floor();
    var y_coord = (y / 256).floor();
    return [x_coord, y_coord];
  }
}
