import 'package:diplom/widgets/createproject_dialog.dart';
import 'package:diplom/widgets/settings_dialog.dart';
import 'package:flutter/material.dart';

class EmptyNavigationRail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      color: ElevationOverlay.applySurfaceTint(
          Theme.of(context).colorScheme.background,
          Theme.of(context).colorScheme.primary,
          3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment
            .spaceBetween, // Распределение пространства между верхней и нижней кнопками
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CreateProjectDialog(); // Диалог создания проекта
                  },
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
          CircularProgressIndicator(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SettingsDialog(); // Диалог настроек
                    },
                  );
                },
                icon: const Icon(Icons.settings),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
