Create database finalproject;

USE finalproject;

# Declaration of Primary Keys

# Natural key as Primary key in Patientdetails table

ALTER TABLE dim_patientdetails
ADD PRIMARY KEY (member_id);

# Natural key as Primary key in Drugdetails table

ALTER TABLE dim_drugdetails
ADD PRIMARY KEY (drug_ndc);

# Surrogate key as Primary key in Paymentdetails table

Alter table fact_paymentdetails
ADD payment_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY;

# Natural key as Primary key in Drugbrand table

ALTER TABLE dim_drugbrand
ADD PRIMARY KEY (drug_brand_generic_code);

# Natural key as Primary key in Drugform table

ALTER TABLE dim_drugform
MODIFY drug_form_code CHAR(5);
ALTER table dim_drugform
ADD PRIMARY KEY (drug_form_code);

# Declaration of Foreign Keys   

ALTER TABLE  fact_paymentdetails
ADD FOREIGN KEY drug_fk(drug_ndc)
REFERENCES dim_drugdetails(drug_ndc)
ON DELETE SET NULL
ON UPDATE RESTRICT;

ALTER TABLE  fact_paymentdetails
ADD FOREIGN KEY patient_fk(member_id)
REFERENCES dim_patientdetails(member_id)
ON DELETE SET NULL
ON UPDATE RESTRICT;


ALTER TABLE  dim_drugdetails
ADD FOREIGN KEY drugbrand_fk(drug_brand_generic_code)
REFERENCES dim_drugbrand(drug_brand_generic_code)
ON DELETE SET NULL
ON UPDATE RESTRICT;


ALTER TABLE dim_drugdetails
MODIFY drug_form_code CHAR(5);
ALTER TABLE  dim_drugdetails
ADD FOREIGN KEY drugform_fk(drug_form_code)
REFERENCES dim_drugform(drug_form_code)
ON DELETE SET NULL
ON UPDATE RESTRICT;

# Number of prescriptions grouped by drug name

select drug_name,
count(*) as Total 
from dim_drugdetails dd 
left join fact_paymentdetails fd on dd.drug_ndc = fd.drug_ndc 
group by drug_name order by count(*) desc;


# Total prescriptions, unique members, total copay & insurance paid $$, for members either ‘age 65+’ or ’ < 65’

select count(fd.drug_ndc) as PRESCRIPTIONS, count(distinct fd.member_id) as MEMBERS, sum(fd.copay) as COPAY_TOTAL,
sum(fd.insurancepaid) as INSURANCE_TOTAL , 
case 
when pd.member_age > 65 then 'age Over 65'
When pd.member_age < 65 then 'age below 65'
end as Age_group
from fact_paymentdetails fd left join dim_patientdetails pd on fd.member_id = pd.member_id
group by Age_group;


# Amount paid by the insurance for the most recent prescription fill date

create table recentinsurance as
select fd.member_id,pd.member_first_name,pd.member_last_name,dd.drug_name,fd.fill_date,fd.insurancepaid, 
row_number() over (partition by fd.member_id order by fd.member_id,fd.fill_date desc) as flag
from fact_paymentdetails fd left join dim_patientdetails pd on fd.member_id = pd.member_id 
left join dim_drugdetails dd on fd.drug_ndc = dd.drug_ndc;

select member_id,member_first_name,member_last_name,drug_name,fill_date,insurancepaid from recentinsurance where flag= 1 ;

