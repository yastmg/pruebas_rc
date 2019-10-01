do $$
	declare 
		_params jsonb;
		_shipment character varying;
		_stop_id integer;
	
begin
	_params = '{"mail": {"to": ["gerardovargasrc@gmail.com, davidaldana@recursoconfiable.com, blancagarcia@recursoconfiable.com, ulisesresendiz@recursoconfiable.com, tolentino.ba.jes@gmail.com, AnaLauraJimenez@wirecoworldgroup.com, ElizabethAvina@wirecoworldgroup.com, gustavomedina@recursoconfiable.com,arelicruz@wirecoworldgroup.com"], "body": {"param": {"data": {"weight": "15000", "shipment": "1269588", "appt_date": "24/08/2018 08:08:00", "dest_date": "2018-09-01 17:45:00-05", "dest_name": "COMERCIALIZADORA METJA", "currentDate": "31/08/2018", "contact_mail": "ElizabethAvina@wirecoworldgroup.com", "contact_name": "Elizabeth Aviña", "dest_address": "AV. JORGE JIMENEZ CANTU NO.230D CASA 14 JOYAS DEL ALBA CUAUTITLAN MEX", "contact_phone": "O: (52-55) 58 99-5507 | C: (52-55) 4203-0760", "location_name": "Camesa Cuautitlán"}}, "template": "~/Views/Mail/Company/Camesa/camesa_notification.cshtml"}, "subject": {"param": {"shipment": "1269588"}, "message": "CAMESA: Embarque asignado [shipment]"}}, "title": "Embarque asignado | 1269588", "url_action": "https://www.rcontrol.com.mx/rpcmail/complex_mail"}';
	_shipment = _params -> 'mail' -> 'body' -> 'param' -> 'data' -> 'shipment';

	SELECT s.stop_id
		into _stop_id
	FROM rc.stop s
		JOIN rc.supply_chain sc ON s.supply_chain_id = sc.supply_chain_id
	WHERE s.shipment = replace(_shipment,'"','')
	  AND sc.status = 'ACTIVE'
	
	  LIMIT 1;

	raise notice 'shipment; %,stop; %, otro;%', _shipment, _stop_id, substring(_shipment,1,8);
end$$


--select ('{"mail": {"to": ["reynahdz-1@hotmail.com, davidaldana@recursoconfiable.com, blancagarcia@recursoconfiable.com, AnaLauraJimenez@wirecoworldgroup.com,ElizabethAvina@wirecoworldgroup.com,arelicruz@wirecoworldgroup.com"], "body": {"param": {"data": {"weight": "722", "shipment": "1263792", "appt_date": "31/08/2018 08:08:00", "dest_date": "2018-08-31 14:14:00-05", "dest_name": "CONDUMEX, S.A. DE C.V.", "currentDate": "30/08/2018", "contact_mail": "ElizabethAvina@wirecoworldgroup.com", "contact_name": "Elizabeth Aviña", "dest_address": "PONIENTE 140 # 720 MEXICO D.F. MEXICO", "contact_phone": "O: (52-55) 58 99-5507 | C: (52-55) 4203-0760", "location_name": "Camesa Cuautitlán"}}, "template": "~/Views/Mail/Company/Camesa/camesa_notification.cshtml"}, "subject": {"param": {"shipment": "1263792"}, "message": "CAMESA: Embarque asignado [shipment]"}}, "title": "Embarque asignado | 1263792", "url_action": "https://www.rcontrol.com.mx/rpcmail/complex_mail"}'::json) -> 'mail' -> 'body' -> 'param' -> 'data'