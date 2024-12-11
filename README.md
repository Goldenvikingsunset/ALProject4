# Business Central Vendor Rating System

A comprehensive vendor performance management solution for Microsoft Dynamics 365 Business Central that enables automated vendor rating, tier-based classification, and performance tracking.

## Process Flows

### Rating Calculation
```mermaid
flowchart TD
    A["Purchase Receipt Posted"] -->|"Post"| B{"Is Rating Enabled?"}
    B -->|"Yes"| C["Create Rating Entry"]
    B -->|"No"| Z["End"]
    C --> D["Calculate Scores"]
    D --> E["Schedule Score"]
    D --> F["Quality Score"]
    D --> G["Quantity Score"]
    E & F & G --> H["Calculate Total Score"]
    H --> I["Determine Rating"]
    I --> J["Update History"]
    J --> K["Calculate Points"]
    K --> L["Update Tier"]
    L --> M{"Tier Changed?"}
    M -->|"Yes"| N["Send Notification"]
    M -->|"No"| O["End Process"]

    style A fill:#f9f,stroke:#333,stroke-width:2px
    style Z fill:#f96,stroke:#333,stroke-width:2px
    style B fill:#bbf,stroke:#333,stroke-width:2px
    style M fill:#bbf,stroke:#333,stroke-width:2px
```

### Tier Assignment
```mermaid
flowchart TD
    A["Start Tier Review"] --> B["Calculate Current Points"]
    B --> C{"Points >= 2000?"}
    C -->|"Yes"| D["Assign Platinum"]
    C -->|"No"| E{"Points >= 1000?"}
    E -->|"Yes"| F["Assign Gold"]
    E -->|"No"| G{"Points >= 500?"}
    G -->|"Yes"| H["Assign Silver"]
    G -->|"No"| I["Assign Bronze"]
    D & F & H & I --> J["Calculate Next Tier Points"]
    J --> K["Update Vendor Record"]
    K --> L["Update Priority Level"]

    style C fill:#bbf,stroke:#333,stroke-width:2px
    style E fill:#bbf,stroke:#333,stroke-width:2px
    style G fill:#bbf,stroke:#333,stroke-width:2px
```

### System Components
```mermaid
graph TB
    subgraph "Setup Tables"
        A["Vendor Rating Setup"]
        B["Rating Scale Setup"]
        C["Delivery Variance"]
        D["Quantity Variance"]
        E["Vendor Tier Setup"]
    end
    
    subgraph "Transaction Processing"
        F["Purchase Orders"]
        G["Receipt Posting"]
        H["Return Orders"]
    end
    
    subgraph "Rating System"
        I["Rating Entry"]
        J["Rating History"]
        K["Point Calculation"]
        L["Tier Management"]
    end
    
    F --> G
    G --> I
    H --> I
    I --> K
    K --> L
    A --> I
    B --> I
    C --> I
    D --> I
    E --> L
    I --> J

    style I fill:#f9f,stroke:#333,stroke-width:2px
    style L fill:#f9f,stroke:#333,stroke-width:2px
```

## Features
- Automated vendor performance rating
- Tier-based vendor classification (Bronze to Platinum)
- Points accumulation system
- Performance history tracking
- Automated tier progression
- Priority level management

## Setup
1. Deploy the extension to your Business Central environment
2. Open Vendor Rating Setup
3. Run Initialize Setup
4. Configure rating scales and variances
5. Set up vendor tiers
6. Begin rating calculations

## Usage
- Ratings are automatically calculated on receipt posting
- Tiers are updated based on point accumulation
- View vendor performance in Vendor Card
- Track progression through tier system
- Monitor vendor statistics in factbox

## Technical Requirements
- Microsoft Dynamics 365 Business Central
- Compatible with 2022 Wave 2 and later

## Contributing
Contributions welcome! Please read the contributing guidelines before submitting pull requests.

## License
MIT License

## Support
For issues and feature requests, please use the GitHub issue tracker.
