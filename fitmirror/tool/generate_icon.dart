import 'dart:io';
import 'package:image/image.dart';

void main() async {
  // Create a 1024x1024 icon
  final size = 1024;
  final img = Image(width: size, height: size);

  // Fill background with red gradient (simulated)
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      // Calculate distance from center for circle mask
      final dx = x - size / 2;
      final dy = y - size / 2;
      final dist = sqrt(dx * dx + dy * dy);

      if (dist < 480) {
        // Red gradient
        final gradientT = (x + y) / (size * 2);
        final r = (229 - gradientT * 30).toInt();
        final g = (57 - gradientT * 35).toInt();
        final b = (53 - gradientT * 25).toInt();
        img.setPixel(x, y, ColorRgba8(r.clamp(0, 255), g.clamp(0, 255), b.clamp(0, 255), 255));
      } else {
        // Transparent
        img.setPixel(x, y, ColorRgba8(0, 0, 0, 0));
      }
    }
  }

  // Draw white mirror frame (ellipse)
  drawEllipse(
    img,
    x1: size ~/ 2 - 200,
    y1: size ~/ 2 - 250,
    x2: size ~/ 2 + 200,
    y2: size ~/ 2 + 150,
    color: ColorRgba8(255, 255, 255, 230),
    thickness: 20,
  );

  // Draw dress silhouette
  final dressPath = <Point>[
    Point(380, 300),
    Point(340, 380),
    Point(340, 500),
    Point(380, 580),
    Point(380, 650),
    Point(440, 680),
    Point(584, 680),
    Point(644, 650),
    Point(644, 580),
    Point(684, 500),
    Point(684, 380),
    Point(644, 300),
  ];

  fillPolygon(img, dressPath, ColorRgba8(255, 255, 255, 240));

  // Draw hanger
  drawLine(
    img,
    x1: size ~/ 2,
    y1: 120,
    x2: size ~/ 2,
    y2: 200,
    color: ColorRgba8(255, 255, 255, 255),
    thickness: 12,
  );

  drawCircle(
    img,
    x: size ~/ 2,
    y: 100,
    radius: 25,
    color: ColorRgba8(255, 255, 255, 255),
    thickness: 10,
  );

  // Add sparkle dots
  fillCircle(img, x: 280, y: 320, radius: 12, color: ColorRgba8(255, 255, 255, 200));
  fillCircle(img, x: 740, y: 380, radius: 10, color: ColorRgba8(255, 255, 255, 180));
  fillCircle(img, x: 300, y: 560, radius: 8, color: ColorRgba8(255, 255, 255, 160));
  fillCircle(img, x: 720, y: 520, radius: 10, color: ColorRgba8(255, 255, 255, 170));

  // Save main icon
  final pngBytes = encodePng(img);
  await File('assets/images/app_icon.png').writeAsBytes(pngBytes);

  // Create adaptive icon foreground (no background)
  final fgImg = Image(width: size, height: size);
  // Transparent background
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      fgImg.setPixel(x, y, ColorRgba8(0, 0, 0, 0));
    }
  }

  // Draw the same elements but centered and smaller for adaptive icon
  final offset = 100;
  final scale = 0.7;

  // Draw mirror frame
  drawEllipse(
    fgImg,
    x1: (size / 2 - 200 * scale).toInt() + offset,
    y1: (size / 2 - 250 * scale).toInt(),
    x2: (size / 2 + 200 * scale).toInt() + offset,
    y2: (size / 2 + 150 * scale).toInt(),
    color: ColorRgba8(229, 57, 53, 255),
    thickness: 25,
  );

  // Draw dress
  final dressPathFg = <Point>[
    Point(380, 350),
    Point(350, 420),
    Point(350, 520),
    Point(390, 580),
    Point(390, 620),
    Point(450, 650),
    Point(574, 650),
    Point(634, 620),
    Point(634, 580),
    Point(674, 520),
    Point(674, 420),
    Point(644, 350),
  ];
  fillPolygon(fgImg, dressPathFg, ColorRgba8(229, 57, 53, 255));

  // Hanger
  drawLine(
    fgImg,
    x1: size ~/ 2 + offset,
    y1: 150,
    x2: size ~/ 2 + offset,
    y2: 220,
    color: ColorRgba8(229, 57, 53, 255),
    thickness: 14,
  );
  drawCircle(
    fgImg,
    x: size ~/ 2 + offset,
    y: 130,
    radius: 28,
    color: ColorRgba8(229, 57, 53, 255),
    thickness: 12,
  );

  final fgPngBytes = encodePng(fgImg);
  await File('assets/images/app_icon_foreground.png').writeAsBytes(fgPngBytes);

  print('Icons generated successfully!');
}
