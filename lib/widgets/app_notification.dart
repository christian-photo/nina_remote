import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class NotificationType {
  static const NotificationType success = NotificationType(progressColor: Colors.green, title: 'Success', icon: Icon(Icons.check_circle_outline_outlined, color: Colors.green,));
  static const NotificationType error = NotificationType(progressColor: Colors.red, title: 'Error', icon: Icon(Icons.error_outline, color: Colors.red,));
  static const NotificationType warning = NotificationType(progressColor: Colors.orange, title: 'Warning', icon: Icon(Icons.warning_outlined, color: Colors.orange,));
  static const NotificationType info = NotificationType(progressColor: Colors.blue, title: 'Info', icon: Icon(Icons.info_outline, color: Colors.blue,));

  final Color progressColor;
  final String title;
  final Icon icon;

  const NotificationType({required this.progressColor, required this.title, required this.icon});
}

class InAppNotification extends StatelessWidget {
  const InAppNotification({super.key, required this.type, required this.message, required this.milliseconds});

  final NotificationType type;
  final String message;
  final int milliseconds;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: SafeArea(
        child: Stack(
          children: [
            ListTile(
              leading: SizedBox.fromSize(
                size: const Size(40, 40),
                child: type.icon
              ),
              title: Text(type.title),
              subtitle: Text(message),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  OverlaySupportEntry.of(context)?.dismiss();
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: milliseconds),
                curve: Curves.linear,
                tween: Tween<double>(
                    begin: 0,
                    end: 1,
                ),
                builder: (context, value, _) =>
                    LinearProgressIndicator(value: value, color: type.progressColor,),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

showNotification(BuildContext context, NotificationType type, String message, int milliseconds) {
  showOverlayNotification((context) => InAppNotification(type: type, message: message, milliseconds: milliseconds,), duration: Duration(milliseconds: milliseconds));
}