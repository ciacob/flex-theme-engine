package com.github.ciacob.flex.ui.theming {
    public class CSSActionParser {
        private static const NAMESPACE_MAP:Object = {
                "s": "spark.components",
                "mx": "mx.controls"
            };

        private static const ACCENT_PATTERN:RegExp = /accent\s*\(\s*([^\)]*)\s*\)/i;

        public static function parse(cssText:String):Array {
            var tasks:Array = [];

            // Remove comments
            cssText = cssText.replace(/\/\*[\s\S]*?\*\//g, "");

            // Match each selector + block pair
            var re:RegExp = /([\w\.\-\|,\s]+)\s*\{([^}]+)\}/g;
            var match:Array;

            while ((match = re.exec(cssText)) !== null) {
                var rawSelectors:String = match[1];
                var body:String = match[2];

                // Handle multiple selectors split by comma
                var selectors:Array = rawSelectors.split(",");
                for each (var selector:String in selectors) {
                    selector = selector.replace(/^\s+|\s+$/g, "");
                    if (selector) {
                        processSelector(selector, body, tasks);
                    }
                }
            }

            return tasks;
        }

        private static function processSelector(selector:String, body:String, tasks:Array):void {
            var taskType:String;
            var target:String = selector;

            if (selector === "global") {
                taskType = "setGlobalStyle";
            }
            else if (selector.indexOf("|") !== -1) {
                var parts:Array = selector.split("|");
                var ns:String = parts[0];
                var comp:String = parts[1];
                var pkg:String = NAMESPACE_MAP[ns];
                if (pkg) {
                    target = pkg + "." + comp;
                    taskType = "setComponentStyle";
                }
                else {
                    trace("[CSSActionParser] Unknown namespace prefix: " + ns);
                    return;
                }
            }
            else if (selector.charAt(0) === ".") {
                taskType = "setClassStyle";
            }
            else {
                trace("[CSSActionParser] Unsupported selector: " + selector);
                return;
            }

            var lines:Array = body.split(";");
            for each (var line:String in lines) {
                line = line.replace(/^\s+|\s+$/g, "");
                if (line === "")
                    continue;

                var partsLine:Array = line.split(":");
                if (partsLine.length < 2)
                    continue;

                var prop:String = partsLine[0].replace(/^\s+|\s+$/g, "");
                var val:String = partsLine.slice(1).join(":").replace(/^\s+|\s+$/g, "");
                var value:* = parseValue(val);

                const isAccentValue:Boolean = (value && typeof (value) == "object" && value.type === "accent");

                if (prop === "relFontSize") {
                    tasks.push({task: "applyRelativeFontSize", args: [selector, value]});
                }
                else {
                    switch (taskType) {
                        case "setGlobalStyle":
                            tasks.push({task: "setGlobalStyle", args: [prop, value]});
                            break;

                        case "setComponentStyle":
                            if (isAccentValue) {
                                tasks.push({task: "applyAccentColor",
                                            args: [target, prop].concat(value.args)});
                            }
                            else {
                                tasks.push({task: "setComponentStyle", args: [target, prop, value]});
                            }
                            break;

                        case "setClassStyle":
                            if (isAccentValue) {
                                tasks.push({task: "applyAccentColor",
                                            args: [selector, prop].concat(value.args)});
                            }
                            else {
                                tasks.push({task: "setClassStyle", args: [selector, prop, value]});
                            }
                            break;
                    }
                }
            }
        }

        private static function parseValue(val:String):* {
            // Accent color (variation)?
            var accentMatch:Array = ACCENT_PATTERN.exec(val);
            if (accentMatch) {
                var ret:Object = {type: "accent"};
                var args:Array = accentMatch[1].split(/\s*,\s*/).map(function(s:String, ..._):* {
                        var n:Number = parseFloat(s);
                        return isNaN(n) ? NaN : n;
                    });
                if (args) {
                    ret.args = args;
                }
                return ret;
            }

            // Array-style value?
            if (val.indexOf(",") !== -1) {
                var parts:Array = val.split(",");
                var parsed:Array = [];
                for each (var part:String in parts) {
                    parsed.push(parseValue(part.replace(/^\s+|\s+$/g, "")));
                }
                return parsed;
            }

            // Hex color
            if (/^#([0-9A-Fa-f]{6})$/.test(val)) {
                return uint("0x" + val.substr(1));
            }

            // ClassReference("...")
            var classRefMatch:Array = /^ClassReference\("([^"]+)"\)$/.exec(val);
            if (classRefMatch) {
                return classRefMatch[1];
            }

            // Number
            if (!isNaN(Number(val))) {
                return Number(val);
            }

            // Strip quotes
            if ((val.charAt(0) === '"' && val.charAt(val.length - 1) === '"') ||
                    (val.charAt(0) === "'" && val.charAt(val.length - 1) === "'")) {
                return val.substring(1, val.length - 1);
            }

            // Raw string
            return val;
        }
    }
}