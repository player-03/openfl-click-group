package com.player03.clickgroup;

import com.player03.clickgroup.ClickEventInfo;
import openfl.display.InteractiveObject;
import openfl.display.Stage;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.EventType;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;

/**
 * OpenFL only dispatches click events (`CLICK`, `MIDDLE_CLICK`, `RIGHT_CLICK`,
 * and `TOUCH_TAP`) when you press and release over the same target. If you drag
 * to a new target, it declines to dispatch the event.
 * 
 * `ClickGroup` makes OpenFL treat a set of objects as a single target. You'll
 * receive a click event as long as you press and release over objects in the
 * same group.
 * 
 * This is particularly useful for dropdown menus like Feathers'
 * `PopUpListView`. Normally, the user has to click twice, once to open the menu
 * and once to pick an option. With a `ClickGroup`, the user can instead press
 * to open the menu, drag, and release to pick an option.
 */
class ClickGroup {
	private var members:Array<InteractiveObject> = [];
	
	private var info:Array<EventInfoWrapper>;
	private var status:ClickStatus = new ClickStatus();
	
	public function new(...objects:InteractiveObject) {
		info = [
			new EventInfoWrapper(status, cast new LeftClickEventInfo()),
			new EventInfoWrapper(status, cast new MiddleClickEventInfo()),
			new EventInfoWrapper(status, cast new RightClickEventInfo()),
			new EventInfoWrapper(status, cast new TouchEventInfo())
		];
		
		for(object in objects) {
			add(object);
		}
	}
	
	/**
	 * Adds the given object to the group, implicitly including its children.
	 */
	public function add(object:InteractiveObject):Void {
		members.push(object);
		
		for(infoWrapper in info) {
			infoWrapper.add(object);
		}
	}
	
	/**
	 * Temporarily adds the given object to the group, for as long as it remains
	 * on the stage.
	 */
	public function addTemporary(object:InteractiveObject):Void {
		add(object);
		
		object.addEventListener(Event.REMOVED_FROM_STAGE, removeTarget);
	}
	
	public inline function has(object:InteractiveObject):Bool {
		return members.indexOf(object) >= 0;
	}
	
	private function removeTarget(e:Event):Void {
		remove(e.target);
	}
	
	public function remove(object:InteractiveObject):Void {
		members.remove(object);
		
		for(infoWrapper in info) {
			infoWrapper.remove(object);
		}
		
		object.removeEventListener(Event.REMOVED_FROM_STAGE, removeTarget);
	}
	
	/**
	 * Listens for when the pointer is dragged over a new object.
	 */
	public inline function addTargetChangeEventListener(listener:TargetChangeEvent -> Void, ?useCapture:Bool = false, ?priority:Int = 0, ?useWeakReference:Bool = false):Void {
		status.addEventListener(TargetChangeEvent.TARGET_CHANGE, listener, useCapture, priority, useWeakReference);
	}
	
	public inline function removeTargetChangeEventListener(listener:TargetChangeEvent -> Void, ?useCapture:Bool = false):Void {
		status.removeEventListener(TargetChangeEvent.TARGET_CHANGE, listener, useCapture);
	}
	
	@:noCompletion public inline function iterator():Iterator<InteractiveObject> {
		return members.iterator();
	}
}

/**
 * Tracks the status of each type of click event.
 * 
 * Dispatches `TargetChangeEvent.TARGET_CHANGE`.
 */
@:allow(com.player03.clickgroup.ClickEventInfo)
class ClickStatus extends EventDispatcher {
	private var mouseDownLeft:InteractiveObject = null;
	private var mouseDownMiddle:InteractiveObject = null;
	private var mouseDownRight:InteractiveObject = null;
	private var touchTargets:Array<InteractiveObject> = [];
	
	public inline function new() {
		super();
	}
}

private class EventInfoWrapper {
	private var status:ClickStatus;
	private var info:ClickEventInfo<Event>;
	
	public function new(status:ClickStatus, info:ClickEventInfo<Event>) {
		this.status = status;
		this.info = info;
	}
	
	public function add(object:InteractiveObject):Void {
		object.addEventListener(info.downEvent, onPointerDown);
		object.addEventListener(info.overEvent, onPointerOver);
		object.addEventListener(info.outEvent, onPointerOut);
		object.addEventListener(info.upEvent, onPointerUp);
	}
	
	public function remove(object:InteractiveObject):Void {
		object.removeEventListener(info.downEvent, onPointerDown);
		object.removeEventListener(info.overEvent, onPointerOver);
		object.removeEventListener(info.outEvent, onPointerOut);
		object.removeEventListener(info.upEvent, onPointerUp);
	}
	
	public function onPointerDown(e:Event):Void {
		info.setValue(status, e, e.target);
	}
	
	public function onPointerOver(e:Event):Void {
		var stage:Stage = e.target.stage;
		if(stage != null) {
			var oldTarget:InteractiveObject = info.getValue(status, e);
			if(oldTarget == null) {
				return;
			}
			
			//Update the stage's stored value, but only if it matches the one we
			//have on record.
			if(oldTarget == info.getStageValue(stage, e)) {
				info.setValue(status, e, e.target);
				info.setStageValue(stage, e, e.target);
				
				status.dispatchEvent(new TargetChangeEvent(e, oldTarget, e.target, info));
			} else {
				//If not, the pointer was most likely released outside.
				info.setValue(status, e, null);
			}
		}
	}
	
	public function onPointerOut(e:Event):Void {
		var stage:Stage = e.target.stage;
		if(stage != null) {
			var oldTarget:InteractiveObject = info.getValue(status, e);
			if(oldTarget != null && oldTarget == info.getStageValue(stage, e)) {
				status.dispatchEvent(new TargetChangeEvent(e, oldTarget, null, info));
			}
		}
	}
	
	public function onPointerUp(e:Event):Void {
		info.setValue(status, e, null);
	}
}

class TargetChangeEvent extends Event {
	/**
	 * Dispatched when the pointer is dragged over a new object.
	 */
	public static inline var TARGET_CHANGE:EventType<TargetChangeEvent> = "clickTargetChange";
	
	/**
	 * The `MOUSE_OVER`, `ROLL_OUT`, `TOUCH_OVER`, or `TOUCH_ROLL_OUT` event
	 * that triggered this one.
	 */
	public var sourceEvent:Event;
	
	/**
	 * The object that previously would have received the click event. `null`
	 * for any object outside the `ClickGroup`.
	 */
	public var oldTarget:Null<InteractiveObject>;
	
	/**
	 * The object that will receive the click event if the pointer releases now.
	 * `null` for any object outside the `ClickGroup`.
	 */
	public var newTarget:Null<InteractiveObject>;
	
	/**
	 * Information about the click event.
	 */
	public var eventInfo:ClickEventInfo<Event>;
	
	public function new(sourceEvent:Event, oldTarget:Null<InteractiveObject>, newTarget:Null<InteractiveObject>, eventInfo:ClickEventInfo<Event>) {
		super(TARGET_CHANGE);
		
		this.sourceEvent = sourceEvent;
		this.oldTarget = oldTarget;
		this.newTarget = newTarget;
		this.eventInfo = eventInfo;
	}
}
