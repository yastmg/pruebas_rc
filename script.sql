do $$

declare
     _uid rc.user_id;
    _start character varying;
    _end character varying;
    _company_id integer;
	_start_date timestamp;
	_end_date timestamp;
	_user_timezone rc.timezone;


BEGIN
	_uid = 23155;
	_start = '2018-05-02 00:00:00';
	_end = '2018-09-02 00:00:00';
	_company_id = 36949;


	DROP TABLE IF EXISTS temp_shipment;
	CREATE TEMP TABLE temp_shipment (temp_shipment varchar(20), temp_path varchar(50));

	--> Obtener informacion del usuario
	SELECT timezone, company_id
	INTO _user_timezone, _company_id
	FROM rc.get_user_information_by_user_id(_uid);
	
	IF NOT FOUND THEN
		PERFORM rc.raise ('EXIT', 'USER_UNKNOWN');
	END IF;

	_start_date := COALESCE(xsd_date_format(_start, _user_timezone::varchar),xsd_date_format(now()::date::text, _user_timezone::varchar));
	_end_date := COALESCE(xsd_date_format(_end, _user_timezone::varchar),xsd_date_format(now()::date::text, _user_timezone::varchar));


	insert into temp_shipment
	select s_c_dst.delivery_zone
		, replace(_cpg.path,'\','/')
	FROM rc.supply_chain as sc
		JOIN rc.supply_chain_company AS scc ON scc.supply_chain_id = sc.supply_chain_id 
		LEFT JOIN rc.supply_chain_vehicle AS sc_v ON sc_v.supply_chain_id = sc.supply_chain_id 
		LEFT JOIN rc.category_vehicle AS c_v ON c_v.category_vehicle_id = sc_v.category_vehicle_id
		JOIN rc.segment AS sg ON sg.supply_chain_id = sc.supply_chain_id
		left JOIN rc.segment_cost AS sg_c ON sg_c.segment_id = sg.segment_id 
		JOIN rc.stop AS s_src ON s_src.stop_id = sg.stop_id_source
		JOIN rc.stop AS s_dst ON s_dst.stop_id = sg.stop_id_destiny
		JOIN rc.appt AS a_src ON a_src.stop_id = sg.stop_id_source
		JOIN rc.appt AS a_dst ON a_dst.stop_id = sg.stop_id_destiny
		JOIN rc.appt_detail AS a_d_src ON a_d_src.appt_id = a_src.appt_id 
		JOIN rc.appt_detail AS a_d_dst ON a_d_dst.appt_id = a_dst.appt_id
		JOIN rc.location AS l_src ON l_src.location_id = s_src.location_id
		JOIN rc.location AS l_dst ON l_dst.location_id = s_dst.location_id
		JOIN rc.region AS r_src ON r_src.region_id = l_src.region_id
		JOIN rc.region AS r_dst ON r_dst.region_id = l_dst.region_id
		JOIN rc.stop_complement AS s_c ON s_c.stop_id = s_src.stop_id 
		JOIN rc.stop_complement AS s_c_dst ON s_c_dst.stop_id = s_dst.stop_id 
		LEFT JOIN rc.company AS com_src ON com_src.company_id = s_src.transline_id
		LEFT JOIN rc.travel AS t_src ON t_src.region_id_source = r_src.region_id AND t_src.region_id_destiny = r_dst.region_id AND t_src.transline_id = s_src.transline_id
		LEFT JOIN rc.travel_cost AS t_cost ON t_cost.travel_id = t_src.travel_id AND t_cost.category_vehicle_id = c_v.category_vehicle_id

		LEFT JOIN rc.travel as t_src_range on t_src_range.region_id_destiny = r_src.region_id and t_src_range.region_id_destiny = r_dst.region_id and t_src_range.transline_id = s_src.transline_id
		LEFT JOIN rc.travel_cost_range as t_cost_range on t_cost_range.travel_id = t_src.travel_id and t_cost_range.initial_range < s_c_dst.delivery_document::integer and t_cost_range.final_range > s_c_dst.delivery_document::integer

		LEFT JOIN rc.track AS trck on trck.stop_id = s_c_dst.stop_id
		LEFT JOIN rc.track_detail AS trck_det ON trck_det.track_id = trck.track_id

		LEFT JOIN rc.custom_paht_generic _cpg ON id_document = s_c_dst.num_bill and type_document = 'num_bill'
	WHERE 
		scc.company_id = _company_id 
		AND s_src.created BETWEEN _start_date AND _end_date;
end$$;
select * from temp_shipment