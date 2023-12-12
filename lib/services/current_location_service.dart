import 'package:geolocator/geolocator.dart';

class CurrentLocationService {
  Future<Position> determinePosition() async {
    var result = "";
    bool serviceEnabled = false;
    LocationPermission permission;
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      if (!serviceEnabled) {
        // await Geolocator.openLocationSettings();
        result = 'บริการตำแหน่งถูกปิดใช้งาน';
        print(result);
        return Future.error(result);
      } else {
        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.deniedForever) {
          await Geolocator.openLocationSettings();
          result =
              'สิทธิ์เข้าถึงตำแหน่งถูกปฏิเสธอย่างถาวรเราไม่สามารถขอสิทธิ์ได้';
          print(result);
          return Future.error(result);
        } else if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission != LocationPermission.whileInUse &&
              permission != LocationPermission.always) {
            await Geolocator.openLocationSettings();
            result = 'สิทธิ์เข้าถึงตำแหน่งถูกปฏิเสธ (ค่า: $permission).';
            print(result);
            return Future.error(result);
          }
        } else {
          return Future.error('สิทธิ์เข้าถึงตำแหน่งถูกปฏิเสธ');
        }
      }
    }
    result = 'สิทธิ์เข้าถึงตำแหน่งถูกปฏิเสธ (ค่า: $permission).';
    return Future.error(result);
  }
}
