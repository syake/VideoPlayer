package views
{
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	/**
	 * シークバービュー
	 * @version Flash Player 9
	 * @ActionScriptversion ActionScript 3.0
	 * @author Hiroaki Komatsu
	 */
	public class UISeekView extends Sprite
	{
		// --- instance
		protected var frameView:Shape;
		protected var bufferView:Shape;
		protected var bufferMask:Shape;
		protected var seekView:Shape;
		protected var seekMask:Shape;
		protected var handle:Sprite;
		
		// --- property
		public var delegate:IUISeekView;
		protected var handleRect:Rectangle;
		protected var dragging:Boolean;
		
		/**
		 * バーの高さを示します（ピクセル単位）。
		 */
		public function get barHeight():Number
		{
			return _barHeight;
		}
		protected var _barHeight:Number;
		
		// --- skin
		[Embed(source = '/drawable/skin/slider_frame_L.png')]
		static protected var SliderFrameL:Class;
		
		[Embed(source = '/drawable/skin/slider_frame_C.png')]
		static protected var SliderFrameC:Class;
		
		[Embed(source = '/drawable/skin/slider_frame_R.png')]
		static protected var SliderFrameR:Class;
		
		[Embed(source = '/drawable/skin/slider_buffer_L.png')]
		static protected var SliderBufferL:Class;
		
		[Embed(source = '/drawable/skin/slider_buffer_C.png')]
		static protected var SliderBufferC:Class;
		
		[Embed(source = '/drawable/skin/slider_buffer_R.png')]
		static protected var SliderBufferR:Class;
		
		[Embed(source = '/drawable/skin/slider_seek_L.png')]
		static protected var SliderSeekL:Class;
		
		[Embed(source = '/drawable/skin/slider_seek_C.png')]
		static protected var SliderSeekC:Class;
		
		[Embed(source = '/drawable/skin/slider_seek_R.png')]
		static protected var SliderSeekR:Class;
		
		[Embed(source = '/drawable/skin/slider_hundle.png')]
		static protected var SliderHundle:Class;
		
		/**
		 * constructor
		 * @param w
		 */
		public function UISeekView(w:Number)
		{
			super();
			
			//枠生成
			frameView = createSliderBar(w, new SliderFrameL as Bitmap, new SliderFrameC as Bitmap, new SliderFrameR as Bitmap);
			addChild(frameView);
			
			//バッファ部分生成
			bufferView = createSliderBar(w, new SliderBufferL as Bitmap, new SliderBufferC as Bitmap, new SliderBufferR as Bitmap);
			addChild(bufferView);
			bufferMask = new Shape();
			bufferMask.graphics.beginFill(0);
			bufferMask.graphics.drawRect(0, 0, w, bufferView.height);
			bufferMask.graphics.endFill();
			addChild(bufferMask);
			bufferView.mask = bufferMask;
			
			//進行状況部分生成
			seekView = createSliderBar(w, new SliderSeekL as Bitmap, new SliderSeekC as Bitmap, new SliderSeekR as Bitmap);
			addChild(seekView);
			seekMask = new Shape();
			seekMask.graphics.beginFill(0);
			seekMask.graphics.drawRect(0, 0, w, seekView.height);
			seekMask.graphics.endFill();
			addChild(seekMask);
			seekView.mask = seekMask;
			
			//高さ
			_barHeight = this.height;
			
			//ハンドルを生成
			var sliderHundle:Bitmap = new SliderHundle as Bitmap;
			handle = new Sprite();
			handle.graphics.beginBitmapFill(sliderHundle.bitmapData, new Matrix(1, 0, 0, 1, -sliderHundle.width / 2, -sliderHundle.height / 2), false, true);
			handle.graphics.drawRect(-sliderHundle.width / 2, - sliderHundle.height / 2, sliderHundle.width, sliderHundle.height);
			handle.graphics.endFill();
			addChild(handle);
			
			//位置
			handle.x = seekView.x;
			handle.y = seekView.y + seekView.height / 2;
			handleRect = new Rectangle(handle.x, handle.y, seekView.width, 0);
			
			//初期設定
			buffer(0, 0);
			commit(0);
			
			if (stage == null) addEventListener(Event.ADDED_TO_STAGE, init);
			else init();
		}
		
		/**
		 * ビューが表示リストから追加されたときに呼び出されます。
		 * @param event
		 */
		protected function init(event:Event = null):void
		{
			//マウスイベント
			handle.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandle, false, 0, true);
		}
		
		/**
		 * スライダーのバーを生成します。
		 * @param w
		 * @param left
		 * @param center
		 * @param right
		 * @return;
		 */
		protected function createSliderBar(w:uint, left:Bitmap, center:Bitmap, right:Bitmap):Shape
		{
			//ホルダー生成
			var holder:Shape = new Shape();
			
			//左描画
			holder.graphics.beginBitmapFill(left.bitmapData, null, false, true);
			holder.graphics.drawRect(0, 0, left.width, left.height);
			holder.graphics.endFill();
			
			//中描画
			holder.graphics.beginBitmapFill(center.bitmapData, null, true, true);
			holder.graphics.drawRect(left.width, 0, w - (left.width + right.width), center.height);
			holder.graphics.endFill();
			
			//右描画
			var posx:Number = w - right.width;
			holder.graphics.beginBitmapFill(right.bitmapData, new Matrix(1, 0, 0, 1, posx % right.width, 0), true, true);
			holder.graphics.drawRect(posx, 0, right.width, right.height);
			holder.graphics.endFill();
			return holder;
		}
		
		/**
		 * バッファの長さを表示します。
		 * @param bytesLoaded
		 * @param bytesTotal
		 */
		public function buffer(bytesLoaded:Number, bytesTotal:Number):void
		{
			var rate:Number = (bytesTotal > 0) ? bytesLoaded / bytesTotal : 0;
			bufferMask.scaleX = rate;
		}
		
		/**
		 * 再生状況を表示します。
		 * @param time
		 * @param duration
		 */
		public function seek(time:Number, duration:Number):void
		{
			if (!dragging) {
				var rate:Number = (duration > 0) ? time / duration : 0;
				commit(rate);
			}
		}
		
		/**
		 * 再生状況を表示します。
		 * @param rate
		 */
		protected function commit(rate:Number):void
		{
			seekMask.scaleX = rate;
			handle.x = seekView.x + seekView.width * rate;
		}
		
		/**
		 * ハンドルがマウスダウンされたときに呼び出されます。
		 * @param event
		 */
		protected function onMouseDownHandle(event:MouseEvent):void
		{
			handle.addEventListener(MouseEvent.MOUSE_UP, onMouseUpHandle);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpHandle);
			addEventListener(Event.ENTER_FRAME, drag);
			dragging = true;
			handle.startDrag(false, handleRect);
			if (delegate != null) delegate.seekViewStartDrag();
		}
		
		/**
		 * ハンドルをドラッグさせます。
		 * @param event
		 */
		protected function drag(event:Event):void
		{
			var rate:Number = (handle.x - seekView.x) / seekView.width;
			commit(rate);
			if (delegate != null) delegate.seekViewDrag(rate);
		}
		
		/**
		 * ハンドルがマウスアップされたときに呼び出されます。
		 * @param event
		 */
		protected function onMouseUpHandle(event:MouseEvent):void
		{
			handle.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpHandle);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpHandle);
			removeEventListener(Event.ENTER_FRAME, drag);
			dragging = false;
			handle.stopDrag();
			if (delegate != null) delegate.seekViewStopDrag();
		}
	}
}
