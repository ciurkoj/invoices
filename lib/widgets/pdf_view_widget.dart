import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path/path.dart';

class PdfViewPage extends StatefulWidget {
  final String? path;

  PdfViewPage({Key? key, this.path}) : super(key: key);

  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final PdfController _pdfController;
  TabController? _tabController;

  String errorMessage = '';
  String fileName = 'Document';
  int currentPage = 1;

  @override
  void initState() {
    _pdfController = PdfController(document: PdfDocument.openFile(widget.path!));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
      ),
      body: Stack(
        children: <Widget>[
          PdfView(
              controller: _pdfController,
              onDocumentLoaded: (document) {
                setState(() {
                  fileName = basename(document.sourceName);
                  _tabController ??= TabController(length: document.pagesCount, vsync: this);
                });
              },
              onPageChanged: (page) {
                setState(() {
                  currentPage = page;
                  _tabController?.index = page - 1;
                });
              },
              onDocumentError: (error) {
                errorMessage = error.toString();
              }),
          _pdfController.loadingState == PdfLoadingState.loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _pdfController.loadingState == PdfLoadingState.error
                  ? Center(
                      child: Text(errorMessage),
                    )
                  : Container(),
          _pdfController.pagesCount != null
              ? _pdfController.pagesCount! > 10
                  ? Positioned.fill(
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Text("$currentPage/${_pdfController.pagesCount}"))),
                    )
                  : Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                            alignment: Alignment.bottomCenter,
                            child: TabPageSelector(
                              controller: _tabController,
                            )),
                      ),
                    )
              : Container(),
        ],
      ),
    );
  }
}
