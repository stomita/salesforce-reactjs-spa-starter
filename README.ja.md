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

