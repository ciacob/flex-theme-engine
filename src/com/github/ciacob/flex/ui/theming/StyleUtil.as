package com.github.ciacob.flex.ui.theming {
    import mx.styles.IStyleManager2;
    import mx.styles.StyleManager;
    import mx.styles.CSSStyleDeclaration;

    public class StyleUtil {
        private static var sm:IStyleManager2 = StyleManager.getStyleManager(null);

        /**
         * Sets or updates a style property on the global style declaration.
         *
         * @param property The name of the style property to set (e.g., "fontSize", "color").
         * @param value The value to assign to the style property.
         */
        public static function setGlobalStyle(property:String, value:*):void {
            var decl:CSSStyleDeclaration = sm.getStyleDeclaration("global") || new CSSStyleDeclaration();
            decl.setStyle(property, value);
            sm.setStyleDeclaration("global", decl, true);
        }

        /**
         * Sets or updates a style property on a specific component's style declaration.
         *
         * @param componentName The fully qualified class name of the component (e.g., "spark.components.Button").
         * @param property The name of the style property to set.
         * @param value The value to assign to the style property.
         */
        public static function setComponentStyle(componentName:String, property:String, value:*):void {
            var decl:CSSStyleDeclaration = sm.getStyleDeclaration(componentName) || new CSSStyleDeclaration();
            decl.setStyle(property, value);
            sm.setStyleDeclaration(componentName, decl, true);
        }

        /**
         * Sets or updates a style property on a CSS class declaration.
         *
         * @param className The name of the CSS class (with or without the leading dot, e.g., "myClass" or ".myClass").
         * @param property The name of the style property to set.
         * @param value The value to assign to the style property.
         */
        public static function setClassStyle(className:String, property:String, value:*):void {
            if (className.charAt(0) !== ".") {
                className = "." + className;
            }
            var decl:CSSStyleDeclaration = sm.getStyleDeclaration(className) || new CSSStyleDeclaration();
            decl.setStyle(property, value);
            sm.setStyleDeclaration(className, decl, true);
        }

        /**
         * Computes and applies a (variation of the) currently set global "accent color" using the
         * given selector, properties and color filtering factors.
         *
         * @param   selector
         *          The selector to apply computed color to.
         *
         * @param   prop
         *          The exact CSS property that will receive the computed color.
         *
         * @param   lightFactor
         *          A factor to apply to current color lightness to obtain a variation (e.g., 0.5 is half as bright).
         *
         * @param   satFactor
         *          A factor to apply to current color saturation to obtain a variation (e.g., 0.5 is half as saturated).
         *
         * @param   hueFactor
         *          A factor to resolve to a hue offset to use, for shifting the current color (e.g., 0.5 means -180 degrees,
         *          which results in the chromatically opposite color).
         *
         * Note: color filtering factors apply in this order: lightness, saturation, hue. Later filters operate on the color
         * earlier filters produced. `NaN` values cause no change to the color.
         */
        public static function applyAccentColor(
                selector:String,
                prop:String,
                lightFactor:Number = NaN,
                satFactor:Number = NaN,
                hueFactor:Number = NaN):void {

            var globalDecl:CSSStyleDeclaration = sm.getStyleDeclaration("global");
            var baseColor:uint = globalDecl ? globalDecl.getStyle("accentColor") : NaN;

            if (isNaN(baseColor)) {
                trace("[StyleUtil] applyAccentColor: No valid global accentColor found.");
                return;
            }

            var newColor:uint = baseColor;

            // Only compute the new color if any filter was given
            if (!isNaN(lightFactor) || !isNaN(satFactor) || !isNaN(hueFactor)) {

                var r:uint = (baseColor >> 16) & 0xFF;
                var g:uint = (baseColor >> 8) & 0xFF;
                var b:uint = baseColor & 0xFF;

                var hsv:Array = RGBtoHSV(r, g, b);
                var h:Number = hsv[0], s:Number = hsv[1], v:Number = hsv[2];

                if (!isNaN(lightFactor))
                    v = Math.max(0, Math.min(100, v * lightFactor));
                if (!isNaN(satFactor))
                    s = Math.max(0, Math.min(100, s * satFactor));
                if (!isNaN(hueFactor)) {
                    h = (h + (hueFactor * 360 - 360)) % 360;
                    if (h < 0) {
                        // Normalize to 0–360
                        h += 360;
                    }
                }

                var rgb:Array = HSVtoRGB(h, s, v);
                newColor = (rgb[0] << 16) | (rgb[1] << 8) | rgb[2];
            }

            var decl:CSSStyleDeclaration = sm.getStyleDeclaration(selector) || new CSSStyleDeclaration();
            decl.setStyle(prop, newColor);
            sm.setStyleDeclaration(selector, decl, true);
        }

        /**
         * Applies a relative font size to a CSS class based on the global font size.
         * If the scale is not provided, it attempts to read a "relFontSize" property from the class declaration.
         *
         * @param className The name of the CSS class (with or without the leading dot).
         * @param scale Optional scaling factor (e.g., 1.5 for 150%). If omitted, the value is read from "relFontSize".
         */
        public static function applyRelativeFontSize(className:String, scale:Number = NaN):void {
            if (className.charAt(0) !== ".") {
                className = "." + className;
            }
            var classDecl:CSSStyleDeclaration = sm.getStyleDeclaration(className);

            // Attempt to read scale from class style if not explicitly given
            if (isNaN(scale) && classDecl) {
                var declaredScale:* = classDecl.getStyle("relFontSize");
                scale = (declaredScale is Number) ? Number(declaredScale) : NaN;
            }
            if (isNaN(scale)) {
                trace("[StyleUtil] applyRelativeFontSize: No valid scale provided or found for " + className);
                return;
            }

            // Get base font size from global
            var globalDecl:CSSStyleDeclaration = sm.getStyleDeclaration("global");
            var baseSize:Number = globalDecl ? (globalDecl.getStyle("fontSize") as Number) || 12 : 12;
            if (isNaN(baseSize)) {
                baseSize = 12;
            }
            var newSize:Number = baseSize * scale;

            // Update or create the class declaration and set fontSize
            var newDecl:CSSStyleDeclaration = classDecl || new CSSStyleDeclaration();
            newDecl.setStyle("fontSize", newSize);
            sm.setStyleDeclaration(className, newDecl, true);
        }

        /**
         * Retrieves the value of a specific style property from a given style selector.
         *
         * @param selector The style selector string—can be "global", a fully qualified component class name (e.g., "spark.components.Button"), or a CSS class name (e.g., ".myClass").
         * @param property The name of the style property to retrieve.
         * @return The value of the requested style property, or null if not found.
         */
        public static function getStyle(selector:String, property:String):* {
            var decl:CSSStyleDeclaration = sm.getStyleDeclaration(selector);
            return decl ? decl.getStyle(property) : null;
        }

        /**
         * Converts Red, Green, Blue to Hue, Saturation, Value
         * @r channel between 0-255
         * @s channel between 0-255
         * @v channel between 0-255
         */
        public static function RGBtoHSV(r:uint, g:uint, b:uint):Array {
            var max:uint = Math.max(r, g, b);
            var min:uint = Math.min(r, g, b);

            var hue:Number = 0;
            var saturation:Number = 0;
            var value:Number = 0;

            var hsv:Array = [];

            // get Hue
            if (max == min) {
                hue = 0;
            }
            else if (max == r) {
                hue = (60 * (g - b) / (max - min) + 360) % 360;
            }
            else if (max == g) {
                hue = (60 * (b - r) / (max - min) + 120);
            }
            else if (max == b) {
                hue = (60 * (r - g) / (max - min) + 240);
            }

            // get Value
            value = max;

            // get Saturation
            if (max == 0) {
                saturation = 0;
            }
            else {
                saturation = (max - min) / max;
            }

            hsv = [Math.round(hue), Math.round(saturation * 100), Math.round(value / 255 * 100)];
            return hsv;
        }

        /**
         * Converts Hue, Saturation, Value to Red, Green, Blue
         * @h Angle between 0-360
         * @s percent between 0-100
         * @v percent between 0-100
         */
        public static function HSVtoRGB(h:Number, s:Number, v:Number):Array {
            var r:Number = 0;
            var g:Number = 0;
            var b:Number = 0;
            var rgb:Array = [];

            var tempS:Number = s / 100;
            var tempV:Number = v / 100;

            var hi:int = Math.floor(h / 60) % 6;
            var f:Number = h / 60 - Math.floor(h / 60);
            var p:Number = (tempV * (1 - tempS));
            var q:Number = (tempV * (1 - f * tempS));
            var t:Number = (tempV * (1 - (1 - f) * tempS));

            switch (hi) {
                case 0:
                    r = tempV;
                    g = t;
                    b = p;
                    break;
                case 1:
                    r = q;
                    g = tempV;
                    b = p;
                    break;
                case 2:
                    r = p;
                    g = tempV;
                    b = t;
                    break;
                case 3:
                    r = p;
                    g = q;
                    b = tempV;
                    break;
                case 4:
                    r = t;
                    g = p;
                    b = tempV;
                    break;
                case 5:
                    r = tempV;
                    g = p;
                    b = q;
                    break;
            }

            rgb = [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)];
            return rgb;
        }
    }
}