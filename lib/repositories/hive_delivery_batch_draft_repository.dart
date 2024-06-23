import 'package:delivery_tracking_app/models/delivery_batch.dart';
import 'package:delivery_tracking_app/repositories/delivery_batch_draft_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveDeliveryBatchDraftRepository
    implements IDeliveryBatchDraftRepository {
  final Box<DeliveryBatchDraft> draftBox =
      Hive.box<DeliveryBatchDraft>('draftBox');

  @override
  Future<void> saveDraft(DeliveryBatchDraft draft) async {
    await draftBox.add(draft);
  }

  @override
  Future<void> overwriteDraftAtId(int id, DeliveryBatchDraft newDraft) async {
    if (draftBox.containsKey(id)) {
      await draftBox.put(id, newDraft);
    }
  }

  @override
  Future<List<DeliveryBatchDraft>> getAllDrafts() async {
    final drafts = draftBox.values.toList().cast<DeliveryBatchDraft>();
    return drafts;
  }

  @override
  Future<DeliveryBatchDraft?> getDraftById(int id) async {
    if (draftBox.containsKey(id)) {
      return draftBox.get(id);
    } else {
      return null;
    }
  }

  @override
  Future<void> deleteDraftById(int id) async {
    await draftBox.delete(id);
  }

  @override
  Future<int?> getIdOfDraft(DeliveryBatchDraft draft) async {
    for (var key in draftBox.keys) {
      final currentDraft = draftBox.get(key);
      if (currentDraft == draft) {
        return key;
      }
    }
    return null;
  }
}
