import 'package:yaml/yaml.dart';

class ParseYaml {
  final String yamlString;
  late final Map<dynamic, dynamic> _yamlMap;

  ParseYaml(this.yamlString) {
    _yamlMap = loadYaml(yamlString);
  }

  // Доступ к элементам документа
  String get projectTitle => _yamlMap['info']['title'].toString(); // Название проекта

  get endPointsList => getPathsKeys();

  List<String> getPathsKeys() {
    var paths = _yamlMap['paths'] as Map?;
    return paths?.keys.cast<String>().toList() ?? [];
  }
}