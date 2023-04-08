bootstrap:
	rbenv install -s
	# bundlerでcocoapodsとfastlaneをインストール
	bundle install
	# cocoapodsのライブラリをインストール
	bundle exec pod install
	open ios-archi.xcworkspace
