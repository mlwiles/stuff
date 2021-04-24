
SELECT * FROM public.jobs where status = 1
--update jobs set status = 3 where job_id='a8624efe-0f2b-45d2-af38-3d24b2ccfd08'
--select * from public.task 
--select * from public.task where job_id='a8624efe-0f2b-45d2-af38-3d24b2ccfd08'
--delete from public.task where job_id='a8624efe-0f2b-45d2-af38-3d24b2ccfd08'
--select * from busy_object where task_id = '4d0ecc02-00c4-4aca-b92e-98a6321c545f'
--delete from busy_object where task_id = '4d0ecc02-00c4-4aca-b92e-98a6321c545f'


SELECT * FROM public.jobs where status = 1 and operation = 'VDC_DELETE_MEDIA'
SELECT * FROM public.task where operation = 'VDC_DELETE_MEDIA'
SELECT * FROM busy_object where task_id in (SELECT id FROM public.task where operation = 'VDC_DELETE_MEDIA')