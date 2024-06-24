import 'package:delivery_tracking_app/models/delivery_batch.dart';
import 'package:delivery_tracking_app/models/delivery_batch_draft.dart';
import 'package:delivery_tracking_app/repositories/delivery_batch_draft_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveDeliveryBatchDraftRepository
    implements IDeliveryBatchDraftRepository {
  final String boxName = 'draftBox';

  Future<Box<DeliveryBatchDraft>> _openBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<DeliveryBatchDraft>(boxName);
    } else {
      return await Hive.openBox<DeliveryBatchDraft>(boxName);
    }
  }

  @override
  Future<void> saveDraft(DeliveryBatchDraft draft) async {
    var draftBox = await _openBox();
    await draftBox.add(draft);
  }

  @override
  Future<void> overwriteDraftAtId(int id, DeliveryBatchDraft newDraft) async {
    var draftBox = await _openBox();
    if (draftBox.containsKey(id)) {
      await draftBox.put(id, newDraft);
    }
  }

  @override
  Future<List<DeliveryBatchDraft>> getAllDrafts() async {
    var draftBox = await _openBox();
    final drafts = draftBox.values.toList().cast<DeliveryBatchDraft>();
    return drafts;
  }

  @override
  Future<DeliveryBatchDraft?> getDraftById(int id) async {
    var draftBox = await _openBox();
    if (draftBox.containsKey(id)) {
      return draftBox.get(id);
    } else {
      return null;
    }
  }

  @override
  Future<void> deleteDraftById(int id) async {
    var draftBox = await _openBox();
    await draftBox.delete(id);
  }

  @override
  Future<int?> getIdOfDraft(DeliveryBatchDraft draft) async {
    var draftBox = await _openBox();
    for (var key in draftBox.keys) {
      final currentDraft = draftBox.get(key);
      if (currentDraft == draft) {
        return key;
      }
    }
    return null;
  }

  @override
  Future<void> clearAll() async {
    var draftBox = await _openBox();
    await draftBox.clear();
  }
}
