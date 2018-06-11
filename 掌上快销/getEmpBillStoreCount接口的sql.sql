getEmpBillStoreCount:
SELECT DISTINCT
	emp2.employee_name,
	tsn.*,
	tsm.*,
	tosm.*,
	c.*,
	e.*,
	f.*,
CASE
		
		WHEN plan_sign.employee_id IS NULL THEN
		'0/0' ELSE concat( normalSignDay, '/', allSignDay ) 
	END plan_sign_pro 
FROM
	t_employee emp2
	LEFT JOIN (
	SELECT
		count( 1 ) AS store_num,
		emp.employee_id 
	FROM
		t_employee emp
		INNER JOIN t_agent_biz_region bizCity ON emp.agent_code = bizCity.agent_code
		LEFT JOIN t_store store ON store.official_emp_id = emp.employee_id 
	WHERE
		1 = 1 
		AND store.creation_date >= '2018-05-24 
		00:00:00' 
		AND '2018-05-24 23:59:59' >= store.creation_date 
		AND emp.employee_id = 489714 
	) tsn ON emp2.employee_id = tsn.employee_id
	LEFT JOIN (
	SELECT
		count( bill.bill_id ) AS bill_count,
		round( sum( bill.total ), 2 ) AS bill_total,
		count( DISTINCT bill.store_id ) AS bill_store,
		emp.employee_id 
	FROM
		t_employee emp
		INNER JOIN t_agent_biz_region bizCity ON emp.agent_code = bizCity.agent_code
		LEFT JOIN t_sales_bill bill ON bill.official_emp_id = emp.employee_id 
	WHERE
		bill.creator_type = 'store' 
		AND bill.STATUS NOT IN ( 'disable', 'cancel' ) 
		AND bill.sale_date >= '2018-05-24 00:00:00' 
		AND '2018-05-24 23:59:59' >= bill.sale_date 
		AND emp.employee_id = 489714 
	GROUP BY
		emp.employee_id 
	) tsm ON emp2.employee_id = tsm.employee_id
	LEFT JOIN (
	SELECT
		count( DISTINCT lh.oper_id ) active_store_num,
		emp.employee_id 
	FROM
		t_operator_login_history lh
		LEFT JOIN t_store store ON store.oper_id = lh.oper_id
		LEFT JOIN t_employee emp ON store.official_emp_id = emp.employee_id
		INNER JOIN t_agent_biz_region bizCity ON emp.agent_code = bizCity.agent_code 
	WHERE
		1 = 1 
		AND lh.login_date >= '2018-05-24 00:00:00' 
		AND '2018-05-24 23:59:59' >= lh.login_date 
		AND emp.employee_id = 489714 
	GROUP BY
		emp.employee_id 
	) tosm ON emp2.employee_id = tosm.employee_id
	LEFT JOIN (
	SELECT
		city,
		emp_id employee_id,
		count( store_id ) first_order_count,
		sum( first_order_money ) first_order_money 
	FROM
		t_first_order_bill 
	WHERE
		1 = 1 
		AND first_order_date >= '2018-05-24 00:00:00' 
		AND '2018-05-24 23:59:59' >= first_order_date 
		AND emp_id = 489714 
	GROUP BY
		city,
		emp_id 
	) c ON emp2.employee_id = c.employee_id
	LEFT JOIN (
	SELECT
		bizCity.biz_region city,
		emp.employee_id,
		emp.employee_name,
		count( DISTINCT b.store_id ) sign,
		count( DISTINCT CASE WHEN b.STATUS = 0 THEN b.store_id END ) normal_sign 
	FROM
		t_employee_sign b
		LEFT JOIN t_employee emp ON b.employee_id = emp.employee_id
		INNER JOIN t_agent_biz_region bizCity ON emp.agent_code = bizCity.agent_code 
	WHERE
		1 = 1 
		AND b.in_time >= '2018-05-24 00:00:00' 
		AND '2018-05-24 23:59:59' >= b.in_time 
		AND b.employee_id = 489714 
	GROUP BY
		bizCity.biz_region,
		emp.employee_id,
		emp.employee_name 
	) e ON emp2.employee_id = e.employee_id
	LEFT JOIN (
	SELECT
		bizCity.biz_region city,
		emp.employee_id,
		emp.employee_name,
		0 logging 
	FROM
		t_store b
		LEFT JOIN t_employee emp ON emp.employee_id = b.official_emp_id
		INNER JOIN t_agent_biz_region bizCity ON emp.agent_code = bizCity.agent_code 
	WHERE
		b.record = 1 
		AND b.official_emp_id > 0 
		AND b.official_emp_id = 489714 
		AND b.last_update_date >= '2018-05-24 00:00:00' 
		AND '2018-05-24 23:59:59' >= b.last_update_date 
	GROUP BY
		bizCity.biz_region,
		emp.employee_id,
		emp.employee_name 
	) f ON emp2.employee_id = f.employee_id
	LEFT JOIN (
	SELECT
		employee_id,
		sum( CASE WHEN storeCount2 / storeCount1 = 1 THEN 1 ELSE 0 END ) normalSignDay,
		count( dat ) allSignDay 
	FROM
		(
		SELECT
			a.employee_id,
			a.employee_name,
			date( a.plan_date ) dat,
			count( a.store_id ) storeCount1,
			count( CASE WHEN b.STATUS = 0 THEN b.store_id END ) storeCount2 
		FROM
			t_employee_sign_plan a
			LEFT JOIN t_employee_sign b ON a.plan_id = b.plan_id 
			AND a.employee_id = b.employee_id 
		WHERE
			1 = 1 
			AND a.plan_date >= '2018-05-24 00:00:00' 
			AND '2018-05-24 23:59:59' >= a.plan_date 
			AND a.employee_id = 489714 
		GROUP BY
			a.employee_id,
			a.employee_name,
			dat 
		) tmp 
	GROUP BY
		employee_id 
	) plan_sign ON emp2.employee_id = plan_sign.employee_id 
WHERE
	emp2.is_official = 1 
	AND emp2.employee_id = 489714 
ORDER BY
	tsm.bill_total DESC 
	LIMIT 0,
	100;