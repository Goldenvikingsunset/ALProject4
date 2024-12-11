codeunit 50106 "Vendor Tier Management"
{
    procedure UpdateVendorTier(VendorNo: Code[20])
    var
        Vendor: Record Vendor;
        VendorTierSetup: Record "Vendor Tier Setup";
        NextTier: Record "Vendor Tier Setup";
    begin
        if not Vendor.Get(VendorNo) then
            exit;

        Vendor.CalcFields("Current Points");

        // Find the appropriate tier based on points
        VendorTierSetup.Reset();
        VendorTierSetup.SetCurrentKey("Minimum Points"); // Ensure we're ordered by points ascending
        VendorTierSetup.SetFilter("Minimum Points", '<=%1', Vendor."Current Points");

        // FindLast will now get us the highest tier where minimum points is <= current points
        if VendorTierSetup.FindLast() then begin
            if Vendor."Current Tier Code" <> VendorTierSetup."Tier Code" then begin
                Vendor."Current Tier Code" := VendorTierSetup."Tier Code";

                // Find next tier
                NextTier.Reset();
                NextTier.SetCurrentKey("Minimum Points");
                NextTier.SetFilter("Minimum Points", '>%1', Vendor."Current Points");
                if NextTier.FindFirst() then
                    Vendor."Next Tier Points Required" := NextTier."Minimum Points" - Vendor."Current Points"
                else
                    Vendor."Next Tier Points Required" := 0;

                Vendor.Modify(true);
                SendTierChangeNotification(Vendor, VendorTierSetup);
            end;
        end;
    end;

    local procedure SendTierChangeNotification(Vendor: Record Vendor; NewTier: Record "Vendor Tier Setup")
    var
        TierChangeNotification: Notification;
    begin
        Vendor.CalcFields("Current Points"); // Ensure we have the latest points
        TierChangeNotification.Message :=
            StrSubstNo('Vendor %1 has reached %2 tier with %3 points. (Priority Level: %4)',
                      Vendor.Name, NewTier."Tier Code", Vendor."Current Points",
                      Format(NewTier."Priority Level"));
        TierChangeNotification.Send();
    end;

    procedure InitializeDefaultTiers()
    var
        VendorTierSetup: Record "Vendor Tier Setup";
    begin
        if not VendorTierSetup.IsEmpty then
            exit;

        InsertTier('BRONZE', 'Bronze Tier', 0, 10);
        InsertTier('SILVER', 'Silver Tier', 500, 20);
        InsertTier('GOLD', 'Gold Tier', 1000, 30);
        InsertTier('PLATINUM', 'Platinum Tier', 2000, 40);
    end;

    local procedure InsertTier(TierCode: Code[20]; Description: Text[100];
                             MinPoints: Integer; PriorityLevel: Integer)
    var
        VendorTierSetup: Record "Vendor Tier Setup";
    begin
        VendorTierSetup.Init();
        VendorTierSetup."Tier Code" := TierCode;
        VendorTierSetup.Description := Description;
        VendorTierSetup."Minimum Points" := MinPoints;
        VendorTierSetup."Priority Level" := PriorityLevel;
        VendorTierSetup.Insert();
    end;
}