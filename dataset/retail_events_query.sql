select * from dim_campaigns;
select * from dim_stores;
select * from dim_products;
select * from fact_events;

/*Provide a list of products with a base price greater than 500 and that are featured
in promo type of 'BOGOF' (Buy One Get One Free). This information will help us
identify high-value products that are currently being heavily discounted, which
can be useful for evaluating our pricing and promotion strategies.*/

select * from fact_events
WHERE base_price>500 and promo_type= 'BOGOF';


/*Generate a report that provides an overview of the number of stores in each city.
The results will be sorted in descending order of store counts, allowing us to
identify the cities with the highest store presence.The report includes two
essential fields: city and store count, which will assist in optimizing our retail
operations.*/

select city, COUNT(*) AS store_count from dim_stores
GROUP BY city
ORDER BY store_count DESC;


/*Generate a report that displays each campaign along with the total revenue
generated before and after the campaign? The report includes three key fields:
campaign_name, total_revenue(before_promotion),
total_revenue(after_promotion). This report should help in evaluating the financial
impact of our promotional campaigns. (Display the values in millions)*/

SELECT dc.campaign_name,
    SUM(fe.base_price * fe.`quantity_sold(before_promo)`) / 1000000 AS total_revenue_before_promotion,
    SUM(fe.base_price * fe.`quantity_sold(after_promo)`) / 1000000 AS total_revenue_after_promotion
FROM 
    fact_events fe
JOIN 
    dim_campaigns dc ON fe.campaign_id = dc.campaign_id
GROUP BY 
    dc.campaign_name
ORDER BY 
    dc.campaign_name;


/*Produce a report that calculates the Incremental Sold Quantity (ISU%) for each
category during the Diwali campaign. Additionally, provide rankings for the
categories based on their ISU%. The report will include three key fields:
category, isuo/o, and rank order. This information will assist in assessing the
category-wise success and impact of the Diwali campaign on incremental sales.*/

SELECT 
    dp.category,
    (SUM(fe.`quantity_sold(after_promo)`) - SUM(fe.`quantity_sold(before_promo)`)) / SUM(fe.`quantity_sold(before_promo)`) * 100 AS ISU_Percentage,
    RANK() OVER (ORDER BY (SUM(fe.`quantity_sold(after_promo)`) - SUM(fe.`quantity_sold(before_promo)`)) / SUM(fe.`quantity_sold(before_promo)`) DESC) AS Rank_Order
FROM 
    fact_events fe
JOIN 
    dim_campaigns dc ON fe.campaign_id = dc.campaign_id
JOIN 
    dim_products dp ON fe.product_code = dp.product_code
WHERE 
    dc.campaign_name = 'Diwali'
GROUP BY 
    dp.category
ORDER BY 
    ISU_Percentage DESC;

/*Create a report featuring the Top 5 products, ranked by Incremental Revenue Percentage (IR%), 
across all campaigns. The report will provide essential information including product name, 
category, and ir%. This analysis helps identify the most successful products in terms of 
incremental revenue across our campaigns, assisting in product optimization.*/

SELECT 
    dp.product_name,
    dp.category,
    (SUM(fe.base_price * fe.`quantity_sold(after_promo)`) - SUM(fe.base_price * fe.`quantity_sold(before_promo)`)) / SUM(fe.base_price * fe.`quantity_sold(before_promo)`) * 100 AS IR_Percentage
FROM 
    fact_events fe
JOIN 
    dim_products dp ON fe.product_code = dp.product_code
GROUP BY 
    dp.product_name, dp.category
ORDER BY 
    IR_Percentage DESC
LIMIT 5;




