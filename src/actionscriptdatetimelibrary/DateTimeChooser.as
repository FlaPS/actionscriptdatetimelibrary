package actionscriptdatetimelibrary
{
	import flash.events.MouseEvent;
	
	import mx.controls.DateChooser;
	import mx.core.mx_internal;
	
	[IconFile("DateChooser.png")]
	
	use namespace mx_internal;
	
	public class DateTimeChooser extends DateChooser
	{
		private var _timeStepper:TimeStepper;
		private var headerHeightDT:Number = 30;
		private var _selectedDateTime:Date;
		
		public function DateTimeChooser()
		{
			super();
		}
		
		public function get timeStepper():TimeStepper
		{
			return _timeStepper;
		}
		
		public function set timeStepper(value:TimeStepper):void
		{
			_timeStepper = value;
			
			invalidateProperties();
			invalidateSize();
		}
		
		public function get selectedDateTime():Date
		{
			var time:Date = timeStepper.timeValue;
			
			if(selectedDate != null)
			{
				_selectedDateTime = new Date(selectedDate.getFullYear(), selectedDate.getMonth(),
					selectedDate.getDate(), time.getHours(), time.getMinutes(), time.getSeconds(),
					time.getMilliseconds());
				
				return _selectedDateTime;
			}
			else
			{
				return null;
			}
		}
		
		public function set selectedDateTime(value:Date):void
		{
			_selectedDateTime = value;
			
			selectedDate = _selectedDateTime;
			
			if(!timeStepper)
			{
				createChildren();
			}
			
			timeStepper.timeValue = _selectedDateTime;
			
			invalidateProperties();
			invalidateSize();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			createTimeStepper();
		}
		
	    override protected function measure():void
	    {
	    	super.measure();
	    	
	    	var stepperHeight:int = timeStepper.height;
	    	
	    	measuredHeight = measuredHeight + stepperHeight;
	    	measuredMinHeight = measuredMinHeight + stepperHeight;
	    }
	    
	    override protected function updateDisplayList(unscaledWidth:Number, 
	    	unscaledHeight:Number):void
	    {
	    	super.updateDisplayList(unscaledWidth, unscaledHeight);
	    	
	    	var stepperHeight:int = timeStepper.height;
	    	
	    	var borderThickness:Number = getStyle("borderThickness");
	    	
			var w:Number = unscaledWidth - borderThickness * 2;
			var h:Number = unscaledHeight - borderThickness * 2 - stepperHeight;
			
			var monthHeight:Number = monthDisplay.getExplicitOrMeasuredHeight();
			var yearWidth:Number = yearDisplay.getExplicitOrMeasuredWidth();
			
			var dateHeight:Number = borderThickness + (headerHeightDT - monthHeight) / 2;
			
	    	dateGrid.setActualSize(w, h - headerHeightDT);
	    	
	    	timeStepper.move((width - timeStepper.width) / 2, 
	    		dateGrid.y + dateGrid.height - 4);
	    }
	    
		
		public function createTimeStepper():void
		{
			if(!timeStepper)
			{
				timeStepper = new TimeStepper();
				
				timeStepper.height = measureText("00:00:00:000").height + 10;
				timeStepper.width = measureText("00:00:00:000").width + 40;
				
				addChild(timeStepper);
			}
		}
	}
}