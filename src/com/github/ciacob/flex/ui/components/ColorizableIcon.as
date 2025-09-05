package com.github.ciacob.flex.ui.components {
    import com.github.ciacob.flex.ui.ColorUtils;
    import flash.events.Event;
    import spark.components.Group;
    import spark.core.SpriteVisualElement;

    // ---- Styles ---------------------------------------------------------

    /** Optional tweak, default 1.0. Allows partial tinting. */
    [Style(name = "tintStrength", type = "Number", inherit = "no")]

    /**
     * A small wrapper that displays a SpriteVisualElement (typically an FXG),
     * scaling it to `fontSize` and tinting it with `color`. Use `src` to set
     * the icon (Class or instance).
     *
     * Measuring policy:
     * - `measure()` returns a square of size `fontSize` (so parent layouts
     *   can reserve exactly that much space).
     * - The icon itself is centered and scaled inside that square.
     */
    public class ColorizableIcon extends Group {


        // ---- Public API -----------------------------------------------------

        /** The source icon. May be a SpriteVisualElement instance or an FXG Class. */
        private var _src:Object;
        private var _srcChanged:Boolean;

        [Inspectable(category = "General")]
        public function get src():Object {
            return _src;
        }

        public function set src(value:Object):void {
            if (value !== _src) {
                _src = value;
                _srcChanged = true;
                invalidateProperties();
            }
        }

        // ---- Internals ------------------------------------------------------

        // live, added child
        private var _icon:SpriteVisualElement;

        // intrinsic max(width,height)
        private var _iconMaxSize:Number = NaN;

        // cached style
        private var _fontSize:int = 16;

        // cached style
        private var _color:uint = 0x000000;

        // cached style
        private var _tintStrength:Number = 1.0;

        public function ColorizableIcon() {
            super();
            mouseChildren = false;
            mouseEnabled = false;
            addEventListener(Event.ADDED_TO_STAGE, onAdded);
        }

        private function onAdded(e:Event):void {
            // ensure we read initial styles on first attach
            invalidateProperties();
            invalidateDisplayList();
        }

        // ---- Lifecycle ------------------------------------------------------

        override public function styleChanged(styleProp:String):void {
            super.styleChanged(styleProp);
            if (styleProp == null || styleProp == "styleName" || styleProp == "fontSize" || styleProp == "color" || styleProp == "tintStrength") {
                invalidateProperties();
                invalidateSize();
                invalidateDisplayList();
            }
        }

        override protected function commitProperties():void {
            super.commitProperties();

            // Resolve styles
            var fs:* = getStyle("fontSize");
            var cl:* = getStyle("color");
            var ts:* = getStyle("tintStrength");

            // Defaulting (so we’re safe even if styles aren’t set)
            _fontSize = (fs is Number && !isNaN(fs)) ? int(fs) : 16;
            _color = (cl is uint) ? uint(cl) : 0x000000;
            _tintStrength = (ts is Number && !isNaN(ts)) ? Number(ts) : 1.0;

            // Resolve/replace icon when src changes.
            if (_srcChanged) {
                _srcChanged = false;

                // Clear old
                if (_icon && _icon.parent == this) {
                    removeElement(_icon);
                }
                _icon = null;
                _iconMaxSize = NaN;

                // Coerce: Class -> instance
                var candidate:Object = _src;
                if (candidate is Class) {
                    try {
                        candidate = new (candidate as Class)();
                    } catch (_:*) {
                        candidate = null;
                    }
                }

                // Accept only SpriteVisualElement
                if (candidate is SpriteVisualElement) {
                    _icon = candidate as SpriteVisualElement;

                    // Center inside our box.
                    _icon.horizontalCenter = 0;
                    _icon.verticalCenter = 0;

                    // Compute intrinsic bounding size.
                    // Guard for 0; sometimes FXG reports 0 until measured once.
                    var w:Number = Math.max(1, _icon.width);
                    var h:Number = Math.max(1, _icon.height);
                    _iconMaxSize = Math.max(w, h);

                    addElement(_icon);
                }
            }

            // (Re)apply scale if we have an icon & intrinsic size.
            if (_icon && _iconMaxSize > 0) {
                const s:Number = _fontSize / _iconMaxSize;

                // Scale the icon; leave its container at measured fontSize box.
                _icon.scaleX = _icon.scaleY = s;
            }
        }

        override protected function measure():void {
            super.measure();

            // Report a square slot of `fontSize` for parent layouts.
            measuredMinWidth = measuredMinHeight = _fontSize;
            measuredWidth = measuredHeight = _fontSize;
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
            super.updateDisplayList(unscaledWidth, unscaledHeight);

            // Keep icon centered regardless of our outer size (parent may override)
            if (_icon) {
                _icon.horizontalCenter = 0;
                _icon.verticalCenter = 0;

                // Enforce scale consistently if someone resized "us" externally.
                if (_iconMaxSize > 0) {
                    const s:Number = _fontSize / _iconMaxSize;
                    if (_icon.scaleX != s || _icon.scaleY != s) {
                        _icon.scaleX = _icon.scaleY = s;
                    }
                }

                // Apply color tint
                ColorUtils.tintSprite(_color, this, _tintStrength);
            }
        }
    }
}
