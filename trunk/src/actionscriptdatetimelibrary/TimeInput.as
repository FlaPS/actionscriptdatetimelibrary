package actionscriptdatetimelibrary
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	
	import mx.controls.TextInput;
	import mx.core.mx_internal;
	import mx.core.IUITextField;
	
	use namespace mx_internal;

	[Event(name="inputMaskEnd")]
	
	public class TimeInput extends TextInput
	{
		private var arrWorking:Array = [];
		private var intPosition:int = 0;
		private var workingUpdated:Boolean = false;
		private var maskUpdated:Boolean = true;
		private var textUpdated:Boolean = false;
		private var strBlank:String = "_";
		private var strDefault:String = "_";
		private var strMask:String = "tn:fn:fn:nnn";
		private var strText:String = "";
		
		public function TimeInput()
		{
			super();
			
			tabChildren = true;
			restrict = "0-9";
//			parentDrawsFocus = true;

 			addEventListener(MouseEvent.CLICK, reposition, true);
			addEventListener(KeyboardEvent.KEY_DOWN, interceptKey, true);
			addEventListener(TextEvent.TEXT_INPUT, intercept, true);
			addEventListener(FocusEvent.FOCUS_IN, interceptFocus, false); 
		}
		
		public function get blankString():String
		{
			return strBlank;
		}
		
		public function get defaultString():String
		{
			return strDefault;
		}
		
		public function get timeMask():String
		{
			return strMask;
		}
		
		override public function get text():String
		{
			var result:String = "";
			
			for(var i:Number = 0; i < arrWorking.length; i++)
			{
				var strChar:String = arrWorking[i];
				if(strMask.charAt(i) == strChar)
				{
					continue;
				}
				
				if(strMask == strBlank)
				{
					strChar = " ";
				}
				
				result += strChar;
			}
			
			return result;
		}
		
		override public function set text(value:String):void
		{
			strText = value;
			textUpdated = true;
			
			try
			{
				invalidateDisplayList();
			}
			catch(e:Error)
			{
				trace(e.message);
			}
		}
		
		public function get actualText():String
		{
			var result:String = "";
			
			for(var i:Number = 0; i < arrWorking.length; i++)
			{
				var strChar:String = arrWorking[i];
				if(strChar == strBlank)
				{
					strChar = strDefault;
				}
				result += strChar;
			}
			
			return result;
		}
		
		private function reposition(event:MouseEvent):void
		{
			var pos:Number = this.selectionBeginIndex;
			intPosition = pos;
		}
		
		private function interceptKey(event:KeyboardEvent):void
		{
/* 			if(event.keyCode == Keyboard.BACKSPACE)
			{
				intPosition = selectionBeginIndex;
				retreatPosition();
				allowChar(strBlank);
			}
			else if(event.keyCode == Keyboard.SPACE)
			{
				allowChar(strDefault);
				advancePosition();
			}
			else if(event.keyCode == Keyboard.DELETE)
			{
				if(intPosition < strMask.length )
				{
					allowChar(strBlank);
					advancePosition(true);
				}
			}
			else if(event.keyCode == Keyboard.LEFT)
			{
				intPosition = this.selectionBeginIndex;
				retreatPosition();
				event.preventDefault();
			}
			else if(event.keyCode == Keyboard.RIGHT)
			{
				advancePosition(true);
				event.preventDefault();
			}
			else if(event.keyCode == Keyboard.END)
			{
				intPosition = arrWorking.length;
				event.preventDefault();
			}
			else if(event.keyCode == Keyboard.HOME)
			{
				intPosition = -1;
				advancePosition(true);
			} */
			
			workingUpdated = true;

			try
			{
				invalidateDisplayList();
			}
			catch(e:Error)
			{
				trace(e.message);
			}
		}
		
		private function interceptFocus(event:FocusEvent):void
		{
			var start:Number = selectionBeginIndex;
			
			if(event.relatedObject != null)
			{
				start = 0;
			}
			setSelection(start, start);
			intPosition = start - 1;
			
			advancePosition();
		}
		
		private function intercept(event:TextEvent):void
		{
			var input:String = event.text;
			
			if(strMask.length <= intPosition)
			{
				event.preventDefault();
				dispatchEvent(new Event("inputMaskEnd"));
				return;
			}
			
			var strChar:String = input.charAt(0);
			var strCurrent:String = strMask.charAt(intPosition);
			var advance:Boolean = true;
			
			switch(strCurrent) 
			{
				case "n":
					if(isNine(strChar))
					{
						allowChar(strChar);
					}
					else
					{
						event.preventDefault();
						advance = false;
					}
					break;
				case "f":
					if(isFive(strChar))
					{
						allowChar(strChar);
					}
					else
					{
						event.preventDefault();
						advance = false;
					}
					break;
				case "t":
					if(isTwo(strChar))
					{
						allowChar(strChar);
					}
					else
					{
						event.preventDefault();
						advance = false;
					}
					break;
				default:
					break;
			}
			
			if(advance)
			{
				advancePosition();
			}
			
			workingUpdated = true;
			
			try
			{
				invalidateDisplayList();
			}
			catch(e:Error)
			{
				trace(e.message);
			}
		}
		
		protected function advancePosition(byArrow:Boolean = false):void
		{
			var pos:Number = intPosition;
			
			while((++pos) < strMask.length && !isMask(strMask.charAt(pos))) ;
			
			intPosition = pos;

			if( pos >= strMask.length && !byArrow)
			{
				dispatchEvent(new Event("inputMaskEnd"));
			}
			
			setSelection(intPosition, intPosition);
		}
		
		protected function retreatPosition():void
		{
			var pos:Number = intPosition;
			
			while((--pos) > 0 && !isMask(strMask.charAt(pos)));
			
			intPosition = pos;
			
			setSelection(intPosition, intPosition);
		}
		
		protected function isMask(strChar:String):Boolean
		{
			return strChar == "n" || strChar == "f" || strChar == "t";
		}
		
		protected function isNine(strChar:String):Boolean
		{
			return strChar == "0" || strChar == "1" || strChar == "2" || strChar == "3" ||
			       strChar == "4" || strChar == "5" || strChar == "6" || strChar == "7" ||
			       strChar == "8" || strChar == "9";
		}
		
		protected function isFive(strChar:String):Boolean
		{
			return strChar == "0" || strChar == "1" || strChar == "2" || strChar == "3" ||
			       strChar == "4" || strChar == "5";
		}
		
		protected function isTwo(strChar:String):Boolean
		{
			return strChar == "0" || strChar == "1" || strChar == "2";
		}
		
		private function allowChar(strChar:String):void
		{
			arrWorking[intPosition] = strChar;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			if(maskUpdated)
			{
				maskUpdated = false;
				
				arrWorking = [];
				var strChar:String = strMask;
				for(var i:int = 0; i < strChar.length; i++)
				{
					var tmpChar:String = strChar.charAt(i);
					
					if(isMask(tmpChar))
					{
						tmpChar = strBlank;
					}
					
					arrWorking.push(tmpChar);
				}
				
				workingUpdated = true;
			}
			
			if(textUpdated)
			{
				textUpdated = false;
				
				var t:Number = 0;
				var value:String = strText;
				
				for(var j:Number = 0; j < strMask.length; j++)
				{
					var m:String = strMask.charAt(j);
					if(isMask(m))
					{
						if(t >= value.length )
						{
							arrWorking[j] = strBlank;
						}
						else
						{
							arrWorking[j] = value.charAt(t);
						}
						
						t += 1;
					}
					else
					{
						arrWorking[j] = m;
					}
				}

				workingUpdated = true;
			}
			
			if(workingUpdated)
			{
				super.text = arrWorking.join("");
				workingUpdated = false;
			}
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		}
		
		override public function setFocus():void
		{
//			stage.focus = textField;
			textField.setFocus();
		}
		
	    internal function getTextField():IUITextField
	    {
	        return textField;
	    }
		
		override protected function focusOutHandler(event:FocusEvent):void
		{
//			event.preventDefault();
//			event.stopPropagation();
//			
//		super.focusOutHandler(event);
//		
//		if (_imeMode != null && _editable)
//		{
//		// When IME.conversionMode is unknown it cannot be
//		// set to anything other than unknown(English)
//		// and when known it cannot be set to unknown
//		if (IME.conversionMode != IMEConversionMode.UNKNOWN 
//		&& prevMode != IMEConversionMode.UNKNOWN)
//		IME.conversionMode = prevMode;
//		IME.enabled = false;
//		}
//		
//		dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
		}
//		override public function drawFocus(isFocused:Boolean):void
//		{
//			if (parentDrawsFocus)
//			{
//				IFocusManagerComponent(parent).drawFocus(isFocused);
//				return;
//			}
//			
//			super.drawFocus(isFocused);
//		}
	}
}