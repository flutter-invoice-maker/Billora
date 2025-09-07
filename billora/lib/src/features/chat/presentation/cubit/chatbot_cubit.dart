import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:billora/src/features/chat/domain/entities/chat_message.dart';
import 'package:billora/src/features/chat/domain/repositories/chat_repository.dart';
import 'package:billora/src/core/services/chatbot_ai_service.dart';
import 'package:uuid/uuid.dart';

part 'chatbot_state.dart';

class ChatbotCubit extends Cubit<ChatbotState> {
  final ChatRepository _chatRepository;
  final ChatbotAIService _aiService;
  final FirebaseAuth _firebaseAuth;
  final Uuid _uuid;

  StreamSubscription<String>? _streamSubscription;
  String? _currentConversationId;
  String? _currentMessageId;

  ChatbotCubit({
    required ChatRepository chatRepository,
    required ChatbotAIService aiService,
    required FirebaseAuth firebaseAuth,
    required Uuid uuid,
  }) : _chatRepository = chatRepository,
       _aiService = aiService,
       _firebaseAuth = firebaseAuth,
       _uuid = uuid,
       super(const Initial());

  String? get _currentUserId => _firebaseAuth.currentUser?.uid;

  /// Send a message and get streaming response
  Future<void> sendMessage(String message, int currentTabIndex) async {
    if (_currentUserId == null) {
      emit(const Error('Please log in to use the AI assistant.'));
      return;
    }

    if (message.trim().isEmpty) {
      return;
    }

    try {
      // Create conversation ID if not exists
      _currentConversationId ??= _uuid.v4();

      // Create user message
      final userMessage = ChatMessage(
        id: _uuid.v4(),
        userId: _currentUserId!,
        content: message,
        isUser: true,
        timestamp: DateTime.now(),
        conversationId: _currentConversationId!,
      );

      // Save user message
      final saveResult = await _chatRepository.saveMessage(userMessage);
      saveResult.fold(
        (failure) => emit(Error('Failed to save message: $failure')),
        (_) => null,
      );

      // Create bot message placeholder
      _currentMessageId = _uuid.v4();
      final botMessage = ChatMessage(
        id: _currentMessageId!,
        userId: _currentUserId!,
        content: '',
        isUser: false,
        timestamp: DateTime.now(),
        isStreaming: true,
        conversationId: _currentConversationId!,
      );

      // Save bot message placeholder
      final botSaveResult = await _chatRepository.saveMessage(botMessage);
      botSaveResult.fold(
        (failure) => emit(Error('Failed to save bot message: $failure')),
        (_) => null,
      );

      // Emit message sent state
      emit(MessageSent(userMessage));

      // Start streaming
      emit(const StreamingStarted());

      _streamSubscription = _aiService.sendMessageStreaming(
        userId: _currentUserId!,
        message: message,
        currentTabIndex: currentTabIndex,
      ).listen(
        (chunk) {
          emit(MessageStreaming(chunk));
        },
        onError: (error) {
          emit(Error('Streaming error: $error'));
        },
        onDone: () async {
          // Update the bot message with final content
          if (_currentMessageId != null) {
            final updateResult = await _chatRepository.updateMessageContent(
              _currentMessageId!,
              state.currentContent,
            );
            updateResult.fold(
              (failure) => emit(Error('Failed to update message: $failure')),
              (_) => emit(const StreamingCompleted()),
            );
          }
        },
      );
    } catch (e) {
      emit(Error('Error sending message: $e'));
    }
  }

  /// Cancel current streaming
  void cancelStreaming() {
    if (_currentConversationId != null) {
      _aiService.cancelStreaming(_currentConversationId!);
    }
    _streamSubscription?.cancel();
    _streamSubscription = null;
    emit(const StreamingCancelled());
  }

  /// Load conversation messages
  Future<void> loadConversation(String conversationId) async {
    if (_currentUserId == null) return;

    try {
      emit(const Loading());
      
      final result = await _chatRepository.getConversationMessages(conversationId);
      result.fold(
        (failure) => emit(Error('Failed to load messages: $failure')),
        (messages) {
          _currentConversationId = conversationId;
          emit(MessagesLoaded(messages));
        },
      );
    } catch (e) {
      emit(Error('Error loading conversation: $e'));
    }
  }

  /// Load user's recent messages
  Future<void> loadRecentMessages() async {
    if (_currentUserId == null) return;

    try {
      emit(const Loading());
      
      final result = await _chatRepository.getUserMessages(_currentUserId!);
      result.fold(
        (failure) => emit(Error('Failed to load messages: $failure')),
        (messages) => emit(MessagesLoaded(messages)),
      );
    } catch (e) {
      emit(Error('Error loading messages: $e'));
    }
  }

  /// Start new conversation
  void startNewConversation() {
    _currentConversationId = null;
    _currentMessageId = null;
    _streamSubscription?.cancel();
    _streamSubscription = null;
    emit(const Initial());
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
