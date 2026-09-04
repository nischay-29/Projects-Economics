# India Inflation Analysis: CPI vs WPI vs GDP Deflator

## Overview

This project examines the relationship between **CPI inflation, WPI
inflation, and GDP-deflator inflation in India** using quarterly data.

The analysis focuses on whether consumer and wholesale price measures
explain movements in the GDP deflator, and whether this relationship
changes around major periods such as **2016 and 2020**.

## Research Question

> How closely are CPI and WPI inflation associated with GDP-deflator
> inflation in India?

## Data

The dataset covers quarterly observations from **2013-14 Q4 to 2025-26
Q2**.

-   **CPI** --- Consumer Price Index
-   **WPI** --- Wholesale Price Index
-   **GDP Deflator** --- calculated from nominal and real GDP

Monthly CPI and WPI data were converted into fiscal-quarter averages.
Inflation rates were calculated as year-on-year changes.

## Methodology

The analysis includes:

-   Quarterly inflation data construction
-   Correlation analysis
-   OLS regression
-   CPI-only and WPI-only models
-   Combined CPI + WPI model
-   Lagged inflation models
-   Quadratic WPI specification
-   Regression diagnostic tests
-   Structural-break analysis using Chow tests and interaction terms

## Key Results

  Model             R²
  ------------ -------
  CPI only       15.6%
  WPI only       70.3%
  CPI + WPI      74.0%
  WPI + WPI²     71.5%

**Main finding:** WPI inflation has a substantially stronger association
with GDP-deflator inflation than CPI inflation over the sample period.

The combined CPI + WPI model provides the highest explanatory power
among the main specifications.

## Structural Break Analysis

A possible break around **2016** provides marginal evidence of parameter
instability:

-   Chow F-statistic: **2.91**
-   p-value: **0.065**

This is significant at the 10% level but not at the conventional 5%
level.

The proposed **2020 break does not provide statistically significant
evidence of a structural break**.



## Tools

-   **Microsoft Excel** --- data cleaning and quarterly data
    construction
-   **R** --- regression and econometric analysis
-   **RStudio** --- statistical workflow
-   **ggplot2** --- visualization
-   **lmtest** --- regression diagnostics

## Limitations

The regressions identify **statistical associations rather than causal
relationships**.

The sample contains 47 quarterly observations, so the results should be
interpreted with appropriate caution. Structural-break tests are also
sensitive to the number of observations around the proposed breakpoint.

## Conclusion

The analysis shows a clear difference between consumer- and
wholesale-price measures of inflation.

**WPI inflation is much more closely associated with GDP-deflator
inflation than CPI inflation over the sample period**, while the
combined CPI + WPI model provides the greatest explanatory power among
the primary models.
