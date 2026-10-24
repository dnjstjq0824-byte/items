import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AetherTraderPro', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text('Order #ORD-1001 • Online', style: TextStyle(fontSize: 10, color: AppTheme.success)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Security Warning Banner (Article 14.5 & 20)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: AppTheme.warning.withValues(alpha: 0.15),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Safety: Never share credentials or trade off-platform. Direct contact is blocked.',
                    style: TextStyle(fontSize: 10, color: AppTheme.warning),
                  ),
                ),
              ],
            ),
          ),

          // Chat Message List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMessageBubble(
                  isMe: false,
                  message: 'Hello! I am ready to fulfill your celestial greatsword on Altair Prime.',
                  time: '10:14 PM',
                ),
                _buildMessageBubble(
                  isMe: true,
                  message: 'Great, my character name is DragonSlayerNA. Meeting in main square.',
                  time: '10:15 PM',
                ),
                _buildMessageBubble(
                  isMe: false,
                  message: 'Trade completed! I uploaded the screenshot evidence to the order.',
                  time: '10:18 PM',
                ),
              ],
            ),
          ),

          // Message Input Field
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppTheme.darkSurface,
              border: Border(top: BorderSide(color: AppTheme.darkBorder)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.attach_file, color: Colors.grey),
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      fillColor: AppTheme.darkBackground,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.send, color: AppTheme.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({required bool isMe, required String message, required String time}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primary : AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: isMe ? null : Border.all(color: AppTheme.darkBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(fontSize: 13, color: Colors.white)),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(fontSize: 9, color: isMe ? Colors.white70 : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
