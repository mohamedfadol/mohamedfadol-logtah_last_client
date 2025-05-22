import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pusher_client_socket/pusher_client_socket.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/domains/app_uri.dart';
import '../../../../models/preview_meeting_model.dart';
import '../../../../providers/meeting_page_provider.dart';
import '../../../../widgets/custom_icon.dart';
import '../../../../widgets/custome_text.dart';
class PdfPreviewScreen extends StatefulWidget {
  final String fileId;
  final PreviewMeetingModel previewMeeting;
  final bool isAdmin;
  const PdfPreviewScreen({required this.fileId, required this.previewMeeting, required this.isAdmin, Key? key}) : super(key: key);

  @override
  _PdfPreviewScreenState createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  late PdfViewerController _pdfViewerController;
  late PusherClient _pusher;
  late Channel _channel;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isPusherInitialized = false;
  String? _error;
  int _lastSentPage = 1; // Stores the last sent page number
  bool _isProcessingPageChange = false;
  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _initializePusher();
  }

  Future<void> _initializePusher() async {
    try {
      String? token = await _storage.read(key: "token");
      if (token == null) {
        throw Exception("Token not found in storage.");
      }

      final options = PusherOptions(
        key: '55634fa2b864e7f12583',
        cluster: 'mt1',
        wsPort: 80,
        host: 'ws.pusherapp.com',
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
        reconnectGap: const Duration(seconds: 2),
      );
      _pusher = PusherClient(options: options);
      _pusher.onConnectionEstablished((data) {
        print("Pusher connection established. Socket ID: ${_pusher.socketId}");
        _subscribeToChannel();
      });
      _pusher.onConnectionError((error) {
        print("Pusher connection error: $error");
      });
      _pusher.connect();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      print("Error initializing Pusher: $e");
    }
  }

  void _subscribeToChannel() {
    try {
      _channel = _pusher.subscribe('file.${widget.fileId}');
      _channel.bind('pusher:subscription_succeeded', (_) {
        print("Successfully subscribed to channel file.${widget.fileId}");
        setState(() {
          _isPusherInitialized = true;
        });
      });
      _channel.bind('page-number-changed', (event) {
        try {
          // Log the raw event data for debugging
          print('Raw event data: ${event['page']}');
          // Extract the 'page' field from the payload
          final pageNumber = event['page'];
          // Validate and use the page number
          if (pageNumber != null && pageNumber is int && pageNumber > 0) {
            Future.delayed(Duration(seconds: 1), () {
              // if (!_isProcessingPageChange) {
                _pdfViewerController.jumpToPage(pageNumber);
                _showSnackbar('Jumped to page $pageNumber from remote update', Colors.green);
              // }
            });
          } else {
            print('Invalid page number in event data: $event');
          }
        } catch (e) {
          print('Error parsing event data: $e');
        }
      });
      _channel.bind('pusher:subscription_error', (error) {
        print("Subscription error: $error");
      });
    } catch (e) {
      print("Error subscribing to channel: $e");
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  void _onPageChanged(int newPage) async {
    try {
      // String? token = await _storage.read(key: "token");
      // if (token == null) {
      //   throw Exception("Token not found in storage.");
      // }
      // if (!widget.isAdmin) {
      //   print("Only admin can change pages.");
      //   return; // Block non-admins from triggering page changes
      // }

      // if (_isProcessingPageChange) return;
      // _isProcessingPageChange = true;

      final provider = Provider.of<MeetingPageProvider>(context,listen: false);


      // if (_isProcessingPageChange) return;
      // _isProcessingPageChange = true;

      Future.delayed(Duration(seconds: 1), () async {
        if (_lastSentPage != newPage) {
          _lastSentPage = newPage;
          final response =  provider.notifyPageChange(widget.fileId, newPage);
        }
        _isProcessingPageChange = false;
      });



    } catch (e) {
      print("Error notifying page change: $e");
    }
  }



  @override
  void dispose() {
    _pusher.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: CustomText(text: "${widget.previewMeeting.meeting?.meetingTitle ?? ""}"),
        ),
        body: Center(
          child: CustomText(text: "Error: $_error"),
        ),
      );
    }
    final String filePath = '${AppUri.baseUntilPublicDirectory}/${widget.previewMeeting.filePath.toString()}';
    return Consumer<MeetingPageProvider>(
        builder: (BuildContext context, MeetingPageProvider provider,
            Widget? ddd) {
          return Scaffold(
            appBar: AppBar(
              title: CustomText(text: '${widget.previewMeeting.meeting?.meetingTitle ?? ""}', fontWeight: FontWeight.bold, fontSize: 18,),
              actions: <Widget>[
                IconButton(
                  icon: CustomIcon(icon: Icons.bookmark),
                  onPressed: () {
                    _pdfViewerKey.currentState?.openBookmarkView();
                  },
                ),
                IconButton(
                  icon: CustomIcon(icon: Icons.arrow_forward),
                  onPressed: () {
                    _pdfViewerController.nextPage();
                  },
                ),
                IconButton(
                  icon: CustomIcon(icon: Icons.arrow_back),
                  onPressed: () {
                    _pdfViewerController.previousPage();
                  },
                ),
              ],
            ),
            body: SfPdfViewer.network(
              filePath,
              key: _pdfViewerKey,
              controller: _pdfViewerController,
              onPageChanged: (details) {
                final newPageNumber = details.newPageNumber;
                if (provider.currentPage != newPageNumber) {
                  _onPageChanged(details.newPageNumber);
                }
              },
            ),
          );
        }
    );
  }
}
