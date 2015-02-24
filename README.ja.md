# Salesforce ReactJS SPA Starter

Salesforce上でReactJSベースのSPA(Single Paged Appp)を作成するためのテンプレートです。
Gulp.jsを利用して自動ビルド・デプロイが可能です。

## セットアップ

Node.jsの0.10かそれ以上がインストールされていることを確認して下さい。

```
$ node --version
```

確認したら、以下のコマンドをプロジェクトディレクトリのルートで実行します。

```
$ npm install
$ bower install
```

`gulp` コマンドがインストールされていない場合は、以下のコマンドを実行します

```
$ npm install -g gulp
```

## ファイルのビルド

`gulp` コマンドを実行してソースコードから実行用のコードを生成します。

```
$ gulp
```

`watch` タスクオプションを指定してgulpを実行すると、ソースコードファイルの変更を監視して自動的にビルドを実行します。

```
$ gulp watch
```

## プレビュー

以下のコマンドでWebアプリケーションサーバを起動できます。

```
$ gulp dev
```

`http://localhost:8000` にアクセスしてアプリのプレビューを表示します。
このコマンドでソースコードの変更の監視も同時におこないます。


## テスト

単体テストを実行汁には以下のコマンドを実行します。

```
$ gulp test
```

ソースコードファイル変更時に自動的にテストを実行するには以下のコマンドを実行します。

```
$ gulp test:watch
```


## デプロイ (Salesforce)

Salesforceに接続するユーザ名・パスワード（セキュリティトークンを含む）を環境変数に指定して、`gulp deploy` コマンドを実行します。

```
$ SF_USERNAME=yourname@example.org SF_PASSWORD=password gulp deploy
```

あるいは、プロジェクト内に `.env` というファイルを用意し、中身に環境変数を `KEY=VALUE` の形式で記述しておき、

```
SF_USERNAME=yourname@example.org
SF_PASSWORD=password
```

その後 `foreman` を経由して `gulp deploy`　を実行します。

```
$ nf run gulp deploy
```

この`nf`コマンドは `npm install -g foreman` でインストール可能です。


## プロジェクト・ディレクトリ構成

```
├── app                    # ソースコードディレクトリ
│   ├── assets               # HTML、画像、フォントなどの静的ファイル
│   │   ├── index.html         # エントリポイントとなるHTMLファイル
│   │   ├── ...
│   │
│   ├── scripts              # スクリプトファイル(JSへコンパイル)
│   │   ├── components         # ReactJS コンポーネントのスクリプトコード
│   │   │   ├── bar.jsx          # .js および .jsx ファイル（JSX記述可能）
│   │   │   ├── baz.cjsx         # .coffee および .cjsx ファイル(JSX記述可能)
│   │   │   ├── foo.coffee
│   │   │   ├── root.js
│   │   │   ├── ...
│   │   │ 
│   │   ├── main.js            # エントリポイントとなるスクリプト
│   │   ├── ...
│   │
│   ├── styles               # LESSスタイルシートファイル（CSSへコンパイル）
│   │   ├── components         # ReactJS コンポーネントのスタイルシート
│   │   ├── main.less          # エントリポイントとなるスタイルシート
│   │   ├── ...
│   │
│   └── templates            # React-templates (http://wix.github.io/react-templates/) 形式のファイルを格納
│       └── components         
│           ├── foo.rt           # app/scripts/components/foo.coffee に対応
│           ├── root.rt          # app/scripts/components/root.js に対応
│           ├── ...
│
├── bower.json             # 依存ライブラリの設定
├── gulpfile.coffee        # Gulp ビルドスクリプト
├── package.json           # プロジェクトの各種設定
│
├── src                    # Force.com プロジェクトのソースコード
│   ├── package.xml
│   ├── pages
│   │   ├── MyAppPage.page
│   │   └── MyAppPage.page-meta.xml
│   └── staticresources
│       ├── MyApp.resource     # ビルドされたファイルを含むZIPファイル (gulpによって生成)
│       ├── MyApp.resource-meta.xml
│       ├── MyAppLib.resource  # Bowerのライブラリを含むZIPファイル (gulpによって生成)
│       └── MyAppLib.resource-meta.xml
│
└── test                   # テストコードディレクトリ
    ├── e2e                  # End-to-End テストのためのコード（protractorを想定）
    │   ├── app001.test.js
    │   ├── ...
    │
    └── unit                 # 単体テスト
        ├── components          # ReactJS コンポーネントの単体テスト
        ├── ...
```

