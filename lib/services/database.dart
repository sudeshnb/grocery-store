import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';

///Database service
abstract class Database {
  Stream<QuerySnapshot> getDataFromCollection(String path, [int length]);

  Future<QuerySnapshot> getFutureDataFromCollectionWithRange(String path,
      {required String orderBy,
      required DocumentSnapshot? startAfter,
      required int length});

  Future<QuerySnapshot> getFutureCollectionWithRangeAndSearch(String path,
      {required String orderBy,
      required DocumentSnapshot? startAfter,
      required int length,
      required String searchedData});

  Future<QuerySnapshot> getFutureCollectionWithRangeAndValue(String path,
      {required String orderBy,
      required DocumentSnapshot? startAfter,
      required int length,
      required String key,
      required String value});

  Stream<DocumentSnapshot> getDataFromDocument(String path);

  Future<DocumentSnapshot> getFutureDataFromDocument(String path);

  Future<void> setData(Map<String, dynamic> data, String path);

  Future<void> removeData(String path);

  Future<void> removeCollection(String path);

  Future<void> updateData(Map<String, dynamic> data, String path);

  Stream<QuerySnapshot> getDataWithArrayCondition(
      String collection, List<String> array);

  Stream<QuerySnapshot> getDataWithValueCondition(
      String collection, String key, String value);

  Stream<QuerySnapshot> getLimitedDataWithValueCondition(
      String collection, String key, String value, int length);

  Stream<QuerySnapshot> getSearchedDataFromCollection(
      String collection, String searchedData,
      [int? length]);
}

class FirestoreDatabase implements Database {
  final _service = FirebaseFirestore.instance;

  @override
  Future<QuerySnapshot> getFutureCollectionWithRangeAndSearch(String path,
      {required String orderBy,
      required DocumentSnapshot? startAfter,
      required int length,
      required String searchedData}) async {
    if (startAfter != null) {
      return await _service
          .collection(path)
          .where('title', isGreaterThanOrEqualTo: searchedData)
          .where('title', isLessThan: searchedData + 'z')
          .orderBy(orderBy)
          .startAfterDocument(startAfter)
          .limit(length)
          .get();
    } else {
      return await _service
          .collection(path)
          .where('title', isGreaterThanOrEqualTo: searchedData)
          .where('title', isLessThan: searchedData + 'z')
          .orderBy(orderBy)
          .limit(length)
          .get();
    }
  }

  @override
  Future<QuerySnapshot> getFutureCollectionWithRangeAndValue(String path,
      {required String orderBy,
      required DocumentSnapshot? startAfter,
      required int length,
      required String key,
      required String value}) async {
    late QuerySnapshot result;
    bool fromCache = false;

    final storage = GetStorage();

    if (storage.hasData(value + (startAfter == null ? "" : startAfter.id))) {
      fromCache = true;
    } else {
      await storage.write(
          value + (startAfter == null ? "" : startAfter.id), true);
    }

    if (startAfter != null) {
      result = await _service
          .collection(path)
          .where(key, isEqualTo: value)
          .orderBy(orderBy)
          .startAfterDocument(startAfter)
          .limit(length)
          .get(GetOptions(
              source: fromCache ? Source.cache : Source.serverAndCache));
    } else {
      result = await _service
          .collection(path)
          .where(key, isEqualTo: value)
          .orderBy(orderBy)
          .limit(length)
          .get(GetOptions(
              source: fromCache ? Source.cache : Source.serverAndCache));
    }

    await Future.forEach<DocumentSnapshot>(result.docs, (element) {
      // print("From Cache: " + element.metadata.isFromCache.toString());
    });

    return result;
  }

  @override
  Future<QuerySnapshot> getFutureDataFromCollectionWithRange(String path,
      {required String orderBy,
      required DocumentSnapshot? startAfter,
      required int length}) async {
    late QuerySnapshot result;
    if (startAfter != null) {
      result = await _service
          .collection(path)
          .orderBy(orderBy)
          .startAfterDocument(startAfter)
          .limit(length)
          .get();
    } else {
      result =
          await _service.collection(path).orderBy(orderBy).limit(length).get();
    }

    return result;
  }

  @override
  Future<DocumentSnapshot> getFutureDataFromDocument(String path) {
    return _service.doc(path).get();
  }

  @override
  Stream<QuerySnapshot> getDataFromCollection(String path, [int? length]) {
    if (length != null) {
      final snapshots = _service.collection(path).limit(length).snapshots();

      return snapshots;
    } else {
      final snapshots = _service.collection(path).snapshots();

      return snapshots;
    }
  }

  @override
  Stream<DocumentSnapshot> getDataFromDocument(String path) {
    final snapshots = _service.doc(path).snapshots();

    return snapshots;
  }

  @override
  Stream<QuerySnapshot> getDataWithArrayCondition(
      String collection, List<String> array) {
    final snapshots = _service
        .collection(collection)
        .where(FieldPath.documentId, whereIn: array)
        .snapshots();

    return snapshots;
  }

  @override
  Stream<QuerySnapshot> getLimitedDataWithValueCondition(
      String collection, String key, String value, int length) {
    final snapshots = _service
        .collection(collection)
        .where(key, isEqualTo: value)
        .limit(length)
        .snapshots();

    return snapshots;
  }

  @override
  Stream<QuerySnapshot> getDataWithValueCondition(
      String collection, String key, String value) {
    final snapshots = _service
        .collection(collection)
        .where(key, isEqualTo: value)
        .snapshots();

    return snapshots;
  }

  @override
  Stream<QuerySnapshot> getSearchedDataFromCollection(
      String collection, String searchedData,
      [int? length]) {
    // TODO
    final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots;
    if (length != null) {
      snapshots = _service
          .collection(collection)
          .where('title', isGreaterThanOrEqualTo: searchedData)
          .where('title', isLessThan: searchedData + 'z')
          .limit(length)
          .snapshots();

      return snapshots;
    } else {
      snapshots = _service
          .collection(collection)
          .where('title', isGreaterThanOrEqualTo: searchedData)
          .where('title', isLessThan: searchedData + 'z')
          .snapshots();

      return snapshots;
    }
  }

  @override
  Future<void> setData(Map<String, dynamic> data, String path) async {
    final snapshots = _service.doc(path);
    await snapshots.set(data);
  }

  @override
  Future<void> updateData(Map<String, dynamic> data, String path) async {
    final snapshots = _service.doc(path);
    await snapshots.update(data);
  }

  @override
  Future<void> removeData(String path) async {
    final snapshots = _service.doc(path);
    await snapshots.delete();
  }

  @override
  Future<void> removeCollection(String path) async {
    await _service.collection(path).get().then((snapshot) async {
      await Future.forEach<DocumentSnapshot>(snapshot.docs, (doc) async {
        await doc.reference.delete();
      });
    });
  }
}
