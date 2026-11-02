-- SQLite; bind :country to one supplied country.

-- 01_kpis
SELECT COUNT(*) AS sales_records, SUM(units_sold) AS units_sold,
 SUM(revenue) AS recorded_revenue, SUM(margin_amount) AS supplied_margin,
 SUM(margin_amount)/NULLIF(SUM(revenue),0) AS weighted_margin_rate,
 1.0*SUM(units_sold)/NULLIF(COUNT(*),0) AS units_per_record,
 SUM(units_sold*unit_price*discount)/NULLIF(SUM(units_sold*unit_price),0) AS weighted_discount
FROM sales_reporting WHERE country = :country;

-- 02_product_mix
SELECT sku, COUNT(*) AS sales_records, SUM(units_sold) AS units_sold,
 SUM(revenue) AS recorded_revenue,
 SUM(revenue)/NULLIF(SUM(SUM(revenue)) OVER (),0) AS revenue_share,
 SUM(margin_amount)/NULLIF(SUM(revenue),0) AS weighted_margin_rate
FROM sales_reporting WHERE country = :country
GROUP BY sku ORDER BY recorded_revenue DESC;

-- 03_monthly_trend
WITH monthly AS (
 SELECT month_start, SUM(revenue) AS recorded_revenue, SUM(units_sold) AS units_sold
 FROM sales_reporting WHERE country = :country GROUP BY month_start
), previous AS (
 SELECT *, LAG(recorded_revenue) OVER (ORDER BY month_start) AS previous_month_revenue
 FROM monthly
)
SELECT *, (recorded_revenue-previous_month_revenue)/NULLIF(previous_month_revenue,0) AS revenue_mom_change
FROM previous ORDER BY month_start;

-- 04_promotion_comparison
SELECT promotion, discount, COUNT(*) AS sales_records,
 SUM(units_sold) AS units_sold, AVG(units_sold) AS units_per_record,
 SUM(revenue) AS recorded_revenue, AVG(revenue) AS revenue_per_record,
 SUM(margin_amount)/NULLIF(SUM(revenue),0) AS weighted_margin_rate
FROM sales_reporting WHERE country = :country
GROUP BY promotion, discount ORDER BY discount;

-- 05_promotion_within_segments
SELECT sku, channel, promotion, discount, COUNT(*) AS sales_records,
 AVG(units_sold) AS units_per_record, AVG(revenue) AS revenue_per_record
FROM sales_reporting WHERE country = :country
GROUP BY sku, channel, promotion, discount
ORDER BY sku, channel, discount;

-- 06_channel_performance
SELECT channel, COUNT(*) AS sales_records, SUM(units_sold) AS units_sold,
 SUM(revenue) AS recorded_revenue,
 SUM(margin_amount)/NULLIF(SUM(revenue),0) AS weighted_margin_rate
FROM sales_reporting WHERE country = :country
GROUP BY channel ORDER BY recorded_revenue DESC;

-- 07_retailer_performance
SELECT retailer, COUNT(*) AS sales_records, SUM(units_sold) AS units_sold,
 SUM(revenue) AS recorded_revenue,
 SUM(margin_amount)/NULLIF(SUM(revenue),0) AS weighted_margin_rate
FROM sales_reporting WHERE country = :country
GROUP BY retailer ORDER BY recorded_revenue DESC;