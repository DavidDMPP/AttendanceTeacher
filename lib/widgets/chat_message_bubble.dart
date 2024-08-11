import 'package:flutter/material.dart';
import '../models/message.dart';
import '../utils/time_utils.dart';

class ChatMessageBubble extends StatelessWidget {
  final Message message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message.senderId, style: const TextStyle(fontWeight: FontWeight.bold)),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(10),
            child: Text(message.content),
          ),
          Text(formatDateTime(message.timestamp), 
               style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}