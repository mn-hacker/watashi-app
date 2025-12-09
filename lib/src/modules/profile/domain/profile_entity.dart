import 'dart:math';

/// Represents a subscription profile (remote URL-based)
class ProfileEntity {
  final String id;
  String name;
  final String url;
  DateTime lastUpdate;
  bool active;
  SubscriptionInfo? subInfo;

  ProfileEntity({
    String? id,
    required this.name,
    required this.url,
    DateTime? lastUpdate,
    this.active = false,
    this.subInfo,
  })  : id = id ?? _generateId(),
        lastUpdate = lastUpdate ?? DateTime.now();

  static String _generateId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = random.nextInt(999999);
    return '$timestamp-$randomPart';
  }

  /// Create a copy with updated fields
  ProfileEntity copyWith({
    String? name,
    DateTime? lastUpdate,
    bool? active,
    SubscriptionInfo? subInfo,
  }) {
    return ProfileEntity(
      id: id,
      name: name ?? this.name,
      url: url,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      active: active ?? this.active,
      subInfo: subInfo ?? this.subInfo,
    );
  }

  /// Create from JSON
  factory ProfileEntity.fromJson(Map<String, dynamic> json) {
    return ProfileEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
      active: json['active'] as bool? ?? false,
      subInfo: json['subInfo'] != null
          ? SubscriptionInfo.fromJson(json['subInfo'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'lastUpdate': lastUpdate.toIso8601String(),
      'active': active,
      'subInfo': subInfo?.toJson(),
    };
  }
}

/// Subscription usage and expiry information
class SubscriptionInfo {
  final int upload; // bytes
  final int download; // bytes
  final int total; // bytes
  final DateTime expire;
  final String? webPageUrl;
  final String? supportUrl;

  const SubscriptionInfo({
    required this.upload,
    required this.download,
    required this.total,
    required this.expire,
    this.webPageUrl,
    this.supportUrl,
  });

  /// Total consumption (upload + download)
  int get consumption => upload + download;

  /// Ratio of used to total (0.0 to 1.0)
  double get ratio => total > 0 ? (consumption / total).clamp(0.0, 1.0) : 0.0;

  /// Whether subscription is expired
  bool get isExpired => expire.isBefore(DateTime.now());

  /// Days remaining until expiry
  int get daysRemaining {
    final remaining = expire.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  /// Check if subscription has unlimited traffic (> 10TB)
  bool get isUnlimitedTraffic => total > 10 * 1099511627776;

  /// Check if subscription has unlimited time (> 100 years)
  bool get isUnlimitedTime => expire.year - DateTime.now().year > 100;

  /// Create from JSON
  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfo(
      upload: json['upload'] as int,
      download: json['download'] as int,
      total: json['total'] as int,
      expire: DateTime.parse(json['expire'] as String),
      webPageUrl: json['webPageUrl'] as String?,
      supportUrl: json['supportUrl'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'upload': upload,
      'download': download,
      'total': total,
      'expire': expire.toIso8601String(),
      'webPageUrl': webPageUrl,
      'supportUrl': supportUrl,
    };
  }

  /// Create a copy with updated fields
  SubscriptionInfo copyWith({
    int? upload,
    int? download,
    int? total,
    DateTime? expire,
    String? webPageUrl,
    String? supportUrl,
  }) {
    return SubscriptionInfo(
      upload: upload ?? this.upload,
      download: download ?? this.download,
      total: total ?? this.total,
      expire: expire ?? this.expire,
      webPageUrl: webPageUrl ?? this.webPageUrl,
      supportUrl: supportUrl ?? this.supportUrl,
    );
  }
}
