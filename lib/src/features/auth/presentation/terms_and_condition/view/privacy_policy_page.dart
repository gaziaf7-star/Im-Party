import 'package:general/src/core/index.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  /// This app's own Privacy Policy content, always shown in the App —
  /// no longer pulled from the backend admin panel, because the old
  /// admin-managed text (RealtimeConfig.privacyPolicyEn/Ar) kept taking
  /// priority and hiding this app's own policy whenever it wasn't empty.
  /// Edit `_defaultPrivacyPolicyHtml` below directly to update the policy
  /// shown in the App.
  String _content() => _defaultPrivacyPolicyHtml;

  @override
  Widget build(BuildContext context) {
    final content = _content();
    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: AppBarWidget(
        backgroundColor: ColorManager.white,
        iconColor: ColorManager.black,
        titleStyle: context.bodyLarge.bold.colorExt(ColorManager.black),
        title: StringManager.privacyPolicy.tr(),
      ),
      body: Container(
        width: ScreenUtil().screenWidth,
        height: ScreenUtil().screenHeight,
        color: ColorManager.white,
        padding: context.paddingSymmetric(horizontal: 20),
        child: content.isEmpty
            ? Center(
          child: Text(
            StringManager.noDataYet.tr(),
            style: context.bodyLarge.colorExt(ColorManager.black),
          ),
        )
            : SingleChildScrollView(
          child: Column(
            children: [
              5.hBox,
              HtmlWidget(
                content,
                textStyle:
                context.bodyLarge.colorExt(ColorManager.black),
              ),
              5.hBox,
            ],
          ),
        ),
      ),
    );
  }
}

/// Built-in default Privacy Policy (used whenever the admin panel hasn't
/// set one via /config/settings). Written to cover the disclosures Google
/// Play commonly checks for a live-streaming / chat / virtual-currency app:
/// data collected, account & data deletion instructions, children's
/// privacy, virtual currency, and contact details.
///
/// Website: https://iamparty.linlive.fr
/// Contact: help24imran@gmail.com
///
/// NOTE: This is a general-purpose template, not legal advice. If your app
/// collects data differently than described here (e.g. no location or
/// contacts access), edit the relevant section below to match reality —
/// Play Store checks that your Data Safety form and policy text agree.
const String _defaultPrivacyPolicyHtml = '''
<h2>Privacy Policy — iamParty</h2>
<p><b>Effective date:</b> October 31, 2026<br/>
<b>Last updated:</b> October 31, 2026<br/>
<b>Website:</b> https://iamparty.linlive.fr<br/>
<b>Contact:</b> help24imran@gmail.com</p>

<p>This Privacy Policy explains how iamParty ("the App", "we", "us", "our") collects, uses, shares, and protects information when you use our live-streaming, chat, and social networking application and related services (together, the "Service"). By creating an account or using the Service, you agree to the practices described here.</p>

<p>If you do not agree with this Policy, please do not use the Service.</p>

<h3>1. Information We Collect</h3>
<p><b>Information you provide directly</b></p>
<ul>
<li><b>Account information:</b> phone number, email address, and password (or third-party sign-in credentials such as Google/Facebook/Apple ID).</li>
<li><b>Profile information:</b> display name, username, profile photo, cover photo, gender, birthday, country, and any bio/description you add.</li>
<li><b>User content:</b> photos, videos, live broadcasts, voice/video room activity, text messages, group posts, comments, and gifts you send or receive.</li>
<li><b>Payment information:</b> when you purchase coins, diamonds, VIP, or other virtual items, payment is processed by the Google Play billing system or our third-party payment gateway. We do not collect or store your full card number; we receive only confirmation of successful payment and the amount/product purchased.</li>
<li><b>Seller (manual) recharge:</b> if you top up through an in-app Seller using a mobile wallet or bank transfer (such as bKash or Nagad), you provide the sending wallet/account number, the transaction ID, optionally the sender's name, and optionally a screenshot of the payment receipt. We use this only to verify your payment and credit your account, and keep it with your recharge history for record-keeping and fraud prevention. We never ask for your wallet PIN or password.</li>
<li><b>Communications with us:</b> messages you send to customer support, including your contact email.</li>
</ul>

<p><b>Information collected automatically</b></p>
<ul>
<li><b>Device information:</b> device model, operating system and version, unique device identifiers, IP address, mobile network information, and language/region settings.</li>
<li><b>Usage data:</b> features used, screens viewed, session length, crash logs, and diagnostic data, used to keep the app stable and to improve it.</li>
<li><b>Camera and microphone:</b> used only when you choose to start or join a live stream, voice room, or video call, or to take/upload a photo or video. We do not access your camera or microphone in the background or without your action.</li>
<li><b>Contacts (optional):</b> if you choose to enable a "find friends" or contact-sync feature, we access your device contacts solely to suggest people you may know. This requires your explicit permission and can be turned off at any time in your device settings.</li>
<li><b>Approximate location (optional):</b> if the Service offers location-based features (such as nearby users or regional live rooms), we may collect approximate location derived from your IP address or, with your permission, device location services.</li>
</ul>

<p><b>Information from third parties</b></p>
<ul>
<li>If you sign in using a third-party account (Google, Facebook, Apple), we receive basic profile information (name, email, profile photo) as authorized by you through that provider.</li>
</ul>

<h3>2. How We Use Information</h3>
<p>We use the information above to:</p>
<ul>
<li>Create and manage your account and authenticate you;</li>
<li>Provide core features: live streaming, chat, voice/video rooms, groups, gifting, and virtual currency;</li>
<li>Process purchases and maintain accurate coin/diamond/VIP balances;</li>
<li>Personalize content and recommendations (e.g., suggested rooms, users, or content);</li>
<li>Detect, investigate, and prevent fraud, abuse, spam, and violations of our Community Guidelines;</li>
<li>Respond to support requests and communicate service-related notices;</li>
<li>Analyze usage to maintain, secure, and improve the Service;</li>
<li>Comply with legal obligations and enforce our Terms of Service.</li>
</ul>
<p>We do not sell your personal information to third parties.</p>

<h3>3. How We Share Information</h3>
<p>We share information only in the following circumstances:</p>
<ul>
<li><b>Service providers:</b> cloud hosting, push-notification providers, analytics providers, and payment processors who help us operate the Service, under contractual obligations to protect your data and use it only for the purposes we specify.</li>
<li><b>Other users:</b> your public profile information, live broadcasts, and content you choose to share are visible to other users of the Service, as intended by the App's social features.</li>
<li><b>Legal reasons:</b> if required by law, legal process, or governmental request, or to protect the rights, property, or safety of iamParty, our users, or the public.</li>
<li><b>Business transfers:</b> if iamParty is involved in a merger, acquisition, or sale of assets, information may be transferred as part of that transaction, subject to this Policy.</li>
<li><b>YouTube:</b> rooms can play YouTube videos using YouTube API Services. When you search for or play a video, your search terms and playback requests are sent to YouTube/Google. By using this feature you agree to the YouTube Terms of Service (https://www.youtube.com/t/terms), and Google's handling of that data is described in the Google Privacy Policy (https://policies.google.com/privacy). We do not store your YouTube viewing history.</li>
</ul>
<p>We do not share your data with third parties for their own advertising purposes.</p>

<h3>4. User-Generated Content and Community Safety</h3>
<p>Live streaming, chat, and social features allow users to create and share content. We:</p>
<ul>
<li>Provide in-app tools to <b>block, mute, and report</b> other users, live streams, and messages;</li>
<li>Review reported content and may remove content or suspend/terminate accounts that violate our Community Guidelines or Terms of Service (including nudity, harassment, hate speech, violence, or content endangering minors);</li>
<li>Reserve the right to proactively moderate public rooms and broadcasts to keep the platform safe.</li>
</ul>
<p><b>iamParty is intended for users aged 18 and older</b> (or the age of majority in your jurisdiction). Live audio/video interaction with strangers is a core feature of the Service, so it is not directed at children.</p>

<h3>5. Virtual Currency and In-App Purchases</h3>
<p>Coins, diamonds, VIP privileges, and similar virtual items purchased in the App:</p>
<ul>
<li>Have no cash value and are not redeemable for real currency, except where required by applicable law or app store policy;</li>
<li>Are billed and refunded according to the policies of the app store (Google Play) through which you purchased them;</li>
<li>May be adjusted, reset, or removed if we detect fraudulent purchases, chargebacks, or violations of our Terms.</li>
</ul>

<h3>6. Children's Privacy</h3>
<p>The Service is not directed at children under 13 (or the minimum age required by your local law), and we do not knowingly collect personal information from children under that age. If we learn that a child has provided us with personal information, we will delete it. If you believe a child has used the Service and provided personal information, please contact us at <b>help24imran@gmail.com</b> so we can investigate and remove it.</p>

<h3>7. Data Retention</h3>
<p>We retain your information for as long as your account is active or as needed to provide the Service, comply with legal obligations, resolve disputes, and enforce our agreements. When no longer needed, we delete or anonymize your information, except where retention is required by law (e.g., financial/transaction records).</p>

<h3>8. Your Rights and Choices</h3>
<p>Depending on your location, you may have the right to:</p>
<ul>
<li>Access, correct, or update your personal information (most of this can be done directly in Settings &gt; Edit Profile);</li>
<li>Request a copy of your data;</li>
<li>Withdraw consent for optional features (e.g., contacts sync, location);</li>
<li>Object to or restrict certain processing;</li>
<li>Lodge a complaint with your local data protection authority.</li>
</ul>

<p><b>8.1 Deleting your account and data</b></p>
<p>You can request deletion of your account and associated personal data at any time by:</p>
<ol>
<li>Going to Settings &gt; Account &gt; Delete Account in the App (if available in your app version), or</li>
<li>Emailing <b>help24imran@gmail.com</b> from your registered email/phone with the subject "Account Deletion Request" and your account ID/username.</li>
</ol>
<p>We will verify your request and delete your account and personal data within a reasonable time, except for information we are legally required to retain (such as transaction records for tax or fraud-prevention purposes).</p>

<h3>9. Data Security</h3>
<p>We use reasonable technical and organizational measures (encryption in transit, access controls, and secure hosting) to protect your information. However, no method of transmission or storage is 100% secure, and we cannot guarantee absolute security.</p>

<h3>10. International Data Transfers</h3>
<p>Your information may be processed and stored on servers located outside your country of residence. Where required, we take steps to ensure such transfers comply with applicable data protection laws.</p>

<h3>11. Changes to This Policy</h3>
<p>We may update this Privacy Policy from time to time. If we make material changes, we will notify you in the App or by other reasonable means before the changes take effect. The "Effective date" above reflects the latest revision.</p>

<h3>12. Contact Us</h3>
<p>If you have questions, concerns, or requests regarding this Privacy Policy or your personal data, please contact us:</p>
<ul>
<li><b>Email:</b> help24imran@gmail.com</li>
<li><b>Website:</b> https://iamparty.linlive.fr</li>
</ul>

''';