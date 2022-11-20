--справочники
drop table if exists public.shipping_country_rates cascade;
drop table if exists public.shipping_agreement cascade;
drop table if exists public.shipping_transfer cascade;
drop table if exists public.shipping_info cascade;
--лог статусов
drop table if exists public.shipping_status cascade;

--справочник стоимости доставки в страны
create table public.shipping_country_rates (
	shipping_country_id serial not null
	,shipping_country text not null
	,shipping_country_base_rate numeric(14,3) not null
	,primary key (shipping_country_id)
);

--справочник тарифов доставки вендора по договору
create table public.shipping_agreement (
	agreementid integer not null
	,agreement_number text
	,agreement_rate double precision
	,agreement_commission double precision
	,primary key (agreementid)
);

--справочник о типах доставки 
create table public.shipping_transfer (
	transfer_type_id serial not null
	,transfer_type text
	,transfer_model text
	,shipping_transfer_rate double precision
	,primary key (transfer_type_id)
);

--справочник комиссий по странам
create table public.shipping_info (
	shippingid bigint not null
	,vendorid bigint
	,payment_amount numeric(14,2)
	,shipping_plan_datetime timestamp
	,transfer_type_id integer not null
	,shipping_country_id integer not null
	,agreementid integer not null
	,primary key (shippingid)
	,foreign key (transfer_type_id) 
		references  public.shipping_transfer (transfer_type_id) on update cascade
	,foreign key (shipping_country_id) 
		references public.shipping_country_rates (shipping_country_id) on update cascade
	,foreign key (agreementid) 
		references public.shipping_agreement (agreementid) on update cascade
);
--добавляем индекс для ускорения аналитических запросов
create index shippingid_info_index on public.shipping_info (shippingid);

--справочник о типах доставки 
create table public.shipping_status (
	shippingid bigint not null
	,status text
	,state text
	,shipping_start_fact_datetime timestamp
	,shipping_end_fact_datetime timestamp null
	,primary key (shippingid)
);
--добавляем индекс для ускорения аналитических запросов
create index shippingid_status_index on public.shipping_status (shippingid);
