#!/usr/bin/env bash
set -euo pipefail

# Gunakan checkout yang sudah ada. Tidak membuat Git worktree.
project=/workspace/MobilePrak/UTS
tools_dir=/workspace/toolchains
mkdir -p "$tools_dir/downloads" "$tools_dir/config" "$tools_dir/gradle-home"
if [[ ! -d "$tools_dir/flutter" ]]; then
  git clone --depth 1 --branch 3.47.7 https://github.com/flutter/flutter.git "$tools_dir/flutter"
fi
expected_flutter=abaf9c523780a608bd46686fd5e53740a07077f8
if [[ "$(git -C "$tools_dir/flutter" rev-parse HEAD)" != "$expected_flutter" ]]; then
  echo 'Versi Flutter berbeda dari versi cloud yang diuji. Jangan reset checkout secara otomatis.' >&2
  exit 1
fi
if [[ ! -x "$tools_dir/jdk21/bin/javac" ]]; then
  archive="$tools_dir/downloads/jdk21.tar.gz"
  if [[ ! -f "$archive" ]]; then
    curl --fail --location --retry 2 \
      'https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.12.1%2B1/OpenJDK21U-jdk_x64_linux_hotspot_21.0.12.1_1.tar.gz' \
      --output "$archive"
  fi
  python3 - "$archive" "$tools_dir/jdk21" <<'PY'
import hashlib, pathlib, sys, tarfile
archive, root = map(pathlib.Path, sys.argv[1:])
expected = 'ce79869e1307ed8ee1e2baa86a412b1eb5b75d10a01006d788a6f968bcfaee94'
if hashlib.sha256(archive.read_bytes()).hexdigest() != expected:
    raise SystemExit('Checksum JDK tidak cocok.')
root.mkdir(parents=True, exist_ok=True)
with tarfile.open(archive) as bundle:
    prefix = bundle.getmembers()[0].name.split('/')[0] + '/'
    for item in bundle.getmembers():
        if item.name.startswith(prefix):
            item.name = item.name[len(prefix):]
            if item.name:
                bundle.extract(item, root, filter='data')
PY
fi
source "$project/tool/cloud_env.sh"

if [[ ! -x "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]]; then
  archive="$tools_dir/downloads/android-commandline.zip"
  if [[ ! -f "$archive" ]]; then
    curl --fail --location --retry 2 \
      https://dl.google.com/android/repository/commandlinetools-linux-16111833_latest.zip \
      --output "$archive"
  fi
  python3 - "$archive" "$ANDROID_HOME" <<'PY'
import hashlib, pathlib, sys, zipfile
archive, sdk_root = map(pathlib.Path, sys.argv[1:])
expected = '0877a1d048fe4a24efe2eff536ca4223f7adeb58648bb81909d33c446918cfa8'
if hashlib.sha256(archive.read_bytes()).hexdigest() != expected:
    raise SystemExit('Checksum Android command-line tools tidak cocok.')
root = sdk_root / 'cmdline-tools'
root.mkdir(parents=True, exist_ok=True)
with zipfile.ZipFile(archive) as bundle:
    bundle.extractall(root)
(root / 'cmdline-tools').rename(root / 'latest')
for path in (root / 'latest/bin').iterdir():
    path.chmod(0o755)
PY
fi

# adb memerlukan direktori preferensi Android standar.
mkdir -p "$HOME/.android"
python3 - <<'PY'
import os, subprocess
sdk = os.environ['ANDROID_HOME']
command = [sdk + '/cmdline-tools/latest/bin/sdkmanager', '--sdk_root=' + sdk]
for arguments in [
    ['--licenses'],
    ['platform-tools', 'platforms;android-36', 'build-tools;36.0.0', 'ndk;28.2.13676358'],
]:
    subprocess.run(command + arguments, input='y\n' * 200, text=True, check=True)
PY

flutter precache --android --web
cd "$project"
flutter pub get --enforce-lockfile
flutter --version
adb version
javac -version
flutter analyze --no-pub
flutter test --no-pub
dart --suppress-analytics run tool/api_smoke.dart
