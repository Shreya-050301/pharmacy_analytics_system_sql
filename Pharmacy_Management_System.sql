-- =========================================================
-- Project: Pharmacy Management System Database
-- Description:
-- A complete SQL project demonstrating schema design,
-- constraints, indexing, views, stored procedures,
-- triggers, functions, and analytical queries.
-- =========================================================



create database pharmacy_project;
use pharmacy_project;
set sql_safe_updates=0;

#for medicines
create table medicines(medicine_id varchar(20) primary key,
					   medicine_name varchar(50) unique,
					   category varchar(30),
					   price_per_unit float, stock_quantity int,expiry_date date );
 
 
 #for doctors
 create table doctors(doctor_id varchar(20) primary key,
					  name varchar(50),
                      specialization varchar(30), 
                      hospital_name varchar(60));
 
 #for patients
 create table patients(patient_id varchar(20) primary key,
					   name  varchar(50),
                       gender varchar(10),
                       dob date,
                       city varchar(40));
 
 #for prescription
 create table prescription(prescription_id varchar(20) primary key,
                           doctor_id varchar(20),patient_id varchar(20),
						   prescription_date date ,
                           diagnosis varchar(50), 
constraint fk_doc_id foreign key(doctor_id) references doctors(doctor_id) on update cascade on delete cascade, 
constraint fk_pat_id foreign key(patient_id) references patients(patient_id) on update cascade on delete cascade);


#for prescription_details
create table prescription_details(prescription_details_id varchar(20) primary key,
                                  prescription_id varchar(20),medicine_id varchar(20), 
                                  dosage varchar(30),
                                  duration varchar(20),
constraint fk_pre_id foreign key(prescription_id) references prescription (prescription_id)on update cascade on delete cascade,
constraint fk_med_id foreign key(medicine_id) references medicines (medicine_id)on update cascade on delete cascade);


 -- for sales
create table sales(sale_id varchar(20) primary key,
                   patient_id varchar(20) not null,
                   medicine_id varchar(20) not null,
                   quantity int,
                   sale_date date default(current_date),
                   payment_method varchar(20),
constraint fk_pat_id1 foreign key(patient_id) references patients(patient_id) on update cascade on delete cascade,
constraint fk_med_id1 foreign key(medicine_id) references medicines (medicine_id)on update cascade on delete cascade);

 -- for restock_alert
create table restock_alerts(alert_id int auto_increment primary key, 
                            medicine_id varchar(20),
                            alert_date date default(current_date),
                            note varchar(80),
constraint fk_med_id2 foreign key(medicine_id) references medicines (medicine_id)on update cascade on delete cascade);

#for suppliers
create table suppliers(
    supplier_id varchar(20) primary key,
    supplier_name varchar(60),
    medicine_id varchar(20), 
    contact_number varchar(10), 
    location varchar(40),
    constraint fk_med_id3 foreign key(medicine_id) references medicines (medicine_id)on update cascade on delete cascade
);

--   QUERIES


--  List medicines that are below minimum stock level (e.g., stock_quantity < 10).
 select * from medicines where stock_quantity<10;
 
 --  Identify medicines that have expired as of today
 select * from medicines where expiry_date<=curdate();
 
 --  Retrieve the top 3 most sold medicines by total quantity.
 select m.medicine_name, sum(s.quantity) as total_sold from medicines m
join sales s
on m.medicine_id = s.medicine_id
group by m.medicine_name
order by total_sold desc
limit 3;
 
 --  Calculate total revenue generated per medicine.
 select medicine_name,sum(s.quantity*m.price_per_unit) total_revenue from medicines m 
 inner join sales s 
 on m.medicine_id=s.medicine_id 
 group by medicine_name;
 
 -- Find the number of distinct patients each doctor has treated.
 select d.name,count(distinct(p.patient_id)) from prescription p 
 inner join doctors d 
 on p.doctor_id=d.doctor_id 
 group by d.name;
 
 --  Show daily sales totals for the last 30 days.
 select s.sale_date,sum(s.quantity*m.price_per_unit) total from medicines m 
 inner join sales s 
 on m.medicine_id=s.medicine_id 
 where s.sale_date>=curdate()-interval 30 day group by s.sale_date
 order by s.sale_date;
 
 --  Identify medicines that have never been sold but were prescribed
 select distinct(medicine_name) from medicines m 
 inner join prescription_details p 
 on m.medicine_id=p.medicine_id  
 left join sales s on p.medicine_id=s.medicine_id
 where sale_date is null;
 
 -- Retrieve the number of prescriptions issued by each doctor in the last 6 months.
 select d.name,count(p.prescription_id) total from doctors d 
 join prescription p 
 on d.doctor_id=p.doctor_id
 where prescription_date>=curdate()-interval 6 month 
 group by d.name,d.doctor_id ;

-- Find medicines that are sold but never prescribed.
select distinct(medicine_name) from  medicines m 
join sales s 
on m.medicine_id=s.medicine_id  
left join prescription_details pd 
on s.medicine_id=pd.medicine_id 
where pd.medicine_id is null;


-- List prescriptions that contain more than 3 different medicines
select prescription_id,count(medicine_id) from prescription_details 
group by prescription_id 
having count(medicine_id)>3;

--  List suppliers supplying medicines that are currently out of stock
select distinct s.supplier_name, s.contact_number, s.location
from suppliers s
join restock_alerts ra 
on s.medicine_id = ra.medicine_id;


-- Find the most commonly prescribed medicine.
select m.medicine_name,count(p.medicine_id) as highest from medicines m 
join prescription_details p 
on m.medicine_id=p.medicine_id 
group by m.medicine_name order by count(p.medicine_id) desc limit 1 ;

-- Show total quantity of each medicine sold in each city
select p.city, sum(s.quantity) as total_quantity
from sales s
join patients p on s.patient_id = p.patient_id
group by p.city;

 -- Identify doctors who have never prescribed any medicine.
select d.name from doctors d where not exists (select 1 from prescription p where d.doctor_id=p.doctor_id);

-- Identify patients who purchased a medicine more than 15 days after it was prescribed.
select name from patients p join prescription pp on p.patient_id=pp.patient_id 
join sales s 
on pp.patient_id=s.patient_id 
where sale_date> prescription_date+ interval 15 day ;

-- Find doctors who prescribed the most medicines overall.
select d.name,count(pd.medicine_id) as total from  doctors d 
join prescription p 
on d.doctor_id=p.doctor_id 
join prescription_details pd
on p.prescription_id=pd.prescription_id 
group by d.name,d.doctor_id;

-- Identify patients who purchased a medicine not prescribed to them.
select p.name from patients p 
join prescription pr 
on p.patient_id=pr.patient_id 
join prescription_details pd 
on pr.prescription_id=pd.prescription_id where not exists( select 1 from sales s where pr.patient_id = p.patient_id
 and pd.medicine_id=s.medicine_id);
 
-- Create a trigger that reduces stock_quantity from the Medicines table after each insertion into the Sales table.

delimiter //
create trigger tri_reduce_stock
after insert on sales
for each row
begin
  update medicines
  set stock_quantity=stock_quantity-new.quantity
  where medicine_id=new.medicine_id;
end //
delimiter ;


--  Create a trigger to send a restock alert (insert into Restock_Alerts table) when stock_quantity falls below 10.
delimiter //
create trigger restock_alert
after insert on sales
for each row
begin   
	   update medicines
	   set stock_quantity=stock_quantity-new.quantity
       where medicine_id=new.medicine_id;
       
       if (select stock_quantity 
        from medicines 
        where medicine_id=new.medicine_id)<10 then
       
        insert into restock_alerts(medicine_id,alert_date,note)
        values(new.medicine_id,curdate(),"stock  below 10");
	   end if;
end //
delimiter ;
       
-- Create a procedure to generate a bill for a patient by calculating the total amount for all medicines purchased on a specific date

delimiter //
create procedure generate_bill(in p_patient_id varchar(20),in p_date date)
begin
  select sum(quantity* price_per_unit) as total_bill from sales s 
  join medicines m 
  on s.medicine_id=m.medicine_id 
  where s.patient_id=p_patient_id
  and s.sale_date=p_date;
end //
delimiter  ;

-- Write a stored procedure that takes a doctor’s ID and returns the list of all patients they’ve treated, with total prescriptions.

delimiter //
create procedure patient_list(in d_doctor_id varchar(20))
begin
   select d.doctor_id,p.name as patient_name, count(pr.prescription_id) as total_prescription from doctors d 
   join prescription pr on d.doctor_id=pr.doctor_id 
   join patients p on p.patient_id=pr.patient_id
   where d.doctor_id=d_doctor_id
   group by d.doctor_id,p.name;
end //
delimiter ;


-- Write a procedure that returns the sales summary (total quantity, total revenue) for given date range and medicine category.

delimiter //
create procedure sales_summary(in start_date date, in end_date date, in medicine_category varchar(20))
begin
    select sum(s.quantity) total_quantity ,sum(s.quantity* m.price_per_unit) as total_revenue from medicines m 
    join sales s on m.medicine_id=s.medicine_id  
    where sale_date between start_date and end_date 
    and m.category=medicine_category;
end //
delimiter ;


