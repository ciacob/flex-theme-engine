package com.github.ciacob.flex.ui.components {
    import spark.components.ProgressBar;

    [Style(name = "borderColor", type = "uint", format = "Color", inherit = "false")]
    [Style(name = "trackColor", type = "uint", format = "Color", inherit = "false")]
    [Style(name = "fillColor", type = "uint", format = "Color", inherit = "false")]
    [Style(name = "cornerRadius", type = "uint", inherit = "false")]
    [Style(name = "minTrackHeight", type = "uint", inherit = "false")]
    [Style(name = "labelStyle", type = "String", inherit = "false")]

    public class CustomProgressBar extends ProgressBar {
        public function CustomProgressBar () {
            super();
        }
    }
}
