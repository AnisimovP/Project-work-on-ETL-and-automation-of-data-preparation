alter table staging.user_order_log drop column if exists status;

alter table staging.user_order_log add column status text default 'shipped';