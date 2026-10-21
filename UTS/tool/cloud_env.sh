#!/usr/bin/env bash
# Khusus cloud workspace; pengguna lokal cukup menggunakan Flutter di PATH.
export FLUTTER_ROOT=/workspace/toolchains/flutter
export JAVA_HOME=/workspace/toolchains/jdk21
export ANDROID_HOME=/workspace/toolchains/android-sdk
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export ANDROID_USER_HOME=/workspace/toolchains/android-user
export GRADLE_USER_HOME=/workspace/toolchains/gradle-home
export PUB_CACHE=/workspace/toolchains/pub-cache
export XDG_CONFIG_HOME=/workspace/toolchains/config
export ANALYZER_STATE_LOCATION_OVERRIDE=/workspace/toolchains/dart-server-cache
export FLUTTER_SUPPRESS_ANALYTICS=true
export DART_SUPPRESS_ANALYTICS=true
export CI=true
export PATH="$JAVA_HOME/bin:$FLUTTER_ROOT/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
if [[ -f /etc/ssl/certs/java/cacerts ]]; then
  export JAVA_TOOL_OPTIONS="${JAVA_TOOL_OPTIONS:-} -Djavax.net.ssl.trustStore=/etc/ssl/certs/java/cacerts"
fi
# Java/Gradle tidak otomatis membaca HTTPS_PROXY seperti curl dan pub.
# Hanya host/port proxy yang diteruskan; kredensial tidak disalin.
_mono_proxy_options=$(python3 - <<'PY'
import os
from urllib.parse import urlsplit
url = os.environ.get('HTTPS_PROXY') or os.environ.get('https_proxy')
if url:
    proxy = urlsplit(url)
    if proxy.username or proxy.password:
        raise SystemExit('Proxy dengan autentikasi memerlukan konfigurasi Java dari platform.')
    if proxy.hostname:
        port = proxy.port or (443 if proxy.scheme == 'https' else 80)
        print(f'-Dhttps.proxyHost={proxy.hostname} -Dhttps.proxyPort={port} '
              f'-Dhttp.proxyHost={proxy.hostname} -Dhttp.proxyPort={port} '
              '-Dhttp.nonProxyHosts=localhost|127.*')
PY
) || return 1
export GRADLE_OPTS="${GRADLE_OPTS:-} $_mono_proxy_options"
unset _mono_proxy_options
