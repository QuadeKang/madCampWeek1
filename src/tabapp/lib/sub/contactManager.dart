import 'dart:convert'; // Import dart:convert for JSON operations
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:tabapp/sub/firstPage.dart'; // Replace with the correct path to your Contact class

class ContactManager {
  static const String _storageKey = "allContacts";

  static Future<void> saveContacts(List<Contact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonContacts = contacts.map((contact) => json.encode(contact.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonContacts);
    print("Saved contacts: ${jsonContacts.length}"); // Log the number of contacts saved
  }

  static Future<List<Contact>> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? jsonContacts = prefs.getStringList(_storageKey);

    if (jsonContacts != null) {
      return jsonContacts.map((jsonContact) => Contact.fromJson(json.decode(jsonContact))).toList();
    } else {
      return [];
    }
  }
}
