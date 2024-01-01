using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath}
using { /Verse.org/Colors }

GUIExtensions<public> := module:
    ToUIMessage<public><localizes>(Text:string)<varies>:message = "{Text}"

    ToUIMessage<public><localizes>(Number:int)<varies>:message = "{Number}"

    CreateBackground<public><constructor>(Color:color)<transacts> :=
        color_block:
            DefaultColor := Color
            DefaultOpacity := 0.6

    (Widgets:[]widget).Stack<public><constructor>()<transacts> :=
        overlay:
            Slots := for (Widget : Widgets):
                overlay_slot{Widget := Widget}

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