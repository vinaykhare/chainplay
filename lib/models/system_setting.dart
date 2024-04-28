class SystemSetting {
  String key = "";
  String value = "";
  String type = "";
  Map<String, Object> toJson() {
    return {
      "key": key,
      "value": value,
      "type": type,
    };
  }
}
