package com.player03.clickgroup;

import com.player03.clickgroup.ClickGroup;
import openfl.display.InteractiveObject;
import openfl.display.Stage;
import openfl.events.Event;
import openfl.events.EventType;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;

/**
 * Information about a single type of click event, for internal use.
 */
@:allow(com.player03.clickgroup.EventInfoWrapper)
class ClickEventInfo<T:Event> {
	/**
	 * The click event everything else corresponds to.
	 */
	public var clickEvent(default, null):EventType<T>;
	
	/**
	 * The mouse down or `TOUCH_BEGIN` event corresponding to `clickEvent`.
	 */
	public var downEvent(default, null):EventType<T>;
	
	/**
	 * Either `MOUSE_OVER` or `TOUCH_OVER`, as appropriate. These events are
	 * dispatched when the mouse moves between children of a display object.
	 */
	public var overEvent(default, null):EventType<T>;
	
	/**
	 * Either `ROLL_OUT` or `TOUCH_ROLL_OUT`, as appropriate. These events are
	 * dispatched when the mouse leaves a display object entirely (and an
	 * `overEvent` would not be dispatched).
	 */
	public var outEvent(default, null):EventType<T>;
	
	/**
	 * The mouse up or `TOUCH_END` event corresponding to `clickEvent`.
	 */
	public var upEvent(default, null):EventType<T>;
	
	private function new(clickEvent:EventType<T>, downEvent:EventType<T>, overEvent:EventType<T>, outEvent:EventType<T>, upEvent:EventType<T>) {
		this.clickEvent = clickEvent;
		this.downEvent = downEvent;
		this.overEvent = overEvent;
		this.outEvent = outEvent;
		this.upEvent = upEvent;
	}
	private function getValue(status:ClickStatus, event:T):InteractiveObject {
		return null;
	}
	private function setValue(status:ClickStatus, event:T, value:InteractiveObject):InteractiveObject {
		return null;
	}
	private function getStageValue(stage:Stage, event:T):InteractiveObject {
		return null;
	}
	private function setStageValue(stage:Stage, event:T, value:InteractiveObject):InteractiveObject {
		return null;
	}
}

class MouseClickEventInfo extends ClickEventInfo<MouseEvent> {
	private function new(clickEvent:EventType<MouseEvent>, downEvent:EventType<MouseEvent>, upEvent:EventType<MouseEvent>) {
		super(clickEvent, downEvent, MouseEvent.MOUSE_OVER, MouseEvent.ROLL_OUT, upEvent);
	}
}

@:allow(com.player03.clickgroup.ClickEventInfo)
@:access(openfl.display.Stage)
class LeftClickEventInfo extends MouseClickEventInfo {
	public function new() {
		super(MouseEvent.CLICK, MouseEvent.MOUSE_DOWN, MouseEvent.MOUSE_UP);
	}
	
	private override function getValue(status:ClickStatus, event:MouseEvent):InteractiveObject {
		return status.mouseDownLeft;
	}
	private override function setValue(status:ClickStatus, event:MouseEvent, value:InteractiveObject):InteractiveObject {
		return status.mouseDownLeft = value;
	}
	private override function getStageValue(stage:Stage, event:MouseEvent):InteractiveObject {
		return stage.__mouseDownLeft;
	}
	private override function setStageValue(stage:Stage, event:MouseEvent, value:InteractiveObject):InteractiveObject {
		return stage.__mouseDownLeft = value;
	}
}

@:allow(com.player03.clickgroup.ClickEventInfo)
@:access(openfl.display.Stage)
class MiddleClickEventInfo extends MouseClickEventInfo {
	public function new() {
		super(MouseEvent.MIDDLE_CLICK, MouseEvent.MIDDLE_MOUSE_DOWN, MouseEvent.MIDDLE_MOUSE_UP);
	}
	
	private override function getValue(status:ClickStatus, event:MouseEvent):InteractiveObject {
		return status.mouseDownMiddle;
	}
	private override function setValue(status:ClickStatus, event:MouseEvent, value:InteractiveObject):InteractiveObject {
		return status.mouseDownMiddle = value;
	}
	private override function getStageValue(stage:Stage, event:MouseEvent):InteractiveObject {
		return stage.__mouseDownMiddle;
	}
	private override function setStageValue(stage:Stage, event:MouseEvent, value:InteractiveObject):InteractiveObject {
		return stage.__mouseDownMiddle = value;
	}
}

@:allow(com.player03.clickgroup.ClickEventInfo)
@:access(openfl.display.Stage)
class RightClickEventInfo extends MouseClickEventInfo {
	public function new() {
		super(MouseEvent.RIGHT_CLICK, MouseEvent.RIGHT_MOUSE_DOWN, MouseEvent.RIGHT_MOUSE_UP);
	}
	
	private override function getValue(status:ClickStatus, event:MouseEvent):InteractiveObject {
		return status.mouseDownRight;
	}
	private override function setValue(status:ClickStatus, event:MouseEvent, value:InteractiveObject):InteractiveObject {
		return status.mouseDownRight = value;
	}
	private override function getStageValue(stage:Stage, event:MouseEvent):InteractiveObject {
		return stage.__mouseDownRight;
	}
	private override function setStageValue(stage:Stage, event:MouseEvent, value:InteractiveObject):InteractiveObject {
		return stage.__mouseDownRight = value;
	}
}

@:allow(com.player03.clickgroup.ClickEventInfo)
@:access(openfl.display.Stage)
class TouchEventInfo extends ClickEventInfo<TouchEvent> {
	public function new() {
		super(TouchEvent.TOUCH_TAP, TouchEvent.TOUCH_BEGIN, TouchEvent.TOUCH_OVER, TouchEvent.TOUCH_ROLL_OUT, TouchEvent.TOUCH_END);
	}
	
	private override function getValue(status:ClickStatus, event:TouchEvent):InteractiveObject {
		return status.touchTargets[event.touchPointID];
	}
	private override function setValue(status:ClickStatus, event:TouchEvent, value:InteractiveObject):InteractiveObject {
		return status.touchTargets[event.touchPointID] = value;
	}
	private override function getStageValue(stage:Stage, event:TouchEvent):InteractiveObject {
		return stage.__touchData[event.touchPointID].touchDownTarget;
	}
	private override function setStageValue(stage:Stage, event:TouchEvent, value:InteractiveObject):InteractiveObject {
		return stage.__touchData[event.touchPointID].touchDownTarget = value;
	}
}
