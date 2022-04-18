import 'dart:convert';
import 'package:example/preferences.dart';
import 'package:http/testing.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:json_annotation/json_annotation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:example/platforms.dart';

@JsonSerializable()
class FormData {
  String? email;
  String? password;

  FormData({
    this.email,
    this.password,
  });

  factory FormData.fromJson(Map<String, dynamic> json) => FormData(
        email: json['email'] as String?,
        password: json['password'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'email': email,
        'password': password,
      };
}

Widget _getPlatformTextFormField(
    {bool autofocus = false,
    bool obscureText = false,
    int maxLines = 1,
    Key? key,
    TextInputAction? textInputAction,
    TextInputType? textInputType,
    String? hintText,
    String? labelText,
    required ValueChanged<String> onChangeCallback}) {
  if (PlatformWidget.isAndroid) {
    return TextFormField(
      key: key,
      autofocus: autofocus,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        filled: true,
        hintText: hintText,
        labelText: labelText,
      ),
      onChanged: onChangeCallback,
      maxLines: maxLines,
      obscureText: obscureText,
    );
  } else {
    return CupertinoTextField(
      key: key,
      keyboardType: textInputType,
      placeholder: hintText,
      onChanged: onChangeCallback,
      textInputAction: textInputAction,
      maxLines: maxLines,
      obscureText: obscureText,
    );
  }
}

class DialogRadioGroup extends Column {
  static int _value = 5;
  late List<String> elements;

  static Widget _getDialogComponent(int index, String option) {
    if (PlatformWidget.isAndroid) {
      return ListTile(
        title: Text(
          option,
        ),
        contentPadding: const EdgeInsets.all(1),
        leading: Radio(
          key: Key('dialog-radio-$index'),
          value: index,
          groupValue: _value,
          activeColor: Colors.blue,
          onChanged: index == 5
              ? null
              : (int? value) {
                  _value = value!;
                },
        ),
      );
    } else {
      return Material(
          color: Colors.transparent,
          child: ListTile(
            title: Text(
              option,
            ),
            contentPadding: const EdgeInsets.all(0),
            leading: Radio(
              key: Key('dialog-radio-$index'),
              value: index,
              groupValue: _value,
              activeColor: Colors.blue,
              onChanged: index == 5
                  ? null
                  : (int? value) {
                      _value = value!;
                    },
            ),
          ));
    }
  }

  DialogRadioGroup({required this.elements})
      : super(
          children: [
            for (int index = 0; index < elements.length; index++)
              _getDialogComponent(index, elements[index]),
          ],
        );
}

class SignInHttpDemo extends StatefulWidget {
  final http.Client? httpClient;

  const SignInHttpDemo({
    this.httpClient,
    Key? key,
  }) : super(key: key);

  @override
  _SignInHttpDemoState createState() => _SignInHttpDemoState();
}

class _SignInHttpDemoState extends State<SignInHttpDemo> {
  FormData formData = FormData();

  Widget _buildBody(BuildContext context) {
    return Form(
        child: Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...[
              _getPlatformTextFormField(
                key: const Key('input-email'),
                hintText: 'Your email address',
                labelText: 'Email',
                textInputAction: TextInputAction.next,
                onChangeCallback: (value) {
                  formData.email = value;
                },
              ),
              _getPlatformTextFormField(
                key: const Key('input-password'),
                labelText: 'Password',
                onChangeCallback: (value) {
                  formData.password = value;
                },
                obscureText: true,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                TextButton(
                  child: const Text('Sign in'),
                  onPressed: () async {
                    // Use a JSON encoded string to send
                    var result = await widget.httpClient!.post(
                        Uri.parse('https://example.com/signin'),
                        body: json.encode(formData.toJson()),
                        headers: {'content-type': 'application/json'});

                    if (result.statusCode == 200) {
                      _showDialog('Successfully signed in.');
                    } else if (result.statusCode == 401) {
                      _showDialog('Unable to sign in.');
                    } else {
                      _showDialog('Something went wrong. Please try again.');
                    }
                  },
                ),
                TextButton(
                  child: const Text('Forgot Password'),
                  onPressed: () async {
                    _showForgotPasswordDialog();
                  },
                ),
              ]),
            ].expand(
              (widget) => [
                widget,
                const SizedBox(
                  height: 24,
                )
              ],
            )
          ],
        ),
      ),
    ));
  }

  Widget _getForgotPasswordBody() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const Text(
          'To verify that this is your email address, select the location to send your verification code.'),
      const Padding(padding: EdgeInsets.all(1), child: Divider()),
      DialogRadioGroup(elements: const [
        "Email em***@***il.com",
        "Text ***-***-**95",
        "Call ***-***-**95",
        "I don't have these anymore",
      ])
    ]);
  }

  WidgetBuilder _getForgotPasswordBuilder() {
    if (PlatformWidget.isAndroid) {
      return (BuildContext context) => AlertDialog(
              title: const Text('Forgot Password'),
              content: _getForgotPasswordBody(),
              actions: [
                TextButton(
                    child: const Text('Cancel', key: Key('dialog-cancel')),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                TextButton(
                    child: const Text('Send Code', key: Key('dialog-send')),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ]);
    } else {
      return (BuildContext context) => CupertinoAlertDialog(
              title: const Text('Forgot Password'),
              content: _getForgotPasswordBody(),
              actions: [
                TextButton(
                    child: const Text('Cancel', key: Key('dialog-cancel')),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                TextButton(
                    child: const Text('Send Code', key: Key('dialog-send')),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ]);
    }
  }

  void _showForgotPasswordDialog() {
    final dialogBuilder = _getForgotPasswordBuilder();

    if (PlatformWidget.isAndroid) {
      showDialog<void>(context: context, builder: dialogBuilder);
    } else {
      showCupertinoModalPopup<void>(context: context, builder: dialogBuilder);
    }
  }

  WidgetBuilder _getDialogBuilder(String message) {
    if (PlatformWidget.isAndroid) {
      return (BuildContext context) =>
          AlertDialog(title: Text(message), actions: [
            TextButton(
                child: const Text('OK', key: Key('dialog-ok')),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ]);
    } else {
      return (BuildContext context) =>
          CupertinoAlertDialog(title: Text(message), actions: [
            TextButton(
                child: const Text('OK', key: Key('dialog-ok')),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ]);
    }
  }

  void _showDialog(String message) {
    final dialogBuilder = _getDialogBuilder(message);

    if (PlatformWidget.isAndroid) {
      showDialog<void>(context: context, builder: dialogBuilder);
    } else {
      showCupertinoModalPopup<void>(context: context, builder: dialogBuilder);
    }
  }

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Form Widgets')),
        body: _buildBody(context));
  }

  Widget _buildIOS(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar:
            const CupertinoNavigationBar(middle: Text('Form Widgets')),
        child: SafeArea(child: _buildBody(context)));
  }

  @override
  Widget build(context) {
    return PlatformWidget(
      androidBuilder: _buildAndroid,
      iosBuilder: _buildIOS,
    );
  }
}

// Set up a mock HTTP client.
final http.Client mockClient = MockClient(_mockHandler);

Future<http.Response> _mockHandler(http.Request request) async {
  var decodedJson = Map<String, dynamic>.from(
      json.decode(request.body) as Map<String, dynamic>);

  if (decodedJson['email'] == 'email@gmail.com' &&
      decodedJson['password'] == 'emailP@s5') {
    return http.Response('', 200);
  }

  return http.Response('', 401);
}

class FormWidgetsDemo extends StatefulWidget {
  const FormWidgetsDemo({Key? key}) : super(key: key);

  @override
  _FormWidgetsDemoState createState() => _FormWidgetsDemoState();
}

class _FormWidgetsDemoState extends State<FormWidgetsDemo> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  DateTime date = DateTime(2022, 4, 15);
  double maxValue = 0;
  bool? sendNotifications = false;
  bool enableFeature = false;

  Widget _getDialogComponent(int index, String key, String message) {
    if (PlatformWidget.isAndroid) {
      return ListTile(title: Text(message, key: Key(key)));
    } else {
      return Material(
          color: Colors.transparent,
          child: ListTile(
              contentPadding: const EdgeInsets.all(1),
              title: Text(message, key: Key(key))));
    }
  }

  Widget _getDialogBody() {
    return ListView.builder(
      // padding: const EdgeInsets.all(1),
      shrinkWrap: true,
      itemCount: 4,
      itemBuilder: (BuildContext context, int index) {
        switch (index) {
          case 0:
            return _getDialogComponent(0, 'dialog-date',
                'Date: ${intl.DateFormat.yMd().format(date)}');
          case 1:
            return _getDialogComponent(1, 'dialog-dollars',
                'Dollars: \$${maxValue.toStringAsFixed(2)}');
          case 2:
            return _getDialogComponent(2, 'dialog-fb-notifications',
                'Facebook Notifications: $sendNotifications');
          case 3:
            return _getDialogComponent(3, 'dialog-gh-notifications',
                'Github Notifications: $enableFeature');
          default:
            return Container();
        }
      },
    );
  }

  WidgetBuilder _getDialogBuilder(String message) {
    if (PlatformWidget.isAndroid) {
      return (BuildContext context) => AlertDialog(
              title: Text(message),
              content: Container(
                  height: 300.0, width: 300.0, child: _getDialogBody()),
              actions: [
                TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ]);
    } else {
      return (BuildContext context) => CupertinoAlertDialog(
              title: Text(message),
              content: Container(
                  height: 300.0, width: 300.0, child: _getDialogBody()),
              actions: [
                TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ]);
    }
  }

  void _showDialog(String message) {
    final dialogBuilder = _getDialogBuilder(message);

    if (PlatformWidget.isAndroid) {
      showDialog<void>(context: context, builder: dialogBuilder);
    } else {
      showCupertinoModalPopup<void>(context: context, builder: dialogBuilder);
    }
  }

  Widget _buildBody(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scrollbar(
        child: Align(
          alignment: Alignment.center,
          child: Card(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ...[
                      _FormDatePicker(
                        date: date,
                        onChanged: (value) {
                          setState(() {
                            date = value;
                          });
                        },
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Estimated value',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ],
                          ),
                          Text(
                            intl.NumberFormat.currency(
                                    symbol: "\$", decimalDigits: 0)
                                .format(maxValue),
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          Slider(
                            key: const Key('form-slider'),
                            min: 0,
                            max: 500,
                            divisions: 500,
                            value: maxValue,
                            onChanged: (value) {
                              print('value: $value');
                              setState(() {
                                maxValue = value;
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            key: const Key('form-checkbox'),
                            value: sendNotifications,
                            onChanged: (checked) {
                              setState(() {
                                sendNotifications = checked;
                              });
                            },
                          ),
                          Text('Send Facebook Notifications',
                              style: Theme.of(context).textTheme.subtitle1),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Send Github Notifications',
                              style: Theme.of(context).textTheme.bodyText1),
                          Switch(
                            key: const Key('form-switch'),
                            value: enableFeature,
                            onChanged: (enabled) {
                              setState(() {
                                enableFeature = enabled;
                              });
                            },
                          ),
                        ],
                      ),
                      Container(
                          width: 500,
                          child: ElevatedButton(
                            onPressed: () {
                              _showDialog('Form State');
                            },
                            child: const Text("Submit"),
                          )),
                    ].expand(
                      (widget) => [
                        widget,
                        const SizedBox(
                          height: 24,
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Form Widgets')),
        body: _buildBody(context));
  }

  Widget _buildIOS(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar:
            const CupertinoNavigationBar(middle: Text('Form Widgets')),
        child: SafeArea(child: _buildBody(context)));
  }

  @override
  Widget build(context) {
    return PlatformWidget(
      androidBuilder: _buildAndroid,
      iosBuilder: _buildIOS,
    );
  }
}

class _FormDatePicker extends StatefulWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const _FormDatePicker({
    required this.date,
    required this.onChanged,
  });

  @override
  _FormDatePickerState createState() => _FormDatePickerState();
}

class _FormDatePickerState extends State<_FormDatePicker> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'Date',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Text(
              intl.DateFormat.yMd().format(widget.date),
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ],
        ),
        TextButton(
          child: const Text('Edit'),
          onPressed: () async {
            _showDateDialog();
          },
        )
      ],
    );
  }

  WidgetBuilder _showCupertinoDateDialog(
      DateTime date, ValueChanged<DateTime> onDateChanged) {
    return (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: CupertinoDatePicker(
            initialDateTime: date,
            mode: CupertinoDatePickerMode.date,
            use24hFormat: true,
            onDateTimeChanged: onDateChanged,
          ),
        ));
  }

  void _showDateDialog() async {
    if (PlatformWidget.isAndroid) {
      var newDate = await showDatePicker(
        context: context,
        initialDate: widget.date,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
      );
      // Don't change the date if the date picker returns null.
      if (newDate == null) {
        return;
      }

      widget.onChanged(newDate);
    } else {
      final dialogBuilder =
          _showCupertinoDateDialog(widget.date, (DateTime? newDate) {
        // Don't change the date if the date picker returns null.
        if (newDate == null) {
          return;
        }
        setState(() => widget.onChanged(newDate));
      });

      showCupertinoModalPopup<DateTime>(
          context: context, builder: dialogBuilder);
    }
  }
}

final demos = [
  Demo(
    name: 'Sign in with HTTP',
    builder: (context) => SignInHttpDemo(
      httpClient: mockClient,
    ),
  ),
  Demo(
    name: 'Form Widgets',
    builder: (context) => const FormWidgetsDemo(),
  ),
  Demo(
    name: 'Preferences',
    builder: (context) => PreferencesPage(),
  ),
];

class FormsPage extends StatelessWidget {
  const FormsPage({Key? key}) : super(key: key);

  Widget _getDemoTile(Demo demo, int index) {
    if (PlatformWidget.isAndroid) {
      return DemoTile(key: Key('item_$index'), demo: demo);
    } else {
      return Material(
        child: DemoTile(key: Key('item_$index'), demo: demo),
      );
    }
  }

  Widget _buildBody(BuildContext context) {
    return ListView(
        children: [...demos.map((d) => _getDemoTile(d, demos.indexOf(d)))]);
  }

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(),
        body: _buildBody(context));
  }

  Widget _buildIOS(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar:
            const CupertinoNavigationBar(middle: Text('Form Widgets')),
        child: SafeArea(child: _buildBody(context)));
  }

  @override
  Widget build(context) {
    return PlatformWidget(
      androidBuilder: _buildAndroid,
      iosBuilder: _buildIOS,
    );
  }
}

class DemoTile extends StatelessWidget {
  final Demo demo;

  const DemoTile({required this.demo, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(demo.name),
      onTap: () {
        Navigator.push<void>(context, MaterialPageRoute(builder: demo.builder));
      },
    );
  }
}

class Demo {
  final String name;
  final WidgetBuilder builder;

  const Demo({required this.name, required this.builder});
}
