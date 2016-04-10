package
{
    import feathers.controls.Check;
    import feathers.controls.Label;
    import feathers.controls.LayoutGroup;
    import feathers.controls.ScrollContainer;
    import feathers.controls.Slider;
    import feathers.controls.TextInput;
    import feathers.layout.HorizontalLayout;
    import feathers.layout.VerticalLayout;
    import feathers.themes.MetalWorksMobileTheme;

    import flash.geom.Point;
    import flash.geom.Rectangle;

    import starling.display.Image;
    import starling.display.Quad;
    import starling.display.Sprite;
    import starling.events.Event;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.extensions.rendererPlus.Material;
    import starling.extensions.rendererPlus.display.RendererPlus;
    import starling.extensions.rendererPlus.lights.AmbientLight;
    import starling.extensions.rendererPlus.lights.PointLight;
    import starling.extensions.rendererPlus.lights.rendering.LightStyle;
    import starling.extensions.rendererPlus.lights.rendering.PointLightStyle;
    import starling.textures.Texture;

    public class SpriteIlluminatorStarlingScene extends Sprite
    {
        // Assets

        [Embed(source="assets/character-with-si-logo.png")]
        public static const CHAR:Class;

        [Embed(source="assets/character-with-si-logo_n.png")]
        public static const CHAR_N:Class;

        [Embed(source="assets/wall.png")]
        public static const WALL:Class;

        [Embed(source="assets/wall_n.png")]
        public static const WALL_N:Class;

        [Embed(source="assets/light.png")]
        public static const LIGHT:Class;

        public function SpriteIlluminatorStarlingScene()
        {
            if(!stage)
                addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            else
                onAddedToStage();
        }

        private function onAddedToStage(e:Event = null):void
        {
            setupScene();
            setupUI();
        }

        private var marker:Image;
        private var pointLight:PointLight;
        private var ambient:AmbientLight;
        private var BGMaterial:Material;
        private var charMaterial:Material;

        private var renderer:RendererPlus;

        private function setupScene():void
        {
            var image:Image;
            var tile:Image;

            // Create DeferredShadingContainer

            renderer = new RendererPlus();
            addChild(renderer);

            // Create background wall

            BGMaterial = new Material(Texture.fromEmbeddedAsset(WALL), Texture.fromEmbeddedAsset(WALL_N));
            renderer.addChild(tile = new Image(BGMaterial));
            tile.width = stage.stageWidth;
            tile.height = stage.stageHeight;
            tile.tileGrid = new Rectangle();

            // Create character

            charMaterial = new Material(Texture.fromEmbeddedAsset(CHAR), Texture.fromEmbeddedAsset(CHAR_N));
            renderer.addChild(image = new Image(charMaterial));
            renderer.addOccluder(image);
            image.x = 200;
            image.y = 100;

            // Add ambient light

            ambient = new AmbientLight();
            (ambient.style as LightStyle).color = 0x222222;
            renderer.addChild(ambient);

            // Add point light

            renderer.addChild(pointLight = new PointLight());

            var style:PointLightStyle = pointLight.style as PointLightStyle;
            style.castsShadows = true;
            style.strength = 1.5;
            style.radius = 500;

            // Light marker

            marker = new Image(Texture.fromEmbeddedAsset(LIGHT));
            addChild(marker);
            marker.addEventListener(TouchEvent.TOUCH, onTouch);
            marker.x = stage.stageWidth / 2;
            marker.y = stage.stageHeight / 2;
            onTouch();
        }

        private var UIContainer:ScrollContainer;

        private function setupUI():void
        {
            new MetalWorksMobileTheme(); // !!!

            var layout:VerticalLayout = new VerticalLayout();
            var group:LayoutGroup;
            var hLayout:HorizontalLayout = new HorizontalLayout();
            var cb:Check;
            var label:Label;
            var slider:Slider;

            // Container

            UIContainer = new ScrollContainer();
            UIContainer.horizontalScrollPolicy = ScrollContainer.SCROLL_POLICY_OFF;
            UIContainer.scrollBarDisplayMode = ScrollContainer.SCROLL_BAR_DISPLAY_MODE_FIXED;
            UIContainer.width = 300;
            UIContainer.height = stage.stageHeight;
            UIContainer.x = stage.stageWidth - UIContainer.width;

            var quad:Quad = new Quad(UIContainer.width, UIContainer.height, 0x000000);
            quad.alpha = 0.85;

            UIContainer.backgroundSkin = quad;
            addChild(UIContainer);

            hLayout.gap = 10;
            layout.gap = 15;
            layout.padding = 10;
            UIContainer.layout = layout;

            // Shadows CB

            cb = new Check();
            cb.label = 'Light casts shadows';
            cb.isSelected = true;
            cb.addEventListener(Event.CHANGE,
                    function (e:Event):void
                    {
                        var style:PointLightStyle = pointLight.style as PointLightStyle;
                        style.castsShadows = !style.castsShadows;
                    }
            );
            UIContainer.addChild(cb);

            // Background params

            group = new LayoutGroup();
            group.layout = hLayout;
            group.addChild(getLabel('BG specular power:'));
            group.addChild(label = getLabel());
            UIContainer.addChild(group);
            UIContainer.addChild(slider = getSlider(0, Material.DEFAULT_SPECULAR_POWER * 2, Material.DEFAULT_SPECULAR_POWER));
            bindSlider(label, slider,
                    function (e:Event):void
                    {
                        BGMaterial.specularPower = (e.currentTarget as Slider).value;
                    }
            );

            group = new LayoutGroup();
            group.layout = hLayout;
            group.addChild(getLabel('BG specular intensity:'));
            group.addChild(label = getLabel());
            UIContainer.addChild(group);
            UIContainer.addChild(slider = getSlider(0, Material.DEFAULT_SPECULAR_INTENSITY * 2, Material.DEFAULT_SPECULAR_INTENSITY));
            bindSlider(label, slider,
                    function (e:Event):void
                    {
                        BGMaterial.specularIntensity = (e.currentTarget as Slider).value;
                    }
            );

            // Char params

            group = new LayoutGroup();
            group.layout = hLayout;
            group.addChild(getLabel('Char specular power:'));
            group.addChild(label = getLabel());
            UIContainer.addChild(group);
            UIContainer.addChild(slider = getSlider(0, Material.DEFAULT_SPECULAR_POWER * 2, Material.DEFAULT_SPECULAR_POWER));
            bindSlider(label, slider,
                    function (e:Event):void
                    {
                        charMaterial.specularPower = (e.currentTarget as Slider).value;
                    }
            );

            group = new LayoutGroup();
            group.layout = hLayout;
            group.addChild(getLabel('Char specular intensity:'));
            group.addChild(label = getLabel());
            UIContainer.addChild(group);
            UIContainer.addChild(slider = getSlider(0, Material.DEFAULT_SPECULAR_INTENSITY * 2, Material.DEFAULT_SPECULAR_INTENSITY));
            bindSlider(label, slider,
                    function (e:Event):void
                    {
                        charMaterial.specularIntensity = (e.currentTarget as Slider).value;
                    }
            );

            // Ambient color

            group = new LayoutGroup();
            group.layout = hLayout;
            group.addChild(getLabel('Ambient color:'));
            UIContainer.addChild(group);

            group = new LayoutGroup();
            group.layout = new HorizontalLayout();
            (group.layout as HorizontalLayout).verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;

            group.addChild(getLabel('#  '));
            UIContainer.addChild(group);

            var input:TextInput = new TextInput();
            input.text = '222222';
            input.width = 200;
            input.addEventListener(Event.CHANGE,
                    function (e:Event):void
                    {
                        var text:String = (e.currentTarget as TextInput).text;
                        var color:uint = parseInt(text.indexOf('#') != -1 ? text.split('#')[1] : text, 16);
                        (ambient.style as LightStyle).color = color;
                    }
            );
            group.addChild(input);
        }

        /*--------------------------
         Event handlers
         --------------------------*/

        private function onTouch(e:TouchEvent = null):void
        {
            var touch:Touch = e ? e.getTouch(marker, TouchPhase.MOVED) : null;

            if(touch)
            {
                var pos:Point = touch.getLocation(this);
                marker.x = pos.x - marker.width / 2;
                marker.y = pos.y - marker.height / 2;
            }

            pointLight.x = marker.x + marker.width / 2;
            pointLight.y = marker.y + marker.height / 2;
        }

        /*--------------------------
         UI helpers
         --------------------------*/

        private function getLabel(text:String = ''):Label
        {
            var label:Label = new Label();
            label.text = text;
            return label;
        }

        private function getSlider(min:Number, max:Number, value:Number):Slider
        {
            var slider:Slider = new Slider();
            slider.minimum = min;
            slider.maximum = max;
            slider.value = value;
            slider.width = 250;
            slider.height = 30;
            slider.trackScaleMode = Slider.TRACK_SCALE_MODE_EXACT_FIT;
            slider.thumbProperties.height = 30;
            slider.thumbProperties.width = 30;

            return slider;
        }

        private function bindSlider(label:Label, slider:Slider, callback:Function):void
        {
            label.text = slider.value.toFixed(2);

            slider.addEventListener(Event.CHANGE,
                    function (e:Event):void
                    {
                        label.text = (e.target as Slider).value.toFixed(2);
                    }
            );

            slider.addEventListener(Event.CHANGE, callback);
        }
    }
}