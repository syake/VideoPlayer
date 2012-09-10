package
{
	import com.syake.video.NetStreamController;
	import com.syake.video.NetStreamEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import views.IUISeekView;
	import views.VideoControlView;
	
	/**
	 * ストリーミング再生プレイヤー
	 * @version Flash Player 9
	 * @ActionScriptversion ActionScript 3.0
	 * @author Hiroaki Komatsu
	 */
	[SWF(width="960", height="640", backgroundColor=0x000000)]
	public class VideoPlayer extends Sprite implements IUISeekView
	{
		static private const VIDEO_URL:String = "http://syake.github.com/VideoStreamExamples/1kuCek4TRK8.flv";
		
		// --- instance
		public var video:Video;
		public var control:VideoControlView;
		
		/**
		 * @see com.syake.video.NetStreamController
		 */
		private var netStream:NetStreamController;
		
		/**
		 * ハンドルのドラッグが開始されたときの再生状況
		 */
		private var playing:Boolean;
		
		/**
		 * VideoPlayerオブジェクトを生成します。
		 */
		public function VideoPlayer()
		{
			if (stage == null) addEventListener(Event.ADDED_TO_STAGE, init);
			else init();
		}
		
		/**
		 * ビューが表示リストから追加されたときに呼び出されます。
		 * @param event
		 */
		protected function init(event:Event = null):void
		{
			//ビデオ生成
			video = new Video(960, 640);
			addChild(video);
			
			//コントロールビュー生成
			control = new VideoControlView(stage.stageWidth - 100, 180);
			control.delegate = this;
			addChild(control);
			control.x = (stage.stageWidth - control.width) / 2;
			control.y = stage.stageHeight - control.height - 30;
			control.toggleButton.addEventListener(MouseEvent.MOUSE_DOWN, togglePause, false, 0, true);
			control.prevButton.addEventListener(MouseEvent.MOUSE_DOWN, prev, false, 0, true);
			control.nextButton.addEventListener(MouseEvent.MOUSE_DOWN, next, false, 0, true);
			
			//ローカルファイルアクセス用のネットコネクションを作成する
			var connection:NetConnection = new NetConnection();
			connection.connect(null);
			
			//ネットストリームオブジェクトを作成する
			netStream = new NetStreamController(connection);
			
			//ビデオオブジェクトとネットストリームオブジェクトを関連付ける
			video.attachNetStream(netStream);
			
			//読み込み開始
			load();
		}
		
		/**
		 * メディアの読み込みを開始します。
		 */
		private function load():void
		{
			control.toggleButton.mouseEnabled = false;
			control.prevButton.mouseEnabled = false;
			control.nextButton.mouseEnabled = false;
			
			addEventListener(Event.ENTER_FRAME, handleNetStreamSeek);
			netStream.addEventListener(NetStreamEvent.SUCCESS, handleNetStreamSuccess);
			netStream.addEventListener(NetStreamEvent.FAILED, handleNetStreamFailed);
			netStream.addEventListener(NetStreamEvent.BUFFER_FLUSH, handleNetStreamBufferFlush);
			netStream.addEventListener(NetStreamEvent.PLAY_START, control.toggleButton.playStart);
			netStream.addEventListener(NetStreamEvent.PLAY_STOP, control.toggleButton.playStop);
			netStream.play(VIDEO_URL);
		}
		
		/**
		 * 再生状況を監視します。
		 * @param event
		 */
		private function handleNetStreamSeek(event:Event):void
		{
			control.buffer(netStream.bytesLoaded, netStream.bytesTotal);
			if (netStream.duration > 0) {
				control.seek(netStream.time, netStream.duration);
			}
		}
		
		/**
		 * メディアの読み込みに成功したときに呼び出されます。
		 * @param event
		 */
		private function handleNetStreamSuccess(event:NetStreamEvent):void
		{
			netStream.removeEventListener(NetStreamEvent.SUCCESS, handleNetStreamSuccess);
			netStream.removeEventListener(NetStreamEvent.FAILED, handleNetStreamFailed);
			control.toggleButton.mouseEnabled = true;
			control.prevButton.mouseEnabled = true;
			control.nextButton.mouseEnabled = true;
		}
		
		/**
		 * メディアの読み込みに失敗したときに呼び出されます。
		 * @param event
		 */
		private function handleNetStreamFailed(event:NetStreamEvent):void
		{
			removeEventListener(Event.ENTER_FRAME, handleNetStreamSeek);
			netStream.removeEventListener(NetStreamEvent.SUCCESS, handleNetStreamSuccess);
			netStream.removeEventListener(NetStreamEvent.FAILED, handleNetStreamFailed);
			netStream.removeEventListener(NetStreamEvent.BUFFER_FLUSH, handleNetStreamBufferFlush);
			netStream.removeEventListener(NetStreamEvent.PLAY_START, control.toggleButton.playStart);
			netStream.removeEventListener(NetStreamEvent.PLAY_STOP, control.toggleButton.playStop);
			
			var txt:TextField = new TextField();
			txt.defaultTextFormat = new TextFormat(null, 36, 0xFFFFFF);
			txt.autoSize = "center";
			txt.selectable = false;
			txt.text = event.info.code;
			addChild(txt);
			txt.x = (video.width - txt.width) / 2;
			txt.y = (video.height - txt.height) / 2;
		}
		
		/**
		 * ストリーム読み込みが終了したときにボタンを有効にします。
		 * @param event
		 */
		private function handleNetStreamBufferFlush(event:NetStreamEvent):void
		{
			netStream.removeEventListener(NetStreamEvent.BUFFER_FLUSH, handleNetStreamBufferFlush);
			control.nextButton.mouseEnabled = true;
		}
		
		/**
		 * トグルボタンがクリックされたときに呼び出されます。
		 * @param event
		 */
		private function togglePause(event:MouseEvent):void
		{
			netStream.togglePause();
			if (netStream.playing) {
				control.toggleButton.playStart();
			} else {
				control.toggleButton.playStop();
			}
		}
		
		/**
		 * prevボタンがクリックされたときに呼び出されます。
		 * @param event
		 */
		protected function prev(event:MouseEvent):void
		{
			netStream.seek(0);
		}
		
		/**
		 * nextボタンがクリックされたときに呼び出されます。
		 * @param event
		 */
		protected function next(event:MouseEvent):void
		{
			netStream.seek(netStream.duration - 2);
		}
		
		// --- delegate
		/**
		 * ハンドルのドラッグが開始されたときに呼び出されます。
		 */
		public function seekViewStartDrag():void
		{
			playing = netStream.playing;
			netStream.pause();
		}
		
		/**
		 * ハンドルのドラッグが進行中のときに呼び出されます。
		 * @param rate
		 */
		public function seekViewDrag(rate:Number):void
		{
			netStream.seek(netStream.duration * rate);
		}
		
		/**
		 * ハンドルのドラッグが停止されたときに呼び出されます。
		 */
		public function seekViewStopDrag():void
		{
			if (playing) netStream.resume();
		}
	}
}
