-- 每个站点，过往7天，每个休食品牌的销售数量和销量
replace into t_stat_agent_xiushi_brand_past_seven_day(agent_code,brand,sales_number,sales)
SELECT
	g.agent_code,
	g.brand,
	ifnull( sum( ifnull( tsbd.amount, 0 ) ), 0 ) sales_number,
	ifnull( format( sum( ifnull( tsbd.amount * tsbd.price, 0 ) ), 2 ), 0 ) sales 
FROM
	t_sales_bill tsb,
	t_sales_bill_detail tsbd,
	t_goods g,
	t_goods_library_category glc,
	t_goods_standard_library_category_relation gslcr 
WHERE
	tsb.sale_date >= date_sub( CURDATE( ), INTERVAL 7 DAY ) 
	AND tsb.bill_id = tsbd.bill_id 
	AND tsbd.goods_id = g.goods_id 
	AND g.CODE = gslcr.CODE 
	AND gslcr.category_id = glc.category_id 
	AND glc.category_id IN ( SELECT category_id FROM t_goods_type_def d WHERE d.type_def = 'leisure') 
GROUP BY
	g.agent_code,
	g.brand
	

-- 每个站点，过往7天，每个非休食品牌的销售数量和销量
replace into t_stat_agent_not_xiushi_brand_past_seven_day(agent_code,brand,sales_number,sales)
SELECT
	g.agent_code,
	g.brand,
	ifnull( sum( ifnull( tsbd.amount, 0 ) ), 0 ) sales_number,
	ifnull( format( sum( ifnull( tsbd.amount * tsbd.price, 0 ) ), 2 ), 0 ) sales 
FROM
	t_sales_bill tsb,
	t_sales_bill_detail tsbd,
	t_goods g,
	t_goods_library_category glc,
	t_goods_standard_library_category_relation gslcr 
WHERE
	tsb.sale_date >= date_sub( CURDATE( ), INTERVAL 7 DAY ) 
	AND tsb.bill_id = tsbd.bill_id 
	AND tsbd.goods_id = g.goods_id 
	AND g.CODE = gslcr.CODE 
	AND gslcr.category_id = glc.category_id 
	AND glc.category_id NOT IN ( SELECT category_id FROM t_goods_type_def d WHERE d.type_def = 'leisure') 
GROUP BY
	g.agent_code,
	g.brand


=======================================================================

-- 每个站点，过往7天，每个休食商品的销售数量和销量
replace into t_stat_agent_xiushi_goods_past_seven_day(agent_code,goods_id,sales_number,sales)
SELECT
	tsb.agent_code,
	tsbd.goods_id,
	ifnull( sum( ifnull( tsbd.amount, 0 ) ), 0 ) sales_number,
	ifnull( format( sum( ifnull( tsbd.amount * tsbd.price, 0 ) ), 2 ), 0 ) sales 
FROM
	t_sales_bill tsb,
	t_sales_bill_detail tsbd,
	t_goods g,
	t_goods_library_category glc,
	t_goods_standard_library_category_relation gslcr 
WHERE
	tsb.sale_date >= date_sub( CURDATE( ), INTERVAL 7 DAY ) 
	AND tsb.bill_id = tsbd.bill_id 
	AND tsbd.goods_id = g.goods_id 
	AND g.CODE = gslcr.CODE 
	AND gslcr.category_id = glc.category_id 
	AND glc.category_id IN ( SELECT category_id FROM t_goods_type_def d WHERE d.type_def = 'leisure') 
GROUP BY
	tsb.agent_code,
	tsbd.goods_id 
ORDER BY
	tsb.agent_code
	
	
-- 每个站点，过往7天，每个非休食商品的销售数量和销量
replace into t_stat_agent_not_xiushi_goods_past_seven_day(agent_code,goods_id,sales_number,sales)
SELECT
	tsb.agent_code,
	tsbd.goods_id,
	ifnull( sum( ifnull( tsbd.amount, 0 ) ), 0 ) amount,
	ifnull( format( sum( ifnull( tsbd.amount * tsbd.price, 0 ) ), 2 ), 0 ) sales 
FROM
	t_sales_bill tsb,
	t_sales_bill_detail tsbd,
	t_goods g,
	t_goods_library_category glc,
	t_goods_standard_library_category_relation gslcr 
WHERE
	tsb.sale_date >= date_sub( CURDATE( ), INTERVAL 7 DAY ) 
	AND tsb.bill_id = tsbd.bill_id 
	AND tsbd.goods_id = g.goods_id 
	AND g.CODE = gslcr.CODE 
	AND gslcr.category_id = glc.category_id 
	AND glc.category_id NOT IN ( SELECT category_id FROM t_goods_type_def d WHERE d.type_def = 'leisure') 
GROUP BY
	tsb.agent_code,
	tsbd.goods_id 
ORDER BY
	tsb.agent_code

=======================================================================

-- 每个站点，过往7天，每个分类下的每个品牌的销售数量和销量
replace into t_stat_agent_category_brand_past_seven_day(agent_code,category_id,brand,sales_number,sales)
SELECT
	g.agent_code,
	glc.category_id,
	g.brand,
	ifnull( sum( ifnull( tsbd.amount, 0 ) ), 0 ) sales_number,
	ifnull( format( sum( ifnull( tsbd.amount * tsbd.price, 0 ) ), 2 ), 0 ) sales 
FROM
	t_sales_bill tsb,
	t_sales_bill_detail tsbd,
	t_goods g,
	t_goods_library_category glc,
	t_goods_standard_library_category_relation gslcr 
WHERE
	tsb.sale_date >= date_sub( CURDATE( ), INTERVAL 7 DAY ) 
	AND tsb.bill_id = tsbd.bill_id 
	AND tsbd.goods_id = g.goods_id 
	AND g.CODE = gslcr.CODE 
	AND gslcr.category_id = glc.category_id 
GROUP BY
	g.agent_code,
	glc.category_id,
	g.brand
	