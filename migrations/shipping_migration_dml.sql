--справочник стоимости доставки в страны
insert into public.shipping_country_rates 
(shipping_country, shipping_country_base_rate)
select distinct 
	shipping_country 
	,shipping_country_base_rate 
from shipping;

select * from public.shipping_country_rates limit 10;

--справочник тарифов доставки вендора по договору
insert into public.shipping_agreement 
(agreementid, agreement_number, agreement_rate, agreement_commission)
select 
	vendor_agreement_array[1]::integer as agreementid
	,vendor_agreement_array[2] as agreement_number
	,vendor_agreement_array[3]::double precision as agreement_rate
	,vendor_agreement_array[4]::double precision as agreement_commission
from (
	select distinct 
		regexp_split_to_array(vendor_agreement_description, ':+') as vendor_agreement_array
	from public.shipping
)t;

select * from public.shipping_agreement limit 10;

--справочник о типах доставки 
insert into public.shipping_transfer 
(transfer_type, transfer_model, shipping_transfer_rate)
select 
	transfer_descr_array[1] as transfer_type
	,transfer_descr_array[2] as transfer_model
	,shipping_transfer_rate
from (
	select distinct 
		regexp_split_to_array(shipping_transfer_description, ':+') as transfer_descr_array
		,shipping_transfer_rate
	from public.shipping
)t;

select * from public.shipping_transfer limit 10;

--справочник комиссий по странам
insert into public.shipping_info 
(shippingid, vendorid, payment_amount, shipping_plan_datetime
,transfer_type_id, shipping_country_id, agreementid)
select distinct 
	s.shippingid 
	,s.vendorid
	,s.payment_amount
	,s.shipping_plan_datetime
	,st.transfer_type_id
	,scr.shipping_country_id
	,(regexp_split_to_array(s.vendor_agreement_description, ':+'))[1]::integer as agreementid
from public.shipping s
left join public.shipping_transfer st
	on s.shipping_transfer_description = concat_ws(':', st.transfer_type, st.transfer_model) 
left join public.shipping_country_rates scr
	on s.shipping_country = scr.shipping_country;

select * from public.shipping_info limit 10;

--лог статусов заказа 
insert into public.shipping_status 
(shippingid,status,state,shipping_start_fact_datetime,shipping_end_fact_datetime)
select
	s.shippingid
	,s.status
	,s.state
	,sl.shipping_start_fact_datetime
	,sl.shipping_end_fact_datetime
	--,sl.max_state_datetime
from shipping s
inner join 
	(
	select 
		shippingid
		,max(state_datetime) as max_state_datetime
		,min(case when state = 'booked' then state_datetime end) as shipping_start_fact_datetime
		,max(case when state = 'recieved' then state_datetime end) as shipping_end_fact_datetime
	from shipping
	group by shippingid
	)sl
	on s.shippingid = sl.shippingid
	and s.state_datetime = sl.max_state_datetime
order by shippingid;

select * from public.shipping_status limit 10;

