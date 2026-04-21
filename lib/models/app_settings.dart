class AppSettings {
  final bool showReaction;
  final bool showComment;
  final bool showShare;
  final bool showFullProfile;
  final bool usePerspectiveApi;
  final bool showWordCounter;

  AppSettings({
    this.showReaction = true,
    this.showComment = true,
    this.showShare = true,
    this.showFullProfile = true,
    this.usePerspectiveApi = true,
    this.showWordCounter = true,
  });

  AppSettings copyWith({
    bool? showReaction,
    bool? showComment,
    bool? showShare,
    bool? showFullProfile,
    bool? usePerspectiveApi,
    bool? showWordCounter,
  }) {
    return AppSettings(
      showReaction: showReaction ?? this.showReaction,
      showComment: showComment ?? this.showComment,
      showShare: showShare ?? this.showShare,
      showFullProfile: showFullProfile ?? this.showFullProfile,
      usePerspectiveApi: usePerspectiveApi ?? this.usePerspectiveApi,
      showWordCounter: showWordCounter ?? this.showWordCounter,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'showReaction': showReaction,
      'showComment': showComment,
      'showShare': showShare,
      'showFullProfile': showFullProfile,
      'usePerspectiveApi': usePerspectiveApi,
      'showWordCounter': showWordCounter,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      showReaction: map['showReaction'] ?? true,
      showComment: map['showComment'] ?? true,
      showShare: map['showShare'] ?? true,
      showFullProfile: map['showFullProfile'] ?? true,
      usePerspectiveApi: map['usePerspectiveApi'] ?? true,
      showWordCounter: map['showWordCounter'] ?? true,
    );
  }
}
