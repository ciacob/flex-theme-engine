package com.github.ciacob.flex.ui {

    import flash.display.DisplayObject;
    import spark.primitives.supportClasses.GraphicElement;
    import flash.geom.ColorTransform;

    public final class ColorUtils {

        private static const NUM_COLOR_CHARS:uint = 6;

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

        public static function HexToDeci(hex:String):uint {
            if (hex.substr(0, 2) != "0x") {
                hex = "0x" + hex;
            }
            return new uint(hex);
        }

        public static function HexToRGB(hex:uint):Array {
            var rgb:Array = [];

            var r:uint = hex >> 16 & 0xFF;
            var g:uint = hex >> 8 & 0xFF;
            var b:uint = hex & 0xFF;

            rgb.push(r, g, b);
            return rgb;
        }

        public static function RGBToHex(r:uint, g:uint, b:uint):uint {
            var hex:uint = (r << 16 | g << 8 | b);
            return hex;
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
            } else if (max == r) {
                hue = (60 * (g - b) / (max - min) + 360) % 360;
            } else if (max == g) {
                hue = (60 * (b - r) / (max - min) + 120);
            } else if (max == b) {
                hue = (60 * (r - g) / (max - min) + 240);
            }

            // get Value
            value = max;

            // get Saturation
            if (max == 0) {
                saturation = 0;
            } else {
                saturation = (max - min) / max;
            }

            hsv = [Math.round(hue), Math.round(saturation * 100), Math.round(value / 255 * 100)];
            return hsv;
        }

        /**
         * Combines individual values of the alpha, red, green and blue channels
         * into a 32 bits color value.
         */
        public static function combineARGB(alpha:uint, red:uint, green:uint, blue:uint):uint {
            return ((alpha << 24) | (red << 16) | (green << 8) | blue);
        }

        /**
         * Combines individual values of the red, green and blue channels
         * into a 24 bits color value.
         */
        public static function combineRGB(red:uint, green:uint, blue:uint):uint {
            return ((red << 16) | (green << 8) | blue);
        }

        /**
         * Something like a poor man's solution for darkening the overall color of a
         * given DisplayObject. Works by tinting with black, which also desaturates the target.
         *
         * @param sprite
         * 		A DisplayObject (subclass) instance to be darkened.
         *
         * @param ColorUtils.
         * 		Optional, a number between 0 and 1 to factor in the lightening amount. Defaults to
         * 		`0.25` (one quarter lightening).
         */
        public static function darkenSprite(sprite:DisplayObject, multiplier:Number = 0.25):void {
            tintSprite(0x000000, sprite, multiplier);
        }

        /**
         * Extracts the value of the alpha channel out of the given (32 bits)
         * color value.
         */
        public static function extractAlpha(colorVal:uint):uint {
            return (colorVal >> 24) & 0xFF;
        }

        /**
         * Extracts the value of the blue channel out of the given
         * color value.
         */
        public static function extractBlue(colorVal:uint):uint {
            return colorVal & 0xFF;
        }

        /**
         * Extracts the value of the green channel out of the given
         * color value.
         */
        public static function extractGreen(colorVal:uint):uint {
            return (colorVal >> 8) & 0xFF;
        }

        /**
         * Extracts the value of the red channel out of the given
         * color value.
         */
        public static function extractRed(colorVal:uint):uint {
            return colorVal >> 16 & 0xFF;
        }

        /**
         * Generates a random, unique 24 bit color (alpha channel not included).
         *
         * @param	pool
         * 			Optional; a spare Array to populate with colors already generated, in order
         * 			to avoid repeating colors. If missing/set to `null`, nothing is done to
         * 			ensure generated colors' unicity.
         *
         * @param	lowerLimit
         * 			Optional; if provided, neither of the red, green and blue
         * 			channels can take values smaller than this limit.
         *
         * @param	higherLimit
         * 			Optional; if provided, neither of the red, green and blue
         * 			channels can take values greater than this limit.
         *
         * @param	redLowerLimit
         * 			Optional; same as "lowerLimit", but for the red channel. Takes precedence over
         * 			"lowerLimit", which is generic.
         *
         * @param	redHigherLimit
         * 		 	Optional; same as "higherLimit", but for the red channel. Takes precedence over
         * 			"higherLimit", which is generic.
         *
         * @param	greenLowerLimit
         * 			Optional; same as "lowerLimit", but for the green channel. Takes precedence over
         * 			"lowerLimit", which is generic.
         *
         * @param	greenHigherLimit
         * 		 	Optional; same as "higherLimit", but for the green channel. Takes precedence over
         * 			"higherLimit", which is generic.
         *
         * @param	blueLowerLimit
         * 			Optional; same as "lowerLimit", but for the blue channel. Takes precedence over
         * 			"lowerLimit", which is generic.
         *
         * @param	blueHigherLimit
         * 		 	Optional; same as "higherLimit", but for the blue channel. Takes precedence over
         * 			"higherLimit", which is generic.
         *
         * @return	The generated color as an unsigned integer.
         */
        public static function generateRandomColor(

            pool:Array = null, lowerLimit:uint = 0, higherLimit:uint = 0xff, redLowerLimit:uint = 0, redHigherLimit:uint = 0, greenLowerLimit:uint = 0, greenHigherLimit:uint = 0, blueLowerLimit:uint = 0, blueHigherLimit:uint = 0

            ):uint {

            lowerLimit = Math.max(lowerLimit, 0);
            redLowerLimit = Math.max(lowerLimit, 0);
            greenLowerLimit = Math.max(lowerLimit, 0);
            blueLowerLimit = Math.max(lowerLimit, 0);

            higherLimit = Math.min(higherLimit, 0xff);
            redHigherLimit = Math.min(higherLimit, 0xff);
            greenHigherLimit = Math.min(higherLimit, 0xff);
            blueHigherLimit = Math.min(higherLimit, 0xff);

            var do_generate:Function = function(

                lower_limit:uint = 0, higher_limit:uint = 0xff, red_lower_limit:uint = 0, red_higher_limit:uint = 0, green_lower_limit:uint = 0, green_higher_limit:uint = 0, blue_lower_limit:uint = 0, blue_higher_limit:uint = 0

                    ):uint {
                        var r:uint = _getRandomInteger(red_lower_limit || lower_limit, red_higher_limit || higher_limit);
                        var g:int = _getRandomInteger(green_lower_limit || lower_limit, green_higher_limit || higher_limit);
                        var b:int = _getRandomInteger(blue_lower_limit || lower_limit, blue_higher_limit || higher_limit);
                        return combineRGB(r, g, b);
                    };

            var color:uint = do_generate(

                lowerLimit, higherLimit, redLowerLimit, redHigherLimit, greenLowerLimit, greenHigherLimit, blueLowerLimit, blueHigherLimit

                );

            if (pool != null) {
                while (pool.indexOf(color) >= 0) {
                    color = do_generate();
                }
                pool.push(color);
            }

            return color;
        }

        public static function hexToHsv(color:uint):Array {
            var colors:Array = HexToRGB(color);
            return RGBtoHSV(colors[0], colors[1], colors[2]);
        }

        public static function hsvToHex(h:Number, s:Number, v:Number):uint {
            var colors:Array = HSVtoRGB(h, s, v);
            return RGBToHex(colors[0], colors[1], colors[2]);
        }

        /**
         * Something like a poor man's solution for lightening up the overall color of a
         * given DisplayObject. Works by tinting with white, which also desaturates the target.
         *
         * @param sprite
         * 		A DisplayObject (subclass) instance to be lightened.
         *
         * @param ColorUtils.
         * 		Optional, a number between 0 and 1 to factor in the lightening amount. Defaults to
         * 		`0.25` (one quarter lightening).
         */
        public static function lightenSprite(sprite:DisplayObject, multiplier:Number = 0.25):void {
            tintSprite(0xffffff, sprite, multiplier);
        }

        /**
         * Adds a (fully opaque) alpha channel to a (24 bits) image.
         * This is a shortcut for `setAlpha(0xff, colorVal)`.
         */
        public static function rgbToArgb(colorVal:uint):uint {
            return setAlpha(0xff, colorVal);
        }

        /**
         * Sets given alpha channel value into given (32 bits) color value.
         */
        public static function setAlpha(alpha:uint, colorVal:uint):uint {
            var R:uint = extractRed(colorVal);
            var G:uint = extractGreen(colorVal);
            var B:uint = extractBlue(colorVal);
            return combineARGB(alpha, R, G, B);
        }

        /**
         * Combines given blue channel value into given color value.
         */
        public static function setBlue(blue:uint, colorVal:uint, useARGB:Boolean = false):uint {
            var R:uint = extractRed(colorVal);
            var G:uint = extractGreen(colorVal);
            if (useARGB) {
                var A:uint = extractAlpha(colorVal);
                return combineARGB(A, R, G, blue);
            }
            return combineRGB(R, G, blue);
        }

        /**
         * Sets given green channel value into given color value.
         */
        public static function setGreen(green:uint, colorVal:uint, useARGB:Boolean = false):uint {
            var R:uint = extractRed(colorVal);
            var B:uint = extractBlue(colorVal);
            if (useARGB) {
                var A:uint = extractAlpha(colorVal);
                return combineARGB(A, R, green, B);
            }
            return combineRGB(R, green, B);
        }

        /**
         * Sets given red channel value into given color value.
         */
        public static function setRed(red:uint, colorVal:uint, useARGB:Boolean = false):uint {
            var G:uint = extractGreen(colorVal);
            var B:uint = extractBlue(colorVal);
            if (useARGB) {
                var A:uint = extractAlpha(colorVal);
                return combineARGB(A, red, G, B);
            }
            return combineRGB(red, G, B);
        }

        /**
         * Paints given "sprite" with given color.  Painting is done using ColorTransform.
         *
         * @param	color
         * 			The color to paint with.
         *
         * @param	sprite
         * 			A DisplayObject (subclass) instance to be painted.
         *
         * @param 	multiplier
         * 			Optional, a number between 0 and 1 to factor in the amount of "paint" used. Defaults
         * 			to `1` (paints with full color).
         *
         * @param 	alphaMultiplier
         * 			Optional, a number between 0 and 1 to factor in the transparency of the resulting
         * 			color. Defaults to `NaN`, which will leave alpha unchanged (default).
         */
        public static function tintSprite(color:uint, sprite:DisplayObject, multiplier:Number = 1, alphaMultiplier:Number = NaN):void {
            if (!sprite) {
                return;
            }

            multiplier = Math.max(0, Math.min(1, multiplier));

            const ctMul:Number = 1 - multiplier;
            const ctRedOff:Number = Math.round(multiplier * extractRed(color));
            const ctGreenOff:Number = Math.round(multiplier * extractGreen(color));
            const ctBlueOff:Number = Math.round(multiplier * extractBlue(color));

            var ct:ColorTransform = sprite.transform.colorTransform; // ← returns a copy

            ct.redMultiplier = ctMul;
            ct.greenMultiplier = ctMul;
            ct.blueMultiplier = ctMul;

            if (!isNaN(alphaMultiplier)) {
                alphaMultiplier = Math.max(0, Math.min(1, alphaMultiplier));
                ct.alphaMultiplier = alphaMultiplier;
            }

            ct.redOffset = ctRedOff;
            ct.greenOffset = ctGreenOff;
            ct.blueOffset = ctBlueOff;
            ct.alphaOffset = 0;

            sprite.transform.colorTransform = ct;
        }

        /**
         * Delegatee of applyChromeColor.
         * Applies the Spark-style “chromeColor” tint to a target DisplayObject
         * or GraphicElement.
         *
         * The tint is implemented as channel offsets relative to the default
         * grey (0xCCCCCC).  For example, a chromeColor of 0xFF0000 adds +51 to
         * the red channel (0xFF – 0xCC) and −204 to both green & blue
         * (0x00 – 0xCC), producing a pure-red-with-alpha transform identical
         * to Spark’s.
         *
         * @param target          DisplayObject to be colorized.
         * @param chromeColor     0xRRGGBB color to apply.
         * @param alphaMultiplier Optional. Alpha multiplier to copy into the
         * 						  transform (1 = fully opaque).  Default = 1.
         */
        public static function $applyChromeColor(target:Object, chromeColor:uint, alphaMultiplier:Number = 1):void {
            if (!target || !((target is DisplayObject) || (target is GraphicElement))) {
                return;
            }

            // Spark constants
            const DEFAULT_COLOR_VALUE:uint = 0xCC; // 204
            const DEFAULT_COLOR:uint = 0xCCCCCC; // grey (204,204,204)

            // If caller passed the default color, no tint is needed.
            if (chromeColor == DEFAULT_COLOR) {
                return;
            }

            var ct:ColorTransform = target.transform.colorTransform; // copy

            ct.redOffset = ((chromeColor >> 16) & 0xFF) - DEFAULT_COLOR_VALUE;
            ct.greenOffset = ((chromeColor >> 8) & 0xFF) - DEFAULT_COLOR_VALUE;
            ct.blueOffset = (chromeColor & 0xFF) - DEFAULT_COLOR_VALUE;

            ct.alphaMultiplier = alphaMultiplier; // Spark copies the skin’s α
            ct.redMultiplier = ct.greenMultiplier = ct.blueMultiplier = 1;
            ct.alphaOffset = 0;

            target.transform.colorTransform = ct;
        }

        /**
         * Applies the Spark-style “chromeColor” tint to a target DisplayObject
         * or GraphicElement.
         *
         * @param 	chromeColor
         * 			The color to apply, in 0xRRGGBB format.
         *
         * @param	...targets
         * 			One or more targets to be colorized.
         */
        public static function applyChromeColor(chromeColor:uint, ... targets):void {
            if (targets && targets.length) {
                for each (var target:Object in targets) {
                    $applyChromeColor(target, chromeColor);
                }
            }
        }

        /**
         * Converts given color value (expressed as an unsigned integer) to a RRGGBB string.
         */
        public static function toHexNotation(colorVal:uint, useARGB:Boolean = false, includeHash:Boolean = false):String {
            var redValue:uint = extractRed(colorVal);
            var greenValue:uint = extractGreen(colorVal);
            var blueValue:uint = extractBlue(colorVal);
            var output:Array = [_padLeft(redValue.toString(16), '0', 2),
                _padLeft(greenValue.toString(16), '0', 2),
                _padLeft(blueValue.toString(16), '0', 2)];
            if (useARGB) {
                var alphaValue:uint = extractAlpha(colorVal);
                output.unshift(_padLeft(alphaValue.toString(16), '0', 2));
            }
            if (includeHash) {
                output.unshift('#');
            }
            return output.join('');
        }

        /**
         * Converts a color (given as an unsigned integer) into the postscript RGB
         * format, were each chanel is represented as a number from 0 to 1 (with `1`
         * meaning e.g., "full red").
         *
         * Example: `toPostscriptRgb (0xff6300)` // returns "1 0.25 0"
         *
         * @param	color
         * 			The color to convert.
         *
         * @param	precision
         * 			Optional. The precision of the decimal used for each chanel value,
         * 			i.e. `4` will give `0.2315`.
         * 			Defaults to `4`.
         *
         * @return	The converted color.
         */
        public static function toPostscriptRgb(color:uint, precision:uint = 4):String {
            var r:uint = ColorUtils.extractRed(color);
            var rVal:String = (r / 0xff).toPrecision(precision);
            var g:uint = ColorUtils.extractGreen(color);
            var gVal:String = (g / 0xff).toPrecision(precision);
            var b:uint = ColorUtils.extractBlue(color);
            var bVal:String = (b / 0xff).toPrecision(precision);
            var ps:String = ([rVal, gVal, bVal]).join(' ');
            return ps;
        }

        /**
         * Pads p_string with specified character to a specified length from the left.
         *
         *	@param p_string String to pad
         *	@param p_padChar Character for pad.
         *	@param p_length Length to pad to.
         *
         *	@returns String
         */
        private static function _padLeft(p_string:String, p_padChar:String, p_length:uint):String {
            var s:String = p_string;
            while (s.length < p_length) {
                s = p_padChar + s;
            }
            return s;
        }

        /**
         * Returns a random integer included in a closed interval [A, B].
         * For example, `getRandomInteger(3, 5)` will return 3, 4, or 5.
         *
         * @param	limitA
         * 			One endpoint of the interval.
         *
         * @param	limitB
         * 			The other endpoint of the interval.
         *
         * @param	randomFunction
         * 			Optional, defaults to `Math.random`.
         * A function that generates random values in [0, 1),
         * i.e., including 0 but excluding 1.
         * 			Allows the use of a seeded PRNG instead of Math.random().
         *
         * @return	A random unsigned integer from the closed interval [A, B].
         */
        private static function _getRandomInteger(limitA:uint, limitB:uint, randomFunction:Function = null):uint {
            if (randomFunction == null) {
                randomFunction = Math.random;
            }
            var poolLength:uint = uint(Math.abs(limitA - limitB)) + 1;
            var lowest:uint = Math.min(limitA, limitB);
            var r:Number = randomFunction() % 1; // Clamp to [0,1) in case a custom PRNG returns 1.0 or higher

            return uint(Math.floor(r * poolLength) + lowest);
        }
    }
}
