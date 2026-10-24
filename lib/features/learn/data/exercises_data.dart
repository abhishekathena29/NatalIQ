import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:natal_iq/features/learn/models/exercise.dart';

/// General prenatal movement and relaxation exercises, written for Natal IQ.
/// These are common, widely-recommended wellness practices (not sourced from
/// a specific study) — always framed as general guidance, not medical advice.
const kExercises = <Exercise>[
  Exercise(
    id: 'pelvic-tilt',
    title: 'Pelvic tilts',
    icon: LucideIcons.activity,
    durationLabel: '2 sets of 10',
    trimesterNote: 'Safe in all trimesters',
    benefits: [
      'Eases lower-back ache as your bump grows',
      'Gently strengthens core and pelvic muscles',
    ],
    steps: [
      'Get on your hands and knees, with wrists under shoulders and knees under hips.',
      'Keep your back neutral, then slowly tuck your pelvis under, gently rounding your lower back.',
      'Hold for 2–3 seconds, feeling your lower abdominal muscles engage.',
      'Release back to a neutral spine. That is one rep.',
      'Repeat slowly and gently, breathing normally throughout.',
    ],
    cautions: [
      'Move slowly — there should be no pain, only a gentle stretch.',
      'If hands-and-knees is uncomfortable, this can also be done standing with your back against a wall.',
    ],
  ),
  Exercise(
    id: 'cat-cow',
    title: 'Cat-cow stretch',
    icon: LucideIcons.personStanding,
    durationLabel: '8–10 slow rounds',
    trimesterNote: 'Safe in all trimesters',
    benefits: [
      'Improves spine mobility and posture',
      'Relieves tension in the back and shoulders',
    ],
    steps: [
      'Start on hands and knees in a tabletop position.',
      'Inhale, drop your belly, and lift your chest and tailbone (cow).',
      'Exhale, round your spine up toward the ceiling and tuck your chin (cat).',
      'Flow slowly between the two positions, moving with your breath.',
    ],
    cautions: [
      'Keep movements small and controlled, especially later in pregnancy.',
      'Stop if you feel any sharp pain or dizziness.',
    ],
  ),
  Exercise(
    id: 'kegels',
    title: 'Kegel exercises',
    icon: LucideIcons.heartPulse,
    durationLabel: '3 sets of 10',
    trimesterNote: 'Safe in all trimesters',
    benefits: [
      'Strengthens the pelvic floor, which supports the bladder and uterus',
      'May help with recovery after birth',
    ],
    steps: [
      'Sit or lie comfortably and relax your body.',
      'Squeeze the muscles you would use to stop the flow of urine.',
      'Hold the squeeze for 5 seconds, breathing normally.',
      'Release slowly and fully for 5 seconds.',
      'Repeat, aiming for sets of 10 a few times a day.',
    ],
    cautions: [
      'Avoid holding your breath or tensing your stomach, thighs, or buttocks instead.',
      'If you have pelvic pain, ask a physiotherapist before starting a routine.',
    ],
  ),
  Exercise(
    id: 'butterfly-stretch',
    title: 'Seated butterfly stretch',
    icon: LucideIcons.flower2,
    durationLabel: 'Hold 20–30 seconds, 3 times',
    trimesterNote: 'Safe in all trimesters',
    benefits: [
      'Opens the hips and inner thighs',
      'Can ease hip tightness as your body prepares for birth',
    ],
    steps: [
      'Sit on the floor with your back tall, soles of your feet together.',
      'Let your knees fall gently out to the sides.',
      'Hold your feet or ankles and sit up as tall as is comfortable.',
      'Breathe slowly, letting your hips soften with each exhale.',
      'Use cushions under your knees for support if needed.',
    ],
    cautions: [
      'Never bounce or force the knees down — ease in gently.',
      'Sit on a cushion or folded blanket if the floor is uncomfortable.',
    ],
  ),
  Exercise(
    id: 'wall-squat',
    title: 'Supported wall squat',
    icon: LucideIcons.dumbbell,
    durationLabel: '8–12 reps',
    trimesterNote: 'Modify depth in the third trimester',
    benefits: [
      'Builds leg and glute strength for everyday movement',
      'Can help the body prepare for labour positions',
    ],
    steps: [
      'Stand with your back against a wall, feet shoulder-width apart and a step away from the wall.',
      'Slowly bend your knees, sliding down the wall into a comfortable mini-squat.',
      'Keep your knees over your ankles, not past your toes.',
      'Hold briefly, then press through your heels to stand back up.',
    ],
    cautions: [
      'Only squat as low as feels stable and comfortable — a shallow squat is fine.',
      'Skip this if you feel pelvic instability or have been advised to avoid squatting.',
    ],
  ),
  Exercise(
    id: 'side-lying-leg-lift',
    title: 'Side-lying leg lifts',
    icon: LucideIcons.activity,
    durationLabel: '2 sets of 10 per side',
    trimesterNote: 'Great from the second trimester onward',
    benefits: [
      'Strengthens hips and outer thighs',
      'A safe alternative once lying on your back is no longer comfortable',
    ],
    steps: [
      'Lie on your side with your head resting on your arm or a pillow.',
      'Keep your bottom leg bent for stability and your top leg straight.',
      'Slowly lift your top leg toward the ceiling, keeping your hips stacked.',
      'Lower it back down with control. That is one rep.',
      'Complete a set, then switch sides.',
    ],
    cautions: [
      'Keep the movement slow and controlled rather than swinging the leg.',
      'Use a pillow between your knees if that feels more comfortable.',
    ],
  ),
  Exercise(
    id: 'prenatal-walk',
    title: 'Gentle walk',
    icon: LucideIcons.footprints,
    durationLabel: '10–20 minutes',
    trimesterNote: 'Safe in all trimesters',
    benefits: [
      'Supports heart health and circulation',
      'Can boost energy and mood',
    ],
    steps: [
      'Choose flat, even ground and comfortable, supportive shoes.',
      'Start walking at an easy pace you can hold a conversation at.',
      'Keep your posture tall and relaxed, swinging your arms naturally.',
      'Slow down or stop if you feel breathless, dizzy, or overly tired.',
      'Finish with a minute or two of slower walking to cool down.',
    ],
    cautions: [
      'Carry water, especially in warm weather.',
      'Stop and rest if you feel contractions, pain, or reduced baby movement, and contact your doctor.',
    ],
  ),
  Exercise(
    id: 'deep-breathing',
    title: 'Deep breathing & relaxation',
    icon: LucideIcons.wind,
    durationLabel: '5 minutes',
    trimesterNote: 'Safe in all trimesters',
    benefits: [
      'Calms the nervous system and lowers stress',
      'A useful skill to practise ahead of labour',
    ],
    steps: [
      'Sit or lie in a comfortable, well-supported position.',
      'Place one hand on your chest and one on your belly.',
      'Breathe in slowly through your nose, feeling your belly rise more than your chest.',
      'Breathe out slowly through your mouth, letting your shoulders soften.',
      'Continue for several slow rounds, resting between if needed.',
    ],
    cautions: [
      'If lying down, prop yourself up with cushions rather than lying flat, especially after the first trimester.',
      'Stop if you feel lightheaded and return to your normal breathing.',
    ],
  ),
];
