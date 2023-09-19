import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talkaro/features/authentication/controller/auth_controller.dart';
import 'package:talkaro/features/calls/repository/call_repository.dart';
import 'package:talkaro/models/call_model.dart';
import 'package:uuid/uuid.dart';

final callControllerProvider = Provider((ref) {
  final callRepository = ref.read(callRepositoryProvider);
  return CallController(
    callRepository: callRepository,
    auth: FirebaseAuth.instance,
    ref: ref,
  );
});

class CallController {
  final CallRepository callRepository;
  final ProviderRef ref;
  final FirebaseAuth auth;
  CallController({
    required this.callRepository,
    required this.ref,
    required this.auth,
  });

  Stream<DocumentSnapshot> get callStream => callRepository.callStream;

  void makeVideoCall(BuildContext context, String receiverName,
      String receiverUid, String receiverProfilePic, bool isGroupChat) {
    ref.read(userDataAuthProvider).whenData((value) {
      String callId = const Uuid().v1();
      Call senderCallData = Call(
          callerId: auth.currentUser!.uid,
          callerName: value!.name,
          callerPic: value.profilePic,
          receiverId: receiverUid,
          receiverName: receiverName,
          receiverPic: receiverProfilePic,
          callId: callId,
          hasDialled: true,
          isAudioCall: false);

      Call recieverCallData = Call(
          callerId: auth.currentUser!.uid,
          callerName: value.name,
          callerPic: value.profilePic,
          receiverId: receiverUid,
          receiverName: receiverName,
          receiverPic: receiverProfilePic,
          callId: callId,
          hasDialled: false,
          isAudioCall: false);
      if (isGroupChat) {
        callRepository.makeGroupCall(senderCallData, context, recieverCallData);
      } else {
        callRepository.makeVideoCall(senderCallData, context, recieverCallData);
      }
    });
  }

  void makeAudioCall(BuildContext context, String receiverName,
      String receiverUid, String receiverProfilePic, bool isGroupChat) {
    ref.read(userDataAuthProvider).whenData((value) {
      String callId = const Uuid().v1();
      Call senderCallData = Call(
          callerId: auth.currentUser!.uid,
          callerName: value!.name,
          callerPic: value.profilePic,
          receiverId: receiverUid,
          receiverName: receiverName,
          receiverPic: receiverProfilePic,
          callId: callId,
          hasDialled: true,
          isAudioCall: true);

      Call recieverCallData = Call(
          callerId: auth.currentUser!.uid,
          callerName: value.name,
          callerPic: value.profilePic,
          receiverId: receiverUid,
          receiverName: receiverName,
          receiverPic: receiverProfilePic,
          callId: callId,
          hasDialled: false,
          isAudioCall: true);
      if (isGroupChat) {
        callRepository.makeGroupCall(senderCallData, context, recieverCallData);
      } else {
        callRepository.makeAudioCall(senderCallData, context, recieverCallData);
      }
    });
  }

  void endCall(
    String callerId,
    String receiverId,
    BuildContext context,
  ) {
    callRepository.endCall(callerId, receiverId, context);
  }
}
