getDriverRaise��

1.getDriverBill����ȡ��˾����ĳ�꣬ĳ���µĶ���ID�б�

SELECT DISTINCT
	a.bill_id -- ��ѯ�����ظ��Ķ�����
FROM
	t_appraise_feedback a
	LEFT JOIN t_tms_order b ON a.bill_id = b.bill_id  -- ���۱�Ķ���id��bill_id�������䵥��Ķ���id��bill_id������
	LEFT JOIN t_tms_vehicle_plan c ON b.plan_id = c.id -- ���䵥��ļƻ�id��plan_id�����ų��ƻ���ļƻ�id��id������
	LEFT JOIN t_driver d ON c.driver_id = d.id -- �ų��ƻ����˾��id��driver_id����˾�����˾��id��id������
WHERE
	1 = 1 
	AND d.id = 55 -- ɸѡ��˾��id
	AND YEAR ( c.count_bonus_time ) = 2018 -- ɸѡ�����㼨Ч���
	AND MONTH ( c.count_bonus_time ) = 5  -- ɸѡ�����㼨Ч�·�

2.getDriverRaise��һ��˾�������ж�������������ݲ�ѯ��ĳ��˾����ÿ�����㼨Ч�·ݵķ����������������ⶩ�������ǳ�����Ķ�������������Ķ�����

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
	t_tms_order a -- �����������ų��ƻ���˾��������ÿ������ÿ���µ���������������������ǳ�����������������������������������������4����Ĺ���
	LEFT JOIN t_tms_vehicle_plan b ON a.plan_id = b.id -- ������ļƻ�id��plan_id���������ų��ƻ����id��id��
	LEFT JOIN t_driver c ON b.driver_id = c.id -- �ų��ƻ����˾��id��driver_id��������˾�����id��id��
	LEFT JOIN ( 
	SELECT -- ��ѯÿ��������ÿ���£�����������������������ǳ���������������������������������������
		d.bill_id,           -- ����id
		YEAR ( d.feedback_time ) year_time, -- ����ʱ������
		MONTH ( d.feedback_time ) month_time,  -- ����ʱ����·�
		sum( CASE WHEN e.`type` = 'logistics' AND e.`appraise` = 'satisfied' THEN '1' ELSE '0' END ) satisfaction_bill, -- �����������������
		sum( CASE WHEN e.`type` = 'logistics' AND e.`appraise` = 'verySatisfied' THEN '1' ELSE '0' END ) verySatisfaction_bill, -- �ǳ������������������
		sum( CASE WHEN e.`type` = 'logistics' AND e.`appraise` = 'unsatisfied' THEN '1' ELSE '0' END ) unsatisfied_bill -- �������������������
	FROM
		t_appraise_feedback d
		LEFT JOIN t_appraise_feedback_info e ON d.appraise_id = e.appraise_id   -- ���۱�����۲�����������id��appraise_id������
	GROUP BY
		d.bill_id,                   -- ���ݣ�����id��������ݣ������·ݣ����Ϸ���
		YEAR ( d.feedback_time ),
		MONTH ( d.feedback_time ) 
	) tmp ON a.bill_id = tmp.bill_id 
	AND tmp.year_time = YEAR ( b.last_update_date )  -- ������Ͷ���ÿ���µ������������������ö�������ݣ��·ݹ���
	AND tmp.month_time = MONTH ( b.last_update_date )  
	LEFT JOIN t_store_biz_region tmp2 ON a.store_id = tmp2.store_id -- �����ŵ�������ö�������ŵ�id��store_id�������ŵ��������ŵ�id��store_id��
WHERE
	c.NAME IS NOT NULL 
	AND a.bill_type = 'FHD'  -- ɸѡ��������Ϊ������
	AND a.order_status = 'sent'  -- ɸѡ����״̬Ϊ���ʹ�
	AND c.id = 55 -- ɸѡ��˾��id
	AND YEAR ( b.count_bonus_time ) = 2018 -- ɸѡ�����㼨Ч���
	AND MONTH ( b.count_bonus_time ) = 5 -- ɸѡ�����㼨Ч�·�
GROUP BY
	b.`driver_id`,             -- ����ָ��˾��id�����㼨Ч��ݣ����㼨Ч�·����Ϸ���
	YEAR ( b.count_bonus_time ),  
	MONTH ( b.count_bonus_time )


3.getDriverBonusMoney����ѯ��ĳ��˾����ĳ���·ݵļ�Ч����
SELECT 
	ifnull( SUM( bonus_money ), 0 ) bonus_money 
FROM
	t_tms_driver_bonus 
WHERE
	1 = 1 
	AND driver_id = 55 
	AND YEAR ( creation_date ) = 2018 
	AND MONTH ( creation_date ) = 5

4.getDriverBillNum����ѯ��ÿ�������ĸ���������

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
		sum( CASE WHEN e.`type` = 'logistics' AND e.`appraise` = 'satisfied' THEN 1 ELSE 0 END ) satisfaction_bill,    -- �����������������
		sum( CASE WHEN e.`type` = 'logistics' AND e.`appraise` = 'verySatisfied' THEN 1 ELSE 0 END ) verySatisfaction_bill,          -- �ǳ������������������
		sum( CASE WHEN e.`type` = 'logistics' AND e.`appraise` = 'unsatisfied' THEN 1 ELSE 0 END ) unsatisfied_bill,				 -- �������������������
		sum( CASE WHEN e.`type` = 'logistics' AND e.appraise_detail LIKE '%�ͻ�����%' THEN 1 ELSE 0 END ) sum_satisfaction_quick,	 -- �ͻ����ٵ�������������
		sum( CASE WHEN e.`type` = 'logistics' AND e.appraise_detail LIKE '%�¹�����%' THEN 1 ELSE 0 END ) sum_satisfaction_regular_cloth, -- �¹������������������
		sum( CASE WHEN e.`type` = 'logistics' AND e.appraise_detail LIKE '%�������%' THEN 1 ELSE 0 END ) sum_satisfaction_goods,		-- ���������������������
		sum( CASE WHEN e.`type` = 'logistics' AND e.appraise_detail LIKE '%��Ʒ���%' THEN 1 ELSE 0 END ) sum_satisfaction_goods_good,
		sum( CASE WHEN e.`type` = 'logistics' AND e.appraise_detail LIKE '%̬������%' THEN 1 ELSE 0 END ) sum_satisfaction_attitude,
		sum( CASE WHEN e.`type` = 'logistics' AND e.appraise_detail LIKE '%�ͻ�̫��%' THEN 1 ELSE 0 END ) sum_unsatisfied_slow,			-- �ͻ�̫����������������
		sum( CASE WHEN e.`type` = 'logistics' AND e.appraise_detail LIKE '%�¹ڲ���%' THEN 1 ELSE 0 END ) sum_unsatisfied_irregular_cloth,
		sum( CASE WHEN e.`type` = 'logistics' AND e.appraise_detail LIKE '%��Ʒ����%' THEN 1 ELSE 0 END ) sum_unsatisfied_damage_goods,
		sum( CASE WHEN e.`type` = 'logistics' AND e.appraise_detail LIKE '%�ʹ���Ʒ%' THEN 1 ELSE 0 END ) sum_unsatisfied_wrong_goods,
		sum( CASE WHEN e.`type` = 'logistics' AND e.appraise_detail LIKE '%̬�ȶ���%' THEN 1 ELSE 0 END ) sum_unsatisfied_bad_attitude,
		sum( CASE WHEN e.`type` = 'logistics' AND e.appraise_detail LIKE '%©����Ʒ%' THEN 1 ELSE 0 END ) sum_unsatisfied_miss_goods 
	FROM
		t_appraise_feedback d
		LEFT JOIN t_appraise_feedback_info e ON d.appraise_id = e.appraise_id 
	WHERE
		1 = 1  -- ɸѡ������id�б�
			and d.bill_id in ()
	GROUP BY
		d.appraise_id, -- ��������id������̶ȣ�������ݣ������·����Ϸ���
		e.`appraise`,
		YEAR ( d.feedback_time ),
		MONTH ( d.feedback_time ) 
	) tmp 
GROUP BY
	`appraise` 
ORDER BY
	appraise DESC