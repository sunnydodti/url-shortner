import 'package:flutter/material.dart';
import '../service/url_service.dart';
import 'colored_text_box.dart';

class ViewsRow extends StatefulWidget {
  const ViewsRow({super.key, required this.shortUrl});

  final String shortUrl;

  @override
  State<ViewsRow> createState() => _ViewsRowState();
}

class _ViewsRowState extends State<ViewsRow> {
  int views = 0;
  bool loading = true;
  bool error = false;
  @override
  void initState() {
    super.initState();
    fetchViews();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 25,
      child: Row(
        children: [
          Text('Views:'),
          Spacer(),
          if (loading)
            Center(
              child: Container(
                margin: EdgeInsets.only(right: 5),
                width: 15,
                height: 15,
                child: CircularProgressIndicator(strokeWidth: 1),
              ),
            ),
          if (error)
            GestureDetector(
              onTap: () {
                setState(() {
                  loading = true;
                  error = false;
                });
                fetchViews();
              },
              child: Icon(Icons.refresh),
            ),
          if (!loading && !error) ColoredTextBox.green(views.toString()),
        ],
      ),
    );
  }

  void fetchViews() async {
    setState(() => loading = true);
    try {
      views = await UrlService.getViews(widget.shortUrl);
      setState(() => loading = false);
    } catch (e) {
      setState(() => error = true);
    }
    setState(() => loading = false);
  }
}
