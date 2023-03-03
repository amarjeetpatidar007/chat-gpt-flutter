import 'dart:async';

import 'package:chatgpt_flutter/models/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController textEditingController = TextEditingController();
  List<ChatMessage> chatMessages = [];
  late OpenAI chatgpt;
  StreamSubscription? streamSubscription;
  bool _isLoading = false;

  @override
  void initState() {
    chatgpt = OpenAI.instance;
    super.initState();
  }

  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  addMessage() {
    ChatMessage message =
        ChatMessage(text: textEditingController.text, user: "user");
    setState(() {
      chatMessages.insert(0, message);
      _isLoading = true;
    });

    textEditingController.clear();

    final req = CompleteText(
        model: kTranslateModelV3, prompt: message.text, maxTokens: 200);
    streamSubscription = chatgpt
        .build(token: "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")
        .onCompleteStream(request: req)
        .listen((response) {
      ChatMessage botMessage =
          ChatMessage(text: response!.choices[0].text, user: "Bot");

      setState(() {
        _isLoading = false;
        chatMessages.insert(0, botMessage);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Chat GPT'),
          centerTitle: true,
        ),
        bottomNavigationBar: ListTile(
          title: TextFormField(
            controller: textEditingController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: " Type... "),
          ),
          trailing: ElevatedButton(
            style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(const Size(50, 50))),
            child: const Icon(
              Icons.send,
            ),
            onPressed: addMessage,
          ),
        ),
        body: ListView.builder(
          reverse: true,
          padding: const EdgeInsets.all(10),
          itemCount: chatMessages.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChatMessage(
                      text: chatMessages[index].text,
                      user: chatMessages[index].user),
                ),
                const Divider(
                  thickness: 1.0,
                ),
                if (_isLoading) CircularProgressIndicator.adaptive()
              ],
            );
          },
        ));
  }
}
