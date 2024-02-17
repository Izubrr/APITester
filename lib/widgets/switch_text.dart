import 'package:flutter/material.dart';

class SwitchText extends StatefulWidget {
  const SwitchText({super.key, required this.color, this.onTap});

  final Color color;
  final VoidCallback? onTap; // Callback для вызова

  @override
  _SwitchTextState createState() => _SwitchTextState();
}


class _SwitchTextState extends State<SwitchText> {
  bool val = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          val = !val;
        });
        widget.onTap?.call();
      },
      child: Container(
        width: 100,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(width: 1.3, color: const Color(0xFF2F2F35)),
            color: Colors.transparent),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(20),
                      color: val
                          ? Colors.white
                          : widget.color),
                  child: Center(
                      child: Text(
                        'Log in',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: val
                                ? Colors.black
                                : Colors.white),
                      )
                  ),
                ),
              ),
              const SizedBox(width: 4.0),
              Expanded(child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(20),
                      color: val
                          ? widget.color
                          : Colors.white),
                  child: Center(
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: val
                                ? Colors.white
                                : Colors.black),
                      )
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}