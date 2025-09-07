import 'package:billora/src/core/utils/typedef.dart';
import 'package:billora/src/features/chat/domain/entities/chat_message.dart';

abstract class ChatRepository {
  /// Save a chat message
  ResultFuture<void> saveMessage(ChatMessage message);
  
  /// Update message content (for streaming)
  ResultFuture<void> updateMessageContent(String messageId, String content);
  
  /// Get message by ID
  ResultFuture<ChatMessage?> getMessageById(String messageId);
  
  /// Get all messages for a user
  ResultFuture<List<ChatMessage>> getUserMessages(String userId);
  
  /// Get messages for a specific conversation
  ResultFuture<List<ChatMessage>> getConversationMessages(String conversationId);
  
  /// Delete a message
  ResultFuture<void> deleteMessage(String messageId);
  
  /// Get user's business data as JSON string for AI context
  ResultFuture<String> getUserData(String userId);
}

