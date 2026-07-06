import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../domain/generated_file.dart';

class GeneratedZipExporter {
  const GeneratedZipExporter();

  void download({
    required String fileName,
    required List<GeneratedFile> files,
  }) {
    if (files.isEmpty) return;

    final archive = Archive();

    for (final file in files) {
      final contentBytes = utf8.encode(file.content);
      archive.addFile(
        ArchiveFile(
          file.path,
          contentBytes.length,
          contentBytes,
        ),
      );
    }

    final zipBytes = ZipEncoder().encode(archive);
    if (zipBytes == null) {
      throw Exception('Could not build zip file.');
    }

    final blob = html.Blob(
      [Uint8List.fromList(zipBytes)],
      'application/zip',
    );
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..download = fileName
      ..style.display = 'none';

    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }
}
