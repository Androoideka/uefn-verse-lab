using { SimulationExtensions }
using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }

ItemExtensions<public> := module:
    equipper<public> := class(monitorable):
        Granter<public>:item_granter_device
        Checker<public>:conditional_button_device
        Player<public>:player

        Update<override>():void =
            if (not Checker.IsHoldingItem[Player]):
                Granter.GrantItem(Player)