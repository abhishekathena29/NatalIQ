/// Local, on-device stand-in for the `/api/chat` streaming endpoint used by
/// the React app (which calls a hosted AI gateway with a private key). There
/// is no backend to port here, so Aanya's replies are generated from a small
/// set of warm, non-diagnostic canned answers keyed by keyword — enough to
/// preserve the chat flow, timing and UI without a network dependency.
class AanyaAi {
  AanyaAi._();

  static const _fallback =
      "That's a thoughtful question. In general, listen to your body, stay "
      "hydrated, and keep up with your prenatal visits. If anything feels "
      "urgent or unusual, please reach out to your doctor — I'm here for "
      "gentle guidance, not diagnosis.";

  static final List<(List<String>, String)> _canned = [
    (
      ['papaya', 'pineapple', 'food', 'eat', 'diet', 'avoid'],
      "Ripe papaya in small amounts is generally considered fine, but raw or "
          "unripe papaya is best avoided — it can contain compounds linked to "
          "contractions. As a rule of thumb, skip unpasteurized dairy, raw "
          "fish, and undercooked meat too. When in doubt, ask your doctor "
          "about your specific diet."
    ),
    (
      ['water', 'hydrat'],
      "Aim for about 8–10 glasses (roughly 2.3 litres) of water a day, a "
          "little more if it's warm or you're active. Keeping a bottle nearby "
          "and sipping through the day is gentler than large amounts at once."
    ),
    (
      ['cramp', 'pain', 'ache'],
      "Mild, occasional cramping can be normal as your body stretches to make "
          "room for your baby. But if it's severe, comes with bleeding, or "
          "doesn't ease with rest, please contact your doctor today — better "
          "safe than sorry."
    ),
    (
      ['exercise', 'yoga', 'walk', 'workout'],
      "Gentle movement like walking, prenatal yoga, and swimming are usually "
          "safe and can even ease back pain and improve sleep. Avoid lying "
          "flat on your back for long periods and anything with a high fall "
          "risk. Always check with your doctor for guidance specific to you."
    ),
    (
      ['sleep', 'tired', 'fatigue'],
      "Fatigue is very common, especially in the first and third trimesters. "
          "Try short naps, sleeping on your side with a pillow between your "
          "knees, and winding down screens an hour before bed. Rest really is "
          "medicine right now."
    ),
    (
      ['kick', 'movement', 'baby move'],
      "Feeling regular movement is reassuring. If you notice a clear "
          "reduction in your baby's usual movements, don't wait — contact "
          "your doctor the same day to have it checked."
    ),
  ];

  static Future<String> reply(String prompt) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final lower = prompt.toLowerCase();
    for (final (keywords, answer) in _canned) {
      if (keywords.any(lower.contains)) return answer;
    }
    return _fallback;
  }
}
