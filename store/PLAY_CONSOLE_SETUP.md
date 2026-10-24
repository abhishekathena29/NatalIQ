# Natal IQ — Google Play Console "Finish setting up your app"

Package: `com.nataliq.app` · Version `1.0.0 (1)`

Replace every `[PLACEHOLDER]` before you submit.

---

## 0. Fix these before you submit (otherwise Google will reject the app)

| # | Issue | Why it matters | Fix |
|---|-------|----------------|-----|
| 1 | **No in-app account deletion** | Play's account deletion policy requires an in-app delete option and a web link for any app where users can create an account. | Add **More → Delete account**. It should delete `users/{uid}` and the user's posts, comments and likes, then call `FirebaseAuth.currentUser.delete()`. Host `store/delete-account.html`. |
| 2 | **Community has no Report or Block** | Play's UGC policy requires users to be able to report content and block other users, and requires the developer to moderate. | Add a Report option to posts and comments (writes to a `reports` collection) and a Block user option. Users must accept community guidelines before they can post. |
| 3 | **Doctors screen shows made-up "Verified & available today" doctors with fees and ratings** | This breaks Play's misleading-claims and health policies. | Remove the screen or label it clearly as "Coming soon / sample". |
| 4 | **Exact alarms**: the nap timer uses `AndroidScheduleMode.exactAllowWhileIdle`, but the manifest has no `SCHEDULE_EXACT_ALARM` | Scheduling throws on Android 12+. If you add `USE_EXACT_ALARM`, Play asks for a restricted declaration. | Switch to `inexactAllowWhileIdle`, or add `<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>`. |
| 5 | The main `AndroidManifest.xml` has no `INTERNET` permission (only the debug and profile manifests do) | The Groq chat and `http` calls can fail in release builds. | Add `<uses-permission android:name="android.permission.INTERNET"/>` to `android/app/src/main/AndroidManifest.xml`. |
| 6 | The app label is `natal_iq` and the launcher icon is the default Flutter icon | Users see this on their home screen, and reviewers notice it. | Set `android:label="Natal IQ"`. Generate launcher icons from `store/app-icon-512.png` using `flutter_launcher_icons`. |
| 7 | Any signed-in user can read the Groq API key from Firestore `config/aanya` | Anyone can extract the key and run up your bill. Not a Play policy issue, but a real risk. | Move the Groq call into a Firebase Cloud Function. |
| 8 | Health disclaimer | Health apps policy. | Show "Not medical advice. Consult your doctor." on the Symptom checker, the Aanya chat and onboarding. |

> New **personal** developer accounts must run a **closed test with at least 12 testers for 14 continuous days** before they can apply for Production access. Start that track early.

---

## 1. Privacy policy
- **URL:** host `store/privacy-policy.html` at a public URL. Options: Firebase Hosting (`firebase deploy --only hosting`), GitHub Pages, or Google Sites. Example: `https://nataliq.web.app/privacy-policy.html`
- The page must be public, not a PDF, not editable, and must name the app and the developer.

## 2. App access
- Select **"All or some functionality is restricted"**. A login is required.
- Add instructions:
  - Name: `Reviewer account`
  - Username: `[reviewer@yourdomain.com]`
  - Password: `[password]`
  - Notes: "Log in with the email and password above. Onboarding is already complete. Every feature (Home, Track, Aanya chat, Learn, Journal, Community) is available after login. No OTP or 2FA."
- Create this account in Firebase Auth beforehand and finish onboarding with it.

## 3. Ads
- **No, my app does not contain ads.**

## 4. Content rating (IARC questionnaire)
- Email: `[SUPPORT_EMAIL]`
- Category: **All other app types** (Reference, News, Educational / Health)
- Violence, fear, sexuality, language, controlled substances, gambling: **No** to all
- Crude humour: No
- **Users can interact or exchange content:** **Yes** (community posts and comments)
- Shares the user's current physical location with other users: **No**
- Allows users to buy digital goods: **No**
- Web browser or search engine: **No**
- Expected result: **Everyone / PEGI 3 / IARC 3+**, flagged "Users Interact". If the pregnancy and body content raises it to Teen or 12+, that is fine.

## 5. Target audience and content
- Target age groups: **18 and over only**
- Appeals to children: **No**
- Store presence: no "Designed for Families"

## 6. News app
- **No**

## 7. COVID-19 contact tracing and status apps
- **My app is not a publicly available COVID-19 contact tracing or status app**

## 8. Data safety
**Overview**
- Does your app collect or share any of the required user data types? **Yes**
- Is all user data encrypted in transit? **Yes**
- Do you provide a way for users to request deletion of their data? **Yes**. Give the URL of `delete-account.html`.
- Account creation method: **Username/email and password**. Add the delete-account URL.

**Data types to declare**

| Data type | Collected | Shared | Optional? | Purposes |
|---|---|---|---|---|
| Personal info → **Name** | Yes | No | Required | App functionality, Account management |
| Personal info → **Email address** | Yes | No | Required | App functionality, Account management |
| Personal info → **User IDs** | Yes | No | Required | App functionality, Account management |
| Health and fitness → **Health info** (pregnancy week, first pregnancy) | Yes | No | Required | App functionality, Personalisation |
| Messages → **Other in-app messages** (Aanya chat text processed by Groq) | Yes* | No** | Optional | App functionality |
| App activity → **Other user-generated content** (community posts, comments) | Yes | No | Optional | App functionality |
| App activity → **App interactions** (likes, communities joined) | Yes | No | Optional | App functionality |

\* Chat text goes off the device to Groq to generate replies, so it counts as "collected". Mark it **processed ephemerally** only if you have confirmed Groq does not retain it. Otherwise leave that box unticked.
\*\* Groq acts as a service provider processing data for you. Google does not count that as "sharing".

**Do not declare** (these stay on the device and are never sent anywhere): journal, tracker (mood, water, steps, sleep, kicks), nap sessions, reminders, quiz answers. You collect no location, photos, contacts, financial data, device IDs or advertising ID.

## 9. Government apps
- **No**

## 10. Financial features
- **My app doesn't provide any financial features**

## 11. Health apps
- Select **Yes, my app has health features**, then tick:
  - Health & Fitness → **Health management** (pregnancy tracking), **Activity and fitness** (steps, prenatal exercises), **Sleep management** (sleep and nap tracking), **Stress management / Mental health** (journal, mood)
  - Medical → **Medical reference and education** (Learn modules, symptom checker)
  - Tick **Reproductive / pregnancy health** if the list offers it.
- The app is **not** regulated as a medical device. No health data is shared with third parties for ads.
- Health Connect: **not used**

## 12. Advertising ID
- **No.** The app does not use the advertising ID. No ads or analytics SDKs are included. Recheck this if you add `firebase_analytics`.

---

## 13. Main store listing

**App name** (30 max)
```
Natal IQ: Pregnancy Companion
```

**Short description** (80 max)
```
Week-by-week pregnancy guide, AI companion, tracker, journal & mom community.
```

**Full description** (4000 max)
```
Natal IQ is your gentle companion for pregnancy and early motherhood: calm, practical support every day, from your first trimester to your first weeks with your baby.

MEET AANYA, YOUR AI COMPANION
Ask Aanya anything, any time of day. Morning sickness, sleep, food cravings, nervous thoughts at 3 a.m. Aanya gives warm, simple answers in a few sentences, and gently reminds you to talk to your doctor when something needs medical attention.

WEEK-BY-WEEK GUIDANCE
Tell us your pregnancy week and Natal IQ shapes your home screen around you: what's happening with your baby, what your body may be feeling, and small things you can do today.

TRACK YOUR DAY
• Mood check-ins
• Water intake towards your daily goal
• Steps and gentle walks
• Sleep hours, plus a nap timer with a home-screen widget
• Baby kick counter

LEARN & PRACTISE
Short lessons on pregnancy, birth and postpartum recovery, plus guided prenatal exercises and stretches you can follow at home.

PRIVATE JOURNAL
Write about your journey and get gentle prompts and insights. Your journal stays on your phone.

A COMMUNITY THAT GETS IT
Join communities of mothers at the same stage, share how you're doing, ask questions and cheer each other on.

REMINDERS & CAREGIVER MODE
Set reminders for vitamins, water and appointments. Caregiver mode helps partners and family learn how to support you.

PRIVATE BY DESIGN
Your chats, journal and daily logs are stored on your device. No ads. We never sell your data.

IMPORTANT
Natal IQ provides general wellness information and is not a substitute for professional medical advice, diagnosis or treatment. Always consult your doctor or midwife about your health and your baby's health. In an emergency, call your local emergency number.

Questions or feedback? Write to us at [SUPPORT_EMAIL].
```

**Graphics**
| Asset | Spec | File |
|---|---|---|
| App icon | 512 × 512 PNG, ≤1 MB | `store/app-icon-512.png` |
| Feature graphic | 1024 × 500 PNG/JPG | `store/feature-graphic-1024x500.png` |
| Phone screenshots | 2–8 images, 9:16 aspect ratio, min 1080 px on the short side recommended (e.g. 1080 × 1920) | Take these from the emulator: Home, Aanya chat, Track, Learn, Journal, Community |
| 7" / 10" tablet screenshots | Optional | Skip unless you support tablets |

Editable sources: `store/src/icon.html` and `store/src/feature.html`. Re-render with headless Chrome or Brave.

**Store settings**
- App category: **Health & Fitness** (or **Parenting**)
- Tags: Pregnancy, Health & wellness, Parenting, Women's health
- Contact email: `[SUPPORT_EMAIL]` (required)
- Website: `[https://nataliq.web.app]` (optional)
- Phone: optional

---

## 14. Other items on the dashboard
- **Countries/regions:** start with India, or add more (the copy is in English).
- **Pricing:** Free. This cannot be changed to paid later.
- **App signing:** use Play App Signing. Upload an `.aab` built with `flutter build appbundle --release` and signed with your upload key.
- **Release notes v1.0.0:** "First release of Natal IQ: week-by-week guidance, Aanya AI companion, daily tracker, journal, learning modules and community."
