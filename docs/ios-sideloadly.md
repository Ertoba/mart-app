# Unsigned iOS device builds for Sideloadly

The root [Codemagic workflow](../codemagic.yaml) creates an unsigned arm64
release IPA from the main branch. Start the ios-sideloadly workflow manually
in Codemagic. Automatic triggers, Apple signing credentials, store uploads,
and publishing are intentionally absent.

The workflow uses Flutter 3.47.5, CocoaPods 1.16.2, and the latest Codemagic
Xcode image on mac_mini_m2. Xcode is intentionally a moving image; its actual
version and the exact source commit are recorded in the artifact provenance.

Expected application identity: ge.mili.customer. Neither the bundle identifier nor
the existing entitlements are rewritten for this workflow.

## Required configuration gate

The existing [Firebase release preflight](../scripts/check-ios-firebase-release.py)
must pass before dependency installation or compilation. This is a fail-closed
check of the real app registration, not a request to rename plist fields.

On 2026-11-11, a genuine Apple application registration was created in the
existing MILI Firebase project (mili-a2a33). The complete official downloaded
configuration is installed without invented app IDs or OAuth identifiers.
The Firebase identity/project and URL-structure preflights pass.

The referenced root Firebase plist and the additional Runner-directory copy
are byte-identical. Customer URL types now keep the existing Facebook callback,
lift the existing mili-customer Keepz callback into its own top-level URL type,
and derive the Firebase phone-auth callback from the official GOOGLE_APP_ID.
Stale upstream Google OAuth and Firebase callbacks were removed.

Live backend configuration reviewed on this date has Google/Facebook/Apple
social login disabled, Firebase OTP disabled, and SMS OTP enabled. The official
Apple registration has no CLIENT_ID or REVERSED_CLIENT_ID; those OAuth fields
are not required for the active phone/SMS login. Google OAuth is deliberately
deferred, not declared ready. Before enabling Google login, configure a genuine
iOS OAuth client, its registered callback, and the backend client validation.
Existing Dart OAuth client configuration and native Meta SDK behavior are
not changed by this iOS Firebase registration fix.

These are static configuration checks only. macOS compilation, Apple signing,
physical-device behavior, APNs delivery, and financial flows remain separate
verification steps; correct Firebase identifiers do not establish those results.

## Native dependency locks

Flutter dependencies are installed with the committed lock enforced.
CocoaPods first attempts installation using the existing native lock.

The Customer Firebase snapshot already matches the locked Flutter packages;
there is no automatic Customer Firebase update case. Normal pod installation
may add the locally tracked Flitt plugin absent from the old native lock.
There is no blanket pod update and no deletion of Podfile.lock. Resolution
failures stop the build; the common helper's targeted repair cases are limited
to the separately audited Vendor/Courier snapshots.

Artifacts retain the prior and resolved native locks. If provenance reports
a changed lock, review the downloaded Podfile.lock and commit it to main
before subsequent builds. The repaired lock is never pushed automatically.

## Download and installation

Download the IPA and provenance from the completed Codemagic build artifacts.
The generated archive has Payload/Runner.app layout and preserves native
bundle symlinks. Sideloadly must sign the IPA locally with the user's Apple
account before installation; this workflow does not access that account.

This is not an App Store/TestFlight distribution build and is not installable
directly as an unsigned IPA. Physical-device installation, re-signing,
push notifications, authentication, maps, and payments require separate
verification. Personal-account signing may restrict capabilities and validity.

Official references:

- [Codemagic Flutter configuration](https://docs.codemagic.io/yaml-quick-start/building-a-flutter-app/)
- [Manual and automatic build triggers](https://docs.codemagic.io/yaml-running-builds/starting-builds-automatically/)
