# AviUtl_Alias_Reader
AviUtlのEXO読み込みをちょっと便利にする、ごちゃまぜドロップス用スクリプトです。

## インストール方法
[ごちゃまぜドロップス](https://github.com/oov/aviutl_gcmzdrops/releases/latest) の最新版をインストールしてください。

その後、https://github.com/Garech-mas/Aviutl_Alias_Reader/releases/latest から`aviutl_alias_reader.lua`をダウンロード、

以下の階層に配置してください。
> AviUtlのインストールフォルダ / GCMZDrops / aviutl_alias_reader.lua


## 仕様
- FPS値が異なるEXOを読み込んだとき、各オブジェクトの長さを調整して読み込めるようになります。
- [exedit] で始まるテキストはオブジェクトファイル(.exo)として追加します。
- [v][vo][a][ao] などで始まるテキストはエイリアス(.exa)として追加します。

## 参考
- [字幕アシストプラグイン](https://aoytsk.blog.jp/aviutl/1412254.html)
- [EXOファイルFPS変換機](https://yachiovithe.wixsite.com/creation-cms/post/exofile_fps_converter)
