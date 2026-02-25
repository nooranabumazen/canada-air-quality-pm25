# Clearing Canada's Air: Three Decades of PM2.5

Interactive dashboard analyzing 34 years of Canada's PM2.5 emissions (1990–2023), built with R Flexdashboard and Plotly. Uses APEI, NAPS, and IQAir data to explore national trends, city-level air quality, and the growing wildfire threat.

![R](https://img.shields.io/badge/R-4.0+-276DC3?logo=r&logoColor=white)
![Plotly](https://img.shields.io/badge/Plotly-Interactive-3F4F75)
![License](https://img.shields.io/badge/License-MIT-green)

<div align="center">

[![View Dashboard](https://img.shields.io/badge/📊_View_Live_Dashboard-c24b3f?style=for-the-badge&logoColor=white)](https://nooranabumazen.github.io/canada-air-quality-pm25/)

</div>

## Why This Matters

Canada's air quality policy is at a crossroads. Decades of regulation have cut industrial PM2.5, but urbanization-driven dust and climate-fueled wildfires are undoing that progress. This report is designed for public health researchers, environmental policy analysts, and municipal planners who need to understand:

- **Where regulation is working** — combustion sources like firewood and coal are success stories worth studying
- **Where it's failing** — road and construction dust have climbed 80%+ despite overall emission declines
- **The wildfire gap** — Canada's official emissions inventory excludes wildfire PM2.5, masking the single largest acute exposure risk
- **City-level disparities** — Edmonton residents breathed nearly double the legal limit in 2023 while Halifax stayed relatively clean

The 2023 wildfire season (when Canada became North America's most polluted country for the first time) makes this analysis especially urgent for climate adaptation planning.

## Dashboard Pages

| Page | What It Shows |
|---|---|
| **Background** | What is PM2.5, why it matters, health impacts ($114B/year, 15,300 deaths) |
| **National Picture** | 34-year emissions by source — stacked area + winners & losers |
| **COVID & Coal** | The 2020 pandemic dip and Ontario's coal phase-out (96% reduction) |
| **The Elephant in the Room** | Wildfire PM2.5 vs. all human sources — 2023 fires produced ~8× anthropogenic total |
| **Across Canada's Cities** | 8 cities coast-to-coast, interactive filters, CAAQS/WHO standard comparison |
| **Wildfire Wildcard** | National avg PM2.5 concentration vs. area burned (dual-axis) |
| **Methodology** | Data sources, standards, limitations, and sourcing transparency |

## Project Structure

```
canada-pm25-report/
├── canada_pm25_report.Rmd       # Flexdashboard report (knit to produce HTML)
├── data/
│   └── canada_pm25_data.xlsx    # All datasets (6 sheets)
├── scripts/
│   └── prepare_data.R           # Data pipeline with full source documentation
└── README.md
```

## Data

All data lives in a single Excel file with 6 sheets:

| Sheet | Source | Description |
|---|---|---|
| `national_emissions` | APEI 2025, Table 2-3 | PM2.5 by source category, 1990–2023 (kt) |
| `electric_utilities` | APEI 2025, subsector data | Coal phase-out impact on power sector PM2.5 |
| `wildfire_estimates` | CNFDB + ECCC/UNDRR emission factors | Estimated wildfire PM2.5 vs. anthropogenic |
| `area_burned` | National Forestry Database / CNFDB | Annual hectares burned, 1990–2023 |
| `city_pm25` | NAPS + IQAir 2023 Report | Ambient PM2.5 for 8 cities, 2014–2023 (µg/m³) |
| `fire_impact` | ECCC CESI indicators + CNFDB | National avg concentration vs. fire severity |

### Data Sourcing Note

National emissions data was transcribed from published APEI tables (ECCC does not expose a stable download URL for sector-level CSV data). City PM2.5 values were compiled from NAPS annual summaries, provincial air quality reports, and the IQAir 2023 World Air Quality Report. Wildfire PM2.5 estimates are derived (area burned × ~713 kt/Mha emission factor). See `scripts/prepare_data.R` for full documentation of every source, methodology notes, and instructions for refreshing from raw ECCC data files when available.

## Requirements

```r
install.packages(c("flexdashboard", "plotly", "readxl", "dplyr", "tidyr", "htmltools"))
```

## Usage

1. Clone the repo
2. Open `canada_pm25_report.Rmd` in RStudio
3. Click **Knit** → produces a self-contained HTML dashboard
4. To regenerate the data file: `source("scripts/prepare_data.R")` (requires `writexl`)

## Key Findings

- **Total PM2.5 fell 15%** from 1990 to 2023 — but road dust (+82%) and construction dust (+80%) partially offset gains
- **Ontario's coal phase-out** cut electric utility PM2.5 by 96% (49 kt → 1.8 kt)
- **2023 wildfires produced ~10,700 kt of PM2.5** — nearly 8× Canada's entire annual anthropogenic total
- **Edmonton hit 16.6 µg/m³ in 2023** — almost double the CAAQS standard of 8.8
- **No major Canadian city meets the WHO guideline** of 5 µg/m³

## Author

**Nooran Abu-Mazen** · MSc Biology (Bioinformatics), University of Waterloo
