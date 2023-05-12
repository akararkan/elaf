import 'package:elaf/AllScreen/MainScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class FeedbackDialog extends StatefulWidget {
  final String? riderID;

  FeedbackDialog({required this.riderID});

  @override
  _FeedbackDialogState createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Send Feedback'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _feedbackController,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your feedback';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Enter your feedback',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Send'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _sendFeedback();
              Navigator.pushNamedAndRemoveUntil(context, MainScreen.main, (route) => false);
            }
          },
        ),
      ],
    );
  }

  void _sendFeedback() {
    final feedback = _feedbackController.text;
    DatabaseReference reference = FirebaseDatabase.instance.reference().child("feedback");

    reference.push().set({
      'rider_id': widget.riderID,
      'feedback': feedback,
      'timestamp': ServerValue.timestamp,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Feedback sent')));
      Navigator.pushNamedAndRemoveUntil(context, MainScreen.main, (route) => false);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send feedback: $error')));
    });
  }

}
