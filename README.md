[![Lifecycle:Stable](https://img.shields.io/badge/Lifecycle-Stable-97ca00)](https://github.com/bcgov/repomountie/blob/master/doc/lifecycle-badges.md)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

BCDS-DIP Comparison Dashboard
============================

## Overview

This code supports a dashboard that researchers can use to determine the coverage of the BC Demographic Survey overall as well as specific demographic variables compared to DIP datasets.

## Usage

* To produce a dashboard:
    * Run the `run_first.R` script to produce the necessary data files in your local space. 
    * Run `app/app.R` to produce the dashboard. Any updates to the dashboard should be made in this file. 

## Structure

Code for this project is structured as follows:

* Main folder: contains the stand-alone `run_first.R` script to produce data files.
* `app`: contains the shiny R code to produce the actual dashboard.
* `app/R`: contains extra functions called by `app.R`, as well as global variables 
required for the app. Also contains the technical documentation support materials. 
* `app/www`: contains any images, fonts, and extra materials used in the dashboard. 

## Requirements

* This project is built in R, and utilizes many standard R packages such as those found in the tidyverse and typical shiny products, as well as some BC specific packages:

    * [bcsapps](https://github.com/bcgov/bcsapps) to produce BC Stats specific themes and layouts.
    * [safepaths](https://github.com/bcgov/safepaths) to provide safe methods of linking to data stored in secure locations.
    
## Project Status

The project is complete, no further changes are expected. 

* This dashboard is the final product of the Data Innovation Program project `23-g06: An Evaluation of the Strengths and Limitations of BCDS Data Available in DIP.`
* Findings from this project are published in the [BC Demographic Survey: DIP Linkage Rates dashboard](https://bcstats.shinyapps.io/bc-demographic-survey-dip-data-linkage-rates/). 
* Data powering this dashboard can be found on the [BC Data Catalogue](https://catalogue.data.gov.bc.ca/dataset/bc-demographic-survey-dip-data-linkage-rates)

## Getting Help or Reporting an Issue

To report bugs/issues/feature requests, please file an [issue](https://github.com/bcgov/bcds-dip-compare/issues/).

## How to Contribute

If you would like to contribute, please see our [CONTRIBUTING](CONTRIBUTING.md) guidelines.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

## License

```
Copyright 2023 Province of British Columbia

Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.
```
---
*This project was created using the [bcgovr](https://github.com/bcgov/bcgovr) package.* 
