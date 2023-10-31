# Xcode Preview のビルド時はスクリプトを実行しない
if [ "$ENABLE_PREVIEWS" = "YES" ]; then
  exit 0
fi

"Pods/Sourcery/bin/sourcery"
