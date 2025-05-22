import 'dart:convert';

import 'package:pusher_client_socket/pusher_client_socket.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../NetworkHandler.dart';
import 'package:pusher_client_socket/channels/channel.dart';
class PusherService {
  late PusherClient _pusher;
   Channel? _channel;

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<void> initializePusher() async {
    try {
      String? token = await storage.read(key: "token");
      if (token == null) {
        throw Exception("Token not found in storage.");
      }
    print(token);
      final options = PusherOptions(
        key: '55634fa2b864e7f12583',
        cluster: 'mt1',
        host: 'ws.pusherapp.com',
        // encrypted: true,
        // host: 'diligov.com',
        wsPort: 80,
        wssPort: 443,
        encrypted: false,
        authOptions: PusherAuthOptions(
          'https://diligov.com/broadcasting/auth',
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
        enableLogging: true,
        autoConnect: false,
        // reconnectGap: const Duration(seconds: 1),
      );

          _pusher = PusherClient(options: options);

      _pusher.onConnectionEstablished((data) {
        print("Connection established - socket-id: ${_pusher.socketId}");
      });
      _pusher.onConnectionError((error) {
        print("Connection error - $error");
      });
      _pusher.onError((error) {
        print("Error - $error");
      });
      _pusher.onDisconnected((data) {
        print("Disconnected - $data");
      });
      print("Pusher Host: ${options.host}");


    } catch (e) {
      print("Error initializing Pusher: $e");
    }
  }




  Future<void> connect(String channelName) async {
    if (_pusher == null) {
      throw Exception("Pusher is not initialized. Call initializePusher() first.");
    }
    try {
      if (_channel == null) {
        _channel = _pusher.subscribe(channelName);
        _channel!.bind('pusher:subscription_succeeded', (_) {
          print('Successfully subscribed to $channelName');
        });
        _channel!.bind('pusher:subscription_error', (error) {
          print('Subscription error: $error');
        });
      } else {
        print("Already subscribed to channel: $channelName");
      }
    } catch (e) {
      print('Error connecting to Pusher channel: $e');
      throw e;
    }
  }

  void listenToPageChanges(Function(int) onPageChanged) {
    if (_channel != null) {
      _channel!.bind('page-number-changed', (event) {
        try {
          final pageNumber = int.parse(event?.data ?? '0');
          onPageChanged(pageNumber);
        } catch (e) {
          print('Error parsing page number: $e');
        }
      });
    } else {
      print("Channel is not initialized. Call connect() first.");
    }
  }

  void disconnect() {
    if (_channel != null) {
      _pusher.unsubscribe(_channel!.name);
    }
    _pusher.disconnect();
    print('Disconnected from Pusher.');
  }

  // int currentPage = 1;
  // Future<void> sendPageChange(int pageNumber) async {
  //   try {
  //     NetworkHandler networkHandler = NetworkHandler();
  //     Map<String, dynamic> data = {'pageNumber': pageNumber};
  //     final response = await networkHandler.post1('/page-change', data);
  //
  //     if (response.statusCode == 200) {
  //       print('Page change event sent successfully: ${response.body}');
  //       final data = json.decode(response.body);
  //       currentPage = data['fileId'];
  //     } else {
  //       print('Failed to notify page change: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Error sending page change event: $e');
  //   }
  // }

  // Channel get channel {
  //   if (_channel == null) {
  //     throw Exception('Channel is not initialized. Call connect first.');
  //   }
  //   return _channel;
  // }
}
