bootstrap:
	# bundlerでcocoapodsとfastlaneをインストール
	bundle install
	# cocoapodsのライブラリをインストール
	bundle exec pod install
	open ios-archi.xcworkspace
