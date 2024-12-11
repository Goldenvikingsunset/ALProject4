Business Central Vendor Rating System
A comprehensive vendor performance management solution for Microsoft Dynamics 365 Business Central that enables automated vendor rating, tier-based classification, and performance tracking.
Process Flows
Rating Calculation
mermaidCopyflowchart TD
    A[Purchase Receipt Posted] --> B{Is Rating Enabled?}
    B -->|Yes| C[Create Rating Entry]
    B -->|No| Z[End]
    C --> D[Calculate Scores]
    D --> E[Schedule Score]
    D --> F[Quality Score]
    D --> G[Quantity Score]
    E & F & G --> H[Calculate Total Score]
    H --> I[Determine Rating]
    I --> J[Update History]
    J --> K[Calculate Points]
    K --> L[Update Tier]
    L --> M{Tier Changed?}
    M -->|Yes| N[Send Notification]
    M -->|No| O[End Process]
Tier Assignment
mermaidCopyflowchart TD
    A[Start Tier Review] --> B[Calculate Current Points]
    B --> C{Points >= 2000?}
    C -->|Yes| D[Assign Platinum]
    C -->|No| E{Points >= 1000?}
    E -->|Yes| F[Assign Gold]
    E -->|No| G{Points >= 500?}
    G -->|Yes| H[Assign Silver]
    G -->|No| I[Assign Bronze]
    D & F & H & I --> J[Calculate Next Tier Points]
    J --> K[Update Vendor Record]
    K --> L[Update Priority Level]
Features

Automated vendor performance rating
Tier-based vendor classification (Bronze to Platinum)
Points accumulation system
Performance history tracking
Automated tier progression
Priority level management

Setup

Deploy the extension to your Business Central environment
Open Vendor Rating Setup
Run Initialize Setup
Configure rating scales and variances
Set up vendor tiers
Begin rating calculations

Usage

Ratings are automatically calculated on receipt posting
Tiers are updated based on point accumulation
View vendor performance in Vendor Card
Track progression through tier system
Monitor vendor statistics in factbox

Technical Requirements

Microsoft Dynamics 365 Business Central
Compatible with 2022 Wave 2 and later

Contributing
Contributions welcome! Please read the contributing guidelines before submitting pull requests.
License
MIT License
Support
For issues and feature requests, please use the GitHub issue tracker.
