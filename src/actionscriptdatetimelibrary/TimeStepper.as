package actionscriptdatetimelibrary
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextLineMetrics;
	import flash.ui.Keyboard;
	
	import mx.controls.Button;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.core.FlexVersion;
	import mx.core.IDataRenderer;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.managers.IFocusManager;
	import mx.managers.IFocusManagerComponent;
	import mx.styles.StyleProxy;
	
	[Event(name="change", type="mx.events.NumericStepperEvent")]
	[Event(name="dataChange", type="mx.events.FlexEvent")]

	[DefaultBindingProperty(source="value", destination="value")]

	[DefaultTriggerEvent("change")]

	public class TimeStepper extends UIComponent 
		implements IDataRenderer, IDropInListItemRenderer, IFocusManagerComponent, IListItemRenderer
	{
		private static const HOURS:int = 1;
		private static const MINUTES:int = 2;
		private static const SECONDS:int = 3;
		private static const MILLISECONDS:int = 4;
		
		private static const TIME_ADD:int = 1;
		private static const TIME_SUBTRACT:int = 2;
		private static const TIME_MAX:int = 3;
		private static const TIME_MIN:int = 4;
		
		public var timeField:TimeInput;
		private var nextButton:Button;
		private var prevButton:Button;
		private var valueSet:Boolean;
		private var _tabIndex:int = -1;
		private var tabIndexChanged:Boolean = false;
		private var _timeValue:Date;
		private var lastTimeValue:Date = new Date();
		private var proposedTimeValue:Date = new Date();
		private var timeValueSet:Boolean;
		private var timeValueChanged:Boolean = false;
		private var _timeData:Object;
		
	 	[Bindable]
		[Embed(source='icons/down_arrow.png')]
		private var downArrowIcon:Class;
		
		[Bindable]
		[Embed(source='icons/up_arrow.png')]
		private var upArrowIcon:Class;
		
		public function TimeStepper()
		{
			super();
			tabChildren = true;
			_timeValue = new Date();
			_timeValue.setFullYear(0, 0, 0);
		}
		
	    override public function get baselinePosition():Number
	    {
	        if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_3_0)
	            return timeField ? timeField.baselinePosition : NaN;
	        
	        if (!validateBaselinePosition())
	            return NaN;

	        return timeField.y + timeField.baselinePosition;
	    }

		private var enabledChanged:Boolean = false;
		
		[Inspectable(category="General", enumeration="true,false", defaultValue="true")]
	    
		override public function set enabled(value:Boolean):void
		{
			super.enabled = value;
			enabledChanged = true;
			
			invalidateProperties();
		}
		
		override public function get enabled():Boolean
		{
			return super.enabled;
		}
		
		override public function get tabIndex():int
		{
			return _tabIndex;
		}
		
		override public function set tabIndex(value:int):void
		{
			if (value == _tabIndex)
				return;
			
			_tabIndex = value;
			tabIndexChanged = true;
			
			invalidateProperties();
		}
		
		private var _data:Object;
		
		[Bindable("dataChange")]
		[Inspectable(environment="none")]
		
		public function get data():Object
		{
			if (!_listData)
			    data = this.timeValue;

			return _data;
		}

		public function set data(value:Object):void
		{
			_timeData = value;
			
			if (!valueSet)
			{
				this.timeValue = _timeData as Date;
				timeValueSet = false;
			}
        
        	dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
		}
		
		protected function get downArrowStyleFilters():Object
		{
			return _downArrowStyleFilters;
		}
		
		private static var _downArrowStyleFilters:Object = 
		{    
			"cornerRadius" : "cornerRadius",        
			"highlightAlphas" : "highlightAlphas",
			"downArrowUpSkin" : "downArrowUpSkin",
			"downArrowOverSkin" : "downArrowOverSkin",
			"downArrowDownSkin" : "downArrowDownSkin",
			"downArrowDisabledSkin" : "downArrowDisabledSkin",
			"downArrowSkin" : "downArrowSkin",
			"repeatDelay" : "repeatDelay",
			"repeatInterval" : "repeatInterval"
		};

		protected function get inputFieldStyleFilters():Object
		{
			return _inputFieldStyleFilters;
		}

		private static var _inputFieldStyleFilters:Object = 
		{
			"backgroundAlpha" : "backgroundAlpha",
			"backgroundColor" : "backgroundColor",
			"backgroundImage" : "backgroundImage",
			"backgroundDisabledColor" : "backgroundDisabledColor",
			"backgroundSize" : "backgroundSize",
			"borderAlpha" : "borderAlpha", 
			"borderColor" : "borderColor",
			"borderSides" : "borderSides", 
			"borderSkin" : "borderSkin",
			"borderStyle" : "borderStyle",
			"borderThickness" : "borderThickness",
			"dropShadowColor" : "dropShadowColor",
			"dropShadowEnabled" : "dropShadowEnabled",
			"embedFonts" : "embedFonts",
			"focusAlpha" : "focusAlpha",
			"focusBlendMode" : "focusBlendMode",
			"focusRoundedCorners" : "focusRoundedCorners", 
			"focusThickness" : "focusThickness",
			"paddingLeft" : "paddingLeft", 
			"paddingRight" : "paddingRight",
			"shadowDirection" : "shadowDirection",
			"shadowDistance" : "shadowDistance",
			"textDecoration" : "textDecoration"
		};
		
		private var _listData:BaseListData;
		
		[Bindable("dataChange")]
		[Inspectable(environment="none")]

		public function get listData():BaseListData
		{
			return _listData;
		}
		
		public function set listData(value:BaseListData):void
		{
			_listData = value;
		}
		
		private var _maxChars:int = 12;
		
		private var maxCharsChanged:Boolean = false;
		
		[Bindable("maxCharsChanged")]
		
		public function get maxChars():int
		{
			return _maxChars;
		}
		
		public function set maxChars(value:int):void
		{
			if (value == _maxChars)
				return;
			
			_maxChars = value;
			maxCharsChanged = true;
			
			invalidateProperties();
			
			dispatchEvent(new Event("maxCharsChanged"));
		}
		
	    private var _timeStepSize:Number = 1;
	
	    [Bindable("stepSizeChanged")]
	    [Inspectable(category="General", defaultValue="1")]
		
		public function get stepSize():Number
		{
			return _timeStepSize;
		}
		
		public function set stepSize(value:Number):void
		{
			_timeStepSize = value;
			
			// To validate the value as min/max/stepsize has changed.
 			if (!timeValueChanged)
			{
 				this.timeValue = this.timeValue;
				timeValueSet = false;
			}
			
			dispatchEvent(new Event("stepSizeChanged"));
		}
		
		protected function get upArrowStyleFilters():Object 
		{
			return _upArrowStyleFilters;
		}
		
		private static var _upArrowStyleFilters:Object = 
		{
			"cornerRadius" : "cornerRadius",        
			"highlightAlphas" : "highlightAlphas",
			"upArrowUpSkin" : "upArrowUpSkin",
			"upArrowOverSkin" : "upArrowOverSkin",
			"upArrowDownSkin" : "upArrowDownSkin",
			"upArrowDisabledSkin" : "upArrowDisabledSkin",
			"upArrowSkin" : "upArrowSkin",
			"repeatDelay" : "repeatDelay",
			"repeatInterval" : "repeatInterval"
		};
		
		private var valueChanged:Boolean = false;
		
		[Bindable("change")]
		[Bindable("valueCommit")]
		[Inspectable(category="General", defaultValue="0")]
		
		public function get timeValue():Date
		{
			return timeValueChanged ? proposedTimeValue : _timeValue;
		}
		
		public function set timeValue(value:Date):void
		{
			timeValueSet = true;
			
			proposedTimeValue = value;
			timeValueChanged = true;
			
			_timeValue = value;
			commitTimeValue();
			
			invalidateProperties();
			invalidateSize();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			if(!timeField)
			{
				timeField = new TimeInput();
				
				var currentTime:String = formatTimeChars(_timeValue.getHours(), 2) +
					formatTimeChars(_timeValue.getMinutes(), 2) +
					formatTimeChars(_timeValue.getSeconds(), 2) +
					formatTimeChars(_timeValue.getMilliseconds(), 3);	
				
				timeField.styleName = new StyleProxy(this, inputFieldStyleFilters);
				timeField.focusEnabled = false;
				
				timeField.maxChars = _maxChars;
				timeField.text = currentTime;
				
 				timeField.addEventListener(FocusEvent.FOCUS_IN, timeField_focusInHandler);
				timeField.addEventListener(FocusEvent.FOCUS_OUT, timeField_focusOutHandler);
				timeField.addEventListener(KeyboardEvent.KEY_DOWN, timeField_keyDownHandler);
				timeField.addEventListener(Event.CHANGE, timeField_changeHandler);
				
				addChild(timeField);
			}
			
			if (!nextButton)
			{
				nextButton = new Button();
				
				nextButton.styleName = new StyleProxy(this, upArrowStyleFilters);
				nextButton.setStyle("icon", upArrowIcon);
				nextButton.height = Math.floor(timeField.height / 2);
				nextButton.width = 24;
				
				nextButton.focusEnabled = false;
				nextButton.autoRepeat = true;
				
				nextButton.addEventListener(MouseEvent.CLICK, buttonClickHandler);
				nextButton.addEventListener(FlexEvent.BUTTON_DOWN, buttonDownHandler);
				
				addChild(nextButton);
			}

			if (!prevButton)
			{
				prevButton = new Button();
				
				prevButton.styleName = new StyleProxy(this, downArrowStyleFilters);
				prevButton.setStyle("icon", downArrowIcon);
				prevButton.height = Math.floor(timeField.height / 2);
				prevButton.width = 24;
				
				prevButton.focusEnabled = false;
				prevButton.autoRepeat = true;
				
				prevButton.addEventListener(MouseEvent.CLICK, buttonClickHandler);
				prevButton.addEventListener(FlexEvent.BUTTON_DOWN, buttonDownHandler);
				
				addChild(prevButton);
			}
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (maxCharsChanged)
			{
				maxCharsChanged = false;
				timeField.maxChars = _maxChars;
			}
			
			if (valueChanged)
			{
				valueChanged = false;
			}
			
			if (enabledChanged)
			{
				enabledChanged = false;
				
				prevButton.enabled = enabled;
				nextButton.enabled = enabled;
				timeField.enabled = enabled;
			}
			
			if (tabIndexChanged)
			{
				timeField.tabIndex = _tabIndex;
				
				tabIndexChanged = false;
			}
		}
		
		override protected function measure():void
		{
			super.measure();
			
	        var lineMetrics:TextLineMetrics = measureText("00:00:00:000");
	        
			var textHeight:Number = timeField.getExplicitOrMeasuredHeight();
			var buttonHeight:Number = prevButton.getExplicitOrMeasuredHeight() + 
				nextButton.getExplicitOrMeasuredHeight();
			
			var h:Number = Math.max(textHeight, buttonHeight);
			h = Math.max(DEFAULT_MEASURED_MIN_HEIGHT, h);
			var textWidth:Number = lineMetrics.width + 5;
			var buttonWidth:Number = Math.max(prevButton.getExplicitOrMeasuredWidth(),
												nextButton.getExplicitOrMeasuredWidth());
			
			var w:Number = textWidth + buttonWidth + 20;
			w = Math.max(DEFAULT_MEASURED_MIN_WIDTH, w);
			
			measuredMinWidth = DEFAULT_MEASURED_MIN_WIDTH;
			measuredMinHeight = DEFAULT_MEASURED_MIN_HEIGHT;
			
			measuredWidth = w;
			measuredHeight = h;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number,
			unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var w:Number = nextButton.getExplicitOrMeasuredWidth();
			var h:Number = Math.round(unscaledHeight / 2);
			var h2:Number = unscaledHeight - h;
			
			nextButton.x = unscaledWidth - w;
			nextButton.y = 0;
			nextButton.setActualSize(w, h2);
			
			prevButton.x = unscaledWidth - w;
			prevButton.y = unscaledHeight - h;
			prevButton.setActualSize(w, h);
			
			timeField.setActualSize(unscaledWidth - w, unscaledHeight);
		}
		
		override public function setFocus():void
		{
			if(stage)
				stage.focus = TextField(timeField.getTextField());;
		}
		
		override protected function isOurFocus(target:DisplayObject):Boolean
		{
			return target == timeField || super.isOurFocus(target);
		}
		
		private function setValue(value:Number,
									sendEvent:Boolean = true,
									trigger:Event = null):void
		{			
			dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
		}
		
		private function takeValueFromTextField(trigger:Event = null):void
		{
			timeValue = convertTextToTime(timeField.text);
		}
		
		private function buttonPress(button:Button, trigger:Event = null):void
		{
			if (enabled)
			{
				// we may get a buttonPress message before focusOut event for
				// the text field. Hence we need to check the value in
				// inputField.
 				takeValueFromTextField();
 				
 				var selectedBlock:int = 
 					getSelectedBlock(timeField.selectionBeginIndex, timeField.selectionEndIndex);
				
				if(selectedBlock > 0)
				{
					button == nextButton ? updateTime(TIME_ADD, selectedBlock) : 
						updateTime(TIME_SUBTRACT, selectedBlock);
				}
			}
		}
		
 		override protected function focusInHandler(event:FocusEvent):void
		{
 			super.focusInHandler(event);
			
			var fm:IFocusManager = focusManager;
			if (fm)
				fm.defaultButtonEnabled = false;
		}
		
		override protected function focusOutHandler(event:FocusEvent):void
		{
 			var fm:IFocusManager = focusManager;
			if (fm)
				fm.defaultButtonEnabled = true;
			
			super.focusOutHandler(event);
			
			takeValueFromTextField(event);
		}
		
		private function buttonDownHandler(event:FlexEvent):void
		{
			buttonPress(Button(event.currentTarget), event);
		}
		
		private function buttonClickHandler(event:MouseEvent):void
		{
			timeField.setFocus();
		}
		
		private function timeField_focusInHandler(event:FocusEvent):void
		{
 			focusInHandler(event);
			
			dispatchEvent(new FocusEvent(event.type, false, false,
											event.relatedObject,
											event.shiftKey, event.keyCode));
		}
		
		private function timeField_focusOutHandler(event:FocusEvent):void
		{
 			focusOutHandler(event);
			
			dispatchEvent(new FocusEvent(event.type, false, false,
											event.relatedObject,
											event.shiftKey,event.keyCode));
		}
		
		private function timeField_keyDownHandler(event:KeyboardEvent):void
		{
			takeValueFromTextField();
			
			var selectedBlock:int = 
 					getSelectedBlock(timeField.selectionBeginIndex, timeField.selectionEndIndex);
			if(selectedBlock > 0)
			{
				switch (event.keyCode)
				{
					case Keyboard.DOWN:
						updateTime(TIME_SUBTRACT, selectedBlock);
						break;
				
					case Keyboard.UP:
						updateTime(TIME_ADD, selectedBlock);
						break;
					
					case Keyboard.PAGE_UP:
						updateTime(TIME_MAX, selectedBlock);
						break;
					
					case Keyboard.PAGE_DOWN:
						updateTime(TIME_MIN, selectedBlock);
						break;
					
					case Keyboard.DELETE:
						resetTime();
						break;
					
					case Keyboard.BACKSPACE:
						commitTimeValue();
						break;
				}
			}
		}
		
		private function timeField_changeHandler(event:Event):void
		{
			event.stopImmediatePropagation();

			timeValue = convertTextToTime(timeField.text);
		}
		
		private function formatTimeChars(value:int, chars:int):String
		{
			if(chars == 2)
			{
				if(value < 10)
				{
					return "0" + value.toString();
				}
				else
				{
					return value.toString();
				}
			}
			else if(chars == 3)
			{
				if(value < 10)
				{
					return "00" + value.toString();
				}
				else if(value > 9 && value < 100)
				{
					return "0" + value.toString();
 				}
 				else
 				{
 					return value.toString();
 				}
			}
			else
			{
				return value.toString();
			}
		}
		
		protected function validateBaselinePosition():Boolean
		{
			if (!parent)
				return false;

			if (width == 0 && height == 0)
			{
				validateNow();
				
				var w:Number = getExplicitOrMeasuredWidth();
				var h:Number = getExplicitOrMeasuredHeight();
				
				setActualSize(w, h);
			}

			validateNow();
			
			return true;
		}
		
		private function convertTimeToText(time:Date):String
		{
			var convertedTime:String;
			
			var hours:String = formatTimeChars(time.getHours(), 2);
			var minutes:String = formatTimeChars(time.getMinutes(), 2);
			var seconds:String = formatTimeChars(time.getSeconds(), 2);
			var milliseconds:String = formatTimeChars(time.getMilliseconds(), 3);
			
			convertedTime = hours + ":" + minutes + ":" + seconds + ":" + milliseconds;
			
			return convertedTime;
		}
		
		private function convertTextToTime(time:String):Date
		{
			var convertedTime:Date = new Date();	
			
			var hours:Number = Number(time.substr(0, 2));
			var minutes:Number = Number(time.substr(2, 2));
			var seconds:Number = Number(time.substr(4, 2));
			var milliseconds:Number = Number(time.substr(6, 3));
			
			convertedTime.setHours(hours, minutes, seconds, milliseconds);
			
			return convertedTime;
		}

		private function getSelectedBlock(begin:int, end:int):int
		{
			if(begin >= 0 && end < 3)
			{
				return HOURS;
			}
			else if(begin > 2 && end < 6)
			{
				return MINUTES;
			}
			else if(begin > 5 && end < 9)
			{
				return SECONDS;
			}
			else if(begin > 8 && end < 13)
			{
				return MILLISECONDS;
			}
			else
			{
				return 0;
			}
		}

		private function resetTime():void
		{
			var allColons:RegExp = /:/g;
			
			lastTimeValue = timeValue;
			
			timeValue.hours = 0;
			timeValue.minutes = 0;
			timeValue.seconds = 0;
			timeValue.milliseconds = 0;
			
			timeField.text = convertTimeToText(timeValue).replace(allColons, "");
			
			timeField.selectionBeginIndex = 0;
		}

		private function updateTime(operation:int, block:int):void
		{
			var allColons:RegExp = /:/g;
			
			lastTimeValue = timeValue;			
			
			switch(block)
			{
				case HOURS:
					timeValue.hours = computeHour(operation, lastTimeValue.getHours());
					break;
				case MINUTES:
					timeValue.minutes = computeMinutesSeconds(operation, lastTimeValue.getMinutes());
					break;
				case SECONDS:
					timeValue.seconds = computeMinutesSeconds(operation, lastTimeValue.getSeconds());
					break;
				case MILLISECONDS:
					timeValue.milliseconds = computeMilliseconds(operation, lastTimeValue.getMilliseconds());
					break;
			}

			timeField.text = convertTimeToText(timeValue).replace(allColons, "");
			
			resetBlock(block);
		}
		
		private function commitTimeValue():void
		{
			var allColons:RegExp = /:/g;
			
			timeField.text = convertTimeToText(timeValue).replace(allColons, "");
		}
		
		private function computeHour(operation:int, value:int):int
		{
			var newValue:int;

			switch(operation)
			{
				case TIME_ADD:
					newValue = (value == 23) ? 0 : value + 1;
					break;
				case TIME_SUBTRACT:
					newValue = (value == 0) ? 23 : value - 1;
					break;
				case TIME_MAX:
					newValue = 23;
					break;
				case TIME_MIN:
					newValue = 0;
					break;
			}

			return newValue;
		}
		
		private function computeMinutesSeconds(operation:int, value:int):int
		{
			var newValue:int;
			
			switch(operation)
			{
				case TIME_ADD:
					newValue = (value == 59) ? 0 : value + 1;
					break;
				case TIME_SUBTRACT:
					newValue = (value == 0) ? 59 : value - 1;
					break;
				case TIME_MAX:
					newValue = 59;
					break;
				case TIME_MIN:
					newValue = 0;
					break;
			}
			
			return newValue;
		}
		
		private function computeMilliseconds(operation:int, value:int):int
		{
			var newValue:int;
			
			switch(operation)
			{
				case TIME_ADD:
					newValue = (value == 999) ? 0 : value + 1;
					break;
				case TIME_SUBTRACT:
					newValue = (value == 0) ? 999 : value - 1;
					break;
				case TIME_MAX:
					newValue = 999;
					break;
				case TIME_MIN:
					newValue = 0;
					break;
			}
			
			return newValue;
		}

		private function resetBlock(block:int):void
		{
			switch(block)
			{
				case HOURS:
					timeField.selectionBeginIndex = 0;
					timeField.selectionEndIndex = 2;
					break;
				case MINUTES:
					timeField.selectionBeginIndex = 3;
					timeField.selectionEndIndex = 5;
					break;
				case SECONDS:
					timeField.selectionBeginIndex = 6;
					timeField.selectionEndIndex = 8;
					break;
				case MILLISECONDS:
					timeField.selectionBeginIndex = 9;
					timeField.selectionEndIndex = 12;
					break;
			}
		}
	}
}