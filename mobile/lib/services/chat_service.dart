import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caretime/api_config.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final String? imageUrl;
  final MessageType type;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.imageUrl,
    this.type = MessageType.text,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      imageUrl: json['imageUrl'],
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
      'type': type.toString().split('.').last,
    };
  }
}

enum MessageType { text, image, file }

class ChatService {
  static WebSocketChannel? _channel;
  static bool _isConnected = false;
  static String? _currentUserId;
  static String? _currentUserName;

  static bool get isConnected => _isConnected;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('userId');
    _currentUserName = prefs.getString('userName');
  }

  static Future<void> connectToChat(String chatId) async {
    if (_isConnected) {
      await disconnect();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final wsUrl = apiBaseUrl.replaceFirst('http', 'ws');
      final uri = Uri.parse('$wsUrl/ws/chat/$chatId?token=$token');

      _channel = WebSocketChannel.connect(uri);
      _isConnected = true;

      _channel!.stream.listen(
        (message) {
          _handleIncomingMessage(message);
        },
        onError: (error) {
          print('WebSocket error: $error');
          _isConnected = false;
        },
        onDone: () {
          print('WebSocket connection closed');
          _isConnected = false;
        },
      );
    } catch (e) {
      print('Failed to connect to chat: $e');
      _isConnected = false;
    }
  }

  static void _handleIncomingMessage(dynamic message) {
    try {
      final data = json.decode(message);
      final chatMessage = ChatMessage.fromJson(data);

      // TODO: Notifier les listeners du nouveau message
      print('Received message: ${chatMessage.content}');
    } catch (e) {
      print('Error parsing message: $e');
    }
  }

  static Future<void> sendMessage({
    required String content,
    MessageType type = MessageType.text,
    String? imageUrl,
  }) async {
    if (!_isConnected || _channel == null) {
      throw Exception('Not connected to chat');
    }

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _currentUserId ?? '',
      senderName: _currentUserName ?? 'Unknown',
      content: content,
      timestamp: DateTime.now(),
      imageUrl: imageUrl,
      type: type,
    );

    _channel!.sink.add(json.encode(message.toJson()));
  }

  static Future<void> sendImage(String imagePath) async {
    // TODO: Upload image to server and get URL
    // For now, just send the path
    await sendMessage(
      content: imagePath,
      type: MessageType.image,
      imageUrl: imagePath,
    );
  }

  static Future<void> disconnect() async {
    if (_channel != null) {
      await _channel!.sink.close();
      _channel = null;
    }
    _isConnected = false;
  }

  static Future<List<ChatMessage>> getChatHistory(String chatId) async {
    // TODO: Implement API call to get chat history
    return [];
  }

  static Future<void> markMessageAsRead(String messageId) async {
    // TODO: Implement API call to mark message as read
  }

  static Future<void> deleteMessage(String messageId) async {
    // TODO: Implement API call to delete message
  }
}
