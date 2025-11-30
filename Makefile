SHELL=/bin/zsh

bootstrap:
	cd . # use chxcode auto
	# ツールの依存関係を解決
	swift package --package-path Tools resolve
	open ios-archi.xcworkspace

lint:
	swift run --package-path Tools swiftlint

lint-fix:
	swift run --package-path Tools swiftlint --fix

format:
	swift run --package-path Tools swiftformat .

sourcery:
	swift run --package-path Tools sourcery --config .sourcery.yml
