[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$WorkspaceRoot,
    [switch]$Resume
)

$ErrorActionPreference = 'Stop'
$physicalWorkspace = (Resolve-Path -LiteralPath $WorkspaceRoot).Path
. (Join-Path $physicalWorkspace 'ops/Enter-MiliEnvironment.ps1')

# Dated Customer-only plan. Console maximum 56 was checked on 2026-11-11.
# Use the existing active Nov 7 upload key; never regenerate it for a rebuild.
# The production runner exports only clean, pushed main and refuses overwrites.
$uploadRecordPath = Join-Path $env:MILI_WORKSPACE 'repos/react-web/Documentation/operations/play-upload-20261111.json'
$uploadRecord = Get-Content -LiteralPath $uploadRecordPath -Encoding UTF8 -Raw | ConvertFrom-Json
$customerEvidence = @($uploadRecord.apps | Where-Object component -eq 'customer')[0].registrationEvidence
if (-not $customerEvidence) { throw 'Verified Customer Play registration evidence is missing.' }

& (Join-Path $physicalWorkspace 'ops/scripts/Build-MiliProductionAabs.ps1') `
    -SigningRunId '20261107-upload-reset' `
    -RunId '20261111-customer-no-ad-id' `
    -Components @('customer') `
    -VersionCodes @{ customer = 57 } `
    -PlayMaxVersionCodes @{ customer = 56 } `
    -BundletoolJar 'M:/tools/bundletool/bundletool-all-1.18.3.jar' `
    -BundletoolSha256 'A099CFA1543F55593BC2ED16A70A7C67FE54B1747BB7301F37FDFD6D91028E29' `
    -PlayRegistrationEvidence @{ customer = $customerEvidence } `
    -Resume:$Resume

# Standard signature/bundle checks above are necessary but do not prove privacy
# policy. Inspect the exact compiled AAB separately; never trust source XML alone.
$artifactRoot = Join-Path $env:MILI_WORKSPACE 'artifacts/production/android/20261111-customer-no-ad-id'
$manifestPath = Join-Path $artifactRoot 'production-build-manifest.json'
$buildManifest = Get-Content -LiteralPath $manifestPath -Encoding UTF8 -Raw | ConvertFrom-Json
$customerBuilds = @($buildManifest.components | Where-Object component -eq 'customer')
if ($customerBuilds.Count -ne 1) { throw 'Expected exactly one Customer production bundle.' }
$customerBuild = $customerBuilds[0]
if ($buildManifest.status -ne 'verified-builds-complete' -or -not $customerBuild.verified -or
    -not $customerBuild.safeToUploadToExistingPlayApp) {
    throw 'Customer production bundle did not pass the standard verification gates.'
}
$java = Join-Path $env:ProgramFiles 'Android/Android Studio/jbr/bin/java.exe'
$bundletool = Join-Path $env:MILI_WORKSPACE 'tools/bundletool/bundletool-all-1.18.3.jar'
$manifestXml = & $java "-Djava.io.tmpdir=$env:TEMP" -jar $bundletool dump manifest `
    "--bundle=$($customerBuild.artifact)" --module=base
if ($LASTEXITCODE -ne 0) { throw 'Could not inspect the exact production AAB manifest.' }
[xml]$compiledManifest = $manifestXml -join "`n"
$androidNamespace = 'http://schemas.android.com/apk/res/android'
$forbiddenPermissions = @(
    'com.google.android.gms.permission.AD_ID',
    'android.permission.ACCESS_ADSERVICES_AD_ID',
    'android.permission.ACCESS_ADSERVICES_ATTRIBUTION',
    'android.permission.ACCESS_ADSERVICES_CUSTOM_AUDIENCE',
    'android.permission.ACCESS_ADSERVICES_TOPICS'
)
foreach ($permission in $compiledManifest.manifest.'uses-permission') {
    if ($permission.GetAttribute('name', $androidNamespace) -in $forbiddenPermissions) {
        throw 'Advertising permission survived into the compiled AAB.'
    }
}
$application = $compiledManifest.manifest.application
if ($application.GetAttribute('name', $androidNamespace) -ne 'ge.mili.customer.MiliApplication') {
    throw 'Compiled AAB does not use the pre-provider privacy Application.'
}
foreach ($setting in @('AutoInitEnabled', 'AutoLogAppEventsEnabled', 'AdvertiserIDCollectionEnabled', 'AutoLogMetaDataEnabled', 'AutoLogProductImprovementEnabled')) {
    $matchingMetadata = @($application.'meta-data' | Where-Object { $_.GetAttribute('name', $androidNamespace) -eq "com.facebook.sdk.$setting" })
    if ($matchingMetadata.Count -ne 1 -or $matchingMetadata[0].GetAttribute('value', $androidNamespace) -ne 'false') {
        throw "Compiled AAB privacy setting is not disabled: $setting"
    }
}
$facebookProviders = @($application.provider | Where-Object { $_.GetAttribute('name', $androidNamespace) -eq 'com.facebook.internal.FacebookInitProvider' })
if ($facebookProviders.Count -ne 1) {
    throw 'Compiled AAB is missing the initialization provider required by the auth plugin.'
}
Write-Host 'CUSTOMER_ADVERTISING_PRIVACY_VERIFIED forbiddenPermissions=0 disabledSettings=5 preProviderApplication=true'
