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

build-errors:
	./scripts/bash/extract-build-errors.sh

build-errors-clean:
	./scripts/bash/extract-build-errors.sh -c

build-errors-json:
	./scripts/bash/extract-build-errors.sh -o json

check-layers:
	./scripts/bash/check-layer-violations.sh

# 自律開発サイクル（全AIエージェント共通）
cycle:
	./scripts/bash/dev-cycle.sh all

cycle-build:
	./scripts/bash/dev-cycle.sh build

cycle-test:
	./scripts/bash/dev-cycle.sh test

cycle-lint:
	./scripts/bash/dev-cycle.sh lint

cycle-ci:
	./scripts/bash/dev-cycle.sh all --fix
