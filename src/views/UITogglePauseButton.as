package views
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * TogglePauseボタン
	 * @version Flash Player 9
	 * @ActionScriptversion ActionScript 3.0
	 * @author Hiroaki Komatsu
	 */
	public class UITogglePauseButton extends Sprite
	{
		// --- property
		protected var bitmap:BitmapData;
		protected var playBitmap:BitmapData;
		protected var pauseBitmap:BitmapData;
		protected var point:Point = new Point();
		
		// --- skin
		[Embed(source = '/drawable/skin/play_button.png')]
		static protected var PlayButton:Class;
		
		[Embed(source = '/drawable/skin/pause_button.png')]
		static protected var PauseButton:Class;
		
		/**
		 * constructor
		 */
		public function UITogglePauseButton()
		{
			super();
			
			var playButton:Bitmap = new PlayButton() as Bitmap;
			var pauseButton:Bitmap = new PauseButton() as Bitmap;
			playBitmap = playButton.bitmapData;
			pauseBitmap = pauseButton.bitmapData;
			
			var w:Number = Math.min(playBitmap.width, pauseBitmap.width);
			var h:Number = Math.min(playBitmap.height, pauseBitmap.height);
			bitmap = new BitmapData(w, h, true, 0x0);
			addChild(new Bitmap(bitmap, "auto", true));
			
			//初期化
			playStop();
		}
		
		/**
		 * 再生が開始されたときの状態にします。
		 */
		public function playStart(event:Event = null):void
		{
			bitmap.lock();
			bitmap.copyPixels(pauseBitmap, bitmap.rect, point);
			bitmap.unlock();
		}
		
		/**
		 * 再生が停止されたときの状態にします。
		 */
		public function playStop(event:Event = null):void
		{
			bitmap.lock();
			bitmap.copyPixels(playBitmap, bitmap.rect, point);
			bitmap.unlock();
		}
		
		/**
		 * このオブジェクトでマウスまたはその他のユーザー入力メッセージを受け取るかどうかを指定します。デフォルト値は true であり、これは表示リスト上の InteractiveObject インスタンスがデフォルトでマウスイベントまたはその他のユーザー入力イベントを受け取ることを意味します。mouseEnabled を false に設定すると、インスタンスでは、マウスイベント（またはキーボードイベントなど、その他のユーザー入力イベント）を一切受け取りません。表示リスト上のこのインスタンスの子は影響を受けません。表示リスト上のオブジェクトのすべての子に関する mouseEnabled 動作を変更するには、flash.display.DisplayObjectContainer.mouseChildren を使用します。
		 * @param enabled
		 */
		override public function set mouseEnabled(enabled:Boolean):void
		{
			this.alpha = enabled ? 1 : 0.5;
			super.mouseEnabled = enabled;
		}
	}
}
