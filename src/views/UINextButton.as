package views
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	/**
	 * NextButtonボタン
	 * @version Flash Player 9
	 * @ActionScriptversion ActionScript 3.0
	 * @author Hiroaki Komatsu
	 */
	public class UINextButton extends Sprite
	{
		// --- skin
		[Embed(source = '/drawable/skin/next_button.png')]
		static protected var _Button:Class;
		
		/**
		 * constructor
		 */
		public function UINextButton()
		{
			super();
			
			var tmp:Bitmap = new _Button() as Bitmap;
			this.graphics.beginBitmapFill(tmp.bitmapData, null, false, true);
			this.graphics.drawRect(0, 0, tmp.width, tmp.height);
			this.graphics.endFill();
			this.mouseEnabled = false;
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
