package com.syake.video
{
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;

	/**
	 * NetStreamController クラスは、NetConnection 経由で単方向ストリーミングチャンネルを開きます。
	 * @version Flash Player 9
	 * @ActionScriptversion ActionScript 3.0
	 * @author Hiroaki Komatsu
	 */
	public class NetStreamController extends NetStream
	{
		/**
		 * 自動再生をするかどうかを示します。
		 * @default true
		 */
		public var autoStart:Boolean = true;
		
		/**
		 * 再生の準備が完了したかどうかを示します。
		 * @default false
		 */
		public function get success():Boolean
		{
			return _success;
		}
		private var _success:Boolean = false;
		
		/**
		 * 総再生時間（秒単位）を示します。
		 * @default 0
		 */
		public function get duration():Number
		{
			return _duration;
		}
		private var _duration:Number;
		
		/**
		 * メディアの幅を示します。
		 * @default 0
		 */
		public function get width():uint
		{
			return _width;
		}
		private var _width:uint;
		
		/**
		 * メディアの高さを示します。
		 * @default 0
		 */
		public function get height():uint
		{
			return _height;
		}
		private var _height:uint;
		
		/**
		 * 再生状況を示します。
		 * @default false
		 */
		public function get playing():Boolean
		{
			return _playing;
		}
		private var _playing:Boolean;
		
		/**
		 * 指定された NetConnection オブジェクトを使用して、ビデオファイルを再生するためのストリームを生成します。
		 * @param connection NetConnection オブジェクトです。
		 * @param peerID このオプションのパラメーターは Flash Player 10 以降で、RTMFP 接続して使用する場合に利用可能です。（NetConnection.protocol プロパティの値が "rtmfp" でない場合、このパラメーターは無視されます。）次の値のいずれかを使用します。
		 */
		public function NetStreamController(connection:NetConnection, peerID:String="connectToFMS")
		{
			super(connection, peerID);
			super.client = {
				onMetaData:function(info:Object):void{
					_duration = info.duration;
					_width = info.width;
					_height = info.height;
				}
			};
		}
		
		/**
		 * ローカルディレクトリまたは Web サーバーからメディアファイルを再生します。Flash Media Server からメディアファイルまたはライブストリームを再生します。NetStatusEvent オブジェクトを送出して、ステータスおよびエラーメッセージをレポートします。
		 */
		override public function play(...arguments):void
		{
			_success = false;
			addEventListener(NetStatusEvent.NET_STATUS, handleNetStatus1);
			super.play.apply(this, arguments);
		}
		
		/**
		 * NetStream による接続状況を監視します。
		 * @param	event
		 */
		private function handleNetStatus1(event:NetStatusEvent):void
		{
			//trace("[NetStreamController]", "handleNetStatus1:", event.info.code);
			removeEventListener(NetStatusEvent.NET_STATUS , handleNetStatus1);
			switch (event.info.code) {
				case "NetStream.Play.StreamNotFound":
					//ストリームロードエラー
					dispatchEvent(new NetStreamEvent(NetStreamEvent.FAILED, false, false, event.info));
					break;
				case "NetStream.Play.Failed":
					//再生中にエラーが発生したとき
					break;
				case "NetStream.Play.Start":
					//配信開始
					_success = true;
					_playing = true;
					dispatchEvent(new NetStreamEvent(NetStreamEvent.SUCCESS, false, false, event.info));
					if (autoStart) {
						dispatchEvent(new NetStreamEvent(event.info.code, false, false, event.info));
					} else {
						this.pause();
					}
					addEventListener(NetStatusEvent.NET_STATUS , handleNetStatus2);
					break;
				case "NetStream.Play.Stop":
					//配信停止
					break;
				case "NetStream.Buffer.Empty":
					//バッファが空になったとき
					break;
				case "NetStream.Buffer.Full":
					//バッファを満たしたとき
					break;
				case "NetStream.Buffer.Flush":
					//ストリーム読み込みが終了
					break;
				case "NetStream.Seek.Failed":
					//シークが失敗したとき
					break;
				case "NetStream.Seek.InvalidTime":
					//有効ではないシーク時間を指定したとき
					break;
				case "NetStream.Seek.Notify":
					//シーク操作を完了できたとき
					break;
			}
		}
		
		/**
		 * NetStream による接続状況を監視します。
		 * @param	event
		 */
		private function handleNetStatus2(event:NetStatusEvent):void
		{
			//trace("[NetStreamController]", "handleNetStatus2:", event.info.code);
			switch (event.info.code) {
				case "NetStream.Play.Start":
					//配信開始
					_playing = true;
					break;
				case "NetStream.Play.Stop":
					//配信停止
					_playing = false;
					break;
			}
			if (willTrigger(event.info.code)) dispatchEvent(new NetStreamEvent(event.info.code, false, false, event.info));
		}
		
		/**
		 * ビデオストリームの再生を開始します。
		 */
		public function start():void
		{
			if (_success) {
				this.seek(0);
				this.resume();
			}
		}
		
		/**
		 * ストリーム上のすべてのデータの再生を停止し、time プロパティを 0 に設定して、他のユーザーがストリームにアクセスできるようにします。また、このメソッドは、HTTP を使用してダウンロードされたビデオファイルのローカルコピーを削除します。アプリケーションでは、アプリケーションで作成したファイルのローカルコピーは削除されますが、コピーがキャッシュディレクトリに残る場合があります。ビデオファイルをキャッシュやローカル記憶域に一切残さないようにする必要がある場合には、Flash Media Server を使用してください。
		 */
		override public function close():void
		{
			removeEventListener(NetStatusEvent.NET_STATUS , handleNetStatus1);
			removeEventListener(NetStatusEvent.NET_STATUS , handleNetStatus2);
			super.close();
		}
		
		/**
		 * NetStream.close() と似ていますが、ビデオオブジェクトに表示される予定の NetStream によって保留にされている最後のフレームもクリアされる点が異なります。NetStream を後から他のストリームで再利用する場合は、NetStream.close() ではなく、これを使用します。ビデオフレームおよび関連するデコンプレッサーオブジェクトのガベージコレクションが強制的に行われます。このメソッドを使用後は、ビデオオブジェクトには空のフレームが表示されます。
		 */
		override public function dispose():void
		{
			removeEventListener(NetStatusEvent.NET_STATUS , handleNetStatus1);
			removeEventListener(NetStatusEvent.NET_STATUS , handleNetStatus2);
			super.dispose();
		}
		
		/**
		 * ビデオストリームの再生を一時停止します。ビデオが既に一時停止している場合は、このメソッドを呼び出しても何も実行されません。ビデオを一時停止した後で再生を再開するには、resume() を呼び出します。一時停止と再生を切り替える（最初にビデオを一時停止し、次に再開する）には、togglePause() を呼び出します。
		 */
		override public function pause():void
		{
			_playing = false;
			super.pause();
		}
		
		/**
		 * 再生を一時停止していたビデオストリームを再開します。ビデオが既に再生中である場合は、このメソッドを呼び出しても何も実行されません。
		 */
		override public function resume():void
		{
			_playing = true;
			super.resume();
		}
		
		/**
		 * ストリームの再生を一時停止または再開します。このメソッドを呼び出すと最初は再生を一時停止し、次に呼び出したときには再生を再開します。このメソッドを使用して、ユーザーが 1 つのボタンを押すだけで再生を一時停止または再生できるようにすることができます。
		 */
		override public function togglePause():void
		{
			_playing = !_playing;
			super.togglePause();
		}
	}
}
