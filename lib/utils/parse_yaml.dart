import 'package:yaml/yaml.dart';

class ParseYaml {
  final String yamlString;
  late final Map<dynamic, dynamic> _yamlMap;

  ParseYaml(this.yamlString) {
    _yamlMap = loadYaml(yamlString);
  }

  // Доступ к элементам документа
  String get openapi => _yamlMap['openapi'].toString();

  String get title => _yamlMap['info']['title'].toString();

  String get version => _yamlMap['info']['version'].toString();

  String get description => _yamlMap['info']['description'].toString();
}