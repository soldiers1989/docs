getDriverRaise：

1.getDriverBill：获取该司机，某年，某个月的订单ID列表

SELECT DISTINCT
	a.bill_id -- 查询出不重复的订单号
FROM
	t_appraise_feedback a
	LEFT JOIN t_tms_order b ON a.bill_id = b.bill_id  -- 评价表的订单id（bill_id）和运输单表的订单id（bill_id）关联
	LEFT JOIN t_tms_vehicle_plan c ON b.plan_id = c.id -- 运输单表的计划id（plan_id）和排车计划表的计划id（id）关联
	LEFT JOIN t_driver d ON c.driver_id = d.id -- 排车计划表的司机id（driver_id）和司机表的司机id（id）关联
WHERE
	1 = 1 
	AND d.id = 55 -- 筛选出司机id
	AND YEAR ( c.count_bonus_time ) = 2018 -- 筛选出计算绩效年份
	AND MONTH ( c.count_bonus_time ) = 5  -- 筛选出计算绩效月份

2.getDriverRaise：一个司机可以有多个订单，最后根据查询出某个司机，每个计算绩效月份的分数，订单数，满意订单数，非常满意的订单数，不满意的订单数

SELECT 
	round(
		(
			(
				count( * ) - (
					ifnull( sum( tmp.satisfaction_bill ), 0 ) + ifnull( sum( tmp.verySatisfaction_bill ), 0 ) + ifnull( sum( tmp.unsatisfied_bill ), 0 ) 
				) + ifnull( sum( tmp.satisfaction_bill ), 0 ) 
			) * 60 + ifnull( sum( tmp.verySatisfaction_bill ), 0 ) * 100 
		) / count( * ),
		2 
	) score,
	ifnull( count( * ), 0 ) monthCountBill,
	ifnull( sum( tmp.satisfaction_bill ), 0 ) satisfactionBill,
	ifnull( sum( tmp.verySatisfaction_bill ), 0 ) verySatisfactionBill,
	ifnull( sum( unsatisfied_bill ), 0 ) unsatisfiedBill 
FROM
	t_tms_order a -- 关联订单，排车计划，司机，还有每个订单每个月的满意的物流评价总数，非常满意的物流评价总数，不满意的物流评价总数，4个表的关联
	LEFT JOIN t_tms_vehicle_plan b ON a.plan_id = b.id -- 订单表的计划id（plan_id），关联排车计划表的id（id）
	LEFT JOIN t_driver c ON b.driver_id = c.id -- 排车计划表的司机id（driver_id），关联司机表的id（id）
	LEFT JOIN ( 
	SELECT -- 查询每个订单，每个月，的满意的物流评价总数，非常满意的物流评价总数，不满意的物流评价总数
		d.bill_id,           -- 订单id
		YEAR ( d.feedback_time ) year_time, -- 反馈时间的年份
		MONTH ( d.feedback_time ) month_time,  -- 反馈时间的月份
		sum( CASE WHEN e.`type` = 'logistics' AND e.`appraise` = 'satisfied' THEN '1' ELSE '0' END ) satisfaction_bill, -- 满意的物流评价总数
		sum( CASE WHEN e.`type` = 'logistics' AND e.`appraise` = 'verySatisfied' THEN '1' ELSE '0' END ) verySatisfaction_bill, -- 非常满意的物流评价总数
		sum( CASE WHEN e.`type` = 'logistics' AND e.`appraise` = 'unsatisfied' THEN '1' ELSE '0' END ) unsatisfied_bill -- 不满意的物流评价总数
	FROM
		t_appraise_feedback d
		LEFT JOIN t_appraise_feedback_info e ON d.appraise_id = e.appraise_id   -- 评价表和评价补充表根据评价id（appraise_id）关联
	GROUP BY
		d.bill_id,                   -- 根据（订单id，评价年份，评价月份）联合分组
		YEAR ( d.feedback_time ),
		MONTH ( d.feedback_time ) 
	) tmp ON a.bill_id = tmp.bill_id 
	AND tmp.year_time = YEAR ( b.last_update_date )  -- 订单表和订单每个月的物流评价总数表，采用订单，年份，月份关联
	AND tmp.month_time = MONTH ( b.last_update_date )  
	LEFT JOIN t_store_biz_region tmp2 ON a.store_id = tmp2.store_id -- 关联门店区域表，用订单表的门店id（store_id）关联门店区域表的门店id（store_id）
WHERE
	c.NAME IS NOT NULL 
	AND a.bill_type = 'FHD'  -- 筛选订单类型为发货单
	AND a.order_status = 'sent'  -- 筛选订单状态为已送达
	AND c.id = 55 -- 筛选出司机id
	AND YEAR ( b.count_bonus_time ) = 2018 -- 筛选出计算绩效年份
	AND MONTH ( b.count_bonus_time ) = 5 -- 筛选出计算绩效月份
GROUP BY
	b.`driver_id`,             -- 根据指派司机id，计算绩效年份，计算绩效月份联合分组
	YEAR ( b.count_bonus_time ),  
	MONTH ( b.count_bonus_time )


3.getDriverBonusMoney：查询出某个司机在某个月份的绩效奖金
SELECT 
	ifnull( SUM( bonus_money ), 0 ) bonus_money 
FROM
	t_tms_driver_bonus 
WHERE
	1 = 1 
	AND driver_id = 55 
	AND YEAR ( creation_date ) = 2018 
	AND MONTH ( creation_date ) = 5

4.getDriverBillNum：查询出每个订单的各种评价数

SELECT
	appraise,
	ifnull( sum( sum_satisfaction_quick ), 0 ) sumSatisfactionQuick,
	ifnull( sum( sum_satisfaction_regular_cloth ), 0 ) sumSatisfactionRegularCloth,
	ifnull( sum( sum_satisfaction_goods ), 0 ) sumSatisfactionGoods,
	ifnull( sum( sum_satisfaction_goods_good ), 0 ) sumSatisfactionGoodsGood,
	ifnull( sum( sum_satisfaction_attitude ), 0 ) sumSatisfactionAttitude,
	ifnull( sum( sum_unsatisfied_slow ), 0 ) sumUnsatisfiedSlow,
	ifnull( sum( sum_unsatisfied_irregular_cloth ), 0 ) sumUnsatisfiedIrregularCloth,
	ifnull( sum( sum_unsatisfied_damage_goods ), 0 ) sumUnsatisfiedDamageGoods,
	ifnull( sum( sum_unsatisfied_wrong_goods ), 0 ) sumUnsatisfiedWrongGoods,
	ifnull( sum( sum_unsatisfied_bad_attitude ), 0 ) sumUnsatisfiedBadAttitude,
	ifnull( sum( sum_unsatisfied_miss_goods ), 0 ) sumUnsatisfiedMissGoods 
FROM
	(
	SELECT
		d.bill_id,
		d.appraise_id,
		e.`appraise`,
		YEAR ( d.feedback_time ) year_time,
		MONTH ( d.feedback_time ) month_time,
		sum( CASE WHEN e.`type` = 'logistics' AND e.`appraise` = 'satisfied' THEN 1 ELSE 0 END ) satisfaction_bill,    -- 满意的物流评价总数
		sum( CASE WHEN e.`type` = 'logistics' AND e.`appraise` = 'verySatisfied' THEN 1 ELSE 0 END ) verySatisfaction_bill,          -- 非常满意的物流评价总数
		sum( CASE WHEN e.`type` = 'logistics' AND e.`appraise` = 'unsatisfied' THEN 1 ELSE 0 END ) unsatisfied_bill,				 -- 不满意的物流评价总数
		sum( CASE WHEN e.`type` = 'logistics' AND e.appraise_detail LIKE '%送货快速%' THEN 1 ELSE 0 END ) sum_satisfaction_quick,	 -- 送货快速的物流评价总数
		sum( CASE WHEN e.`type` = 'logistics' AND e.appraise_detail LIKE '%衣冠整齐%' THEN 1 ELSE 0 END ) sum_satisfaction_regular_cloth, -- 衣冠整齐的物流评价总数
		sum( CASE WHEN e.`type` = 'logistics' AND e.appraise_detail LIKE '%主动搬货%' THEN 1 ELSE 0 END ) sum_satisfaction_goods,		-- 主动搬货的物流评价总数
		sum( CASE WHEN e.`type` = 'logistics' AND e.appraise_detail LIKE '%商品完好%' THEN 1 ELSE 0 END ) sum_satisfaction_goods_good,
		sum( CASE WHEN e.`type` = 'logistics' AND e.appraise_detail LIKE '%态度良好%' THEN 1 ELSE 0 END ) sum_satisfaction_attitude,
		sum( CASE WHEN e.`type` = 'logistics' AND e.appraise_detail LIKE '%送货太慢%' THEN 1 ELSE 0 END ) sum_unsatisfied_slow,			-- 送货太慢的物流评价总数
		sum( CASE WHEN e.`type` = 'logistics' AND e.appraise_detail LIKE '%衣冠不整%' THEN 1 ELSE 0 END ) sum_unsatisfied_irregular_cloth,
		sum( CASE WHEN e.`type` = 'logistics' AND e.appraise_detail LIKE '%商品破损%' THEN 1 ELSE 0 END ) sum_unsatisfied_damage_goods,
		sum( CASE WHEN e.`type` = 'logistics' AND e.appraise_detail LIKE '%送错商品%' THEN 1 ELSE 0 END ) sum_unsatisfied_wrong_goods,
		sum( CASE WHEN e.`type` = 'logistics' AND e.appraise_detail LIKE '%态度恶劣%' THEN 1 ELSE 0 END ) sum_unsatisfied_bad_attitude,
		sum( CASE WHEN e.`type` = 'logistics' AND e.appraise_detail LIKE '%漏送商品%' THEN 1 ELSE 0 END ) sum_unsatisfied_miss_goods 
	FROM
		t_appraise_feedback d
		LEFT JOIN t_appraise_feedback_info e ON d.appraise_id = e.appraise_id 
	WHERE
		1 = 1  -- 筛选出订单id列表
			and d.bill_id in ()
	GROUP BY
		d.appraise_id, -- 根据评价id，满意程度，反馈年份，反馈月份联合分组
		e.`appraise`,
		YEAR ( d.feedback_time ),
		MONTH ( d.feedback_time ) 
	) tmp 
GROUP BY
	`appraise` 
ORDER BY
	appraise DESC