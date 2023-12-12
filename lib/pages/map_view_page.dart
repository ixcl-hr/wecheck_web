import 'package:flutter/material.dart';

import 'package:flutter/gestures.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/util_service.dart';

class MapViewPage extends StatefulWidget {
  const MapViewPage({Key? key, required this.lat, required this.lng})
      : super(key: key);
  //final String title = "ที่อยู่ปัจจุบัน";
  final double lat;
  final double lng;
  @override
  MapViewPageState createState() => MapViewPageState(lat, lng);
}

class MapViewPageState extends State<MapViewPage> {
  // var profile;

  MapViewPageState(double lat, double lng) {
    this.lat = lat;
    this.lng = lng;

    controller = MapController(location: LatLng(lat, lng), zoom: zoom);
  }

  double lat = 0;
  double lng = 0;
  double zoom = 18;
  late MapController controller;

  @override
  void initState() {
    super.initState();

    // _launchInWebViewWithJavaScript(
    //     "https://www.google.co.th/maps/@$widget.lat,$widget.lng,17z");
    // //Enable virtual display.
    //if (!kIsWeb && Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  bool isLoading = true;

  final bool _darkMode = false;

  // final markers = [
  //   LatLng(35.674, 51.41),
  //   LatLng(35.676, 51.41),
  //   LatLng(35.678, 51.41),
  //   LatLng(35.68, 51.41),
  //   LatLng(35.682, 51.41),
  //   LatLng(35.684, 51.41),
  //   LatLng(35.686, 51.41),
  // ];

  void _gotoDefault() {
    controller.center = LatLng(lat, lng);
    setState(() {});
  }

  void _onDoubleTap() {
    controller.zoom += 0.5;
    setState(() {});
  }

  Offset? _dragStart;
  double _scaleStart = 1.0;
  void _onScaleStart(ScaleStartDetails details) {
    _dragStart = details.focalPoint;
    _scaleStart = 1.0;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final scaleDiff = details.scale - _scaleStart;
    _scaleStart = details.scale;

    if (scaleDiff > 0) {
      controller.zoom += 0.02;
      setState(() {});
    } else if (scaleDiff < 0) {
      controller.zoom -= 0.02;
      setState(() {});
    } else {
      final now = details.focalPoint;
      final diff = now - _dragStart!;
      _dragStart = now;
      controller.drag(diff.dx, diff.dy);
      setState(() {});
    }
  }

  Widget _buildMarkerWidget(Offset pos, Color color) {
    return Positioned(
      left: pos.dx - 16,
      top: pos.dy - 16,
      width: 50, //24,
      height: 50, //24,
      child: Icon(
        Icons.location_on,
        color: color,
        size: 50,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UtilService.getTextFromLang("map", "แผนที่")),
        actions: const [
          // IconButton(
          //   tooltip: 'Toggle Dark Mode',
          //   onPressed: () {
          //     setState(() {
          //       _darkMode = !_darkMode;
          //     });
          //   },
          //   icon: Icon(Icons.wb_sunny),
          // ),
        ],
      ),
      body: MapLayoutBuilder(
        controller: controller,
        builder: (context, transformer) {
          // final markerPositions =
          //     markers.map(transformer.fromLatLngToXYCoords).toList();

          // final markerWidgets = markerPositions.map(
          //   (pos) => _buildMarkerWidget(pos, Colors.red),
          // );

          final homeLocation = transformer.toOffset(LatLng(lat, lng));

          final homeMarkerWidget = _buildMarkerWidget(homeLocation, Colors.red);

          final centerLocation = Offset(
              transformer.constraints.biggest.width / 2,
              transformer.constraints.biggest.height / 2);

          final centerMarkerWidget =
              _buildMarkerWidget(centerLocation, Colors.purple);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onDoubleTap: _onDoubleTap,
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            onTapUp: (details) {
              final location = transformer.toLatLng(details.localPosition);

              final clicked = transformer.toOffset(location);

              print('${location.longitude}, ${location.latitude}');
              print('${clicked.dx}, ${clicked.dy}');
              print('${details.localPosition.dx}, ${details.localPosition.dy}');
            },
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  final delta = event.scrollDelta;

                  controller.zoom -= delta.dy / 1000.0;
                  setState(() {});
                }
              },
              child: Stack(
                children: [
                  Map(
                    controller: controller,
                    builder: (context, x, y, z) {
                      //Legal notice: This url is only used for demo and educational purposes. You need a license key for production use.

                      //Google Maps
                      final url =
                          'https://www.google.com/maps/vt/pb=!1m4!1m3!1i$z!2i$x!3i$y!2m3!1e0!2sm!3i420120488!3m7!2sen!5e1105!12m4!1e68!2m2!1sset!2sRoadmap!4e0!5m1!1e0!23i4111425';

                      final darkUrl =
                          'https://maps.googleapis.com/maps/vt?pb=!1m5!1m4!1i$z!2i$x!3i$y!4i256!2m3!1e0!2sm!3i556279080!3m17!2sen-US!3sUS!5e18!12m4!1e68!2m2!1sset!2sRoadmap!12m3!1e37!2m1!1ssmartmaps!12m4!1e26!2m2!1sstyles!2zcC52Om9uLHMuZTpsfHAudjpvZmZ8cC5zOi0xMDAscy5lOmwudC5mfHAuczozNnxwLmM6I2ZmMDAwMDAwfHAubDo0MHxwLnY6b2ZmLHMuZTpsLnQuc3xwLnY6b2ZmfHAuYzojZmYwMDAwMDB8cC5sOjE2LHMuZTpsLml8cC52Om9mZixzLnQ6MXxzLmU6Zy5mfHAuYzojZmYwMDAwMDB8cC5sOjIwLHMudDoxfHMuZTpnLnN8cC5jOiNmZjAwMDAwMHxwLmw6MTd8cC53OjEuMixzLnQ6NXxzLmU6Z3xwLmM6I2ZmMDAwMDAwfHAubDoyMCxzLnQ6NXxzLmU6Zy5mfHAuYzojZmY0ZDYwNTkscy50OjV8cy5lOmcuc3xwLmM6I2ZmNGQ2MDU5LHMudDo4MnxzLmU6Zy5mfHAuYzojZmY0ZDYwNTkscy50OjJ8cy5lOmd8cC5sOjIxLHMudDoyfHMuZTpnLmZ8cC5jOiNmZjRkNjA1OSxzLnQ6MnxzLmU6Zy5zfHAuYzojZmY0ZDYwNTkscy50OjN8cy5lOmd8cC52Om9ufHAuYzojZmY3ZjhkODkscy50OjN8cy5lOmcuZnxwLmM6I2ZmN2Y4ZDg5LHMudDo0OXxzLmU6Zy5mfHAuYzojZmY3ZjhkODl8cC5sOjE3LHMudDo0OXxzLmU6Zy5zfHAuYzojZmY3ZjhkODl8cC5sOjI5fHAudzowLjIscy50OjUwfHMuZTpnfHAuYzojZmYwMDAwMDB8cC5sOjE4LHMudDo1MHxzLmU6Zy5mfHAuYzojZmY3ZjhkODkscy50OjUwfHMuZTpnLnN8cC5jOiNmZjdmOGQ4OSxzLnQ6NTF8cy5lOmd8cC5jOiNmZjAwMDAwMHxwLmw6MTYscy50OjUxfHMuZTpnLmZ8cC5jOiNmZjdmOGQ4OSxzLnQ6NTF8cy5lOmcuc3xwLmM6I2ZmN2Y4ZDg5LHMudDo0fHMuZTpnfHAuYzojZmYwMDAwMDB8cC5sOjE5LHMudDo2fHAuYzojZmYyYjM2Mzh8cC52Om9uLHMudDo2fHMuZTpnfHAuYzojZmYyYjM2Mzh8cC5sOjE3LHMudDo2fHMuZTpnLmZ8cC5jOiNmZjI0MjgyYixzLnQ6NnxzLmU6Zy5zfHAuYzojZmYyNDI4MmIscy50OjZ8cy5lOmx8cC52Om9mZixzLnQ6NnxzLmU6bC50fHAudjpvZmYscy50OjZ8cy5lOmwudC5mfHAudjpvZmYscy50OjZ8cy5lOmwudC5zfHAudjpvZmYscy50OjZ8cy5lOmwuaXxwLnY6b2Zm!4e0&key=AIzaSyAOqYYyBbtXQEtcHG7hwAwyCPQSYidG8yU&token=31440';
                      //Mapbox Streets
                      // final url =
                      //     'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/$z/$x/$y?access_token=YOUR_MAPBOX_ACCESS_TOKEN';

                      return CachedNetworkImage(
                        imageUrl: _darkMode ? darkUrl : url,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  homeMarkerWidget,
                  // ...markerWidgets,
                  //centerMarkerWidget,
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _gotoDefault,
        tooltip: 'My Location',
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
