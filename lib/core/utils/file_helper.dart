import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';

class FileHelper {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  
  static Future<File> generateCsvFile(List<List<dynamic>> rows, String fileName) async {
    final csv = const ListToCsvConverter().convert(rows);
    final path = await _localPath;
    final file = File('$path/$fileName.csv');
    
    return file.writeAsString(csv);
  }
  
  static Future<File> generatePdfReport({
    required String title,
    required List<String> headers,
    required List<List<String>> data,
    String fileName = 'report',
  }) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(title, style: pw.TextStyle(fontSize: 20)),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: headers,
              data: data,
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellHeight: 30,
              cellAlignments: {
                for (var i = 0; i < headers.length; i++)
                  i: pw.Alignment.centerLeft,
              },
            ),
            pw.SizedBox(height: 20),
            pw.Footer(
              margin: const pw.EdgeInsets.only(top: 20),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Generated on: ${DateTime.now().toString().split('.')[0]}'),
                  pw.Text('Page ${context.pageNumber} of ${context.pagesCount}'),
                ],
              ),
            ),
          ];
        },
      ),
    );
    
    final path = await _localPath;
    final file = File('$path/$fileName.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }
  
  static Future<void> shareFile(File file) async {
    await Share.shareXFiles([XFile(file.path)]);
  }
}
