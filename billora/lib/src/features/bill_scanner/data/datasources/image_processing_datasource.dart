import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

class ImageProcessingDataSource {
  Future<File> optimizeForOCR(File originalFile) async {
    final image = img.decodeImage(await originalFile.readAsBytes());
    if (image == null) throw Exception('Không thể đọc ảnh');
    
    // Resize để tối ưu tốc độ và chất lượng
    final resized = img.copyResize(
      image, 
      width: math.min(1200, image.width),
      height: math.min(1600, image.height),
    );
    
    // Tăng độ tương phản
    final enhanced = img.adjustColor(
      resized,
      contrast: 1.2,
      brightness: 1.1,
    );
    
    // Lưu ảnh đã tối ưu
    final tempDir = Directory.systemTemp;
    final optimizedFile = File('${tempDir.path}/optimized_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await optimizedFile.writeAsBytes(img.encodeJpg(enhanced, quality: 85));
    
    return optimizedFile;
  }

  bool hasVietnameseText(String text) {
    return RegExp(r'[àáạảãâấầẩẫậăắằẳẵặèéẹẻẽêếềểễệìíịỉĩòóọỏõôốồổỗộơờớởỡợùúụủũưừứửữựỳýỵỷỹđ]')
        .hasMatch(text.toLowerCase());
  }
} 