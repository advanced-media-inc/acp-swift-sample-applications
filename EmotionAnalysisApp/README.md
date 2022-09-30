# EmotionAnalysisApp
AmiVoice APIの非同期HTTP音声認識APIを利用した感情解析iOSのサンプルアプリケーション

## About
録音した音声データを解析し、感情解析と音声認識できるiOSアプリです。

<div align="center" position="relative">
  <a href="#">
      <img src="https://user-images.githubusercontent.com/93509335/191208765-bbc71942-b002-47db-81a1-92aa43ee9e87.gif"
     width="600px">
  </a>
  <p>図1 感情解析アプリのイメージ図</p>
</div>

## Article
以下のAmiVoice Tech Blogで詳しく紹介しています。

[【Swift】AmiVoice APIとAlamofireでつくる感情解析アプリ](https://amivoice-tech.hatenablog.com/draft/entry/dWe8qOmTm2drqTVdzW6mGyz5djY)

## Requirements
### 動作環境
- iOS 14.0 and later
### 開発者の環境
下記の環境で開発、テストを行っています。
- macOS Monterey 12.5.1
- Xcode 13.4.1
- Swift 5.0

## How to use
1. AmiVoice APIのAPPKEYの設定
2. 音声の録音
3. 音声認識結果・感情解析結果の表示
<div align="center" position="relative">
  <a href="#">
      <img src="https://user-images.githubusercontent.com/93509335/191213941-5c5df379-23bd-4a32-b2e1-4df4f4ddb1d4.png"
     width="600px">
  </a>
  <p>図2 操作の流れ</p>
</div>

## Reference
- [非同期 HTTP インタフェース | AmiVoice Cloud Platform](https://docs.amivoice.com/amivoice-api/manual/user-guide/request/async-http-interface/)
- [感情解析 | AmiVoice Cloud Platform](https://docs.amivoice.com/amivoice-api/manual/user-guide/function/sentiment-analysis/)
- [GitHub - Alamofire/Alamofire: Elegant HTTP Networking in Swift](https://github.com/Alamofire/Alamofire)
- [Alamofireでmultipart/form-dataリクエスト - Qiita](https://qiita.com/gologo13/items/e7b1ed56b6692e388d4d)
- [Alamofire vs URLSession: a comparison for networking in Swift - SwiftLee](https://www.avanderlee.com/swift/alamofire-vs-urlsession/)
- [GitHub - nubank/ios-charts: Beautiful charts for iOS/tvOS/OSX! The Apple side of the crossplatform MPAndroidChart.](https://github.com/nubank/ios-charts)
- [[Swift]グラフを作成するライブラリChartsを使って折れ線グラフを描画してみた | DevelopersIO](https://dev.classmethod.jp/articles/charts-line-graph-sample/)
