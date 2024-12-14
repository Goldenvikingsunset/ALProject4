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
        VendorTierSetup.SetCurrentKey("Setup Code", "Minimum Points");
        VendorTierSetup.SetRange("Setup Code", Vendor."Rating Setup Code");
        VendorTierSetup.SetFilter("Minimum Points", '<=%1', Vendor."Current Points");

        // FindLast will get us the highest tier where minimum points is <= current points
        if VendorTierSetup.FindLast() then begin
            Vendor."Current Tier Code" := VendorTierSetup."Tier Code";

            // Find next tier within the same setup code
            NextTier.Reset();
            NextTier.SetRange("Setup Code", Vendor."Rating Setup Code");
            NextTier.SetCurrentKey("Setup Code", "Minimum Points");
            NextTier.SetFilter("Minimum Points", '>%1', Vendor."Current Points");
            if NextTier.FindFirst() then
                Vendor."Next Tier Points Required" := NextTier."Minimum Points" - Vendor."Current Points"
            else
                Vendor."Next Tier Points Required" := 0;

            Vendor.Modify(true);
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

        // Default Tiers
        InsertTier('DEFAULT', 'BRONZE', 'Bronze Tier', 0, 10);
        InsertTier('DEFAULT', 'SILVER', 'Silver Tier', 500, 20);
        InsertTier('DEFAULT', 'GOLD', 'Gold Tier', 1000, 30);
        InsertTier('DEFAULT', 'PLATINUM', 'Platinum Tier', 2000, 40);

        // Manufacturing Tiers
        InsertTier('MANUFACTURING', 'BRONZE', 'Manufacturing Bronze', 0, 15);
        InsertTier('MANUFACTURING', 'SILVER', 'Manufacturing Silver', 750, 25);
        InsertTier('MANUFACTURING', 'GOLD', 'Manufacturing Gold', 1500, 35);
        InsertTier('MANUFACTURING', 'PLATINUM', 'Manufacturing Platinum', 3000, 45);

        // Service Tiers
        InsertTier('SERVICES', 'BRONZE', 'Service Bronze', 0, 5);
        InsertTier('SERVICES', 'SILVER', 'Service Silver', 300, 15);
        InsertTier('SERVICES', 'GOLD', 'Service Gold', 750, 25);
        InsertTier('SERVICES', 'PLATINUM', 'Service Platinum', 1500, 35);

        // Supply Tiers
        InsertTier('SUPPLIES', 'BRONZE', 'Supply Bronze', 0, 12);
        InsertTier('SUPPLIES', 'SILVER', 'Supply Silver', 600, 22);
        InsertTier('SUPPLIES', 'GOLD', 'Supply Gold', 1200, 32);
        InsertTier('SUPPLIES', 'PLATINUM', 'Supply Platinum', 2500, 42);
    end;

    local procedure InsertTier(SetupCode: Code[20]; TierCode: Code[20]; Description: Text[100];
                         MinPoints: Integer; PriorityLevel: Integer)
    var
        VendorTierSetup: Record "Vendor Tier Setup";
    begin
        VendorTierSetup.Init();
        VendorTierSetup."Setup Code" := SetupCode;
        VendorTierSetup."Tier Code" := TierCode;
        VendorTierSetup.Description := Description;
        VendorTierSetup."Minimum Points" := MinPoints;
        VendorTierSetup."Priority Level" := PriorityLevel;
        VendorTierSetup.Insert();
    end;

}