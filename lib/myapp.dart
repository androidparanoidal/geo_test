import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geo_test/tile_func.dart';
import 'package:http/http.dart' as http;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _longCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _zoomCtrl = TextEditingController();
  int x_coord = 0;
  int y_coord = 0;
  String imageUrl = '';

  @override
  void dispose() {
    _longCtrl.dispose();
    _latCtrl.dispose();
    _zoomCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Get Tiles'),
          centerTitle: true,
        ),
        body: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextFormField(
                    controller: _longCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                    ],
                    decoration:
                        const InputDecoration(label: Text('Введите широту')),
                  ),
                  TextFormField(
                    controller: _latCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                    ],
                    decoration:
                        const InputDecoration(label: Text('Введите долготу')),
                  ),
                  TextFormField(
                    controller: _zoomCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                    ],
                    decoration:
                        const InputDecoration(label: Text('Введите масштаб')),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: displayTile,
                      child: const Text('Получить результат')),
                  //
                  const SizedBox(height: 10),
                  Text('x = $x_coord, y = $y_coord'),

                  Image.network(
                    imageUrl,
                    errorBuilder: (context, exception, stackTrace) {
                      return const Text('Ничего не найдено');
                    },
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Future<void> displayTile() async {
    final x = double.tryParse(_longCtrl.text);
    final y = double.tryParse(_latCtrl.text);
    final zoom = int.tryParse(_zoomCtrl.text);

    var tile = FuncTile();

    final pixelCoords = tile.getPixelCoord(x!, y!, zoom!);
    final tileNumbers = tile.getTileNumbers(pixelCoords[0], pixelCoords[1]);

    setState(() {
      x_coord = tileNumbers[0];
      y_coord = tileNumbers[1];
    });

    final url =
        'https://core-carparks-renderer-lots.maps.yandex.net/maps-rdr-carparks/tiles?l=carparks&x=$x_coord&y=$y_coord&z=$zoom&scale=1&lang=ru_RU';
    print(url);
    final response = await http.get(Uri.parse(url));
    print(response.statusCode);

    setState(() {
      imageUrl = response.statusCode == 200 ? url : '';
    });

    if (response.statusCode != 200) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ошибка'),
          content: const Text('Ничего не найдено'),
          actions: [
            TextButton(
              child: const Text('Повторить'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }
  }
}
