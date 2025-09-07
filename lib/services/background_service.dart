import 'package:aces_uniben/features/notifications/notification_service.dart';
import 'package:aces_uniben/features/updates/providers/updates_provider.dart';
import 'package:workmanager/workmanager.dart';
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final updatesProvider = UpdatesProvider();
    final newPosts = await updatesProvider.checkForNewUpdatesAndGetNewPosts();

    if (newPosts["forum"]!.isNotEmpty) {
      final latestForum = newPosts["forum"]!.first;
      NotificationService().showImageNotification(
        id: 101,
        title: "New Forum Post!",
        body: latestForum.title,
        imageUrl: latestForum.imageUrl
      );
    }

    if (newPosts["announcements"]!.isNotEmpty) {
      final latestAnn = newPosts["announcements"]!.first;
      NotificationService().showImageNotification(
        id: 102,
        title: "New Announcement!",
        body: latestAnn.title,
        imageUrl: latestAnn.imageUrl
      );
    }

    if (newPosts["mhs"]!.isNotEmpty) {
      final latestMhs = newPosts["mhs"]!.first;
      NotificationService().showImageNotification(
        id: 103,
        title: "New MHS Article!",
        body: latestMhs.title,
        imageUrl: latestMhs.imageUrl

      );
    }

    return Future.value(true);
  });
}
