import 'package:flutter/material.dart';
import 'package:lafz/app/app_config.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('کیسے کھیلیں')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1. آج کا پانچ حرفی لفظ تلاش کریں۔', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('2. آپ کے پاس پانچ کوششیں ہیں۔', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              _buildRule('🟩', 'درست حرف، درست جگہ'),
              _buildRule('🟨', 'حرف موجود ہے لیکن جگہ غلط ہے'),
              _buildRule('⬜', 'حرف لفظ میں موجود نہیں'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRule(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 15),
          Text(text, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
