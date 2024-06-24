import 'package:delivery_tracking_app/models/delivery_batch.dart';
import 'package:delivery_tracking_app/models/delivery_batch_draft.dart';

abstract interface class IDeliveryBatchDraftRepository {
  void saveDraft(DeliveryBatchDraft draft);

  void overwriteDraftAtId(int id, DeliveryBatchDraft newDraft);

  Future<List<DeliveryBatchDraft>> getAllDrafts();

  Future<DeliveryBatchDraft?> getDraftById(int id);

  void deleteDraftById(int id);

  void getIdOfDraft(DeliveryBatchDraft draft);

  Future<void> clearAll();
}