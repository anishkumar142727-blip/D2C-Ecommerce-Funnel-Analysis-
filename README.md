# D2C Marketing Funnel Analysis

Analysis of a 120,000-session D2C e-commerce funnel using SQL and Tableau to identify where users drop off, quantify revenue impact, and evaluate channel/device performance.

## Objective

Understand user behavior across the marketing funnel — visit → view → cart → checkout → purchase — to pinpoint the biggest drop-off stage, quantify the revenue lost to funnel leakage, and evaluate whether acquisition channel, device, or campaign type meaningfully affect conversion.

## Dataset

- **Source:** `d2c_marketing_funnel_data` — session-level e-commerce funnel data
- **Size:** 120,000 sessions
- **Fields:** `channel`, `campaign_type`, `device`, `user_type`, `region`, funnel stage flags (`visited_website`, `viewed_product`, `added_to_cart`, `checkout_started`, `purchase_completed`), `discount_applied`, `order_value`, `revenue`, `month`

## Tools

- **MySQL** — data cleaning, validation, and funnel/segment analysis
- **Tableau Public** — interactive dashboard (funnel visualization, channel/device breakdowns, monthly trend)

## Data Validation

Before analysis, I checked for logical consistency in funnel progression (e.g., a session can't start checkout without having added to cart):

```sql
SELECT * FROM d2c_marketing_funnel_data
WHERE (checkout_started = 'Yes' AND added_to_cart = 'No')
   OR (added_to_cart = 'Yes' AND viewed_product = 'No')
   OR (purchase_completed = 'Yes' AND checkout_started = 'No');
```

**Note:** An earlier version of this analysis was run on a partially-imported dataset (541 rows instead of the true 120,000) due to a MySQL Workbench import failure. Re-validating the row count against the source file caught the discrepancy before drawing conclusions — a reminder to always verify data completeness before analysis, since the partial sample produced misleading channel/device differences that did not hold up at full scale.

## Key Findings

**1. Funnel drop-off is heavily concentrated at one stage**

| Stage | Sessions | Conversion from prior stage |
|---|---|---|
| Visited | 120,000 | — |
| Viewed Product | 77,870 | 64.89% |
| Added to Cart | 27,156 | 34.87% |
| Checkout Started | 16,234 | 59.78% |
| Purchased | 8,181 | 50.39% |

**Overall conversion: 6.82%**

The largest leak is **View → Cart (65.13% drop-off, 50,714 users lost)** — more than any other stage. This is the primary lever for improving overall conversion.

**2. Channel, device, and campaign type show minimal impact at scale**

| Channel | Conversion % |
|---|---|
| Email | 7.31% |
| Organic | 6.81% |
| Social | 6.81% |
| Paid Ads | 6.72% |

Desktop (6.91%) vs. Mobile (6.78%) is similarly flat. These differences are small enough that acquisition channel is **not** the primary conversion lever — funnel/UX improvements matter more than channel reallocation.

**3. Revenue lost to checkout abandonment**

- 8,053 sessions started checkout but did not complete purchase
- **₹40,18,447 (~₹40 lakh)** in potential revenue lost over the analysis period

**4. Data quality flag: `discount_applied`**

Sessions with `discount_applied = 'Yes'` show a 100.00% purchase completion rate (4,462 / 4,462) with zero exceptions. This is not a realistic behavioral pattern — it suggests the field is recorded **after** purchase completion rather than representing a pre-purchase incentive shown to the user. This is called out explicitly rather than presented as a causal "discounts drive conversion" finding.

**5. Monthly trend is stable**

Conversion held steady in a narrow 6.6%–7.06% band across all 6 months (Jul–Dec 2025) — no meaningful seasonal anomaly.

## Business Recommendations

1. **Prioritize product-page → cart UX** — this is the highest-leverage, most statistically reliable improvement area
2. **Investigate checkout abandonment specifically** — ₹40L in recoverable revenue over 6 months is a substantial opportunity (e.g., exit-intent offers, simplified checkout flow, payment method expansion)
3. **Don't reallocate marketing budget based on channel conversion differences** — they're not meaningful at this scale; use other criteria (CAC, LTV) for channel investment decisions
4. **Audit the discount-tracking implementation** before using it in any causal analysis or reporting

## Dashboard

![D2C Funnel Analysis Dashboard](./screenshots/dashboard_overview.png)

Interactive Tableau dashboard includes:
- Funnel overview (session counts at each stage)
- Conversion by channel
- Revenue by campaign type (treemap)
- Channel × Device performance heatmap
- Monthly conversion and revenue trend
- Monthly purchase volume


> To view the screenshot above, save the dashboard image as `screenshots/dashboard_overview.png` in this repo before pushing.

## SQL Queries

Full query set available in [`queries.sql`](./queries.sql), covering funnel calculation, drop-off analysis, channel/device/region/campaign segmentation, discount impact, and revenue-at-risk calculations.
