getHistoryDriverScore：获取司机历史分数
SELECT
	a.*,
	ifnull( sum( b.bonus_money ), 0 ) achievement 
FROM
	(
	SELECT YEAR
		( b.last_update_date ) YEAR,
		MONTH ( b.last_update_date ) MONTH,
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
		b.driver_id 
	FROM
		t_tms_order a
		LEFT JOIN t_tms_vehicle_plan b ON a.plan_id = b.id
		LEFT JOIN t_driver c ON b.driver_id = c.id
		LEFT JOIN (
		SELECT
			d.bill_id,
			YEAR ( d.feedback_time ) year_time,
			MONTH ( d.feedback_time ) month_time,
			sum( CASE WHEN e.`type` = 'logistics' AND e.`appraise` = 'satisfied' THEN '1' ELSE '0' END ) satisfaction_bill,
			sum( CASE WHEN e.`type` = 'logistics' AND e.`appraise` = 'verySatisfied' THEN '1' ELSE '0' END ) verySatisfaction_bill,
			sum( CASE WHEN e.`type` = 'logistics' AND e.`appraise` = 'unsatisfied' THEN '1' ELSE '0' END ) unsatisfied_bill 
		FROM
			t_appraise_feedback d
			LEFT JOIN t_appraise_feedback_info e ON d.appraise_id = e.appraise_id 
		GROUP BY
			d.bill_id,
			YEAR ( d.feedback_time ),
			MONTH ( d.feedback_time ) 
		) tmp ON a.bill_id = tmp.bill_id 
		AND tmp.year_time = YEAR ( b.last_update_date ) 
		AND tmp.month_time = MONTH ( b.last_update_date )
		LEFT JOIN t_store_biz_region tmp2 ON a.store_id = tmp2.store_id 
	WHERE
		c.NAME IS NOT NULL 
		AND a.bill_type = 'FHD' 
		AND a.order_status = 'sent' < IF test = "id != null and id != ''" > 
		AND c.id = 55 </ IF > 
	GROUP BY
		b.`driver_id`,
		YEAR ( b.last_update_date ),
		MONTH ( b.last_update_date ) 
	) a
	LEFT JOIN t_tms_driver_bonus b ON a.driver_id = b.driver_id 
	AND YEAR ( b.creation_date ) = `year` 
	AND MONTH ( b.creation_date ) = a.`month` 
GROUP BY
	a.YEAR,
	a.MONTH 
ORDER BY
	YEAR DESC,
MONTH DESC 
	LIMIT 0,
	20
