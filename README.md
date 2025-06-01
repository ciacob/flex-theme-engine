# Flex Theme Engine
## Theme system for Apache Flex (4.16+)

### A lightweight and extensible theme system for Apache Flex (4.16+), designed to provide advanced runtime theming features including:

- Embedded theme switching

- Dynamic base font scaling (`relFontSize`)

- Accent color transformation (`accent(...)`)

- System font selection with filtering

## 🔧 Components
### 1. ThemeManager
Manages application-wide theme operations.

`applyTheme(cssClass:Class):void`
<br>Applies a theme from an embedded CSS file. Automatically clears styles from the previous theme.

`setBaseFontSize(size:Number):void`
<br>Updates the base font size and recalculates all relative font declarations (relFontSize).

`setGlobalFont(fontName:String):Boolean`
<br>Sets the global font if available on the system.

`setPreferredDefaultFonts(defaults:Array):void`
<br>Applies the first available font from a platform-specific fallback list.

`getCurrentGlobalFont():Object`
<br>Returns the current global font and its index within the system font list.

`getSystemFontNames(excludePatterns:* = undefined):Array`
<br>Lists available system fonts, optionally filtered. Sorted with UI-priority.

### 2. StyleUtil
Contains low-level utilities for applying style operations programmatically.

`setGlobalStyle(name:String, value:*):void`
<br>Applies a style property to the global scope.

`setClassStyle(selector:String, prop:String, value:*):void`
<br>Sets a specific style on a class selector.

`applyRelativeFontSize(selector:String, factor:Number = NaN:void`
<br>Dynamically applies font sizes relative to the global base.

`applyAccentStyle(selector:String, property:String, lightFactor:Number = NaN, satFactor:Number = NaN, hueFactor:Number = NaN):void`
<br>Applies a dynamically computed color to a style property using the global accentColor as a base.

### 3. CSSActionParser
Parses raw CSS text and converts it to actionable instructions consumed by the theming engine.

Supports:

- `relFontSize: <factor>` — applies scaled fonts

- `accent(<light>, <sat>, <hue>)` — computes dynamic hues

- Standard property application via `StyleUtil`

## Requirements
- Apache Flex 4.16+

- Compatible runtime (AIR recommended)

- MXML or ActionScript Flex projects

- Preferably Spark components

## Embedding Themes
Embed CSS files as application/octet-stream and pass the resulting class to `ThemeManager.applyTheme()`.

```actionscript
[Embed(source="/themes/light.css", mimeType="application/octet-stream")]
private var LightTheme:Class;

ThemeManager.applyTheme(LightTheme);
```

### Sample CSS classes
File: `light.css`
```css
/* Light theme */
/* Global styles */
global {
    color: #000000;
    chromeColor: #d0d0d0;
}

s|WindowedApplication {
    backgroundColor: #d0d0d0;
}

.largerFont, .h2 {
    relFontSize: 3.5;
}

s|List {
    alternatingItemColors: #FFFFFF;
    rollOverColor: #CEDBEF;
    selectionColor: #7FCEFF;
}
```

File: `dark.css`
```css
/* Dark theme */
/* Global styles */
global {
    color: #FFFFFF;
    chromeColor: #2B2B2B;
    accentColor: #00ccff;
}

s|WindowedApplication {
    backgroundColor: #444444;
}

.largerFont, .h2 {
    relFontSize: 3.5;
}

s|Button {
    color: accent(10);
}

s|List {
    contentBackgroundColor: #303030;
    alternatingItemColors: #303030;
    rollOverColor: accent (0.5, 0.4, 1.01); 
    selectionColor: accent(0.5);
}
```