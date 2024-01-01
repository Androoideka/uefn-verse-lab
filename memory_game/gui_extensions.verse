using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath}
using { /Verse.org/Colors }

GUIExtensions<public> := module:
    ToUIMessage<public><localizes>(Text:string)<varies>:message = "{Text}"

    ToUIMessage<public><localizes>(Number:int)<varies>:message = "{Number}"

    (Color:color).CreateBackground<public><constructor>()<transacts> :=
        color_block:
            DefaultColor := Color
            DefaultOpacity := 0.6
    
    (Widget:widget).StretchToScreenSize<public>()<transacts>:canvas_slot =
        MakeCanvasSlot(Widget, vector2{X := 0.0, Y := 0.0}, ?Size := vector2{X := 1920.0, Y := 1080.0})

    (Widgets:[][]widget).ArrangeGrid<public><constructor>()<transacts> :=
        stack_box:
            Orientation := orientation.Horizontal
            Slots := for (Column : Widgets):
                stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Distribution := option{1.0}
                    Padding := margin{Top := 0.0, Left := 16.0, Right := 16.0, Bottom := 0.0}
                    Widget := stack_box:
                        Orientation := orientation.Vertical
                        Slots := for (Component : Column):
                            stack_box_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Distribution := option{1.0}
                                Padding := margin{Top := 16.0, Left := 0.0, Right := 0.0, Bottom := 16.0}
                                Widget := Component

    CreateUI<public><constructor>(Exit:button_loud, Slots:[]canvas_slot)<transacts> :=
        canvas:
            Slots := array
            {
                MakeCanvasSlot(NamedColors.Beige.CreateBackground(), vector2{X := 0.0, Y := 0.0}, ?Size := vector2{X := 1920.0, Y := 1080.0})
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.85, Y := 0.05}, Maximum := vector2{X := 0.95, Y := 0.1}}
                    Widget := Exit
            } + Slots