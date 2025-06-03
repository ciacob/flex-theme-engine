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
  
- Setting skin class names via `ClassReference("com.example.MyClass")`, **but** you must make sure that `MyClass` is linked and compiled, e.g.:
```actionscript
import com.example.MyClass
// ...
private var helper1:MyClass;
```


### 4. FlexSkins

#### `IconButtonSkin.mxml`

This is an improved Button class with support for an FXG icon and text. The icon is colorized using the `color` style, and the button background is colorized using the `chromeColor` **while preserving label and icon visibility** (unlike the OOB solution).

To populate the button, one has three options:
1. `<s:Button label="my text" />`
2. `<s:Button content="{myFxgInstance}" />`
3. `<s:Button content="{[myFxgInstance, 'my text']}" />`
4. `<s:Button content="{['my text', myFxgInstance]}" />`

Other combinations work as well, such as setting the text or icon as the lone member of the Array, or using `content` instead of `label`, etc.

Other improvements:
- The space around the content (label and/or icon) is computed as a factor of the current font size.
- Order of text and icon in the Array reflects in their positioning in the button.

-----

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
