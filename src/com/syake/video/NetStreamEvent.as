package com.syake.video
{
	import flash.events.Event;

	/**
	 * NetStreamEvent クラスは、NetStreamEvent オブジェクトを作成するための基本クラスとして使用されます。これらの NetStreamEvent オブジェクトは、イベントの発生時にイベントリスナーにパラメータとして渡されます。
	 */
	public class NetStreamEvent extends Event
	{
		/**
		 * メディアの接続または読み込みに失敗したときの type プロパティ値を定義します。
		 */
		public static const FAILED:String = "NetStream.FAILED";
		
		/**
		 * メディアの読み込みに成功したときの type プロパティ値を定義します。
		 */
		public static const SUCCESS:String = "NetStream.SUCCESS";
		
		/**
		 * メディアファイルの値が設定されていなかったときの type プロパティ値を定義します。
		 */
		public static const PLAY_STREAM_NULL:String = "NetStream.Play.StreamNull";
		
		/**
		 * ストリームロードエラーが発生したときの type プロパティ値を定義します。
		 */
		public static const PLAY_STREAM_NOT_FOUND:String = "NetStream.Play.StreamNotFound";
		
		/**
		 * 配信成功時の type プロパティ値を定義します。
		 */
		public static const PLAY_STREAM_SUCCESS:String = "NetStream.Play.StreamSuccess";
		
		/**
		 * 再生中にエラーが発生したときの type プロパティ値を定義します。
		 */
		public static const PLAY_FAILED:String = "NetStream.Play.Failed";
		
		/**
		 * 配信開始時の type プロパティ値を定義します。
		 */
		public static const PLAY_START:String = "NetStream.Play.Start";
		
		/**
		 * 配信停止時の type プロパティ値を定義します。
		 */
		public static const PLAY_STOP:String = "NetStream.Play.Stop";
		
		/**
		 * バッファが空になったときの type プロパティ値を定義します。
		 */
		public static const BUFFER_EMPTY:String = "NetStream.Buffer.Empty";
		
		/**
		 * バッファを満たしたときの type プロパティ値を定義します。
		 */
		public static const BUFFER_FULL:String = "NetStream.Buffer.Full";
		
		/**
		 * ストリーム読み込みが終了したときの type プロパティ値を定義します。
		 */
		public static const BUFFER_FLUSH:String = "NetStream.Buffer.Flush";
		
		/**
		 * シークが失敗したときの type プロパティ値を定義します。
		 */
		public static const SEEK_FAILED:String = "NetStream.Seek.Failed";
		
		/**
		 * 有効ではないシーク時間を指定したとき type プロパティ値を定義します。
		 */
		public static const SEEK_INVALIDTIME:String = "NetStream.Seek.InvalidTime";
		
		/**
		 * シーク操作を完了できたときのイベント
		 */
		public static const SEEK_NOTIFY:String = "NetStream.Seek.Notify";
		
		/**
		 * オブジェクトのステータスまたはエラー状態を記述するプロパティを持つオブジェクトです。
		 */
		public function get info():Object
		{
			return _info;
		}
		
		/**
		 * @private
		 */
		protected var _info:Object;
		
		/**
		 * イベントリスナーにパラメータとして渡す NetStreamEvent オブジェクトを作成します。
		 * @param type Event.type としてアクセス可能なイベントタイプです。
		 * @param bubbles NetStreamEvent オブジェクトがイベントフローのバブリング段階で処理されるかどうかを判断します。デフォルト値は false です。
		 * @param cancelable NetStreamEvent オブジェクトがキャンセル可能かどうかを判断します。デフォルト値は false です。
		 * @param info NetStreamEvent オブジェクトから渡されるオブジェクトのステータスまたはエラー状態を記述するプロパティを持つオブジェクトです。デフォルト値は null です。
		 */
		public function NetStreamEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, info:Object=null)
		{
			super(type, bubbles, cancelable);
			_info = info;
		}

		/**
		 * NetStreamEvent サブクラスのインスタンスを複製します。
		 */
		public override function clone():Event
		{
			return new NetStreamEvent(type, bubbles, cancelable, _info);
		} 
		
		/**
		 * NetStreamEvent オブジェクトのすべてのプロパティを含むストリングを返します。
		 */
		public override function toString():String
		{ 
			return formatToString("NetStreamEvent", "type", "bubbles", "cancelable", "info"); 
		}
	}
}
