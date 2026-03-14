import 'dart:async';
import 'dart:io';
import '../../services/app_logger.dart';

/// Servicio para verificar conectividad a internet
class ConnectivityService {
  static ConnectivityService? _instance;

  ConnectivityService._();

  static ConnectivityService get instance =>
      _instance ??= ConnectivityService._();

  /// Verificar si hay conexión a internet
  Future<bool> hasConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } catch (e) {
      appLogger.warning('Error verificando conectividad: $e');
      return false;
    }
  }

  /// Verificar si el backend está accesible
  Future<bool> isBackendReachable(String baseUrl) async {
    try {
      final uri = Uri.parse('$baseUrl/health');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);

      final request = await client.getUrl(uri);
      final response = await request.close();
      client.close();

      return response.statusCode == 200;
    } catch (e) {
      appLogger.warning('Backend no accesible: $e');
      return false;
    }
  }
}
