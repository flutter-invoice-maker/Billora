part of 'chatbot_cubit.dart';

abstract class ChatbotState extends Equatable {
  const ChatbotState();

  @override
  List<Object?> get props => [];

  /// Get current content for streaming updates
  String get currentContent {
    if (this is MessageStreaming) {
      return (this as MessageStreaming).content;
    }
    return '';
  }
}

class Initial extends ChatbotState {
  const Initial();
}

class Loading extends ChatbotState {
  const Loading();
}

class MessageSent extends ChatbotState {
  final ChatMessage message;

  const MessageSent(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageStreaming extends ChatbotState {
  final String content;

  const MessageStreaming(this.content);

  @override
  List<Object?> get props => [content];
}

class StreamingStarted extends ChatbotState {
  const StreamingStarted();
}

class StreamingCompleted extends ChatbotState {
  const StreamingCompleted();
}

class StreamingCancelled extends ChatbotState {
  const StreamingCancelled();
}

class MessagesLoaded extends ChatbotState {
  final List<ChatMessage> messages;

  const MessagesLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class Error extends ChatbotState {
  final String message;

  const Error(this.message);

  @override
  List<Object?> get props => [message];
}

