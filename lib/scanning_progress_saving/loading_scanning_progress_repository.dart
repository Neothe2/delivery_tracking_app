import 'package:delivery_tracking_app/models/crate.dart';
import 'package:delivery_tracking_app/scanning_progress_saving/loading_scanning_progress.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LoadingScanningProgressRepository {
  final String boxName = 'loadingScanningProgressBox';

  Future<Box<LoadingScanningProgress>> _openBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<LoadingScanningProgress>(boxName);
    } else {
      return await Hive.openBox<LoadingScanningProgress>(boxName);
    }
  }

  Future<List<Crate>> getCrates() async {
    var draftBox = await _openBox();

    LoadingScanningProgress? loadingScanningProgress =
        await _getLoadingScanningProgressOrNull();

    if (loadingScanningProgress != null) {
      return loadingScanningProgress.crates;
    } else {
      return [];
    }
  }

  Future<LoadingScanningProgress?> _getLoadingScanningProgressOrNull() async {
    var draftBox = await _openBox();
    if (draftBox.containsKey(1)) {
      return draftBox.get(1);
    } else {
      return null;
    }
  }

  Future<void> saveCrates(List<Crate> crates) async {
    var draftBox = await _openBox();
    var newLoadingScanningProgress = LoadingScanningProgress(crates: crates);
    await draftBox.put(1, newLoadingScanningProgress);
  }

  Future<void> clear() async {
    var draftBox = await _openBox();
    await draftBox.clear();
  }
}
