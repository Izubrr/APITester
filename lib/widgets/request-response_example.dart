// import 'package:diplom/main.dart';
// import 'package:diplom/pages/project_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_highlight/flutter_highlight.dart';
// import 'package:flutter_highlight/themes/github.dart';
// import 'package:flutter_highlight/themes/monokai-sublime.dart';
//
// class RequestResponseExample extends StatefulWidget {
//   final String selectedResponse;
//
//   const RequestResponseExample({super.key, required this.selectedResponse});
//
//   @override
//   State<RequestResponseExample> createState() => _RequestResponseExampleState();
// }
//
// class _RequestResponseExampleState extends State<RequestResponseExample> {
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final codeTheme = isDarkMode ? monokaiSublimeTheme : githubTheme;
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Align(
//             alignment: Alignment.topLeft,
//             child: ValueListenableBuilder<String>(
//                 valueListenable: selectedResponseNotifier,
//                 builder: (context, value, child) { return
//               SegmentedButton<String>(
//                 segments: paths[selectedApiIndex].responses.map((key) {
//                   return ButtonSegment<String>(
//                     value: key,
//                     label: Text(key),
//                   );
//                 }).toList(),
//                 selected: {value},
//                 onSelectionChanged: (newSelection) {
//                   setState(() {
//                     selectedResponseNotifier.value = newSelection.first;
//                   });
//                 },
//               );
//             }),
//           ),
//         ),
//         Row(
//           children: [
//             Expanded(
//               child: Card(
//                 child: ListTile(
//                   title: const Text('Request Example'),
//                   subtitle: SizedBox(
//                     height: 300,
//                     child: SingleChildScrollView(
//                       child: FutureBuilder<String>(
//                         future: () async {
//                           // Ключ для кэширования, который комбинирует идентификатор проекта и индекс API
//                           String cacheKey = 'requestExample-${selectedProjectIdNotifier.value}-$selectedApiIndex';
//
//                           // Проверяем, есть ли данные в кэше для текущего API
//                           String? cachedData =
//                           apiDataCache[cacheKey];
//                           if (cachedData != null) {
//                             // Если данные есть в кэше, возвращаем их, оборачивая в Future
//                             return cachedData;
//                           } else {
//                             // Если в кэше нет данных, загружаем их и сохраняем в кэш
//                             String newData = await fetchMapWithRefs(
//                                 map: requestBodyCodes[paths[selectedApiIndex].pathId],
//                                 requestMapId: 'schema');
//                             apiDataCache[cacheKey] = newData;
//                             return newData;
//                           }
//                         }(),
//                         builder: (context, snapshot) {
//                           return snapshot.connectionState ==
//                               ConnectionState.waiting
//                               ? const CircularProgressIndicator()
//                               : !snapshot.hasData
//                               ? const Text(
//                               'There is no Request Example')
//                               : HighlightView(
//                             snapshot.data!,
//                             language: 'json',
//                             theme: codeTheme,
//                             padding:
//                             const EdgeInsets.all(12),
//                             textStyle: const TextStyle(
//                               fontFamily: 'monospace',
//                               fontSize: 14,
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: Card(
//                 child: ListTile(
//                   title: const Text('Response Example'),
//                   subtitle: SizedBox(
//                     height: 300,
//                     child: SingleChildScrollView(
//                       child: FutureBuilder<String>(
//                         future: () async {
//                           // Ключ для кэширования, который комбинирует идентификатор проекта и индекс API
//                           String cacheKey = 'responseExample-${selectedProjectIdNotifier.value}-$selectedApiIndex';
//                           String? cacheResponseCode;
//
//                           // Проверяем, есть ли данные в кэше для текущего API
//                           String? cachedData = apiDataCache[cacheKey];
//                           if (cachedData != null && cacheResponseCode == selectedResponseNotifier.value) {
//                             // Если данные есть в кэше, возвращаем их, оборачивая в Future
//                             return cachedData;
//                           } else {
//                             cacheResponseCode = selectedResponseNotifier.value;
//                             // Если в кэше нет данных, загружаем их и сохраняем в кэш
//                             Map<String, dynamic> map = responseCodes[paths[selectedApiIndex].pathId];
//                             String newData = await fetchMapWithRefs(
//                                 map: map[selectedResponseNotifier.value],
//                                 requestMapId: 'examples');
//                             apiDataCache[cacheKey] = newData;
//                             return newData;
//                           }
//                         }(),
//                         builder: (context, snapshot) {
//                           return snapshot.connectionState ==
//                               ConnectionState.waiting
//                               ? const CircularProgressIndicator()
//                               : !snapshot.hasData
//                               ? const Text(
//                               'There is no Response Example')
//                               : HighlightView(
//                             snapshot.data!,
//                             language: 'json',
//                             theme: codeTheme,
//                             padding:
//                             const EdgeInsets.all(12),
//                             textStyle: const TextStyle(
//                               fontFamily: 'monospace',
//                               fontSize: 14,
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
