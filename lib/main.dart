import 'package:flutter/material.dart';
import 'package:invoices/pages/invoices_page.dart';

Future main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const String title = 'Invoices';

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: title,
    themeMode: ThemeMode.dark,
    theme: ThemeData(
      appBarTheme: const AppBarTheme(),
    ),
    home: InvoicesPage(),
  );
}
