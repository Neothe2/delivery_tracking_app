import 'contact.dart';

class User {
  int id;
  String username;
  Contact contact;
  List<String> groups;

  User(this.id, this.username, this.contact, this.groups);
}
