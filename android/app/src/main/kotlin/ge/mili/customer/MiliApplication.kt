package ge.mili.customer

import android.app.Application
import android.content.Context
import com.facebook.FacebookSdk

class MiliApplication : Application() {
    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)

        // ContentProviders run before Application.onCreate. Set the public SDK
        // overrides here, before FacebookInitProvider, so previously cached true
        // preferences cannot re-enable automatic collection after an upgrade.
        // Basic SDK initialization is retained for the auth plugin's construction;
        // this is not a claim that the SDK performs no network requests at all.
        FacebookSdk.setAutoInitEnabled(false)
        FacebookSdk.setAutoLogAppEventsEnabled(false)
        FacebookSdk.setAdvertiserIDCollectionEnabled(false)
        FacebookSdk.setAutoLogMetaDataEnabled(false)
        FacebookSdk.setAutoLogProductImprovementEnabled(false)
    }
}
