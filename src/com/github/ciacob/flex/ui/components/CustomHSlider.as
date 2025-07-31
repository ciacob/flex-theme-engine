package com.github.ciacob.flex.ui.components {
    
    import spark.components.HSlider;

    [Style(name = "trackBorderColor", type = "uint", format = "Color", inherit = "false")]
    [Style(name = "trackColor", type = "uint", format = "Color", inherit = "false")]
    [Style(name = "thumbBorderColor", type = "uint", format = "Color", inherit = "false")]
    [Style(name = "thumbColor", type = "uint", format = "Color", inherit = "false")]
    [Style(name = "cornerRadius", type = "uint", inherit = "false")]

    public class CustomHSlider extends HSlider {
        function CustomHSlider () {
            super();
        }
    }
}