import 'package:delivery_tracking_app/models/crate.dart';
import 'package:delivery_tracking_app/scanning_progress_saving/unloading_scanning_progress.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UnloadingScanningProgressRepository {
  final String boxName = 'unloadingScanningProgressBox';

  Future<Box<UnloadingScanningProgress>> _openBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<UnloadingScanningProgress>(boxName);
    } else {
      return await Hive.openBox<UnloadingScanningProgress>(boxName);
    }
  }

  Future<List<Crate>> getCratesOfDeliveryBatch(int deliveryBatchId) async {
    var draftBox = await _openBox();

    UnloadingScanningProgress? loadingScanningProgress =
        await _getUnloadingScanningProgressOrNull(deliveryBatchId);

    if (loadingScanningProgress != null) {
      return loadingScanningProgress.crates;
    } else {
      return [];
    }
  }

  Future<UnloadingScanningProgress?> _getUnloadingScanningProgressOrNull(
    int deliveryBatchId,
  ) async {
    var draftBox = await _openBox();
    if (draftBox.containsKey(deliveryBatchId)) {
      return draftBox.get(deliveryBatchId);
    } else {
      return null;
    }
  }

  Future<void> saveCrates(int deliveryBatchId, List<Crate> crates) async {
    var draftBox = await _openBox();
    var newLoadingScanningProgress = UnloadingScanningProgress(
      deliveryBatchId: deliveryBatchId,
      crates: crates,
    );
    await draftBox.put(deliveryBatchId, newLoadingScanningProgress);
  }

  Future<void> clearProgressOfDeliveryBatch(int deliveryBatchId) async {
    var draftBox = await _openBox();
    await draftBox.delete(deliveryBatchId);
  }

  Future<void> clearAll() async {
    var draftBox = await _openBox();
    await draftBox.clear();
  }
}
