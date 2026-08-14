USE campusx;
SELECT * FROM d2c_marketing_funnel_data
WHERE (checkout_started = 'Yes' AND added_to_cart = 'No')
   OR (added_to_cart = 'Yes' AND viewed_product = 'No')
   OR (purchase_completed = 'Yes' AND checkout_started = 'No');
   
   
-- stage wise count and percentage conversion at each stage


SELECT
  COUNT(*) AS total_sessions,
  SUM(CASE WHEN visited_website = 'Yes' THEN 1 ELSE 0 END) AS visited,
  SUM(CASE WHEN viewed_product = 'Yes' THEN 1 ELSE 0 END) AS viewed,
  SUM(CASE WHEN added_to_cart = 'Yes' THEN 1 ELSE 0 END) AS added_cart,
  SUM(CASE WHEN checkout_started = 'Yes' THEN 1 ELSE 0 END) AS checkout,
  SUM(CASE WHEN purchase_completed = 'Yes' THEN 1 ELSE 0 END) AS purchased,
  ROUND(SUM(CASE WHEN viewed_product='Yes' THEN 1 ELSE 0 END) * 100.0 / SUM(CASE WHEN visited_website='Yes' THEN 1 ELSE 0 END), 2) AS visit_to_view_pct,
  ROUND(SUM(CASE WHEN added_to_cart='Yes' THEN 1 ELSE 0 END) * 100.0 / SUM(CASE WHEN viewed_product='Yes' THEN 1 ELSE 0 END), 2) AS view_to_cart_pct,
  ROUND(SUM(CASE WHEN checkout_started='Yes' THEN 1 ELSE 0 END) * 100.0 / SUM(CASE WHEN added_to_cart='Yes' THEN 1 ELSE 0 END), 2) AS cart_to_checkout_pct,
  ROUND(SUM(CASE WHEN purchase_completed='Yes' THEN 1 ELSE 0 END) * 100.0 / SUM(CASE WHEN checkout_started='Yes' THEN 1 ELSE 0 END), 2) AS checkout_to_purchase_pct,
  ROUND(SUM(CASE WHEN purchase_completed='Yes' THEN 1 ELSE 0 END) * 100.0 / SUM(CASE WHEN visited_website='Yes' THEN 1 ELSE 0 END), 2) AS overall_conversion_pct
FROM d2c_marketing_funnel_data;

-- Drop-off Rate at Each Stage (where's the biggest leak?)



SELECT
  'Visit to View' AS funnel_stage,
  SUM(CASE WHEN visited_website='Yes' THEN 1 ELSE 0 END) - SUM(CASE WHEN viewed_product='Yes' THEN 1 ELSE 0 END) AS users_dropped,
  ROUND(100 - (SUM(CASE WHEN viewed_product='Yes' THEN 1 ELSE 0 END) * 100.0 / SUM(CASE WHEN visited_website='Yes' THEN 1 ELSE 0 END)), 2) AS drop_off_pct
FROM d2c_marketing_funnel_data
UNION ALL
SELECT
  'View to Cart',
  SUM(CASE WHEN viewed_product='Yes' THEN 1 ELSE 0 END) - SUM(CASE WHEN added_to_cart='Yes' THEN 1 ELSE 0 END),
  ROUND(100 - (SUM(CASE WHEN added_to_cart='Yes' THEN 1 ELSE 0 END) * 100.0 / SUM(CASE WHEN viewed_product='Yes' THEN 1 ELSE 0 END)), 2)
FROM d2c_marketing_funnel_data
UNION ALL
SELECT
  'Cart to Checkout',
  SUM(CASE WHEN added_to_cart='Yes' THEN 1 ELSE 0 END) - SUM(CASE WHEN checkout_started='Yes' THEN 1 ELSE 0 END),
  ROUND(100 - (SUM(CASE WHEN checkout_started='Yes' THEN 1 ELSE 0 END) * 100.0 / SUM(CASE WHEN added_to_cart='Yes' THEN 1 ELSE 0 END)), 2)
FROM d2c_marketing_funnel_data
UNION ALL
SELECT
  'Checkout to Purchase',
  SUM(CASE WHEN checkout_started='Yes' THEN 1 ELSE 0 END) - SUM(CASE WHEN purchase_completed='Yes' THEN 1 ELSE 0 END),
  ROUND(100 - (SUM(CASE WHEN purchase_completed='Yes' THEN 1 ELSE 0 END) * 100.0 / SUM(CASE WHEN checkout_started='Yes' THEN 1 ELSE 0 END)), 2)
FROM d2c_marketing_funnel_data;

USE campusx;

-- funnel conversion by channel

SELECT
  channel,
  COUNT(*) AS sessions,
  SUM(CASE WHEN purchase_completed = 'Yes' THEN 1 ELSE 0 END) AS purchases,
  ROUND(SUM(CASE WHEN purchase_completed='Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS conversion_pct
FROM d2c_marketing_funnel_data
GROUP BY channel
ORDER BY conversion_pct DESC;



-- funnel conversion by device

SELECT
  device,
  COUNT(*) AS sessions,
  SUM(CASE WHEN purchase_completed = 'Yes' THEN 1 ELSE 0 END) AS purchases,
  ROUND(SUM(CASE WHEN purchase_completed='Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS conversion_pct
FROM d2c_marketing_funnel_data
GROUP BY device
ORDER BY conversion_pct DESC;

-- new vs returning users

SELECT
  user_type,
  COUNT(*) AS sessions,
  SUM(CASE WHEN added_to_cart='Yes' THEN 1 ELSE 0 END) AS cart_adds,
  SUM(CASE WHEN purchase_completed = 'Yes' THEN 1 ELSE 0 END) AS purchases,
  ROUND(SUM(CASE WHEN purchase_completed='Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS conversion_pct
FROM d2c_marketing_funnel_data
GROUP BY user_type
ORDER BY conversion_pct DESC;

-- metro vs non metro region

SELECT
  region,
  COUNT(*) AS sessions,
  SUM(CASE WHEN purchase_completed = 'Yes' THEN 1 ELSE 0 END) AS purchases,
  ROUND(SUM(CASE WHEN purchase_completed='Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS conversion_pct,
  ROUND(AVG(CASE WHEN purchase_completed='Yes' THEN order_value END), 2) AS avg_order_value
FROM d2c_marketing_funnel_data
GROUP BY region;

-- campaign type 
SELECT
  campaign_type,
  COUNT(*) AS sessions,
  SUM(CASE WHEN purchase_completed = 'Yes' THEN 1 ELSE 0 END) AS purchases,
  ROUND(SUM(CASE WHEN purchase_completed='Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS conversion_pct,
  ROUND(SUM(revenue), 2) AS total_revenue
FROM d2c_marketing_funnel_data
GROUP BY campaign_type
ORDER BY total_revenue DESC;

-- influence of disvount

SELECT
  discount_applied,
  COUNT(*) AS sessions_with_checkout,
  SUM(CASE WHEN purchase_completed = 'Yes' THEN 1 ELSE 0 END) AS purchases,
  ROUND(SUM(CASE WHEN purchase_completed='Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS conversion_pct,
  ROUND(AVG(order_value), 2) AS avg_order_value
FROM d2c_marketing_funnel_data
WHERE checkout_started = 'Yes'
GROUP BY discount_applied;

USE campusx;
SELECT
  COUNT(*) AS abandoned_checkouts,
  ROUND(SUM(order_value), 2) AS potential_revenue_lost
FROM d2c_marketing_funnel_data
WHERE checkout_started = 'Yes' AND purchase_completed = 'No';

-- best combo
SELECT
  channel,
  device,
  COUNT(*) AS sessions,
  SUM(CASE WHEN purchase_completed = 'Yes' THEN 1 ELSE 0 END) AS purchases,
  ROUND(SUM(CASE WHEN purchase_completed='Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS conversion_pct
FROM d2c_marketing_funnel_data
GROUP BY channel, device
ORDER BY conversion_pct DESC
LIMIT 10;


-- monthly trend

SELECT
  month,
  COUNT(*) AS sessions,
  SUM(CASE WHEN purchase_completed = 'Yes' THEN 1 ELSE 0 END) AS purchases,
  ROUND(SUM(CASE WHEN purchase_completed='Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS conversion_pct,
  ROUND(SUM(revenue), 2) AS total_revenue
FROM d2c_marketing_funnel_data
GROUP BY month
ORDER BY month;


--


SELECT
  channel,
  COUNT(*) AS sessions,
  SUM(CASE WHEN purchase_completed = 'Yes' THEN 1 ELSE 0 END) AS purchases,
  ROUND(SUM(CASE WHEN purchase_completed='Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS conversion_pct,
  ROUND(SUM(revenue), 2) AS total_revenue
FROM d2c_marketing_funnel_data
GROUP BY channel
ORDER BY conversion_pct DESC;

-- device
SELECT
  device,
  COUNT(*) AS sessions,
  SUM(CASE WHEN purchase_completed = 'Yes' THEN 1 ELSE 0 END) AS purchases,
  ROUND(SUM(CASE WHEN purchase_completed='Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS conversion_pct,
  ROUND(SUM(revenue), 2) AS total_revenue
FROM d2c_marketing_funnel_data
GROUP BY device
ORDER BY conversion_pct DESC;

