package views
{
	public interface IUISeekView
	{
		/**
		 * ハンドルのドラッグが開始されたときに呼び出されます。
		 */
		function seekViewStartDrag():void;
		
		/**
		 * ハンドルのドラッグが進行中のときに呼び出されます。
		 * @param rate
		 */
		function seekViewDrag(rate:Number):void;
		
		/**
		 * ハンドルのドラッグが停止されたときに呼び出されます。
		 */
		function seekViewStopDrag():void;
	}
}