# OpenFL click group
OpenFL only dispatches click events (`CLICK`, `MIDDLE_CLICK`, `RIGHT_CLICK`, and `TOUCH_TAP`) when you press and release over the same target. If you drag to a new target, it declines to dispatch the event.

`ClickGroup` makes OpenFL treat a set of objects as a single target. You'll receive a click event as long as you press and release over objects in the same group.

## Usage

This is particularly useful for dropdown menus like Feathers' `PopUpListView`. Normally, the user has to click twice, once to open the menu and once to pick an option. With a `ClickGroup`, the user can instead press to open the menu, drag, and release to pick an option.

```haxe
import com.player03.clickgroup.ClickGroup;
import feathers.controls.PopUpListView;

class GroupPopUpListView extends PopUpListView {
    private var clickGroup:ClickGroup;
    
    public function new(?dataProvider:IFlatCollection<Dynamic>) {
        super(dataProvider);
        
        //Group this and all children.
        clickGroup = new ClickGroup(this);
    }
    
    private override function createListView() {
        super.createListView();
        
        //`listView` is not a child, so must be added manually.
        clickGroup.add(listView);
    }
}
```

Since `PopUpListView` doesn't expect this mode of interaction, dragging over list items won't highlight them. You can fix this by listening for a `TargetChangeEvent`.

```haxe
clickGroup.addTargetChangeEventListener(
    function(event:TargetChangeEvent):Void {
        //`event.oldTarget` refers to the old object, and in other situations we
        //might want to update it. Here, it'll take care of itself.
        
        //`event.newTarget` is typically the child of a `ToggleButton`.
        if(event.newTarget != null
            && Std.isOfType(event.newTarget.parent, ToggleButton)) {
            var button:ToggleButton = cast event.newTarget.parent;
            
            //At the moment, updating the button requires `@:privateAccess`.
            if(!button.selected) {
                @:privateAccess button.changeState(DOWN(false));
            }
        }
    }
);
```

You can add objects to the group temporarily. These will be removed if they leave the stage.

```haxe
clickGroup.addTemporary(tempGroupMember);
```

Or you can remove objects manually.

```haxe
private override function createListView() {
    if(listView != null) {
        //Ungroup the old one before making a new one.
        clickGroup.remove(listView);
    }
    
    super.createListView();
    
    clickGroup.add(listView);
}
```
