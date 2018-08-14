-- 每个站点，每个商品前一个月的销售数量
-- 用于统计每个站点的畅销商品
SELECT
	tsb.agent_code,
	tsbd.goods_id,
	ifnull( sum( ifnull( tsbd.amount, 0 ) ), 0 ) sales_number 
FROM
	t_sales_bill tsb,
	t_sales_bill_detail tsbd 
WHERE
	tsb.sale_date >= date_sub( CURDATE( ), INTERVAL 30 DAY ) 
	AND tsb.bill_id = tsbd.bill_id 
GROUP BY
	tsb.agent_code,
	tsbd.goods_id 

-- 每个站点，每个商品每一天的销售数量
-- 只保留2个星期数据
SELECT
	tsb.agent_code,
	tsbd.goods_id,
	STR_TO_DATE(DATE_FORMAT(tsb.sale_date,"%Y-%m-%d"),"%Y-%m-%d") as sale_day,
	ifnull( sum( ifnull( tsbd.amount, 0 ) ), 0 ) sales_number 
FROM
	t_sales_bill tsb,
	t_sales_bill_detail tsbd 
WHERE
	tsb.sale_date >= date_sub( CURDATE( ), INTERVAL 14 DAY ) 
	AND tsb.bill_id = tsbd.bill_id 
GROUP BY
	tsb.agent_code,
	tsbd.goods_id,
	STR_TO_DATE(DATE_FORMAT(tsb.sale_date,"%Y-%m-%d"),"%Y-%m-%d")
	

-- 每个商品，最后一次参与促销活动的时间
SELECT
	tsbd.goods_id,
	max( tsb.sale_date ) AS sale_date 
FROM
	t_sales_bill tsb,
	t_sales_bill_detail tsbd 
WHERE
	tsb.bill_id = tsbd.bill_id 
	AND tsbd.activity_id != 0 
GROUP BY
	tsbd.goods_id
	