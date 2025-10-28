# Team Screen Dashboard

## Project Overview
This is an interactive dashboard designed to analyze and visualize data gained from performance screenings of competitive teams. The dashboard summarizes testing results to help identify strengths and development areas across a roster and to support coaching and athlete performance decisions.

## Audience
This dashboard is intended for:
- Coaches of the teams
- Individual athletes
- Performance specialists and support staff associated with the team

## Features
- Uses data from six performance tests that capture speed, agility, and power metrics.
- Computes team averages and ranks each athlete on individual tests and overall performance.
- Standardizes scores using z-scores (relative to the team average) to create a composite "Total Score of Athleticism" (TSA).
- Includes an Excel-based dashboard (see the `reports` folder) with three interactive tabs: Team Profile, Athlete Profile, and Athlete Profile Comparison.
- Visualizations include bar charts, radar charts, and box-and-whisker plots to show distributions and comparisons.

## Project Structure
- `/data`: Cleaned raw data used for the project (CSV/Excel files).
- `/reports`: The Excel dashboard and downloadable report files.
- `/visuals`: Screenshots of the dashboard tabs and visual outputs.

## Technologies Used
- Excel (data cleaning, z-score calculations, and the dashboard workbook)
- Standard chart types: bar charts, radar charts, box-and-whisker plots

## How to Use
1. Open the Excel dashboard found in the `/reports` folder.
2. Explore the three main tabs:
   - Team Profile: Shows raw team averages for each test, a bar graph of TSA for all athletes, and box-and-whisker breakdowns for each test (this tab is static/non-interactive).
   - Athlete Profile: Interactive — select an athlete by their assigned number to view raw scores, per-test rankings versus the team, overall TSA ranking, and visualizations of z-scores (bar chart and radar chart).
   - Athlete Profile Comparison: Compare two athletes side-by-side using radar charts and raw-score breakdowns against the team average.
3. See the `/visuals` folder for screenshots of each dashboard tab.
4. Inspect `/data` for the cleaned raw dataset. The raw data was generated from online sample testing protocols and cleaned in Excel prior to analysis.

## Key Insights
- The TSA (Total Score of Athleticism) provides a single standardized measure to rank athletes relative to their team using z-scores.
- Z-score standardization enables fair comparisons across different test metrics (speed, agility, power).
- Visual comparisons (radar charts and box plots) make it easy to identify an athlete's strengths and weaknesses relative to teammates and the team average.