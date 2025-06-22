package com.github.ciacob.flex.ui.components {
    import mx.core.UIComponent;
    import flash.display.Graphics;
    import flash.geom.Matrix;
    import flash.display.GradientType;
    import flash.display.BlendMode;
    import flash.display.Shape;
    import flash.display.BitmapData;
    import flash.geom.Rectangle;

    [Style(name = "borderColors", type = "Array", format = "Color", inherit = "yes")]
    [Style(name = "borderAlphas", type = "Array", format = "Number", inherit = "yes")]
    [Style(name = "borderWidths", type = "Array", format = "uint", inherit = "yes")]
    [Style(name = "xMultiplyColors", type = "Array", format = "Color", inherit = "yes")]
    [Style(name = "yMultiplyColors", type = "Array", format = "Color", inherit = "yes")]
    [Style(name = "cornerRadius", type = "Number", inherit = "false")]
    [Style(name = "padding", type = "uint", inherit = "false")]

    /**
     * Generic background surface component for Flex applications.
     * This component allows for customizable borders, gradients, and corner radii.
     */
    public class BackgroundSurface extends UIComponent {
        public function BackgroundSurface() {
            super();
        }

        /**
         * Returns an array of values for the given style name.
         * If the style is not defined, it returns an empty array.
         * If the style is a single value, it returns an array with that value.
         * If the style is an array, it returns that array.
         * @param styleName - The name of the style to retrieve.
         * @return An array of values for the style.
         */
        private function _getArrayOf(styleName:String):Array {
            var rawVal:* = getStyle(styleName);
            if (rawVal === undefined) {
                return [];
            }
            if (rawVal is Array) {
                return (rawVal as Array);
            }
            return [rawVal];
        }

        /**
         * Updates the display list of the component.
         * This method is called to render the component's visual appearance.
         * @param w - The width of the component.
         * @param h - The height of the component.
         * It draws borders, fills with gradients, and applies styles.
         */
        override protected function updateDisplayList(w:Number, h:Number):void {
            super.updateDisplayList(w, h);

            const cornerRadius:Number = getStyle("cornerRadius") || 0;
            const borderColors:Array = _getArrayOf("borderColors");
            const borderAlphas:Array = _getArrayOf("borderAlphas");
            const borderWidths:Array = _getArrayOf("borderWidths");

            const xMultiplyColors:Array = _getArrayOf("xMultiplyColors");
            const yMultiplyColors:Array = _getArrayOf("yMultiplyColors");

            // 1. Create an off-screen buffer to render into
            const buffer:BitmapData = new BitmapData(w, h, true, 0x00000000); // Transparent base
            const tempShape:Shape = new Shape();
            const g:Graphics = tempShape.graphics;

            // 2. Draw borders
            var offset:Number = 0;
            var drawArea:Rectangle = new Rectangle;
            for (var i:int = 0; i < borderColors.length; i++) {
                const color:uint = borderColors[i];
                const alpha:Number = (i < borderAlphas.length) ? borderAlphas[i] : 1.0;

                g.beginFill(color, alpha);

                drawArea.x = drawArea.y = offset;
                drawArea.width = Math.max(0, w - 2 * offset);
                drawArea.height = Math.max(0, h - 2 * offset);

                g.drawRoundRect(drawArea.x, drawArea.y, drawArea.width, drawArea.height, cornerRadius);
                g.endFill();

                if (i < borderWidths.length) {
                    offset += borderWidths[i];
                } else {
                    offset += 1;
                }
            }

            // 3. Draw the base shape into buffer
            buffer.draw(tempShape);

            // 4. Apply xMultiplyColors (top-to-bottom gradient)
            if (xMultiplyColors.length > 1) {
                const xGradient:Shape = new Shape();
                const gx:Graphics = xGradient.graphics;

                const xAlphas:Array = [];
                const xRatios:Array = [];

                for (i = 0; i < xMultiplyColors.length; i++) {
                    xAlphas[i] = 1.0;
                    xRatios[i] = 255 * i / (xMultiplyColors.length - 1);
                }

                const xMatrix:Matrix = new Matrix();
                xMatrix.createGradientBox(drawArea.width, drawArea.height, Math.PI / 2);
                gx.beginGradientFill(GradientType.LINEAR, xMultiplyColors, xAlphas, xRatios, xMatrix);

                gx.drawRoundRect(drawArea.x, drawArea.y, drawArea.width, drawArea.height, cornerRadius);
                gx.endFill();

                buffer.draw(xGradient, null, null, BlendMode.MULTIPLY);
            }

            // 5. Apply yMultiplyColors (left-to-right gradient)
            if (yMultiplyColors.length > 1) {
                const yGradient:Shape = new Shape();
                const gy:Graphics = yGradient.graphics;

                const yAlphas:Array = [];
                const yRatios:Array = [];

                for (i = 0; i < yMultiplyColors.length; i++) {
                    yAlphas[i] = 1.0;
                    yRatios[i] = 255 * i / (yMultiplyColors.length - 1);
                }

                const yMatrix:Matrix = new Matrix();
                yMatrix.createGradientBox(w, h, 0);

                gy.beginGradientFill(GradientType.LINEAR, yMultiplyColors, yAlphas, yRatios, yMatrix);
                gy.drawRoundRect(drawArea.x, drawArea.y, drawArea.width, drawArea.height, cornerRadius);

                gy.endFill();

                buffer.draw(yGradient, null, null, BlendMode.MULTIPLY);
            }

            // 6. Draw the final composed image to our component
            const gSelf:Graphics = graphics;
            gSelf.clear();
            gSelf.beginBitmapFill(buffer, null, false, true);

            gSelf.drawRoundRect(0, 0, w, h, cornerRadius);

            gSelf.endFill();
        }

    }
}
