/// Base class for all proxy configurations.
abstract class ProtocolConfigBase {
  final String origLink;
  final String remark;

  ProtocolConfigBase({required this.origLink, required this.remark});

  /// Converts the configuration to a Xray JSON object.
  Map<String, dynamic> toXrayJson({bool allowInsecure = false});
}
