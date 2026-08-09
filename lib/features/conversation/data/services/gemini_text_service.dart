import 'package:firebase_ai/firebase_ai.dart';


class GeminiTextService {
  static final FirebaseAI _ai = FirebaseAI.googleAI();

  Future<String?> generateResponseWithPersonality({
    required String userMessage,
    required String personality,
    required String friendName,
  }) async {
    try {
      // 1. بناء تعليمات النظام كنص (String)
      final systemPromptText = _getPersonalityPrompt(friendName, personality);

      // 2. تحويل النص إلى كائن Content باستخدام Content.system()
      final systemInstructionContent = Content.system(systemPromptText);

      final model = _ai.generativeModel(
        model: 'gemini-3.5-flash', // ✅ تم التعديل
        generationConfig: GenerationConfig(
          temperature: 0.8,
          maxOutputTokens: 250,
        ),
        // 3. تمرير كائن Content إلى systemInstruction
        systemInstruction: systemInstructionContent,
      );

      final prompt = Content.text(userMessage);

      final response = await model.generateContent([prompt]);
      final DateTime sentAt = DateTime.now();

      if (response.text != null && response.text!.isNotEmpty) {
        return response.text;
      }
      return null;
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }

  String _getPersonalityPrompt(String friendName, String personality) {
    return 'You are a friend named $friendName.\n\n'
        'Your personality: $personality\n\n'
        'Important Instructions:\n'
        '- Speak only in English.\n'
        '- Do not use any other language.\n'
        '- Use natural, conversational English.\n'
        '- Keep responses short and natural (1-2 sentences max).\n'
        '- Use appropriate emojis for your personality.';
  }
}