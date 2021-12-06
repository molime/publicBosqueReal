import 'package:cloud_firestore/cloud_firestore.dart';

final usersRef = FirebaseFirestore.instance.collection('users');

class UserLocal {
  final String id;
  final String email;
  final String membership;
  final DateTime timestamp;
  List<String> searchTerms;
  String photoUrl;
  String displayName;
  String phone;
  bool validated;

  UserLocal({
    this.id,
    this.email,
    this.photoUrl,
    this.displayName,
    this.phone,
    this.membership,
    this.validated,
    this.timestamp,
    this.searchTerms,
  });

  factory UserLocal.fromDocument(DocumentSnapshot doc) {
    UserLocal userLocal = UserLocal(
      id: doc.id != null ? doc.id : null,
      email: (doc.data() as Map)['email'] != null
          ? (doc.data() as Map)['email']
          : null,
      photoUrl: (doc.data() as Map)['photoUrl'] != null
          ? (doc.data() as Map)['photoUrl']
          : null,
      displayName: (doc.data() as Map)['displayName'] != null
          ? (doc.data() as Map)['displayName']
          : null,
      phone: (doc.data() as Map)['phone'] != null
          ? (doc.data() as Map)['phone']
          : null,
      membership: (doc.data() as Map)['membership'] != null
          ? (doc.data() as Map)['membership']
          : null,
      validated: (doc.data() as Map)['validated'] != null
          ? (doc.data() as Map)['validated']
          : false,
      timestamp: (doc.data() as Map)['timestamp'] != null
          ? (doc.data() as Map)['timestamp'].toDate()
          : null,
      searchTerms: [],
    );

    for (dynamic queryTerm in (doc.data() as Map)['searchTerms']) {
      userLocal.searchTerms.add(
        queryTerm.toString(),
      );
    }

    return userLocal;
  }

  Future<void> changePhone({String newPhone}) async {
    this.phone = newPhone;
    await usersRef.doc(this.id).update(
      {
        'phone': newPhone,
      },
    );
  }

  Future<void> changeName({String newName}) async {
    this.displayName = newName;
    await usersRef.doc(this.id).update(
      {
        'displayName': newName,
      },
    );
  }

  Future<void> changePhoto({String newPhotoUrl}) async {
    this.photoUrl = newPhotoUrl;
    await usersRef.doc(this.id).update(
      {
        'photoUrl': newPhotoUrl,
      },
    );
  }

  void makeValid() {
    this.validated = true;
  }
}
