class WebSocketState {
  const WebSocketState({
    this._isConnected = false,
  });

  final bool  _isConnected;

  bool get isConnected => _isConnected;

  WebSocketState  copyWith({
    bool? isConnected,
  }) {
    return WebSocketState(
      isConnected: isConnected ?? _isConnected,
    );
  }
}