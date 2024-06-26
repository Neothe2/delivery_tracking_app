import 'package:delivery_tracking_app/models/delivery_batch.dart';
import 'package:delivery_tracking_app/models/delivery_batch_draft.dart';

abstract interface class IDeliveryBatchDraftRepository {
  void saveDraft(DeliveryBatchDraft draft);

  Future<void> overwriteDraftAtId(int id, DeliveryBatchDraft newDraft);

  Future<List<DeliveryBatchDraft>> getAllDrafts();

  Future<DeliveryBatchDraft?> getDraftById(int id);

  Future<void> deleteDraftById(int id);

  Future<int?> getIdOfDraft(DeliveryBatchDraft draft);

  Future<void> clearAll();
}
