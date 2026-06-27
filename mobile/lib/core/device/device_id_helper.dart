import 'package:device_info_plus/device_info_plus.dart';

class DeviceIdHelper {
  DeviceIdHelper._();

  static final DeviceInfoPlugin _plugin = DeviceInfoPlugin();

  static Future<String> getDeviceId() async {
    try {
      final info = await _plugin.deviceInfo;
      if (info is AndroidDeviceInfo) {
        return info.id;
      }
      if (info is IosDeviceInfo) {
        return info.identifierForVendor ?? 'unknown-ios-device';
      }
      if (info is WebBrowserInfo) {
        return info.vendor ?? 'unknown-web';
      }
      if (info is LinuxDeviceInfo) {
        return info.machineId ?? 'unknown-linux';
      }
      return 'unknown-device';
    } catch (_) {
      return 'unknown-device';
    }
  }
}
