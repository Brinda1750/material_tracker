import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _subscription;
  
  final _connectivityController = StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectivityController.stream;
  
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  
  ConnectivityHelper() {
    _initConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }
  
  Future<void> _initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      result = ConnectivityResult.none;
    }
    
    return _updateConnectionStatus(result);
  }
  
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    _isConnected = result != ConnectivityResult.none;
    _connectivityController.add(_isConnected);
  }
  
  void dispose() {
    _subscription.cancel();
    _connectivityController.close();
  }
}
