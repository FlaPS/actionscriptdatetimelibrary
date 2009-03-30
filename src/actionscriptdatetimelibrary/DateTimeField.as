package actionscriptdatetimelibrary
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import mx.controls.Button;
	import mx.controls.ComboBase;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.controls.listClasses.ListData;
	import mx.core.ClassFactory;
	import mx.core.FlexVersion;
	import mx.core.IDataRenderer;
	import mx.core.IFactory;
	import mx.core.UIComponentGlobals;
	import mx.core.mx_internal;
	import mx.events.CalendarLayoutChangeEvent;
	import mx.events.DateChooserEvent;
	import mx.events.DropdownEvent;
	import mx.events.FlexEvent;
	import mx.events.FlexMouseEvent;
	import mx.managers.IFocusManagerComponent;
	import mx.managers.PopUpManager;
	import mx.skins.halo.HaloBorder;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	import mx.styles.StyleProxy;
	import mx.validators.EmailValidator;
	
	use namespace mx_internal;
	
	[Event(name="change", type="mx.events.CalendarLayoutChangeEvent")]
	[Event(name="close", type="mx.events.DropdownEvent")]
	[Event(name="dataChange", type="mx.events.FlexEvent")]
	[Event(name="open", type="mx.events.DropdownEvent")]
	[Event(name="scroll", type="mx.events.DateChooserEvent")]
	
	[Style(name="borderColor", type="uint", format="Color", inherit="no")]
	[Style(name="borderThickness", type="Number", format="Length", inherit="no")]
	[Style(name="cornerRadius", type="Number", format="Length", inherit="no", deprecatedReplacement="dateChooserStyleName", deprecatedSince="3.0")]
	[Style(name="dateChooserStyleName", type="String", inherit="no")]
	[Style(name="fillAlphas", type="Array", arrayType="Number", inherit="no", deprecatedReplacement="nextMonthStyleFilters, prevMonthStyleFilters, dateChooserStyleName", deprecatedSince="3.0")]
	[Style(name="fillColors", type="Array", arrayType="uint", format="Color", inherit="no", deprecatedReplacement="nextMonthStyleFilters, prevMonthStyleFilters, dateChooserStyleName", deprecatedSince="3.0")]
	[Style(name="headerColors", type="Array", arrayType="uint", format="Color", inherit="yes", deprecatedReplacement="dateChooserStyleName", deprecatedSince="3.0")]
	[Style(name="headerStyleName", type="String", inherit="no", deprecatedReplacement="dateChooserStyleName", deprecatedSince="3.0")]
	[Style(name="highlightAlphas", type="Array", arrayType="Number", inherit="no", deprecatedReplacement="dateChooserStyleName", deprecatedSince="3.0")]
	[Style(name="rollOverColor", type="uint", format="Color", inherit="yes")]
	[Style(name="selectionColor", type="uint", format="Color", inherit="yes")]
	[Style(name="skin", type="Class", inherit="no", states=" up, over, down, disabled")]
	[Style(name="todayColor", type="uint", format="Color", inherit="yes")]
	[Style(name="todayStyleName", type="String", inherit="no", deprecatedReplacement="dateChooserStyleName", deprecatedSince="3.0")]
	[Style(name="weekDayStyleName", type="String", inherit="no", deprecatedReplacement="dateChooserStyleName", deprecatedSince="3.0")]
	
	[Exclude(name="selectedIndex", kind="property")]
	[Exclude(name="selectedItem", kind="property")]
	[Exclude(name="borderThickness", kind="style")]
	[Exclude(name="editableUpSkin", kind="style")]
	[Exclude(name="editableOverSkin", kind="style")]
	[Exclude(name="editableDownSkin", kind="style")]
	[Exclude(name="editableDisabledSkin", kind="style")]
	
	[AccessibilityClass(implementation="mx.accessibility.DateFieldAccImpl")]
	
	[DefaultBindingProperty(source="selectedDateTime", destination="selectedDateTime")]
	
	[DefaultTriggerEvent("change")]
	
	[IconFile("icons/DateField.png")]
	
	[RequiresDataBinding(true)]
	
	[ResourceBundle("SharedResources")]
	[ResourceBundle("controls")]
	public class DateTimeField extends ComboBase 
									implements IDataRenderer, IDropInListItemRenderer, 
									IFocusManagerComponent, IListItemRenderer
	{
		internal static var createAccessibilityImplementation:Function;
		
		[Embed(source="icons/DateChooser.png")] 
		private var imgDateChooser:Class;
		
		public static function dateToString(value:Date, outputFormat:String):String
		{
			if(!value)
				return "";
			
			var date:String = String(value.getDate());
			if(date.length < 2)
				date = "0" + date;
			
			var month:String = String(value.getMonth() + 1);
			if(month.length < 2)
				month = "0" + month;
			
			var year:String = String(value.getFullYear());
			
			var output:String = "";
			var mask:String;
			
			var n:int = outputFormat != null ? outputFormat.length : 0;
			for(var i:int = 0; i < n; i++)
			{
				mask = outputFormat.charAt(i);
				
				if(mask == "M")
				{
					output += month;
					i++;
				}
				else if(mask == "D")
				{
					output += date;
					i++;
				}
				else if(mask == "Y")
				{
					if(outputFormat.charAt(i+2) == "Y")
					{
						output += year;
						i += 3;
					}
					else
					{
						output += year.substring(2,4);
						i++;
					}
				}
				else
				{
					output += mask;
				}
			}
			
			return output;
		}
		
		public static function stringToDateTime(valueString:String, inputFormat:String):Date
		{
			var mask:String
			var temp:String;
			var dateString:String = "";
			var monthString:String = "";
			var yearString:String = "";
			var hourString:String = "";
			var minuteString:String = "";
			var secondString:String = "";
			var millisecondString:String = "";
			var j:int = 0;
			
			var n:int = inputFormat.length;
			for(var i:int = 0; i < n; i++,j++)
			{
				temp = "" + valueString.charAt(j);
				mask = "" + inputFormat.charAt(i);
				
				if(mask == "M")
				{
					if (isNaN(Number(temp)) || temp == " ")
						j--;
					else
						monthString += temp;
				}
				else if(mask == "D")
				{
					if (isNaN(Number(temp)) || temp == " ")
						j--;
					else
						dateString += temp;
				}
				else if(mask == "Y")
				{
					yearString += temp;
				}
				else if(mask == "H")
				{
					if (isNaN(Number(temp)) || temp == " ")
						j--;
					else
						hourString += temp;
				}
				else if(mask == "i")
				{
					if (isNaN(Number(temp)) || temp == " ")
						j--;
					else
						minuteString += temp;
				}
				else if(mask == "s")
				{
					if (isNaN(Number(temp)) || temp == " ")
						j--;
					else
						secondString += temp;
				}
				else if(mask == "u")
				{
					if (isNaN(Number(temp)) || temp == " ")
						j--;
					else
						millisecondString += temp;
				}
				else if(!isNaN(Number(temp)) && temp != " ")
				{
					return null;
				}
			}
			
			temp = "" + valueString.charAt(inputFormat.length - i + j);
			if(!(temp == "") && (temp != " "))
				return null;
			
			var monthNum:Number = Number(monthString);
			var dayNum:Number = Number(dateString);
			var yearNum:Number = Number(yearString);
			var hourNum:Number = Number(hourString);
			var minuteNum:Number = Number(minuteString);
			var secondNum:Number = Number(secondString);
			var millisecondNum:Number = Number(millisecondString);
			
			if(isNaN(yearNum) || isNaN(monthNum) || isNaN(dayNum) || isNaN(hourNum) 
				|| isNaN(minuteNum) || isNaN(secondNum) || isNaN(millisecondNum))
				return null;
			
			if(yearString.length == 2 && yearNum < 70)
				yearNum+=2000;
			
			var newDate:Date = new Date(yearNum, monthNum - 1, dayNum, hourNum, 
				minuteNum, secondNum, millisecondNum);
			
			if(dayNum != newDate.getDate() || (monthNum - 1) != newDate.getMonth())
				return null;
			
			return newDate;
		}
    	
		public static function dateTimeToString(value:Date, outputFormat:String):String
		{
			if(!value)
			{
				return "";
			}
			
			var date:String = String(value.getDate());
			if(date.length < 2)
				date = "0" + date;
			
			var month:String = String(value.getMonth() + 1);
			if(month.length < 2)
				month = "0" + month;
			
			var year:String = String(value.getFullYear());
			
			var hour:String = String(value.getHours());
			if(hour.length < 2)
				hour = "0" + hour;
			
			var minute:String = String(value.getMinutes());
			if(minute.length < 2)
				minute = "0" + minute;
			
			var second:String = String(value.getSeconds());
			if(second.length < 2)
				second = "0" + second;
			
			var millisecond:String = String(value.getMilliseconds());
			if(millisecond.length == 2)
			{
				millisecond = "0" + millisecond;
			}
			else if(millisecond.length == 1)
			{
				millisecond = "00" + millisecond;
			}
			
			var output:String = "";
			var mask:String;
			
			var n:int = outputFormat != null ? outputFormat.length : 0;
			for (var i:int = 0; i < n; i++)
			{
				mask = outputFormat.charAt(i);
				
				if(mask == "M")
				{
					output += month;
					i++;
				}
				else if(mask == "D")
				{
					output += date;
					i++;
				}
				else if(mask == "Y")
				{
					if (outputFormat.charAt(i+2) == "Y")
					{
						output += year;
						i += 3;
					}
					else
					{
						output += year.substring(2,4);
						i++;
					}
				}
				else if(mask == "H")
				{
					output += hour;
					i++;
				}
				else if(mask == "i")
				{
					output += minute;
					i++;
				}
				else if(mask == "s")
				{
					output += second;
					i++;
				}
				else if(mask == "u")
				{
					output += millisecond;
					i += 2;
				}
				else
				{
					output += mask;
				}
			}
			
			return output;
		}
		
		public function DateTimeField()
		{
			super();
		}
		
		private var creatingDropdownDateTime:Boolean = false;
		
		internal var showingDropdownDateTime:Boolean = false;
		
		private var inKeyDown:Boolean = false;
		
		private var isPressed:Boolean;
		
		private var openPos:Number = 0;
		
		private var lastSelectedDateTime:Date;
		
		private var updateDateTimeFiller:Boolean = false;
		
		private var addedToPopupManager:Boolean = false;
		
		private var isMouseOver:Boolean = false;
		
		private var yearChangedWithKeys:Boolean = false;
		
		private var selectedDateTimeSet:Boolean;
		
		private var _enabled:Boolean = true;
		
		private var enabledChanged:Boolean = false;
		
		[Bindable("enabledChanged")]
		[Inspectable(category="General", enumeration="true,false", defaultValue="true")]
		
		override public function get enabled():Boolean
		{
			return _enabled;
		}
		
		override public function set enabled(value:Boolean):void
		{
			if(value == _enabled)
				return;
			
			_enabled = value;
			super.enabled = value;
			enabledChanged = true;
			
			invalidateProperties();
		}
		
		private var _data:Object;
		
		[Bindable("dataChange")]
		[Inspectable(environment="none")]		
		
		public function get data():Object
		{
			return _data;
		}
		
		public function set data(value:Object):void
		{
			var newDate:Date;
			
			_data = value;
			
			if (_listData && _listData is DataGridListData)
				newDate = _data[DataGridListData(_listData).dataField];
			else if (_listData is ListData && ListData(_listData).labelField in _data)
				newDate = _data[ListData(_listData).labelField];
			else if (_data is String)
				newDate = new Date(Date.parse(data as String));
			else
				newDate = _data as Date;
			
			if(!selectedDateTimeSet)
			{
				selectedDateTime = newDate;
				selectedDateTimeSet = false;
			}
			
			dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
		}
		
		private var _dayNames:Array;
		
		private var dayNamesChanged:Boolean = false;
		
		private var dayNamesOverride:Array;
		
		[Bindable("dayNamesChanged")]
		[Inspectable(arrayType="String", defaultValue="null")]
		
		public function get dayNames():Array
		{
			return _dayNames;
		}
		
		public function set dayNames(value:Array):void
		{
			dayNamesOverride = value;
			
			_dayNames = value != null ? 
						value : 
						resourceManager.getStringArray(
							"controls", "dayNamesShortest");
			
			_dayNames = (_dayNames) ? _dayNames.slice(0) : null;
			
			dayNamesChanged = true;
			
			invalidateProperties();
		}
		
		private var _disabledDays:Array = [];
		
		private var disabledDaysChanged:Boolean = false;
		
		[Bindable("disabledDaysChanged")]
		[Inspectable(arrayType="int")]
		
		public function get disabledDays():Array
		{
			return _disabledDays;
		}
		
		public function set disabledDays(value:Array):void
		{
			_disabledDays = value;
			disabledDaysChanged = true;
			updateDateTimeFiller = true;
			
			invalidateProperties();
		}
		
		private var _disabledRanges:Array = [];
		
		private var disabledRangesChanged:Boolean = false;
		
		[Bindable("disabledRangesChanged")]
		[Inspectable(arrayType="Object")]
		
		public function get disabledRanges():Array
		{
			return _disabledRanges;
		}
		
		public function set disabledRanges(value:Array):void
		{
			_disabledRanges = scrubTimeValues(value);
			disabledRangesChanged = true;
			updateDateTimeFiller = true;
			
			invalidateProperties();
		}
		
		private var _displayedMonth:int = (new Date()).getMonth();
		
		private var displayedMonthChanged:Boolean = false;
		
		[Bindable("displayedMonthChanged")]
		[Inspectable(category="General")]
		
		public function get displayedMonth():int
		{
			if(dropdownDateTime && dropdownDateTime.displayedMonth != _displayedMonth)
				return dropdownDateTime.displayedMonth;
			else
				return _displayedMonth;
		}
		
		public function set displayedMonth(value:int):void
		{
			_displayedMonth = value;
			displayedMonthChanged = true;
			
			invalidateProperties();
		}
		
		private var _displayedYear:int = (new Date()).getFullYear();
		
		private var displayedYearChanged:Boolean = false;
		
		[Bindable("displayedYearChanged")]
		[Inspectable(category="General")]
		
		public function get displayedYear():int
		{
			if (dropdownDateTime && dropdownDateTime.displayedYear != _displayedYear)
				return dropdownDateTime.displayedYear;
			else
				return _displayedYear;
		}
		
		public function set displayedYear(value:int):void
		{
			_displayedYear = value;
			displayedYearChanged = true;
			
			invalidateProperties();
		}
		
		private var _dropdownDateTime:DateTimeChooser;
		
		public function get dropdownDateTime():DateTimeChooser
		{
			return _dropdownDateTime;
		}
		
		private var _dropdownDateTimeFactory:IFactory = 
			new ClassFactory(DateTimeChooser);
		
		[Bindable("dropdownDateTimeFactoryChanged")]
		
		public function get dropdownFactory():IFactory
		{
			return _dropdownDateTimeFactory;
		}
		
		public function set dropdownFactory(value:IFactory):void
		{
			_dropdownDateTimeFactory = value;
			
			dispatchEvent(new Event("dropdownDateTimeFactoryChanged"));
		}
		
		private var _firstDayOfWeek:Object
		
		private var firstDayOfWeekChanged:Boolean = false;
		
		[Bindable("firstDayOfWeekChanged")]
		[Inspectable(defaultValue="0")]
		
		private var firstDayOfWeekOverride:Object;
		
		public function get firstDayOfWeek():Object
		{
			return _firstDayOfWeek;
		}
		
		public function set firstDayOfWeek(value:Object):void
		{
			firstDayOfWeekOverride = value;
		
			_firstDayOfWeek = value != null ?
								int(value) : 
								resourceManager.getInt(
								"controls", "firstDayOfWeek");
		
			firstDayOfWeekChanged = true;
		
			invalidateProperties();
		}
		
		private var _formatString:String = null;
		
		[Bindable("formatStringChanged")]
		[Inspectable(defaultValue="null")]
		
		private var formatStringOverride:String;
		
		public function get formatString():String
		{
			return _formatString;
		}
		
		public function set formatString(value:String):void
		{
			formatStringOverride = value;
			
			_formatString = value != null ?
							value :
							resourceManager.getString(
							"SharedResources", "dateFormat");
			
			updateDateTimeFiller = true;
			
			invalidateProperties();
			invalidateSize();
			
			dispatchEvent(new Event("formatStringChanged"));
		}
		
		private var _labelFunction:Function;
		
		[Bindable("labelFunctionChanged")]
		[Inspectable(category="Data")]
    	
		public function get labelFunction():Function
		{
			return _labelFunction;
		}
    	
		public function set labelFunction(value:Function):void
		{
			_labelFunction = value;
			updateDateTimeFiller = true;
			
			invalidateProperties();
			
			dispatchEvent(new Event("labelFunctionChanged"));
		}
    
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
		
		private var _maxYear:int = 2100;
		
		private var maxYearChanged:Boolean = false;
		
		public function get maxYear():int
		{
			if(dropdownDateTime)
				return dropdownDateTime.maxYear;
			else
				return _maxYear;
		}
		
		public function set maxYear(value:int):void
		{
			if (_maxYear == value)
				return;
			
			_maxYear = value;
			maxYearChanged = true;
			
			invalidateProperties();
		}
		
		private var _minYear:int = 1900;
		
		private var minYearChanged:Boolean = false;
		
		public function get minYear():int
		{
			if(dropdownDateTime)
				return dropdownDateTime.minYear;
			else
				return _minYear;
		}
		
		public function set minYear(value:int):void
		{
			if (_displayedYear == value)
				return;
			
			_minYear = value;
			minYearChanged = true;
			
			invalidateProperties();
		}
		
		private var _monthNames:Array;
		
		private var monthNamesChanged:Boolean = false;
		
		private var monthNamesOverride:Array;
		
		[Bindable("monthNamesChanged")]
		[Inspectable(category="Other", arrayType="String", defaultValue="null")]
		
		public function get monthNames():Array
		{
			return _monthNames;
		}
		
		public function set monthNames(value:Array):void
		{
			monthNamesOverride = value;
			
			_monthNames = value != null ?
							value :
							resourceManager.getStringArray(
								"SharedResources", "monthNames");
			 
			_monthNames = _monthNames ? _monthNames.slice(0) : null;
			
			monthNamesChanged = true;
			
			invalidateProperties();
		}
		
		private var _monthSymbol:String;
		
		private var monthSymbolChanged:Boolean = false;
		
		private var monthSymbolOverride:String;
		
		[Bindable("monthSymbolChanged")]
		[Inspectable(defaultValue="")]
		
		public function get monthSymbol():String
		{
			return _monthSymbol;
		}
		
		public function set monthSymbol(value:String):void
		{
			monthSymbolOverride = value;
			
			_monthSymbol = value != null ?
							value :
							resourceManager.getString(
								"SharedResources", "monthSymbol");
			
			monthSymbolChanged = true;
			
			invalidateProperties();
		}
		
	    private var _showTime:Boolean = false;
	    
	    public function get showTime():Boolean
	    {
	    	return _showTime;
	    }
	    
	    public function set showTime(value:Boolean):void
	    {
	    	_showTime = value;
	    	
	    	if(_showTime)
	    	{
				formatString = resourceManager.getString("SharedResources", 
					"dateFormat") + " HH:ii:ss";
	    	}
	    	else
	    	{
				formatString = resourceManager.getString("SharedResources", 
					"dateFormat");
	    	}
	    }
	    
		private var _parseFunctionDateTime:Function = DateTimeField.stringToDateTime;
		
		[Bindable("parseFunctionChangedDateTime")]
		
		public function get parseFunctionDateTime():Function
		{
			return _parseFunctionDateTime;
		}
		
		public function set parseFunctionDateTime(value:Function):void
		{
			_parseFunctionDateTime = value;
			
			dispatchEvent(new Event("parseFunctionChangedDateTime"));
		}
		
		private var _selectableRange:Object = null;
		
	    private var selectableRangeChanged:Boolean = false;
	
	    [Bindable("selectableRangeChanged")]
	    [Inspectable(arrayType="Date")]
		
		public function get selectableRange():Object
		{
			return _selectableRange;
		}
		
		public function set selectableRange(value:Object):void
		{
			_selectableRange = scrubTimeValue(value);
			selectableRangeChanged = true;
			updateDateTimeFiller = true;
			
			invalidateProperties();
		}
		
		private var _selectedDateTime:Date = null;
		
		private var selectedDateTimeChanged:Boolean = false;
		
		[Bindable("change")]
		[Bindable("valueCommit")]
		[Inspectable(category="General")]
		
		public function get selectedDateTime():Date
		{
			return _selectedDateTime;
		}
		
		public function set selectedDateTime(value:Date):void
		{
			selectedDateTimeSet = true;
			_selectedDateTime = value;
			updateDateTimeFiller = true;
			selectedDateTimeChanged = true;
			
			invalidateProperties();
		}
		
		private var _showToday:Boolean = true;
		
		private var showTodayChanged:Boolean = false;
		
		[Bindable("showTodayChanged")]
		[Inspectable(category="General", defaultValue="true")]
		
		public function get showToday():Boolean
		{
			return _showToday;
		}
		
		public function set showToday(value:Boolean):void
		{
			_showToday = value;
			showTodayChanged = true;
			
			invalidateProperties();
		}
		
		private var _yearNavigationEnabled:Boolean = false;
		
		private var yearNavigationEnabledChanged:Boolean = false;
		
		[Bindable("yearNavigationEnabledChanged")]
		[Inspectable(defaultValue="false")]
		
		public function get yearNavigationEnabled():Boolean
		{
			return _yearNavigationEnabled;
		}
		
		public function set yearNavigationEnabled(value:Boolean):void
		{
			_yearNavigationEnabled = value;
			yearNavigationEnabledChanged = true;
		
			invalidateProperties();
		}
		
		private var _yearSymbol:String;
		
		private var yearSymbolChanged:Boolean = false;
		
		private var yearSymbolOverride:String;
		
		[Bindable("yearSymbolChanged")]
		[Inspectable(defaultValue="")]
		
		public function get yearSymbol():String
		{
			return _yearSymbol;
		}
		
		public function set yearSymbol(value:String):void
		{
			yearSymbolOverride = value;
			
			_yearSymbol = value != null ?
							value :
							resourceManager.getString(
								"controls", "yearSymbol");
			
			yearSymbolChanged = true;
			
			invalidateProperties();
		}
		
		override protected function initializeAccessibility():void
		{
			if(DateTimeField.createAccessibilityImplementation != null)
				DateTimeField.createAccessibilityImplementation(this);
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			createDateTimeDropdown();
			
			downArrowButton.setStyle("paddingLeft", 0);
			downArrowButton.setStyle("paddingRight", 0);
			downArrowButton.setStyle("skin", imgDateChooser);
			textInput.editable = false;
			textInput.addEventListener(TextEvent.TEXT_INPUT, textInput_textInputHandler);
			
			HaloBorder(getChildAt(0)).visible = false
		}
		
	    override protected function commitProperties():void
	    {
			if(enabledChanged)
			{
				enabledChanged = false;
				dispatchEvent(new Event("enabledChanged"));
			}
			
			if(dayNamesChanged)
			{
				dayNamesChanged = false;
				
				dropdownDateTime.dayNames = _dayNames ? _dayNames.slice(0) : null;
				dispatchEvent(new Event("dayNamesChanged"));
			}
			
			if(disabledDaysChanged)
			{
				disabledDaysChanged = false;
				dropdownDateTime.disabledDays = _disabledDays.slice(0);
				dispatchEvent(new Event("disabledDaysChanged"));
			}
			
			if(disabledRangesChanged)
			{
				disabledRangesChanged = false;
				dropdownDateTime.disabledRanges = _disabledRanges.slice(0);
				dispatchEvent(new Event("disabledRangesChanged"));
			}
			
			if(displayedMonthChanged)
			{
				displayedMonthChanged = false;
				dropdownDateTime.displayedMonth = _displayedMonth;
				dispatchEvent(new Event("displayedMonthChanged"));
			}
			
			if(displayedYearChanged)
			{
				displayedYearChanged = false;
				dropdownDateTime.displayedYear = _displayedYear;
				dispatchEvent(new Event("displayedYearChanged"));
			}
			
			if(firstDayOfWeekChanged)
			{
				firstDayOfWeekChanged = false;
				dropdownDateTime.firstDayOfWeek = _firstDayOfWeek;
				dispatchEvent(new Event("firstDayOfWeekChanged"));
			}
			
			if(minYearChanged)
			{
				minYearChanged = false;
				dropdownDateTime.minYear = _minYear;
			}
			
			if(maxYearChanged)
			{
				maxYearChanged = false;
				dropdownDateTime.maxYear = _maxYear;
			}

			if(monthNamesChanged)
			{
				monthNamesChanged = false;
				dropdownDateTime.monthNames = _monthNames ? _monthNames.slice(0) : 
					null;
				dispatchEvent(new Event("monthNamesChanged"));
			}
			
			if(selectableRangeChanged)
			{
				selectableRangeChanged = false;
				dropdownDateTime.selectableRange = _selectableRange is Array ? 
					_selectableRange.slice(0) : _selectableRange;
				dispatchEvent(new Event("selectableRangeChanged"));
			}
			
			if(selectedDateTimeChanged)
			{
				selectedDateTimeChanged = false;
				dropdownDateTime.selectedDateTime = _selectedDateTime;
				dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
			}
			
			if(showTodayChanged)
			{
				showTodayChanged = false;
				dropdownDateTime.showToday = _showToday;
				dispatchEvent(new Event("showTodayChanged"));
			}

			if(updateDateTimeFiller)
			{
				updateDateTimeFiller = false;
				dateTimeFiller(_selectedDateTime);
			}

			if(yearNavigationEnabledChanged)
			{
				yearNavigationEnabledChanged = false;
				dropdownDateTime.yearNavigationEnabled = _yearNavigationEnabled;
				dispatchEvent(new Event("yearNavigationEnabledChanged"));
			}
			
			if(yearSymbolChanged)
			{
				yearSymbolChanged = false;
				dropdownDateTime.yearSymbol = _yearSymbol;
				dispatchEvent(new Event("yearSymbolChanged"));
			}
			
			if (monthSymbolChanged)
			{
				monthSymbolChanged = false;
				dropdownDateTime.monthSymbol = _monthSymbol;
				dispatchEvent(new Event("monthSymbolChanged"));
			}
			
			super.commitProperties();
		}
		
		override protected function measure():void
		{
			var buttonWidth:Number = downArrowButton.getExplicitOrMeasuredWidth();
			var buttonHeight:Number = downArrowButton.getExplicitOrMeasuredHeight();
			
			var bigDate:Date = new Date(2008, 08, 08, 08, 08, 08, 000);
			var txt:String;
			
			if(showTime)
			{
				txt = (_labelFunction != null) ? 
					_labelFunction(bigDate) : 
					dateTimeToString(bigDate, formatString);
			}
			else
			{
				txt = (_labelFunction != null) ? 
					_labelFunction(bigDate) : 
					dateToString(bigDate, formatString);
			}
			
			measuredMinWidth = measuredWidth = measureText(txt).width + 8 + 2 + buttonWidth;
			if (FlexVersion.compatibilityVersion >= FlexVersion.VERSION_3_0)
				measuredMinWidth = measuredWidth += getStyle("paddingLeft") + getStyle("paddingRight");
			measuredMinHeight = measuredHeight = textInput.getExplicitOrMeasuredHeight();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number,
			unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var w:Number = unscaledWidth;
			var h:Number = unscaledHeight;
			
			var arrowWidth:Number = Button(getChildAt(1)).getExplicitOrMeasuredWidth();
			var arrowHeight:Number = Button(getChildAt(1)).getExplicitOrMeasuredHeight();
			
			downArrowButton.setActualSize(arrowWidth, arrowHeight);
			downArrowButton.move(w - arrowWidth, Math.round((h - arrowHeight) / 2));
			
			textInput.setActualSize(w - arrowWidth - 2, h);
		}
		
		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);
			
			if(dropdownDateTime)
				dropdownDateTime.styleChanged(styleProp);
			
			if(styleProp == null || styleProp == "styleName" ||
				styleProp == "dateChooserStyleName")
			{
				if(dropdownDateTime)
				{
					var dateChooserStyleName:String = getStyle(
						"dateChooserStyleName");
					
					if(dateChooserStyleName)
					{
						var styleDecl:CSSStyleDeclaration =
							StyleManager.getStyleDeclaration("." + dateChooserStyleName);
						
						if(styleDecl)
						{
							_dropdownDateTime.styleDeclaration = styleDecl;
							_dropdownDateTime.regenerateStyleCache(true);
						}
					}
				} 
			}
		}
		
		override public function notifyStyleChangeInChildren(
			styleProp:String, recursive:Boolean):void
		{
			super.notifyStyleChangeInChildren(styleProp, recursive);
			
			if(dropdownDateTime)
				dropdownDateTime.notifyStyleChangeInChildren(styleProp, recursive);
		}
		
		override public function regenerateStyleCache(recursive:Boolean):void
		{
			super.regenerateStyleCache(recursive);
			
			if(dropdownDateTime)
				dropdownDateTime.regenerateStyleCache(recursive);
		}
		
		override protected function resourcesChanged():void
		{
			super.resourcesChanged();
			
			dayNames = dayNamesOverride;
			firstDayOfWeek = firstDayOfWeekOverride;
			formatString = formatStringOverride;
			monthNames = monthNamesOverride;
			monthSymbol = monthSymbolOverride;
			yearSymbol = yearSymbolOverride;
		}
		
		public function open():void
		{
			displayDropdown(true);
		}
		
		public function close():void
		{
			displayDropdown(false);
		}
		
		private function displayDropdown(show:Boolean, triggerEvent:Event = null):void
		{
			if(!_enabled)
				return;
			
			if(show == showingDropdownDateTime)
				return;
			
			if(!addedToPopupManager)
			{
				addedToPopupManager = true;
				PopUpManager.addPopUp(_dropdownDateTime, this, false);
			}
			else
				PopUpManager.bringToFront(_dropdownDateTime);
			
			var point:Point = new Point(unscaledWidth - downArrowButton.width,0);
			point = localToGlobal(point);
			if(show)
			{
				if (_parseFunctionDateTime != null)
					_selectedDateTime = _parseFunctionDateTime(text, formatString);
				lastSelectedDateTime = _selectedDateTime;
				selectedDateTime_changeHandler(triggerEvent);
					
				var dd:DateTimeChooser = dropdownDateTime;
		
				if(_dropdownDateTime.selectedDateTime)
				{
					_dropdownDateTime.displayedMonth = 
						_dropdownDateTime.selectedDateTime.getMonth();
					_dropdownDateTime.displayedYear = 
						_dropdownDateTime.selectedDateTime.getFullYear();
				}
				
				_dropdownDateTime.timeStepper.timeField.setFocus();
				
				point = dd.parent.globalToLocal(point);
				dd.visible = show;
				dd.scaleX = scaleX;
				dd.scaleY = scaleY;
		
				var xVal:Number = point.x;
				var yVal:Number = point.y;
				
				var screen:Rectangle = systemManager.screen;
				
				if(screen.width > dd.getExplicitOrMeasuredWidth() + point.x &&
					screen.height < dd.getExplicitOrMeasuredHeight() + point.y)
				{
					xVal = point.x
					yVal = point.y - dd.getExplicitOrMeasuredHeight();
					openPos = 1;
				}
				else if(screen.width < dd.getExplicitOrMeasuredWidth() + point.x &&
					screen.height < dd.getExplicitOrMeasuredHeight() + point.y)
				{
					xVal = point.x - dd.getExplicitOrMeasuredWidth() + downArrowButton.width;
					yVal = point.y - dd.getExplicitOrMeasuredHeight();
					openPos = 2;
				}
				else if (screen.width < dd.getExplicitOrMeasuredWidth() + point.x &&
					screen.height > dd.getExplicitOrMeasuredHeight() + point.y)
				{
					xVal = point.x - dd.getExplicitOrMeasuredWidth() + downArrowButton.width;
					yVal = point.y + unscaledHeight;
					openPos = 3;
				}
				else
					openPos = 0;
				
				UIComponentGlobals.layoutManager.validateClient(dd, true);
				dd.move(xVal, yVal);
				Object(dd).setActualSize(dd.getExplicitOrMeasuredWidth(),dd.getExplicitOrMeasuredHeight());
			}
			else
			{
				_dropdownDateTime.visible = false;
			}
			
			showingDropdownDateTime = show;
			
			var event:DropdownEvent =
				new DropdownEvent(show ? DropdownEvent.OPEN : DropdownEvent.CLOSE);
			event.triggerEvent = triggerEvent;
			dispatchEvent(event);
		}
		
		private function createDateTimeDropdown():void
		{
			if(creatingDropdownDateTime)
				return;
			
			creatingDropdownDateTime = true;
			
			_dropdownDateTime = dropdownFactory.newInstance();
			_dropdownDateTime.focusEnabled = false;
			_dropdownDateTime.owner = this;
			_dropdownDateTime.moduleFactory = moduleFactory;
			var todaysDate:Date = new Date();
			_dropdownDateTime.displayedMonth = todaysDate.getMonth();
			_dropdownDateTime.displayedYear = todaysDate.getFullYear();
			
			if(FlexVersion.compatibilityVersion < FlexVersion.VERSION_3_0)
				_dropdownDateTime.styleName = this;
			else
				_dropdownDateTime.styleName = new StyleProxy(this, {}); 
			
			var dateChooserStyleName:Object = getStyle("dateChooserStyleName");
			if(dateChooserStyleName)
			{
				var styleDecl:CSSStyleDeclaration =
					StyleManager.getStyleDeclaration("." + dateChooserStyleName);
				
				if (styleDecl)
					_dropdownDateTime.styleDeclaration = styleDecl;
			}
			
			_dropdownDateTime.visible = false;
			
			_dropdownDateTime.addEventListener(CalendarLayoutChangeEvent.CHANGE, 
				dropdownDateTime_changeHandler);
			_dropdownDateTime.addEventListener(DateChooserEvent.SCROLL, 
				dropdownDateTime_scrollHandler);
			_dropdownDateTime.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, 
				dropdownDateTime_mouseDownOutsideHandler);
			_dropdownDateTime.addEventListener(FlexMouseEvent.MOUSE_WHEEL_OUTSIDE, 
				dropdownDateTime_mouseDownOutsideHandler);
			
			creatingDropdownDateTime = false;
		}
		
		private function dateTimeFiller(value:Date):void
		{
			if(_labelFunction != null)
			{
				textInput.text = labelFunction(value);
			}
			else
			{
				if(showTime)
					textInput.text = dateTimeToString(value, formatString);
				else
					textInput.text = dateToString(value, formatString);
			}
		}
		
		private function scrubTimeValue(value:Object):Object
		{
			if(value is Date)
			{
				return new Date(value.getFullYear(), value.getMonth(), value.getDate());
			}
			else if(value is Object) 
			{
				var range:Object = {};
				if(value.rangeStart)
				{
					range.rangeStart = new Date(value.rangeStart.getFullYear(), 
						value.rangeStart.getMonth(), value.rangeStart.getDate());
				}
				
				if(value.rangeEnd)
				{
					range.rangeEnd = new Date(value.rangeEnd.getFullYear(), 
						value.rangeEnd.getMonth(), value.rangeEnd.getDate());
				}
				return range;
			}
			return null;
		}
 
		private function scrubTimeValues(values:Array):Array
		{
			var dates:Array = [];
			for(var i:int = 0; i < values.length; i++)
			{
				dates[i] = scrubTimeValue(values[i]);
			}
			return dates;
		}
		
		override protected function focusOutHandler(event:FocusEvent):void
		{
			if(showingDropdownDateTime && event != null)
				displayDropdown(false);
			
			super.focusOutHandler(event);
			
			if(_parseFunctionDateTime != null)
				_selectedDateTime = _parseFunctionDateTime(text, formatString);
			
			selectedDateTime_changeHandler(event);
		}
		
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			if(event.ctrlKey && event.keyCode == Keyboard.DOWN)
			{
				displayDropdown(true, event);
				event.stopPropagation();
			}
			else if(event.ctrlKey && event.keyCode == Keyboard.UP)
			{
				if(showingDropdownDateTime)
					selectedDateTime = lastSelectedDateTime;
				displayDropdown(false, event);
				event.stopPropagation();
			}
			else if(event.keyCode == Keyboard.ESCAPE)
			{
				if(showingDropdownDateTime)
					selectedDateTime = lastSelectedDateTime;
				displayDropdown(false, event);
				event.stopPropagation();
			}
			else if(event.keyCode == Keyboard.ENTER)
			{
				if(showingDropdownDateTime)
				{
					_selectedDateTime = _dropdownDateTime.selectedDateTime;
					displayDropdown(false, event);
					event.stopPropagation();
				}
				else if(editable)
				{
					if(_parseFunctionDateTime != null)
		    			_selectedDateTime = _parseFunctionDateTime(text, formatString);
				}
				selectedDateTime_changeHandler(event);
			}
			else if(event.keyCode == Keyboard.UP || 
				event.keyCode == Keyboard.DOWN || 
				event.keyCode == Keyboard.LEFT || 
				event.keyCode == Keyboard.RIGHT || 
				event.keyCode == Keyboard.PAGE_UP || 
				event.keyCode == Keyboard.PAGE_DOWN || 
				event.keyCode == 189 || 
				event.keyCode == 187 || 
				event.keyCode == Keyboard.HOME || 
				event.keyCode == Keyboard.END)
			{
				if(showingDropdownDateTime)
				{
					if(yearNavigationEnabled &&
		    			(event.keyCode == 189 || event.keyCode == 187)) 
		    			yearChangedWithKeys = true;
					inKeyDown = true;
					
					dropdownDateTime.dispatchEvent(event);
					inKeyDown = false;
					
					event.stopPropagation();
				}
			}
		}
		
		override protected function downArrowButton_buttonDownHandler(
			event:FlexEvent):void
		{
			callLater(displayDropdown, [!showingDropdownDateTime, event ]);
			
			downArrowButton.phase = "up";
		}
		
		override protected function textInput_changeHandler(event:Event):void
		{
			super.textInput_changeHandler(event);
			
			var inputDate:Date = _parseFunctionDateTime(text, formatString);
			if(inputDate)
				_selectedDateTime = inputDate;
		}
		
		private function dropdownDateTime_changeHandler(
			event:CalendarLayoutChangeEvent):void
		{
			_selectedDateTime = dropdownDateTime.selectedDateTime;
			
			if(!inKeyDown)
				displayDropdown(false);
			
			if (_selectedDateTime)
				dateTimeFiller(_selectedDateTime);
			else
				textInput.text = "";
			
			var e:CalendarLayoutChangeEvent = new 
				CalendarLayoutChangeEvent(CalendarLayoutChangeEvent.CHANGE);
			e.newDate = event.newDate;
			e.triggerEvent = event.triggerEvent;
			dispatchEvent(e);                   
		}
		
		private function dropdownDateTime_scrollHandler(event:DateChooserEvent):void
		{
			dispatchEvent(event);
		}
		
		private function dropdownDateTime_mouseDownOutsideHandler(event:MouseEvent):void
		{
			if(!hitTestPoint(event.stageX, event.stageY, true))
				displayDropdown(false, event);
		}
		
		private function selectedDateTime_changeHandler(triggerEvent:Event):void
		{
			if(!dropdownDateTime.selectedDateTime && !_selectedDateTime)
				return;
			
			if(_selectedDateTime)
				dateTimeFiller(_selectedDateTime);
			
			if(dropdownDateTime.selectedDateTime && _selectedDateTime &&
				dropdownDateTime.selectedDateTime.getFullYear() == _selectedDateTime.getFullYear() &&
				dropdownDateTime.selectedDateTime.getMonth() == _selectedDateTime.getMonth() &&
				dropdownDateTime.selectedDateTime.getDate() == _selectedDateTime.getDate())
				return;
			
			dropdownDateTime.selectedDateTime = _selectedDateTime;
			
			var changeEvent:CalendarLayoutChangeEvent =
				new CalendarLayoutChangeEvent(CalendarLayoutChangeEvent.CHANGE);
			changeEvent.newDate = _selectedDateTime;
			changeEvent.triggerEvent = triggerEvent;
			dispatchEvent(changeEvent);
		}
		
		private function textInput_textInputHandler(event:TextEvent):void
		{
			if(yearChangedWithKeys)
			{
				event.preventDefault();
				yearChangedWithKeys = false;
			}
		}
		
		internal function isShowingDropdown():Boolean
		{
			return showingDropdownDateTime;
		}
	}
}