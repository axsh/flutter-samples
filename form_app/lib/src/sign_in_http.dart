// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:material_ui/material_ui.dart';

part 'sign_in_http.g.dart';

@JsonSerializable()
class FormData {
  String? email;
  String? password;

  FormData({this.email, this.password});

  factory FormData.fromJson(Map<String, dynamic> json) =>
      _$FormDataFromJson(json);

  Map<String, dynamic> toJson() => _$FormDataToJson(this);
}

class SignInHttpDemo extends StatefulWidget {
  final http.Client? httpClient;

  const SignInHttpDemo({this.httpClient, super.key});

  @override
  State<SignInHttpDemo> createState() => _SignInHttpDemoState();
}

class _SignInHttpDemoState extends State<SignInHttpDemo> {
  FormData formData = FormData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('サインインフォーム')),
      body: Form(
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...[
                  TextFormField(
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      filled: true,
                      hintText: 'メールアドレスを入力',
                      labelText: 'メール',
                    ),
                    onChanged: (value) {
                      formData.email = value;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: 'パスワード',
                    ),
                    obscureText: true,
                    onChanged: (value) {
                      formData.password = value;
                    },
                  ),
                  TextButton(
                    child: const Text('サインイン'),
                    onPressed: () async {
                      // Use a JSON encoded string to send
                      var result = await widget.httpClient!.post(
                        Uri.parse('https://example.com/signin'),
                        body: json.encode(formData.toJson()),
                        headers: {'content-type': 'application/json'},
                      );

                      _showDialog(switch (result.statusCode) {
                        200 => 'サインインに成功しました。',
                        401 => 'サインインできません。',
                        _ => 'エラーが発生しました。もう一度試してください。',
                      });
                    },
                  ),
                ].expand((widget) => [widget, const SizedBox(height: 24)]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
