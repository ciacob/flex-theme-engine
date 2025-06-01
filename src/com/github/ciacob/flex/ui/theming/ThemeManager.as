package com.github.ciacob.flex.ui.theming {
    import flash.system.Capabilities;
    import flash.text.Font;
    import flash.utils.ByteArray;

    import mx.styles.IStyleManager2;
    import mx.styles.StyleManager;
    import mx.styles.CSSStyleDeclaration;
    import flash.text.FontType;
    import flash.text.FontStyle;

    public class ThemeManager {

        public static const DEFAULT_FONT_EXCLUDE_PATTERNS:Array = [
                "light",
                "medium",
                "heavy",
                "bold",
                "black",
                "heading",
                "titling",
                "semil",
                "semib",
                "condensed",
                "italic",
                "script",
                "print",
                "engraved",
                "wingdings",
                "webdings",
                "marlett",
                "ms outlook",
                "ms reference specialty",
                "mt extra",
                "TtsNote",
                "symbol",
                "finale",
                "maestro",
                "copyist",
            ];

        private static const sm:IStyleManager2 = StyleManager.getStyleManager(null);

        private static var lastThemeGlobals:Array = [];
        private static var lastThemeRelFonts:Array = [];
        private static var lastThemeStyles:Array = []; // [{ selector: String, properties: Array }]
        private static var lastThemeAccents:Array = []; // [{ selector, property, factors: [l,s,h] }]

        /**
         * Helper. Does a multi-criterial sort of font names, putting first all fonts containing "UI"
         * in their font name. To be used as an Array.sort() argument.
         */
        private static function _sortFonts(a:String, b:String):int {
            var aMatch:Boolean = /\bui\b/i.test(a);
            var bMatch:Boolean = /\bui\b/i.test(b);

            if (aMatch && !bMatch)
                return -1;
            if (!aMatch && bMatch)
                return 1;

            return a.toLowerCase().localeCompare(b.toLowerCase());
        }

        /**
         * Sets the global base font size and reapplies all relative font size styles
         * defined in the currently active theme.
         *
         * This method updates the "fontSize" property in the global style declaration,
         * then reapplies each selector tracked by the last theme that declared a "relFontSize"
         * rule, effectively recalculating their scaled font sizes.
         *
         * @param size The new base font size (must be a number ≥ 5). Values below 5 or NaN are ignored.
         */
        public static function setBaseFontSize(size:Number):void {
            if (isNaN(size) || size < 5) {
                trace("[ThemeManager] Ignored invalid base font size:", size);
                return;
            }

            StyleUtil.setGlobalStyle("fontSize", size);

            for each (var relSizeInfo:Object in lastThemeRelFonts) {
                StyleUtil.applyRelativeFontSize(relSizeInfo.selector, relSizeInfo.factor);
            }
        }

        /**
         * Sets the global "accent color", then recomputes and reapplies all related color variations,
         * across the entire active theme.
         * 
         * This method updates all properties, across all selectors, that use a value in the form of
         * `accent ( )`. The parenthesized values, if given, define filters that produce color 
         * variations (see `StyleUtil.applyAccentColor()` for details).
         * 
         * @param color The new accent color to use.
         */
        public static function setAccentColor(color:uint):void {
            StyleUtil.setGlobalStyle("accentColor", color);

            for each (var info:Object in lastThemeAccents) {
                StyleUtil.applyAccentColor(info.selector, info.property,
                        info.factors[0], info.factors[1], info.factors[2]);
            }
        }

        /**
         * Applies a new theme expressed as an embedded CSS class.
         * Previous theme styles and global values are cleared before applying.
         * @param cssClass The embedded CSS file class (application/octet-stream).
         */
        public static function applyTheme(cssClass:Class):void {
            clearLastThemeStyles();

            var cssBytes:ByteArray = new cssClass() as ByteArray;
            var cssText:String = cssBytes.readUTFBytes(cssBytes.length);
            var cssTasks:Array = CSSActionParser.parse(cssText);

            var styleTracker:Object = {}; // selector → [prop1, prop2, ...]

            for each (var entry:Object in cssTasks) {
                if (entry && entry.task && (StyleUtil[entry.task] is Function)) {
                    (StyleUtil[entry.task] as Function).apply(null, entry.args || []);

                    switch (entry.task) {
                        case "setGlobalStyle":
                            lastThemeGlobals.push(entry.args[0]); // property name
                            break;

                        case "applyRelativeFontSize":
                            var relSel:String = entry.args[0];
                            var relFactor:Number = entry.args[1];
                            lastThemeRelFonts.push({selector: relSel, factor: relFactor});
                            if (!styleTracker[relSel])
                                styleTracker[relSel] = [];
                            styleTracker[relSel].push("fontSize");
                            // intentional fall-through to also process other class styles

                        case "setComponentStyle":
                        case "setClassStyle":
                            var sel:String = entry.args[0];
                            var prop:String = entry.args[1];
                            if (prop !== "relFontSize") {
                                if (!styleTracker[sel])
                                    styleTracker[sel] = [];
                                styleTracker[sel].push(prop);
                            }
                            break;

                        case "applyAccentColor":
                            var acSel:String = entry.args[0];
                            var acProp:String = entry.args[1];
                            var acFactors:Array = entry.args.slice(2);
                            lastThemeAccents.push({selector: acSel, property: acProp, factors: acFactors});
                            if (!styleTracker[acSel])
                                styleTracker[acSel] = [];
                            styleTracker[acSel].push(acProp);
                            break;
                    }
                }
            }

            // Convert styleTracker object to array
            lastThemeStyles = [];
            for (var selector:String in styleTracker) {
                lastThemeStyles.push({
                            selector: selector,
                            properties: styleTracker[selector]
                        });
            }
        }

        /**
         * Clears previously applied component/class/global styles and resets tracking.
         */
        private static function clearLastThemeStyles():void {
            var prop:String;

            // Clear component/class styles per property
            for each (var item:Object in lastThemeStyles) {
                var decl:CSSStyleDeclaration = sm.getStyleDeclaration(item.selector);
                if (decl) {
                    for each (prop in item.properties) {
                        decl.clearStyle(prop);
                    }
                    sm.setStyleDeclaration(item.selector, decl, true);
                }
            }
            lastThemeStyles = [];

            // Clear previous global properties
            var globalDecl:CSSStyleDeclaration = sm.getStyleDeclaration("global") || new CSSStyleDeclaration();
            for each (prop in lastThemeGlobals) {
                globalDecl.clearStyle(prop);
            }
            sm.setStyleDeclaration("global", globalDecl, true);
            lastThemeGlobals = [];

            // Reset relative font size and accent color tracking.
            lastThemeRelFonts = [];
            lastThemeAccents = [];
        }

        /**
         * Returns a sorted array of available system font names (device fonts only).
         * Optionally excludes fonts whose names contain any of the specified substrings.
         *
         * @param excludePatterns An optional array of substrings. If a font name contains any, it will be excluded.
         *                        Pass `null` to disable filtering entirely. If missing or `undefined`, default
         *                        exclusions are used (see ThemeManager.DEFAULT_FONT_EXCLUDE_PATTERNS).
         * @return An alphabetically sorted array of font names.
         */
        public static function getSystemFontNames(excludePatterns:* = undefined):Array {
            if (excludePatterns === undefined) {
                excludePatterns = DEFAULT_FONT_EXCLUDE_PATTERNS;
            }

            var fonts:Array = Font.enumerateFonts(true);
            var names:Array = fonts
                .filter(function(f:Font, ..._):Boolean {
                        if (f.fontType !== FontType.DEVICE || f.fontStyle !== FontStyle.REGULAR)
                            return false;

                        if (excludePatterns && (excludePatterns is Array) && excludePatterns.length > 0) {
                            var lowerName:String = f.fontName.toLowerCase();
                            for each (var pattern:String in excludePatterns as Array) {
                                if (lowerName.indexOf(pattern.toLowerCase()) !== -1) {
                                    return false;
                                }
                            }
                        }

                        return true;
                    })
                .map(function(f:Font, ..._):String {
                        return f.fontName;
                    });

            names.sort(_sortFonts);
            return names;
        }

        /**
         * Returns the current global font and its index within the system font list.
         */
        public static function getCurrentGlobalFont():Object {
            var globalDecl:CSSStyleDeclaration = sm.getStyleDeclaration("global");
            var name:String = globalDecl ? globalDecl.getStyle("fontFamily") : null;
            var all:Array = getSystemFontNames();
            var index:int = name ? all.indexOf(name) : -1;
            return {name: name, index: index};
        }

        /**
         * Attempts to set the first available font from a preferred list for the current OS.
         * @param defaults Array of { os: "win"|"mac"|"android"|"ios", fonts: [String] }
         */
        public static function setPreferredDefaultFonts(defaults:Array):void {
            var os:String = Capabilities.os.toLowerCase();
            var platform:String =
                os.indexOf("win") !== -1 ? "win" :
                os.indexOf("mac") !== -1 ? "mac" :
                os.indexOf("android") !== -1 ? "android" :
                os.indexOf("ios") !== -1 ? "ios" : "other";

            var entry:Object = null;
            for each (var item:Object in defaults) {
                if (item.os === platform) {
                    entry = item;
                    break;
                }
            }

            if (!entry || !entry.fonts || !(entry.fonts is Array))
                return;

            for each (var font:String in entry.fonts) {
                if (setGlobalFont(font)) {
                    trace("[ThemeManager] Applied default font for", platform, ":", font);
                    return;
                }
            }
        }

        /**
         * Sets the global font if it is available. Returns true if successful.
         * @param fontName The font name to apply as global fontFamily.
         */
        public static function setGlobalFont(fontName:String):Boolean {
            if (!fontName || getSystemFontNames().indexOf(fontName) === -1) {
                return false;
            }
            StyleUtil.setGlobalStyle("fontFamily", fontName);
            trace('[ThemeManager] Successfully set font:', fontName);
            return true;
        }
    }
}