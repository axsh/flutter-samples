// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:english_words/english_words.dart' as english_words;
import 'package:material_ui/material_ui.dart';

class FormValidationDemo extends StatefulWidget {
  const FormValidationDemo({super.key});

  @override
  State<FormValidationDemo> createState() => _FormValidationDemoState();
}

class _FormValidationDemoState extends State<FormValidationDemo> {
  final _formKey = GlobalKey<FormState>();
  String? adjective;
  String? noun;
  bool? agreedToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📖 ストーリージェネレーター'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextButton(
              child: const Text('送信'),
              onPressed: () {
                // Validate the form by getting the FormState from the GlobalKey
                // and calling validate() on it.
                var valid = _formKey.currentState!.validate();
                if (!valid) {
                  return;
                }

                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('あなたのストーリー'),
                    content: Text('$adjectiveな開発者が$nounを見た'),
                    actions: [
                      TextButton(
                        child: const Text('完了'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // A text field that validates that the text is an adjective.
                TextFormField(
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return '形容詞を入力してください。';
                    }
                    if (english_words.adjectives.contains(value)) {
                      return null;
                    }
                    return '有効な形容詞ではありません。';
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    hintText: '例: quick、beautiful、interesting',
                    labelText: '形容詞を入力',
                  ),
                  onChanged: (value) {
                    adjective = value;
                  },
                ),
                const SizedBox(height: 24),
                // A text field that validates that the text is a noun.
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return '名詞を入力してください。';
                    }
                    if (english_words.nouns.contains(value)) {
                      return null;
                    }
                    return '有効な名詞ではありません。';
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    hintText: '例: 人、場所、物',
                    labelText: '名詞を入力',
                  ),
                  onChanged: (value) {
                    noun = value;
                  },
                ),
                const SizedBox(height: 24),
                // A custom form field that requires the user to check a
                // checkbox.
                FormField<bool>(
                  initialValue: false,
                  validator: (value) {
                    if (value == false) {
                      return 'サービス利用規約に同意する必要があります。';
                    }
                    return null;
                  },
                  builder: (formFieldState) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: agreedToTerms,
                              onChanged: (value) {
                                // When the value of the checkbox changes,
                                // update the FormFieldState so the form is
                                // re-validated.
                                formFieldState.didChange(value);
                                setState(() {
                                  agreedToTerms = value;
                                });
                              },
                            ),
                            Text(
                              '利用規約に同意します。',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        if (!formFieldState.isValid)
                          if (formFieldState.errorText != null)
                            Text(
                              'サービス利用規約に同意する必要があります。',
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.error,
                                  ),
                            ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
