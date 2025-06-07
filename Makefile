SHELL=/bin/zsh

bootstrap:
	cd . # use chxcode auto
	rbenv install -s
	# bundlerでcocoapodsとfastlaneをインストール
	bundle config set --local path vendor/bundle
	bundle install
	# cocoapodsのライブラリをインストール
	bundle exec pod install
	open ios-archi.xcworkspace

