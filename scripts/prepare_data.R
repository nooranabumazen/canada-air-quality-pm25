# ============================================================
# prepare_data.R
# Canada PM2.5 Report — Data Preparation & Sourcing
#
# This script documents the origin, extraction, and any
# transformations applied to every dataset used in the report.
# It writes a single Excel workbook with one sheet per dataset.
#
# Run once to generate data/canada_pm25_data.xlsx, then
# knit canada_pm25_report.Rmd which reads from that file.
# ============================================================

library(writexl)

# ============================================================
# 1. NATIONAL EMISSIONS BY SOURCE CATEGORY
# ============================================================
# Source: Air Pollutant Emissions Inventory (APEI) 2025 Report
#         Environment and Climate Change Canada (ECCC)
#         Published: March 2025
#         Coverage: 1990–2023 (anthropogenic sources only)
#         Reference: Chapter 2, Table 2-3 — PM2.5 emissions by sector
#         URL: https://www.canada.ca/en/environment-climate-change/services/
#              pollutants/air-emissions-inventory-overview.html
#
# Extraction: Values manually transcribed from APEI Table 2-3.
#   - "Paved & Unpaved Roads" = APEI category "Dust — Road"
#   - "Crop Production" = APEI category "Agriculture — Crops"
#   - "Construction Dust" = APEI category "Dust — Construction"
#   - "Other Sources" = sum of remaining categories:
#       Manufacturing, Commercial/Residential (excl. firewood),
#       Transportation, Incineration, Misc.
#   - "Home Firewood" = APEI category "Residential — Wood Combustion"
#   - "Total" = sum of all five categories above
#
# Units: kilotonnes (kt) of PM2.5 per year
# Note: APEI excludes wildfire and open burning from these totals.
#       ECCC recalculates historical values with each new edition,
#       so numbers may differ from earlier APEI reports.

national_emissions <- data.frame(
  year = 1990:2023,
  roads    = c(251,244,261,267,282,287,294,307,312,312,308,325,324,331,327,323,329,347,349,364,361,360,376,390,380,395,399,414,438,443,378,425,432,457),
  crops    = c(673,666,651,637,622,608,594,580,567,553,540,526,507,487,467,447,428,414,401,387,374,361,364,367,370,373,376,372,368,363,359,355,351,346),
  constr   = c(226,218,194,195,215,221,227,255,262,265,276,291,276,276,290,323,306,318,356,323,374,400,429,447,466,411,355,358,378,396,363,356,372,407),
  other    = c(357,335,312,322,317,318,298,281,272,272,266,243,216,227,204,203,178,170,166,152,150,146,144,135,140,133,126,127,123,122,118,124,119,109),
  firewood = c(102,102,108,109,106,103,106,104,83,80,81,70,67,63,66,68,66,78,77,78,69,73,69,75,76,73,69,69,71,68,58,52,55,51)
)
national_emissions$total <- with(national_emissions, roads + crops + constr + other + firewood)


# ============================================================
# 2. ELECTRIC UTILITIES PM2.5
# ============================================================
# Source: APEI 2025 Report, Chapter 2, "Electric Power Generation" subsector
#         Supplemented by Ontario Ministry of the Environment data on
#         the provincial coal phase-out timeline.
#
# Context: Ontario completed its coal phase-out in April 2014
#   (Nanticoke, Lambton, Thunder Bay, Atikokan stations closed 2013-2014).
#   This was the first complete coal phase-out in North America.
#   National electric utility PM2.5 dropped 96% (49 kt → 1.8 kt),
#   largely attributable to Ontario's decision.
#
# Extraction: Selected benchmark years from APEI Table 2-3,
#   subsector "Electric Power Generation (Utilities)".
#   Not every year is available at this subsector granularity;
#   intermediate years interpolated from APEI trend charts.
#
# Units: kilotonnes (kt) of PM2.5

electric_utilities <- data.frame(
  year = c(1990, 1995, 2000, 2005, 2008, 2010, 2012, 2014, 2016, 2018, 2019, 2020, 2021, 2022, 2023),
  pm25 = c(49, 35, 23, 9.1, 6, 4.5, 3.5, 3.2, 2.8, 3.2, 2.8, 2.4, 2.0, 2.1, 1.8)
)


# ============================================================
# 3. WILDFIRE EMISSIONS ESTIMATES
# ============================================================
# Source (area burned): Canadian National Fire Database (CNFDB)
#   Natural Resources Canada, Canadian Forest Service
#   URL: https://cwfis.cfs.nrcan.gc.ca/ha/nfdb
#
# Source (emission factor): UNDRR / ECCC joint analysis (2023)
#   Estimated emission factor: ~713 kt PM2.5 per million hectares burned
#   This is a rough national average; actual emissions vary by
#   forest type, fire intensity, moisture content, and burn severity.
#
# Methodology:
#   wildfire_pm25 = area_burned_mha × 713
#   This produces an ORDER-OF-MAGNITUDE estimate, not a precise figure.
#   The APEI does NOT include wildfire emissions in its main inventory.
#   APEI tracks only "prescribed burns" under its Fires category.
#
# Anthropogenic comparison values: Total from national_emissions sheet
#   for matching years.
#
# Note: Not all years are included — selected years where both
#   wildfire area and anthropogenic totals are available.
#
# Units: area_burned_mha = million hectares
#        wildfire_pm25 = kilotonnes (kt)
#        anthropogenic_pm25 = kilotonnes (kt) from APEI

wf_years <- c(1990,1995,2000,2002,2004,2006,2008,2010,2012,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023)
wf_area  <- c(1.1,6.6,0.6,2.8,3.3,2.0,1.7,3.0,2.1,3.5,3.9,1.4,3.4,2.3,1.8,0.6,4.0,1.5,15.0)

wildfire_estimates <- data.frame(
  year = wf_years,
  area_burned_mha = wf_area,
  wildfire_pm25 = round(wf_area * 713),
  anthropogenic_pm25 = c(1609,1537,1471,1390,1354,1339,1349,1282,1382,1399,1385,1349,1383,1378,1392,1276,1317,1329,1370)
)


# ============================================================
# 4. AREA BURNED — FULL ANNUAL SERIES
# ============================================================
# Source: Canadian National Fire Database (CNFDB)
#   Natural Resources Canada, Canadian Forest Service
#   URL: https://cwfis.cfs.nrcan.gc.ca/ha/nfdb
#
# Coverage: 1990–2023, annual totals for all of Canada
# Note: 2023 was the worst fire season since records began (~1970),
#   with ~15 million hectares burned. Previous worst was 1995 at 6.6M ha.
#
# Units: million hectares

area_burned <- data.frame(
  year = 1990:2023,
  burned_mha = c(1.1,0.9,0.7,1.7,6.3,6.6,1.8,0.6,4.7,1.6,0.6,0.6,2.8,1.7,3.3,1.7,2.0,1.5,1.7,0.8,3.0,2.6,1.9,4.2,3.5,3.9,1.4,3.4,2.3,1.8,0.6,4.0,1.5,15.0)
)


# ============================================================
# 5. CITY-LEVEL PM2.5 CONCENTRATIONS
# ============================================================
# Sources:
#   Primary: National Air Pollution Surveillance (NAPS) Program
#     ECCC, annual monitoring station data
#     URL: https://www.canada.ca/en/environment-climate-change/services/
#          air-pollution/monitoring-networks-data/national-air-pollution-program.html
#
#   Supplementary: IQAir 2023 World Air Quality Report
#     Used for 2023 values and cross-validation
#     URL: https://www.iqair.com/world-air-quality-report
#
#   Additional validation:
#     - Alberta Air Quality Report 2023 (Edmonton, Calgary)
#     - Ontario Air Quality Report 2023 (Toronto, Ottawa)
#     - ScienceDirect spatiotemporal PM2.5 trends study (2010-2016)
#
# Metric: Annual average PM2.5 concentration (µg/m³)
#   This is ambient concentration (what people breathe),
#   NOT emissions (what is released). The relationship between
#   emissions and concentrations depends on meteorology, geography,
#   and transboundary transport.
#
# City selection: 8 major cities chosen for geographic coverage
#   (coast to coast) and data availability:
#   - Western: Vancouver, Calgary, Edmonton, Winnipeg
#   - Central: Toronto, Ottawa, Montreal
#   - Atlantic: Halifax
#
# Standards for reference:
#   - CAAQS (Canadian Ambient Air Quality Standard): 8.8 µg/m³ annual
#   - WHO guideline (2021 update): 5.0 µg/m³ annual
#
# Note on IQAir data: IQAir incorporates both government monitors
#   and low-cost sensor networks. Values may differ slightly from
#   NAPS-only readings. 2023 values are heavily influenced by
#   wildfire smoke, especially for western cities.
#
# IQAir 2023 finding: Canada was the most polluted country in
#   North America for the first time, with the continent's 13 most
#   polluted cities all located within Canada.

city_pm25 <- data.frame(
  year = rep(2014:2023, 8),
  city = rep(c("Vancouver","Calgary","Edmonton","Winnipeg","Toronto","Ottawa","Montreal","Halifax"), each = 10),
  region = rep(c("Western","Western","Western","Western","Central","Central","Central","Atlantic"), each = 10),
  pm25 = c(
    # Vancouver (BC) — NAPS station: Vancouver International Airport #2
    5.8, 5.5, 5.2, 6.0, 6.8, 6.1, 5.0, 5.4, 5.6, 8.4,
    # Calgary (AB) — NAPS station: Calgary Central / Alberta AQ Report
    7.5, 7.0, 6.8, 7.4, 7.8, 7.2, 5.8, 6.6, 7.0, 12.8,
    # Edmonton (AB) — NAPS station: Edmonton Central / Alberta AQ Report
    # Highest baseline among major cities due to winter inversions + oil & gas
    8.2, 7.8, 7.2, 8.0, 8.5, 7.4, 6.0, 7.2, 7.6, 16.6,
    # Winnipeg (MB) — NAPS station: Winnipeg Ellen St.
    6.5, 6.2, 5.9, 6.6, 6.4, 6.3, 5.4, 5.8, 6.0, 9.8,
    # Toronto (ON) — NAPS station: Toronto West / Ontario AQ Report
    7.8, 7.3, 7.0, 7.6, 8.0, 7.4, 6.2, 6.8, 7.2, 10.1,
    # Ottawa (ON) — NAPS station: Ottawa Downtown
    6.5, 6.0, 5.8, 6.4, 6.6, 6.2, 5.2, 5.8, 6.2, 9.7,
    # Montreal (QC) — NAPS station: Montreal Drummond
    7.6, 7.2, 6.8, 7.2, 7.5, 7.0, 5.8, 6.5, 6.8, 10.5,
    # Halifax (NS) — NAPS station: Halifax Downtown
    # Typically cleanest major city; Atlantic air dilutes pollutants
    6.2, 5.8, 5.5, 5.7, 6.0, 5.8, 4.8, 5.2, 5.4, 7.6
  )
)


# ============================================================
# 6. WILDFIRE IMPACT ON AIR QUALITY
# ============================================================
# Source: NAPS national average PM2.5 concentrations (annual)
#   combined with CNFDB area burned data
#
# Purpose: Shows the relationship between wildfire severity
#   and what Canadians actually breathe. Unlike the emissions data
#   in sheets 1-3, this is CONCENTRATION data (µg/m³).
#
# Note: 2023 was the first year the national average exceeded
#   the CAAQS standard of 8.8 µg/m³ in the NAPS record.
#   Peak daily concentrations were much higher (many cities
#   exceeded 100 µg/m³ during smoke events).
#
# Units: nat_avg_pm25 = µg/m³ (annual average)
#        area_burned_mha = million hectares

fire_impact <- data.frame(
  year = 2009:2023,
  nat_avg_pm25 = c(5.9, 6.0, 5.8, 5.6, 5.8, 5.7, 5.5, 5.6, 6.5, 6.8, 5.8, 5.4, 5.6, 6.0, 9.5),
  area_burned_mha = c(0.8, 3.0, 2.6, 1.9, 4.2, 3.5, 3.9, 1.4, 3.4, 2.3, 1.8, 0.6, 4.0, 1.5, 14.0)
)


# ============================================================
# WRITE TO EXCEL
# ============================================================
dir.create("data", showWarnings = FALSE)

write_xlsx(
  list(
    national_emissions = national_emissions,
    electric_utilities = electric_utilities,
    wildfire_estimates = wildfire_estimates,
    area_burned        = area_burned,
    city_pm25          = city_pm25,
    fire_impact        = fire_impact
  ),
  path = "data/canada_pm25_data.xlsx"
)

cat("Wrote data/canada_pm25_data.xlsx with 6 sheets:\n")
cat("  1. national_emissions  — APEI source categories (1990-2023)\n")
cat("  2. electric_utilities  — Coal phase-out story (selected years)\n")
cat("  3. wildfire_estimates  — Estimated wildfire PM2.5 vs anthropogenic\n")
cat("  4. area_burned         — CNFDB annual area burned (1990-2023)\n")
cat("  5. city_pm25           — 8 cities, NAPS/IQAir (2014-2023)\n")
cat("  6. fire_impact         — National avg concentration vs fires (2009-2023)\n")
