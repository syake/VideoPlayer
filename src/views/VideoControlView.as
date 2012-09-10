package views
{
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ビデオコントローラービュー
	 * @version Flash Player 9
	 * @ActionScriptversion ActionScript 3.0
	 * @author Hiroaki Komatsu
	 */
	public class VideoControlView extends Sprite
	{
		// --- instance
		public var toggleButton:UITogglePauseButton;
		public var prevButton:UIPrevButton;
		public var nextButton:UINextButton;
		public var seekView:UISeekView;
		public var seekTime:TextField;
		public var restTime:TextField;
		
		/**
		 * UISeekBarViewのデリゲートを指定します。
		 */
		public function get delegate():IUISeekView
		{
			return seekView.delegate;
		}
		public function set delegate(value:IUISeekView):void
		{
			seekView.delegate = value;
		}
		
		/**
		 * constructor
		 * @param w
		 * @param h
		 */
		public function VideoControlView(w:Number, h:Number)
		{
			super();
			
			//下地生成
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(w, h, Math.PI / 2, 0, 0);
			this.graphics.lineStyle(3, 0xFFFFFF);
			this.graphics.beginGradientFill(GradientType.LINEAR, [0xA6A6A6, 0x404040, 0x000000, 0x000000], [0.5, 0.5, 0.5, 0.5], [0, 110, 127, 255], matrix);
			this.graphics.drawRoundRect(0, 0, w, h, 50, 50);
			this.graphics.endFill();
			
			//トグルボタン生成
			toggleButton = new UITogglePauseButton();
			addChild(toggleButton);
			toggleButton.x = (w - toggleButton.width) / 2;
			toggleButton.y = (h - toggleButton.height) / 4;
			
			//prevボタン生成
			prevButton = new UIPrevButton();
			addChild(prevButton);
			prevButton.x = (w - toggleButton.width) / 3;
			prevButton.y = toggleButton.y;
			
			//nextボタン生成
			nextButton = new UINextButton();
			addChild(nextButton);
			nextButton.x = (w - toggleButton.width) / 3 * 2;
			nextButton.y = toggleButton.y;
			
			//シークバー生成
			var barW:Number = w - 300;
			seekView = new UISeekView(barW);
			addChild(seekView);
			seekView.x = (w - barW) / 2;
			seekView.y = (h - seekView.barHeight) / 4 * 3;
			
			//時間生成
			seekTime = new TextField();
			seekTime.selectable = false;
			seekTime.defaultTextFormat = new TextFormat(null, 36, 0xFFFFFF, null, null, null, null, null, "right");
			addChild(seekTime);
			
			restTime = new TextField();
			restTime.selectable = false;
			restTime.defaultTextFormat = new TextFormat(null, 36, 0xFFFFFF, null, null, null, null, null, "left");
			addChild(restTime);
			
			//初期化
			seek(0, 0);
			
			//位置
			seekTime.width = restTime.width = 100;
			seekTime.height = seekTime.textHeight;
			restTime.height = restTime.textHeight;
			seekTime.x = seekView.x - seekTime.width - 40;
			seekTime.y = seekView.y + (seekView.barHeight - seekTime.height) / 2;
			restTime.x = seekView.x + seekView.width;
			restTime.y = seekView.y + (seekView.barHeight - restTime.height) / 2;
		}
		
		/**
		 * バッファの長さを表示します。
		 * @param bytesLoaded
		 * @param bytesTotal
		 */
		public function buffer(bytesLoaded:Number, bytesTotal:Number):void
		{
			seekView.buffer(bytesLoaded, bytesTotal);
		}
		
		/**
		 * 再生状況を表示します。
		 * @param time
		 * @param duration
		 */
		public function seek(time:Number, duration:Number):void
		{
			seekView.seek(time, duration);
			seekTime.text = timeFormat(time);
			restTime.text = "- " + timeFormat(duration - time);
		}
		
		/**
		 * 秒をデジタル書式（m:ss）に変換します。
		 * @param	time
		 * @return
		 */
		protected function timeFormat(time:Number):String
		{
			if (time < 0) time = 0;
			var min:int = Math.floor(time / 60);
			var sec:int = Math.floor(time % 60);
			var min_val:String = String(min);
			var sec_val:String = (sec < 10) ? "0" + sec : String(sec);
			return min_val + ":" + sec_val;
		}
	}
}