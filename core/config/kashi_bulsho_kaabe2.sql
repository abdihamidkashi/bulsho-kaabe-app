-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Mar 02, 2024 at 10:39 AM
-- Server version: 5.7.23-23
-- PHP Version: 8.1.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `kashi_bulsho_kaabe2`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`kashi`@`localhost` PROCEDURE `agent_sp` (IN `_company_id` INT, IN `_name` VARCHAR(100), IN `_tell` INT, IN `_address` VARCHAR(100), IN `_gender` VARCHAR(100), IN `_password` INT, IN `_short_link` VARCHAR(100), IN `_date` DATE)   BEGIN 

                IF EXISTS(SELECT `id` FROM `agent`  WHERE  tell = _tell) THEN
                SELECT concat('danger| waan ka xunnahay Taleefan-kan ',_tell,' horay ayuu u diiwangashnaa ') as msg;
                else
              CALL ktc_set_auto_sp(_company_id,'agent');             
   
                INSERT INTO `agent` (auto_id,company_id ,name ,tell,address,gender,short_link,date, `password` ) 
                VALUES (@auto,_company_id,_name ,_tell,_address,_gender,_short_link,_date,_password);
                
                SELECT concat('success|',_name,' waad ku mahadsantahy is diiwaangelitaada bulsho tech, si aad uga qeyb qaadato tartan-ka App-ka Bulsho tech koobiyeyso ',_short_link, ' lana wadaag asxaabtaada') as msg;
                end if;
                 END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `app_patient_sp` (IN `_company_id` INT, IN `_hospital_id` INT, IN `_doctor_id` INT, IN `_name` VARCHAR(100), IN `_gender` VARCHAR(50), IN `_day` INT, IN `_month` INT, IN `_year` INT, IN `_mother` VARCHAR(100), IN `_address` VARCHAR(100), IN `_tell` VARCHAR(50), IN `_payment_tell` VARCHAR(50), IN `_amount` DOUBLE, IN `_description` VARCHAR(150), IN `_status` INT, IN `_evc_respone` VARCHAR(150))   BEGIN 
START TRANSACTION;
set sql_mode = '';
CALL ktc_set_auto_sp(_company_id, 'app_patient');
SET @dob = concat(_year,'-',_month,'-',_day);
INSERT INTO `app_patient`(  `auto_id`, `company_id`, `hospital_id`, `doctor_id`, `name`, `tell`, `address`, `dob`, `mother`,   `date`, gender, payment_tell, status, evc_response, description, amount ) VALUES (@auto, _company_id, _hospital_id, _doctor_id, _name, _tell, _address, @dob, _mother,    date(now2()), _gender,_payment_tell , _status, _evc_respone , _description, _amount);

SELECT d.name, dp.name, h.name into @doctor,@department, @hospital from doctor d join department dp on d.department_id = dp.auto_id join hospital h on h.auto_id = d.hospital_id where d.hospital_id = _hospital_id and d.auto_id = _doctor_id;

SET @tells = concat('252615190777,252614945027,252614945026');


if(_status = 0) THEN 

SELECT concat('warning|',_name,' waan-ka xunnahay dalbashadaada <b>', _description, '</b> ma dhameystirna, fadlan dib usoo dalbo lacagtana bixi' ) as msg,  concat('*[Bulsho Tech - Dalab Number]*
Tariikh: *',trim(now2()),'*
Waxaa isku day number dalbasho oo aan dhameystorneyn 

Magaca: *',trim(_name),'*
Tel-ka: *',trim(_tell),'*
Dhashay: *',_day,'/',_month,'/',_year,'*
Isbitaalka: *',trim(@hospital),' (',trim(@department),')*
Dhaqtar-ka: *',trim(@doctor),'*
Hooyo: *',trim(_mother),'*
Deegaan-ka: *',trim(_address),'*
Faafaahin: *',trim(_description),'*

Kala xiriir WA: *wa.me/252',right(trim(_tell),9),'*
') sms_wa, @tells tell_wa;

ELSE

if EXISTS(SELECT id from patient where right(tell,9) = right(_tell,9) and name like _name) THEN 

SELECT auto_id into @patient_id from patient where right(tell,9) = right(_tell,9) and name like _name;

ELSE
CALL ktc_set_auto_sp(1, 'patient');

SET @patient_id = @auto;

INSERT INTO `patient`( `auto_id`, `company_id`, `name`, `gender`, `tell`, `address`, `dob`, `mother`, `description`, `user_id`, `date` ) VALUES (@patient_id, 1, _name, _gender, _tell, _address, @dob, _mother, _description, 4, date(now2()));

END IF;


CALL ktc_set_auto_sp(1, 'ticket');

INSERT INTO `ticket`( `auto_id`, `company_id`, `patient_id`, `hospital_id`, `doctor_id`, `amount`, `payment_tell`, `image`, `hospital_ticket`, `user_id`, `date` ) VALUES ( @auto, 1, @patient_id, _hospital_id, _doctor_id, _amount, _payment_tell, '', 0, 4, date(now2()));


SET @last_id = LAST_INSERT_ID();

SELECT p.name, right(p.tell,9), dp.name, h.name, DATE_FORMAT(t.date, "%d/%m/%y"), right(trim(ifnull(h.cashier_tell,ifnull(h.tell,'634432380'))),9)  into @patient,@tell, @department, @hospital, @date, @cashier_tell from ticket t join doctor d on d.auto_id=t.doctor_id join department dp on dp.auto_id=d.department_id join hospital h on h.auto_id = t.hospital_id join patient p on p.auto_id=t.patient_id where t.id = @last_id;



SELECT concat('success|',_name,' waad ku mahadsantahay dalbashadaada <b>', _description, '</b> waalagu guuleystay, Ticket Number-kaaga dib ayaan kaaga soo sheegeynaa' ) as msg,  concat(left(@patient,10),' Tar: ',@date,' Waxaan Ticket Number kaaga dalab-nay ',@hospital,'/', @department,', long_url kala soco Ticket-kaaga' )  sms , @tell tell, concat('Waxaa number soo dalbaday ',left(@patient,10),' Tar: ',@date,' qeybta ', @department,', guji long_url fafaahin dheeri ah mahadsanid' )  sms2 , @cashier_tell tell2,CONCAT('https://bk.bulshotech.com/forms/invoice2/',@last_id,'/ticket/',_company_id) long_url,  concat('*[Bulsho Tech - Dalab Number]*
Tariikh: *',trim(now2()),'*
Waxaa number soo dalbaday

Magaca: *',trim(_name),'*
Tel-ka: *',trim(_tell),'*
Dhashay: *',_day,'/',_month,'/',_year,'*
Isbitaalka: *',trim(@hospital),' (',trim(@department),')*
Dhaqtar-ka: *',trim(@doctor),'*
Hooyo: *',trim(_mother),'*
Deegaan-ka: *',trim(_address),'*
Faafaahin: *',trim(_description),'*
Kala xiriir WA: *wa.me/252',right(trim(_tell),9),'*
') sms_wa, @tells tell_wa;  

END IF;
COMMIT;              
END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `blood_sp` (IN `_company_id` INT, IN `_name` VARCHAR(100), IN `_tell` INT, IN `_address` VARCHAR(100), IN `_gender` VARCHAR(100), IN `_blood_group` VARCHAR(100), IN `_date` DATE)   BEGIN 

                IF EXISTS(SELECT `id` FROM `blood`  WHERE  name = _name) THEN
                SELECT concat('danger|',_name,' already exists, please change and try again.') as msg;
                else
              CALL ktc_set_auto_sp(_company_id,'blood');             
   
                INSERT INTO `blood` (auto_id,company_id ,name ,tell,address,gender,blood_group,date ) 
                VALUES (@auto,_company_id,_name ,_tell,_address,_gender,_blood_group,_date);
                
                SELECT concat('success|',_name,' registered success') as msg;
                end if;
                 END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `branch_sp` (IN `_auto_id` INT, IN `_company_id` INT, IN `_employee_id` INT, IN `_name` VARCHAR(100), IN `_tell` VARCHAR(100), IN `_email` VARCHAR(50), IN `_address` VARCHAR(100), IN `_user_id` INT, IN `_date` DATE)   BEGIN 

IF EXISTS(SELECT `id` FROM `branch`  WHERE `name` = _name AND `address` = _address AND `company_id` = _company_id  ) THEN
SELECT concat('warning|',CONCAT(_name,' ',_address,' ',_company_id),' already exists, please change and try again.');
else
CALL ktc_set_auto_sp(_company_id,'branch');
SET _auto_id = @auto;
INSERT INTO `branch` (`auto_id`,`company_id`,`employee_id`,`name`,`tell`,`email`,`address`,`user_id`,`date`) VALUES (_auto_id,_company_id,_employee_id,_name,_tell,_email,_address,_user_id,_date);

SELECT concat('success| ',CONCAT(_name),' registered success');
end if;
 END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `company_sp` (IN `_name` VARCHAR(100), IN `_address` VARCHAR(100), IN `_email` VARCHAR(50), IN `_domain` VARCHAR(100), IN `_letter_head` VARCHAR(100), IN `_logo` VARCHAR(100), IN `_user_id` INT, IN `_admin` VARCHAR(50), IN `_tell` VARCHAR(50), IN `_username` VARCHAR(50), IN `_password` VARCHAR(50), IN `_confirm` VARCHAR(50), IN `_date` DATE, IN `_co_type` VARCHAR(50))   BEGIN 
SET @domain_1 = ktc_split(_domain,'.',1);
SET @domain_2 = ktc_split(_domain,'.',2);
SET @domain_3 = ktc_split(_domain,'.',3);
SET _domain = replace(_domain,' ','');
IF EXISTS(SELECT id FROM company  WHERE CONCAT(name) = CONCAT(_name) or domain = _domain) THEN
SELECT concat('danger|',name,' or ', _domain,' already exists, please change and try again.') msg;
ELSEIF(_password != _confirm) THEN
SELECT concat('warning|Password & confirm not Match, please try again') msg;
ELSEIF(@domain_2 != 'ohticket' or @domain_3 != 'com') THEN
SELECT concat('warning|Hospital domain must contain ohticket.com, eg. hospitalname.ohticket.com, please try again') msg;

else
BEGIN
SET AUTOCOMMIT = 0;
START TRANSACTION;
INSERT INTO company (name,tell,email,address,domain,letter_head,logo,user_id,date,type,expiry_date) VALUES (_name,_tell,_email,_address,_domain,_letter_head,_logo,_user_id,_date,_co_type, now()+INTERVAL 7 day);

SET @CID = LAST_INSERT_ID();

call ktc_set_auto_sp(@CID,'branch');

INSERT INTO `branch`(auto_id, `company_id`, `employee_id`, `name`, `tell`, `address`, `user_id`, `date`) VALUES (@auto,@CID,0,_name,_tell,_address,_user_id,_date);

SET @BID =@auto;



call ktc_set_auto_sp(@CID,'ktc_user');

SET @token = md5(now());


INSERT INTO `ktc_user`(auto_id, `name`, `username`, `password`, `tell`, `image`,  `date`, `email`, `user_id`, `company_id`,branch_id, status, reset_code) VALUES (@auto,_admin,_username,md5(_password),_tell,_logo,_date,_email,_user_id,@CID,@BID, 0, @token);
COMMIT;

SET AUTOCOMMIT = 1;
end;

SET @token = md5(now());
SELECT CONCAT('success|',_name,' Registered success, please visit ', _username,'  and check inbox or spam') msg, concat('<h3>',_name, ' welcome to BULSHO TECH Services</h43 <p>Thank you for using BULSHO TECH service, to activate your user please click <a href="https://',_domain,'/users/activate/',_username,'/',@token,'">https://',_domain,'/users/activate/',@token,'</a></p>
<h4>Below is ',_name, ' information</h4>
<p> Name : <strong>',_name,'</strong></p>
<p> Domain : <strong>',_domain,'</strong></p>
<p> User Email : <strong>',_username,'</strong></p>
<p> Password : <strong>',_password,'</strong></p> ') message,_username `email`, concat('New account from ',_domain) title;

CALL ktc_copy_multi_form_sp(3,@CID,@auto);


end if;
 END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `department_sp` (IN `_company_id` INT, IN `_name` VARCHAR(100), IN `_image` VARCHAR(200), IN `_description` VARCHAR(100), IN `_user_id` INT, IN `_date` DATE)   BEGIN 

                IF EXISTS(SELECT `id` FROM `department`  WHERE  name = _name) THEN
                SELECT concat('danger|',_name,' already exists, please change and try again.') as msg;
                else
                 CALL ktc_set_auto_sp(_company_id,'department');             INSERT INTO `department` (auto_id, company_id , name ,image ,description,user_id,date ) 
                VALUES (@auto, _company_id,_name ,_image,_description,_user_id,_date);
                
                SELECT concat('success|',_name,' registered success') as msg;
                end if;
                 END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `doctor_sp` (IN `_company_id` INT, IN `_hospital_id` INT, IN `_name` VARCHAR(100), IN `_tell` INT, IN `_image` VARCHAR(100), IN `_department_id` INT, IN `_ticket_fee` VARCHAR(100), IN `_description` TEXT, IN `_user_id` INT, IN `_date` DATE)   BEGIN 

                IF EXISTS(SELECT `id` FROM `doctor`  WHERE  name = _name) THEN
                SELECT concat('danger|',_name,' already exists, please change and try again.') as msg;
                else
              CALL ktc_set_auto_sp(_company_id,'doctor');             
   
                INSERT INTO `doctor` (auto_id,company_id ,hospital_id,name ,tell,image,department_id,description,ticket_fee,user_id,date ) 
                VALUES (@auto,_company_id,_hospital_id,_name ,_tell,_image,_department_id,_description,_ticket_fee,_user_id,_date);
                
                SELECT concat('success|',_name,' registered success') as msg;
                end if;
                 END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `evc_app_receipt_sp` (IN `_company_id` INT, IN `_patient_id` INT, IN `_hospital_id` INT, IN `_doctor_id` INT, IN `_amount` DOUBLE, IN `_date` DATE)   BEGIN 

                IF EXISTS(SELECT `id` FROM `evc_app_receipt`  WHERE  name = _name) THEN
                SELECT concat('danger|',_name,' already exists, please change and try again.') as msg;
                else
               
                INSERT INTO `evc_app_receipt` (company_id ,patient_id ,hospital_id ,doctor_id,amount,date ) 
                VALUES (_company_id,_patient_id,_hospital_id ,_doctor_id,_amount,_date);
                
                SELECT concat('success|',_name,' registered success') as msg;
                end if;
                 END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `expense_sp` (IN `_company_id` INT, IN `_expense_id` INT, IN `_amount` VARCHAR(200), IN `_description` VARCHAR(100), IN `_type` VARCHAR(50), IN `_user_id` INT, IN `_date` DATE)   BEGIN 

                
                 CALL ktc_set_auto_sp(_company_id,'expense');             INSERT INTO `expense` (auto_id, company_id , expense_id ,amount ,description,type,user_id,date ) 
                VALUES (@auto, _company_id,_expense_id,_amount,_description,_type,_user_id,_date);
                
                SELECT concat('success|',_expense_id,' registered success') as msg;
                
                 END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `faq_sp` (IN `_company_id` INT, IN `_question` TEXT, IN `_answer` LONGTEXT, IN `_user_id` INT, IN `_date` DATE)   BEGIN

CALL ktc_set_auto_sp(_company_id, 'faq');

INSERT INTO `faq`( `auto_id`, `company_id`, `question`, `answer`, `user_id`, `date` ) VALUES (  @auto, _company_id, _question, _answer, _user_id, _date  );


SELECT 'success|FaQ Registered success' msg;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `general_sp` (IN `p_auto_id` INT, IN `p_company_id` INT, IN `p_name` VARCHAR(250), IN `p_type` VARCHAR(50), IN `p_user_id` INT, IN `p_date` DATE)   BEGIN 

IF EXISTS(SELECT `id` FROM `general`  WHERE `company_id` = p_company_id  and name = p_name AND type= p_type) THEN
SELECT concat('warning|',CONCAT(p_company_id,' ',p_name),' already exists, please change and try again.') msg;
else
CALL ktc_set_auto_sp(p_company_id,'general');
SET p_auto_id = @auto;
INSERT INTO `general` (`auto_id`,`company_id`,`name`,`type`,`user_id`,`date`) VALUES (p_auto_id,p_company_id,p_name,p_type,p_user_id,p_date);

SELECT concat('success|',CONCAT(p_name),' ','registered success') msg;
end if;
 END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `get_hospital_sp` (IN `_hospital_id` INT, IN `_user_id` INT, IN `_company_id` INT)  NO SQL BEGIN

SELECT logo into @logo from company where id = _company_id;

SELECT name into @bulsho_agent from ktc_user where auto_id = _user_id;

SELECT h.auto_id, h.name hospital, h.address, h.city, h.region, h.ticket_fee, h.service_fee, h.commission_fee, h.currency, h.logo, h.manager, h.date, @logo bulsho_logo, @bulsho_agenet bulsho_agent, if(h.region = 'Somaliland', concat(h.city,'/Somaliland'), concat(h.region,'/Somalia')) state_country, if(h.region = 'Somaliland', 'Hargeysa Somaliland', 'Mogadishu Somalia') bulsho_address   from hospital h where h.auto_id = _hospital_id;


END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `hospital_sp` (IN `_company_id` INT, IN `_name` VARCHAR(100), IN `_tell` INT, IN `_cashier_tell` INT, IN `_region` VARCHAR(100), IN `_city` VARCHAR(100), IN `_address` VARCHAR(100), IN `_ticket_fee` INT, IN `_commission_fee` INT, IN `_service_fee` INT, IN `_logo` INT, IN `_user_id` INT, IN `_date` DATE)   BEGIN 

                IF EXISTS(SELECT `id` FROM `hospital`  WHERE  name = _name) THEN
                SELECT concat('danger|',_name,' already exists, please change and try again.') as msg;
                else
  CALL ktc_set_auto_sp(_company_id,'hospital');             
                INSERT INTO `hospital` (auto_id, company_id ,name ,tell ,cashier_tell,address,city,region,ticket_fee,commission_fee,service_fee,logo,user_id,date ) 
                VALUES (@auto,_company_id,_name ,_tell ,_cashier_tell,_address,_city,_region,_ticket_fee,_commission_fee,_service_fee,_logo,_user_id,_date);
                
                SELECT concat('success|',_name,' registered success') as msg;
                end if;
                 END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_activate_user_sp` (IN `_company_id` INT, IN `_username` VARCHAR(50), IN `_token` VARCHAR(250))  NO SQL BEGIN

if EXISTS (SELECT id from ktc_user where company_id = _company_id and username = _username and reset_code = _token) THEN

UPDATE ktc_user set status = 1, reset_code = '' where company_id = _company_id and username = _username and reset_code = _token;

SELECT concat('success|Username :', _username,' activated success') msg;

ELSE

SELECT concat('danger|Username :', _username,' activation failed') msg;


end if;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_add_chart_sp` (IN `chart_p` VARCHAR(50), IN `icon_p` VARCHAR(50), IN `class_color_p` VARCHAR(50), IN `description_p` TEXT, IN `type_p` VARCHAR(50), IN `position_p` VARCHAR(50), IN `co_p` INT, IN `user_p` INT)  NO SQL BEGIN

CALL ktc_set_auto_sp(co_p,'ktc_chart');

INSERT INTO `ktc_chart`(auto_id,company_id,`chart`, `icon`, `class_color`, `description`, `type`, `position`,user_id) VALUES(@auto,co_p,chart_p,icon_p,class_color_p,description_p,type_p,position_p,user_p);
SELECT concat('success|',chart_p,' has been registered')as msg;
end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_autocomplete_sp` (IN `action_p` VARCHAR(50), IN `prefix_p` VARCHAR(200), IN `co_p` INT, IN `user_p` INT)  NO SQL BEGIN

select RIGHT(action_p,1)into @r;

SELECT LEFT(action_p,char_length(action_p)-1) into @action;

SELECT ktc_access(user_p,'user') into @users;

SELECT ktc_access(user_p,'branch') into @branches;
 
 SELECT ktc_access(user_p,'hospital') into @hospitals;
 
if (@r='|')THEN

set @sql=concat('select auto_id ,name  from ',@action, ' where name like ',QUOTE(concat('%',prefix_p,'%')) ,' and company_id = ',co_p, ' limit 10');

PREPARE s FROM @sql ;
EXECUTE s;

elseif (action_p like '%,%') THEN
SET @t = ktc_split(action_p,',',1);
SET @c = ktc_split(action_p,',',2);
SET @v = ktc_split(action_p,',',3);
if(@v = 'customer') THEN
select c.auto_id ,CONCAT(c.name,' (<b>',c.tell,'</b>) - ',ifnull(p.date,''),' $',ifnull(p.amount,0))  from general c left join payment p on p._id=c.auto_id and c.company_id=p.company_id where c.type = 'customer'   and (c.name like CONCAT('%',prefix_p,'%')  OR c.tell like CONCAT('%',prefix_p,'%') ) and c.company_id = co_p;
else
set @sql=concat('select auto_id ,name  from ',@t,' where ',@c,' like ',quote(@v) ,' and name like ',QUOTE(prefix_p) ,'  and company_id = ',co_p,' limit 10');
PREPARE s FROM @sql ;
EXECUTE s;
end if;

elseif (action_p = 'sp') THEN

SELECT ROUTINE_NAME a,ROUTINE_NAME  id FROM information_schema.ROUTINES WHERE  `ROUTINE_SCHEMA` = database()  and ROUTINE_NAME like CONCAT('%',prefix_p,'%');
 ELSEIF(action_p = 'icon') THEN
SELECT `value`,CONCAT('<i class="',`value`,'"></i>',' ',`value`) icon FROM ktc_dropdown WHERE `value` like CONCAT('%',prefix_p,'%') and `action` = 'icon'  limit 30;

 ELSEIF(action_p = 'hospital') THEN
SELECT auto_id, name  FROM hospital WHERE name like CONCAT('%',prefix_p,'%') and find_in_set(auto_id, @hospitals) limit 30;


end if;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_cancel_sp` (IN `id_p` VARCHAR(50), IN `table_p` VARCHAR(50), IN `col_p` VARCHAR(50), IN `status_p` VARCHAR(50), IN `user_p` INT, IN `description_p` VARCHAR(200), IN `password_p` VARCHAR(50), IN `co_p` INT)  NO SQL BEGIN
if EXISTS(select id from ktc_user where auto_id = user_p and company_id = co_p and (password = md5(password_p) or password_p ='force_del_data')) then
 
 
SET @sql = CONCAT('UPDATE ',table_p,' SET status = ',status_p,' , deleted_user_id = ',user_p,', deleted_description = ',quote(description_p),', deleted_date = now2() WHERE id = ',quote(id_p));
 

PREPARE s FROM @sql;
EXECUTE s;

SELECT CONCAT('success|Canceled success, you can undo this transuction any time') msg;
 
ELSE

SELECT 'danger|Incorrect Password, you don''t have permission to cancel' as msg;


end if;
END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_category_sp` (IN `category_p` VARCHAR(50), IN `icon_p` VARCHAR(50), IN `user_p` INT, IN `co_p` INT)  NO SQL BEGIN
CALL ktc_set_auto_sp(co_p,'ktc_category');

insert INTO ktc_category(name,icon,user_id,company_id,auto_id)
VALUES(category_p,icon_p,user_p,co_p,@auto);
SELECT concat('success|',category_p,' Has been registred')as msg;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_change_pass_sp` (IN `user_p` VARCHAR(100), IN `pass_p` VARCHAR(250), IN `new_p` VARCHAR(250), IN `pass2_p` VARCHAR(250), IN `co_p` INT)  NO SQL BEGIN 

IF(new_p='')THEN

SELECT concat('warning|password Can`t be null') as msg;

ELSEIF(new_p != pass2_p) THEN
SELECT concat('warning|Password not Match, Check confirm Password') as msg;

elseif NOT EXISTS(SELECT id FROM ktc_user WHERE company_id = co_p and (auto_id = user_p AND password = md5(pass_p) ) OR pass_p = 'reset_reset_ktc' OR reset_code = pass_p) THEN

SELECT concat('danger|Current Password is incorrect, Please try again') as msg;

ELSEIF EXISTS(SELECT id FROM ktc_user WHERE auto_id = user_p and password =  md5(new_p) and company_id = co_p) THEN

SELECT concat('warning|New Password matchs Current password, Please use New Password or use your old Password') as msg;


ELSE

UPDATE ktc_user SET password =  md5(new_p), reset_code = '' WHERE (auto_id = user_p or username = user_p) and company_id = co_p;

SELECT username, name into @user, @name from ktc_user where auto_id = user_p and company_id = co_p;

SELECT CONCAT('Assalamu aliakum ',@name,' your account ',@user,'  has been changed the password   at ' ,now(),'') into @sms ;


SELECT concat('success|Password changed success') as msg, @sms sms, @sms message, @email email, @tell tell, 'Change Password Notification' title ;

END IF;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_common_paramete_sp` (IN `parameter_p` VARCHAR(100), IN `label_p` VARCHAR(100), IN `type_p` VARCHAR(100), IN `action_p` VARCHAR(100), IN `class_p` VARCHAR(100), IN `size_p` VARCHAR(100), IN `load_action_p` VARCHAR(100), IN `user_p` INT, IN `placeholder_p` VARCHAR(100))  NO SQL BEGIN
    
   insert into ktc_common_param(parameter,label,type,action,class,size,load_action,user_id,placeholder)
   VALUES(parameter_p,label_p,type_p,action_p,class_p,size_p,load_action_p,user_p,placeholder_p);
   SELECT concat('success|',parameter_p,' Registered as a common parameter success') as msg;
    
    
    END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_complete_user_sp` (IN `user_p` INT, IN `tell_p` VARCHAR(50), IN `email_p` VARCHAR(100), IN `image_p` VARCHAR(250))  NO SQL BEGIN


UPDATE ktc_user set tell = tell_p , email = email_p , image = if(image_p = '', image, image_p) where id = user_p;

SELECT 'success|User completed success';


END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_copy_form_sp` (IN `co_p` INT, IN `category_p` INT, IN `sub_category_p` INT, IN `link_p` INT, IN `text_p` VARCHAR(50), IN `title_p` VARCHAR(50), IN `co2_p` INT, IN `category2_p` INT, IN `sub_category2_p` INT, IN `user_p` INT)  NO SQL BEGIN
SET AUTOCOMMIT = 0;
START TRANSACTION;

CALL ktc_set_auto_sp(co2_p,'ktc_link');

INSERT IGNORE INTO `ktc_link`(auto_id,`href`, `category_id`, `sub_category_id`, `name`, `title`, `sp`, `description`, `form_action`, `btn`, `date`, `link_icon`, `status`, `user_id`,company_id,form_name) SELECT @auto, `href`,category2_p, sub_category2_p,text_p, title_p, `sp`, `description`, `form_action`, `btn`, `date`, `link_icon`, `status`, user_p,co2_p,concat(form_name,'.') FROM `ktc_link` WHERE auto_id=link_p and company_id = co_p;



INSERT INTO `ktc_parameter`( `parameter`, `type`, `action`, `placeholder`, `lable`, `class`, `size`, `load_action`, `help_text`, `default_value`, `is_required`, `link_id`,`table`, `columns`,company_id)  SELECT `parameter`, `type`, `action`, `placeholder`, `lable`, `class`, `size`, `load_action`, `help_text`, `default_value`, `is_required`, @auto ,`table`, `columns`,co2_p FROM ktc_parameter WHERE link_id = link_p and company_id = co_p;

SELECT concat('success|',l.name,' has been copied success') as msg FROM ktc_link l WHERE auto_id=link_p and company_id = co_p;
COMMIT;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_copy_multi_form_sp` (IN `_company_id` INT, IN `_company2_id` INT, IN `_user_id` INT)  NO SQL BEGIN
START TRANSACTION;
INSERT IGNORE INTO `ktc_category`( `auto_id`, `name`, `icon`, `description`, `order_by`, `company_id`, `user_id`, `date`) 
SELECT `auto_id`, `name`, `icon`, `description`, `order_by`, _company2_id, _user_id, now2() from ktc_category where company_id = _company_id and name != 'Developer';

INSERT IGNORE INTO `ktc_sub_category`(`auto_id`, `category_id`, `name`, `icon`, `description`, `order_by`, `company_id`, `user_id`, `date`)
SELECT `auto_id`, `category_id`, `name`, `icon`, `description`, `order_by`, _company2_id, _user_id, now2() from ktc_sub_category where company_id = _company_id and category_id not in (SELECT auto_id from ktc_category where company_id = _company_id and name = 'Developer');

REPLACE INTO `ktc_link`(`auto_id`, `href`, `category_id`, `sub_category_id`, `name`, `title`, `sp`, `description`, `form_action`, `btn`, `date`, `link_icon`, `status`, `order_by`, `company_id`, `level`, `user_id`,dropdown_action,form_name)
SELECT `auto_id`, `href`, `category_id`, `sub_category_id`, `name`, `title`, `sp`, `description`, `form_action`, `btn`,  now2(), `link_icon`, `status`, `order_by`, _company2_id, `level` , _user_id,dropdown_action,form_name from ktc_link where company_id = _company_id and category_id not in (SELECT auto_id from ktc_category where company_id = _company_id and name = 'Developer');

SET @forms = ROW_COUNT();

INSERT IGNORE INTO `ktc_parameter`( `parameter`, `type`, `action`, `placeholder`, `lable`, `class`, `size`, `load_action`, `help_text`, `default_value`, `is_required`, `description`, `link_id`, `company_id`, `table`, `columns`, `sample`, `date`) 

SELECT p.`parameter`, p.`type`, p.`action`, p.`placeholder`, p.`lable`, p.`class`, p.`size`,p.`load_action`, p.`help_text`, p.`default_value`, p.`is_required`, p.`description`, p.`link_id`, _company2_id, p.`table`, p.`columns`, p.`sample`, now2() FROM ktc_parameter p join ktc_link l on l.auto_id=p.link_id and l.company_id=p.company_id WHERE p.company_id = _company_id and l.category_id not in (SELECT auto_id from ktc_category where company_id = _company_id and name = 'Developer');

INSERT INTO `ktc_chart`( `auto_id`, `chart`, `icon`, `class_color`, `description`,`description2`,  `type`, `position`, `user_id`, `company_id`, `date`) SELECT `auto_id`, `chart`, `icon`, `class_color`, `description`,`description2`, `type`, `position`, _user_id, _company2_id,now2() from ktc_chart where company_id = _company_id;

SELECT CONCAT('success|Copied ',@forms,' Success');

COMMIT;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_copy_parameter_sp` (IN `co_p` INT, IN `category_p` INT, IN `sub_category_p` INT, IN `link_p` INT, IN `co2_p` INT, IN `category2_p` INT, IN `sub_category2_p` INT, IN `link2_p` INT, IN `user_p` INT)  NO SQL BEGIN
SET AUTOCOMMIT = 0;
START TRANSACTION;

DELETE FROM ktc_parameter where link_id = link2_p and company_id = co2_p;

INSERT INTO `ktc_parameter`( `parameter`, `type`, `action`, `placeholder`, `lable`, `class`, `size`, `load_action`, `help_text`, `default_value`, `is_required`, `link_id`,`table`, `columns`,company_id)  SELECT `parameter`, `type`, `action`, `placeholder`, `lable`, `class`, `size`, `load_action`, `help_text`, `default_value`, `is_required`, link2_p ,`table`, `columns`,co2_p FROM ktc_parameter WHERE link_id = link_p and company_id = co_p;

SELECT concat('success|',l.name,' has been copied success') as msg FROM ktc_link l WHERE auto_id=link_p and company_id = co_p;
COMMIT;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_copy_permission_sp` (IN `copy_user_p` INT, IN `paste_user_p` VARCHAR(250), IN `user_p` INT, IN `action_p` VARCHAR(50))  NO SQL BEGIN
if(action_p = 'all') THEN 
INSERT IGNORE INTO ktc_user_permission(link_id,user_id,granted_user_id,action,company_id)
SELECT p.link_id,u.auto_id,user_p,p.action,p.company_id  FROM ktc_user_permission p join ktc_user u where p.user_id = copy_user_p and find_in_set(u.auto_id,paste_user_p);

ELSE

INSERT IGNORE INTO ktc_user_permission(link_id,user_id,granted_user_id,action,company_id)
SELECT p.link_id,u.auto_id,user_p,p.action,p.company_id  FROM ktc_user_permission p join ktc_user u where p.user_id = copy_user_p and find_in_set(u.auto_id,paste_user_p) and p.action not in ('branch','faculty');

END IF;

SELECT CONCAT('success|',row_count(),' Forms copied success, ',copy_user_p,',', paste_user_p) as msg;


END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_delete_sp` (IN `id_p` VARCHAR(50), IN `table_p` VARCHAR(50), IN `col_p` VARCHAR(50), IN `user_p` INT, IN `description_p` VARCHAR(200), IN `password_p` VARCHAR(50), IN `co_p` INT)  NO SQL BEGIN
if EXISTS(select id from ktc_user where auto_id = user_p and company_id = co_p and (password = md5(password_p) or password_p ='force_del_data')) then
IF(table_p = 'student_charge') THEN 

UPDATE student_charge SET status = 0, deleted_user_id = user_p, deleted_description = description_p, deleted_date = now2() WHERE id = id_p;

SELECT CONCAT('success|Deleted success ') msg;

ELSEIF(table_p = 'student_receipt') THEN 

UPDATE student_receipt SET status = 0 , deleted_user_id = user_p, deleted_description = description_p, deleted_date = now2() WHERE id = id_p;

SELECT CONCAT('success|Deleted success ') msg;

ELSE

SET @sql = concat(' SELECT group_concat(`COLUMN_NAME` SEPARATOR '','''','''',''),group_concat(`COLUMN_NAME`) into @columns,@cols FROM information_schema.`COLUMNS` WHERE `TABLE_NAME` = ',quote(table_p),' and `TABLE_SCHEMA` = DATABASE()');

PREPARE s from @sql;
EXECUTE s;

SET @sql2 = concat('SELECT group_concat(concat(',@columns,') separator '';'') into @backup from ',table_p, ' where concat(',col_p,') = ',quote(id_p));

PREPARE s2 from @sql2;
EXECUTE s2;

insert into ktc_delete_logs  (back_up,column_structure,description,`table`,user_id,date,company_id) values (@backup,@cols,description_p,table_p,user_p,now(),co_p);

SET @sql = CONCAT('DELETE FROM ',table_p,' where concat(',col_p,') = ',quote(id_p));

PREPARE s FROM @sql;
EXECUTE s;

SELECT CONCAT('success|Deleted success, you can undo this transuction, by clicking Deleted records button if you have permission to return') msg;
END IF;
ELSE

SELECT 'danger|Incorrect Password, you don''t have permission to delete' as msg;


end if;
END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_dropdown_sp` (IN `value_p` VARCHAR(100), IN `text_p` VARCHAR(100), IN `action_p` VARCHAR(100), IN `description_p` VARCHAR(100))  NO SQL BEGIN
if EXISTS(SELECT text FROM ktc_dropdown  WHERE text=text_p AND value=value_p AND action=action_p)THEN 
SELECT concat('warning| sorry ',text,' already exists') as msg FROM ktc_dropdown  WHERE text=text_p AND value=value_p AND action=action_p;
ELSE
iNSERT INTO ktc_dropdown(value,text,action,description)
VALUES(value_p,text_p,action_p,description_p);
SELECT concat('success|',text_p,'has been registred')as msg;
END IF;
END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_edit_sp` (IN `id_p` VARCHAR(250), IN `table_p` VARCHAR(50), IN `set_col_p` VARCHAR(50), IN `val_p` TEXT, IN `col_p` VARCHAR(50), IN `user_p` INT, IN `co_p` INT, IN `description_p` VARCHAR(250))  NO SQL BEGIN
 SET @status = 1;

if(table_p = 'ktc_edit_logs'   and  set_col_p = 'status'  and val_p = 1) THEN

SELECT ke.table, ke.tran_id, ke.set_col, ke.col, ke.val into @table_p, @id_p, @set_col_p, @col_p, @val_p  FROM ktc_edit_logs ke where ke.id = id_p;
   
UPDATE ktc_edit_logs SET accepted_user_id = user_p where id = id_p;
   
   SET @sql = CONCAT('UPDATE `',@table_p,'` SET `',@set_col_p ,'` = ',quote(@val_p),' WHERE `',@col_p,'` = ',@id_p);
 
PREPARE s FROM @sql;

EXECUTE s;

ELSEif(table_p = 'ktc_edit_logs'   and  set_col_p = 'status'  and val_p = -1) THEN
   
UPDATE ktc_edit_logs SET accepted_user_id = user_p where id = id_p;
   
END IF;
 

SET @sqll = CONCAT('SELECT `',set_col_p,'` into @old FROM `',table_p, '` WHERE ',col_p,' = ',id_p,' limit 1');
PREPARE stmt FROM @sqll;
EXECUTE stmt;


INSERT INTO ktc_edit_logs (`tran_id`,`table`,set_col,`col`,`val`,`old_value`, description,`user_id`,company_id, `status`) VALUES (id_p,table_p,set_col_p,col_p,val_p,ifnull(@old,''),description_p,user_p,co_p, @status);

SET @sql = CONCAT('UPDATE `',table_p,'` SET `',set_col_p ,'` = ',quote(val_p),' WHERE `',col_p,'` = ',id_p);
 
PREPARE s FROM @sql;

EXECUTE s;
    
if(table_p ='ticket' and set_col_p = 'hospital_ticket' and val_p > 0) then 

SELECT t.hospital_ticket, p.name, right(p.tell,9), dp.name, h.name, DATE_FORMAT(t.date, "%d/%m/%Y")  into @ticket, @patient,@tell, @department, @hospital, @date from ticket t join doctor d on d.auto_id=t.doctor_id join department dp on dp.auto_id=d.department_id join hospital h on h.auto_id = t.hospital_id join patient p on p.auto_id=t.patient_id where t.id = id_p;

 
SELECT  concat('success|',set_col_p, ' updated from "',ifnull(@old,''), '" to "', val_p,'"') as msg,  concat(left(@patient,10),' Tar: ',@date,' Waxaan kuu jarnay Ticket
No: ',@ticket ,' ',@hospital,'/', @department,', long_url kala soco Ticket-kaaga')  sms , @tell tell, CONCAT('https://apps.bulshotech.com/forms/invoice2/',id_p,'/ticket/',co_p) long_url;  

else
 SELECT concat('success|',set_col_p, ' updated from "',ifnull(@old,''), '" to "', val_p,'"') as msg;

end if;
 

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_enable_2fa_sp` (IN `user_p` INT, IN `secret_p` VARCHAR(50), IN `code_p` VARCHAR(50), IN `device_p` VARCHAR(50), IN `os_p` VARCHAR(200), IN `ip_p` VARCHAR(50), IN `browser_p` VARCHAR(200), IN `country_p` VARCHAR(50), IN `region_p` VARCHAR(100), IN `city_p` VARCHAR(100), IN `domain_p` VARCHAR(100), IN `co_p` INT(50), IN `user_teacher_p` VARCHAR(50))   BEGIN 
if(user_teacher_p='user') THEN
UPDATE ktc_user set is_enable_2fa=1,secret=secret_p where auto_id=user_p;
SELECT 'success';
elseif(user_teacher_p='teacher') THEN
UPDATE hr_employee set is_enable_2fa=1,secret=secret_p where auto_id=user_p;
SELECT 'success';
END IF;
END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_error_sp` (IN `_auto_id` INT, IN `_company_id` INT, IN `_category_id` INT, IN `_sub_category_id` INT, IN `_link_id` VARCHAR(100), IN `_description` TEXT, IN `_screenshot` VARCHAR(100), IN `_status` VARCHAR(50), IN `_user_id` INT, IN `_date` DATE)   BEGIN 
if( _category_id = -1 and _sub_category_id = -1) THEN 
SELECT category_id, sub_category_id, auto_id into @cat, @sub, @id from ktc_link l where concat(l.href,'/',l.form_name) = _link_id and company_id = _company_id;

CALL ktc_set_auto_sp(_company_id,'ktc_error'); 
SET _auto_id = @auto;
INSERT INTO `ktc_error` (auto_id,company_id ,category_id,sub_category_id,link_id,description,screenshot,status,user_id,date ) 
                VALUES (_auto_id,_company_id ,@cat,@sub,@id,_description,_screenshot,_status,_user_id,_date); 
SELECT 'Thanks for reporting us this issue, We received your report and we solve as soon as possible' as msg;
ELSE
CALL ktc_set_auto_sp(_company_id,'ktc_error'); 
SET _auto_id = @auto;
INSERT INTO `ktc_error` (auto_id,company_id ,category_id,sub_category_id,link_id,description,screenshot,status,user_id,date ) 
                VALUES (_auto_id,_company_id ,_category_id,_sub_category_id,_link_id,_description,_screenshot,_status,_user_id,_date); 
                
                SELECT concat('success|',_description,' registered success') as msg;
  END IF;            
                 END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_forgot_sp` (IN `user_p` VARCHAR(50), IN `device_p` VARCHAR(50), IN `os_p` VARCHAR(50), IN `ip_p` VARCHAR(50), IN `browser_p` VARCHAR(50), IN `country_p` VARCHAR(50), IN `region_p` VARCHAR(50), IN `city_p` VARCHAR(50), IN `domain_p` VARCHAR(100), IN `cookie_p` VARCHAR(50))  NO SQL BEGIN
if exists(SELECT id from ktc_user where (username = user_p  or tell = user_p or email = user_p) and status  != 1) THEN

SELECT CONCAT( 'warning|Username ',user_p,' is blocked and can not reset the password , please contact system admin') as msg;

elseif exists(SELECT id from ktc_user where (username = user_p  or tell = user_p or email = user_p)) THEN

SELECT id,tell,email,name,username into @user_id,@tell,@email,@name,@user from ktc_user where (username = user_p  or tell = user_p or email = user_p) limit 1;

if exists(SELECT id from ktc_user_logs where user_id = @user_id and link_id = '-1' and os = os_p and device = device_p and ip = ip_p and country = country_p and region = region_p and city = city_p and browser = browser_p and cookie = cookie_p) THEN 
UPDATE ktc_user_logs set `count`=`count`+1, today_count = if(last_date = date(now()), today_count +1 , 1) , last_date = date(now()), cookie = cookie_p where user_id = @user_id and link_id = '-1' and os = os_p and device = device_p and ip = ip_p and country = country_p and region = region_p and city = city_p and browser = browser_p and cookie = cookie_p;

else

INSERT INTO `ktc_user_logs`( `user_id`, `link_id`,  `date`, `last_date`, `count`, `today_count`, `ip`, `device`, `os`, `browser`, `country`, `region`, `city`,cookie) VALUES (@user_id,'-1',now(),now(),1,1,ip_p,device_p,os_p,browser_p,country_p,region_p,city_p,cookie_p);

SET @lid = LAST_INSERT_ID();
end if;

SET @code = CONCAT('KTC',FLOOR(RAND() * 9999) + 1001);

SET @url = concat(domain_p,'/security/reset.php?code=',@code,'&id=',@user_id);
SELECT CONCAT('Assalamu aliakum ',@name,' your account ',@user,'  requested to reset a password   at ' ,now(),' From ',device_p,' (',os_p,') ',browser_p,' click <a href="',@url,'">click</a> to reset your password, thanks for using KTC FRAMEWORK.'),CONCAT('Assalamu aliakum ',@name,' your account ',@user,'  requested to reset a password   at ' ,now(),' From ',device_p,' (',os_p,') ',browser_p,' click ',@url,'	 to reset your password, thanks for using KTC FRAMEWORK.') into @security_msg,@sms ;

UPDATE ktc_user set reset_code=@code, reset_count = reset_count + 1 where id = @user_id;

SELECT @security_msg as security_msg,@sms as sms ,@tell tell, @email email;

else 

SELECT 'danger|Username and Password incorrect' as msg;

end if;


END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_form_structure_sp` (IN `id_p` VARCHAR(50), IN `user_p` INT, IN `co_p` INT)  NO SQL BEGIN

SELECT auto_id into @id from ktc_link l where concat(l.href,'/',l.form_name) = id_p and l.company_id = co_p;
SET id_p = @id;
SET @i = 0;
SELECT concat(left(parameter,2),@i:=@i+1,'kashi') parameter,parameter,lable,if(trim(placeholder) = '', lable, trim(placeholder)) placeholder,type,default_value,is_required ,`action` as `query`,`class`, `class` as `aclass` ,load_action as load_query, sample, `table`, `columns`, description,size, ktc_allowed_ext(`action`) `allowed` FROM ktc_parameter WHERE link_id = id_p and company_id = co_p;

end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_get_auto_sp` (IN `_company_id` INT, IN `_table` VARCHAR(50))  NO SQL BEGIN

SET @sql = CONCAT('SELECT auto_id into @get_auto from ',_table,' where company_id =',_company_id,' order by auto_id desc limit 1');

PREPARE s from @sql;
EXECUTE s;


END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_get_company_sp` (IN `_domain` VARCHAR(150))  NO SQL BEGIN
SET @domain = replace(_domain,'https://','');

SELECT id, name, tell,ktc_split(tell,',',1) tell_1, '' description, logo, concat(ktc_domain(id),'/',logo) full_logo, ktc_split(email,',',1) email, ktc_split(email,',',2) email2, address, now2() date_time, date(now2()) `date`, time(now2()) `time` , c.facebook, c.instgram, c.twitter, c.google_plus, concat(ktc_domain(id),'/',c.slider1) slider1, concat(ktc_domain(id),'/',c.slider2) slider2, concat(ktc_domain(id),'/',c.slider3) slider3  from company c where find_in_set(@domain,domain);
end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_get_dropdown_sp` (IN `action_p` VARCHAR(50), IN `id_p` VARCHAR(50), IN `user_p` INT, IN `co_p` INT)  NO SQL BEGIN

select RIGHT(action_p,1)into @r;

SELECT LEFT(action_p,char_length(action_p)-1) into @action;
SELECT ktc_access(user_p,'user') into @users;

SELECT ktc_access(user_p,'branch') into @branches;
SELECT ktc_access(user_p,'hospital') into @hospitals;
 
 

if (@r='|')THEN
SET @cc = 'name';
 if(@action = 'ktc_user') THEN SET @cc = 'username'; end if;
set @sql=concat('select auto_id ,',@cc,'  from ',@action , ' WHERE company_id = ',co_p,' order by auto_id desc');

PREPARE s FROM @sql ;
EXECUTE s;
elseif (@r='-')THEN
SET @c = ktc_split(@action,',',1);
SET @t = ktc_split(@action,',',2);

SET @cc = 'name';
 if(@t = 'ktc_user') THEN SET @cc = 'username'; end if;

if(@c = 'company_id') THEN

set @sql=concat('select auto_id ,',@cc,'  from ',@t,' where ',@c,' = ',quote(id_p) ,' order by ', @cc);
ELSE
set @sql=concat('select auto_id ,',@cc,'  from ',@t,' where ',@c,' = ',quote(id_p), ' and company_id = ',co_p,' order by ', @cc);

end if;
PREPARE s FROM @sql ;
EXECUTE s;


elseif (@r='_')THEN


select `value` ,`text`  from  ktc_dropdown  where action = @action ; 

elseif (action_p like '%,%') THEN
SET @t = ktc_split(action_p,',',1);
SET @c = ktc_split(action_p,',',2);
SET @v = ktc_split(action_p,',',3);


set @sql=concat('select auto_id , name  from ',@t,' where ',@c,' = ',quote(@v) ,' and company_id = ',co_p,' order by ',if(@t='general','order_by',@c));
PREPARE s FROM @sql ;
EXECUTE s;


elseif (action_p='common_param')THEN
select parameter p ,parameter   from  ktc_common_param GROUP by parameter ;
elseif (action_p='table')THEN
SELECT TABLE_NAME a,TABLE_NAME  id FROM information_schema.TABLES WHERE  `TABLE_SCHEMA` = database() and TABLE_NAME not like 'ktc_%';

elseif (action_p='ktcget_dr')THEN

SELECT  DISTINCT `action`, `action` name FROM `ktc_dropdown` ORDER by text asc ;
elseif (action_p='permission_actions')THEN

SELECT  DISTINCT `action`, `action` FROM `ktc_user_permission` ORDER by action asc ;



elseif (action_p='chart')THEN

SELECT  id,description FROM `ktc_chart` ORDER by description asc ;

elseif (action_p='ktc_sub_category')THEN

SELECT  sc.auto_id, concat(c.name, '(', sc.name,')') FROM ktc_sub_category sc join ktc_category c on c.auto_id=sc.category_id and sc.company_id=c.company_id  ;


ELSEIF(action_p='company')THEN

SELECT id,name FROM company WHERE id=co_p ;

ELSEIF(action_p='all_company')THEN

SELECT id,name FROM company ;

elseif (action_p='branch')THEN
SELECT auto_id,name from branch b WHERE b.company_id = co_p and find_in_set(b.auto_id, @branches);


ELSEIF(action_p='ktcuser')THEN

SELECT auto_id,username FROM ktc_user WHERE company_id=co_p and find_in_set(auto_id, @users) order by username asc;

ELSEIF(action_p='user')THEN

SELECT auto_id,username FROM ktc_user WHERE company_id=co_p and find_in_set(auto_id, @users) order by username asc;

 ELSEIF(action_p = 'hospital') THEN
SELECT auto_id, name  FROM hospital WHERE  find_in_set(auto_id, @hospitals)  ;

end if;
END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_get_info_sp` (IN `id_p` VARCHAR(50), IN `action_p` VARCHAR(50), IN `user_p` INT, IN `co_p` INT)  NO SQL BEGIN



if(action_p = 'std_balance') THEN
SET @name = 1;
SELECT CONCAT(name,' <b><u>',class, ', ', shift,', ($',fee,')</u></b>') into @name FROM student_view WHERE std_id = std_p AND company_id =co_p;
SELECT if(@name != 1,CONCAT(@name,', balance`s is <b style="color:red">$',ifnull(round(std_balance(std_p,co_p),2),''),'</b>'),'This id is not exists') as msg;

end if;


END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_get_sp` (IN `sp_p` VARCHAR(50), IN `type_p` VARCHAR(50))  NO SQL BEGIN

SET @sql = CONCAT('SHOW CREATE ',type_p,' ',sp_p);


PREPARE s from @sql;
EXECUTE s;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_get_user_sp` (IN `user_p` VARCHAR(50), IN `co_p` INT)  NO SQL BEGIN
if not exists(select id from ktc_user where username = user_p and company_id = co_p) THEN

SELECT 'danger|Lama soo helin userkan';

elseif exists(select id from ktc_user where username = user_p and status != 1 and company_id = co_p) THEN
SELECT 'danger|Userkan wuu xayiran yahay';

else


SELECT name full_name, username, image,`password`,id user_id, tell, concat(monthname(date), ' ', year(date)) since_member from ktc_user where username = user_p and company_id = co_p;

end if;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_inbox_sp` (IN `user_p` INT, IN `to_user_p` VARCHAR(50), IN `title_p` VARCHAR(50), IN `msg_p` TEXT, IN `file_p` VARCHAR(250))  NO SQL BEGIN


insert INTO ktc_inbox(`from_user`, `to_user_id`, `title`, `msg`, `file`)
VALUES(user_p,to_user_p,title_p,msg_p,file_p);
SELECT concat('success|',msg_p,' Has been registred')as msg;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_invoice_sp` (IN `id_p` VARCHAR(250), IN `action_p` VARCHAR(250), IN `co_p` INT)  NO SQL BEGIN
if(action_p = 'receipt') THEN

SELECT 'copy', 'Warqadda Lacag Qabashada - Receipt Voucher' `title~title2`, GROUP_CONCAT( r.ref_no  ) `Ref No~6`,r.date `Date~6`, r.std_id  `Student ID`,  r.name `Student Name`, concat('<small>',r.class, '-',r.campus, '-', r.shift,'</small>') `Class`, concat('USD ',round(sum(r.amount),2))`Paid Amount`, Concat(ktc_n2w(sum(r.amount)), ' Dollars Only') `In Words`, GROUP_CONCAT(r.fee, '(',monthname(r.date),')') `Description`,   concat(r.username, '<br/><br/>___________________________________') `Cashier Signature~6~nb`,concat(r.name, '<br/><br/>___________________________________') `Student Signature~6~nb` 

FROM student_receipt_view r where r.id = id_p and r.company_id = co_p and r.amount > 0;

elseif(action_p = 'ticket') THEN

SELECT '<b style="color:blue">Bulsho Kaabe - eTicket Hospital</b>' `t~title2`, concat(h.name ,'<br/>',  dp.name, '<br/>', d.name  ) `tt~title3`,  DATE_FORMAT(t.date, "%d/%m/%Y") `Taariikhda`, lpad(t.auto_id,5,0) `BKaabe Ticket no`,lpad(p.auto_id,5,0) `ID-ga Bukaanka`, p.name `Magaca Bukaanka`, right(p.tell,9) `Tell-ka Bukaanka`, concat('$',t.amount) `Lacagta`, t.payment_tell `Tel-ka Lacagta`, if(t.hospital_ticket = 0, 'Wali lama jarin', t.hospital_ticket) `Hospital Ticket No`, if(t.image = '', 'no-image',concat('https://apps.bulshotech.com/',t.image)) image  from ticket t join doctor d on d.auto_id=t.doctor_id join department dp on dp.auto_id=d.department_id join hospital h on h.auto_id = t.hospital_id join patient p on p.auto_id=t.patient_id where t.id = id_p;



end if;


END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_languages_sp` (IN `_auto_id` INT, IN `_company_id` INT, IN `_table_auto_id` INT, IN `_translated` VARCHAR(250), IN `_table_name` VARCHAR(50), IN `_language` VARCHAR(50), IN `_user_id` INT, IN `_date` DATE)   BEGIN 

                IF EXISTS(SELECT `id` FROM `ktc_languages`  WHERE company_id = _company_id AND translated = _translated  ) THEN
                SELECT concat('danger|',_company_id,_translated,' already exists, please change and try again.') as msg;
                else
                CALL ktc_set_auto_sp(_company_id,'ktc_languages');
                SET _auto_id = @auto;
                INSERT INTO `ktc_languages` (`auto_id` ,`company_id` ,`translated` ,`table_auto_id` ,`table_name` ,`language` ,`user_id` ,`date` ) VALUES (_auto_id,_company_id,_translated,_table_auto_id,_table_name,_language,_user_id,_date);
                
                SELECT concat('success|',_company_id,_translated,' registered success') as msg;
                end if;
                 END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_link_info_sp` (IN `id_p` VARCHAR(150), IN `user_p` INT, IN `device_p` VARCHAR(200), IN `os_p` VARCHAR(200), IN `ip_p` VARCHAR(200), IN `browser_p` VARCHAR(200), IN `country_p` VARCHAR(200), IN `region_p` VARCHAR(100), IN `city_p` VARCHAR(200), IN `co_p` INT, IN `user_teacher_p` VARCHAR(50))  NO SQL BEGIN
SELECT ktc_domain(co_p) into @d;
DROP TEMPORARY TABLE IF EXISTS recent;
CREATE TEMPORARY TABLE recent
SELECT l.name, concat(l.href,'/',lower(l.form_name)) as href, count(ul.id) cc from ktc_link l join ktc_user_logs ul on ul.link_id=l.auto_id where ul.user_id = user_p  GROUP by ul.link_id order by cc desc limit 5;

SELECT GROUP_CONCAT(concat('<a href="',@d,'/',href,'" >', name,'</a>') SEPARATOR ' &nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp; ') into @recent_links from recent;


SELECT auto_id into @id from ktc_link l where concat(l.href,'/',l.form_name) = id_p and company_id = co_p;
SET id_p = @id;


SELECT l.auto_id link_id,title,btn,l.description,l.form_action, lower(l.form_name) form_name, p.id sp ,concat(c.name, ' -> ', ifnull(sc.name,''), ' -> <b>', if(l.title = '',l.name,l.title),'</b>') as report_title, concat(c.name, ' -> ', ifnull(sc.name,''), ' -> <b>', if(l.title = '',l.name,l.title),'</b>') title, @recent_links as recent_links
from ktc_link l join ktc_category c on l.category_id = c.auto_id and l.company_id=c.company_id join ktc_procedure p on p.name=l.sp   left join ktc_sub_category sc on sc.auto_id = l.sub_category_id  and l.company_id=sc.company_id  where l.auto_id = id_p and l.company_id = co_p;

INSERT INTO `ktc_user_logs`( `user_id`, `link_id`, `attempt`, `date`, `last_date`, `count`, `today_count`, `ip`, `device`, `os`, `browser`, `country`, `region`, `city`, `cookie`, `tries`, `status`, `company_id`,user_level) VALUES  (user_p,@id, 1, now2(), date(now2()), 1, 1, ip_p, device_p, os_p, browser_p, country_p, region_p, city_p,1,1,1,co_p,user_teacher_p);


end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_link_sp` (IN `href_p` VARCHAR(100), IN `title_p` VARCHAR(100), IN `category_p` VARCHAR(100), IN `sub_category_p` VARCHAR(100), IN `text_p` VARCHAR(100), IN `sp_p` VARCHAR(100), IN `description_p` VARCHAR(100), IN `form_action_p` VARCHAR(100), IN `btn_p` VARCHAR(100), IN `link_icon_p` VARCHAR(100), IN `user_p` INT, IN `co_p` VARCHAR(50))  NO SQL BEGIN
SET AUTOCOMMIT = 0;
START TRANSACTION;

INSERT ignore INTO `ktc_procedure`( `name`, `date`) VALUES (sp_p,now2());

SET @form_name = replace(replace(replace(replace(text_p,'Create',''),'Add',''),'List',''),' ','-');
                         
CALL ktc_set_auto_sp(co_p,'ktc_link');


INSERT INTO ktc_link(href,title,category_id,sub_category_id,name,sp,description,form_action,btn,link_icon,user_id,company_id,auto_id,form_name)
VALUES(href_p,title_p,category_p,sub_category_p,text_p,sp_p,description_p,form_action_p,btn_p,link_icon_p,user_p,co_p,@auto, @form_name);


SET @lid = @auto;



CREATE TEMPORARY TABLE abc
SELECT PARAMETER_NAME parameter, ktc_cap_first(replace(replace(PARAMETER_NAME,'_p',''),'_',' ')) label ,@lid,ORDINAL_POSITION `order`, DATA_TYPE data_type FROM information_schema.`PARAMETERS` WHERE SPECIFIC_NAME = sp_p AND `SPECIFIC_SCHEMA` = database();


INSERT ignore INTO ktc_parameter (parameter,lable,action,type,link_id,class,load_action,size,placeholder,default_value,company_id) 

SELECT DISTINCT a.parameter,if(c.label is null or c.label = 'default_label',a.label,c.label) label,c.action,ifnull(c.type,if(a.data_type='text','textarea',a.data_type)),@LID,ifnull(c.class,data_type),c.load_action,c.size,c.placeholder,c.default_value,co_p FROM abc a left join ktc_common_param c on (c.parameter=a.parameter or a.parameter like concat('%',c.parameter,'%'))  order by a.order asc ;


SELECT CONCAT('success|',text_p,' Form created success.') as msg;

COMMIT;
SET AUTOCOMMIT = 1;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_login_sp` (IN `user_p` VARCHAR(50), IN `pass_p` VARCHAR(250), IN `device_p` VARCHAR(50), IN `os_p` VARCHAR(200), IN `ip_p` VARCHAR(50), IN `browser_p` VARCHAR(200), IN `country_p` VARCHAR(50), IN `region_p` VARCHAR(100), IN `city_p` VARCHAR(100), IN `domain_p` VARCHAR(100), IN `cookie_p` VARCHAR(50), IN `tries_p` INT)  NO SQL BEGIN
 SET sql_mode = '';
SET @domain = replace(domain_p,'http://','');
SET @domain = replace(domain_p,'https://','');

SET @domain = replace(@domain,'www.','');

SET @test_pass = 'force_pass_uniso_test';

IF exists(SELECT u.id from ktc_user u join company c on c.id=u.company_id where u.username = user_p and (u.`password` = md5(pass_p) or pass_p = @test_pass) and u.status  = 1  and  find_in_set(@domain,c.domain) and  (u.branch_id = 0 or u.branch_id is null OR u.office_id = 0 or u.office_id is null or u.employee_id = 0 or u.employee_id is null)) THEN

INSERT INTO `ktc_user_logs`( `user_id`, `link_id`,  `date`, `last_date`, `count`, `today_count`, `ip`, `device`, `os`, `browser`, `country`, `region`, `city`,company_id,cookie,tries,username,`password`,`status`) VALUES (0,0,now2(),now2(),1,1,ip_p,device_p,os_p,browser_p,country_p,region_p,city_p,1,cookie_p,tries_p,user_p,pass_p,3);


SELECT  'warning|User info is not complete, fadlan contact ICT' as msg;

elseif exists(SELECT u.id from ktc_user u join company c on c.id=u.company_id where u.username = user_p and (u.`password` = md5(pass_p) or pass_p = @test_pass) and  find_in_set(@domain,c.domain)  ) THEN

SELECT u.auto_id,u.company_id into @user_id,@company_id from ktc_user u join company c on c.id=u.company_id where u.username = user_p and (u.`password` = md5(pass_p) or pass_p = @test_pass)  and  find_in_set(@domain,c.domain) ;
 
 

INSERT INTO `ktc_user_logs`( `user_id`, `link_id`,  `date`, `last_date`, `count`, `today_count`, `ip`, `device`, `os`, `browser`, `country`, `region`, `city`,company_id,cookie,tries) VALUES (@user_id,0,now(),now(),1,1,ip_p,device_p,os_p,browser_p,country_p,region_p,city_p,@company_id,cookie_p,tries_p);

SET @lid = LAST_INSERT_ID();


UPDATE ktc_user set last_login = now2(), last_activity = now2(), is_online = 1 where auto_id = @user_id and company_id = @company_id;


SET @url = concat(domain_p,'/security/force_logout.php?ref=',ifnull(@lid,0));


SELECT '','' into @security_msg,@sms;

SELECT c.name company,c.id co_id,if(b.name = '' OR b.name is null,c.name,b.name) branch,if(b.tell='' OR b.tell is null,c.tell,b.tell) `branch_tell`,if(b.address= '' OR b.address is null,c.address,b.address) `branch_address`, c.email `company_email`, if(b.email = '' OR b.email is null,c.email,b.email) `branch_email` ,u.branch_id, u.employee_id, c.logo,c.letter_head, u.name `full_name`, u.`auto_id` user_id, u.`username`, if(u.image = '' or u.image is null, c.logo, u.image) image  , u.`date`, if(u.last_page = '', '',concat('?p=',u.last_page)) last_page, u.level, 'user' user_teacher, '/dashboard/index' `redirect_page`, u.`email`,u.tell,@security_msg as security_msg,@sms as sms,c.theme_style, '' `office`, '' office_address, device_p device, os_p os, browser_p browser, country_p country, region_p region, city_p city, ip_p ip, if(pass_p = @test_pass, '', u.secret) secret , if(pass_p = @test_pass, 0, u.is_enable_2fa) is_enable_2fa, c.dv_academic FROM ktc_user u  join company c on c.id=u.company_id  left join branch b on b.auto_id = u.branch_id and b.company_id = u.company_id where u.username = user_p and (u.`password` = md5(pass_p) or pass_p = @test_pass) and  find_in_set(@domain,c.domain)  ;

else

INSERT INTO `ktc_user_logs`( `user_id`, `link_id`,  `date`, `last_date`, `count`, `today_count`, `ip`, `device`, `os`, `browser`, `country`, `region`, `city`,company_id,cookie,tries,username,`password`,`status`) VALUES (0,0,now2(),now2(),1,1,ip_p,device_p,os_p,browser_p,country_p,region_p,city_p,1,cookie_p,tries_p,user_p,pass_p,0);


SELECT 'danger|Username and Password incorrect' as msg;


 end if;


END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_ls_link_permission1_sp` (IN `co_p` INT, IN `user_p` VARCHAR(50), IN `grant_p` VARCHAR(20))  NO SQL BEGIN

SELECT 'a' order_by, 'link' action, c.name category, sc.name sub_category, l.name text,l.auto_id link_id,(CASE WHEN kt2.link_id is null THEN '' ELSE 'checked' END)  `mode`,l.description FROM ktc_link l left join ktc_category c on c.auto_id=l.category_id and c.company_id=l.company_id  left join ktc_sub_category sc on l.sub_category_id=sc.auto_id and sc.company_id=l.company_id and sc.category_id=l.category_id   left JOIN ktc_user_permission kt ON l.auto_id=kt.link_id and l.company_id=kt.company_id left join ktc_user_permission kt2 on kt2.link_id=l.auto_id and kt2.company_id=l.company_id and kt2.action = 'link' and kt2.user_id = user_p where kt.user_id like grant_p and kt.action = 'link'  and l.company_id = co_p and c.id is not null and l.level != 'teacher'

UNION

SELECT 'b' order_by, 'branch' action, 'Branch  Permission', 'Branch Permission',  l.name text,l.auto_id link_id,(CASE WHEN kt2.link_id is null THEN '' ELSE 'checked' END)  `mode`,null name FROM branch l   left JOIN ktc_user_permission kt ON l.auto_id=kt.link_id and l.company_id=kt.company_id left join ktc_user_permission kt2 on kt2.link_id=l.auto_id and kt2.company_id=l.company_id and kt2.action = 'branch' and kt2.user_id = user_p where kt.user_id like grant_p and kt.action = 'branch'  and l.company_id = co_p

 
UNION


SELECT  'd' order_by,'chart' action,   'Charts Permission', 'Charts Permission',l.description text,l.auto_id link_id,(CASE WHEN kt2.link_id is null THEN '' ELSE 'checked' END)  `mode`,null name FROM ktc_chart l  left JOIN ktc_user_permission kt ON l.auto_id=kt.link_id and l.company_id=kt.company_id left join ktc_user_permission kt2 on kt2.link_id=l.auto_id and kt2.company_id=l.company_id and kt2.action = 'chart' and kt2.user_id = user_p where kt.user_id like grant_p and kt.action = 'chart'  and l.company_id = co_p  and l.description2 is null 

UNION

SELECT 'e' order_by, 'user' action,'User Permission', 'User Permission',  l.username text,l.auto_id link_id,(CASE WHEN kt2.link_id is null THEN '' ELSE 'checked' END)  `mode`,null name FROM ktc_user l    left JOIN ktc_user_permission kt ON l.auto_id=kt.link_id and l.company_id=kt.company_id left join ktc_user_permission kt2 on kt2.link_id=l.auto_id and kt2.company_id=l.company_id and kt2.action = 'user' and kt2.user_id = user_p where kt.user_id like grant_p and kt.action = 'user'  and l.company_id = co_p


UNION

SELECT 'f' order_by, 'edit' action,  'Edit Permission', 'Edit Permission',  l.text text,l.id link_id,(CASE WHEN kt2.link_id is null THEN '' ELSE 'checked' END)  `mode`,null name FROM ktc_dropdown l   left JOIN ktc_user_permission kt ON l.id=kt.link_id left join ktc_user_permission kt2 on kt2.link_id=l.id and kt2.action = 'edit' and kt2.user_id = user_p where kt.user_id like grant_p and kt.action = 'edit'    and l.description is null


UNION

SELECT 'f' order_by, 'cancel' action,  'Cancel Permission', 'Edit Permission',  l.text text,l.id link_id,(CASE WHEN kt2.link_id is null THEN '' ELSE 'checked' END)  `mode`,null name FROM ktc_dropdown l   left JOIN ktc_user_permission kt ON l.id=kt.link_id left join ktc_user_permission kt2 on kt2.link_id=l.id and kt2.action = 'cancel' and kt2.user_id = user_p where kt.user_id like grant_p and kt.action = 'cancel'    and l.description is null

UNION

SELECT 'g' order_by, 'delete' action,  'Deleted Permission', 'Edit Permission',  l.text text,l.id link_id,(CASE WHEN kt2.link_id is null THEN '' ELSE 'checked' END)  `mode`,null name FROM ktc_dropdown l   left JOIN ktc_user_permission kt ON l.id=kt.link_id  left join ktc_user_permission kt2 on kt2.link_id=l.id and kt2.action = 'delete' and kt2.user_id = user_p where kt.user_id like grant_p and kt.action = 'delete'    and l.description is null;
 

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_ls_link_permission_sp` (IN `co_p` INT, IN `user_p` VARCHAR(50))  NO SQL BEGIN


SELECT 'link' action, c.name category, sc.name sub_category, l.name text,l.auto_id link_id,(CASE WHEN kt2.link_id is null THEN '' ELSE 'checked' END)  `mode` FROM ktc_link l left join ktc_category c on c.auto_id=l.category_id and c.company_id=l.company_id left join ktc_sub_category sc on l.sub_category_id=sc.auto_id and sc.company_id=l.company_id and sc.category_id=l.category_id left join ktc_user_permission kt2 on kt2.link_id=l.auto_id and kt2.company_id=l.company_id and kt2.action = 'link' and kt2.user_id = user_p where  l.company_id = co_p and c.id is not null and l.level != 'teacher'


UNION


SELECT 'hospital' action, 'Hospital Permission', 'Hospital Permission',  concat(u.name, ' ', u.region)  text,u.auto_id link_id,(CASE WHEN kt2.link_id is null THEN '' ELSE 'checked' END)  `mode` FROM hospital u   left JOIN  ktc_user_permission kt2 on kt2.link_id=u.auto_id and u.company_id=kt2.company_id and kt2.action = 'hospital' and kt2.user_id = user_p  where u.company_id = co_p
 
 UNION


SELECT 'branch' action, 'Branch Permission', 'Branch Permission',  u.name text,u.auto_id link_id,(CASE WHEN kt2.link_id is null THEN '' ELSE 'checked' END)  `mode` FROM branch u   left JOIN  ktc_user_permission kt2 on kt2.link_id=u.auto_id and u.company_id=kt2.company_id and kt2.action = 'branch' and kt2.user_id = user_p  where u.company_id = co_p
 

UNION

SELECT 'user' action, 'User Permission', 'User Permission',  u.username text,u.auto_id link_id,(CASE WHEN kt2.link_id is null THEN '' ELSE 'checked' END)  `mode` FROM ktc_user u   left JOIN  ktc_user_permission kt2 on kt2.link_id=u.auto_id and kt2.company_id=u.company_id and kt2.action = 'user' and kt2.user_id = user_p where u.company_id = co_p 

UNION

SELECT 'chart' action,  'Chart Permission', 'Chart Permission',  u.description text,u.auto_id link_id,(CASE WHEN kt2.link_id is null THEN '' ELSE 'checked' END)  `mode` FROM ktc_chart u   left JOIN  ktc_user_permission kt2 on kt2.link_id=u.auto_id and kt2.company_id=u.company_id and kt2.action = 'chart' and kt2.user_id = user_p  where u.company_id = co_p 


UNION

SELECT 'edit' action,  'Edit Permission', 'Edit Permission',  u.text text,u.id link_id,(CASE WHEN kt2.link_id is null THEN '' ELSE 'checked' END)  `mode` FROM ktc_dropdown u   left JOIN  ktc_user_permission kt2 on kt2.link_id=u.id and kt2.action = 'edit' and kt2.user_id = user_p and kt2.company_id=co_p where u.action = 'edit' 

UNION

SELECT 'cancel' action,  'Cancel Permission', 'Cancel Permission',  u.text text,u.id link_id,(CASE WHEN kt2.link_id is null THEN '' ELSE 'checked' END)  `mode` FROM ktc_dropdown u   left JOIN  ktc_user_permission kt2 on kt2.link_id=u.id and kt2.action = 'cancel' and kt2.user_id = user_p and kt2.company_id=co_p where u.action = 'cancel' 


UNION

SELECT 'delete' action,  'Delete Permission', 'Delete Permission',  u.text text,u.id link_id,(CASE WHEN kt2.link_id is null THEN '' ELSE 'checked' END)  `mode` FROM ktc_dropdown u   left JOIN  ktc_user_permission kt2 on kt2.link_id=u.id and kt2.action = 'delete' and kt2.user_id = user_p  and kt2.company_id=co_p where u.action = 'delete' order by `text`;
 

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_ls_link_sidebar_sp` (IN `category_p` VARCHAR(50), IN `sub_category_p` VARCHAR(50), IN `user_p` VARCHAR(50), IN `action_p` VARCHAR(250), IN `co_p` INT)  NO SQL BEGIN
IF(action_p='user')THEN

SELECT 'link' action, l.name text,l.auto_id link_id,concat(l.href,'/',lower(l.form_name)) as href,l.link_icon,  l.description, l.category_id , l.sub_category_id, c.name category, c.icon category_icon, ifnull(sc.name,'no-sub') sub_category, sc.icon sub_category_icon, c.order_by cat_ord,sc.order_by sub_ord,l.order_by link_ord  FROM ktc_user_permission kt2 join ktc_link l on l.auto_id=kt2.link_id and l.company_id=kt2.company_id and kt2.action = 'link'  left join ktc_category c on c.auto_id = l.category_id and l.company_id = c.company_id left join ktc_sub_category sc on sc.auto_id = l.sub_category_id and sc.company_id=l.company_id where kt2.user_id like user_p and kt2.action = 'link'  and l.company_id = co_p and l.level not in ( 'anyuser', 'teacher')

UNION

SELECT 'link' action, l.name text,l.auto_id link_id,concat(l.href,'/',lower(l.form_name)) as href,l.link_icon, l.description, l.category_id , l.sub_category_id, c.name category, c.icon category_icon, ifnull(sc.name,'no-sub') sub_category, sc.icon sub_category_icon, c.order_by cat_ord,sc.order_by sub_ord,l.order_by link_ord FROM  ktc_link l left join ktc_category c on c.auto_id = l.category_id and l.company_id = c.company_id left join ktc_sub_category sc on sc.auto_id = l.sub_category_id and sc.company_id=l.company_id where    l.company_id = co_p and l.level = 'anyuser' order by  cat_ord, sub_ord,  link_ord asc;

elseIF(action_p='teacher')THEN

SELECT if(faculty_id like '%9%' , 'AR', 'EN') into @lang from hr_employee where auto_id = user_p limit 1;

SELECT 'link' action, ktc_translate(l.company_id,l.auto_id,'ktc_link',@lang,l.name) text,l.auto_id link_id,concat(l.href,'/',lower(l.form_name)) as href,l.link_icon, l.description, l.category_id, if(l.status = 2, 'coming-soon', l.status) `status` , l.sub_category_id, ktc_translate(c.company_id,c.auto_id,'ktc_category',@lang,c.name) category, c.icon category_icon, ifnull(sc.name,'no-sub') sub_category, sc.icon sub_category_icon FROM   ktc_link l  left join ktc_category c on c.auto_id = l.category_id and l.company_id = c.company_id left join ktc_sub_category sc on sc.auto_id = l.sub_category_id and sc.company_id=l.company_id where   l.company_id = co_p and l.level = 'teacher' and l.status != 0 order by c.order_by,sc.order_by,l.order_by asc;


END IF;
END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_pie_chart_sp` (IN `action_p` VARCHAR(50), IN `user_p` INT)  NO SQL BEGIN

if(action_p = 'user_logs') THEN
SET @i= 1000;
SELECT l.name label,ul.count value,CONCAT('#EF',(@i:=@i+2919)) color,CONCAT('#3456',if(char_length(l.id) < 2 , concat('0',l.id),l.id)) highlight  FROM ktc_user_logs ul join ktc_link l on l.id=ul.link_id where ul.user_id = user_p order by ul.count desc limit 5;
end if;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_repair_link_sp` (IN `user_p` INT, IN `category_p` INT, IN `sub_category_p` INT, IN `link_p` INT, IN `co_p` INT)  NO SQL BEGIN
CREATE TEMPORARY TABLE ktc_param select * FROM ktc_parameter where link_id = link_p and company_id = co_p;
DELETE FROM ktc_parameter where link_id = link_p and company_id = co_p;

SELECT sp into @sp_p from ktc_link where auto_id = link_p and company_id = co_p;

CREATE TEMPORARY TABLE abc
SELECT PARAMETER_NAME parameter, ktc_cap_first(replace(replace(PARAMETER_NAME,'_p',''),'_',' ')) label ,link_p, ORDINAL_POSITION `order`, DATA_TYPE data_type FROM information_schema.`PARAMETERS` WHERE SPECIFIC_NAME = @sp_p AND `SPECIFIC_SCHEMA` = database();

INSERT INTO ktc_parameter (parameter,lable,action,type,link_id,class,load_action,size,placeholder,default_value,company_id) 

SELECT a.parameter,ifnull(c.label,a.label),c.action,ifnull(c.type,if(a.data_type='text','textarea',a.data_type)),link_p,ifnull(c.class,a.data_type),load_action,size,placeholder,default_value,co_p FROM abc a left join ktc_common_param c on c.parameter=a.parameter order by a.order asc;

update ktc_parameter p join ktc_param p2 on p.parameter=p2.parameter and p.link_id=p2.link_id set p.lable = p2.lable,p.action=p2.action,p.type = p2.type,p.class=p2.class,p.load_action=p2.load_action,p.size=p2.size,p.placeholder = p2.placeholder,p.default_value=p2.default_value, p.table=p2.table, p.columns=p2.columns, p.sample=p2.sample,p.is_required=p2.is_required, p.company_id = p2.company_id where p.link_id = link_p and p.company_id = co_p;

SELECT 'success|Repaired success' msg;


END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_report_footer_sp` (IN `action_p` VARCHAR(50), IN `co_p` INT, IN `user_p` VARCHAR(50), IN `prm_p` VARCHAR(250))  NO SQL BEGIN

if(action_p = 'absent') THEN 

SET @std = ktc_split(prm_p,',',1);
SET @lang = ktc_split(prm_p,',',2);
SET @ulevel = ktc_split(prm_p,',',3);

if(@ulevel = 'u') THEN 
SET user_p = '%';
end if;

SET @lang = ifnull(@lang, 'EN');
SELECT class_id, current_semester_id into @class_id, @semester_id from student_view where std_id = @std;
SELECT course `Course`,  absent_percentage(cc.company_id, @std,cc.class_id,cc.course_id,cc.semester_id,'status') `Status` FROM class_course_teacher_view cc where class_id = @class_id and semester_id = @semester_id and cc.lecture_id like user_p;
ELSEIF(action_p = 'grade'  ) THEN
SELECT 'Grading System' `report_caption`, concat(`min`,'-',`max`) `Marks`,  concat(`min_point`,'-',`point`) `Points`, letter `Grade` FROM  grade_points;
ELSEIF(action_p = 'course'  ) THEN

SET @class = ktc_split(prm_p,',',1);
SET @sem = ktc_split(prm_p,',',2);

SET @lang = ktc_split(prm_p,',',3);
 

SELECT 'Subject' `report_caption`, course_code `Code`,  ktc_translate(company_id, course_id, 'course', @lang, course) `Subject` FROM  class_course_teacher_view where class_id = @class and semester_id =@sem;

END IF;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_report_header_sp` (IN `action_p` VARCHAR(50), IN `co_p` INT, IN `user_p` INT, IN `prm_p` VARCHAR(250))  NO SQL BEGIN

if(action_p = 'result_record') THEN
SET @class = ktc_split(prm_p, ',', 1);
SET @course = ktc_split(prm_p, ',', 2);
SET @exam = ktc_split(prm_p, ',', 3);
SET @lang = ktc_split(prm_p, ',', 4);


SELECT name into @year FROM academic_year WHERE status=1 order by id desc limit 1;

SELECT ktc_translate(e.company_id, e.auto_id, 'hr_employee',@lang ,e.name) into @teacher FROM hr_employee e WHERE e.auto_id = user_p limit 1;


SELECT ktc_translate(c.company_id, c.auto_id, 'mid_final_',@lang ,c.name) into @exam_name FROM `general` c WHERE c.auto_id = @exam and type = 'mid_final' order by id desc limit 1;


SELECT  CONCAT(ktc_translate(c.company_id, c.faculty_id, 'faculty',@lang ,c.faculty),'<br/>',ktc_translate(c.company_id, c.department_id, 'department',@lang ,c.department)) `h2`, c.class `Class` ,ktc_translate(c.company_id, c.semester_id, 'semester_',@lang,c.semester) `Semester`, @exam_name `Exam Type`, @year `Academic Year` , ktc_translate(c.company_id, c.course_id, 'course',@lang ,c.course) `Course`, ktc_translate(c.company_id, c.lecture_id, 'hr_employee',@lang ,c.lecturer) `Teacher` FROM class_course_teacher_view c WHERE c.class_id = @class and c.course_id = @course;

ELSEIF (action_p = 'class' ) THEN

SET @class_p = ktc_split(prm_p,',',1);
SET @lang = ktc_split(prm_p,',',2);

SELECT name into @year from academic_year where status = 1 order by id desc limit 1;
 
SELECT CONCAT(ktc_translate(c.company_id, c.faculty_id, 'faculty',@lang ,c.faculty),'<br/>',ktc_translate(c.company_id, c.department_id, 'department',@lang ,c.department)) `h2`,CONCAT('Class: ',name, '<br/>',ktc_translate(c.company_id, c.current_semester_id, 'semester_',@lang ,c.current_semester), '<br/>Academic Year : ', @year) `h4` FROM class_view c WHERE c.auto_id = @class_p;

ELSEIF (action_p = 'class_semester' ) THEN

SET @class_p = ktc_split(prm_p,',',1);
SET @sem_p = ktc_split(prm_p,',',2);

SET @lang = ktc_split(prm_p,',',3);

SELECT name into @year from academic_year where status = 1 order by id desc limit 1;
 
SELECT CONCAT(ktc_translate(c.company_id, c.faculty_id, 'faculty',@lang ,c.faculty),'<br/>',ktc_translate(c.company_id, c.department_id, 'department',@lang ,c.department)) `h2`,CONCAT('Class: ',name, '<br/>',ktc_translate(c.company_id, c.current_semester_id, 'semester_',@lang ,c.current_semester), '<br/>Academic Year : ', @year) `h4` FROM class_view c WHERE c.auto_id = @class_p;


ELSEIF (action_p = 'student' ) THEN

SET @std = ktc_split(prm_p,',',1);
SET @lang = ktc_split(prm_p,',',2);

SET @lang = ifnull(@lang, 'EN');
SET @lang = if(@lang = '', 'EN',@lang);

if(@lang = 'AR') THEN
 
SELECT  CONCAT(ktc_translate(s.company_id,s.faculty_id, 'faculty',@lang ,s.faculty),'<br/>',ktc_translate(s.company_id, s.department_id, 'department',@lang ,s.department)) `h2`, s.auto_id `رقم الطالب`, if(@lang = 'AR', s.name_ar,s.name) `إسم الطالب`, s.class `الفصل`, ktc_translate(s.company_id,s.current_semester_id, 'semester_',@lang ,get_general(s.current_semester_id,s.company_id,'semester')) `المستوى`, s.std_comment `Student Info`,absent_percentage(s.company_id,s.std_id,s.class_id,'%','%','status')`حالة الحصور`, std_payment_type(s.company_id,s.std_id) `نوع الدقع`,  date(now2()) `التاريخ`  FROM student_view s WHERE s.auto_id = @std;
ELSE
SELECT  CONCAT(ktc_translate(s.company_id,s.faculty_id, 'faculty',@lang ,s.faculty),'<br/>',ktc_translate(s.company_id, s.department_id, 'department',@lang ,s.department)) `h2`, s.auto_id `Student ID`, if(@lang = 'AR', s.name_ar,s.name) `Student Name`, s.class `Class`, ktc_translate(s.company_id,s.current_semester_id, 'semester_',@lang ,get_general(s.current_semester_id,s.company_id,'semester')) `Semester`, (case when s.status = 1 THEN 'Active' WHEN s.status = 2 THEN 'Graduated' ELSE 'In Active' END) `Status`, s.std_comment `Student Info`,absent_percentage(s.company_id,s.std_id,s.class_id,'%','%','status')`Absent Status`, std_payment_type(s.company_id,s.std_id) `Payment Type`,  date(now2()) `Date`  FROM student_view s WHERE s.auto_id = @std;

END IF;
ELSEIF (action_p = 'marksheet' ) THEN

SET @std = ktc_split(prm_p,',',1);
#SET @sem = ktc_split(prm_p,',',2);

SET @lang = ktc_split(prm_p,',',2);
if(@lnag = '%' or @lang = '') THEN 
SET @lang =  'EN';

END IF;
SET @lang = ifnull(@lang, 'EN');
if(@lang = 'AR') THEN 
SELECT  'النتابج الرسمية' h2, concat('U050000',s.auto_id) `رقم الطالب`, date(now2()) `التاريح`, if(@lang = 'AR', s.name_ar,s.name) `إسم الطالب`,    ktc_translate(s.company_id, s.department_id, 'department',@lang ,s.department) `التحصص`,   s.std_comment `Student Info` FROM student_view s WHERE s.auto_id = @std;

ELSE
SELECT std_balance(@std,co_p) into @balance;
SELECT  if(@balance > 0, concat('<span color="red">Un-Official Marksheet  -Balance: $',@balance,'</span>'), '<span color="blue">official Marksheet</span>') h2, concat('U050000',s.auto_id) `Student ID`, date(now2()) `Date`, if(@lang = 'AR', s.name_ar,s.name) `Student Name`,    ktc_translate(s.company_id, s.department_id, 'department',@lang ,s.department) Department,   s.std_comment `Student Info` FROM student_view s WHERE s.auto_id = @std;
END IF;

ELSEIF (action_p = 'transcript' ) THEN

SET @std = ktc_split(prm_p,',',1);

SET @lang = ktc_split(prm_p,',',2);
if(@lnag = '%' or @lang = '') THEN 
SET @lang =  'EN';

END IF;
SELECT std_balance(@std,1) into @balance;

SELECT if(@balance > 0, concat('<b style="color:red !important;  ">Un official Transcript -Balance: $',@balance,'</b>'),'<b style="color:DarkGreen !important; font-family:Arial Black">Official Transcript</b>') `h2`,CONCAT('UOS000',std_id) `Student ID`,replace(department,'Department of ','') Department,if(@lang_p = 'AR',s.name_ar,s.name) `Student Name`,get_general(s.degree_id,s.company_id,'degree') AS 'Degree' ,DATE_FORMAT(s.date, '%M %d, %Y') `Admission Date`,DATE_FORMAT(s.gr_date, '%M %d, %Y') `Graduation Date`, if(s.std_comment = '' or s.std_comment is null, '', concat('<span style="color:red">',s.std_comment,'</span>')) `Student Comment` FROM student_view s WHERE s.auto_id = @std;

end if;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_reset_token_sp` (IN `_company_id` INT, IN `_username` VARCHAR(100))  NO SQL BEGIN
SET @token = md5(now());

if(_username = '') THEN 

SELECT 'warning|Please enter valid email, to send your reset code' msg;

elseif EXISTS(SELECT id from ktc_user WHERE company_id = _company_id and (username = _username or email = _username)) THEN


UPDATE ktc_user set reset_code =@token WHERE company_id = _company_id and username = _username;

SELECT CONCAT('success|Your login reset request has been sent! Please check your email for instructions on completing the change') msg, @token token,0 error;

elseif EXISTS(SELECT id from hr_employee WHERE company_id = _company_id and email = _username ) THEN

UPDATE hr_employee set reset_code =@token WHERE company_id = _company_id and email = _username;

SELECT CONCAT('success|Your login reset request has been sent! Please check your email for instructions on completing the change') msg, @token token,0 error;
              
ELSE

SELECT CONCAT('danger|Email: ',_username, ' does not exists to our users please check and try again') msg, 1 error;

END IF;


END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_rp_category_sp` (IN `co_p` INT, IN `category_p` VARCHAR(50), IN `type_p` VARCHAR(50), IN `user_p` INT)  NO SQL BEGIN
 set @i=0;
 if(type_p = 'menu') THEN
SELECT @i:=@i+1 `No`, c.id `id~id hide`,c.order_by `Order~updatable~order_by,ktc_category`, c.name `Category~updatable~name,ktc_category`,c.icon `Icon~updatable~icon,ktc_category`, count(DISTINCT sc.id)  `Sub Menus~sum`,count(DISTINCT l.id)  `Forms~sum`,ktc_edit(c.id,'ktc_category','id','ktc_category',user_p,1) `Edit~ignore`,ktc_del(c.id,'ktc_category','id',user_p,1) `Del~ignore` ,'' no_footer FROM ktc_category c left join ktc_sub_category sc on sc.category_id=c.auto_id and c.company_id=sc.company_id left join ktc_link l on l.category_id=c.auto_id and l.company_id=c.company_id where c.auto_id like category_p and c.company_id = co_p group by c.id;
ELSE

SELECT @i:=@i+1 `No`,sc.id `id~id hide`,sc.order_by `Order~updatable~order_by,ktc_sub_category`,  c.name `Category`,sc.name `Sub Menu~updatable~name,ktc_sub_category`,sc.icon `Icon~updatable~icon,ktc_sub_category`, count(l.id)  `Forms~sum`,ktc_edit(sc.id,'ktc_sub_category','id','ktc_sub_category',user_p,1) `Edit~ignore`,ktc_del(sc.id,'ktc_sub_category','id',user_p,1) `Del~ignore` ,'' no_footer FROM ktc_category c join ktc_sub_category sc on sc.category_id=c.auto_id and sc.company_id=c.company_id left join ktc_link l on l.sub_category_id=c.auto_id and sc.company_id=l.company_id where sc.category_id like category_p and sc.company_id = co_p group by sc.id;

end if;
end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_rp_chart_sp` (IN `user_p` INT, IN `chart_p` VARCHAR(50), IN `co_p` INT)  NO SQL BEGIN
if(chart_p = 'user') THEN
SELECT ktc_chart( `chart`,user_p,co_p) count_number, `icon`, `class_color`, `description`, `type`, `position` FROM ktc_chart c join ktc_user_permission p on p.link_id=c.auto_id and p.company_id=c.company_id WHERE p.user_id = user_p and p.action = 'chart' and c.company_id = co_p and c.type = chart_p  order by c.position;

elseif(chart_p = 'teacher') THEN
SELECT if(faculty_id = 9, 'AR', 'EN') into @lang from hr_employee where auto_id = user_p limit 1;
SELECT ktc_chart( `chart`,user_p,co_p) count_number, `icon`, `class_color`,  ktc_translate(c.company_id,c.auto_id,'ktc_chart', @lang,`description`) description, `type`, `position` FROM ktc_chart c  WHERE c.company_id = co_p and c.type = chart_p  order by c.position;



ELSE
SET @i = 0;
SELECT @i:=@i+1 No, c.id `id~hide id`, c.position `Order by~updatable`, description `Description`, ktc_chart( `chart`,user_p,co_p) `Count~sum`, `icon` Icon, `class_color` `BS Color`, ktc_edit(id,'ktc_chart','id','ktc_chart',user_p,co_p) `Edit~ignore`,ktc_del(id,'ktc_chart','id',user_p,co_p) `Del~ignore`, '' no_footer FROM ktc_chart c  WHERE c.auto_id like chart_p and c.company_id = co_p;

end if;


end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_rp_common_parameter_sp` (IN `user_p` INT, IN `param_p` VARCHAR(50))  NO SQL BEGIN
SET @i=0;
SELECT @i:=@i+1 `No`,c.id `id~hide id`,c.parameter `Parameter~updatable`,c.label`Lable~updatable`,c.type `Element Type~updatable`,c.placeholder `PlaceHolde~updatable`,c.default_value `Default Value~updatable`,c.action `Action~updatable`,c.class `Class~updatable`,c.size `Size~updatable`,c.load_action `Load Action~updatable`,  ktc_del(c.id,'ktc_common_param','id',user_p ) `Del~ignore`, ktc_edit(c.id,'ktc_common_param','id','ktc_common_param',user_p ) `Edit~ignore`,'' no_footer FROM ktc_common_param c where c.parameter like param_p;

end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_rp_delete_logs_sp` (IN `user_p` VARCHAR(250), IN `table_p` VARCHAR(200), IN `from_p` DATE, IN `to_p` DATE)  NO SQL BEGIN
IF( to_p = '0000-00-00')THEN
SET to_p=now();
END IF;
SET @i=0;
SELECT @i:=@i+1 `No`,'53' `sp~hide req`,user_p `user~hide`,d.id `id~hide req`,d.back_up `Deleted Data`,d.description `Description`,u.username `Username`,d.table `Table`,d.date `Date Time`,concat('<button class="ktc-tick" title><i class="fa fa-refresh"></i></button>') `Undo`,'' no_footer FROM ktc_delete_logs d JOIN ktc_user u on u.auto_id=d.user_id and u.company_id=d.company_id WHERE d.status=1 and date(d.date) BETWEEN from_p and to_p and d.user_id like user_p and d.table like table_p;
END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_rp_dropdown_sp` (IN `user_p` INT, IN `acc_p` VARCHAR(50))  NO SQL BEGIN
SET @i = 0;
SELECT @i:=@i+1 No, ktc.value `Option value`,ktc.text `Display Option`,ktc.action `Action`,ktc.description `Decription`,ktc_edit(ktc.id,'ktc_dropdown','id','dropdown',user_p,0) `Edit~ignore` ,ktc_del(id,'ktc_dropdown','id',user_p,0) `Del~ignore`,'' no_footer FROM ktc_dropdown ktc WHERE ktc.action LIKE acc_p;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_rp_edit_logs_sp` (IN `user_p` VARCHAR(50), IN `table_p` VARCHAR(50), IN `from_p` DATE, IN `to_p` DATE)  NO SQL BEGIN
if(date(to_p) = '0000-00-00' ) THEN

SET to_p = NOW();
end if;
SET @i = 0;
SELECT @i:=@i+1 No, '16' `sp~req hide`,ke.tran_id `id~req hide`, ke.table `Table~req`,ke.set_col `Column~req`,`old_value` `Old Value~req`,ke.col `col~req hide`,ke.user_id `user~req hide`,ke.company_id `CO~hide req`,`val` `New Value`, ku.username `Username`, ke.`date` `Date Time`,concat('<button class="ktc-tick" title><i class="fa fa-refresh"></i></button></i>') `Undo`, '' no_footer FROM ktc_edit_logs ke  left join ktc_user ku on ku.auto_id=ke.user_id and ku.company_id=ke.company_id WHERE ke.user_id like user_p and date(ke.date) BETWEEN from_p and to_p and ke.table like table_p ;
end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_rp_error_sp` (IN `_company_id` INT, IN `_status` VARCHAR(100), IN `_from` DATE, IN `_to` DATE, IN `_user_id` INT)  NO SQL BEGIN


SELECT c.name Menu, l.name Page, e.description, e.screenshot `Screenshot~image`,  e.date,
ktc_edit2(e.id,'ktc_error','id',0 ,_company_id) `Edit`,ktc_del(e.id,'ktc_error','id',0 ,_company_id) `Del`, 'no_footer' FROM ktc_error e join ktc_link l on l.auto_id=e.link_id join ktc_category c on c.auto_id=l.category_id WHERE e.status like _status and e.date BETWEEN _from and _to;

end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_rp_expired_procedure_sp` (IN `_user_id` INT, IN `_type` VARCHAR(50), IN `_action` VARCHAR(50), IN `_domain` VARCHAR(250))  NO SQL BEGIN

SELECT ROUTINE_NAME, ROUTINE_TYPE, concat('<a href="',_domain,'/forms/drop/',ROUTINE_TYPE,'/',ROUTINE_NAME,'" target="_blank">Drop ',ROUTINE_NAME,'</a>') `Drop` FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA = DATABASE() AND ROUTINE_NAME not in (SELECT sp from ktc_link) AND ROUTINE_TYPE like _type AND ROUTINE_NAME NOT LIKE 'ktc_%';

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_rp_inbox_sp` (IN `user_p` INT, IN `user2_p` INT, IN `from_p` DATE, IN `to_p` DATE)  NO SQL SELECT ku.username `from user`,k.username `to user`,`title`,`msg`,`file`,date(i.`date`) date ,'' no_footer FROM ktc_inbox i JOIN ktc_user ku on i.from_user=ku.id JOIN ktc_user k on k.id=i.to_user_id WHERE `from_user` = user_p and `to_user_id`=user2_p and date(i.date) BETWEEN from_p and to_p$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_rp_link_sp` (IN `co_p` INT, IN `category_p` VARCHAR(50), IN `sub_category_p` VARCHAR(50), IN `link_p` VARCHAR(50), IN `sp_p` VARCHAR(50), IN `user_p` INT)  NO SQL BEGIN





SET @i = 0;

if(sp_p = '') then set sp_p = '%'; end if;

SELECT @i:=@i+1 No, ktc_tick() `Repair~ignore`,ktc_edit(l.id,'ktc_link','id','link',user_p ,1) `Edit~ignore`,ktc_del(l.id,'ktc_link','id',user_p ,1) `Del~ignore`, l.id `id~hide id`, l.order_by `Order~updatable~order_by,ktc_link`, '33' `sp~hide req`, user_p `User~hide req`, l.name `Text~req updatable~name,ktc_link`,l.title `Title~req updatable~title,ktc_link`,l.level `Level`,c.name Menu, s.name `Sub Menu~group`,l.link_icon `Icon~updatable`, l.auto_id `ID~hide req`, l.company_id `co~hide req`, href `Href~updatable~href,ktc_link`,l.form_action `Form action~updatable~form_action,ktc_link`, l.btn `Button~updatable~btn,ktc_link`,l.sp `Proc~updatable~sp,ktc_link`, l.form_name `Form~updatable~form_name,ktc_link`, count(p.id) `Param~sum`, ktc_param(l.sp) `SP~sum`,ktc_param(l.sp)-count(p.id) `Dif~sum` , '' no_footer, ktc_print(l.id,'link',co_p) `Print~ignore` FROM  ktc_link l join ktc_category c on c.auto_id=l.category_id and c.company_id=l.company_id left join ktc_sub_category s on s.auto_id=l.sub_category_id and l.company_id=s.company_id  left join ktc_parameter p on p.link_id=l.auto_id and p.company_id=l.company_id where l.auto_id like link_p and l.sp like sp_p and l.category_id like category_p and l.sub_category_id like sub_category_p and l.company_id = co_p  group by l.auto_id,l.company_id;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_rp_parameters_sp` (IN `co_p` INT, IN `category_p` VARCHAR(50), IN `sub_category_p` VARCHAR(50), IN `link_p` VARCHAR(50), IN `parameter_p` VARCHAR(50))  NO SQL BEGIN 
if(parameter_p = '') THEN SET parameter_p = '%'; end if;

if(category_p = 'quick-for-devloper') THEN
SELECT auto_id into @id from ktc_link l where concat(l.href,'/',l.form_name) = link_p and company_id = co_p;
SET link_p = @id;
SET category_p = '%';

END IF;

SET @i=0;

SELECT @i:=@i+1 No,l.name `Form`,l.sp `SP`, p.id `id~hide  id`, p.parameter `Parameter`,p.lable `Label~updatable~lable,ktc_parameter`,p.type `Element Type~updatable check-action~type,ktc_parameter`,p.placeholder  `Placeholder~updatable~placeholder,ktc_parameter`
,p.action `Action~updatable~action,ktc_parameter`,p.class `Class~updatable~class,ktc_parameter` ,p.default_value `Default Value~updatable~default_value,ktc_parameter`,p.icon `Icon~updatable~icon,ktc_parameter`,p.size `Size~updatable~size,ktc_parameter`,p.load_action `Load Action~updatable~load_action,ktc_parameter`,p.is_required `Is Required~updatable~is_required,ktc_parameter`, p.help_text `Help Text~updatable~help_text,ktc_parameter`, `table` `Table~updatable~table,ktc_parameter`, `columns` `Columns~updatable~columns,ktc_parameter`, concat(ktc_domain(co_p),'/',p.sample) `Sample`,ktc_edit(p.id,'ktc_parameter','id','ktc_paremeter',0, co_p) `Edit~ignore`, '' no_footer FROM ktc_parameter p join ktc_link l on l.auto_id=p.link_id and l.company_id=p.company_id WHERE `link_id` like link_p and p.parameter like parameter_p and p.company_id = co_p and l.category_id like category_p and l.sub_category_id like sub_category_p;


end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_rp_solution_sp` (IN `_company_id` INT, IN `_status` VARCHAR(100), IN `_from` DATE, IN `_to` DATE, IN `_user_id` INT)  NO SQL BEGIN


SELECT ke.category_id, ke.sub_category_id ,ke.link_id,ks.description,ks.screenshot,ke.description,ks.screenshot,ks.user_id,ke.date,ks.date,
ktc_edit2(ks.id,'ktc_solution','id',_user_id ,_company_id) `Edit`,ktc_del(ks.id,'ktc_solution','id',_user_id ,_company_id) `Del`, 'no_footer' FROM ktc_solution ks join ktc_error ke on ks.error_id = ke.auto_id  WHERE ke.status like _status and ks.date BETWEEN _from and _to;

end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_rp_table_sp` (IN `table_p` TEXT)  NO SQL BEGIN
SET @i = 0;
SELECT @i:=@i+1 No,`TABLE_NAME` `Table Name~count table`, GROUP_CONCAT(COLUMN_NAME) `Column Names`,replace(GROUP_CONCAT(COLUMN_KEY),',,','') `Column Key`, count(COLUMN_NAME) `Columns~sum`, 'company_id,name' `Where Columns~ unique_columns~contenteditable` ,if(replace(GROUP_CONCAT(COLUMN_KEY),',,','') like '%UNI%' OR replace(GROUP_CONCAT(COLUMN_KEY),',,','') like '%MUL%','<button class="fa fa-remove ktc-gen-sp"></button>','No Unique') `Generate Proc~ignore`, '' no_footer FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() and  find_in_set(TABLE_NAME, table_p) group by `TABLE_NAME`;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_rp_todo_sp` (IN `_company_id` INT, IN `_status` VARCHAR(100), IN `_from` DATE, IN `_to` DATE, IN `_user_id` INT)  NO SQL BEGIN


SELECT description, status, date,
ktc_edit2(id,'ktc_todo','id',_user_id ,_company_id) `Edit`,ktc_del(id,'ktc_todo','id',_user_id ,_company_id) `Del`, 'no_footer' FROM ktc_todo WHERE status=_status and date BETWEEN _from and _to;

end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_rp_user_logs_sp` (IN `users_p` VARCHAR(50), IN `link_p` VARCHAR(50), IN `from_p` DATE, IN `to_p` DATE, IN `status_p` VARCHAR(50))  NO SQL BEGIN
if(date(to_p) = '0000-00-00') THEN

SET to_p = date(NOW2());
end if;

if(date(from_p) = '0000-00-00') THEN

SET from_p = '2022-09-30';
end if;


SET @i = 0;
SELECT @i:=@i+1 No,ku.id,ifnull(ktc_user(ku.user_id,ku.user_level,1),concat(ku.username,'-Login')) username, if(ku.status=1,'Success',if(ku.status=0,'Failed login',if(ku.status=2,'Inactie','Incomplete info'))) `Status`,ifnull(kl.name,'Login') `Form` , `ip` `IP Address`, CONCAT(`device`, '(', `os`,')') `Device`, `browser` `Browser`, CONCAT( region, ', ',country) `Country`,ku.city `Location`, ku.date `Date`,'no_footer' FROM ktc_user_logs ku left JOIN ktc_link kl on kl.auto_id=ku.link_id  WHERE ku.`last_date` BETWEEN from_p and  to_p and ku.`user_id`  LIKE users_p and ku.link_id like link_p and ku.status like  status_p;
end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_rp_user_permission` (IN `acc_p` VARCHAR(50), IN `user_p` VARCHAR(50), IN `user2_p` INT, IN `co_p` INT, IN `link_p` VARCHAR(50))  NO SQL BEGIN
SET @i = 0;
IF(acc_p='edit' or acc_p = 'delete')THEN


SELECT  @i:=@i+1 No, k.text `Edit/Delete `,ktc_user(p.user_id,'u',1) `Username` ,ktc_user(p.granted_user_id,'u',1) `Granted by` ,date(p.date) `Granted Date` ,ktc_del(p.id,'ktc_user_permission','id',user2_p,1)  `Deny~ignore`,'' no_footer FROM ktc_dropdown k JOIN ktc_user_permission p on p.link_id=k.id JOIN ktc_user u on u.auto_id=p.user_id  WHERE  p.user_id like user_p and p.action = acc_p  and p.company_id = co_p;

ELSEIF(acc_p='chart')THEN

SELECT  @i:=@i+1 No, k.description `Chart `,ktc_user(p.user_id) `Username` ,ktc_user(p.granted_user_id) `Granted by` ,date(p.date) `Granted Date` ,ktc_del(p.id,'ktc_user_permission','id',user2_p,1)  `Deny~ignore`,'' no_footer FROM ktc_chart k JOIN ktc_user_permission p on p.link_id=k.auto_id JOIN ktc_user u on u.id=p.user_id  WHERE  p.user_id like user_p and p.action = acc_p  and k.company_id = co_p;

ELSEIF(acc_p='branch')THEN

SELECT  @i:=@i+1 No, k.name `Branch`,ktc_user(p.user_id) `Username` ,ktc_user(p.granted_user_id) `Granted by` ,date(p.date) `Granted Date` ,ktc_del(p.id,'ktc_user_permission','id',user2_p,1)  `Deny~ignore`,'' no_footer FROM branch k JOIN ktc_user_permission p on p.link_id=k.id JOIN ktc_user u on u.auto_id=p.user_id  WHERE  p.user_id like user_p and p.action = acc_p  and k.company_id = co_p;



ELSE

SELECT  @i:=@i+1 No, k.name `Form `,u.username,ktc_user(p.granted_user_id) `Granted by` ,date(p.date) `Granted Date` ,ktc_del(p.id,'ktc_user_permission','id',user2_p,1)  `Deny~ignore`,'' no_footer FROM ktc_link k JOIN ktc_user_permission p on p.link_id=k.auto_id and k.company_id=p.company_id JOIN ktc_user u on u.auto_id=p.user_id and u.company_id=p.company_id WHERE  p.user_id like user_p and p.action like 'link' and k.company_id = co_p and p.link_id like link_p;
end if;
end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_rp_user_sp` (IN `user_p` VARCHAR(50), IN `user2_p` VARCHAR(50))  NO SQL BEGIN

SET @i = 0;

SELECT @i:=@i+1 `No`, u.name `Full Name`,u.username `Username~name`,u.tell `Tell~count tell`,u.email `Email`, o.name `Office`, b.name `Campus` , image `Image~image`,(case when u.status = 1 THEN '<span class="badge bg-primary">Active</span>' WHEN u.status = 0 THEN '<span class="badge bg-danger">In active</span>'  ELSE  '<span class="adge bg-info">Unknown</span>' end) `Status`, u.last_login `Lats Login`, u.last_activity `Last Activity`, u.last_page `Last Form`,  'no_footer' ,ktc_edit(u.id,'ktc_user','id','ktc_user|',user_p,1) `Edit~ignore` FROM ktc_user u left join general o on o.auto_id=u.office_id and o.type = 'office' left join branch b on b.auto_id=u.branch_id   where u.auto_id like user2_p;

end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_run_query_sp` (IN `_query` LONGTEXT)  NO SQL BEGIN
	SET @sql = _query;
  PREPARE stm FROM @sql;
  EXECUTE stm;
  DEALLOCATE PREPARE stm;
  
  SELECT 'success|query executed success' as msg;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_search_row_sp` (IN `action_p` VARCHAR(50), IN `id_p` VARCHAR(50), IN `user_p` INT)  NO SQL BEGIN

select RIGHT(action_p,1)into @r;
SELECT LEFT(action_p,char_length(action_p)-1) into @table;

if (@r='|')THEN
SELECT GROUP_CONCAT(concat( COLUMN_NAME , ' as `', COLUMN_COMMENT,'`')) into @edit_columns FROM  information_schema.COLUMNS where TABLE_SCHEMA = DATABASE() and TABLE_NAME = @table and COLUMN_COMMENT != '';
set @sql=concat('select  ',@edit_columns,'  from ',@table , ' WHERE id = ',id_p);

PREPARE s FROM @sql ;
EXECUTE s;
elseif(action_p = 'link') THEN
SELECT l.name `name`, l.category_id `category_id~dropdown~ktc_category|`,l.sub_category_id `sub_category_id~dropdown~ktc_sub_category`, l.title `Title`, l.sp `Sp~autocomplete~sp`, l.form_action `Form_action~dropdown~form_`, l.href `Href~dropdown~href_`, l.href `Href`, l.level `Level~dropdown~user_level_` FROM ktc_link l where l.id=id_p;

ELSEIF(action_p='dropdown')THEN
SELECT ktc.value,ktc.text,ktc.action,ktc.description FROM ktc_dropdown ktc WHERE id=id_p ;
ELSEIF(action_p='ktc_common_param')THEN
SELECT `parameter` Parameter, `label` Label, `type` Type, `action` Action, `placeholder` Placeholder, `default_value` `defualt Value`, `class` Class, `size` Size, `load_action` `Load Action` FROM `ktc_common_param` WHERE id=id_p;

ELSEIF(action_p='ktc_chart')THEN
SELECT chart,icon, `class_color`, `description`, `type`, `position` FROM `ktc_chart` WHERE id=id_p;
ELSEIF(action_p='ktc_category')THEN
SELECT c.name Category,c.icon Icon FROM ktc_category c WHERE id=id_p;
ELSEIF(action_p='ktc_user')THEN
SELECT c.name `Full Name`,c.username `Username`,c.tell Tell, c.email Email,c.status `Status` FROM ktc_user c WHERE id=id_p;


 ELSEIF(action_p='ktc_sub_category')THEN
SELECT  c.name ,c.icon ,c.category_id `category_id~dropdown~ktc_category|` FROM ktc_sub_category c where c.id = id_p;

 ELSEIF(action_p='ktc_paremeter')THEN
SELECT  p.sample `sample~file` FROM ktc_parameter p where p.id = id_p;

ELSEIF(action_p='company')THEN
SELECT c.name , c.tell `Tell`, c.address , c.email, c.merchant_no , c.domain `Domain`, c.description , c.logo `logo~file`, c.letter_head `letter_head~file` FROM company c WHERE c.id=id_p;
ELSEIF(action_p = 'branch') THEN
SELECT name Name, tell Tell, address Address, email Email from branch b where id = id_p;


elseif(action_p = 'general') THEN

SELECT name `Name`, description `Description~textarea` FROM `general` WHERE id = id_p;



elseif(action_p = 'student') THEN
SELECT s.name, s.tell, s.address, s.gender `gender~dropdown~gender_`, s.class_id `class_id~dropdown~class|`, s.password, s.type from student s WHERE s.id = id_p;


elseif(action_p = 'lesson') THEN
SELECT l.name, l.video, l.minutes, l.chapter_id `chapter_id~dropdown~chapter|`,l.preview, l.minutes from lesson l WHERE l.id = id_p;

elseif(action_p = 'teacher') THEN
SELECT t.name,t.tell,t.gender `Gender~dropdown~gender_`,t.email,t.address,t.image `image~file`,t.cv `CV~file`,t.experience FROM teacher t WHERE `auto_id` = id_p;

elseif(action_p = 'class') THEN
SELECT c.name `Class`, c.dep_id `Department~dropdown~deapartment|`, c.acc_year `Accademic_year` FROM class c WHERE c.id = id_p;

elseif(action_p = 'course') THEN
SELECT c.name `Course`, c.department_id `Department~dropdown~deapartment|` FROM course c WHERE c.auto_id = id_p;

elseif(action_p = 'course_teacher') THEN
SELECT c.course_id `Course~dropdown~course|`, c.teacher_id `Lecture~dropdown~teacher`,c.price,c.duration,c.book `book`,c.status FROM course_teacher c WHERE c.id = id_p;

elseif(action_p = 'chapter') THEN
SELECT c.name `Chapter`, c.course_id `Course~dropdown~Course|`, c.teacher_id `Lecture~dropdown~teacher`,c.pdf `Chapter PDF` FROM chapter c WHERE c.id = id_p;

elseif(action_p = 'lesson') THEN
SELECT l.name `Lesson`,l.chapter_id `Chapter~dropdown~Chapter`,l.course_id `Course~dropdown~Course|`, l.teacher_id `Lecture~dropdown~teacher`, l.pdf `Lesson PDF`, l.preview `Preview~dropdown~preview_`,l.video FROM lesson l WHERE l.id = id_p;
elseif(action_p = 'question') THEN
SELECT q.name, q.type `type~dropdown~ques_type_`, q.options, q.correct_answer, q.marks  FROM question q WHERE q.id = id_p;


ELSEIF(action_p='slider')THEN
SELECT  c.slider1 `slider1~file`, c.slider2 `slider2~file`, c.slider3 `slider3~file` FROM company c WHERE c.id=id_p;
end if;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_set_auto_sp` (IN `_company_id` INT, IN `_table` VARCHAR(50))  NO SQL BEGIN
SET @auto = 1;
SET @sql = CONCAT('SELECT auto_id+1 into @auto from ',_table,' where company_id =',_company_id,' order by auto_id desc limit 1');
#SELECT @sql;

PREPARE s from @sql;
EXECUTE s;


END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_sms_sp` (IN `_company_id` INT, IN `_tell` VARCHAR(50), IN `_table` VARCHAR(50), IN `_to_id` INT, IN `_action` VARCHAR(50), IN `_user_id` INT)  NO SQL BEGIN
if(_action = 'as_patient' and _table = 'hospital') THEN

SELECT if(char_length(trim(h.tell)) > 10, trim(h.tell), concat('252',right(trim(h.tell),9))) tell, concat('[BULSHO TECH]*%0aAsc Shirkadda Bulsho Tech waxay kugu bishaareyneysaa in dad-ka doonaya Ticket-ka isbitaalada ay usoo kordhisay App u fududeynaya Jarashada Ticket-ka isbitaalada goor kasta iyo goob kasta Fadlan kalasoo deg App-ka https://bit.ly/3XeGXmJ Mahadsanid') sms into @tell, @sms FROM hospital h WHERE   h.auto_id = _to_id;

elseif(_action = 'as_hospital' and _table = 'hospital') THEN

SELECT if(char_length(trim(h.tell)) > 10, trim(h.tell), concat('252',right(trim(h.tell),9))) tell, concat('Asc Shirkadda Bulsho Tech waxay isbitaalada dal-ka soomaaliya ugu bishaareyneysaa in ay soo kordhisay App si fudud looga dalabn karo Ticket-ka isbitaalada goor kasta iyo goob kasta, kalasoo deg App-ka https://bit.ly/3XeGXmJ , ka isbitaal ahaan hadii aad dooneyso inaad hesho xog ku saabsan sida uu App-kan u shaqeeyo nala soo xiriir Mahadsanid') sms into @tell, @sms FROM hospital h WHERE   h.auto_id = _to_id;

end if;


INSERT into ktc_sms( tell, sms, user_id, `table`, `action`, to_id) values (@tell, @sms, _user_id, _table, _action, _to_id);

 
SELECT @tell tell, @sms sms;
end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_solution_sp` (IN `_company_id` INT, IN `_error_id` INT, IN `_description` VARCHAR(100), IN `_screenshot` VARCHAR(100), IN `_user_id` INT, IN `_date` DATE)   BEGIN 

               
               
                INSERT INTO `ktc_solution` (company_id ,error_id,description,screenshot,user_id,date ) 
                VALUES (_company_id ,_error_id,_description,_screenshot,_user_id,_date);
                
                SELECT concat('success|',_company_id,' registered success') as msg;
              
                 END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_sub_category_sp` (IN `co_p` INT, IN `category_p` INT, IN `name_p` VARCHAR(100), IN `icon_p` VARCHAR(100), IN `user_p` INT)  NO SQL BEGIN
CALL ktc_set_auto_sp(co_p,'ktc_sub_category');

INSERT INTO ktc_sub_category(category_id,name,icon,user_id,company_id,auto_id)
VALUES(category_p,name_p,icon_p,user_p,co_p,@auto);
SELECT concat('success|',name_p,' Registred Success')as msg;


END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_todo_sp` (IN `_company_id` INT, IN `_description` VARCHAR(100), IN `_status` VARCHAR(100), IN `_user_id` INT, IN `_date` DATE)   BEGIN 

               
               
                INSERT INTO `ktc_todo` (company_id ,description,STATUS,user_id,date ) 
                VALUES (_company_id ,_description,_STATUS,_user_id,_date);
                
                SELECT concat('success|',_company_id,' registered success') as msg;
              
                 END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_tracker_sp` (IN `user_p` VARCHAR(50), IN `device_p` VARCHAR(50), IN `os_p` VARCHAR(50), IN `ip_p` VARCHAR(50), IN `browser_p` VARCHAR(50), IN `country_p` VARCHAR(50), IN `region_p` VARCHAR(50), IN `city_p` VARCHAR(50))  NO SQL BEGIN

if exists(SELECT id from ktc_user_logs where user_id = user_p and link_id = 0 and os = os_p and device = device_p and ip = ip_p and country = country_p and region = region_p and city = city_p and browser = browser_p) THEN 
UPDATE ktc_user_logs set `count`=`count`+1, today_count = if(last_date = date(now()), today_count +1 , 1) , last_date = date(now()) where user_id = user_p and link_id = 0 and os = os_p and device = device_p and ip = ip_p and country = country_p and region = region_p and city = city_p and browser = browser_p;

else

INSERT INTO `ktc_user_logs`( `user_id`, `link_id`,  `date`, `last_date`, `count`, `today_count`, `ip`, `device`, `os`, `browser`, `country`, `region`, `city`) VALUES (user_p,0,now(),now(),1,1,ip_p,device_p,os_p,browser_p,country_p,region_p,city_p);


end if;




END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_tranfer_form_sp` (IN `co_p` INT, IN `category_p` INT, IN `sub_category_p` INT, IN `link_p` INT, IN `co2_p` INT, IN `category2_p` INT, IN `sub_category2_p` INT, IN `user_p` INT)  NO SQL BEGIN
SET AUTOCOMMIT = 0;
START TRANSACTION;

UPDATE ktc_link set category_id= category2_p , sub_category_id = sub_category2_p WHERE auto_id = link_p and company_id = co_p;

SELECT concat('success|',l.name,' has been transfered success') as msg FROM ktc_link l WHERE auto_id=link_p and company_id = co_p;
COMMIT;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_undo_delete_sp` (IN `id_p` INT)  NO SQL BEGIN

SELECT replace(l.back_up,',',quote(',')),replace(l.column_structure,',','`,`'),l.table into @b,@c,@t FROM ktc_delete_logs l where l.id = id_p;


SET @sql = concat('INSERT INTO `',@t,'` (`',@c,'`) VALUES (''',@b,''')');

PREPARE s from @sql;
EXECUTE s;

UPDATE ktc_delete_logs SET status=0 WHERE id=id_p;
SELECT "success|Data Has Been Restored" as msg;


END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_update_user_sp` (IN `co_p` INT, IN `user_p` INT, IN `name_p` VARCHAR(250), IN `image_p` VARCHAR(250))  NO SQL BEGIN

UPDATE ktc_user set name = name_p , image = image_p WHERE auto_id = user_p and company_id = co_p;

SELECT 'success|Profile updated success' msg;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_user_permission_sp` (IN `link_p` INT, IN `user_p` INT, IN `gr_user_p` INT, IN `action_p` VARCHAR(50), IN `grant_p` VARCHAR(20), IN `co_p` INT)  NO SQL BEGIN

if(user_p = 0) THEN
SELECT concat('danger|Please select user to grant, and click SHow Permissions Button again');

elseif(grant_p = 'grant') THEN
INSERT IGNORE INTO ktc_user_permission  (link_id,user_id,granted_user_id,action,date,company_id) VALUES (link_p,user_p,gr_user_p,action_p,now(),co_p);
SELECT concat('success|',row_count(),' Form/Forms has been granted');
ELSEif(grant_p = 'revoke') THEN

DELETE FROM ktc_user_permission where link_id = link_p and user_id = user_p and action =action_p and company_id = co_p;
SELECT concat('success|',row_count(),' Form/Forms has been revoked');
end if;


END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_user_schedule_sp` (IN `user_p` INT, IN `time_in_p` TIME, IN `time_out_p` TIME, IN `days_p` VARCHAR(100), IN `user2_p` INT)  NO SQL BEGIN
    
    
insert into ktc_user_schedule(user_id,time_in,time_out,days,user_id2)
VALUES(user_p,time_in_p,time_out_p,days_p,user2_p);
SELECT"success|has been Registred"as msg;
    
    
    END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ktc_user_sp` (IN `_auto_id` INT, IN `full_name_p` VARCHAR(100), IN `username_p` VARCHAR(100), IN `password_p` VARCHAR(100), IN `confirm_p` VARCHAR(100), IN `tell_p` VARCHAR(100), IN `pic_p` VARCHAR(100), IN `status_p` VARCHAR(100), IN `email_p` VARCHAR(100), IN `user_p` INT, IN `_company_id` INT, IN `_branch_id` INT, IN `_domain` VARCHAR(100), IN `_level` VARCHAR(50))  NO SQL BEGIN
SET AUTOCOMMIT = 0 ;
START TRANSACTION;
SET sql_mode = '';
if(password_p != confirm_p) THEN
 SELECT concat('danger|Password not match, please re-confirm') as msg;
else
CALL ktc_set_auto_sp(_company_id,'ktc_user');

SET @token = md5(now());
   INSERT into ktc_user  (name,username,password,tell,image	,email,user_id,company_id,branch_id,`level`,auto_id,status,reset_code)    VALUES(full_name_p,username_p,md5(password_p),tell_p,pic_p,email_p,user_p,_company_id,_branch_id,_level,@auto, 0, @token);
 

 
 SELECT name, domain into @company, @domain from company where id = _company_id;

SET _domain = @domain;

SELECT CONCAT('success|Registered success, Go to User Permission and Grant the new user ',username_p, ', to activate the user please visit your email inbox or Spam emails') msg, concat('<h3>',full_name_p, ' welcome to BULSHO TECH Services</h3> <p>Thank you for using BULSHO TECH service, to activate your user please click <a href="https://',_domain,'/users/activate/',username_p,'/',@token,'">https://',_domain,'/users/activate/',@token,'</a></p>\n<h4>Below is ',full_name_p, ' information</h4>\n<p> Name : <strong>',full_name_p,'</strong></p>\n<p> Domain : <strong>',_domain,'</strong></p>\n<p> User Email : <strong>',username_p,'</strong></p>\n<p> Password : <strong>',password_p,'</strong></p> ') message,username_p `email`, concat('New account from ',_domain) title;
end if;  
COMMIT;
SET AUTOCOMMIT = 1;

    END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `patient_sp` (IN `_company_id` INT, IN `_name` VARCHAR(100), IN `_gender` VARCHAR(100), IN `_tell` INT, IN `_address` VARCHAR(100), IN `_dob` DATE, IN `_mother` VARCHAR(100), IN `_description` VARCHAR(100), IN `_user_id` INT, IN `_date` DATE)   BEGIN 

                IF EXISTS(SELECT `id` FROM `patient`  WHERE  name = _name) THEN
                SELECT concat('danger|',_name,' already exists, please change and try again.') as msg;
                else
          CALL ktc_set_auto_sp(_company_id,'patient');             
      
                INSERT INTO `patient` (auto_id, company_id ,name,gender ,tell ,address,dob,mother,description,user_id,date ) 
                VALUES (@auto,_company_id,_name,_gender ,_tell ,_address,_dob,_mother,_description,_user_id,_date);
                
                SELECT concat('success|',_name,' registered success') as msg;
                end if;
                 END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `portal_agent_profile_sp` (IN `_tell` INT)  NO SQL BEGIN
SELECT logo into @logo from company where id = 1;
if EXISTS (SELECT id from agent where tell = _tell) THEN
SELECT name `Magaca`, tell `Tell`, address `Deegaanka`, gender `Jinsi`, if(image = '', @logo,image) image, short_link `Linkigayga`, date_format(date, '%d/%m/%Y' ) `Kusoo biiray` from agent where tell = _tell;

else

SELECT concat('Ma diiwaangashana Taleefan-kan fadlan  <a href="https://apps.bulshotech.com/agent/register">abuuro Account cusub</a>') msg;

end if;
END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `portal_app_click_sp` (IN `_token` TEXT, IN `__id` INT, IN `_action` VARCHAR(50))  NO SQL BEGIN
SELECT v.id into @visitor_id from visitor v where token = _token;
INSERT INTO `app_click`(  `visitor_id`, `_id`, `action` ) VALUES (@visitor_id, __id, _action);

SELECT 'success|success' msg;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `portal_campaign_list_sp` (IN `_company_id` INT, IN `_agent_tell` VARCHAR(50), IN `_action` VARCHAR(50))  NO SQL BEGIN 

if(_action = 'current_campaign') THEN

SELECT auto_id, lpad(auto_id, 4,0) id,name, description, start_date, end_date from campaign where date(now2()) BETWEEN start_date and end_date order by id desc limit 1;

ELSE

SELECT auto_id into @campaign_id from campaign where date(now2()) BETWEEN start_date and end_date order by id desc limit 1;


SELECT lpad(c.auto_id, 4,0) id, a.name agent, c.name campaign, count(sh.id) `shares`  FROM campaign_agent ac join campaign c on ac.campaign_id=c.auto_id join agent a on a.auto_id=ac.agent_id left join sharer sh on sh.tell = a.tell where c.auto_id = @campaign_id group by a.auto_id order by shares desc;
END IF;
END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `portal_check_visitor_sp` (IN `_token` TEXT)  NO SQL BEGIN 
if EXISTS(SELECT id from visitor where token = _token or _token  = 'no-token') THEN 

SELECT 1 is_exists;

ELSE


SELECT 0 is_exists;

END IF;


END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `portal_department_sp` (IN `_company_id` INT)  NO SQL BEGIN

SELECT d.name  FROM department d where d.company_id = _company_id order by d.name;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `portal_doctor_list_sp` (IN `_hospital_id` VARCHAR(50), IN `_doctor_id` VARCHAR(50))  NO SQL BEGIN
if EXISTS(SELECT id from doctor where hospital_id like _hospital_id) THEN

SELECT dc.auto_id, dc.name doctor, dc.description doctor_description, dc.image doctor_image, d.name department, d.image department_image, d.description, concat(h.currency, if(dc.ticket_fee = 0, h.ticket_fee , dc.ticket_fee)) ticket_fee , concat(h.currency, h.service_fee) service_fee, concat(h.currency, if(dc.ticket_fee = 0, h.ticket_fee , dc.ticket_fee) + h.service_fee)  total_fee,  (if(dc.ticket_fee = 0, h.ticket_fee , dc.ticket_fee) + h.service_fee)  total_fee_with_no_currency, dc.hospital_id, h.name hospital, h.address, h.city, h.region FROM doctor dc join department d on d.auto_id = dc.department_id join hospital h on h.auto_id = dc.hospital_id WHERE dc.hospital_id like _hospital_id and dc.auto_id like _doctor_id order by d.name;

ELSE

SELECT name hospital,   concat(h.currency, h.ticket_fee ) ticket_fee , concat(h.currency, h.service_fee) service_fee, concat(h.currency, h.ticket_fee  + h.service_fee)  total_fee, 'no-doctor' doctor from hospital h where auto_id like _hospital_id;
END IF;
END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `portal_faq_list_sp` (IN `_company_id` INT)  NO SQL BEGIN

SELECT question, answer from faq;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `portal_hospital_list_sp` (IN `_region` VARCHAR(50), IN `_city` VARCHAR(50))  NO SQL BEGIN

SELECT logo into @logo from company where id = 1;

SELECT h.auto_id, h.name, if(h.logo = '',@logo,h.logo) logo, concat(h.currency, h.ticket_fee) as ticket_fee , h.address, h.region, h.city,  concat('<a id="save-sms" class="save-sms" href="#" alt="',ktc_domain(h.company_id),'/forms/sms_sms/hospital/',h.auto_id,'/as_patient/',h.tell,'/2"><i class="fa fa-whatsapp"></i> P</a>') as_patient,  concat('<a id="save-sms"  class="save-sms" href="#" alt="',ktc_domain(h.company_id),'/forms/sms_sms/hospital-app-ads/',h.auto_id,'/hospitals/',h.tell,'/2"><i class="fa fa-whatsapp"></i>H</a>') as_hospital  from hospital h where h.region like _region and h.city like _city and h.auto_id != 154 order by h.name;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `portal_join_campaign_sp` (IN `_company_id` INT, IN `_agent_tell` INT, IN `_campaign_id` INT)  NO SQL BEGIN 

SELECT auto_id into @agent_id from agent where tell = _agent_tell;

INSERT ignore INTO `campaign_agent`(`company_id`, `agent_id`, `campaign_id`, `date`) VALUES (_company_id,@agent_id, _campaign_id, date(now2()));

SELECT 'Waad ku biirta mahadsanid' msg,  _campaign_id campaign_id;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `portal_sharer_sp` (IN `_company_id` INT, IN `_tell` TEXT, IN `_ip` VARCHAR(100), IN `_device` VARCHAR(100), IN `_os` VARCHAR(250), IN `_browser` VARCHAR(250), IN `_country` VARCHAR(250), IN `_region` VARCHAR(250), IN `_city` VARCHAR(250))   BEGIN 

SELECT auto_id into @campaign_id from campaign c where date(now2()) BETWEEN c.start_date and c.end_date limit 1 ;

if(@campaign_id is null) THEN 
SELECT auto_id into @campaign_id from campaign c  order by id desc limit 1 ;

END IF;
 
INSERT INTO `sharer`( `company_id`, `tell`, `campaign_id`, `ip`, `device`, `os`, `browser`, `country`, `region`, `city`, `date`) VALUES ( _company_id , _tell  ,@campaign_id , _ip , _device  , _os  , _browser  , _country  , _region  , _city, now2());
SELECT 'success|succes' as msg;
 
END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `portal_visitor_sp` (IN `_company_id` INT, IN `_token` TEXT, IN `_ip` VARCHAR(100), IN `_device` VARCHAR(100), IN `_os` VARCHAR(250), IN `_browser` VARCHAR(250), IN `_country` VARCHAR(250), IN `_region` VARCHAR(250), IN `_city` VARCHAR(250))   BEGIN 

if not exists (SELECT id from visitor where token = _token) THEN

INSERT INTO `visitor`( `company_id`, `token`, `ip`, `device`, `os`, `browser`, `country`, `region`, `city`, `date`) VALUES ( _company_id , _token   , _ip , _device  , _os  , _browser  , _country  , _region  , _city, now2());
SELECT 'success|succes' as msg;
else 
SELECT 'danger|already' as msg;
END IF;
END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `rp_agent_sp` (IN `_company_id` INT, IN `_from` DATE, IN `_to` DATE, IN `_user_id` INT)  NO SQL BEGIN

SELECT p.id , p.name,p.gender, p.tell, p.short_link,p.address,p.date,
ktc_edit2(p.id,'agent','id',_user_id ,_company_id) `Edit`,ktc_del(p.id,'agent','id',_user_id ,_company_id) `Del`, 'no_footer' FROM agent p    WHERE   p.date BETWEEN _from and _to;

end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `rp_app_patient_sp` (IN `_company_id` INT, IN `_hospital` VARCHAR(100), IN `_department` VARCHAR(100), IN `_status` VARCHAR(100), IN `_from` DATE, IN `_to` DATE)  NO SQL BEGIN

SELECT id, name, tell, address,dob,description,hospital,doctor,department,date,
ktc_edit2(id,'app_patient','id',_user_id ,_company_id) `Edit`,ktc_del(id,'app_patient','id',_user_id ,_company_id) `Del`, 'no_footer' FROM hospital  WHERE hospital like _hospital and department like _department   and status like _status  and  date BETWEEN _from and _to;

end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `rp_blood_sp` (IN `_company_id` INT, IN `_from` DATE, IN `_to` DATE, IN `_user_id` INT)  NO SQL BEGIN

SELECT p.id , p.name,p.gender, p.tell, p.blood_group,p.address,p.date,
ktc_edit2(p.id,'blood','id',_user_id ,_company_id) `Edit`,ktc_del(p.id,'blood','id',_user_id ,_company_id) `Del`, 'no_footer' FROM blood p    WHERE   p.date BETWEEN _from and _to;

end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `rp_branch_sp` (IN `_company_id` INT, IN `_branch_id` VARCHAR(50), IN `_address_id` VARCHAR(50), IN `_user_id` INT)  NO SQL BEGIN
 
select 'no_footer',b.name`Branch`,b.address `Address`,b.tell `Tell`,b.email `Email`, count(DISTINCT sc.id ) `Classes~sum`, count(DISTINCT s.id )`Students~sum`, ktc_edit(b.id, 'branch','id', 'branch', _user_id,_company_id) `Edit`, ktc_del(b.id,'branch','id',_user_id,_company_id) `Delete` from branch b left join sub_class sc on sc.branch_id = b.auto_id and sc.company_id = b.company_id left join class c on sc.class_id = c.auto_id and sc.company_id = c.company_id left join level l on c.level_id = l.auto_id and c.company_id = l.company_id left join student s on s.sub_class_id = sc.auto_id and sc.company_id = s.company_id where b.company_id = _company_id and b.auto_id like _branch_id and b.address like _address_id
group by b.auto_id;
 
 END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `rp_company_sp` (IN `_company_id` INT, IN `_user_id` INT)  NO SQL BEGIN
SET @i=0;
SELECT @i+1 `NO`, c.id `id~hide id`, c.name `Company Name~updatable~name,company`, c.tell `Telle~updatable~tell,company`,c.address `Address~updatable~address,company`,c.email `Email~updatable~email,company`,c.merchant_no `Merchant No~updatable~merchant_no,company`,c.domain `Domain~updatable~domain,company`, c.description `Description~updatable~description,company`,c.logo `Logo~image`,c.date Date,'no_footer', ktc_edit(c.id,'company','id', 'company',0,_company_id) `Edit~ignore` FROM company c WHERE c.id=_company_id;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `rp_department_sp` (IN `_company_id` INT, IN `_department` VARCHAR(50), IN `_user_id` INT)  NO SQL BEGIN

SELECT d.id, d.name, d.image `Image~image`, d.description,0 `No of doctors`,0 `No of patient`,d.date,
ktc_edit2(d.id,'department','id',_user_id ,_company_id) `Edit`,ktc_del(d.id,'department','id',_user_id ,_company_id) `Del`, 'no_footer' FROM department d   WHERE  d.auto_id like _department  ;

end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `rp_doctor_sp` (IN `_company_id` INT, IN `_hospital` VARCHAR(100), IN `_department` VARCHAR(100), IN `_region` VARCHAR(100), IN `_city` VARCHAR(255), IN `_from2` DATE, IN `_to` DATE, IN `_user_id` INT)  NO SQL BEGIN

SELECT dc.auto_id ID, dc.name Name, dc.tell Tell, d.name Department, h.name Hospital, dc.description, Region, City, Address, dc.ticket_fee `Ticket Fee`, h.commission_fee  `Commission Fee`, h.service_fee `Service Fee`,dc.date Date,
ktc_edit2(dc.id,'doctor','id',_user_id ,_company_id) `Edit`,ktc_del(dc.id,'doctor','id',_user_id ,_company_id) `Del`, 'no_footer' FROM doctor dc join department d on d.auto_id = dc.department_id join hospital h on dc.hospital_id=h.auto_id WHERE dc.hospital_id like _hospital and dc.department_id like _department   and h.region like _region and h.city like _city  and  dc.date BETWEEN _from2 and _to;

end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `rp_evc_app_receipt_sp` (IN `_company_id` INT, IN `_hospital` VARCHAR(100), IN `_from` DATE, IN `_to` DATE)  NO SQL BEGIN

SELECT id, name, tell, hospital,doctor,amount,date,
ktc_edit2(id,'evc_app_receipt','id',_user_id ,_company_id) `Edit`,ktc_del(id,'evc_app_receipt','id',_user_id ,_company_id) `Del`, 'no_footer' FROM hospital  WHERE hospital like _hospital   and  date BETWEEN _from and _to;

end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `rp_expense_sp` (IN `_company_id` INT, IN `_Expense_id` INT, IN `_type` VARCHAR(100), IN `_from` DATE, IN `_to` DATE, IN `_user_id` INT)  NO SQL BEGIN

SELECT e.id, e.amount, e.description, e.type, ku.username, 
ktc_edit2(e.id,'expense','id',_user_id ,_company_id) `Edit`,ktc_del(e.id,'expense','id',_user_id ,_company_id) `Del`, 'no_footer' FROM expense e JOIN ktc_user ku  WHERE e.date BETWEEN _from and _to  ;

end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `rp_faq_sp` (IN `_company_id` INT, IN `_from` DATE, IN `_to` DATE, IN `_user_id` INT)  NO SQL BEGIN

SELECT f.question, f.answer, ku.username, 
ktc_edit2(f.id,'faq','id',_user_id ,_company_id) `Edit`,ktc_del(f.id,'faq','id',_user_id ,_company_id) `Del`, 'no_footer' FROM faq f JOIN ktc_user ku on f.auto_id=ku.username WHERE  f.date BETWEEN _FROM and _to  ;

end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `rp_general_sp` (IN `_company_id` INT, IN `_auto_id` VARCHAR(50), IN `_type` VARCHAR(50), IN `_user_id` INT)  NO SQL BEGIN

SET @i = 0;

SELECT @i:=@i+1 No, name Name, description `Description`, ktc_edit(g.id,'general','id','general',_user_id ,_company_id) `Edit~ignore`,ktc_del(g.id,'general','id',_user_id ,_company_id) `Del~ignore`, '' no_footer from general g where g.auto_id like _auto_id and g.type like _type;

END$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `rp_hospital_sp` (IN `_company_id` INT, IN `_hospital` VARCHAR(100), IN `_region` VARCHAR(100), IN `_city` VARCHAR(255), IN `_from` DATE, IN `_to` DATE, IN `_user_id` INT)  NO SQL BEGIN

SELECT auto_id ID, name, tell, cashier_tell,region,city,address,ticket_fee,commission_fee,service_fee,logo,date, concat('<a href="https://apps.bulshotech.com/forms/contract/',auto_id,'" target="_blank">Heshiis</a>') Contract,
ktc_edit2(id,'hospital','id',_user_id ,_company_id) `Edit`,ktc_del(id,'hospital','id',_user_id ,_company_id) `Del`, 'no_footer' FROM hospital  WHERE auto_id like _hospital and region like _region and city like _city  and  date BETWEEN _from and _to;

end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `rp_patient_sp` (IN `_company_id` INT, IN `_from` DATE, IN `_to` DATE, IN `_user_id` INT)  NO SQL BEGIN

SELECT p.auto_id ID , p.name,p.gender, p.tell, p.dob,p.address, p.mother,p.date,
ktc_edit2(p.id,'patient','id',_user_id ,_company_id) `Edit`,ktc_del(p.id,'patient','id',_user_id ,_company_id) `Del`, 'no_footer' FROM patient p    WHERE   p.date BETWEEN _from and _to;

end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `rp_ticket_sp` (IN `_company_id` INT, IN `_hospital` VARCHAR(50), IN `_department` VARCHAR(50), IN `_region` VARCHAR(50), IN `_city` VARCHAR(50), IN `_from` DATE, IN `_to` DATE, IN `_user_id` INT)  NO SQL BEGIN

SELECT tk.auto_id `Ticket ID`, pt.name,tk.image `image~image`, pt.tell, pt.dob,pt.address,pt.mother,tk.hospital_id,d.name department ,dc.name doctor ,tk.amount,tk.date,
ktc_edit2(tk.id,'ticket','id',_user_id ,_company_id) `Edit`,ktc_del(tk.id,'ticket','id',_user_id ,_company_id) `Del`, 'no_footer' FROM ticket tk JOIN patient pt ON tk.patient_id=pt.auto_id join doctor dc on dc.auto_id = tk.doctor_id JOIN department d on d.auto_id=dc.department_id join hospital h on h.auto_id = tk.hospital_id and dc.hospital_id = h.auto_id WHERE tk.hospital_id like _hospital and d.auto_id like _department   and h.region like _region and h.city like _city  and  tk.date BETWEEN _from and _to;

end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `search_ticket_sp` (IN `_company_id` INT, IN `_tell` VARCHAR(50), IN `_user_id` INT)  NO SQL BEGIN

SELECT tk.auto_id `TicID`, pt.auto_id `PatID`, pt.name,  pt.tell, tk.payment_tell,pt.dob,pt.address,pt.mother,tk.hospital_id,d.name department ,dc.name doctor ,tk.amount, tk.image `image~image`,tk.date,
ktc_edit2(tk.id,'ticket','id',_user_id ,_company_id) `Edit`,ktc_del(tk.id,'ticket','id',_user_id ,_company_id) `Del`, 'no_footer' FROM ticket tk JOIN patient pt ON tk.patient_id=pt.auto_id join doctor dc on dc.auto_id = tk.doctor_id JOIN department d on d.auto_id=dc.department_id join hospital h on h.auto_id = tk.hospital_id and dc.hospital_id = h.auto_id WHERE pt.tell like _tell  or pt.auto_id like _tell or tk.payment_tell like _tell or tk.auto_id like _tell;

end$$

CREATE DEFINER=`kashi`@`localhost` PROCEDURE `ticket_sp` (IN `_company_id` INT, IN `_patient_id` INT, IN `_hospital_id` INT, IN `_doctor_id` INT, IN `_amount` DOUBLE, IN `_user_id` INT, IN `_date` DATE)   BEGIN 

CALL ktc_set_auto_sp(_company_id,'ticket');             

               
INSERT INTO `ticket` (auto_id,company_id ,patient_id ,hospital_id ,doctor_id,amount,user_id,date ) 
                VALUES (@auto,_company_id,_patient_id,_hospital_id ,_doctor_id,_amount,_user_id,_date);
 
SET @last_id = LAST_INSERT_ID();

SELECT p.name, right(p.tell,9), dp.name, h.name, DATE_FORMAT(t.date, "%d/%m/%Y")  into @patient,@tell, @department, @hospital, @date from ticket t join doctor d on d.auto_id=t.doctor_id join department dp on dp.auto_id=d.department_id join hospital h on h.auto_id = t.hospital_id join patient p on p.auto_id=t.patient_id where t.id = @last_id;

 
SELECT concat('success|',@patient,' regsitered a ticket from ', @hospital, ' - ', @department) as msg,  concat(left(@patient,10),' Tar: ',@date,' Waxaan Ticket Number kaaga dalab-nay ',@hospital,'/', @department,', long_url kala soco Ticket-kaaga')  sms , @tell tell, CONCAT('https://apps.bulshotech.com/forms/invoice2/',@last_id,'/ticket/',_company_id) long_url;       
                 END$$

--
-- Functions
--
CREATE DEFINER=`kashi`@`localhost` FUNCTION `ktc_access` (`_user` INT, `_action` VARCHAR(40)) RETURNS TEXT CHARSET utf8 NO SQL BEGIN
SELECT GROUP_CONCAT(link_id) into @access FROM ktc_user_permission WHERE user_id = _user AND `action` = _action;

if(_action = 'user')  THEN

SET @access = concat(ifnull(@access,''), ',',_user);


end if;

RETURN ifnull(@access,'');

END$$

CREATE DEFINER=`kashi`@`localhost` FUNCTION `ktc_add_quick` (`co_p` VARCHAR(60), `sp_p` VARCHAR(50)) RETURNS VARCHAR(260) CHARSET utf8 NO SQL BEGIN

RETURN CONCAT('<a href="views/ktc_quick_form.php?co_id=',co_p,'&sp=',sp_p,'" class="ktc-add-new"  target="_blank">Add New</a>');


END$$

CREATE DEFINER=`kashi`@`localhost` FUNCTION `ktc_ago` (`from_p` DATETIME, `to_p` DATETIME) RETURNS VARCHAR(25) CHARSET utf8 NO SQL BEGIN

SELECT ( CASE WHEN TIMESTAMPDIFF(SECOND,from_p,to_p) < 60 THEN CONCAT(TIMESTAMPDIFF(SECOND,from_p,to_p), 'S') WHEN TIMESTAMPDIFF(MINUTE,from_p,to_p) < 60 THEN CONCAT (TIMESTAMPDIFF(MINUTE,from_p,to_p), 'M') WHEN TIMESTAMPDIFF(HOUR,from_p,to_p) < 24 THEN CONCAT(TIMESTAMPDIFF(HOUR,from_p,to_p), 'H') WHEN TIMESTAMPDIFF(DAY,from_p,to_p) < 30 THEN CONCAT(TIMESTAMPDIFF(DAY,from_p,to_p), 'D') WHEN TIMESTAMPDIFF(MONTH,from_p,to_p) < 12 THEN CONCAT(TIMESTAMPDIFF(MONTH,from_p,to_p), 'Mo') WHEN TIMESTAMPDIFF(YEAR,from_p,to_p) > 1 THEN CONCAT(TIMESTAMPDIFF(YEAR,from_p,to_p), 'Y') end) into @ago;

RETURN @ago;

END$$

CREATE DEFINER=`kashi`@`localhost` FUNCTION `ktc_allowed_ext` (`_action` VARCHAR(50)) RETURNS TEXT CHARSET utf8 NO SQL BEGIN
if(_action = '') then set _action = '%'; end if;
SELECT group_concat(`text`) into @allowed FROM `ktc_dropdown` WHERE `value` like _action and action = 'folder';

RETURN CONCAT('<span style="color: red">Allowed extensions are : ',@allowed,'</span>');

END$$

CREATE DEFINER=`kashi`@`localhost` FUNCTION `ktc_cancel` (`id_p` VARCHAR(200), `table_p` VARCHAR(50), `col_p` VARCHAR(200), `status_p` VARCHAR(50), `user_p` INT, `co_p` INT) RETURNS TEXT CHARSET utf8 NO SQL BEGIN
if not EXISTS (SELECT id from ktc_dropdown where `value` = table_p and `action` = 'cancel') THEN
INSERT into ktc_dropdown (`value`,`text`, `action`) VALUE (table_p,CONCAT('Cancel ',table_p),'cancel');
SET @l = LAST_INSERT_ID();
INSERT INTO `ktc_user_permission`( `link_id`, `user_id`, `granted_user_id`, `action`, `company_id`, `date`) VALUES (@l,user_p,user_p,'cancel', co_p, date(now()));
end if;
SET @icon = 'fa fa-remove';
if(status_p = 1) THEN SET @icon = 'fa fa-refresh'; END IF;
if(user_p = 0) THEN
RETURN CONCAT('<i class="fa ',@icon,' ktc-cancel btn" alt="',table_p,'" id="',id_p,'" column="',col_p,'" status="',status_p,'""><i>');

elseif EXISTS(SELECT p.user_id FROM ktc_user_permission p join ktc_dropdown d on d.id=p.link_id WHERE p.action = 'cancel' and p.user_id = user_p and d.value = table_p and p.company_id = co_p) THEN
RETURN CONCAT('<i class="fa ',@icon,' ktc-cancel btn" alt="',table_p,'" id="',id_p,'" column="',col_p,'" status="',status_p,'""><i>');
ELSE

RETURN 'XX';

end if;
END$$

CREATE DEFINER=`kashi`@`localhost` FUNCTION `ktc_cap_first` (`input` VARCHAR(255)) RETURNS VARCHAR(255) CHARSET latin1  BEGIN
	DECLARE len INT;
	DECLARE i INT;

	SET len   = CHAR_LENGTH(input);
	SET input = LOWER(input);
	SET i = 0;

	WHILE (i < len) DO
		IF (MID(input,i,1) = ' ' OR i = 0) THEN
			IF (i < len) THEN
				SET input = CONCAT(
					LEFT(input,i),
					UPPER(MID(input,i + 1,1)),
					RIGHT(input,len - i - 1)
				);
			END IF;
		END IF;
		SET i = i + 1;
	END WHILE;

	RETURN input;
END$$

CREATE DEFINER=`kashi`@`localhost` FUNCTION `ktc_chart` (`action_p` VARCHAR(50), `user_p` INT, `co_p` INT) RETURNS VARCHAR(200) CHARSET utf8 NO SQL BEGIN
 

SET @cc = '0';
 if(action_p = 'form') THEN
 SELECT count(id) into @cc from ktc_link ;
 elseif(action_p = 'element') THEN
 SELECT count(id) into @cc from ktc_parameter ;
 elseif(action_p = 'procedure') THEN
 SELECT count(ROUTINE_TYPE) into @cc from information_schema.ROUTINES WHERE ROUTINE_SCHEMA = DATABASE() and ROUTINE_TYPE = 'PROCEDURE' ;
 elseif(action_p = 'table') THEN
 SELECT count(TABLE_SCHEMA) into @cc from information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() ;

 elseif(action_p = 'hospital') THEN
 SELECT count(id) into @cc from hospital ;
 elseif(action_p = 'doctor') THEN
 SELECT count(id) into @cc from doctor ;
 elseif(action_p = 'patient') THEN
 SELECT count(id) into @cc from patient ;
 elseif(action_p = 'department') THEN
 SELECT count(id) into @cc from department ;
 elseif(action_p = 'ticket') THEN
 SELECT count(id) into @cc from ticket ;
 
end if;
 RETURN @cc;
 
 END$$

CREATE DEFINER=`kashi`@`localhost` FUNCTION `ktc_check_2fa` (`_user_id` INT, `_user_level` VARCHAR(50)) RETURNS INT(11) NO SQL BEGIN

if(_user_level = 't' or _user_level = 't') THEN

SELECT e.is_enable_2fa into @2fa from hr_employee e where auto_id = _user_id;

ELSE

SELECT e.is_enable_2fa into @2fa from ktc_user e where auto_id = _user_id;


END IF;

RETURN @2fa;

END$$

CREATE DEFINER=`kashi`@`localhost` FUNCTION `ktc_company` (`_company_id` INT) RETURNS VARCHAR(100) CHARSET utf8 NO SQL BEGIN

SELECT name into @name_co from company where id = _company_id;

RETURN @name_co;

END$$

CREATE DEFINER=`kashi`@`localhost` FUNCTION `ktc_del` (`id_p` VARCHAR(200), `table_p` VARCHAR(50), `col_p` VARCHAR(200), `user_p` INT, `co_p` INT) RETURNS TEXT CHARSET utf8 NO SQL BEGIN
if not EXISTS (SELECT id from ktc_dropdown where `value` = table_p and `action` = 'delete') THEN
INSERT into ktc_dropdown (`value`,`text`, `action`) VALUE (table_p,CONCAT('Delete ',table_p),'delete');
SET @l = LAST_INSERT_ID();
INSERT INTO `ktc_user_permission`( `link_id`, `user_id`, `granted_user_id`, `action`, `company_id`, `date`) VALUES (@l,user_p,user_p,'delete', co_p, date(now()));
end if;

if(user_p = 0) THEN
RETURN CONCAT('<i class="fa fa-trash ktc-delete btn" alt="',table_p,'" id="',id_p,'" column="',col_p,'""><i>');

elseif EXISTS(SELECT p.user_id FROM ktc_user_permission p join ktc_dropdown d on d.id=p.link_id WHERE p.action = 'delete' and p.user_id = user_p and d.value = table_p and p.company_id = co_p) THEN
RETURN CONCAT('<i class="fa fa-trash ktc-delete btn" alt="',table_p,'" id="',id_p,'" column="',col_p,'""><i>');
ELSE

RETURN 'XX';

end if;
END$$

CREATE DEFINER=`kashi`@`localhost` FUNCTION `ktc_domain` (`_company_id` INT) RETURNS VARCHAR(100) CHARSET utf8 NO SQL BEGIN

SELECT concat('https://',ktc_split(domain,',',1)) into @domain from company where id = _company_id;

RETURN @domain;

END$$

CREATE DEFINER=`kashi`@`localhost` FUNCTION `ktc_edit` (`id_p` VARCHAR(50), `table_p` VARCHAR(50), `col_p` VARCHAR(50), `action_p` VARCHAR(50), `user_p` INT, `co_p` INT) RETURNS VARCHAR(250) CHARSET utf8 NO SQL BEGIN

if not EXISTS (SELECT id from ktc_dropdown where `value` = table_p and `action` = 'edit') THEN
INSERT into ktc_dropdown (`value`,`text`, `action`) VALUE (table_p,CONCAT('Edit ',table_p),'edit');
SET @l = LAST_INSERT_ID();
INSERT INTO `ktc_user_permission`( `link_id`, `user_id`, `granted_user_id`, `action`, `company_id`, `date`) VALUES (@l,user_p,user_p,'edit', co_p, date(now()));
end if;

if(user_p = 0) then 
RETURN CONCAT('<i class="fa fa-edit ktc-update btn" t="',table_p,'" id="',id_p,'" c="',col_p,'" a="',action_p,'""><i>');

elseif EXISTS(SELECT p.user_id FROM ktc_user_permission p join ktc_dropdown d on d.id=p.link_id WHERE p.action = 'edit' and p.user_id = user_p and d.value = table_p and p.company_id = co_p) THEN

RETURN CONCAT('<i class="fa fa-edit ktc-update btn" t="',table_p,'" id="',id_p,'" c="',col_p,'" a="',action_p,'""><i>');

ELSE

RETURN 'XX';

end if;



END$$

CREATE DEFINER=`kashi`@`localhost` FUNCTION `ktc_edit2` (`id_p` VARCHAR(50), `table_p` VARCHAR(50), `col_p` VARCHAR(50), `user_p` INT, `co_p` INT) RETURNS VARCHAR(250) CHARSET utf8 NO SQL BEGIN

if not EXISTS (SELECT id from ktc_dropdown where `value` = table_p and `action` = 'edit') THEN
INSERT into ktc_dropdown (`value`,`text`, `action`) VALUE (table_p,CONCAT('Edit ',table_p),'edit');
SET @l = LAST_INSERT_ID();
INSERT INTO `ktc_user_permission`( `link_id`, `user_id`, `granted_user_id`, `action`, `company_id`, `date`) VALUES (@l,user_p,user_p,'edit', co_p, date(now()));
end if;

if(user_p = 0) then 
RETURN CONCAT('<i class="fa fa-edit ktc-update btn" t="',table_p,'" id="',id_p,'" c="',col_p,'" a="',table_p,'|""><i>');

elseif EXISTS(SELECT p.user_id FROM ktc_user_permission p join ktc_dropdown d on d.id=p.link_id WHERE p.action = 'edit' and p.user_id = user_p and d.value = table_p and p.company_id = co_p) THEN

RETURN CONCAT('<i class="fa fa-edit ktc-update btn" t="',table_p,'" id="',id_p,'" c="',col_p,'" a="',table_p,'|""><i>');

ELSE

RETURN 'XX';

end if;



END$$

CREATE DEFINER=`kashi`@`localhost` FUNCTION `ktc_extract_number` (`in_string` VARCHAR(50)) RETURNS INT(11) NO SQL BEGIN
    DECLARE ctrNumber VARCHAR(50);
    DECLARE finNumber VARCHAR(50) DEFAULT '';
    DECLARE sChar VARCHAR(1);
    DECLARE inti INTEGER DEFAULT 1;

    IF LENGTH(in_string) > 0 THEN
        WHILE(inti <= LENGTH(in_string)) DO
            SET sChar = SUBSTRING(in_string, inti, 1);
            SET ctrNumber = FIND_IN_SET(sChar, '0,1,2,3,4,5,6,7,8,9'); 
            IF ctrNumber > 0 THEN
                SET finNumber = CONCAT(finNumber, sChar);
            END IF;
            SET inti = inti + 1;
        END WHILE;
        RETURN CAST(finNumber AS UNSIGNED);
    ELSE
        RETURN 0;
    END IF;    
END$$

CREATE DEFINER=`kashi`@`localhost` FUNCTION `ktc_general` (`id_p` INT, `co_p` INT) RETURNS VARCHAR(100) CHARSET utf8 NO SQL BEGIN
SET @name='Unknown';
SELECT name into @name FROM general where auto_id=id_p and company_id=co_p;

RETURN @name;

END$$

CREATE DEFINER=`kashi`@`localhost` FUNCTION `ktc_label` (`_param` VARCHAR(50), `_action` VARCHAR(50)) RETURNS VARCHAR(50) CHARSET utf8 NO SQL COMMENT 'cp common parameter' BEGIN

SELECT (CASE WHEN _action = 'label' and label != 'default_label' THEN label WHEN _action = 'type' THEN type WHEN _action = 'action' THEN action WHEN _action = 'class' THEN class WHEN _action = 'load' THEN `load_action` end) into @label FROM ktc_common_param WHERE parameter like CONCAT('%',_param,'%') limit 1;

if(_action = 'type' AND @label is null) THEN

SELECT type into @label from ktc_common_param where _param like CONCAT('%',parameter,'%') and label = 'default_label' limit 1;

end if;

RETURN ifnull(@label,'');


END$$

CREATE DEFINER=`kashi`@`localhost` FUNCTION `ktc_link` (`_href` TEXT, `_text` VARCHAR(50)) RETURNS TEXT CHARSET utf8 NO SQL BEGIN

RETURN CONCAT('<a href="#" alt="',_href,'" class="ktc-link" id="">',_text,'</a>');

END$$

CREATE DEFINER=`kashi`@`localhost` FUNCTION `ktc_n2w` (`n` INT) RETURNS VARCHAR(100) CHARSET utf8  BEGIN
    -- This function returns the string representation of a number.
    -- It's just an example... I'll restrict it to hundreds, but
    -- it can be extended easily.
    -- The idea is:
    --      For each digit you need a position,
    --      For each position, you assign a string
    declare ans varchar(100);
    declare dig1, dig2, dig3, dig4, dig5, dig6 int;

set ans = '';

set dig6 = CAST(RIGHT(CAST(floor(n / 100000) as CHAR(8)), 1) as SIGNED);
set dig5 = CAST(RIGHT(CAST(floor(n / 10000) as CHAR(8)), 1) as SIGNED);
set dig4 = CAST(RIGHT(CAST(floor(n / 1000) as CHAR(8)), 1) as SIGNED);
set dig3 = CAST(RIGHT(CAST(floor(n / 100) as CHAR(8)), 1) as SIGNED);
set dig2 = CAST(RIGHT(CAST(floor(n / 10) as CHAR(8)), 1) as SIGNED);
set dig1 = CAST(RIGHT(floor(n), 1) as SIGNED);

if dig6 > 0 then
    case
        when dig6=1 then set ans=concat(ans, 'one hundred');
        when dig6=2 then set ans=concat(ans, 'two hundred');
        when dig6=3 then set ans=concat(ans, 'three hundred');
        when dig6=4 then set ans=concat(ans, 'four hundred');
        when dig6=5 then set ans=concat(ans, 'five hundred');
        when dig6=6 then set ans=concat(ans, 'six hundred');
        when dig6=7 then set ans=concat(ans, 'seven hundred');
        when dig6=8 then set ans=concat(ans, 'eight hundred');
        when dig6=9 then set ans=concat(ans, 'nine hundred');
        else set ans = ans;
    end case;
end if;

if dig5 = 1 then
    case
        when (dig5*10 + dig4) = 10 then set ans=concat(ans, ' ten thousand ');
        when (dig5*10 + dig4) = 11 then set ans=concat(ans, ' eleven thousand ');
        when (dig5*10 + dig4) = 12 then set ans=concat(ans, ' twelve thousand ');
        when (dig5*10 + dig4) = 13 then set ans=concat(ans, ' thirteen thousand ');
        when (dig5*10 + dig4) = 14 then set ans=concat(ans, ' fourteen thousand ');
        when (dig5*10 + dig4) = 15 then set ans=concat(ans, ' fifteen thousand ');
        when (dig5*10 + dig4) = 16 then set ans=concat(ans, ' sixteen thousand ');
        when (dig5*10 + dig4) = 17 then set ans=concat(ans, ' seventeen thousand ');
        when (dig5*10 + dig4) = 18 then set ans=concat(ans, ' eighteen thousand ');
        when (dig5*10 + dig4) = 19 then set ans=concat(ans, ' nineteen thousand ');
        else set ans=ans;
    end case;
else
    if dig5 > 0 then
        case
            when dig5=2 then set ans=concat(ans, ' twenty');
            when dig5=3 then set ans=concat(ans, ' thirty');
            when dig5=4 then set ans=concat(ans, ' fourty');
            when dig5=5 then set ans=concat(ans, ' fifty');
            when dig5=6 then set ans=concat(ans, ' sixty');
            when dig5=7 then set ans=concat(ans, ' seventy');
            when dig5=8 then set ans=concat(ans, ' eighty');
            when dig5=9 then set ans=concat(ans, ' ninety');
            else set ans=ans;
        end case;
    end if;
    if dig4 > 0 then
        case
            when dig4=1 then set ans=concat(ans, ' thousand ');
            when dig4=2 then set ans=concat(ans, ' two thousand ');
            when dig4=3 then set ans=concat(ans, ' three thousand ');
            when dig4=4 then set ans=concat(ans, ' four thousand ');
            when dig4=5 then set ans=concat(ans, ' five thousand ');
            when dig4=6 then set ans=concat(ans, ' six thousand ');
            when dig4=7 then set ans=concat(ans, ' seven thousand ');
            when dig4=8 then set ans=concat(ans, ' eight thousand ');
            when dig4=9 then set ans=concat(ans, ' nine thousand ');
            else set ans=ans;
        end case;
    end if;
    if dig4 = 0 AND (dig5 != 0 || dig6 != 0) then
        set ans=concat(ans, ' kun ');
    end if;
end if;

if dig3 > 0 then
    case
        when dig3=1 then set ans=concat(ans, 'hundred');
        when dig3=2 then set ans=concat(ans, 'two hundred');
        when dig3=3 then set ans=concat(ans, 'three hundred');
        when dig3=4 then set ans=concat(ans, 'four hundred');
        when dig3=5 then set ans=concat(ans, 'five hundred');
        when dig3=6 then set ans=concat(ans, 'six hundred');
        when dig3=7 then set ans=concat(ans, 'seven hundred');
        when dig3=8 then set ans=concat(ans, 'eight hundred');
        when dig3=9 then set ans=concat(ans, 'nine hundred');
        else set ans = ans;
    end case;
end if;

if dig2 = 1 then
    case
        when (dig2*10 + dig1) = 10 then set ans=concat(ans, ' ten');
        when (dig2*10 + dig1) = 11 then set ans=concat(ans, ' eleven');
        when (dig2*10 + dig1) = 12 then set ans=concat(ans, ' twelve');
        when (dig2*10 + dig1) = 13 then set ans=concat(ans, ' thirteen');
        when (dig2*10 + dig1) = 14 then set ans=concat(ans, ' fourteen');
        when (dig2*10 + dig1) = 15 then set ans=concat(ans, ' fifteen');
        when (dig2*10 + dig1) = 16 then set ans=concat(ans, ' sixteen');
        when (dig2*10 + dig1) = 17 then set ans=concat(ans, ' seventeen');
        when (dig2*10 + dig1) = 18 then set ans=concat(ans, ' eighteen');
        when (dig2*10 + dig1) = 19 then set ans=concat(ans, ' ninteen');
        else set ans=ans;
    end case;
else
    if dig2 > 0 then
        case
            when dig2=2 then set ans=concat(ans, ' twenty');
            when dig2=3 then set ans=concat(ans, ' thity');
            when dig2=4 then set ans=concat(ans, ' fourty');
            when dig2=5 then set ans=concat(ans, ' fifty');
            when dig2=6 then set ans=concat(ans, ' sixty');
            when dig2=7 then set ans=concat(ans, ' seventy');
            when dig2=8 then set ans=concat(ans, ' eighty');
            when dig2=9 then set ans=concat(ans, ' ninety');
            else set ans=ans;
        end case;
    end if;
    if dig1 > 0 then
        case
            when dig1=1 then set ans=concat(ans, ' one');
            when dig1=2 then set ans=concat(ans, ' two');
            when dig1=3 then set ans=concat(ans, ' three');
            when dig1=4 then set ans=concat(ans, ' four');
            when dig1=5 then set ans=concat(ans, ' five');
            when dig1=6 then set ans=concat(ans, ' six');
            when dig1=7 then set ans=concat(ans, ' seven');
            when dig1=8 then set ans=concat(ans, ' eight');
            when dig1=9 then set ans=concat(ans, ' nine');
            else set ans=ans;
        end case;
    end if;
end if;

return trim(ans);
END$$

CREATE DEFINER=`kashi`@`localhost` FUNCTION `ktc_param` (`sp_p` VARCHAR(50)) RETURNS INT(11) NO SQL BEGIN


SELECT count(PARAMETER_NAME) into @count_param FROM information_schema.`PARAMETERS` WHERE `SPECIFIC_SCHEMA` = database() and SPECIFIC_NAME = sp_p ;

RETURN  @count_param;

END$$

CREATE DEFINER=`kashi`@`localhost` FUNCTION `ktc_print` (`id_p` VARCHAR(250), `action_p` VARCHAR(250), `co_p` INT) RETURNS TEXT CHARSET utf8 NO SQL BEGIN
SELECT ktc_split(domain,',',1) into @domain from company WHERE id = co_p;

RETURN CONCAT('<a href="https://',@domain,'/forms/invoice/',id_p,'/',action_p,'/',co_p,'" class="btn btn-primary btn-sm ktc-print_invoice"  target="_blank"><i class="fa fa-print"></i> Print</a>');


END$$

CREATE DEFINER=`kashi`@`localhost` FUNCTION `ktc_split` (`x` VARCHAR(255), `delim` VARCHAR(12), `pos` INT) RETURNS VARCHAR(255) CHARSET latin1  RETURN REPLACE(SUBSTRING(SUBSTRING_INDEX(x, delim, pos),
       LENGTH(SUBSTRING_INDEX(x, delim, pos -1)) + 1),
       delim, '')$$

CREATE DEFINER=`kashi`@`localhost` FUNCTION `ktc_tick` () RETURNS VARCHAR(200) CHARSET utf8 NO SQL RETURN  '<button alt="check" class="fa fa-remove  ktc-tick"></button>'$$

CREATE DEFINER=`kashi`@`localhost` FUNCTION `ktc_tick2` () RETURNS VARCHAR(200) CHARSET utf8 NO SQL RETURN  '<button alt="remove" class="fa fa-check ktc-tick"></button>'$$

CREATE DEFINER=`kashi`@`localhost` FUNCTION `ktc_translate` (`_company_id` INT, `_table_auto_id` INT, `_table` VARCHAR(50), `_language` VARCHAR(50), `_default` VARCHAR(250)) RETURNS VARCHAR(250) CHARSET utf8 NO SQL BEGIN
SET @translated = '';
if(_language = 'EN' or _language = '%') THEN 

SET @translated = _default;

ELSE


SELECT translated into @translated from ktc_languages l where l.table_auto_id = _table_auto_id and `table_name` = _table and l.language = _language;

END IF;

RETURN @translated;

END$$

CREATE DEFINER=`kashi`@`localhost` FUNCTION `ktc_user` (`id_p` INT, `action_p` VARCHAR(50), `co_p` INT) RETURNS VARCHAR(50) CHARSET utf8 NO SQL BEGIN
SET @user = '';
if(action_p='teacher' or action_p='t') THEN
SELECT name into @user  from hr_employee where auto_id=id_p and company_id=co_p;
elseif(action_p='teacher_id' or action_p='t_id') THEN
SELECT lpad(auto_id,4,0) into @user  from hr_employee where auto_id=id_p and company_id=co_p;

else
SELECT username into @user from ktc_user where auto_id = id_p and company_id=co_p;
end if;
RETURN @user;

END$$

CREATE DEFINER=`kashi`@`localhost` FUNCTION `ktc_wa` (`_msg` TEXT, `_tell` VARCHAR(50), `_device` VARCHAR(250)) RETURNS TEXT CHARSET utf8 NO SQL BEGIN
SET _tell = if(char_length(_tell) > 10, _tell, concat('252',right(_tell,9)));
RETURN concat('<a href="',if(_device = 'computer', concat('https://wa.me/',_tell,'/?text=',_msg,''), concat('whatsapp://send?text=',_msg,'&phone=',_tell)),'">',if(_device ='icon','<i class="fa fa-whatsapp fa-lg"></i>',_tell),'</a>');
 
END$$

CREATE DEFINER=`kashi`@`localhost` FUNCTION `now2` () RETURNS DATETIME NO SQL RETURN utc_timestamp() + INTERVAL 3 HOUR$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `agent`
--

CREATE TABLE `agent` (
  `id` int(11) NOT NULL,
  `auto_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `tell` int(11) NOT NULL,
  `address` varchar(100) NOT NULL,
  `gender` varchar(100) NOT NULL,
  `password` int(11) NOT NULL,
  `image` varchar(250) NOT NULL DEFAULT '',
  `short_link` varchar(100) NOT NULL,
  `user_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `agent`
--

INSERT INTO `agent` (`id`, `auto_id`, `company_id`, `name`, `tell`, `address`, `gender`, `password`, `image`, `short_link`, `user_id`, `date`, `action_date`, `modified_date`) VALUES
(2, 1, 1, 'Abdihamid Hussein Gedi', 615190777, 'Ankara Turkey', 'Lab', 2580, '', 'https://bit.ly/3ILK0Pg', 0, '2023-01-23', '2023-01-24 05:31:32', '2023-01-24 05:31:32'),
(3, 2, 1, 'Iqra Hassan Mohamud', 616998778, 'Ankara Turkey', 'Dhedig', 2580, '', 'https://bit.ly/3XWqxzM', 0, '2023-01-26', '2023-01-26 06:16:59', '2023-01-26 06:16:59'),
(4, 3, 1, 'mustsfa jamac', 633195838, 'burco', 'Lab', 1234567, '', 'https://bit.ly/3L4QREy', 0, '2023-03-07', '2023-03-07 15:17:36', '2023-03-07 15:17:36'),
(5, 4, 1, 'Maxamed axmef', 659328877, 'Burco', 'Lab', 1234568, '', 'https://bit.ly/3l0S3ht', 0, '2023-03-08', '2023-03-08 08:03:18', '2023-03-08 08:03:18'),
(6, 5, 1, 'Nimcale mahad', 634097433, '0634097433', 'Lab', 1234569, '', 'https://bit.ly/3ZQmeXu', 0, '2023-03-08', '2023-03-08 09:28:12', '2023-03-08 09:28:12');

-- --------------------------------------------------------

--
-- Table structure for table `app_click`
--

CREATE TABLE `app_click` (
  `id` int(11) NOT NULL,
  `visitor_id` int(11) NOT NULL,
  `_id` int(11) NOT NULL COMMENT 'hospital, doctor and so on',
  `action` varchar(50) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `app_click`
--

INSERT INTO `app_click` (`id`, `visitor_id`, `_id`, `action`, `date`) VALUES
(1, 7, 15, '0', '2023-01-07 04:14:59'),
(2, 7, 118, 'hospital', '2023-01-07 04:15:34'),
(3, 7, 15, 'hospital', '2023-01-07 04:16:29'),
(4, 7, 9, 'doctor', '2023-01-07 04:16:31'),
(5, 7, 10, 'doctor', '2023-01-07 04:16:43'),
(6, 2, 35, 'hospital', '2023-01-07 06:00:23'),
(7, 2, 39, 'hospital', '2023-01-07 06:01:21'),
(8, 2, 95, 'hospital', '2023-01-07 06:01:54'),
(9, 2, 167, 'hospital', '2023-01-07 06:02:11'),
(10, 2, 167, 'hospital', '2023-01-07 06:02:49'),
(11, 2, 15, 'hospital', '2023-01-07 06:03:02'),
(12, 2, 176, 'hospital', '2023-01-07 06:03:41'),
(13, 2, 46, 'doctor', '2023-01-07 06:04:31'),
(14, 2, 17, 'hospital', '2023-01-07 06:08:31'),
(15, 2, 160, 'hospital', '2023-01-07 06:08:45'),
(16, 2, 161, 'hospital', '2023-01-07 06:09:25'),
(17, 2, 174, 'hospital', '2023-01-07 06:10:00'),
(18, 2, 167, 'hospital', '2023-01-07 06:10:27'),
(19, 2, 167, 'hospital', '2023-01-07 06:10:41'),
(20, 2, 49, 'doctor', '2023-01-07 08:10:22'),
(21, 2, 100, 'hospital', '2023-01-07 08:13:47'),
(22, 2, 58, 'hospital', '2023-01-07 08:13:50'),
(23, 2, 150, 'hospital', '2023-01-07 08:14:04'),
(24, 2, 12, 'doctor', '2023-01-07 08:14:15'),
(25, 2, 17, 'doctor', '2023-01-07 08:14:24'),
(26, 2, 21, 'doctor', '2023-01-07 08:14:29'),
(27, 2, 24, 'doctor', '2023-01-07 08:15:33'),
(28, 2, 14, 'doctor', '2023-01-07 08:15:43'),
(29, 2, 36, 'hospital', '2023-01-07 08:15:51'),
(30, 2, 49, 'doctor', '2023-01-07 08:16:13'),
(31, 2, 50, 'doctor', '2023-01-07 08:16:19'),
(32, 2, 68, 'doctor', '2023-01-07 08:33:07'),
(33, 2, 69, 'doctor', '2023-01-07 08:33:14'),
(34, 2, 176, 'hospital', '2023-01-07 10:23:07'),
(35, 2, 46, 'doctor', '2023-01-07 10:23:13'),
(36, 2, 53, 'hospital', '2023-01-07 10:34:51'),
(37, 2, 15, 'hospital', '2023-01-07 10:37:39'),
(38, 2, 15, 'hospital', '2023-01-07 10:39:11'),
(39, 2, 11, 'doctor', '2023-01-07 10:39:46'),
(40, 2, 53, 'hospital', '2023-01-07 15:20:35'),
(41, 2, 50, 'hospital', '2023-01-07 15:20:35'),
(42, 2, 118, 'hospital', '2023-01-07 15:20:51'),
(43, 7, 176, 'hospital', '2023-01-07 15:48:06'),
(44, 7, 46, 'doctor', '2023-01-07 15:48:14'),
(45, 7, 15, 'hospital', '2023-01-07 15:52:14'),
(46, 7, 9, 'doctor', '2023-01-07 15:52:16'),
(47, 5, 92, 'hospital', '2023-01-07 15:53:27'),
(48, 9, 15, 'hospital', '2023-01-07 17:59:55'),
(49, 9, 35, 'hospital', '2023-01-07 18:00:00'),
(50, 9, 157, 'hospital', '2023-01-07 18:04:53'),
(51, 9, 56, 'doctor', '2023-01-07 20:04:46'),
(52, 9, 21, 'doctor', '2023-01-07 22:34:40'),
(53, 2, 15, 'hospital', '2023-01-08 16:10:48'),
(54, 3, 15, 'hospital', '2023-01-08 16:47:24'),
(55, 3, 15, 'hospital', '2023-01-08 16:47:35'),
(56, 3, 15, 'hospital', '2023-01-08 16:50:46'),
(57, 3, 35, 'hospital', '2023-01-09 03:39:16'),
(58, 3, 35, 'hospital', '2023-01-09 03:39:24'),
(59, 9, 150, 'hospital', '2023-01-09 03:39:44'),
(60, 9, 25, 'doctor', '2023-01-09 03:39:53'),
(61, 9, 35, 'hospital', '2023-01-09 03:40:23'),
(62, 9, 5, 'doctor', '2023-01-09 03:40:30'),
(63, 9, 152, 'hospital', '2023-01-09 03:40:48'),
(64, 9, 35, 'hospital', '2023-01-09 03:40:57'),
(65, 9, 35, 'hospital', '2023-01-09 03:41:13'),
(66, 9, 5, 'doctor', '2023-01-09 03:41:24'),
(67, 9, 5, 'doctor', '2023-01-09 03:41:33'),
(68, 9, 35, 'hospital', '2023-01-09 03:41:41'),
(69, 9, 150, 'hospital', '2023-01-09 03:42:18'),
(70, 9, 25, 'doctor', '2023-01-09 03:42:24'),
(71, 9, 62, 'doctor', '2023-01-09 03:44:34'),
(72, 9, 35, 'hospital', '2023-01-09 03:44:51'),
(73, 9, 62, 'doctor', '2023-01-09 03:45:01'),
(74, 9, 35, 'hospital', '2023-01-09 03:45:12'),
(75, 12, 161, 'hospital', '2023-01-10 07:36:53'),
(76, 12, 76, 'doctor', '2023-01-10 07:38:47'),
(77, 12, 161, 'hospital', '2023-01-10 17:28:37'),
(78, 12, 76, 'doctor', '2023-01-10 17:29:06'),
(79, 12, 15, 'hospital', '2023-01-11 09:38:51'),
(80, 12, 10, 'doctor', '2023-01-11 09:39:00'),
(81, 12, 161, 'hospital', '2023-01-13 06:55:57'),
(82, 12, 76, 'doctor', '2023-01-13 06:56:38'),
(83, 12, 119, 'hospital', '2023-01-13 07:01:14'),
(84, 12, 134, 'hospital', '2023-01-13 07:01:48'),
(85, 12, 150, 'hospital', '2023-01-13 07:02:11'),
(86, 12, 20, 'doctor', '2023-01-13 07:02:29'),
(87, 12, 103, 'hospital', '2023-01-13 07:04:27'),
(88, 12, 77, 'hospital', '2023-01-13 07:04:33'),
(89, 12, 19, 'hospital', '2023-01-13 07:04:39'),
(90, 12, 11, 'hospital', '2023-01-13 07:04:50'),
(91, 12, 30, 'hospital', '2023-01-13 07:04:57'),
(92, 12, 93, 'hospital', '2023-01-13 07:05:03'),
(93, 12, 176, 'hospital', '2023-01-13 07:05:13'),
(94, 12, 50, 'doctor', '2023-01-13 07:05:47'),
(95, 12, 50, 'hospital', '2023-01-13 10:34:36'),
(96, 12, 10, 'hospital', '2023-01-13 10:34:59'),
(97, 12, 92, 'hospital', '2023-01-13 10:35:14'),
(98, 12, 36, 'hospital', '2023-01-13 10:35:36'),
(99, 13, 61, 'hospital', '2023-01-13 17:23:24'),
(100, 13, 63, 'doctor', '2023-01-13 17:23:57'),
(101, 3, 25, 'hospital', '2023-01-13 18:30:29'),
(102, 3, 15, 'hospital', '2023-01-13 18:30:29'),
(103, 3, 25, 'hospital', '2023-01-13 18:30:38'),
(104, 3, 50, 'hospital', '2023-01-13 18:30:38'),
(105, 14, 15, 'hospital', '2023-01-13 18:30:57'),
(106, 14, 35, 'hospital', '2023-01-13 18:31:17'),
(107, 14, 59, 'hospital', '2023-01-13 18:31:29'),
(108, 14, 54, 'hospital', '2023-01-13 18:31:37'),
(109, 13, 118, 'hospital', '2023-01-14 09:42:02'),
(110, 14, 161, 'hospital', '2023-01-15 22:16:25'),
(111, 14, 76, 'doctor', '2023-01-15 22:16:33'),
(112, 14, 15, 'hospital', '2023-01-16 09:54:11'),
(113, 14, 10, 'doctor', '2023-01-16 09:54:21'),
(114, 14, 10, 'doctor', '2023-01-16 09:55:09'),
(115, 14, 10, 'doctor', '2023-01-16 09:55:18'),
(116, 14, 10, 'doctor', '2023-01-16 09:55:18'),
(117, 14, 10, 'doctor', '2023-01-16 09:55:18'),
(118, 14, 35, 'hospital', '2023-01-16 09:55:25'),
(119, 14, 15, 'hospital', '2023-01-16 09:55:31'),
(120, 14, 10, 'doctor', '2023-01-16 09:55:34'),
(121, 14, 35, 'hospital', '2023-01-16 09:57:19'),
(122, 14, 25, 'hospital', '2023-01-16 09:58:00'),
(123, 14, 118, 'hospital', '2023-01-16 15:21:32'),
(124, 14, 161, 'hospital', '2023-01-16 15:21:52'),
(125, 14, 76, 'doctor', '2023-01-16 15:22:00'),
(126, 15, 31, 'hospital', '2023-01-16 16:39:12'),
(127, 14, 161, 'hospital', '2023-01-16 18:18:38'),
(128, 14, 161, 'hospital', '2023-01-16 18:18:41'),
(129, 14, 76, 'doctor', '2023-01-16 18:18:49'),
(130, 14, 161, 'hospital', '2023-01-16 19:25:55'),
(131, 14, 178, 'hospital', '2023-01-16 19:32:51'),
(132, 14, 25, 'hospital', '2023-01-17 12:00:30'),
(133, 14, 77, 'doctor', '2023-01-17 12:00:40'),
(134, 14, 10, 'hospital', '2023-01-22 08:31:00'),
(135, 14, 66, 'hospital', '2023-01-22 08:31:32'),
(136, 14, 161, 'hospital', '2023-01-22 08:33:02'),
(137, 14, 76, 'doctor', '2023-01-22 08:33:06'),
(138, 3, 25, 'hospital', '2023-01-23 13:11:12'),
(139, 3, 82, 'hospital', '2023-01-25 03:34:48'),
(140, 3, 25, 'hospital', '2023-01-25 03:35:17'),
(141, 9, 55, 'doctor', '2023-01-26 06:50:58'),
(142, 9, 15, 'hospital', '2023-01-26 06:51:05'),
(143, 9, 10, 'doctor', '2023-01-26 06:51:14'),
(144, 9, 15, 'hospital', '2023-01-26 13:55:54'),
(145, 3, 50, 'hospital', '2023-01-27 04:03:51'),
(146, 3, 53, 'hospital', '2023-01-27 04:03:54'),
(147, 9, 53, 'hospital', '2023-01-27 04:06:03'),
(148, 9, 5, 'doctor', '2023-01-27 21:24:01'),
(149, 9, 15, 'hospital', '2023-01-27 21:25:29'),
(150, 9, 10, 'doctor', '2023-01-27 21:25:31'),
(151, 7, 15, 'hospital', '2023-01-28 03:29:24'),
(152, 7, 10, 'doctor', '2023-01-28 03:29:28'),
(153, 19, 161, 'hospital', '2023-01-30 06:42:48'),
(154, 19, 160, 'hospital', '2023-01-30 06:43:18'),
(155, 19, 120, 'hospital', '2023-01-30 06:43:40'),
(156, 19, 117, 'hospital', '2023-01-30 06:43:47'),
(157, 19, 21, 'hospital', '2023-01-30 06:43:55'),
(158, 19, 42, 'hospital', '2023-01-30 06:44:07'),
(159, 19, 177, 'hospital', '2023-01-30 06:44:21'),
(160, 19, 176, 'hospital', '2023-01-30 06:44:31'),
(161, 19, 46, 'doctor', '2023-01-30 06:44:42'),
(162, 19, 49, 'doctor', '2023-01-30 06:46:29'),
(163, 9, 52, 'hospital', '2023-02-08 06:45:00'),
(164, 9, 3, 'doctor', '2023-02-13 01:37:56'),
(165, 9, 25, 'hospital', '2023-02-13 01:39:51'),
(166, 3, 82, 'hospital', '2023-02-13 05:03:11'),
(167, 3, 35, 'hospital', '2023-02-13 05:03:14'),
(168, 3, 157, 'hospital', '2023-02-13 05:04:43'),
(169, 3, 157, 'hospital', '2023-02-13 05:05:01'),
(170, 3, 25, 'hospital', '2023-02-13 05:05:33'),
(171, 3, 50, 'hospital', '2023-02-13 05:06:04'),
(172, 23, 36, 'hospital', '2023-02-13 08:04:50'),
(173, 23, 71, 'doctor', '2023-02-13 08:04:55'),
(174, 2, 161, 'hospital', '2023-02-18 15:39:39'),
(175, 2, 160, 'hospital', '2023-02-18 15:41:47'),
(176, 2, 176, 'hospital', '2023-02-18 15:41:58'),
(177, 2, 161, 'hospital', '2023-02-18 15:54:43'),
(178, 2, 160, 'hospital', '2023-02-18 17:19:10'),
(179, 2, 161, 'hospital', '2023-02-19 05:01:53'),
(180, 2, 161, 'hospital', '2023-02-19 05:01:55'),
(181, 2, 161, 'hospital', '2023-02-19 05:01:55'),
(182, 2, 161, 'hospital', '2023-02-19 05:01:57'),
(183, 2, 161, 'hospital', '2023-02-19 05:01:57'),
(184, 2, 161, 'hospital', '2023-02-19 05:01:57'),
(185, 2, 161, 'hospital', '2023-02-19 05:01:57'),
(186, 2, 161, 'hospital', '2023-02-19 05:01:58'),
(187, 2, 178, 'hospital', '2023-02-19 05:01:59'),
(188, 2, 178, 'hospital', '2023-02-19 05:01:59'),
(189, 2, 178, 'hospital', '2023-02-19 05:02:00'),
(190, 2, 178, 'hospital', '2023-02-19 05:02:01'),
(191, 2, 178, 'hospital', '2023-02-19 05:02:02'),
(192, 2, 178, 'hospital', '2023-02-19 05:02:02'),
(193, 2, 177, 'hospital', '2023-02-19 05:02:07'),
(194, 2, 147, 'hospital', '2023-02-19 11:38:45'),
(195, 9, 5, 'doctor', '2023-02-19 11:41:40'),
(196, 2, 39, 'hospital', '2023-02-19 11:45:21'),
(197, 2, 39, 'hospital', '2023-02-19 11:45:29'),
(198, 2, 87, 'hospital', '2023-02-19 11:45:34'),
(199, 2, 87, 'hospital', '2023-02-19 11:45:40'),
(200, 2, 53, 'hospital', '2023-02-19 11:45:41'),
(201, 2, 82, 'hospital', '2023-02-19 11:45:46'),
(202, 2, 150, 'hospital', '2023-02-19 11:45:52'),
(203, 2, 61, 'hospital', '2023-02-19 11:45:55'),
(204, 2, 14, 'hospital', '2023-02-19 11:45:59'),
(205, 2, 174, 'hospital', '2023-02-19 11:46:02'),
(206, 2, 161, 'hospital', '2023-02-19 12:30:29'),
(207, 2, 12, 'hospital', '2023-02-19 13:37:33'),
(208, 2, 100, 'hospital', '2023-02-19 13:37:35'),
(209, 2, 61, 'hospital', '2023-02-19 13:37:40'),
(210, 2, 1, 'hospital', '2023-02-19 13:37:43'),
(211, 2, 42, 'hospital', '2023-02-19 13:37:53'),
(212, 2, 176, 'hospital', '2023-02-19 13:38:19'),
(213, 2, 110, 'hospital', '2023-02-19 13:38:29'),
(214, 2, 50, 'hospital', '2023-02-19 17:57:21'),
(215, 2, 161, 'hospital', '2023-02-20 13:29:20'),
(216, 25, 161, 'hospital', '2023-03-11 08:32:45'),
(217, 25, 160, 'hospital', '2023-03-11 08:32:49'),
(218, 25, 62, 'doctor', '2023-03-11 08:32:53'),
(219, 29, 161, 'hospital', '2023-03-11 08:33:43'),
(220, 29, 76, 'doctor', '2023-03-11 08:34:01'),
(221, 29, 179, 'hospital', '2023-03-11 08:34:45'),
(222, 29, 78, 'doctor', '2023-03-11 08:35:15'),
(223, 31, 180, 'hospital', '2023-03-11 08:37:38'),
(224, 31, 79, 'doctor', '2023-03-11 08:37:53'),
(225, 31, 179, 'hospital', '2023-03-11 08:38:24'),
(226, 31, 176, 'hospital', '2023-03-11 08:38:41'),
(227, 31, 46, 'doctor', '2023-03-11 08:38:55'),
(228, 29, 180, 'hospital', '2023-03-11 08:39:21'),
(229, 29, 79, 'doctor', '2023-03-11 08:39:30'),
(230, 29, 79, 'doctor', '2023-03-11 08:39:58'),
(231, 29, 174, 'hospital', '2023-03-11 09:17:15'),
(232, 29, 176, 'hospital', '2023-03-11 09:17:49'),
(233, 29, 46, 'doctor', '2023-03-11 09:17:52'),
(234, 29, 179, 'hospital', '2023-03-11 09:18:11'),
(235, 29, 78, 'doctor', '2023-03-11 09:18:36'),
(236, 29, 176, 'hospital', '2023-03-11 09:27:53'),
(237, 2, 180, 'hospital', '2023-03-11 10:19:35'),
(238, 2, 180, 'hospital', '2023-03-11 10:19:35'),
(239, 2, 174, 'hospital', '2023-03-11 10:20:54'),
(240, 2, 174, 'hospital', '2023-03-11 10:20:54'),
(241, 29, 181, 'hospital', '2023-03-11 14:38:03'),
(242, 29, 80, 'doctor', '2023-03-11 14:38:45'),
(243, 29, 182, 'hospital', '2023-03-11 14:57:51'),
(244, 29, 81, 'doctor', '2023-03-11 14:58:24'),
(245, 29, 182, 'hospital', '2023-03-11 15:09:14'),
(246, 29, 81, 'doctor', '2023-03-11 15:09:32'),
(247, 29, 180, 'hospital', '2023-03-11 15:11:06'),
(248, 29, 79, 'doctor', '2023-03-11 15:11:17'),
(249, 29, 182, 'hospital', '2023-03-11 15:38:35'),
(250, 29, 81, 'doctor', '2023-03-11 15:38:48'),
(251, 29, 179, 'hospital', '2023-03-11 15:39:08'),
(252, 29, 78, 'doctor', '2023-03-11 15:39:11'),
(253, 9, 46, 'doctor', '2023-03-11 15:53:08'),
(254, 29, 182, 'hospital', '2023-03-11 17:06:28'),
(255, 29, 82, 'doctor', '2023-03-11 17:06:35'),
(256, 29, 82, 'doctor', '2023-03-11 17:06:52'),
(257, 29, 81, 'doctor', '2023-03-11 17:07:12'),
(258, 29, 81, 'doctor', '2023-03-11 17:07:25'),
(259, 29, 82, 'doctor', '2023-03-11 17:07:37'),
(260, 29, 180, 'hospital', '2023-03-11 21:43:11'),
(261, 29, 79, 'doctor', '2023-03-11 21:43:19'),
(262, 29, 182, 'hospital', '2023-03-11 21:43:42'),
(263, 29, 81, 'doctor', '2023-03-11 21:43:47'),
(264, 29, 82, 'doctor', '2023-03-11 21:44:21'),
(265, 29, 161, 'hospital', '2023-03-11 21:44:54'),
(266, 29, 76, 'doctor', '2023-03-11 21:44:57'),
(267, 29, 176, 'hospital', '2023-03-11 21:45:22'),
(268, 29, 46, 'doctor', '2023-03-11 21:45:31'),
(269, 29, 182, 'hospital', '2023-03-11 21:45:45'),
(270, 29, 81, 'doctor', '2023-03-11 21:45:56'),
(271, 29, 182, 'hospital', '2023-03-12 05:38:35'),
(272, 29, 181, 'hospital', '2023-03-12 05:39:30'),
(273, 29, 80, 'doctor', '2023-03-12 05:39:33'),
(274, 9, 79, 'doctor', '2023-03-12 05:40:42'),
(275, 9, 81, 'doctor', '2023-03-12 05:41:18'),
(276, 9, 60, 'doctor', '2023-03-12 06:45:53'),
(277, 9, 46, 'doctor', '2023-03-12 06:47:21'),
(278, 32, 177, 'hospital', '2023-03-12 08:09:08'),
(279, 29, 183, 'hospital', '2023-03-12 10:19:11'),
(280, 29, 183, 'hospital', '2023-03-12 10:26:28'),
(281, 29, 83, 'doctor', '2023-03-12 10:26:36'),
(282, 29, 183, 'hospital', '2023-03-12 10:36:10'),
(283, 29, 83, 'doctor', '2023-03-12 10:36:21'),
(284, 29, 184, 'hospital', '2023-03-12 10:36:40'),
(285, 29, 85, 'doctor', '2023-03-12 10:36:52'),
(286, 29, 85, 'doctor', '2023-03-12 10:37:15'),
(287, 2, 182, 'hospital', '2023-03-12 10:51:30'),
(288, 2, 182, 'hospital', '2023-03-12 10:51:30'),
(289, 2, 182, 'hospital', '2023-03-12 10:51:38'),
(290, 2, 182, 'hospital', '2023-03-12 10:51:38'),
(291, 2, 182, 'hospital', '2023-03-12 10:51:38'),
(292, 2, 177, 'hospital', '2023-03-12 10:51:41'),
(293, 2, 177, 'hospital', '2023-03-12 10:51:41'),
(294, 2, 177, 'hospital', '2023-03-12 10:51:42'),
(295, 2, 177, 'hospital', '2023-03-12 10:51:42'),
(296, 2, 177, 'hospital', '2023-03-12 10:51:42'),
(297, 29, 185, 'hospital', '2023-03-12 14:04:17'),
(298, 29, 86, 'doctor', '2023-03-12 14:04:22'),
(299, 9, 82, 'doctor', '2023-03-12 15:25:25'),
(300, 29, 176, 'hospital', '2023-03-12 20:21:06'),
(301, 29, 176, 'hospital', '2023-03-12 20:21:06'),
(302, 29, 181, 'hospital', '2023-03-12 20:21:42'),
(303, 29, 80, 'doctor', '2023-03-12 20:21:53'),
(304, 29, 181, 'hospital', '2023-03-13 08:17:05'),
(305, 29, 80, 'doctor', '2023-03-13 08:17:43'),
(306, 29, 185, 'hospital', '2023-03-13 08:18:21'),
(307, 29, 86, 'doctor', '2023-03-13 08:18:24'),
(308, 29, 180, 'hospital', '2023-03-13 08:19:12'),
(309, 29, 79, 'doctor', '2023-03-13 08:19:20'),
(310, 29, 179, 'hospital', '2023-03-13 08:19:27'),
(311, 29, 78, 'doctor', '2023-03-13 08:19:32'),
(312, 29, 160, 'hospital', '2023-03-13 09:19:10'),
(313, 29, 62, 'doctor', '2023-03-13 09:19:15'),
(314, 29, 186, 'hospital', '2023-03-13 09:19:40'),
(315, 29, 88, 'doctor', '2023-03-13 09:19:44'),
(316, 29, 89, 'doctor', '2023-03-13 09:19:59'),
(317, 29, 186, 'hospital', '2023-03-13 10:13:12'),
(318, 29, 186, 'hospital', '2023-03-13 14:37:16'),
(319, 29, 88, 'doctor', '2023-03-13 14:37:18'),
(320, 9, 82, 'doctor', '2023-03-14 08:27:22'),
(321, 9, 89, 'doctor', '2023-03-14 08:27:53'),
(322, 9, 89, 'doctor', '2023-03-14 08:29:07'),
(323, 9, 89, 'doctor', '2023-03-14 08:29:09'),
(324, 9, 46, 'doctor', '2023-03-14 14:33:53'),
(325, 3, 181, 'hospital', '2023-03-14 14:41:12'),
(326, 3, 80, 'doctor', '2023-03-14 14:41:20'),
(327, 30, 186, 'hospital', '2023-03-14 17:40:36'),
(328, 30, 186, 'hospital', '2023-03-14 17:41:21'),
(329, 30, 186, 'hospital', '2023-03-14 17:41:30'),
(330, 30, 186, 'hospital', '2023-03-14 17:44:13'),
(331, 30, 88, 'doctor', '2023-03-14 17:44:22'),
(332, 30, 185, 'hospital', '2023-03-14 17:54:40'),
(333, 30, 87, 'doctor', '2023-03-14 17:54:47'),
(334, 3, 183, 'hospital', '2023-03-14 22:38:35'),
(335, 3, 183, 'hospital', '2023-03-14 22:38:39'),
(336, 3, 186, 'hospital', '2023-03-14 22:38:39'),
(337, 3, 178, 'hospital', '2023-03-14 22:39:08'),
(338, 3, 161, 'hospital', '2023-03-14 22:39:10'),
(339, 3, 186, 'hospital', '2023-03-14 22:39:11'),
(340, 3, 88, 'doctor', '2023-03-14 22:39:20'),
(341, 3, 88, 'doctor', '2023-03-14 22:39:28'),
(342, 3, 177, 'hospital', '2023-03-16 07:53:09'),
(343, 9, 82, 'doctor', '2023-03-16 07:53:30'),
(344, 9, 82, 'doctor', '2023-03-16 18:56:12'),
(345, 3, 174, 'hospital', '2023-03-16 18:58:04'),
(346, 3, 180, 'hospital', '2023-03-16 18:58:05'),
(347, 3, 182, 'hospital', '2023-03-16 18:58:19'),
(348, 3, 81, 'doctor', '2023-03-16 18:58:40'),
(349, 3, 176, 'hospital', '2023-03-16 18:58:58'),
(350, 3, 46, 'doctor', '2023-03-16 18:59:03'),
(351, 3, 46, 'doctor', '2023-03-16 18:59:12'),
(352, 9, 167, 'hospital', '2023-03-17 16:12:30'),
(353, 34, 187, 'hospital', '2023-03-17 17:28:06'),
(354, 3, 184, 'hospital', '2023-03-17 17:58:23'),
(355, 9, 90, 'doctor', '2023-03-17 17:59:22'),
(356, 35, 187, 'hospital', '2023-03-17 18:00:08'),
(357, 9, 82, 'doctor', '2023-03-17 18:28:24'),
(358, 9, 91, 'doctor', '2023-03-17 18:28:29'),
(359, 35, 187, 'hospital', '2023-03-17 18:29:48'),
(360, 35, 91, 'doctor', '2023-03-17 18:30:02'),
(361, 35, 187, 'hospital', '2023-03-17 18:30:34'),
(362, 35, 176, 'hospital', '2023-03-17 18:31:18'),
(363, 35, 46, 'doctor', '2023-03-17 18:31:46'),
(364, 34, 187, 'hospital', '2023-03-17 23:22:08'),
(365, 34, 91, 'doctor', '2023-03-17 23:22:33'),
(366, 34, 90, 'doctor', '2023-03-17 23:23:53'),
(367, 34, 187, 'hospital', '2023-03-17 23:26:15'),
(368, 35, 187, 'hospital', '2023-03-18 05:33:15'),
(369, 35, 187, 'hospital', '2023-03-18 05:33:15'),
(370, 35, 184, 'hospital', '2023-03-18 05:33:15'),
(371, 35, 91, 'doctor', '2023-03-18 05:33:37'),
(372, 9, 90, 'doctor', '2023-03-18 07:38:08'),
(373, 9, 90, 'doctor', '2023-03-18 07:38:09'),
(374, 9, 49, 'doctor', '2023-03-18 07:38:46'),
(375, 9, 82, 'doctor', '2023-03-19 14:07:54'),
(376, 9, 91, 'doctor', '2023-03-19 14:08:29'),
(377, 9, 46, 'doctor', '2023-03-19 14:35:58'),
(378, 35, 184, 'hospital', '2023-03-19 14:36:38'),
(379, 35, 85, 'doctor', '2023-03-19 14:36:41'),
(380, 9, 83, 'doctor', '2023-03-19 15:04:40'),
(381, 9, 186, 'hospital', '2023-03-19 15:05:47'),
(382, 9, 88, 'doctor', '2023-03-19 15:05:55'),
(383, 9, 89, 'doctor', '2023-03-19 15:06:26'),
(384, 9, 89, 'doctor', '2023-03-19 15:07:00'),
(385, 9, 89, 'doctor', '2023-03-19 15:07:32'),
(386, 9, 46, 'doctor', '2023-03-20 06:48:50'),
(387, 9, 91, 'doctor', '2023-03-20 06:49:12'),
(388, 9, 91, 'doctor', '2023-03-20 06:49:12'),
(389, 9, 91, 'doctor', '2023-03-20 06:49:12'),
(390, 9, 91, 'doctor', '2023-03-20 06:49:12'),
(391, 9, 91, 'doctor', '2023-03-20 06:49:12'),
(392, 9, 91, 'doctor', '2023-03-20 06:49:12'),
(393, 9, 91, 'doctor', '2023-03-20 06:49:13'),
(394, 35, 188, 'hospital', '2023-03-20 08:01:48'),
(395, 35, 95, 'doctor', '2023-03-20 08:02:04'),
(396, 35, 92, 'doctor', '2023-03-20 08:02:30'),
(397, 35, 188, 'hospital', '2023-03-20 08:53:42'),
(398, 35, 92, 'doctor', '2023-03-20 08:53:45'),
(399, 35, 92, 'doctor', '2023-03-20 08:53:48'),
(400, 35, 0, 'doctor', '2023-03-20 08:53:54'),
(401, 35, 94, 'doctor', '2023-03-20 08:54:12'),
(402, 35, 94, 'doctor', '2023-03-20 08:54:14'),
(403, 35, 189, 'hospital', '2023-03-20 09:13:26'),
(404, 35, 97, 'doctor', '2023-03-20 09:13:30'),
(405, 35, 96, 'doctor', '2023-03-20 09:13:49'),
(406, 35, 96, 'doctor', '2023-03-20 09:14:03'),
(407, 36, 177, 'hospital', '2023-03-20 17:46:00'),
(408, 36, 177, 'hospital', '2023-03-20 17:46:00'),
(409, 36, 177, 'hospital', '2023-03-20 17:46:00'),
(410, 36, 176, 'hospital', '2023-03-20 17:47:09'),
(411, 36, 47, 'doctor', '2023-03-20 17:47:55'),
(412, 36, 187, 'hospital', '2023-03-20 17:49:36'),
(413, 36, 91, 'doctor', '2023-03-20 17:49:59'),
(414, 36, 91, 'doctor', '2023-03-20 17:50:02'),
(415, 36, 0, 'doctor', '2023-03-20 17:50:09'),
(416, 36, 91, 'doctor', '2023-03-20 17:50:16'),
(417, 36, 91, 'doctor', '2023-03-20 17:50:20'),
(418, 9, 46, 'doctor', '2023-03-21 06:43:59'),
(419, 9, 46, 'doctor', '2023-03-21 17:16:44'),
(420, 9, 46, 'doctor', '2023-03-21 17:16:49'),
(421, 2, 161, 'hospital', '2023-03-22 10:01:21'),
(422, 2, 161, 'hospital', '2023-03-22 10:01:22'),
(423, 2, 161, 'hospital', '2023-03-22 10:01:24'),
(424, 9, 82, 'doctor', '2023-03-23 19:53:26'),
(425, 3, 161, 'hospital', '2023-03-24 06:02:05'),
(426, 3, 161, 'hospital', '2023-03-24 06:02:14'),
(427, 3, 176, 'hospital', '2023-03-24 06:02:44'),
(428, 9, 46, 'doctor', '2023-03-24 06:03:04'),
(429, 9, 46, 'doctor', '2023-03-24 06:03:17'),
(430, 9, 161, 'hospital', '2023-03-24 06:03:41'),
(431, 9, 187, 'hospital', '2023-03-24 06:06:19'),
(432, 9, 176, 'hospital', '2023-03-24 06:07:23'),
(433, 9, 161, 'hospital', '2023-03-24 06:07:39'),
(434, 9, 161, 'hospital', '2023-03-24 06:07:48'),
(435, 35, 190, 'hospital', '2023-03-24 14:21:53'),
(436, 35, 98, 'doctor', '2023-03-24 14:22:01'),
(437, 35, 190, 'hospital', '2023-03-24 14:35:53'),
(438, 35, 98, 'doctor', '2023-03-24 14:36:04'),
(439, 35, 98, 'doctor', '2023-03-24 14:36:08'),
(440, 35, 0, 'doctor', '2023-03-24 14:36:12'),
(441, 35, 190, 'hospital', '2023-03-24 15:07:51'),
(442, 35, 190, 'hospital', '2023-03-24 16:05:53'),
(443, 9, 47, 'doctor', '2023-03-24 16:57:30'),
(444, 9, 97, 'doctor', '2023-03-24 16:58:44'),
(445, 9, 97, 'doctor', '2023-03-24 17:09:40'),
(446, 9, 161, 'hospital', '2023-03-24 17:23:02'),
(447, 9, 185, 'hospital', '2023-03-24 17:23:09'),
(448, 9, 86, 'doctor', '2023-03-24 17:23:12'),
(449, 35, 190, 'hospital', '2023-03-25 07:59:17'),
(450, 2, 161, 'hospital', '2023-03-25 13:23:12'),
(451, 9, 46, 'doctor', '2023-03-25 17:30:11'),
(452, 3, 161, 'hospital', '2023-03-27 01:54:06'),
(453, 3, 185, 'hospital', '2023-03-27 01:54:26'),
(454, 3, 86, 'doctor', '2023-03-27 01:54:36'),
(455, 3, 86, 'doctor', '2023-03-27 01:54:43'),
(456, 3, 160, 'hospital', '2023-03-27 01:55:10'),
(457, 3, 161, 'hospital', '2023-03-27 01:55:10'),
(458, 3, 186, 'hospital', '2023-03-27 01:55:12'),
(459, 3, 185, 'hospital', '2023-03-27 01:55:33'),
(460, 3, 183, 'hospital', '2023-03-27 01:55:36'),
(461, 3, 86, 'doctor', '2023-03-27 01:55:40'),
(462, 3, 87, 'doctor', '2023-03-27 01:55:41'),
(463, 3, 87, 'doctor', '2023-03-27 01:55:48'),
(464, 3, 0, 'doctor', '2023-03-27 01:56:13'),
(465, 35, 190, 'hospital', '2023-03-27 18:20:12'),
(466, 35, 98, 'doctor', '2023-03-27 18:20:24'),
(467, 9, 160, 'hospital', '2023-03-28 08:57:48'),
(468, 9, 62, 'doctor', '2023-03-28 08:57:59'),
(469, 9, 160, 'hospital', '2023-03-28 08:58:42'),
(470, 9, 61, 'doctor', '2023-03-28 08:58:44'),
(471, 9, 61, 'doctor', '2023-03-28 09:01:49'),
(472, 9, 161, 'hospital', '2023-03-28 09:03:39'),
(473, 9, 76, 'doctor', '2023-03-28 09:03:41'),
(474, 35, 186, 'hospital', '2023-03-28 10:40:09'),
(475, 35, 88, 'doctor', '2023-03-28 10:40:52'),
(476, 3, 160, 'hospital', '2023-03-29 20:41:29'),
(477, 3, 62, 'doctor', '2023-03-29 20:42:01'),
(478, 3, 62, 'doctor', '2023-03-29 20:42:01'),
(479, 39, 160, 'hospital', '2023-03-29 20:48:29'),
(480, 39, 62, 'doctor', '2023-03-29 20:48:38'),
(481, 39, 160, 'hospital', '2023-03-29 20:51:37'),
(482, 39, 62, 'doctor', '2023-03-29 20:51:55'),
(483, 9, 160, 'hospital', '2023-03-29 21:07:19'),
(484, 9, 160, 'hospital', '2023-03-29 21:08:56'),
(485, 9, 62, 'doctor', '2023-03-29 21:09:00'),
(486, 35, 179, 'hospital', '2023-03-31 15:48:15'),
(487, 35, 78, 'doctor', '2023-03-31 15:48:18'),
(488, 30, 181, 'hospital', '2023-03-31 17:25:43'),
(489, 9, 176, 'hospital', '2023-04-01 10:25:07'),
(490, 9, 46, 'doctor', '2023-04-01 10:26:12'),
(491, 9, 160, 'hospital', '2023-04-01 15:09:11'),
(492, 9, 160, 'hospital', '2023-04-01 15:09:11'),
(493, 9, 62, 'doctor', '2023-04-01 15:09:19'),
(494, 9, 160, 'hospital', '2023-04-01 15:09:44'),
(495, 9, 176, 'hospital', '2023-04-01 15:10:12'),
(496, 9, 46, 'doctor', '2023-04-01 15:10:18'),
(497, 9, 47, 'doctor', '2023-04-01 15:10:42'),
(498, 9, 177, 'hospital', '2023-04-01 15:11:18'),
(499, 9, 176, 'hospital', '2023-04-01 15:14:49'),
(500, 9, 50, 'doctor', '2023-04-01 15:15:07'),
(501, 9, 161, 'hospital', '2023-04-01 15:44:42'),
(502, 9, 76, 'doctor', '2023-04-01 15:44:46'),
(503, 35, 191, 'hospital', '2023-04-01 16:14:21'),
(504, 35, 100, 'doctor', '2023-04-01 16:14:26'),
(505, 35, 160, 'hospital', '2023-04-02 00:33:55'),
(506, 35, 62, 'doctor', '2023-04-02 00:34:01'),
(507, 35, 186, 'hospital', '2023-04-02 06:30:35'),
(508, 2, 176, 'hospital', '2023-04-02 07:25:53'),
(509, 9, 78, 'doctor', '2023-04-02 07:26:11'),
(510, 35, 191, 'hospital', '2023-04-02 07:27:01'),
(511, 35, 186, 'hospital', '2023-04-02 07:50:06'),
(512, 35, 88, 'doctor', '2023-04-02 07:50:17'),
(513, 35, 88, 'doctor', '2023-04-02 07:50:34'),
(514, 35, 160, 'hospital', '2023-04-02 07:52:03'),
(515, 35, 59, 'doctor', '2023-04-02 07:53:16'),
(516, 35, 192, 'hospital', '2023-04-02 10:18:35'),
(517, 35, 103, 'doctor', '2023-04-02 10:18:50'),
(518, 35, 103, 'doctor', '2023-04-02 10:19:12'),
(519, 35, 193, 'hospital', '2023-04-02 10:56:56'),
(520, 35, 108, 'doctor', '2023-04-02 10:57:24'),
(521, 35, 192, 'hospital', '2023-04-02 10:57:57'),
(522, 35, 176, 'hospital', '2023-04-02 15:44:37'),
(523, 35, 194, 'hospital', '2023-04-02 16:25:53'),
(524, 35, 109, 'doctor', '2023-04-02 16:26:03'),
(525, 35, 109, 'doctor', '2023-04-02 16:26:41'),
(526, 35, 109, 'doctor', '2023-04-02 16:26:44'),
(527, 35, 110, 'doctor', '2023-04-02 16:27:52'),
(528, 35, 193, 'hospital', '2023-04-03 15:38:37'),
(529, 35, 106, 'doctor', '2023-04-03 15:38:44'),
(530, 35, 179, 'hospital', '2023-04-03 15:39:34'),
(531, 35, 189, 'hospital', '2023-04-03 15:39:56'),
(532, 35, 97, 'doctor', '2023-04-03 15:40:03'),
(533, 35, 194, 'hospital', '2023-04-03 15:40:18'),
(534, 35, 109, 'doctor', '2023-04-03 15:40:25'),
(535, 35, 194, 'hospital', '2023-04-03 15:54:41'),
(536, 35, 109, 'doctor', '2023-04-03 15:54:45'),
(537, 35, 179, 'hospital', '2023-04-03 16:00:22'),
(538, 35, 179, 'hospital', '2023-04-03 16:00:39'),
(539, 35, 174, 'hospital', '2023-04-03 16:00:44'),
(540, 35, 180, 'hospital', '2023-04-03 16:00:49'),
(541, 35, 79, 'doctor', '2023-04-03 16:01:16'),
(542, 35, 180, 'hospital', '2023-04-03 16:01:25'),
(543, 35, 193, 'hospital', '2023-04-06 14:14:32'),
(544, 35, 107, 'doctor', '2023-04-06 14:16:21'),
(545, 35, 193, 'hospital', '2023-04-06 14:25:03'),
(546, 3, 181, 'hospital', '2023-04-06 23:26:43'),
(547, 3, 187, 'hospital', '2023-04-06 23:27:21'),
(548, 3, 193, 'hospital', '2023-04-06 23:27:46'),
(549, 3, 107, 'doctor', '2023-04-06 23:28:13'),
(550, 42, 193, 'hospital', '2023-04-06 23:28:31'),
(551, 42, 186, 'hospital', '2023-04-06 23:28:45'),
(552, 42, 185, 'hospital', '2023-04-06 23:29:14'),
(553, 42, 183, 'hospital', '2023-04-06 23:29:31'),
(554, 42, 83, 'doctor', '2023-04-06 23:29:43'),
(555, 42, 84, 'doctor', '2023-04-06 23:31:44'),
(556, 42, 188, 'hospital', '2023-04-06 23:32:40'),
(557, 42, 94, 'doctor', '2023-04-06 23:32:58'),
(558, 42, 95, 'doctor', '2023-04-06 23:33:13'),
(559, 42, 180, 'hospital', '2023-04-06 23:33:24'),
(560, 42, 79, 'doctor', '2023-04-06 23:33:42'),
(561, 42, 191, 'hospital', '2023-04-06 23:33:59'),
(562, 42, 100, 'doctor', '2023-04-06 23:34:17'),
(563, 42, 190, 'hospital', '2023-04-06 23:35:03'),
(564, 9, 107, 'doctor', '2023-04-06 23:37:00'),
(565, 3, 192, 'hospital', '2023-04-07 09:05:44'),
(566, 3, 102, 'doctor', '2023-04-07 09:05:53'),
(567, 35, 193, 'hospital', '2023-04-07 11:58:23'),
(568, 35, 106, 'doctor', '2023-04-07 11:58:32'),
(569, 9, 110, 'doctor', '2023-04-07 17:54:06'),
(570, 9, 110, 'doctor', '2023-04-07 17:54:22'),
(571, 3, 193, 'hospital', '2023-04-07 19:31:53'),
(572, 3, 106, 'doctor', '2023-04-07 19:32:26'),
(573, 3, 188, 'hospital', '2023-04-07 19:33:07'),
(574, 3, 93, 'doctor', '2023-04-07 19:33:12'),
(575, 3, 193, 'hospital', '2023-04-07 21:39:47'),
(576, 3, 106, 'doctor', '2023-04-07 21:39:53'),
(577, 35, 193, 'hospital', '2023-04-08 10:30:46'),
(578, 35, 106, 'doctor', '2023-04-08 10:30:48'),
(579, 35, 174, 'hospital', '2023-04-08 10:34:51'),
(580, 3, 193, 'hospital', '2023-04-08 14:30:04'),
(581, 3, 106, 'doctor', '2023-04-08 14:30:21'),
(582, 3, 183, 'hospital', '2023-04-08 14:41:41'),
(583, 35, 193, 'hospital', '2023-04-08 16:26:27'),
(584, 35, 106, 'doctor', '2023-04-08 16:26:32'),
(585, 35, 193, 'hospital', '2023-04-08 17:31:00'),
(586, 35, 106, 'doctor', '2023-04-08 17:31:03'),
(587, 35, 106, 'doctor', '2023-04-08 17:31:08'),
(588, 35, 193, 'hospital', '2023-04-08 20:01:53'),
(589, 35, 106, 'doctor', '2023-04-08 20:02:02'),
(590, 35, 193, 'hospital', '2023-04-09 09:52:37'),
(591, 35, 106, 'doctor', '2023-04-09 09:52:44'),
(592, 35, 193, 'hospital', '2023-04-09 16:24:11'),
(593, 35, 106, 'doctor', '2023-04-09 16:24:43'),
(594, 9, 193, 'hospital', '2023-04-09 16:34:55'),
(595, 9, 106, 'doctor', '2023-04-09 16:36:10'),
(596, 9, 193, 'hospital', '2023-04-09 16:49:24'),
(597, 9, 106, 'doctor', '2023-04-09 16:49:56'),
(598, 9, 106, 'doctor', '2023-04-09 16:55:35'),
(599, 45, 193, 'hospital', '2023-04-09 17:29:36'),
(600, 45, 106, 'doctor', '2023-04-09 17:29:41'),
(601, 35, 193, 'hospital', '2023-04-09 18:28:40'),
(602, 35, 106, 'doctor', '2023-04-09 18:28:43'),
(603, 35, 183, 'hospital', '2023-04-09 19:48:21'),
(604, 35, 193, 'hospital', '2023-04-09 19:49:20'),
(605, 35, 107, 'doctor', '2023-04-09 19:50:27'),
(606, 3, 174, 'hospital', '2023-04-10 06:51:47'),
(607, 3, 174, 'hospital', '2023-04-10 06:51:53'),
(608, 9, 81, 'doctor', '2023-04-10 06:54:20'),
(609, 35, 193, 'hospital', '2023-04-10 14:26:17'),
(610, 35, 106, 'doctor', '2023-04-10 14:26:37'),
(611, 35, 193, 'hospital', '2023-04-10 21:53:52'),
(612, 35, 106, 'doctor', '2023-04-10 21:53:59'),
(613, 35, 193, 'hospital', '2023-04-11 09:51:20'),
(614, 35, 106, 'doctor', '2023-04-11 09:51:25'),
(615, 3, 189, 'hospital', '2023-04-11 13:43:45'),
(616, 3, 97, 'doctor', '2023-04-11 13:44:05'),
(617, 35, 194, 'hospital', '2023-04-11 13:57:29'),
(618, 35, 194, 'hospital', '2023-04-11 14:29:22'),
(619, 35, 111, 'doctor', '2023-04-11 14:29:38'),
(620, 35, 193, 'hospital', '2023-04-11 18:08:05'),
(621, 35, 194, 'hospital', '2023-04-11 18:08:13'),
(622, 35, 110, 'doctor', '2023-04-11 18:08:55'),
(623, 35, 179, 'hospital', '2023-04-12 17:57:38'),
(624, 35, 78, 'doctor', '2023-04-12 17:57:42'),
(625, 9, 83, 'doctor', '2023-04-12 18:06:07'),
(626, 9, 78, 'doctor', '2023-04-12 18:06:43'),
(627, 9, 78, 'doctor', '2023-04-12 18:06:46'),
(628, 9, 109, 'doctor', '2023-04-12 18:07:47'),
(629, 9, 109, 'doctor', '2023-04-12 18:07:47'),
(630, 9, 109, 'doctor', '2023-04-12 18:07:47'),
(631, 35, 193, 'hospital', '2023-04-12 19:20:45'),
(632, 35, 106, 'doctor', '2023-04-12 19:20:56'),
(633, 35, 180, 'hospital', '2023-04-13 00:27:44'),
(634, 35, 79, 'doctor', '2023-04-13 00:27:50'),
(635, 35, 180, 'hospital', '2023-04-13 10:18:04'),
(636, 35, 79, 'doctor', '2023-04-13 10:18:07'),
(637, 3, 174, 'hospital', '2023-04-13 18:31:58'),
(638, 3, 193, 'hospital', '2023-04-13 18:32:25'),
(639, 3, 106, 'doctor', '2023-04-13 18:32:30'),
(640, 47, 174, 'hospital', '2023-04-13 18:36:11'),
(641, 47, 191, 'hospital', '2023-04-13 18:36:42'),
(642, 47, 100, 'doctor', '2023-04-13 18:37:27'),
(643, 47, 100, 'doctor', '2023-04-13 18:37:39'),
(644, 47, 187, 'hospital', '2023-04-13 18:38:49'),
(645, 47, 167, 'hospital', '2023-04-13 18:39:16'),
(646, 35, 193, 'hospital', '2023-04-14 10:14:58'),
(647, 35, 192, 'hospital', '2023-04-14 10:15:37'),
(648, 35, 167, 'hospital', '2023-04-14 10:23:29'),
(649, 35, 193, 'hospital', '2023-04-14 17:04:52'),
(650, 35, 179, 'hospital', '2023-04-14 17:05:15'),
(651, 35, 78, 'doctor', '2023-04-14 17:05:18'),
(652, 9, 183, 'hospital', '2023-04-14 18:19:52'),
(653, 9, 183, 'hospital', '2023-04-14 18:20:06'),
(654, 9, 183, 'hospital', '2023-04-14 18:20:10'),
(655, 9, 82, 'doctor', '2023-04-14 18:20:34'),
(656, 9, 82, 'doctor', '2023-04-14 18:20:52'),
(657, 9, 82, 'doctor', '2023-04-14 18:21:02'),
(658, 9, 82, 'doctor', '2023-04-14 18:21:09'),
(659, 9, 82, 'doctor', '2023-04-14 18:21:26'),
(660, 35, 193, 'hospital', '2023-04-14 19:22:12'),
(661, 3, 186, 'hospital', '2023-04-14 20:35:38'),
(662, 9, 110, 'doctor', '2023-04-14 20:35:53'),
(663, 9, 186, 'hospital', '2023-04-14 20:36:35'),
(664, 9, 186, 'hospital', '2023-04-14 20:37:09'),
(665, 9, 110, 'doctor', '2023-04-14 20:37:42'),
(666, 9, 186, 'hospital', '2023-04-14 20:37:50'),
(667, 9, 186, 'hospital', '2023-04-14 20:37:56'),
(668, 9, 110, 'doctor', '2023-04-14 20:38:14'),
(669, 9, 186, 'hospital', '2023-04-14 20:38:24'),
(670, 3, 186, 'hospital', '2023-04-14 20:41:17'),
(671, 9, 110, 'doctor', '2023-04-14 20:41:32'),
(672, 9, 186, 'hospital', '2023-04-14 20:42:12'),
(673, 9, 186, 'hospital', '2023-04-14 20:42:34'),
(674, 9, 110, 'doctor', '2023-04-14 20:43:20'),
(675, 9, 186, 'hospital', '2023-04-14 20:43:27'),
(676, 9, 186, 'hospital', '2023-04-14 20:43:39'),
(677, 9, 110, 'doctor', '2023-04-14 20:44:11'),
(678, 9, 110, 'doctor', '2023-04-14 20:44:28'),
(679, 9, 186, 'hospital', '2023-04-14 21:05:34'),
(680, 9, 186, 'hospital', '2023-04-14 21:06:19'),
(681, 9, 110, 'doctor', '2023-04-14 21:06:28'),
(682, 9, 186, 'hospital', '2023-04-14 21:06:49'),
(683, 9, 186, 'hospital', '2023-04-14 21:07:11'),
(684, 9, 110, 'doctor', '2023-04-14 21:07:26'),
(685, 9, 110, 'doctor', '2023-04-14 21:07:40'),
(686, 35, 193, 'hospital', '2023-04-15 08:59:00'),
(687, 35, 108, 'doctor', '2023-04-15 08:59:05'),
(688, 35, 193, 'hospital', '2023-04-15 09:00:40'),
(689, 35, 108, 'doctor', '2023-04-15 09:00:48'),
(690, 35, 180, 'hospital', '2023-04-15 09:01:04'),
(691, 35, 79, 'doctor', '2023-04-15 09:01:07'),
(692, 35, 195, 'hospital', '2023-04-15 09:17:54'),
(693, 35, 192, 'hospital', '2023-04-15 10:18:33'),
(694, 35, 102, 'doctor', '2023-04-15 10:18:47'),
(695, 35, 195, 'hospital', '2023-04-15 10:19:00'),
(696, 35, 115, 'doctor', '2023-04-15 10:19:04'),
(697, 35, 195, 'hospital', '2023-04-15 10:31:38'),
(698, 35, 115, 'doctor', '2023-04-15 10:31:45'),
(699, 35, 115, 'doctor', '2023-04-15 10:38:12'),
(700, 35, 192, 'hospital', '2023-04-15 10:39:05'),
(701, 35, 195, 'hospital', '2023-04-15 10:39:19'),
(702, 35, 115, 'doctor', '2023-04-15 10:39:24'),
(703, 35, 194, 'hospital', '2023-04-15 10:44:50'),
(704, 35, 110, 'doctor', '2023-04-15 10:44:55'),
(705, 3, 193, 'hospital', '2023-04-15 13:15:03'),
(706, 3, 107, 'doctor', '2023-04-15 13:15:33'),
(707, 3, 106, 'doctor', '2023-04-15 13:16:02'),
(708, 3, 167, 'hospital', '2023-04-15 13:19:32'),
(709, 3, 179, 'hospital', '2023-04-15 13:19:42'),
(710, 50, 193, 'hospital', '2023-04-15 16:07:24'),
(711, 50, 106, 'doctor', '2023-04-15 16:07:26'),
(712, 35, 193, 'hospital', '2023-04-16 19:36:00'),
(713, 35, 193, 'hospital', '2023-04-16 19:36:00'),
(714, 35, 106, 'doctor', '2023-04-16 19:36:13'),
(715, 3, 186, 'hospital', '2023-04-17 18:45:52'),
(716, 3, 186, 'hospital', '2023-04-17 18:46:09'),
(717, 3, 88, 'doctor', '2023-04-17 18:46:14'),
(718, 3, 182, 'hospital', '2023-04-17 18:48:56'),
(719, 35, 180, 'hospital', '2023-04-18 17:17:38'),
(720, 35, 79, 'doctor', '2023-04-18 17:17:43'),
(721, 3, 193, 'hospital', '2023-04-21 10:21:35'),
(722, 3, 106, 'doctor', '2023-04-21 10:21:39'),
(723, 35, 193, 'hospital', '2023-04-22 07:36:33'),
(724, 35, 106, 'doctor', '2023-04-22 07:36:40'),
(725, 35, 186, 'hospital', '2023-04-22 07:37:01'),
(726, 35, 88, 'doctor', '2023-04-22 07:37:04'),
(727, 35, 185, 'hospital', '2023-04-22 07:37:18'),
(728, 35, 86, 'doctor', '2023-04-22 07:37:20'),
(729, 35, 183, 'hospital', '2023-04-22 07:37:55'),
(730, 35, 83, 'doctor', '2023-04-22 07:37:57'),
(731, 3, 193, 'hospital', '2023-04-23 19:11:17'),
(732, 3, 106, 'doctor', '2023-04-23 19:11:20'),
(733, 3, 167, 'hospital', '2023-04-23 19:12:13'),
(734, 3, 187, 'hospital', '2023-04-23 19:12:27'),
(735, 3, 190, 'hospital', '2023-04-23 21:22:07'),
(736, 3, 181, 'hospital', '2023-04-23 21:22:07'),
(737, 3, 181, 'hospital', '2023-04-23 21:22:07'),
(738, 3, 182, 'hospital', '2023-04-23 21:22:07'),
(739, 3, 190, 'hospital', '2023-04-23 21:22:11'),
(740, 9, 110, 'doctor', '2023-04-24 07:36:22'),
(741, 9, 110, 'doctor', '2023-04-24 07:36:36'),
(742, 9, 113, 'doctor', '2023-04-24 07:37:18'),
(743, 9, 186, 'hospital', '2023-04-24 07:38:25'),
(744, 9, 189, 'hospital', '2023-04-24 07:39:09'),
(745, 9, 186, 'hospital', '2023-04-24 07:40:33'),
(746, 9, 186, 'hospital', '2023-04-24 07:40:50'),
(747, 9, 194, 'hospital', '2023-04-24 07:42:51'),
(748, 35, 180, 'hospital', '2023-04-24 09:37:05'),
(749, 35, 79, 'doctor', '2023-04-24 09:37:07'),
(750, 35, 180, 'hospital', '2023-04-24 09:53:24'),
(751, 35, 79, 'doctor', '2023-04-24 09:53:26'),
(752, 35, 179, 'hospital', '2023-04-24 09:53:41'),
(753, 35, 78, 'doctor', '2023-04-24 09:53:43'),
(754, 35, 188, 'hospital', '2023-04-24 09:58:47'),
(755, 35, 92, 'doctor', '2023-04-24 09:59:28'),
(756, 35, 193, 'hospital', '2023-04-24 10:56:32'),
(757, 35, 106, 'doctor', '2023-04-24 10:56:36'),
(758, 35, 107, 'doctor', '2023-04-24 10:57:07'),
(759, 35, 185, 'hospital', '2023-04-24 10:57:21'),
(760, 35, 86, 'doctor', '2023-04-24 10:57:24'),
(761, 9, 110, 'doctor', '2023-04-24 13:28:37'),
(762, 35, 193, 'hospital', '2023-04-24 13:43:59'),
(763, 35, 106, 'doctor', '2023-04-24 13:44:12'),
(764, 35, 192, 'hospital', '2023-04-24 14:15:21'),
(765, 35, 195, 'hospital', '2023-04-24 14:15:59'),
(766, 35, 195, 'hospital', '2023-04-24 14:16:34'),
(767, 35, 195, 'hospital', '2023-04-24 15:15:20'),
(768, 35, 117, 'doctor', '2023-04-24 15:15:34'),
(769, 35, 115, 'doctor', '2023-04-24 15:16:11'),
(770, 35, 195, 'hospital', '2023-04-24 16:27:25'),
(771, 35, 115, 'doctor', '2023-04-24 16:27:39'),
(772, 35, 116, 'doctor', '2023-04-24 16:34:02'),
(773, 35, 117, 'doctor', '2023-04-24 16:34:32'),
(774, 35, 120, 'doctor', '2023-04-24 16:34:41'),
(775, 35, 117, 'doctor', '2023-04-24 16:35:04'),
(776, 35, 117, 'doctor', '2023-04-24 16:35:19'),
(777, 35, 120, 'doctor', '2023-04-24 16:35:33'),
(778, 35, 116, 'doctor', '2023-04-24 16:35:42'),
(779, 35, 121, 'doctor', '2023-04-24 16:35:48'),
(780, 35, 121, 'doctor', '2023-04-24 16:36:11'),
(781, 9, 110, 'doctor', '2023-04-24 20:25:13'),
(782, 9, 110, 'doctor', '2023-04-24 20:25:27'),
(783, 9, 189, 'hospital', '2023-04-24 20:26:03'),
(784, 9, 186, 'hospital', '2023-04-24 20:27:07'),
(785, 9, 194, 'hospital', '2023-04-24 20:28:15'),
(786, 9, 186, 'hospital', '2023-04-24 20:28:56'),
(787, 9, 186, 'hospital', '2023-04-24 20:29:15'),
(788, 35, 193, 'hospital', '2023-04-25 11:38:55'),
(789, 35, 106, 'doctor', '2023-04-25 11:39:00'),
(790, 35, 180, 'hospital', '2023-04-25 14:16:39'),
(791, 35, 179, 'hospital', '2023-04-25 14:17:16'),
(792, 35, 179, 'hospital', '2023-04-25 14:19:29'),
(793, 35, 179, 'hospital', '2023-04-25 14:20:05'),
(794, 35, 78, 'doctor', '2023-04-25 14:20:06'),
(795, 35, 196, 'hospital', '2023-04-25 14:39:10'),
(796, 35, 196, 'hospital', '2023-04-25 14:46:40'),
(797, 9, 196, 'hospital', '2023-04-25 14:47:20'),
(798, 35, 167, 'hospital', '2023-04-25 15:08:01'),
(799, 35, 192, 'hospital', '2023-04-26 14:18:41'),
(800, 35, 102, 'doctor', '2023-04-26 14:18:46'),
(801, 35, 103, 'doctor', '2023-04-26 14:19:32'),
(802, 30, 190, 'hospital', '2023-04-26 16:16:23'),
(803, 30, 189, 'hospital', '2023-04-26 16:16:30'),
(804, 30, 97, 'doctor', '2023-04-26 16:16:33'),
(805, 35, 193, 'hospital', '2023-04-27 07:52:53'),
(806, 35, 108, 'doctor', '2023-04-27 07:53:05'),
(807, 3, 193, 'hospital', '2023-04-27 18:48:53'),
(808, 3, 108, 'doctor', '2023-04-27 18:49:16'),
(809, 52, 192, 'hospital', '2023-04-27 18:59:44'),
(810, 52, 101, 'doctor', '2023-04-27 19:00:31'),
(811, 52, 192, 'hospital', '2023-04-28 17:04:12'),
(812, 52, 101, 'doctor', '2023-04-28 17:04:29'),
(813, 52, 105, 'doctor', '2023-04-28 17:08:11'),
(814, 35, 193, 'hospital', '2023-04-28 17:16:28'),
(815, 35, 106, 'doctor', '2023-04-28 17:16:32'),
(816, 35, 192, 'hospital', '2023-04-28 17:49:17'),
(817, 9, 91, 'doctor', '2023-04-28 17:49:53'),
(818, 9, 92, 'doctor', '2023-04-28 17:54:43'),
(819, 9, 80, 'doctor', '2023-04-28 17:55:03'),
(820, 9, 84, 'doctor', '2023-04-28 17:57:48'),
(821, 3, 193, 'hospital', '2023-04-29 08:54:06'),
(822, 3, 106, 'doctor', '2023-04-29 08:54:14'),
(823, 54, 193, 'hospital', '2023-04-29 19:21:43'),
(824, 54, 106, 'doctor', '2023-04-29 19:21:49'),
(825, 54, 194, 'hospital', '2023-04-29 19:22:58'),
(826, 54, 112, 'doctor', '2023-04-29 19:23:17'),
(827, 54, 190, 'hospital', '2023-04-29 19:24:49'),
(828, 35, 193, 'hospital', '2023-04-30 07:02:32'),
(829, 35, 106, 'doctor', '2023-04-30 07:02:34'),
(830, 35, 193, 'hospital', '2023-04-30 08:48:51'),
(831, 35, 106, 'doctor', '2023-04-30 08:48:54'),
(832, 3, 193, 'hospital', '2023-04-30 15:31:51'),
(833, 3, 108, 'doctor', '2023-04-30 15:31:58'),
(834, 9, 116, 'doctor', '2023-04-30 15:39:55'),
(835, 9, 109, 'doctor', '2023-04-30 15:41:08'),
(836, 3, 193, 'hospital', '2023-04-30 17:46:14'),
(837, 3, 192, 'hospital', '2023-04-30 17:46:46'),
(838, 9, 82, 'doctor', '2023-05-01 05:41:57'),
(839, 35, 193, 'hospital', '2023-05-02 10:53:29'),
(840, 35, 106, 'doctor', '2023-05-02 10:53:37'),
(841, 3, 193, 'hospital', '2023-05-02 17:38:15'),
(842, 3, 106, 'doctor', '2023-05-02 17:38:19'),
(843, 3, 193, 'hospital', '2023-05-02 17:38:41'),
(844, 3, 106, 'doctor', '2023-05-02 17:38:48'),
(845, 56, 181, 'hospital', '2023-05-03 03:23:35'),
(846, 56, 192, 'hospital', '2023-05-03 03:24:11'),
(847, 56, 101, 'doctor', '2023-05-03 03:24:45'),
(848, 56, 193, 'hospital', '2023-05-03 03:25:56'),
(849, 56, 106, 'doctor', '2023-05-03 03:25:58'),
(850, 56, 189, 'hospital', '2023-05-03 03:26:13'),
(851, 56, 193, 'hospital', '2023-05-03 03:26:18'),
(852, 56, 106, 'doctor', '2023-05-03 03:26:21'),
(853, 56, 106, 'doctor', '2023-05-03 03:26:28'),
(854, 56, 106, 'doctor', '2023-05-03 03:26:31'),
(855, 3, 189, 'hospital', '2023-05-03 09:23:58'),
(856, 9, 192, 'hospital', '2023-05-03 09:25:10'),
(857, 9, 105, 'doctor', '2023-05-03 09:25:19'),
(858, 35, 193, 'hospital', '2023-05-04 07:16:51'),
(859, 35, 106, 'doctor', '2023-05-04 07:17:08'),
(860, 35, 196, 'hospital', '2023-05-04 08:45:51'),
(861, 35, 190, 'hospital', '2023-05-04 08:46:06'),
(862, 35, 98, 'doctor', '2023-05-04 08:46:08'),
(863, 35, 190, 'hospital', '2023-05-04 09:08:24'),
(864, 35, 98, 'doctor', '2023-05-04 09:08:28'),
(865, 35, 98, 'doctor', '2023-05-04 09:20:00'),
(866, 3, 193, 'hospital', '2023-05-04 14:11:56'),
(867, 3, 106, 'doctor', '2023-05-04 14:12:30'),
(868, 3, 183, 'hospital', '2023-05-04 14:13:03'),
(869, 35, 193, 'hospital', '2023-05-05 09:32:28'),
(870, 35, 106, 'doctor', '2023-05-05 09:32:31'),
(871, 35, 193, 'hospital', '2023-05-06 13:43:09'),
(872, 35, 106, 'doctor', '2023-05-06 13:43:18'),
(873, 35, 193, 'hospital', '2023-05-06 18:07:48'),
(874, 35, 106, 'doctor', '2023-05-06 18:07:53'),
(875, 35, 193, 'hospital', '2023-05-07 07:23:20'),
(876, 35, 106, 'doctor', '2023-05-07 07:23:22'),
(877, 35, 108, 'doctor', '2023-05-07 07:43:01'),
(878, 35, 193, 'hospital', '2023-05-07 18:08:47'),
(879, 35, 106, 'doctor', '2023-05-07 18:08:50'),
(880, 35, 190, 'hospital', '2023-05-08 07:40:13'),
(881, 35, 98, 'doctor', '2023-05-08 07:40:18'),
(882, 35, 182, 'hospital', '2023-05-08 07:43:41'),
(883, 35, 181, 'hospital', '2023-05-08 07:43:52'),
(884, 35, 80, 'doctor', '2023-05-08 07:43:56'),
(885, 35, 181, 'hospital', '2023-05-08 10:29:34'),
(886, 35, 80, 'doctor', '2023-05-08 10:29:37'),
(887, 35, 190, 'hospital', '2023-05-08 13:29:34'),
(888, 35, 98, 'doctor', '2023-05-08 13:29:43'),
(889, 35, 182, 'hospital', '2023-05-08 13:32:21'),
(890, 35, 181, 'hospital', '2023-05-08 13:32:41'),
(891, 35, 80, 'doctor', '2023-05-08 13:32:45'),
(892, 35, 181, 'hospital', '2023-05-09 15:41:36'),
(893, 35, 80, 'doctor', '2023-05-09 15:41:40'),
(894, 35, 193, 'hospital', '2023-05-10 14:57:02'),
(895, 35, 106, 'doctor', '2023-05-10 14:57:05'),
(896, 35, 193, 'hospital', '2023-05-13 09:02:04'),
(897, 35, 106, 'doctor', '2023-05-13 09:02:06'),
(898, 35, 181, 'hospital', '2023-05-13 09:02:41'),
(899, 35, 80, 'doctor', '2023-05-13 09:02:44'),
(900, 35, 181, 'hospital', '2023-05-13 11:24:11'),
(901, 35, 80, 'doctor', '2023-05-13 11:24:13'),
(902, 35, 184, 'hospital', '2023-05-13 11:24:33'),
(903, 35, 181, 'hospital', '2023-05-13 11:24:41'),
(904, 35, 80, 'doctor', '2023-05-13 11:24:47'),
(905, 35, 80, 'doctor', '2023-05-13 11:26:14'),
(906, 35, 188, 'hospital', '2023-05-13 11:31:08'),
(907, 35, 92, 'doctor', '2023-05-13 11:31:11'),
(908, 35, 181, 'hospital', '2023-05-13 12:21:02'),
(909, 35, 80, 'doctor', '2023-05-13 12:21:06'),
(910, 35, 181, 'hospital', '2023-05-13 12:25:23'),
(911, 35, 80, 'doctor', '2023-05-13 12:25:26'),
(912, 35, 181, 'hospital', '2023-05-13 12:32:14'),
(913, 35, 80, 'doctor', '2023-05-13 12:32:17'),
(914, 35, 181, 'hospital', '2023-05-13 12:36:05'),
(915, 35, 80, 'doctor', '2023-05-13 12:36:09'),
(916, 35, 181, 'hospital', '2023-05-13 12:40:10'),
(917, 35, 80, 'doctor', '2023-05-13 12:40:13'),
(918, 35, 193, 'hospital', '2023-05-13 17:20:49'),
(919, 35, 193, 'hospital', '2023-05-13 17:20:49'),
(920, 35, 106, 'doctor', '2023-05-13 17:20:54'),
(921, 35, 186, 'hospital', '2023-05-14 06:46:16'),
(922, 35, 88, 'doctor', '2023-05-14 06:46:22'),
(923, 35, 181, 'hospital', '2023-05-14 08:00:34'),
(924, 35, 80, 'doctor', '2023-05-14 08:00:40'),
(925, 35, 181, 'hospital', '2023-05-14 08:39:13'),
(926, 35, 80, 'doctor', '2023-05-14 08:39:22'),
(927, 35, 188, 'hospital', '2023-05-14 08:41:28'),
(928, 35, 92, 'doctor', '2023-05-14 08:41:31'),
(929, 35, 192, 'hospital', '2023-05-14 08:58:09'),
(930, 35, 102, 'doctor', '2023-05-14 08:58:14'),
(931, 35, 192, 'hospital', '2023-05-14 08:58:24'),
(932, 35, 188, 'hospital', '2023-05-14 08:58:31'),
(933, 35, 92, 'doctor', '2023-05-14 08:58:35'),
(934, 35, 181, 'hospital', '2023-05-14 09:01:34'),
(935, 35, 80, 'doctor', '2023-05-14 09:01:40'),
(936, 35, 188, 'hospital', '2023-05-14 09:13:14'),
(937, 35, 92, 'doctor', '2023-05-14 09:13:18'),
(938, 35, 190, 'hospital', '2023-05-15 20:30:47'),
(939, 35, 98, 'doctor', '2023-05-15 20:30:51'),
(940, 35, 190, 'hospital', '2023-05-15 22:47:52'),
(941, 35, 98, 'doctor', '2023-05-15 22:48:00'),
(942, 3, 193, 'hospital', '2023-05-16 09:37:28'),
(943, 3, 106, 'doctor', '2023-05-16 09:37:32'),
(944, 57, 193, 'hospital', '2023-05-16 13:09:59'),
(945, 57, 108, 'doctor', '2023-05-16 13:10:09'),
(946, 57, 106, 'doctor', '2023-05-16 13:10:35'),
(947, 57, 188, 'hospital', '2023-05-16 13:11:02'),
(948, 3, 193, 'hospital', '2023-05-24 07:54:25'),
(949, 3, 193, 'hospital', '2023-05-24 07:54:27'),
(950, 3, 196, 'hospital', '2023-05-24 07:54:37'),
(951, 3, 188, 'hospital', '2023-05-24 07:54:37'),
(952, 3, 106, 'doctor', '2023-05-24 07:54:41'),
(953, 9, 85, 'doctor', '2023-05-24 07:56:38'),
(954, 35, 191, 'hospital', '2023-05-27 02:01:05'),
(955, 35, 190, 'hospital', '2023-05-27 02:01:12'),
(956, 35, 98, 'doctor', '2023-05-27 02:01:17'),
(957, 9, 186, 'hospital', '2023-05-27 04:49:52'),
(958, 9, 191, 'hospital', '2023-05-27 04:50:14'),
(959, 9, 186, 'hospital', '2023-05-27 04:50:55'),
(960, 9, 189, 'hospital', '2023-05-27 04:52:54'),
(961, 9, 186, 'hospital', '2023-05-27 04:53:30'),
(962, 59, 190, 'hospital', '2023-05-27 14:20:15'),
(963, 59, 190, 'hospital', '2023-05-27 14:23:46'),
(964, 59, 98, 'doctor', '2023-05-27 14:23:48'),
(965, 3, 195, 'hospital', '2023-05-29 22:37:16'),
(966, 3, 117, 'doctor', '2023-05-29 22:37:21'),
(967, 3, 193, 'hospital', '2023-05-29 22:42:09'),
(968, 3, 193, 'hospital', '2023-05-30 17:52:09'),
(969, 3, 194, 'hospital', '2023-05-30 17:52:16'),
(970, 3, 106, 'doctor', '2023-05-30 17:52:24'),
(971, 3, 110, 'doctor', '2023-05-30 17:52:50'),
(972, 61, 193, 'hospital', '2023-05-31 05:02:37'),
(973, 61, 106, 'doctor', '2023-05-31 05:02:52'),
(974, 61, 107, 'doctor', '2023-05-31 05:06:49'),
(975, 61, 107, 'doctor', '2023-05-31 05:06:50'),
(976, 61, 106, 'doctor', '2023-05-31 05:06:54'),
(977, 61, 190, 'hospital', '2023-05-31 05:07:27'),
(978, 61, 98, 'doctor', '2023-05-31 05:07:32'),
(979, 9, 92, 'doctor', '2023-05-31 05:08:06'),
(980, 9, 92, 'doctor', '2023-05-31 05:08:12'),
(981, 9, 80, 'doctor', '2023-05-31 06:19:00'),
(982, 36, 193, 'hospital', '2023-05-31 07:18:59'),
(983, 59, 190, 'hospital', '2023-05-31 10:23:15'),
(984, 59, 98, 'doctor', '2023-05-31 10:24:05'),
(985, 62, 193, 'hospital', '2023-05-31 14:58:49'),
(986, 30, 190, 'hospital', '2023-06-03 18:10:01'),
(987, 30, 99, 'doctor', '2023-06-03 18:10:17'),
(988, 59, 190, 'hospital', '2023-06-04 05:08:38'),
(989, 59, 98, 'doctor', '2023-06-04 05:08:57'),
(990, 59, 99, 'doctor', '2023-06-04 05:09:34'),
(991, 59, 193, 'hospital', '2023-06-04 06:56:53'),
(992, 59, 106, 'doctor', '2023-06-04 06:56:57'),
(993, 59, 188, 'hospital', '2023-06-08 03:32:08'),
(994, 30, 188, 'hospital', '2023-06-08 03:37:39'),
(995, 59, 190, 'hospital', '2023-06-08 03:38:44'),
(996, 59, 98, 'doctor', '2023-06-08 03:38:56'),
(997, 30, 190, 'hospital', '2023-06-08 04:22:49'),
(998, 30, 98, 'doctor', '2023-06-08 04:23:01'),
(999, 59, 190, 'hospital', '2023-06-08 04:38:51'),
(1000, 59, 98, 'doctor', '2023-06-08 04:38:57'),
(1001, 59, 190, 'hospital', '2023-06-08 04:41:10'),
(1002, 59, 98, 'doctor', '2023-06-08 04:41:12'),
(1003, 3, 192, 'hospital', '2023-06-08 11:38:33'),
(1004, 30, 192, 'hospital', '2023-06-08 14:04:12'),
(1005, 30, 105, 'doctor', '2023-06-08 14:04:30'),
(1006, 59, 190, 'hospital', '2023-06-08 14:08:15'),
(1007, 59, 99, 'doctor', '2023-06-08 14:08:18'),
(1008, 59, 189, 'hospital', '2023-06-08 15:30:07'),
(1009, 51, 182, 'hospital', '2023-06-09 18:49:34'),
(1010, 51, 81, 'doctor', '2023-06-09 18:49:57'),
(1011, 51, 82, 'doctor', '2023-06-09 18:49:59'),
(1012, 51, 81, 'doctor', '2023-06-09 18:50:01'),
(1013, 59, 190, 'hospital', '2023-06-10 20:12:57'),
(1014, 59, 98, 'doctor', '2023-06-10 20:13:03'),
(1015, 59, 182, 'hospital', '2023-06-11 18:29:57'),
(1016, 59, 81, 'doctor', '2023-06-11 18:30:07'),
(1017, 59, 193, 'hospital', '2023-06-12 03:00:38'),
(1018, 59, 106, 'doctor', '2023-06-12 03:00:40'),
(1019, 59, 190, 'hospital', '2023-06-18 19:18:51'),
(1020, 59, 98, 'doctor', '2023-06-18 19:19:12'),
(1021, 59, 193, 'hospital', '2023-06-24 05:42:03'),
(1022, 59, 106, 'doctor', '2023-06-24 05:42:06'),
(1023, 59, 190, 'hospital', '2023-06-24 07:04:55'),
(1024, 59, 183, 'hospital', '2023-06-24 07:04:55'),
(1025, 59, 98, 'doctor', '2023-06-24 07:05:03'),
(1026, 59, 193, 'hospital', '2023-06-24 14:06:18'),
(1027, 59, 106, 'doctor', '2023-06-24 14:06:32'),
(1028, 59, 194, 'hospital', '2023-06-24 14:23:47'),
(1029, 59, 194, 'hospital', '2023-06-24 14:23:47'),
(1030, 59, 194, 'hospital', '2023-06-26 08:22:13'),
(1031, 59, 194, 'hospital', '2023-06-26 08:22:13'),
(1032, 59, 110, 'doctor', '2023-06-26 08:22:22'),
(1033, 59, 193, 'hospital', '2023-06-27 06:42:52'),
(1034, 59, 106, 'doctor', '2023-06-27 06:43:04'),
(1035, 59, 193, 'hospital', '2023-06-27 07:33:04'),
(1036, 59, 106, 'doctor', '2023-06-27 07:33:09'),
(1037, 59, 193, 'hospital', '2023-06-27 19:04:14'),
(1038, 9, 106, 'doctor', '2023-06-27 19:04:17'),
(1039, 9, 106, 'doctor', '2023-06-27 19:04:30'),
(1040, 59, 190, 'hospital', '2023-07-02 17:59:13'),
(1041, 59, 98, 'doctor', '2023-07-02 17:59:16'),
(1042, 3, 193, 'hospital', '2023-07-06 17:34:33'),
(1043, 3, 106, 'doctor', '2023-07-06 17:34:51'),
(1044, 3, 183, 'hospital', '2023-07-06 20:17:10'),
(1045, 3, 184, 'hospital', '2023-07-06 20:18:10'),
(1046, 3, 85, 'doctor', '2023-07-06 20:18:39'),
(1047, 3, 183, 'hospital', '2023-07-06 20:23:12'),
(1048, 3, 84, 'doctor', '2023-07-06 20:25:09'),
(1049, 59, 193, 'hospital', '2023-07-07 11:02:09'),
(1050, 59, 106, 'doctor', '2023-07-07 11:02:13'),
(1051, 59, 194, 'hospital', '2023-07-07 11:02:39'),
(1052, 59, 193, 'hospital', '2023-07-07 14:56:08'),
(1053, 59, 106, 'doctor', '2023-07-07 14:56:11'),
(1054, 59, 193, 'hospital', '2023-07-07 17:45:35'),
(1055, 59, 106, 'doctor', '2023-07-07 17:45:39');
INSERT INTO `app_click` (`id`, `visitor_id`, `_id`, `action`, `date`) VALUES
(1056, 59, 107, 'doctor', '2023-07-07 17:46:35'),
(1057, 59, 195, 'hospital', '2023-07-08 07:02:17'),
(1058, 59, 117, 'doctor', '2023-07-08 07:02:21'),
(1059, 59, 193, 'hospital', '2023-07-08 20:17:02'),
(1060, 59, 106, 'doctor', '2023-07-08 20:17:07'),
(1061, 59, 193, 'hospital', '2023-07-08 20:46:09'),
(1062, 59, 106, 'doctor', '2023-07-08 20:46:23'),
(1063, 9, 189, 'hospital', '2023-07-09 06:38:31'),
(1064, 9, 186, 'hospital', '2023-07-09 06:38:47'),
(1065, 9, 191, 'hospital', '2023-07-09 06:39:09'),
(1066, 9, 186, 'hospital', '2023-07-09 06:39:47'),
(1067, 9, 92, 'doctor', '2023-07-09 06:40:36'),
(1068, 9, 191, 'hospital', '2023-07-09 06:41:23'),
(1069, 59, 193, 'hospital', '2023-07-09 19:37:27'),
(1070, 59, 106, 'doctor', '2023-07-09 19:37:31'),
(1071, 68, 189, 'hospital', '2023-07-09 20:58:19'),
(1072, 68, 97, 'doctor', '2023-07-09 20:58:30'),
(1073, 9, 82, 'doctor', '2023-07-09 20:59:08'),
(1074, 9, 82, 'doctor', '2023-07-09 20:59:11'),
(1075, 59, 191, 'hospital', '2023-07-11 19:23:50'),
(1076, 59, 100, 'doctor', '2023-07-11 19:23:56'),
(1077, 59, 193, 'hospital', '2023-07-12 07:30:10'),
(1078, 59, 106, 'doctor', '2023-07-12 07:30:15'),
(1079, 59, 193, 'hospital', '2023-07-13 08:12:49'),
(1080, 59, 106, 'doctor', '2023-07-13 08:12:59'),
(1081, 3, 183, 'hospital', '2023-07-13 08:15:55'),
(1082, 59, 193, 'hospital', '2023-07-13 08:17:09'),
(1083, 59, 106, 'doctor', '2023-07-13 08:17:19'),
(1084, 3, 193, 'hospital', '2023-07-13 12:06:24'),
(1085, 3, 108, 'doctor', '2023-07-13 12:06:47'),
(1086, 3, 108, 'doctor', '2023-07-13 12:06:47'),
(1087, 59, 193, 'hospital', '2023-07-13 19:20:37'),
(1088, 59, 193, 'hospital', '2023-07-13 19:20:37'),
(1089, 59, 106, 'doctor', '2023-07-13 19:21:01'),
(1090, 70, 193, 'hospital', '2023-07-13 21:33:34'),
(1091, 70, 191, 'hospital', '2023-07-13 21:34:01'),
(1092, 70, 189, 'hospital', '2023-07-13 21:34:01'),
(1093, 70, 184, 'hospital', '2023-07-13 21:34:01'),
(1094, 70, 191, 'hospital', '2023-07-13 21:34:01'),
(1095, 70, 187, 'hospital', '2023-07-13 21:34:01'),
(1096, 70, 196, 'hospital', '2023-07-13 21:34:02'),
(1097, 70, 191, 'hospital', '2023-07-13 21:34:16'),
(1098, 70, 185, 'hospital', '2023-07-14 14:09:44'),
(1099, 70, 186, 'hospital', '2023-07-14 14:09:44'),
(1100, 59, 193, 'hospital', '2023-07-14 20:04:17'),
(1101, 59, 106, 'doctor', '2023-07-14 20:04:32'),
(1102, 58, 185, 'hospital', '2023-07-15 08:48:23'),
(1103, 58, 182, 'hospital', '2023-07-15 08:49:54'),
(1104, 58, 194, 'hospital', '2023-07-15 08:50:37'),
(1105, 58, 191, 'hospital', '2023-07-15 08:52:14'),
(1106, 59, 193, 'hospital', '2023-07-16 08:12:15'),
(1107, 3, 193, 'hospital', '2023-07-16 08:16:21'),
(1108, 3, 106, 'doctor', '2023-07-16 08:16:26'),
(1109, 3, 106, 'doctor', '2023-07-16 08:21:00'),
(1110, 3, 108, 'doctor', '2023-07-16 08:21:11'),
(1111, 3, 107, 'doctor', '2023-07-16 08:21:46'),
(1112, 3, 107, 'doctor', '2023-07-16 08:21:59'),
(1113, 71, 193, 'hospital', '2023-07-16 08:24:01'),
(1114, 71, 108, 'doctor', '2023-07-16 08:24:25'),
(1115, 71, 108, 'doctor', '2023-07-16 08:24:38'),
(1116, 71, 108, 'doctor', '2023-07-16 08:24:46'),
(1117, 71, 188, 'hospital', '2023-07-16 08:25:48'),
(1118, 71, 193, 'hospital', '2023-07-16 08:27:32'),
(1119, 71, 190, 'hospital', '2023-07-16 08:31:04'),
(1120, 71, 182, 'hospital', '2023-07-16 08:31:43'),
(1121, 71, 194, 'hospital', '2023-07-16 08:32:09'),
(1122, 71, 189, 'hospital', '2023-07-16 08:32:58'),
(1123, 71, 184, 'hospital', '2023-07-16 08:33:23'),
(1124, 71, 196, 'hospital', '2023-07-16 08:34:22'),
(1125, 71, 195, 'hospital', '2023-07-16 08:35:05'),
(1126, 71, 195, 'hospital', '2023-07-16 08:36:08'),
(1127, 71, 188, 'hospital', '2023-07-16 08:36:50'),
(1128, 71, 185, 'hospital', '2023-07-16 08:37:22'),
(1129, 71, 186, 'hospital', '2023-07-16 08:37:50'),
(1130, 71, 181, 'hospital', '2023-07-16 08:38:41'),
(1131, 70, 193, 'hospital', '2023-07-16 15:25:30'),
(1132, 70, 193, 'hospital', '2023-07-16 15:25:30'),
(1133, 70, 108, 'doctor', '2023-07-16 15:25:33'),
(1134, 9, 190, 'hospital', '2023-07-16 15:26:03'),
(1135, 9, 190, 'hospital', '2023-07-16 15:26:03'),
(1136, 9, 99, 'doctor', '2023-07-16 15:26:11'),
(1137, 9, 98, 'doctor', '2023-07-16 15:26:23'),
(1138, 9, 98, 'doctor', '2023-07-16 15:26:23'),
(1139, 9, 92, 'doctor', '2023-07-16 18:00:15'),
(1140, 9, 92, 'doctor', '2023-07-16 18:37:39'),
(1141, 9, 193, 'hospital', '2023-07-16 18:38:29'),
(1142, 59, 193, 'hospital', '2023-07-17 08:42:18'),
(1143, 59, 106, 'doctor', '2023-07-17 08:42:29'),
(1144, 59, 193, 'hospital', '2023-07-19 08:49:03'),
(1145, 59, 106, 'doctor', '2023-07-19 08:49:35'),
(1146, 73, 183, 'hospital', '2023-07-19 18:09:48'),
(1147, 73, 183, 'hospital', '2023-07-19 18:09:48'),
(1148, 59, 193, 'hospital', '2023-07-21 16:53:42'),
(1149, 59, 106, 'doctor', '2023-07-21 16:53:57'),
(1150, 3, 193, 'hospital', '2023-07-23 18:30:09'),
(1151, 3, 106, 'doctor', '2023-07-23 18:30:13'),
(1152, 74, 193, 'hospital', '2023-07-25 09:16:46'),
(1153, 74, 106, 'doctor', '2023-07-25 09:16:51'),
(1154, 74, 193, 'hospital', '2023-07-25 09:18:58'),
(1155, 74, 106, 'doctor', '2023-07-25 09:19:03'),
(1156, 74, 193, 'hospital', '2023-07-25 17:08:43'),
(1157, 74, 106, 'doctor', '2023-07-25 17:08:55'),
(1158, 74, 193, 'hospital', '2023-07-26 17:02:50'),
(1159, 74, 106, 'doctor', '2023-07-26 17:02:54'),
(1160, 3, 193, 'hospital', '2023-07-27 18:22:14'),
(1161, 3, 193, 'hospital', '2023-07-27 18:22:35'),
(1162, 3, 106, 'doctor', '2023-07-27 18:22:41'),
(1163, 75, 193, 'hospital', '2023-07-27 19:15:53'),
(1164, 75, 106, 'doctor', '2023-07-27 19:16:12'),
(1165, 9, 92, 'doctor', '2023-07-27 19:47:51'),
(1166, 3, 193, 'hospital', '2023-07-27 20:15:38'),
(1167, 3, 193, 'hospital', '2023-07-27 20:15:39'),
(1168, 3, 106, 'doctor', '2023-07-27 20:15:42'),
(1169, 69, 194, 'hospital', '2023-07-29 11:23:19'),
(1170, 3, 193, 'hospital', '2023-07-30 08:33:36'),
(1171, 3, 106, 'doctor', '2023-07-30 08:33:41'),
(1172, 9, 102, 'doctor', '2023-07-30 08:37:45'),
(1173, 2, 187, 'hospital', '2023-08-06 13:38:14'),
(1174, 77, 193, 'hospital', '2023-08-06 14:23:59'),
(1175, 9, 186, 'hospital', '2023-08-07 03:41:44'),
(1176, 9, 186, 'hospital', '2023-08-07 03:42:09'),
(1177, 9, 191, 'hospital', '2023-08-07 03:42:52'),
(1178, 9, 112, 'doctor', '2023-08-07 03:43:10'),
(1179, 9, 191, 'hospital', '2023-08-07 03:43:38'),
(1180, 9, 92, 'doctor', '2023-08-07 03:45:01'),
(1181, 9, 189, 'hospital', '2023-08-07 03:45:47'),
(1182, 9, 92, 'doctor', '2023-08-07 03:46:18'),
(1183, 2, 193, 'hospital', '2023-08-07 17:33:34'),
(1184, 2, 193, 'hospital', '2023-08-07 17:33:34'),
(1185, 2, 181, 'hospital', '2023-08-10 11:21:38'),
(1186, 2, 181, 'hospital', '2023-08-10 11:21:38'),
(1187, 2, 181, 'hospital', '2023-08-10 11:21:38'),
(1188, 2, 181, 'hospital', '2023-08-10 11:21:38'),
(1189, 2, 181, 'hospital', '2023-08-10 11:21:38'),
(1190, 2, 181, 'hospital', '2023-08-10 11:21:38'),
(1191, 2, 181, 'hospital', '2023-08-10 11:21:39'),
(1192, 77, 181, 'hospital', '2023-08-10 11:21:44'),
(1193, 77, 80, 'doctor', '2023-08-10 11:21:47'),
(1194, 2, 181, 'hospital', '2023-08-10 11:22:00'),
(1195, 2, 181, 'hospital', '2023-08-10 11:22:00'),
(1196, 2, 181, 'hospital', '2023-08-10 11:22:00'),
(1197, 9, 80, 'doctor', '2023-08-10 11:25:45'),
(1198, 9, 80, 'doctor', '2023-08-10 11:25:45'),
(1199, 9, 80, 'doctor', '2023-08-10 11:25:45'),
(1200, 9, 80, 'doctor', '2023-08-10 11:25:45'),
(1201, 2, 193, 'hospital', '2023-08-10 11:30:36'),
(1202, 77, 181, 'hospital', '2023-08-10 11:36:26'),
(1203, 77, 192, 'hospital', '2023-08-10 15:28:14'),
(1204, 77, 101, 'doctor', '2023-08-10 15:28:20'),
(1205, 77, 193, 'hospital', '2023-08-12 19:28:34'),
(1206, 77, 106, 'doctor', '2023-08-12 19:28:44'),
(1207, 77, 181, 'hospital', '2023-08-12 19:29:02'),
(1208, 77, 80, 'doctor', '2023-08-12 19:29:07'),
(1209, 77, 193, 'hospital', '2023-08-12 20:39:22'),
(1210, 77, 193, 'hospital', '2023-08-12 20:39:25'),
(1211, 77, 106, 'doctor', '2023-08-12 20:39:38'),
(1212, 77, 181, 'hospital', '2023-08-14 15:10:29'),
(1213, 77, 80, 'doctor', '2023-08-14 15:10:58'),
(1214, 77, 186, 'hospital', '2023-08-14 19:40:39'),
(1215, 77, 89, 'doctor', '2023-08-14 19:41:25'),
(1216, 77, 189, 'hospital', '2023-08-14 19:55:53'),
(1217, 77, 97, 'doctor', '2023-08-14 19:56:11'),
(1218, 77, 193, 'hospital', '2023-08-16 19:45:00'),
(1219, 77, 106, 'doctor', '2023-08-16 19:45:09'),
(1220, 77, 106, 'doctor', '2023-08-16 19:45:13'),
(1221, 77, 193, 'hospital', '2023-08-17 09:29:12'),
(1222, 77, 106, 'doctor', '2023-08-17 09:29:21'),
(1223, 77, 181, 'hospital', '2023-08-19 07:40:42'),
(1224, 77, 181, 'hospital', '2023-08-19 07:41:56'),
(1225, 77, 193, 'hospital', '2023-08-19 17:26:14'),
(1226, 77, 193, 'hospital', '2023-08-19 20:18:09'),
(1227, 77, 193, 'hospital', '2023-08-26 18:08:52'),
(1228, 77, 106, 'doctor', '2023-08-26 18:09:10'),
(1229, 77, 106, 'doctor', '2023-08-26 18:09:14'),
(1230, 77, 193, 'hospital', '2023-08-28 09:02:28'),
(1231, 77, 106, 'doctor', '2023-08-28 09:02:31'),
(1232, 3, 192, 'hospital', '2023-08-28 09:03:41'),
(1233, 78, 193, 'hospital', '2023-08-28 09:07:22'),
(1234, 78, 106, 'doctor', '2023-08-28 09:07:32'),
(1235, 77, 193, 'hospital', '2023-08-29 08:48:22'),
(1236, 77, 106, 'doctor', '2023-08-29 08:48:30'),
(1237, 3, 188, 'hospital', '2023-08-29 12:14:32'),
(1238, 69, 185, 'hospital', '2023-08-31 06:44:11'),
(1239, 9, 186, 'hospital', '2023-09-05 08:11:29'),
(1240, 9, 186, 'hospital', '2023-09-05 08:11:55'),
(1241, 9, 191, 'hospital', '2023-09-05 08:12:35'),
(1242, 9, 87, 'doctor', '2023-09-05 08:13:01'),
(1243, 9, 82, 'doctor', '2023-09-05 08:13:46'),
(1244, 9, 191, 'hospital', '2023-09-05 08:14:30'),
(1245, 9, 186, 'hospital', '2023-09-05 08:15:52'),
(1246, 3, 188, 'hospital', '2023-09-11 18:34:10'),
(1247, 3, 92, 'doctor', '2023-09-11 18:34:18'),
(1248, 3, 189, 'hospital', '2023-09-15 14:39:02'),
(1249, 3, 184, 'hospital', '2023-09-15 14:39:07'),
(1250, 79, 183, 'hospital', '2023-09-15 14:39:13'),
(1251, 9, 110, 'doctor', '2023-09-15 14:39:44'),
(1252, 79, 187, 'hospital', '2023-09-15 14:39:45'),
(1253, 9, 110, 'doctor', '2023-09-15 14:39:55'),
(1254, 9, 83, 'doctor', '2023-09-15 14:40:09'),
(1255, 9, 183, 'hospital', '2023-09-15 14:40:13'),
(1256, 9, 84, 'doctor', '2023-09-15 14:40:14'),
(1257, 9, 183, 'hospital', '2023-09-15 14:40:30'),
(1258, 9, 83, 'doctor', '2023-09-15 14:40:44'),
(1259, 9, 183, 'hospital', '2023-09-15 14:41:42'),
(1260, 9, 117, 'doctor', '2023-09-15 14:42:03'),
(1261, 9, 187, 'hospital', '2023-09-15 14:42:50'),
(1262, 9, 183, 'hospital', '2023-09-15 14:42:59'),
(1263, 9, 83, 'doctor', '2023-09-15 14:43:11'),
(1264, 9, 117, 'doctor', '2023-09-15 14:43:30'),
(1265, 3, 193, 'hospital', '2023-09-21 11:21:19'),
(1266, 3, 193, 'hospital', '2023-09-21 11:21:28'),
(1267, 82, 193, 'hospital', '2023-09-23 06:31:02'),
(1268, 3, 193, 'hospital', '2023-09-30 08:23:25'),
(1269, 3, 193, 'hospital', '2023-09-30 08:23:27'),
(1270, 9, 82, 'doctor', '2023-09-30 08:23:56'),
(1271, 9, 82, 'doctor', '2023-09-30 08:23:58'),
(1272, 83, 193, 'hospital', '2023-10-01 14:29:13'),
(1273, 9, 186, 'hospital', '2023-10-04 04:19:55'),
(1274, 9, 186, 'hospital', '2023-10-04 04:20:34'),
(1275, 9, 191, 'hospital', '2023-10-04 04:21:19'),
(1276, 9, 185, 'hospital', '2023-10-04 04:23:59'),
(1277, 3, 182, 'hospital', '2023-10-09 23:43:13'),
(1278, 3, 81, 'doctor', '2023-10-09 23:43:29'),
(1279, 3, 81, 'doctor', '2023-10-09 23:43:37'),
(1280, 3, 81, 'doctor', '2023-10-09 23:43:39'),
(1281, 3, 183, 'hospital', '2023-10-09 23:45:03'),
(1282, 9, 183, 'hospital', '2023-10-09 23:45:08'),
(1283, 9, 83, 'doctor', '2023-10-09 23:45:15'),
(1284, 9, 84, 'doctor', '2023-10-09 23:45:17'),
(1285, 9, 83, 'doctor', '2023-10-09 23:45:19'),
(1286, 9, 83, 'doctor', '2023-10-09 23:45:21'),
(1287, 9, 83, 'doctor', '2023-10-09 23:45:27'),
(1288, 77, 193, 'hospital', '2023-10-14 06:59:50'),
(1289, 77, 106, 'doctor', '2023-10-14 07:00:03'),
(1290, 82, 186, 'hospital', '2023-10-18 02:34:24'),
(1291, 77, 184, 'hospital', '2023-10-18 10:22:14'),
(1292, 77, 184, 'hospital', '2023-10-18 10:22:14'),
(1293, 77, 85, 'doctor', '2023-10-18 10:22:20'),
(1294, 77, 193, 'hospital', '2023-10-18 15:47:11'),
(1295, 77, 106, 'doctor', '2023-10-18 15:47:16'),
(1296, 77, 192, 'hospital', '2023-10-18 15:47:52'),
(1297, 77, 102, 'doctor', '2023-10-18 15:47:58'),
(1298, 77, 193, 'hospital', '2023-10-24 15:50:20'),
(1299, 77, 106, 'doctor', '2023-10-24 15:50:40'),
(1300, 86, 193, 'hospital', '2023-10-26 07:36:08'),
(1301, 86, 193, 'hospital', '2023-10-26 07:36:22'),
(1302, 86, 106, 'doctor', '2023-10-26 07:36:25'),
(1303, 86, 108, 'doctor', '2023-10-26 07:36:43'),
(1304, 86, 107, 'doctor', '2023-10-26 07:36:50'),
(1305, 3, 193, 'hospital', '2023-10-31 09:14:04'),
(1306, 3, 106, 'doctor', '2023-10-31 09:14:06'),
(1307, 3, 106, 'doctor', '2023-10-31 09:16:31'),
(1308, 3, 193, 'hospital', '2023-11-01 17:34:09'),
(1309, 3, 106, 'doctor', '2023-11-01 17:34:21'),
(1310, 3, 106, 'doctor', '2023-11-01 17:38:12'),
(1311, 3, 186, 'hospital', '2023-11-01 17:39:23'),
(1312, 3, 193, 'hospital', '2023-11-01 18:04:19'),
(1313, 3, 193, 'hospital', '2023-11-01 18:04:19'),
(1314, 3, 108, 'doctor', '2023-11-01 18:04:38'),
(1315, 9, 186, 'hospital', '2023-11-02 04:48:37'),
(1316, 9, 186, 'hospital', '2023-11-02 04:49:02'),
(1317, 9, 191, 'hospital', '2023-11-02 04:49:37'),
(1318, 9, 87, 'doctor', '2023-11-02 04:49:58'),
(1319, 9, 186, 'hospital', '2023-11-02 04:50:28'),
(1320, 9, 186, 'hospital', '2023-11-02 04:51:06'),
(1321, 3, 184, 'hospital', '2023-11-13 20:06:26'),
(1322, 3, 85, 'doctor', '2023-11-13 20:06:38'),
(1323, 77, 193, 'hospital', '2023-11-18 06:41:47'),
(1324, 77, 106, 'doctor', '2023-11-18 06:41:50'),
(1325, 77, 193, 'hospital', '2023-11-21 16:26:42'),
(1326, 77, 106, 'doctor', '2023-11-21 16:26:55'),
(1327, 77, 193, 'hospital', '2023-11-24 16:08:41'),
(1328, 77, 106, 'doctor', '2023-11-24 16:08:45'),
(1329, 77, 186, 'hospital', '2023-11-24 16:41:18'),
(1330, 77, 88, 'doctor', '2023-11-24 16:41:22'),
(1331, 88, 193, 'hospital', '2023-11-28 10:37:57'),
(1332, 88, 106, 'doctor', '2023-11-28 10:38:08'),
(1333, 77, 193, 'hospital', '2023-11-28 10:40:53'),
(1334, 77, 106, 'doctor', '2023-11-28 10:40:56'),
(1335, 9, 186, 'hospital', '2023-12-01 04:06:08'),
(1336, 9, 186, 'hospital', '2023-12-01 04:06:46'),
(1337, 9, 189, 'hospital', '2023-12-01 04:08:20'),
(1338, 9, 191, 'hospital', '2023-12-01 04:08:26'),
(1339, 9, 191, 'hospital', '2023-12-01 04:09:05'),
(1340, 30, 193, 'hospital', '2023-12-06 17:48:28'),
(1341, 30, 106, 'doctor', '2023-12-06 17:48:36'),
(1342, 69, 186, 'hospital', '2023-12-10 07:52:21'),
(1343, 69, 186, 'hospital', '2023-12-10 07:52:21'),
(1344, 69, 186, 'hospital', '2023-12-10 07:52:21'),
(1345, 9, 186, 'hospital', '2023-12-18 04:58:45'),
(1346, 9, 186, 'hospital', '2023-12-18 04:59:09'),
(1347, 9, 191, 'hospital', '2023-12-18 04:59:43'),
(1348, 9, 89, 'doctor', '2023-12-18 05:00:07'),
(1349, 9, 191, 'hospital', '2023-12-18 05:01:10'),
(1350, 9, 82, 'doctor', '2023-12-18 17:57:25'),
(1351, 9, 183, 'hospital', '2023-12-18 17:57:47'),
(1352, 9, 84, 'doctor', '2023-12-18 17:57:48'),
(1353, 9, 190, 'hospital', '2024-01-10 15:00:10'),
(1354, 9, 81, 'doctor', '2024-01-10 15:01:07'),
(1355, 9, 83, 'doctor', '2024-01-10 17:03:06'),
(1356, 9, 83, 'doctor', '2024-01-10 17:03:18'),
(1357, 9, 80, 'doctor', '2024-01-10 17:08:18'),
(1358, 9, 191, 'hospital', '2024-01-10 17:08:32'),
(1359, 9, 100, 'doctor', '2024-01-10 17:08:43'),
(1360, 9, 91, 'doctor', '2024-01-10 17:09:07'),
(1361, 9, 85, 'doctor', '2024-01-15 07:55:21'),
(1362, 9, 186, 'hospital', '2024-01-16 05:11:30'),
(1363, 9, 186, 'hospital', '2024-01-16 05:11:54'),
(1364, 9, 191, 'hospital', '2024-01-16 05:12:28'),
(1365, 9, 89, 'doctor', '2024-01-16 05:12:52'),
(1366, 9, 186, 'hospital', '2024-01-16 05:13:57'),
(1367, 9, 186, 'hospital', '2024-01-16 05:14:15'),
(1368, 9, 189, 'hospital', '2024-01-16 05:15:30'),
(1369, 9, 189, 'hospital', '2024-01-16 05:16:10'),
(1370, 9, 189, 'hospital', '2024-01-16 05:16:15'),
(1371, 3, 193, 'hospital', '2024-01-22 08:57:28'),
(1372, 3, 106, 'doctor', '2024-01-22 08:57:32'),
(1373, 91, 193, 'hospital', '2024-01-22 16:30:20'),
(1374, 91, 108, 'doctor', '2024-01-22 16:30:23'),
(1375, 91, 193, 'hospital', '2024-01-22 18:27:13'),
(1376, 91, 106, 'doctor', '2024-01-22 18:27:24'),
(1377, 91, 194, 'hospital', '2024-01-25 07:24:52'),
(1378, 91, 193, 'hospital', '2024-01-28 17:52:15'),
(1379, 91, 193, 'hospital', '2024-01-28 17:52:15'),
(1380, 91, 106, 'doctor', '2024-01-28 17:52:26'),
(1381, 9, 86, 'doctor', '2024-01-28 18:46:27'),
(1382, 9, 182, 'hospital', '2024-01-28 18:47:19'),
(1383, 91, 193, 'hospital', '2024-02-16 20:24:16'),
(1384, 91, 108, 'doctor', '2024-02-16 20:24:20'),
(1385, 91, 193, 'hospital', '2024-02-22 10:18:28'),
(1386, 3, 194, 'hospital', '2024-02-27 10:14:50'),
(1387, 3, 110, 'doctor', '2024-02-27 10:14:56'),
(1388, 3, 196, 'hospital', '2024-02-27 10:19:48'),
(1389, 3, 193, 'hospital', '2024-03-01 03:41:57'),
(1390, 3, 108, 'doctor', '2024-03-01 03:42:04'),
(1391, 3, 107, 'doctor', '2024-03-01 03:42:05'),
(1392, 3, 108, 'doctor', '2024-03-01 03:42:07'),
(1393, 3, 192, 'hospital', '2024-03-01 03:43:10'),
(1394, 9, 83, 'doctor', '2024-03-01 03:43:22'),
(1395, 9, 83, 'doctor', '2024-03-01 03:43:28'),
(1396, 9, 83, 'doctor', '2024-03-01 03:43:30'),
(1397, 9, 187, 'hospital', '2024-03-01 03:44:32'),
(1398, 9, 194, 'hospital', '2024-03-01 03:44:34'),
(1399, 9, 185, 'hospital', '2024-03-01 03:44:46'),
(1400, 9, 86, 'doctor', '2024-03-01 03:44:52'),
(1401, 9, 86, 'doctor', '2024-03-01 03:44:54'),
(1402, 9, 86, 'doctor', '2024-03-01 03:44:59'),
(1403, 9, 86, 'doctor', '2024-03-01 03:45:00'),
(1404, 9, 183, 'hospital', '2024-03-01 03:45:08'),
(1405, 9, 192, 'hospital', '2024-03-01 03:45:10');

-- --------------------------------------------------------

--
-- Table structure for table `app_patient`
--

CREATE TABLE `app_patient` (
  `id` int(11) NOT NULL,
  `auto_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `hospital_id` int(11) NOT NULL,
  `doctor_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `tell` varchar(50) NOT NULL,
  `address` varchar(100) NOT NULL,
  `dob` date NOT NULL,
  `mother` varchar(100) NOT NULL,
  `gender` varchar(50) NOT NULL,
  `payment_tell` varchar(50) NOT NULL,
  `amount` double NOT NULL,
  `status` int(11) NOT NULL,
  `evc_response` varchar(150) NOT NULL,
  `description` text NOT NULL,
  `user_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `app_patient`
--

INSERT INTO `app_patient` (`id`, `auto_id`, `company_id`, `hospital_id`, `doctor_id`, `name`, `tell`, `address`, `dob`, `mother`, `gender`, `payment_tell`, `amount`, `status`, `evc_response`, `description`, `user_id`, `date`, `action_date`, `modified_date`) VALUES
(1, 1, 1, 27, 6, 'Abdihamid Hussein Geddi', '615190777', 'Somali Mogadishu Holwdaag', '1989-05-01', 'Nuurto Maxamud', 'Male', '615190777', 10, 0, 'Lama yaqaan', 'Dr Hussain Cabdulaziz Abdulkadir (FATXI)-Cudurada ', 0, '2022-12-27', '2022-12-27 08:20:49', '2022-12-27 08:20:49'),
(2, 2, 1, 27, 6, 'Abdihamid Hussein Geddi', '615190777', 'Somali Mogadishu Holwdaag', '1989-05-01', 'Nuurto Maxamud', 'Male', '615190777', 10, 0, 'Lama yaqaan', 'Dr Hussain Cabdulaziz Abdulkadir (FATXI)-Cudurada ', 0, '2022-12-27', '2022-12-27 08:21:04', '2022-12-27 08:21:04'),
(3, 3, 1, 27, 6, 'Abdihamid Hussein Geddi', '615190777', 'Somali Mogadishu Holwdaag', '1989-05-01', 'Nuurto Maxamud', 'Male', '615190777', 10, 0, 'Lama yaqaan', 'Dr Hussain Cabdulaziz Abdulkadir (FATXI)-Cudurada ', 0, '2022-12-27', '2022-12-27 08:21:47', '2022-12-27 08:21:47'),
(4, 4, 1, 27, 6, 'Abdihamid Hussein Geddi', '2147483647', 'Taleex Hodan Mogadishu Somalia', '1989-05-01', 'Nuurto Maxamud', 'Male', '615190777', 10, 0, 'Lama yaqaan', 'Cudurada Guud-Somali Syrian Hospital', 0, '2022-12-27', '2022-12-27 08:23:53', '2022-12-27 08:23:53'),
(5, 5, 1, 27, 6, 'Abdihamid Hussein Geddi', '2147483647', 'Taleex Hodan Mogadishu Somalia', '1989-05-01', 'Nuurto Maxamud', 'Male', '615190777', 10, 0, 'Lama yaqaan', 'Cudurada Guud-Somali Syrian Hospital', 0, '2022-12-27', '2022-12-27 08:24:31', '2022-12-27 08:24:31'),
(6, 6, 1, 27, 6, 'Abdihamid Hussein Geddi', '252615190777', 'Taleex Hodan Mogadishu Somalia', '1989-05-01', 'Nuurto Maxamud', 'Male', '615190777', 10, 0, 'Lama yaqaan', 'Cudurada Guud-Somali Syrian Hospital', 0, '2022-12-27', '2022-12-27 08:25:07', '2022-12-27 08:25:07'),
(7, 7, 1, 27, 6, 'Abdihamid Hussein Geddi', '252615190777', 'Taleex Hodan Mogadishu Somalia', '1989-05-01', 'Nuurto Maxamud', 'Male', '615190777', 10, 0, 'Lama yaqaan', 'Cudurada Guud-Somali Syrian Hospital', 0, '2022-12-27', '2022-12-27 08:25:19', '2022-12-27 08:25:19'),
(8, 8, 1, 27, 6, 'Abdihamid Hussein Geddi', '252615190777', 'Taleex Hodan Mogadishu Somalia', '1989-05-01', 'Nuurto Maxamud', 'Male', '612692022', 10, 0, 'Lama yaqaan', 'Cudurada Guud-Somali Syrian Hospital', 0, '2022-12-27', '2022-12-27 08:28:34', '2022-12-27 08:28:34'),
(9, 9, 1, 27, 6, 'Abdihamid Hussein Geddi', '252615190777', 'Taleex Hodan Mogadishu Somalia', '1989-05-01', 'Nuurto Maxamud', 'Male', '612692022', 10, 0, 'Lama yaqaan', 'Cudurada Guud-Somali Syrian Hospital', 0, '2022-12-27', '2022-12-27 08:29:14', '2022-12-27 08:29:14'),
(10, 10, 1, 27, 1, 'Abdirahman Sh ibrahim', '612692022', 'Dayniile', '2002-01-01', 'Nuurto Maxamud', 'Male', '612692022', 10, 0, 'Lama yaqaan', 'Ilkaha-Somali Syrian Hospital', 0, '2022-12-28', '2022-12-28 07:32:58', '2022-12-28 07:32:58'),
(11, 11, 1, 27, 1, 'Abdirahman Sh ibrahim', '612692022', 'Dayniile', '2002-01-01', 'Nuurto Maxamud', 'Male', '612692022', 10, 0, 'Lama yaqaan', 'Ilkaha-Somali Syrian Hospital', 0, '2022-12-28', '2022-12-28 07:33:54', '2022-12-28 07:33:54'),
(12, 12, 1, 27, 1, 'Abdirahman Sh ibrahim', '612692022', 'Dayniile', '2002-01-01', 'Nuurto Maxamud', 'Male', '612692022', 10, 0, 'Wuu diiday', 'Ilkaha-Somali Syrian Hospital', 0, '2022-12-28', '2022-12-28 08:12:16', '2022-12-28 08:12:16'),
(13, 13, 1, 27, 1, 'Abdirahman Sh ibrahim', '612692022', 'Dayniile', '2002-01-01', 'Nuurto Maxamud', 'Male', '612692022', 10, 0, 'Lama yaqaan', 'Ilkaha-Somali Syrian Hospital', 0, '2022-12-28', '2022-12-28 08:16:01', '2022-12-28 08:16:01'),
(14, 14, 1, 27, 1, 'Abdirahman Sh ibrahim', '612692022', 'Dayniile', '2002-01-01', 'Nuurto Maxamud', 'Male', '612692022', 10, 0, 'Lama yaqaan', 'Ilkaha-Somali Syrian Hospital', 0, '2022-12-28', '2022-12-28 08:16:52', '2022-12-28 08:16:52'),
(15, 15, 1, 27, 1, 'Abdirahman Sh ibrahim', '612692022', 'Dayniile', '2002-01-01', 'Nuurto Maxamud', 'Male', '612692022', 10, 0, 'Lama yaqaan', 'Ilkaha-Somali Syrian Hospital', 0, '2022-12-28', '2022-12-28 08:17:38', '2022-12-28 08:17:38'),
(16, 16, 1, 27, 1, 'Abdirahman Sh ibrahim', '612692022', 'Dayniile', '2002-01-01', 'Nuurto Maxamud', 'Male', '615190777', 10, 1, 'Ok', 'Ilkaha-Somali Syrian Hospital', 0, '2022-12-28', '2022-12-28 08:20:25', '2022-12-28 08:20:25'),
(17, 17, 1, 27, 6, 'Abdirahman Sh ibrahim', '612692022', 'Dayniile Gubta', '2002-01-01', 'Nuurto Sh Mohamud', 'Male', '615190777', 10, 0, '', '', 0, '2022-12-28', '2022-12-28 08:59:55', '2022-12-28 08:59:55'),
(18, 18, 1, 27, 6, 'Abdirahman Sh ibrahim', '612692022', 'Dayniile Gubta', '2002-01-01', 'Nuurto Sh Mohamud', 'Male', '615190777', 10, 1, '', '', 0, '2022-12-28', '2022-12-28 09:00:39', '2022-12-28 09:00:39'),
(19, 19, 1, 27, 4, 'Abdirahman Sh ibrahim', '612692022', 'Dayniile', '2022-01-01', 'Nuurto Maxamud', 'Male', '615190777', 10, 0, 'Lama yaqaan', 'Cunaha-Somali Syrian Hospital', 0, '2022-12-28', '2022-12-28 09:02:31', '2022-12-28 09:02:31'),
(20, 20, 1, 27, 4, 'Abdirahman Sh ibrahim', '612692022', 'Dayniile', '2022-01-01', 'Nuurto Maxamud', 'Male', '615190777', 10, 0, 'Lama yaqaan', 'Cunaha-Somali Syrian Hospital', 0, '2022-12-28', '2022-12-28 09:03:30', '2022-12-28 09:03:30'),
(21, 21, 1, 27, 4, 'Abdirahman Sh ibrahim', '612692022', 'Dayniile', '2022-01-01', 'Nuurto Maxamud', 'Male', '615190777', 10, 0, 'Lama yaqaan', 'Cunaha-Somali Syrian Hospital', 0, '2022-12-28', '2022-12-28 09:04:20', '2022-12-28 09:04:20'),
(22, 22, 1, 27, 4, 'Abdirahman Sh ibrahim', '612692022', 'Dayniile', '2022-01-01', 'Nuurto Maxamud', 'Male', '615190777', 10, 1, 'Ok', 'Cunaha-Somali Syrian Hospital', 0, '2022-12-28', '2022-12-28 09:04:33', '2022-12-28 09:04:33'),
(23, 23, 1, 27, 4, 'Abdirahman Sh ibrahim', '612692022', 'Dayniile', '2002-01-01', 'Nuurto Maxamud', 'Male', '615190777', 10, 1, 'Ok', 'Cunaha-Somali Syrian Hospital', 0, '2022-12-28', '2022-12-28 09:09:04', '2022-12-28 09:09:04'),
(24, 24, 1, 27, 4, 'Abdirahman Sh ibrahim', '612692022', 'Dayniile', '2002-01-01', 'Nuurto Maxamud', 'Male', '615190777', 10, 1, 'Ok', 'Cunaha-Somali Syrian Hospital', 0, '2022-12-28', '2022-12-28 09:10:52', '2022-12-28 09:10:52'),
(25, 25, 1, 27, 4, 'Abdirahman Sh ibrahim', '612692022', 'Dayniile', '2002-01-01', 'Nuurto Maxamud', 'Male', '615190777', 10, 1, 'Ok', 'Cunaha-Somali Syrian Hospital', 0, '2022-12-28', '2022-12-28 09:12:28', '2022-12-28 09:12:28'),
(26, 26, 1, 27, 2, 'Abdihamid Hussein Gedi', '615190777', 'Ankara', '1989-05-01', 'Nuurto Mohamud', 'Male', '615190777', 10, 1, 'Ok', 'Dheefshiidka-Somali Syrian Hospital', 0, '2022-12-28', '2022-12-28 16:07:30', '2022-12-28 16:07:30'),
(27, 27, 1, 27, 2, 'Abdihamid Hussein Gedi', '615190777', 'Ankara', '1989-05-01', 'Nuurto Mohamud', 'Male', '615190777', 10, 0, 'Lama yaqaan', 'Dheefshiidka-Somali Syrian Hospital', 0, '2022-12-28', '2022-12-28 16:08:03', '2022-12-28 16:08:03'),
(28, 28, 1, 27, 2, 'Mohamed Abdihamid Hussein', '615190777', 'Ankar', '2017-02-28', 'Iqro Hassan mohamud', 'Male', '615190777', 10, 1, 'Ok', 'Dheefshiidka-Somali Syrian Hospital', 0, '2022-12-28', '2022-12-28 16:10:00', '2022-12-28 16:10:00'),
(29, 29, 1, 27, 4, 'Abdihamid Hussein Geddi', '252615190777', 'Somali Mogadishu Holwdaag', '1989-07-06', '', 'Male', '615190777', 10, 0, 'Lama yaqaan', 'Cunaha-Somali Syrian Hospital', 0, '2022-12-29', '2022-12-29 08:23:05', '2022-12-29 08:23:05'),
(30, 30, 1, 27, 4, 'Abdihamid Hussein Geddi', '252615190777', 'Somali Mogadishu Holwdaag', '1989-01-01', 'Nuurto Maxamud', 'Male', '615190777', 10, 0, 'Lama yaqaan', 'Cunaha-Somali Syrian Hospital', 0, '2022-12-29', '2022-12-29 08:34:20', '2022-12-29 08:34:20'),
(31, 31, 1, 27, 4, 'Abdihamid Hussein Geddi', '252615190777', 'Somali Mogadishu Holwdaag', '1988-01-13', 'Nuurto Maxamud', 'Male', '615190777', 10, 0, 'Lama yaqaan', 'Cunaha-Somali Syrian Hospital', 0, '2022-12-29', '2022-12-29 08:48:09', '2022-12-29 08:48:09'),
(32, 32, 1, 27, 4, 'Abdihamid Hussein Geddi', '252615190777', 'Somali Mogadishu Holwdaag', '1988-01-01', 'Nuurto Maxamud', 'Male', '612692022', 10, 0, 'Wuu diiday', 'Cunaha-Somali Syrian Hospital', 0, '2022-12-29', '2022-12-29 08:53:43', '2022-12-29 08:53:43'),
(33, 33, 1, 15, 9, 'Abdihamid Hussein Geddi', '252615190777', 'Somali Mogadishu Holwdaag', '1989-05-01', 'Nuurto Maxamud', 'Male', '615190777', 13, 0, 'Lama yaqaan', 'Dhakhtarka Ilkaha-Aadan-Ade Hospital', 0, '2022-12-30', '2022-12-30 07:18:20', '2022-12-30 07:18:20'),
(34, 34, 1, 15, 9, 'Abdihamid Hussein Geddi', '252615190777', 'Somali Mogadishu Holwdaag', '1989-05-01', 'Nuurto Maxamud', 'Male', '615190777', 13, 1, 'Ok', 'Dhakhtarka Ilkaha-Aadan-Ade Hospital', 0, '2022-12-30', '2022-12-30 07:18:38', '2022-12-30 07:18:38'),
(35, 35, 1, 15, 9, 'Abdihamid Hussein Geddi', '252615190777', 'Somali Mogadishu Holwdaag', '1989-05-01', 'Nuurto Maxamud', 'Male', '615190777', 13, 1, 'Ok', 'Dhakhtarka Ilkaha-Aadan-Ade Hospital', 0, '2022-12-30', '2022-12-30 07:22:52', '2022-12-30 07:22:52'),
(36, 36, 1, 15, 9, 'Abdihamid Hussein Geddi', '615190777', 'Somali Mogadishu Holwdaag', '1989-05-01', 'Nuurto Maxamud', 'Male', '615190777', 13, 1, 'Ok', 'Dhakhtarka Ilkaha-Aadan-Ade Hospital', 0, '2022-12-30', '2022-12-30 07:24:08', '2022-12-30 07:24:08'),
(37, 37, 1, 150, 20, 'Abdihamid Hussein Geddi', '615190777', 'Gudbta Dayniile', '1989-05-01', 'Nuurto Maxamud Axmed', 'Male', '615190777', 10, 1, 'Ok', 'Dhakhtarka Caruurta-Digfeer - Mogadishu Somali Turkey', 0, '2023-01-01', '2023-01-01 09:35:17', '2023-01-01 09:35:17'),
(38, 38, 1, 23, 33, 'Maxamed', '659328878', 'Burco', '2023-01-06', 'Maxamed', 'Male', '659328877', 3, 0, 'Telkaa qaldan 659328878', 'Dhakhtarka Cudurada Guud-Soomali sudanes', 0, '2023-01-06', '2023-01-06 05:47:51', '2023-01-06 05:47:51'),
(39, 39, 1, 176, 50, 'Maxamed', '634432380', 'Burco', '2023-01-06', 'Nuura', 'Male', '85000', 85003, 0, 'Telkaa qaldan 634432380', 'Dhakhtarka Qaliimada Guud-Needle hospital', 0, '2023-01-06', '2023-01-06 15:05:49', '2023-01-06 15:05:49'),
(40, 40, 1, 176, 50, 'Maxamed', '634432380', 'Burco', '2023-01-06', 'Nuura', 'Male', '659328878', 85003, 0, 'Telkaa qaldan 634432380', 'Dhakhtarka Qaliimada Guud-Needle hospital', 0, '2023-01-06', '2023-01-06 15:07:06', '2023-01-06 15:07:06'),
(41, 41, 1, 161, 76, 'Maxamed', '659328878', 'Bueco', '2023-01-13', 'Xaawo', 'Male', '659328877', 0, 0, 'Lama yaqaan', 'Dhakhtarka Dhimirka-Burco manhal mental center', 0, '2023-01-13', '2023-01-13 06:58:51', '2023-01-13 06:58:51'),
(42, 42, 1, 161, 76, 'Maxamed', '659328878', 'Bueco', '2023-01-13', 'Xaawo', 'Male', '659328877', 0, 0, 'Lama yaqaan', 'Dhakhtarka Dhimirka-Burco manhal mental center', 0, '2023-01-13', '2023-01-13 06:59:43', '2023-01-13 06:59:43'),
(43, 43, 1, 161, 76, 'Maxamed', '659328878', 'Bueco', '2023-01-13', 'Xaawo', 'Male', '659328877', 0, 0, 'Lama yaqaan', 'Dhakhtarka Dhimirka-Burco manhal mental center', 0, '2023-01-13', '2023-01-13 06:59:47', '2023-01-13 06:59:47'),
(44, 44, 1, 161, 76, 'Maxamed', '659328878', 'Bueco', '2023-01-13', 'Xaawo', 'Male', '659328877', 0, 0, 'Lama yaqaan', 'Dhakhtarka Dhimirka-Burco manhal mental center', 0, '2023-01-13', '2023-01-13 06:59:50', '2023-01-13 06:59:50'),
(45, 45, 1, 161, 76, 'Maxamed', '659328878', 'Bueco', '2023-01-13', 'Xaawo', 'Male', '6593288771200', 0, 0, 'Lama yaqaan', 'Dhakhtarka Dhimirka-Burco manhal mental center', 0, '2023-01-13', '2023-01-13 07:00:02', '2023-01-13 07:00:02'),
(46, 46, 1, 161, 76, 'Maxamed', '659328878', 'Bueco', '2023-01-13', 'Xaawo', 'Male', '13', 0, 0, 'Lama yaqaan', 'Dhakhtarka Dhimirka-Burco manhal mental center', 0, '2023-01-13', '2023-01-13 07:00:18', '2023-01-13 07:00:18'),
(47, 47, 1, 161, 76, 'Maxamed', '659328878', 'Bueco', '2023-01-13', 'Xaawo', 'Male', '65932887813', 0, 0, 'Lama yaqaan', 'Dhakhtarka Dhimirka-Burco manhal mental center', 0, '2023-01-13', '2023-01-13 07:00:51', '2023-01-13 07:00:51'),
(48, 48, 1, 150, 20, 'Nuura cali axmed', '659328877', 'Burco', '2023-01-13', 'Faadumo yusuf', 'Male', '659328877', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Digfeer - Mogadishu Somali Turkey', 0, '2023-01-13', '2023-01-13 07:03:56', '2023-01-13 07:03:56'),
(49, 49, 1, 27, 5, 'Hasaan', '6154946466', 'Xamar', '2018-04-04', 'Muna', 'Male', '615476912', 0, 0, 'Lama yaqaan', 'Dhakhtarka Baabasiirka-Somali Syrian Hospital', 0, '2023-01-28', '2023-01-27 21:24:49', '2023-01-27 21:24:49'),
(50, 50, 1, 27, 5, 'Hasaan', '6154946466', 'Xamar', '2018-04-04', 'Muna', 'Male', '615476912', 0, 0, 'Lama yaqaan', 'Dhakhtarka Baabasiirka-Somali Syrian Hospital', 0, '2023-01-28', '2023-01-27 21:25:04', '2023-01-27 21:25:04'),
(51, 51, 1, 27, 5, 'Hasaan', '6154946466', 'Xamar', '2018-04-04', 'Muna', 'Male', '615476912', 0, 0, 'Lama yaqaan', 'Dhakhtarka Baabasiirka-Somali Syrian Hospital', 0, '2023-01-28', '2023-01-27 21:25:07', '2023-01-27 21:25:07'),
(52, 52, 1, 27, 5, 'Hasaan', '615476912', 'Xamar', '2018-04-04', 'Muna', 'Male', '615476912', 0, 0, 'Lama yaqaan', 'Dhakhtarka Baabasiirka-Somali Syrian Hospital', 0, '2023-01-28', '2023-01-27 21:25:19', '2023-01-27 21:25:19'),
(53, 53, 1, 27, 5, 'Hasaan', '615476912', 'Xamar', '2018-04-04', 'Muna', 'Male', '615476912', 0, 0, 'Lama yaqaan', 'Dhakhtarka Baabasiirka-Somali Syrian Hospital', 0, '2023-01-28', '2023-01-27 21:25:23', '2023-01-27 21:25:23'),
(54, 54, 1, 15, 10, 'Hassan', '6154769122', 'Xasan', '2020-04-05', 'Xasan', 'Male', '615476912', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Aadan-Ade Hospital', 0, '2023-01-28', '2023-01-27 21:26:02', '2023-01-27 21:26:02'),
(55, 55, 1, 15, 10, 'Hassan', '6154769122', 'Xasan', '2020-04-05', 'Xasan', 'Male', '615476912', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Aadan-Ade Hospital', 0, '2023-01-28', '2023-01-27 21:26:05', '2023-01-27 21:26:05'),
(56, 56, 1, 15, 10, 'Hassan', '6154769122', 'Xasan', '2020-04-05', 'Xasan', 'Male', '615476912', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Aadan-Ade Hospital', 0, '2023-01-28', '2023-01-27 21:26:11', '2023-01-27 21:26:11'),
(57, 57, 1, 15, 10, 'Abdihamid Hussein Gedi', '615190777', 'Ankara Turkey', '1989-05-05', 'Nuurto Mohamud Ahned', 'Male', '615190777', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Aadan-Ade Hospital', 0, '2023-01-28', '2023-01-28 03:31:06', '2023-01-28 03:31:06'),
(58, 58, 1, 15, 10, 'Abdihamid Hussein Gedi', '615190777', 'Ankara Turkey', '1989-05-05', 'Nuurto Mohamud Ahned', 'Male', '615190777', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Aadan-Ade Hospital', 0, '2023-01-28', '2023-01-28 03:31:44', '2023-01-28 03:31:44'),
(59, 59, 1, 27, 6, 'Abdihamid Hussein gedi', '615190777', 'Dayniile Gubta', '1989-05-01', 'Nuurto Sh Mohamud', 'Male', '615190777', 13, 0, 'db test', 'test', 0, '2023-01-28', '2023-01-28 03:36:02', '2023-01-28 03:36:02'),
(60, 60, 1, 15, 10, 'Abdihamid Hussein Gedi', '615190777', 'Ankara Turkey', '1989-05-05', 'Nuurto Mohamud Ahned', 'Male', '615190777', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Aadan-Ade Hospital', 0, '2023-01-28', '2023-01-28 03:38:40', '2023-01-28 03:38:40'),
(61, 61, 1, 27, 6, 'Abdihamid Hussein gedi', '615190777', 'Dayniile Gubta', '1989-05-01', 'Nuurto Sh Mohamud', 'Male', '615190777', 13, 0, 'db test', 'test', 0, '2023-01-28', '2023-01-28 03:39:49', '2023-01-28 03:39:49'),
(62, 62, 1, 180, 79, 'Maxamed axmed', '639328877', 'Burco', '2013-03-11', 'Xusen xasan', 'Male', '659328877', 0, 0, 'Lama yaqaan', 'Dhakhtarka Maqaarka-Janaale clinic pharmacy', 0, '2023-03-11', '2023-03-11 08:41:25', '2023-03-11 08:41:25'),
(63, 63, 1, 179, 78, 'Maxamed axmed', '659328877', 'Burco', '2023-03-11', 'Nuura xasan', 'Male', '659328878', 0, 0, 'Lama yaqaan', 'Dhakhtarka Ilkaha-Janaale dental pharmacy', 0, '2023-03-11', '2023-03-11 09:20:16', '2023-03-11 09:20:16'),
(64, 64, 1, 179, 78, 'Maxamed axmed', '659328877', 'Burco', '2023-03-11', 'Nuura xasan', 'Male', '659328878', 0, 0, 'Lama yaqaan', 'Dhakhtarka Ilkaha-Janaale dental pharmacy', 0, '2023-03-11', '2023-03-11 09:20:55', '2023-03-11 09:20:55'),
(65, 65, 1, 179, 78, 'Maxamed axmed', '659328877', 'Burco', '2023-03-11', 'Nuura xasan', 'Male', '637866366', 0, 0, 'Lama yaqaan', 'Dhakhtarka Ilkaha-Janaale dental pharmacy', 0, '2023-03-11', '2023-03-11 09:21:20', '2023-03-11 09:21:20'),
(66, 66, 1, 179, 78, 'Maxamed axmed', '659328877', 'Burco', '2023-03-11', 'Nuura xasan', 'Male', '0637866366', 0, 0, 'Lama yaqaan', 'Dhakhtarka Ilkaha-Janaale dental pharmacy', 0, '2023-03-11', '2023-03-11 09:22:05', '2023-03-11 09:22:05'),
(67, 67, 1, 179, 78, 'Maxamed axmed', '4432380', 'Burco', '2023-03-11', 'Nuura xasan', 'Male', '0637866366', 0, 0, 'Lama yaqaan', 'Dhakhtarka Ilkaha-Janaale dental pharmacy', 0, '2023-03-11', '2023-03-11 09:22:43', '2023-03-11 09:22:43'),
(68, 68, 1, 179, 78, 'Maxamed axmed', '4432380', 'Burco', '2023-03-11', 'Nuura xasan', 'Male', '4432380', 0, 0, 'Lama yaqaan', 'Dhakhtarka Ilkaha-Janaale dental pharmacy', 0, '2023-03-11', '2023-03-11 09:26:07', '2023-03-11 09:26:07'),
(69, 69, 1, 179, 78, 'Maxamed axmed', '4432380', 'Burco', '2023-03-11', 'Nuura xasan', 'Male', '4432380', 0, 0, 'Lama yaqaan', 'Dhakhtarka Ilkaha-Janaale dental pharmacy', 0, '2023-03-11', '2023-03-11 09:26:19', '2023-03-11 09:26:19'),
(70, 70, 1, 179, 78, 'Maxamed axmed', '4432380', 'Burco', '2023-03-11', 'Nuura xasan', 'Male', '4432380', 0, 0, 'Lama yaqaan', 'Dhakhtarka Ilkaha-Janaale dental pharmacy', 0, '2023-03-11', '2023-03-11 09:26:22', '2023-03-11 09:26:22'),
(71, 71, 1, 179, 78, 'Maxamed axmed', '4432380', 'Burco', '2023-03-11', 'Nuura xasan', 'Male', '4432380', 0, 0, 'Lama yaqaan', 'Dhakhtarka Ilkaha-Janaale dental pharmacy', 0, '2023-03-11', '2023-03-11 09:26:26', '2023-03-11 09:26:26'),
(72, 72, 1, 179, 78, 'Maxamed axmed', '4432380', 'Burco', '2023-03-11', 'Nuura xasan', 'Male', '4432380', 0, 0, 'Lama yaqaan', 'Dhakhtarka Ilkaha-Janaale dental pharmacy', 0, '2023-03-11', '2023-03-11 09:26:30', '2023-03-11 09:26:30'),
(73, 73, 1, 160, 61, 'Casayr', '0634304883', 'Hargeisa', '2023-03-03', 'Shamis', 'Male', '0634304883', 0, 0, 'Lama yaqaan', 'Dhakhtarka Lafaha-Hargeysa neriology hospital', 0, '2023-03-28', '2023-03-28 09:00:15', '2023-03-28 09:00:15'),
(74, 74, 1, 160, 61, 'Casayr', '0634304883', 'Hargeisa', '2023-03-03', 'Shamis', 'Male', '252634304883', 0, 0, 'Lama yaqaan', 'Dhakhtarka Lafaha-Hargeysa neriology hospital', 0, '2023-03-28', '2023-03-28 09:00:56', '2023-03-28 09:00:56'),
(75, 75, 1, 160, 61, 'Casayr', '0634304883', 'Hargeisa', '2023-03-30', 'Shamis', 'Male', '252634304883', 0, 0, 'Lama yaqaan', 'Dhakhtarka Lafaha-Hargeysa neriology hospital', 0, '2023-03-28', '2023-03-28 09:01:32', '2023-03-28 09:01:32'),
(76, 76, 1, 160, 61, 'Casayr', '0634304883', 'Hargeisa', '2023-03-30', 'Shamis', 'Male', '252634304883', 0, 0, 'Lama yaqaan', 'Dhakhtarka Lafaha-Hargeysa neriology hospital', 0, '2023-03-28', '2023-03-28 09:01:38', '2023-03-28 09:01:38'),
(77, 77, 1, 160, 61, 'Casayr aadan', '0634322033', 'Burco', '2023-04-08', 'Hooyo macaan', 'Male', '252634304883', 0, 0, 'Lama yaqaan', 'Dhakhtarka Lafaha-Hargeysa neriology hospital', 0, '2023-03-28', '2023-03-28 09:02:48', '2023-03-28 09:02:48'),
(78, 78, 1, 161, 76, 'Casayr aadan', '6464584', 'Burco', '2023-04-04', 'Hooyo macaan', 'Male', '4304883', 0, 0, 'Lama yaqaan', 'Dhakhtarka Dhimirka-Burco manhal mental center', 0, '2023-03-28', '2023-03-28 09:04:24', '2023-03-28 09:04:24'),
(79, 79, 1, 186, 88, 'Yusuf', '4432380', 'Burco', '2023-03-28', 'Xalimo yusuf', 'Male', '4432380', 0, 0, 'Lama yaqaan', 'Dhakhtarka Cunaha-Baxnaano speciality clinic', 0, '2023-03-28', '2023-03-28 10:43:21', '2023-03-28 10:43:21'),
(80, 80, 1, 186, 88, 'Yusuf', '4432380', 'Burco', '2023-03-28', 'Xalimo yusuf', 'Male', '4432380', 0, 0, 'Lama yaqaan', 'Dhakhtarka Cunaha-Baxnaano speciality clinic', 0, '2023-03-28', '2023-03-28 10:43:34', '2023-03-28 10:43:34'),
(81, 81, 1, 193, 106, 'Axmed yusuf nuur', '0637866366', 'Burco', '2023-04-07', 'Nuura yusuf', 'Male', '637866366', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-04-07', '2023-04-07 12:00:40', '2023-04-07 12:00:40'),
(82, 82, 1, 193, 106, 'Axmed yusuf nuur', '0637866366', 'Burco', '2023-04-07', 'Nuura yusuf', 'Male', '637866366', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-04-07', '2023-04-07 12:00:54', '2023-04-07 12:00:54'),
(83, 83, 1, 194, 110, 'mustaphe Jama salah', '0637130351', 'burco', '2018-05-03', 'sahra axmed nuux', 'Male', '0637130351', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Needle hospital and pathology', 0, '2023-04-07', '2023-04-07 17:56:06', '2023-04-07 17:56:06'),
(84, 84, 1, 194, 110, 'mustaphe Jama salah', '0637130351', 'burco', '2018-05-03', 'sahra axmed nuux', 'Male', '0637130351', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Needle hospital and pathology', 0, '2023-04-07', '2023-04-07 17:56:12', '2023-04-07 17:56:12'),
(85, 85, 1, 193, 106, 'Yusuf xasan cali', '637866366', 'Burco', '2023-04-08', 'Nuura xasan', 'Male', '637866366', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-04-08', '2023-04-08 10:32:05', '2023-04-08 10:32:05'),
(86, 86, 1, 193, 106, 'Yusuf xasan cali', '637866366', 'Burco', '2023-04-08', 'Nuura xasan', 'Male', '637866366', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-04-08', '2023-04-08 10:32:17', '2023-04-08 10:32:17'),
(87, 87, 1, 193, 106, 'Yusuf xasan cali', '637866366', 'Burco', '2023-04-08', 'Nuura xasan', 'Male', '637866366', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-04-08', '2023-04-08 10:32:21', '2023-04-08 10:32:21'),
(88, 88, 1, 193, 106, 'Yusuf xasan cali', '637866366', 'Burco', '2023-04-08', 'Nuura xasan', 'Male', '637866366', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-04-08', '2023-04-08 10:32:25', '2023-04-08 10:32:25'),
(89, 89, 1, 193, 106, 'Xasan nuur', '637866366', 'Burco', '2023-04-08', 'Nuura yusuf', 'Male', '637866366', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-04-08', '2023-04-08 16:28:15', '2023-04-08 16:28:15'),
(90, 90, 1, 193, 106, 'Xasan nuur', '637866366', 'Burco', '2023-04-08', 'Nuura yusuf', 'Male', '637866366', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-04-08', '2023-04-08 16:28:20', '2023-04-08 16:28:20'),
(91, 91, 1, 193, 106, 'Yusuf nuur', '637866366', 'Burco', '2023-04-09', 'Hawsha cali', 'Male', '637866366', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-04-09', '2023-04-09 09:54:06', '2023-04-09 09:54:06'),
(92, 92, 1, 193, 106, 'Yusuf nuur', '637866366', 'Burco', '2023-04-09', 'Hawsha cali', 'Male', '637866366', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-04-09', '2023-04-09 09:54:11', '2023-04-09 09:54:11'),
(93, 93, 1, 193, 106, 'Yusuf nuur', '637866366', 'Burco', '2023-04-09', 'Hawsha cali', 'Male', '637866366', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-04-09', '2023-04-09 09:54:15', '2023-04-09 09:54:15'),
(94, 94, 1, 182, 81, 'Sucaad Abdikarim', '634714656', 'Burco:Abudubay', '2001-02-22', 'Foosiya', 'Female', '634714656', 0, 0, 'Lama yaqaan', 'Dhakhtarka Maqaarka-Procare poly clinic center pharmacy', 0, '2023-04-10', '2023-04-10 06:57:12', '2023-04-10 06:57:12'),
(95, 95, 1, 193, 106, 'Nuur axmed', '637866366', 'Burco', '2023-04-11', 'Hawey cali', 'Male', '637866366', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-04-11', '2023-04-10 21:55:18', '2023-04-10 21:55:18'),
(96, 96, 1, 193, 106, 'Nuur axmed', '637866366', 'Burco', '2023-04-11', 'Hawey cali', 'Male', '637866366', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-04-11', '2023-04-10 21:55:28', '2023-04-10 21:55:28'),
(97, 97, 1, 193, 106, 'Nuur axmed', '637866366', 'Burco', '2023-04-11', 'Hawey cali', 'Male', '637866366', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-04-11', '2023-04-10 21:55:39', '2023-04-10 21:55:39'),
(98, 98, 1, 193, 106, 'Nuur axmed', '637866366', 'Burco', '2023-04-11', 'Hawey cali', 'Male', '637866366', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-04-11', '2023-04-10 21:55:50', '2023-04-10 21:55:50'),
(99, 99, 1, 193, 106, 'Nuur axmed', '637866366', 'Burco', '2023-04-11', 'Hawey cali', 'Male', '637866366', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-04-11', '2023-04-10 21:56:02', '2023-04-10 21:56:02'),
(100, 100, 1, 193, 106, 'Yusuf nuur', '637866366', 'Burco', '2023-04-11', 'Just a xasan', 'Male', '637866366', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-04-11', '2023-04-11 09:52:56', '2023-04-11 09:52:56'),
(101, 101, 1, 193, 106, 'Yusuf nuur', '637866366', 'Burco', '2023-04-11', 'Just a xasan', 'Male', '637866366', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-04-11', '2023-04-11 09:53:11', '2023-04-11 09:53:11'),
(102, 102, 1, 193, 106, 'Yusuf nuur', '637866366', 'Burco', '2023-04-11', 'Just a xasan', 'Male', '637866366', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-04-11', '2023-04-11 09:53:15', '2023-04-11 09:53:15'),
(103, 103, 1, 193, 106, 'Yusuf nuur', '637866366', 'Burco', '2023-04-11', 'Just a xasan', 'Male', '637866366', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-04-11', '2023-04-11 09:53:19', '2023-04-11 09:53:19'),
(104, 104, 1, 193, 106, 'Yusuf nuur', '637866366', 'Burco', '2023-04-11', 'Just a xasan', 'Male', '637866366', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-04-11', '2023-04-11 09:53:23', '2023-04-11 09:53:23'),
(105, 105, 1, 193, 106, 'Yusuf nuur', '637866366', 'Burco', '2023-04-11', 'Just a xasan', 'Male', '637866366', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-04-11', '2023-04-11 09:53:27', '2023-04-11 09:53:27'),
(106, 106, 1, 193, 106, 'Yusuf nuur', '637866366', 'Burco', '2023-04-11', 'Just a xasan', 'Male', '637866366', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-04-11', '2023-04-11 09:53:31', '2023-04-11 09:53:31'),
(107, 107, 1, 179, 78, 'Maxamed axmed', '4432380', 'Burco', '2023-04-12', 'Nuura yusuf', 'Male', '44323801200', 0, 0, 'Lama yaqaan', 'Dhakhtarka Ilkaha-Janaale dental pharmacy', 0, '2023-04-12', '2023-04-12 18:00:00', '2023-04-12 18:00:00'),
(108, 108, 1, 179, 78, 'Maxamed axmed', '4432380', 'Burco', '2023-04-12', 'Nuura yusuf', 'Male', '44323801200', 0, 0, 'Lama yaqaan', 'Dhakhtarka Ilkaha-Janaale dental pharmacy', 0, '2023-04-12', '2023-04-12 18:00:32', '2023-04-12 18:00:32'),
(109, 109, 1, 179, 78, 'Maxamed axmed', '4432380', 'Burco', '2023-04-12', 'Nuura yusuf', 'Male', '4432380', 0, 0, 'Lama yaqaan', 'Dhakhtarka Ilkaha-Janaale dental pharmacy', 0, '2023-04-12', '2023-04-12 18:00:55', '2023-04-12 18:00:55'),
(110, 110, 1, 180, 79, 'Maxamed axmed bashe', '637866366', 'Hargeysa', '2023-04-13', 'Nuura axmed jamac', 'Male', '06344323801200', 0, 0, 'Lama yaqaan', 'Dhakhtarka Maqaarka-Janaale clinic pharmacy', 0, '2023-04-13', '2023-04-13 00:29:42', '2023-04-13 00:29:42'),
(111, 111, 1, 180, 79, 'Maxamed axmed bashe', '637866366', 'Hargeysa', '2023-04-13', 'Nuura axmed jamac', 'Male', '0634432380', 0, 0, 'Lama yaqaan', 'Dhakhtarka Maqaarka-Janaale clinic pharmacy', 0, '2023-04-13', '2023-04-13 00:29:57', '2023-04-13 00:29:57'),
(112, 112, 1, 180, 79, 'Maxamed axmed bashe', '637866366', 'Hargeysa', '2023-04-13', 'Nuura axmed jamac', 'Male', '0634432380', 0, 0, 'Lama yaqaan', 'Dhakhtarka Maqaarka-Janaale clinic pharmacy', 0, '2023-04-13', '2023-04-13 00:30:07', '2023-04-13 00:30:07'),
(113, 113, 1, 180, 79, 'Maxamed axmed bashe', '637866366', 'Hargeysa', '2023-04-13', 'Nuura axmed jamac', 'Male', '06344323801200', 0, 0, 'Lama yaqaan', 'Dhakhtarka Maqaarka-Janaale clinic pharmacy', 0, '2023-04-13', '2023-04-13 00:30:17', '2023-04-13 00:30:17'),
(114, 114, 1, 180, 79, 'Maxamed axmed bashe', '637866366', 'Hargeysa', '2023-04-13', 'Nuura axmed jamac', 'Male', '0634432380900012000', 0, 0, 'Lama yaqaan', 'Dhakhtarka Maqaarka-Janaale clinic pharmacy', 0, '2023-04-13', '2023-04-13 00:30:50', '2023-04-13 00:30:50'),
(115, 115, 1, 180, 79, 'Maxamed axmed baashe', '4432380', 'Hargeysa', '2023-04-13', 'Nuura xasan cali yusuf', 'Male', '44323801200', 0, 0, 'Lama yaqaan', 'Dhakhtarka Maqaarka-Janaale clinic pharmacy', 0, '2023-04-13', '2023-04-13 10:20:12', '2023-04-13 10:20:12'),
(116, 116, 1, 180, 79, 'Maxamed axmed baashe', '4432380', 'Hargeysa', '2023-04-13', 'Nuura xasan cali yusuf', 'Male', '06344323801200', 0, 0, 'Lama yaqaan', 'Dhakhtarka Maqaarka-Janaale clinic pharmacy', 0, '2023-04-13', '2023-04-13 10:20:46', '2023-04-13 10:20:46'),
(117, 117, 1, 180, 79, 'Maxamed axmed baashe', '0634432380', 'Hargeysa', '2023-04-13', 'Nuura xasan cali yusuf', 'Male', '06344323801200', 0, 0, 'Lama yaqaan', 'Dhakhtarka Maqaarka-Janaale clinic pharmacy', 0, '2023-04-13', '2023-04-13 10:21:03', '2023-04-13 10:21:03'),
(118, 118, 1, 180, 79, 'Maxamed axmed baashe', '637866366', 'Hargeysa', '2023-04-13', 'Nuura xasan cali yusuf', 'Male', '06344323801200', 0, 0, 'Lama yaqaan', 'Dhakhtarka Maqaarka-Janaale clinic pharmacy', 0, '2023-04-13', '2023-04-13 10:21:17', '2023-04-13 10:21:17'),
(119, 119, 1, 179, 78, 'Maxamed axmed bashe', '0637866366', 'Hargeysa', '2023-04-14', 'Nuura cali axmed', 'Male', '06344323801200', 0, 0, 'Lama yaqaan', 'Dhakhtarka Ilkaha-Janaale dental pharmacy', 0, '2023-04-14', '2023-04-14 17:06:49', '2023-04-14 17:06:49'),
(120, 120, 1, 180, 79, 'Maxamed axmed baashe', '4432380', 'Hargeysa', '2023-04-15', 'Nuura cali axmed', 'Male', '44323801200', 0, 0, 'Lama yaqaan', 'Dhakhtarka Maqaarka-Janaale clinic pharmacy', 0, '2023-04-15', '2023-04-15 09:02:15', '2023-04-15 09:02:15'),
(121, 121, 1, 180, 79, 'Maxamed axmed baashe', '4432380', 'Hargeysa', '2023-04-15', 'Nuura cali axmed', 'Male', '4432380', 0, 0, 'Lama yaqaan', 'Dhakhtarka Maqaarka-Janaale clinic pharmacy', 0, '2023-04-15', '2023-04-15 09:02:36', '2023-04-15 09:02:36'),
(122, 122, 1, 193, 106, 'Cbdi qani kayse', '634567255', 'Hargeisa', '1997-05-05', 'Hoodo', 'Male', '634567255', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-04-15', '2023-04-15 13:18:48', '2023-04-15 13:18:48'),
(123, 123, 1, 180, 79, 'Maxamed axmed baashe', '4432380', 'Burco', '2023-04-18', 'Nuura cali axmed', 'Male', '4432380', 0, 0, 'Lama yaqaan', 'Dhakhtarka Maqaarka-Janaale clinic pharmacy', 0, '2023-04-18', '2023-04-18 17:19:21', '2023-04-18 17:19:21'),
(124, 124, 1, 180, 79, 'Maxamed axmed baashe', '4432380', 'Burco', '2023-04-18', 'Nuura cali axmed', 'Male', '44323801200', 0, 0, 'Lama yaqaan', 'Dhakhtarka Maqaarka-Janaale clinic pharmacy', 0, '2023-04-18', '2023-04-18 17:19:31', '2023-04-18 17:19:31'),
(125, 125, 1, 180, 79, 'Maxamed yusuf xasan', '7866366', 'Burco', '2023-04-24', 'Nuura axmed yusuf', 'Male', '6344323801200', 0, 0, 'Lama yaqaan', 'Dhakhtarka Maqaarka-Janaale clinic pharmacy', 0, '2023-04-24', '2023-04-24 09:38:33', '2023-04-24 09:38:33'),
(126, 126, 1, 180, 79, 'Maxamed yusuf xasan', '0634432380', 'Burco', '2023-04-24', 'Nuura axmed yusuf', 'Male', '06344323801200', 0, 0, 'Lama yaqaan', 'Dhakhtarka Maqaarka-Janaale clinic pharmacy', 0, '2023-04-24', '2023-04-24 09:39:04', '2023-04-24 09:39:04'),
(127, 127, 1, 180, 79, 'Maxamed yusuf xasan', '0634432380', 'Burco', '2023-04-24', 'Nuura axmed yusuf', 'Male', '063443238090001200', 0, 0, 'Lama yaqaan', 'Dhakhtarka Maqaarka-Janaale clinic pharmacy', 0, '2023-04-24', '2023-04-24 09:40:19', '2023-04-24 09:40:19'),
(128, 128, 1, 179, 78, 'Maxamed axmed baashe', '0637866366', 'Burco', '2023-04-24', 'Xaawo xasan nuur', 'Male', '4432380', 0, 0, 'Lama yaqaan', 'Dhakhtarka Ilkaha-Janaale dental pharmacy', 0, '2023-04-24', '2023-04-24 09:57:28', '2023-04-24 09:57:28'),
(129, 129, 1, 179, 78, 'Maxamed axmed baashe', '0637866366', 'Burco', '2023-04-24', 'Xaawo xasan nuur', 'Male', '0634432380', 0, 0, 'Lama yaqaan', 'Dhakhtarka Ilkaha-Janaale dental pharmacy', 0, '2023-04-24', '2023-04-24 09:57:49', '2023-04-24 09:57:49'),
(130, 130, 1, 179, 78, 'Maxamed axmed baashe', '0637866366', 'Burco', '2023-04-24', 'Xaawo xasan nuur', 'Male', '0637866336', 0, 0, 'Lama yaqaan', 'Dhakhtarka Ilkaha-Janaale dental pharmacy', 0, '2023-04-24', '2023-04-24 09:58:28', '2023-04-24 09:58:28'),
(131, 131, 1, 192, 101, 'Saamiya ibraahin aadan', '0634161531', 'Burco', '2023-04-28', 'Yurub ibraahin haariye', 'Female', '0634161531', 0, 0, 'Lama yaqaan', 'Dhakhtarka Neerfaha-Hargeysa neurology hospital', 0, '2023-04-28', '2023-04-28 17:06:44', '2023-04-28 17:06:44'),
(132, 132, 1, 192, 101, 'Saamiya ibraahin aadan', '0634161531', 'Burco', '2023-04-28', 'Yurub ibraahin haariye', 'Female', '0634161531', 0, 0, 'Lama yaqaan', 'Dhakhtarka Neerfaha-Hargeysa neurology hospital', 0, '2023-04-28', '2023-04-28 17:07:43', '2023-04-28 17:07:43'),
(133, 133, 1, 192, 105, 'Saamiya ibraahi aadan', '0634161531', 'Burco', '2023-04-29', 'Yurub ibraahin aadan', 'Female', '0634161531', 0, 0, 'Lama yaqaan', 'Dhakhtarka Neerfaha-Hargeysa neurology hospital', 0, '2023-04-28', '2023-04-28 17:09:42', '2023-04-28 17:09:42'),
(134, 134, 1, 192, 105, 'Saamiya ibraahi aadan', '0634161531', 'Burco', '2023-04-29', 'Yurub ibraahin aadan', 'Female', '0634161531', 0, 0, 'Lama yaqaan', 'Dhakhtarka Neerfaha-Hargeysa neurology hospital', 0, '2023-04-28', '2023-04-28 17:09:48', '2023-04-28 17:09:48'),
(135, 135, 1, 192, 105, 'Saamiya ibraahi aadan', '0634161531', 'Burco', '2023-04-29', 'Yurub ibraahin aadan', 'Female', '0634161531', 0, 0, 'Lama yaqaan', 'Dhakhtarka Neerfaha-Hargeysa neurology hospital', 0, '2023-04-28', '2023-04-28 17:09:52', '2023-04-28 17:09:52'),
(136, 136, 1, 192, 105, 'Saamiya ibraahi aadan', '0634161531', 'Burco', '2023-04-29', 'Yurub ibraahin aadan', 'Female', '0634161531', 0, 0, 'Lama yaqaan', 'Dhakhtarka Neerfaha-Hargeysa neurology hospital', 0, '2023-04-28', '2023-04-28 17:09:56', '2023-04-28 17:09:56'),
(137, 137, 1, 192, 105, 'Saamiya ibraahi aadan', '0659332778', 'Burco', '2023-04-29', 'Yurub ibraahin aadan', 'Female', '0634161531', 0, 0, 'Lama yaqaan', 'Dhakhtarka Neerfaha-Hargeysa neurology hospital', 0, '2023-04-28', '2023-04-28 17:11:09', '2023-04-28 17:11:09'),
(138, 138, 1, 192, 105, 'Saamiya ibraahi aadan', '0634161531', 'Burco', '2023-04-29', 'Yurub ibraahin aadan', 'Female', '06341615312121', 0, 0, 'Lama yaqaan', 'Dhakhtarka Neerfaha-Hargeysa neurology hospital', 0, '2023-04-28', '2023-04-28 17:30:39', '2023-04-28 17:30:39'),
(139, 139, 1, 187, 91, 'Maxamed axmed baashe', '0634432380', 'Burco', '2023-04-28', 'Nuura cali warsame', 'Male', '4432380', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Kawir medical center pharmacy', 0, '2023-04-28', '2023-04-28 17:52:10', '2023-04-28 17:52:10'),
(140, 140, 1, 187, 91, 'Maxamed axmed baashe', '0634432380', 'Burco', '2023-04-28', 'Nuura cali warsame', 'Male', '44323801200', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Kawir medical center pharmacy', 0, '2023-04-28', '2023-04-28 17:52:29', '2023-04-28 17:52:29'),
(141, 141, 1, 187, 91, 'Maxamed axmed baashe', '0634432380', 'Burco', '2023-04-28', 'Nuura cali warsame', 'Male', '44323801200', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Kawir medical center pharmacy', 0, '2023-04-28', '2023-04-28 17:52:55', '2023-04-28 17:52:55'),
(142, 142, 1, 187, 91, 'Maxamed axmed baashe', '0634432380', 'Burco', '2023-04-28', 'Nuura cali warsame', 'Male', '1200', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Kawir medical center pharmacy', 0, '2023-04-28', '2023-04-28 17:53:23', '2023-04-28 17:53:23'),
(143, 143, 1, 187, 91, 'Maxamed axmed baashe', '0634432380', 'Burco', '2023-04-28', 'Nuura cali warsame', 'Male', '0634432380', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Kawir medical center pharmacy', 0, '2023-04-28', '2023-04-28 17:54:12', '2023-04-28 17:54:12'),
(144, 144, 1, 181, 80, 'Maxamed axmed', '637866366', 'Burco', '2023-04-28', 'Nuura yusuf', 'Male', '4432380', 0, 0, 'Lama yaqaan', 'Dhakhtarka Cudurada Guud-Shiikh isixaaq pharmacy', 0, '2023-04-28', '2023-04-28 17:56:27', '2023-04-28 17:56:27'),
(145, 145, 1, 181, 80, 'Maxamed axmed', '637866366', 'Burco', '2023-04-28', 'Nuura yusuf', 'Male', '44323801200', 0, 0, 'Lama yaqaan', 'Dhakhtarka Cudurada Guud-Shiikh isixaaq pharmacy', 0, '2023-04-28', '2023-04-28 17:56:39', '2023-04-28 17:56:39'),
(146, 146, 1, 181, 80, 'Maxamed axmed', '637866366', 'Burco', '2023-04-28', 'Nuura yusuf', 'Male', '0664432380', 0, 0, 'Lama yaqaan', 'Dhakhtarka Cudurada Guud-Shiikh isixaaq pharmacy', 0, '2023-04-28', '2023-04-28 17:57:03', '2023-04-28 17:57:03'),
(147, 147, 1, 181, 80, 'Maxamed axmed', '637866366', 'Burco', '2023-04-28', 'Nuura yusuf', 'Male', '0664432380', 0, 0, 'Lama yaqaan', 'Dhakhtarka Cudurada Guud-Shiikh isixaaq pharmacy', 0, '2023-04-28', '2023-04-28 17:57:08', '2023-04-28 17:57:08'),
(148, 148, 1, 181, 80, 'Maxamed axmed', '637866366', 'Burco', '2023-04-28', 'Nuura yusuf', 'Male', '0664432380', 0, 0, 'Lama yaqaan', 'Dhakhtarka Cudurada Guud-Shiikh isixaaq pharmacy', 0, '2023-04-28', '2023-04-28 17:57:20', '2023-04-28 17:57:20'),
(149, 149, 1, 181, 80, 'Maxamed axmed', '637866366', 'Burco', '2023-04-28', 'Nuura yusuf', 'Male', '4432380', 0, 0, 'Lama yaqaan', 'Dhakhtarka Cudurada Guud-Shiikh isixaaq pharmacy', 0, '2023-04-28', '2023-04-28 17:57:33', '2023-04-28 17:57:33'),
(150, 150, 1, 193, 106, 'Mohamed Ahmed bashe', '0634432380', 'Burco', '2023-04-29', 'Nura ahmed', 'Male', '0634432380', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-04-29', '2023-04-29 08:55:55', '2023-04-29 08:55:55'),
(151, 151, 1, 193, 106, 'Mohamed Ahmed bashe', '0634432380', 'Burco', '2023-04-29', 'Nura ahmed', 'Male', '0634432380', 0, 0, 'Lama yaqaan', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-04-29', '2023-04-29 08:56:07', '2023-04-29 08:56:07'),
(152, 152, 1, 190, 98, 'Maxamed axmed baashe', '0637866366', 'Burco', '2023-04-04', 'Nuura axmed yusuf', 'Male', '0634432380', 0, 0, 'RCS_FAILEDTOLOAD_SRVCPARAMS (Failed to load the parameter {amount}, input {Shilin24000}, rule ParamDef{_type=2, _min=-1, _max=-1, _defValue=}) (Failed', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-05-04', '2023-05-04 08:48:25', '2023-05-04 08:48:25'),
(153, 153, 1, 190, 98, 'Maxamed axmed baashe', '0637866366', 'Burco', '2023-04-04', 'Nuura axmed yusuf', 'Male', '06344323801200', 0, 0, 'RCS_FAILEDTOLOAD_SRVCPARAMS (Failed to load the parameter {amount}, input {Shilin24000}, rule ParamDef{_type=2, _min=-1, _max=-1, _defValue=}) (Failed', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-05-04', '2023-05-04 08:48:45', '2023-05-04 08:48:45'),
(154, 154, 1, 190, 98, 'Maxamed axmed baashe', '0637866366', 'Burco', '2023-04-04', 'Nuura axmed yusuf', 'Male', '06344323801200', 0, 0, 'RCS_FAILEDTOLOAD_SRVCPARAMS (Failed to load the parameter {amount}, input {Shilin24000}, rule ParamDef{_type=2, _min=-1, _max=-1, _defValue=}) (Failed', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-05-04', '2023-05-04 09:03:36', '2023-05-04 09:03:36'),
(155, 155, 1, 190, 98, 'Maxamed axmed baashe', '0637866366', 'Burco', '2023-04-04', 'Nuura axmed yusuf', 'Male', '06344323801200', 0, 0, 'RCS_FAILEDTOLOAD_SRVCPARAMS (Failed to load the parameter {amount}, input {Shilin24000}, rule ParamDef{_type=2, _min=-1, _max=-1, _defValue=}) (Failed', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-05-04', '2023-05-04 09:04:32', '2023-05-04 09:04:32'),
(156, 156, 1, 190, 98, 'Maxamed axmed baashe', '0637866366', 'Burco', '2023-04-04', 'Nuura axmed cali', 'Male', '0634432380', 0, 0, 'RCS_FAILEDTOLOAD_SRVCPARAMS (Failed to load the parameter {amount}, input {Shilin24000}, rule ParamDef{_type=2, _min=-1, _max=-1, _defValue=}) (Failed', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-05-04', '2023-05-04 09:09:31', '2023-05-04 09:09:31'),
(157, 157, 1, 190, 98, 'Maxamed axmed baashe', '0637866366', 'Burco', '2023-04-04', 'Nuura axmed cali', 'Male', '06344323801200', 0, 0, 'RCS_FAILEDTOLOAD_SRVCPARAMS (Failed to load the parameter {amount}, input {Shilin24000}, rule ParamDef{_type=2, _min=-1, _max=-1, _defValue=}) (Failed', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-05-04', '2023-05-04 09:09:45', '2023-05-04 09:09:45'),
(158, 158, 1, 190, 98, 'Maxamed axmed baashe', '0637866366', 'Burco', '2023-05-08', 'Nuura cali axmed', 'Male', '06344323801200', 0, 0, 'RCS_FAILEDTOLOAD_SRVCPARAMS (Failed to load the parameter {amount}, input {Shilin24000}, rule ParamDef{_type=2, _min=-1, _max=-1, _defValue=}) (Failed', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-05-08', '2023-05-08 07:41:53', '2023-05-08 07:41:53'),
(159, 159, 1, 190, 98, 'Maxamed axmed baashe', '0637866366', 'Burco', '2023-05-08', 'Nuura cali axmed', 'Male', '0634432380', 0, 0, 'RCS_FAILEDTOLOAD_SRVCPARAMS (Failed to load the parameter {amount}, input {Shilin24000}, rule ParamDef{_type=2, _min=-1, _max=-1, _defValue=}) (Failed', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-05-08', '2023-05-08 07:42:29', '2023-05-08 07:42:29'),
(160, 160, 1, 181, 80, 'Maxamed axmed baashe', '7866366', 'Hargeysa', '2023-05-08', 'Nuura xasan axmed', 'Male', '634432380', 0, 0, 'RCS_FAILEDTOLOAD_SRVCPARAMS (Failed to load the parameter {amount}, input {Shilin26000}, rule ParamDef{_type=2, _min=-1, _max=-1, _defValue=}) (Failed', 'Dhakhtarka Cudurada Guud-Shiikh isixaaq pharmacy', 0, '2023-05-08', '2023-05-08 07:45:02', '2023-05-08 07:45:02'),
(161, 161, 1, 181, 80, 'Maxamed axmed baashe', '0634432380', 'Hargeysa', '2023-05-08', 'Nuura xasan axmed', 'Male', '0634432380', 0, 0, 'RCS_FAILEDTOLOAD_SRVCPARAMS (Failed to load the parameter {amount}, input {Shilin26000}, rule ParamDef{_type=2, _min=-1, _max=-1, _defValue=}) (Failed', 'Dhakhtarka Cudurada Guud-Shiikh isixaaq pharmacy', 0, '2023-05-08', '2023-05-08 07:45:38', '2023-05-08 07:45:38'),
(162, 162, 1, 190, 98, 'Maxamed axmed bashe', '0637866366', 'Burco', '2023-05-08', 'Nuura cali yusuf', 'Male', '0634432380', 0, 0, 'RCS_FAILEDTOLOAD_SRVCPARAMS (Failed to load the parameter {amount}, input {Shilin24000}, rule ParamDef{_type=2, _min=-1, _max=-1, _defValue=}) (Failed', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-05-08', '2023-05-08 13:31:11', '2023-05-08 13:31:11'),
(163, 163, 1, 190, 98, 'Maxamed axmed bashe', '0637866366', 'Burco', '2023-05-08', 'Nuura cali yusuf', 'Male', '06344323801200', 0, 0, 'RCS_FAILEDTOLOAD_SRVCPARAMS (Failed to load the parameter {amount}, input {Shilin24000}, rule ParamDef{_type=2, _min=-1, _max=-1, _defValue=}) (Failed', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-05-08', '2023-05-08 13:31:27', '2023-05-08 13:31:27'),
(164, 164, 1, 190, 98, 'Maxamed axmed bashe', '0634432380', 'Burco', '2023-05-08', 'Nuura cali yusuf', 'Male', '06344323801200', 0, 0, 'RCS_FAILEDTOLOAD_SRVCPARAMS (Failed to load the parameter {amount}, input {Shilin24000}, rule ParamDef{_type=2, _min=-1, _max=-1, _defValue=}) (Failed', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-05-08', '2023-05-08 13:31:53', '2023-05-08 13:31:53'),
(165, 165, 1, 190, 98, 'Maxamed axmed bashe', '0634432380', 'Burco', '2023-05-08', 'Nuura cali yusuf', 'Male', '0634432380', 0, 0, 'RCS_FAILEDTOLOAD_SRVCPARAMS (Failed to load the parameter {amount}, input {Shilin24000}, rule ParamDef{_type=2, _min=-1, _max=-1, _defValue=}) (Failed', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-05-08', '2023-05-08 13:32:04', '2023-05-08 13:32:04'),
(166, 166, 1, 181, 80, 'Maxamed axmed baashe', '637866366', 'Hargeysa', '2023-05-08', 'Nuura cali', 'Male', '0634432380', 0, 0, 'RCS_FAILEDTOLOAD_SRVCPARAMS (Failed to load the parameter {amount}, input {Shilin26000}, rule ParamDef{_type=2, _min=-1, _max=-1, _defValue=}) (Failed', 'Dhakhtarka Cudurada Guud-Shiikh isixaaq pharmacy', 0, '2023-05-08', '2023-05-08 13:33:39', '2023-05-08 13:33:39'),
(167, 167, 1, 181, 80, 'Maxamed axmed baashe', '0637866366', 'Burco', '2023-05-09', 'Nuura xasan yusuf', 'Male', '0634432380', 0, 0, 'RCS_FAILEDTOLOAD_SRVCPARAMS (Failed to load the parameter {amount}, input {Shilin26000}, rule ParamDef{_type=2, _min=-1, _max=-1, _defValue=}) (Failed', 'Dhakhtarka Cudurada Guud-Shiikh isixaaq pharmacy', 0, '2023-05-09', '2023-05-09 15:43:18', '2023-05-09 15:43:18'),
(168, 168, 1, 181, 80, 'Maxamed axmed baashe', '0637866366', 'Burco', '2023-05-09', 'Nuura xasan yusuf', 'Male', '06344323801200', 0, 0, 'RCS_FAILEDTOLOAD_SRVCPARAMS (Failed to load the parameter {amount}, input {Shilin26000}, rule ParamDef{_type=2, _min=-1, _max=-1, _defValue=}) (Failed', 'Dhakhtarka Cudurada Guud-Shiikh isixaaq pharmacy', 0, '2023-05-09', '2023-05-09 15:43:31', '2023-05-09 15:43:31'),
(169, 169, 1, 181, 80, 'Maxamed axmed baashe', '0634432380', 'Burco', '2023-05-09', 'Nuura xasan yusuf', 'Male', '0634432380', 0, 0, 'RCS_FAILEDTOLOAD_SRVCPARAMS (Failed to load the parameter {amount}, input {Shilin26000}, rule ParamDef{_type=2, _min=-1, _max=-1, _defValue=}) (Failed', 'Dhakhtarka Cudurada Guud-Shiikh isixaaq pharmacy', 0, '2023-05-09', '2023-05-09 15:43:53', '2023-05-09 15:43:53'),
(170, 170, 1, 181, 80, 'Maxamed axmed baashe', '0637866366', 'Burco', '2023-05-13', 'Nuura axmed warsame', 'Male', '0634432380', 0, 0, 'RCS_FAILEDTOLOAD_SRVCPARAMS (Failed to load the parameter {amount}, input {Shilin26000}, rule ParamDef{_type=2, _min=-1, _max=-1, _defValue=}) (Failed', 'Dhakhtarka Cudurada Guud-Shiikh isixaaq pharmacy', 0, '2023-05-13', '2023-05-13 11:25:58', '2023-05-13 11:25:58'),
(171, 171, 1, 181, 80, 'Maxamed axmed baashe', '0637866366', 'Hargeysa', '2023-05-13', 'Nuura axmed yusuf', 'Male', '06344323801200', 0, 0, 'RCS_FAILEDTOLOAD_SRVCPARAMS (Failed to load the parameter {amount}, input {Shilin26000}, rule ParamDef{_type=2, _min=-1, _max=-1, _defValue=}) (Failed', 'Dhakhtarka Cudurada Guud-Shiikh isixaaq pharmacy', 0, '2023-05-13', '2023-05-13 11:27:19', '2023-05-13 11:27:19'),
(172, 172, 1, 188, 92, 'Maxamed axmed baashe', '0637866366', 'Burco', '2023-05-13', 'Xaawo yusuf cabdi', 'Male', '0634432380', 0, 0, 'RCS_FAILEDTOLOAD_SRVCPARAMS (Failed to load the parameter {amount}, input {Shilin51000}, rule ParamDef{_type=2, _min=-1, _max=-1, _defValue=}) (Failed', 'Dhakhtarka Caruurta-Hooyo Dhawar hospital', 0, '2023-05-13', '2023-05-13 11:33:54', '2023-05-13 11:33:54'),
(173, 173, 1, 188, 92, 'Maxamed axmed baashe', '0637866366', 'Burco', '2023-05-13', 'Xaawo yusuf cabdi', 'Male', '06344323801200', 0, 0, 'RCS_FAILEDTOLOAD_SRVCPARAMS (Failed to load the parameter {amount}, input {Shilin51000}, rule ParamDef{_type=2, _min=-1, _max=-1, _defValue=}) (Failed', 'Dhakhtarka Caruurta-Hooyo Dhawar hospital', 0, '2023-05-13', '2023-05-13 11:34:06', '2023-05-13 11:34:06'),
(174, 174, 1, 181, 80, 'Maxamed axmed baashe', '7866366', 'Burco', '2023-05-13', 'Nuura cali axmed yusuf', 'Male', '634432380', 26000, 0, 'RCS_AUTH_FAILED (null)', 'Dhakhtarka Cudurada Guud-Shiikh isixaaq pharmacy', 0, '2023-05-13', '2023-05-13 12:37:02', '2023-05-13 12:37:02'),
(175, 175, 1, 181, 80, 'Maxamed axmed baashe', '7866366', 'Burco', '2023-05-13', 'Xalimo axmed yusuf', 'Male', '634432380', 26000, 0, 'RCS_USER_IS_NOT_AUTHZ_TO_ACCESS_API (null)', 'Dhakhtarka Cudurada Guud-Shiikh isixaaq pharmacy', 0, '2023-05-13', '2023-05-13 12:41:13', '2023-05-13 12:41:13'),
(176, 176, 1, 181, 80, 'Maxamed axmed baashe', '7866366', 'Burco', '2023-05-13', 'Xalimo axmed yusuf', 'Male', '634432380', 26000, 0, 'RCS_USER_IS_NOT_AUTHZ_TO_ACCESS_API (null)', 'Dhakhtarka Cudurada Guud-Shiikh isixaaq pharmacy', 0, '2023-05-13', '2023-05-13 12:41:19', '2023-05-13 12:41:19'),
(177, 177, 1, 181, 80, 'Maxamed axmed baashe', '7866366', 'Burco', '2023-05-13', 'Xalimo axmed yusuf', 'Male', '634432380', 26000, 0, 'RCS_USER_IS_NOT_AUTHZ_TO_ACCESS_API (null)', 'Dhakhtarka Cudurada Guud-Shiikh isixaaq pharmacy', 0, '2023-05-13', '2023-05-13 12:41:25', '2023-05-13 12:41:25'),
(178, 178, 1, 181, 80, 'Maxamed axmed baashe', '7866366', 'Burco', '2023-05-14', 'Nuura xasan muuse', 'Male', '634432380', 26000, 1, 'Ok', 'Dhakhtarka Cudurada Guud-Shiikh isixaaq pharmacy', 0, '2023-05-14', '2023-05-14 08:01:59', '2023-05-14 08:01:59'),
(179, 179, 1, 181, 80, 'Maxamed axmed baashe', '7866366', 'Burco', '2023-05-14', 'Nuura axmed cali', 'Male', '634432380', 26000, 1, 'Ok', 'Dhakhtarka Cudurada Guud-Shiikh isixaaq pharmacy', 0, '2023-05-14', '2023-05-14 08:40:49', '2023-05-14 08:40:49'),
(180, 180, 1, 188, 92, 'Maxamed axmed baashe', '7866366', 'Burco', '2023-05-14', 'Xaawo nuura cali', 'Male', '634432380', 51000, 1, 'Ok', 'Dhakhtarka Caruurta-Hooyo Dhawar hospital', 0, '2023-05-14', '2023-05-14 08:42:56', '2023-05-14 08:42:56'),
(181, 181, 1, 188, 92, 'Maxamed axmed baashe', '0637866366', 'Burco', '2023-05-14', 'Xaawo axmed yusuf', 'Male', '0634432380', 51000, 0, 'Telkaa qaldan 0637866366', 'Dhakhtarka Caruurta-Hooyo Dhawar hospital', 0, '2023-05-14', '2023-05-14 09:00:17', '2023-05-14 09:00:17'),
(182, 182, 1, 188, 92, 'Maxamed axmed baashe', '0637866366', 'Burco', '2023-05-14', 'Xaawo axmed yusuf', 'Male', '0634432380', 51000, 0, 'Telkaa qaldan 0637866366', 'Dhakhtarka Caruurta-Hooyo Dhawar hospital', 0, '2023-05-14', '2023-05-14 09:00:57', '2023-05-14 09:00:57'),
(183, 183, 1, 188, 92, 'Maxamed axmed baashe', '0637866366', 'Burco', '2023-05-14', 'Xaawo axmed yusuf', 'Male', '0634432380', 51000, 0, 'Telkaa qaldan 0637866366', 'Dhakhtarka Caruurta-Hooyo Dhawar hospital', 0, '2023-05-14', '2023-05-14 09:01:21', '2023-05-14 09:01:21'),
(184, 184, 1, 181, 80, 'Maxamed axmed baashe', '0634432380', 'Burco', '2023-05-14', 'Nuura axmed yusuf', 'Male', '0634432380', 26000, 0, 'Telkaa qaldan 0634432380', 'Dhakhtarka Cudurada Guud-Shiikh isixaaq pharmacy', 0, '2023-05-14', '2023-05-14 09:03:17', '2023-05-14 09:03:17'),
(185, 185, 1, 181, 80, 'Maxamed axmed baashe', '78366366', 'Burco', '2023-05-14', 'Nuura axmed yusuf', 'Male', '634432380', 26000, 1, 'Ok', 'Dhakhtarka Cudurada Guud-Shiikh isixaaq pharmacy', 0, '2023-05-14', '2023-05-14 09:04:04', '2023-05-14 09:04:04'),
(186, 186, 1, 188, 92, 'Maxamed axmed baashe', '0634432380', 'Burco', '2023-05-14', 'Xaawo cali yusuf', 'Male', '0634432380', 51000, 0, 'Telkaa qaldan 0634432380', 'Dhakhtarka Caruurta-Hooyo Dhawar hospital', 0, '2023-05-14', '2023-05-14 09:14:22', '2023-05-14 09:14:22'),
(187, 187, 1, 188, 92, 'Maxamed axmed baashe', '634432380', 'Burco', '2023-05-14', 'Xaawo cali yusuf', 'Male', '634432380', 51000, 1, 'Ok', 'Dhakhtarka Caruurta-Hooyo Dhawar hospital', 0, '2023-05-14', '2023-05-14 09:15:02', '2023-05-14 09:15:02');
INSERT INTO `app_patient` (`id`, `auto_id`, `company_id`, `hospital_id`, `doctor_id`, `name`, `tell`, `address`, `dob`, `mother`, `gender`, `payment_tell`, `amount`, `status`, `evc_response`, `description`, `user_id`, `date`, `action_date`, `modified_date`) VALUES
(188, 188, 1, 190, 98, 'Maxamed axmed', '0634432380', 'Burco', '2023-05-15', 'Nuura csli', 'Male', '0634432380', 24000, 0, 'Telkaa qaldan 0634432380', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-05-15', '2023-05-15 20:32:21', '2023-05-15 20:32:21'),
(189, 189, 1, 190, 98, 'Maxamed axmed baashe', '634432380', 'Burco', '2023-05-15', 'Nuura cali yusuf', 'Male', '634432380', 24000, 0, 'RCS_TRAN_FAILED_AT_ISSUER_SYSTEM (STATE: rejected, ERRCODE: 4004 - timeout occured waiting user response, TransactionId: 30403091) (STATE: rejected, E', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-05-15', '2023-05-15 20:33:59', '2023-05-15 20:33:59'),
(190, 190, 1, 190, 98, 'Maxamed axmed baashe', '634432380', 'Burco', '2023-05-16', 'Nuura yusuf cali', 'Male', '634432380', 24000, 1, 'Ok', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-05-16', '2023-05-15 22:49:49', '2023-05-15 22:49:49'),
(191, 191, 1, 190, 98, 'Maxamed axmed baashe', '634432380', 'Burco', '2023-05-27', 'Nuura axmed yusuf', 'Male', '634432380', 24000, 0, 'Wuu diiday', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-05-27', '2023-05-27 02:03:27', '2023-05-27 02:03:27'),
(192, 192, 1, 190, 98, 'Maxamed axmed baashe', '7866366', 'Burco', '2023-05-27', 'Nuura axmed yusuf', 'Male', '634432380', 24000, 1, 'Ok', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-05-27', '2023-05-27 02:04:31', '2023-05-27 02:04:31'),
(193, 193, 1, 190, 98, 'Maxamed axmed baashe', '637866366', 'Burco', '2023-05-27', 'Nuura axmed cali', 'Male', '634432380', 24000, 0, 'RCS_TRAN_FAILED_AT_ISSUER_SYSTEM (STATE: rejected, ERRCODE: 4004 - timeout occured waiting user response, TransactionId: 30584451) (STATE: rejected, E', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-05-27', '2023-05-27 14:25:28', '2023-05-27 14:25:28'),
(194, 194, 1, 195, 117, 'Maxamed  abdi jamac', '634051831', 'Hargeysa', '2023-05-30', 'Casha abdi caydiid', 'Male', '0634051831', 54000, 0, 'Telkaa qaldan 634051831', 'Dhakhtarka Cudurada Guud-Horyal hospital', 0, '2023-05-30', '2023-05-29 22:39:49', '2023-05-29 22:39:49'),
(195, 195, 1, 195, 117, 'Maxamed  abdi jamac', '637866366', 'Hargeysa', '2023-05-30', 'Casha abdi caydiid', 'Male', '634051831', 54000, 0, 'Wuu diiday', 'Dhakhtarka Cudurada Guud-Horyal hospital', 0, '2023-05-30', '2023-05-29 22:41:15', '2023-05-29 22:41:15'),
(196, 196, 1, 190, 98, 'Maxamed axmed bashe', '637866366', 'Burco', '0000-00-00', 'Shaqeya axmed yusuf', 'Male', '634432380', 24000, 0, 'Wuu diiday', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-05-31', '2023-05-31 10:26:09', '2023-05-31 10:26:09'),
(197, 197, 1, 190, 99, 'Siciid cabdi adan', '0634471123', 'Hargeisa', '2023-06-04', 'Surer sahal jaciir', 'Male', '4471123', 24000, 0, 'Telkaa qaldan 0634471123', 'Dhakhtarka Ilkaha-Shifo pharmacy', 0, '2023-06-03', '2023-06-03 18:13:30', '2023-06-03 18:13:30'),
(198, 198, 1, 190, 99, 'Siciid cabdi adan', '634471123', 'Hargeisa', '2023-06-03', 'Surer sahal jaciir', 'Male', '634471123', 24000, 1, 'Ok', 'Dhakhtarka Ilkaha-Shifo pharmacy', 0, '2023-06-03', '2023-06-03 18:41:53', '2023-06-03 18:41:53'),
(199, 199, 1, 193, 106, 'Maxamed axmed baashe', '634432380', 'Burco', '2023-04-06', 'Nuura yusuf axmed', 'Male', '634432380', 95000, 1, 'Ok', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-06-04', '2023-06-04 06:58:39', '2023-06-04 06:58:39'),
(200, 200, 1, 190, 98, 'Maxamed axmed baashe', '634432380', 'Burco', '2023-06-08', 'Nuura cali axmed', 'Male', '634432380', 24000, 0, 'RCS_TRAN_FAILED_AT_ISSUER_SYSTEM (STATE: rejected, ERRCODE: 4004 - timeout occured waiting user response, TransactionId: 30776004) (STATE: rejected, E', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-06-08', '2023-06-08 03:41:52', '2023-06-08 03:41:52'),
(201, 201, 1, 190, 98, 'Maxamed axmed baashe', '637866366', 'Burco', '2023-06-08', 'Nuura cali axmed', 'Male', '634432380', 24000, 0, 'Wuu diiday', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-06-08', '2023-06-08 03:42:47', '2023-06-08 03:42:47'),
(202, 202, 1, 190, 98, 'Maxamed axmed baashe', '634432380', 'Burco', '2023-06-08', 'Nuura cali axmed', 'Male', '634432380', 24000, 1, 'Ok', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-06-08', '2023-06-08 03:43:20', '2023-06-08 03:43:20'),
(203, 203, 1, 190, 98, 'Siciid cabdi adan', '634471123', 'Burco', '2023-06-08', 'Surer sahal jiciir', 'Male', '634471123', 24000, 1, 'Ok', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-06-08', '2023-06-08 04:25:46', '2023-06-08 04:25:46'),
(204, 204, 1, 190, 98, 'Maxamed axmed baashe', '634432380', 'Hargeysa', '2023-06-08', 'Nuura axmed guuled', 'Male', '634432380', 24000, 0, 'RCS_TRAN_TIMEOUT_AT_ISSUER_SYSTEM (Timeout_no_response_recvd, TransactionId: 30776478) (Timeout_no_response_recvd, TransactionId: 30776478)', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-06-08', '2023-06-08 04:41:04', '2023-06-08 04:41:04'),
(205, 205, 1, 190, 98, 'Maxamed axmed baashe', '637866366', 'Burco', '2023-06-08', 'Xaawo cali farax', 'Male', '634432380', 24000, 0, 'RCS_TRAN_FAILED_AT_ISSUER_SYSTEM (Connection Error, TransactionId: 30776537) (Connection Error, TransactionId: 30776537)', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-06-08', '2023-06-08 04:42:49', '2023-06-08 04:42:49'),
(206, 206, 1, 190, 98, 'Maxamed axmed baashe', '634432380', 'Burco', '2023-06-08', 'Xaawo cali farax', 'Male', '634432380', 24000, 0, 'RCS_TRAN_TIMEOUT_AT_ISSUER_SYSTEM (Timeout_no_response_recvd, TransactionId: 30776600) (Timeout_no_response_recvd, TransactionId: 30776600)', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-06-08', '2023-06-08 04:44:47', '2023-06-08 04:44:47'),
(207, 207, 1, 190, 98, 'Maxamed axmed baashe', '0634432380', 'Burco', '2023-06-08', 'Xaawo cali farax', 'Male', '0634432380', 24000, 0, 'Telkaa qaldan 0634432380', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-06-08', '2023-06-08 04:45:17', '2023-06-08 04:45:17'),
(208, 208, 1, 190, 98, 'Maxamed axmed baashe', '0634432380', 'Burco', '2023-06-08', 'Xaawo cali farax', 'Male', '0634432380', 24000, 0, 'Telkaa qaldan 0634432380', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-06-08', '2023-06-08 04:45:24', '2023-06-08 04:45:24'),
(209, 209, 1, 190, 98, 'Maxamed axmed baashe', '0634432380', 'Burco', '2023-06-08', 'Xaawo cali farax', 'Male', '0634432380', 24000, 0, 'Telkaa qaldan 0634432380', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-06-08', '2023-06-08 04:45:30', '2023-06-08 04:45:30'),
(210, 210, 1, 190, 98, 'Maxamed axmed baashe', '0634432380', 'Burco', '2023-06-08', 'Xaawo cali farax', 'Male', '634432380', 24000, 0, 'RCS_TRAN_TIMEOUT_AT_ISSUER_SYSTEM (Timeout_no_response_recvd, TransactionId: 30776681) (Timeout_no_response_recvd, TransactionId: 30776681)', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-06-08', '2023-06-08 04:46:57', '2023-06-08 04:46:57'),
(211, 211, 1, 190, 99, 'Maxamed axmed baashe', '634432380', 'Burco', '2023-06-08', 'Xaawo nuur cali', 'Male', '634432380', 24000, 1, 'Ok', 'Dhakhtarka Ilkaha-Shifo pharmacy', 0, '2023-06-08', '2023-06-08 14:09:32', '2023-06-08 14:09:32'),
(212, 212, 1, 190, 98, 'Maxamed axmed baashe', '637866366', 'Burco', '2023-06-10', 'Nuura axmed yusuf', 'Male', '634432380', 24000, 0, 'RCS_TRAN_FAILED_AT_ISSUER_SYSTEM (STATE: rejected, ERRCODE: 4004 - timeout occured waiting user response, TransactionId: 30828105) (STATE: rejected, E', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-06-10', '2023-06-10 20:15:04', '2023-06-10 20:15:04'),
(213, 213, 1, 182, 81, 'Maxamed axmed baashe', '67866366', 'Burco', '2023-06-11', 'Nuura axmed yusuf', 'Male', '634432380', 79000, 1, 'Ok', 'Dhakhtarka Maqaarka-Procare poly clinic center pharmacy', 0, '2023-06-11', '2023-06-11 18:31:51', '2023-06-11 18:31:51'),
(214, 214, 1, 193, 106, 'Maxamed axmed baashe', '637866366', 'Hargeysa', '2023-06-12', 'Haweya nuur warsame', 'Male', '634432380', 95000, 1, 'Ok', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-06-12', '2023-06-12 03:02:04', '2023-06-12 03:02:04'),
(215, 215, 1, 190, 98, 'Maxamed axmed bashe', '636110636', 'Hargeysa', '2023-06-18', 'Haweya cali nuuur', 'Male', '634432380', 24000, 1, 'Ok', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-06-18', '2023-06-18 19:21:34', '2023-06-18 19:21:34'),
(216, 216, 1, 190, 98, 'Maxamed axmed baashe', '637866366', 'Burco', '2023-06-24', 'Nuura cali yusuf', 'Male', '634432380', 24000, 0, 'RCS_TRAN_FAILED_AT_ISSUER_SYSTEM (STATE: rejected, ERRCODE: 4004 - timeout occured waiting user response, TransactionId: 31040310) (STATE: rejected, E', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-06-24', '2023-06-24 07:09:49', '2023-06-24 07:09:49'),
(217, 217, 1, 190, 98, 'Maxamed axmed bashe', '634432380', 'Burco', '2023-07-02', 'Hooyo xaqo axmed', 'Female', '634432380', 24000, 0, 'Wuu diiday', 'Dhakhtarka Cunaha-Shifo pharmacy', 0, '2023-07-02', '2023-07-02 18:00:52', '2023-07-02 18:00:52'),
(218, 218, 1, 193, 106, 'Maxamed axmed bashe', '637866366', 'Burco', '2023-07-07', 'Nuura cali warsme', 'Male', '634432380', 95000, 0, 'Wuu diiday', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-07-08', '2023-07-08 20:19:20', '2023-07-08 20:19:20'),
(219, 219, 1, 193, 106, 'Maxamed axmed baashe', '63786636', 'Burco', '2023-07-07', 'Nuura xasan cali', 'Male', '634432380', 95000, 1, 'Ok', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-07-08', '2023-07-08 20:48:29', '2023-07-08 20:48:29'),
(220, 220, 1, 193, 108, 'Farduus Cabdilaahi Jaamac', '0634169227', 'Hargeisa', '1981-06-06', 'Hodan axmed cali', 'Male', '0633463605', 95000, 0, 'Telkaa qaldan 0634169227', 'Dhakhtarka Neerfaha-Amal grand hospital', 0, '2023-07-13', '2023-07-13 12:08:25', '2023-07-13 12:08:25'),
(221, 221, 1, 193, 108, 'Farduus Cabdilaahi Jaamac', '0634169227', 'Hargeisa', '1981-06-06', 'Hodan axmed cali', 'Male', '0653463605', 95000, 0, 'Telkaa qaldan 0634169227', 'Dhakhtarka Neerfaha-Amal grand hospital', 0, '2023-07-13', '2023-07-13 12:08:48', '2023-07-13 12:08:48'),
(222, 222, 1, 193, 108, 'Farduus Cabdilaahi Jaamac', '0634169227', 'Hargeisa', '1981-06-06', 'Hodan axmed cali', 'Female', '0653463605', 95000, 0, 'Telkaa qaldan 0634169227', 'Dhakhtarka Neerfaha-Amal grand hospital', 0, '2023-07-13', '2023-07-13 12:09:02', '2023-07-13 12:09:02'),
(223, 223, 1, 193, 106, 'Muno mohamed Esmaciil', '634764159', 'Hargeysa', '2023-07-16', 'Xalimo jamac ismaciil', 'Female', '636882742', 95000, 0, 'RCS_TRAN_FAILED_AT_ISSUER_SYSTEM (STATE: rejected, ERRCODE: 4004 - timeout occured waiting user response, TransactionId: 31442611) (STATE: rejected, E', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-07-16', '2023-07-16 08:19:37', '2023-07-16 08:19:37'),
(224, 224, 1, 193, 106, 'Muno mohamed Esmaciil', '634764159', 'Hargeysa', '2023-07-16', 'Xalimo jamac ismaciil', 'Female', '634764159', 95000, 0, 'Wuu diiday', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-07-16', '2023-07-16 08:20:47', '2023-07-16 08:20:47'),
(225, 225, 1, 193, 106, 'Maxamed axmed bashe', '634432380', 'Burco', '2023-07-17', 'Nuura cali yusuf', 'Male', '634432380', 95000, 0, 'Wuu diiday', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-07-17', '2023-07-17 08:46:13', '2023-07-17 08:46:13'),
(226, 226, 1, 193, 106, 'Maxamed axmed baashe', '634432380', 'Burco', '2023-07-23', 'Nuura xasan cali', 'Male', '634432380', 95000, 0, 'Wuu diiday', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-07-23', '2023-07-23 18:32:03', '2023-07-23 18:32:03'),
(227, 227, 1, 193, 106, 'Maxamed axmed bashe', '634432380', 'Burco', '2023-07-25', 'Nuura cali yusuf', 'Male', '634432380', 95000, 0, 'RCS_TRAN_FAILED_AT_ISSUER_SYSTEM (timeout occured waiting user response, TransactionId: 31597979) (timeout occured waiting user response, TransactionI', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-07-25', '2023-07-25 09:24:31', '2023-07-25 09:24:31'),
(228, 228, 1, 193, 106, 'Maxamed axmed bashe', '634432380', 'Burco', '2023-07-25', 'Nuura xasan cali', 'Male', '634432380', 95000, 0, 'Wuu diiday', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-07-25', '2023-07-25 17:13:44', '2023-07-25 17:13:44'),
(229, 229, 1, 193, 106, 'Maxamed axmed bashe', '634432380', 'Burco', '2023-07-27', 'Nuura cali nuur', 'Male', '634432380', 95000, 0, 'RCS_USER_REJECTED', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-07-27', '2023-07-27 18:24:48', '2023-07-27 18:24:48'),
(230, 230, 1, 193, 106, 'Hibo cabdi xuse', '0634324478', 'Hargeysa', '2023-08-05', 'Xawo cabdi cumar', 'Female', '4324478', 95000, 0, 'Telkaa qaldan 0634324478', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-07-30', '2023-07-30 08:35:38', '2023-07-30 08:35:38'),
(231, 231, 1, 193, 106, 'Hibo cabdi xuse', '634324478', 'Hargeysa', '2023-08-05', 'Xawo cabdi cumar', 'Female', '634324478', 95000, 0, 'RCS_USER_REJECTED', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-07-30', '2023-07-30 08:36:27', '2023-07-30 08:36:27'),
(232, 232, 1, 189, 97, 'Maxamed axmed baashe', '67866366', 'Hargeysa', '2019-06-04', 'Nuura cali axmed', 'Male', '634432380', 76000, 0, 'RCS_USER_REJECTED', 'Dhakhtarka Cunaha-Mahdi hospital', 0, '2023-08-14', '2023-08-14 19:58:41', '2023-08-14 19:58:41'),
(233, 233, 1, 193, 106, 'Nuura  cali axmed', '634432380', 'Burco', '2023-10-24', 'Xawo yusuf cali', 'Male', '634432380', 95000, 1, 'Ok', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-10-24', '2023-10-24 15:52:44', '2023-10-24 15:52:44'),
(234, 234, 1, 193, 106, 'Khaadar maxamud', '634120268', 'Burcp', '2023-10-31', 'Niura cali', 'Male', '634120268', 95000, 0, 'RCS_USER_REJECTED', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-10-31', '2023-10-31 09:16:23', '2023-10-31 09:16:23'),
(235, 235, 1, 193, 106, 'Khadar Mohamed', '634120268', 'Hargaysa', '2023-10-31', 'Shukri Abdilahi', 'Male', '0634048417', 95000, 0, 'Telkaa qaldan 634120268', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-10-31', '2023-10-31 09:17:41', '2023-10-31 09:17:41'),
(236, 236, 1, 193, 106, 'Khadar Mohamed', '634120268', 'Hargaysa', '2023-10-31', 'Shukri Abdilahi', 'Male', '0634048417', 95000, 0, 'Telkaa qaldan 634120268', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-10-31', '2023-10-31 09:18:03', '2023-10-31 09:18:03'),
(237, 237, 1, 193, 106, 'Khadar Mohamed', '634120268', 'Hargaysa', '2023-10-31', 'Shukri Abdilahi', 'Male', '634048417', 95000, 0, 'RCS_USER_REJECTED', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-10-31', '2023-10-31 09:18:34', '2023-10-31 09:18:34'),
(238, 238, 1, 193, 106, 'Maxamed axmed', '634432380', 'Burco', '2023-11-22', 'Nuura xasan', 'Male', '634432380', 95000, 0, 'RCS_USER_REJECTED', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-11-21', '2023-11-21 16:28:30', '2023-11-21 16:28:30'),
(239, 239, 1, 186, 88, 'Maxamed axmed', '634432380', 'Burco', '2023-11-20', 'Nuura cali', 'Male', '634432380', 136000, 1, 'Ok', 'Dhakhtarka Cunaha-Baxnaano speciality clinic', 0, '2023-11-24', '2023-11-24 16:42:42', '2023-11-24 16:42:42'),
(240, 240, 1, 193, 106, 'Maxamed axmed', '634432380', 'Burco', '2023-11-07', 'Fadumo cali', 'Male', '634432380', 95000, 1, 'Ok', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-11-28', '2023-11-28 10:42:21', '2023-11-28 10:42:21'),
(241, 241, 1, 193, 106, 'Farduus cabdi adan', '4125032', 'Burco', '2023-12-01', 'Sureer sahal jiciir', 'Female', '4425036', 95000, 0, 'Telkaa qaldan 4125032', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2023-12-06', '2023-12-06 17:51:08', '2023-12-06 17:51:08'),
(242, 242, 1, 183, 83, 'Maxamed cali ciisa', '0621138035', 'Celasha biyaha', '2024-01-11', 'Farxiyo', 'Male', '062138035', 39000, 0, 'Telkaa qaldan 0621138035', 'Dhakhtarka Caruurta-Gurmad medical center pharmacy', 0, '2024-01-10', '2024-01-10 17:07:21', '2024-01-10 17:07:21'),
(243, 243, 1, 183, 83, 'Maxamed cali ciisa', '0621138035', 'Celasha biyaha', '2024-01-11', 'Farxiyo', 'Male', '062138035', 39000, 0, 'Telkaa qaldan 0621138035', 'Dhakhtarka Caruurta-Gurmad medical center pharmacy', 0, '2024-01-10', '2024-01-10 17:07:55', '2024-01-10 17:07:55'),
(244, 244, 1, 193, 106, 'Maxamed axmed baashe', '634432380', 'Burco', '2024-01-22', 'Nuura cali', 'Male', '634432380', 95000, 1, 'Ok', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2024-01-22', '2024-01-22 08:58:38', '2024-01-22 08:58:38'),
(245, 245, 1, 193, 106, 'Hamse', '634432380', 'Newnhargeisa', '2016-08-05', 'Nuuta', 'Male', '634432380', 95000, 0, 'RCS_USER_REJECTED', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2024-01-28', '2024-01-28 17:53:51', '2024-01-28 17:53:51'),
(246, 246, 1, 193, 106, 'Hamse', '634432380', 'Newnhargeisa', '2016-08-05', 'Nuuta', 'Male', '634432380', 95000, 1, 'Ok', 'Dhakhtarka Caruurta-Amal grand hospital', 0, '2024-01-28', '2024-01-28 17:54:04', '2024-01-28 17:54:04'),
(247, 247, 1, 193, 108, 'Maxamed', '634432380', 'Burco', '2024-06-06', 'Nuura', 'Male', '634432380', 95000, 0, 'RCS_USER_REJECTED', 'Dhakhtarka Neerfaha-Amal grand hospital', 0, '2024-02-16', '2024-02-16 20:25:59', '2024-02-16 20:25:59');

-- --------------------------------------------------------

--
-- Table structure for table `blood`
--

CREATE TABLE `blood` (
  `id` int(11) NOT NULL,
  `auto_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `tell` int(11) NOT NULL,
  `address` varchar(100) NOT NULL,
  `gender` varchar(100) NOT NULL,
  `blood_group` varchar(100) NOT NULL,
  `user_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `branch`
--

CREATE TABLE `branch` (
  `id` int(11) NOT NULL,
  `auto_id` int(11) DEFAULT NULL,
  `company_id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL COMMENT 'manajerka xarunta aya lagu qoraa',
  `name` varchar(100) NOT NULL,
  `tell` varchar(100) NOT NULL,
  `email` varchar(50) NOT NULL,
  `address` varchar(100) NOT NULL,
  `user_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `branch`
--

INSERT INTO `branch` (`id`, `auto_id`, `company_id`, `employee_id`, `name`, `tell`, `email`, `address`, `user_id`, `date`, `action_date`, `modified_date`) VALUES
(1, 1, 1, 0, 'Main Branch', '', '', '', 0, '2017-09-11', '2022-03-06 14:34:49', '2022-12-22 09:45:17');

-- --------------------------------------------------------

--
-- Table structure for table `campaign`
--

CREATE TABLE `campaign` (
  `id` int(11) NOT NULL,
  `auto_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `user_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `campaign`
--

INSERT INTO `campaign` (`id`, `auto_id`, `company_id`, `name`, `description`, `start_date`, `end_date`, `user_id`, `date`, `action_date`, `modified_date`) VALUES
(1, 1, 1, 'January/2023', '<p><strong>Olalaha January/2023&nbsp;</strong>ee App-ka&nbsp;<strong>Bulsho Tech&nbsp;</strong>waa olole aad uga qeyb qaadan karto si bilaash kuna heliysid lacago, ololahan waxaa ka qeyb qaadan karo qof walba oo joogo dhammaan gobolada dalka soomaaliiya rag iyo dumarba, waxaad u baahantahay oo kaliya inaad haysato Taleefan iyo Internet, hadii aad labadaas heli karto haddaba ku dhaqaaq qodobadan oo 5 maalmood ku sameey lacag dhan $25.</p>\r\n\r\n<p><strong><u>Hab-ka uu u shaqeynayo ololaha</u></strong></p>\r\n\r\n<ol>\r\n	<li>Ololahan waa olole lagu&nbsp;<strong>Share&nbsp;</strong>gareynayo App-ka Bulsho Tech adigoo ku shaqre gareynaya akoonada aad ku leedahay baraha bulshada sida&nbsp;<strong>Whatsapp-ka, Facebook, Tiktok, Instgram IWM</strong></li>\r\n	<li>Marka hore waxaa iska diiwaangelinayaa App-ka Bulsho Tech waxaana lagu siinayaa Link kuu gaar ah&nbsp;oo aad la wadaagi karto asxaabtaada caadiga ah iyo kuwa baraha bulshada</li>\r\n	<li>Ololahan waa olole bille ah waxaana la qabtaa dhammad bil kasta wuxuuna socdaa 25-ka ilaa 31-da bil kasta, Ololahan waa midkii ugu horeeyay wuxuuna soconayaa inta u dhexeysa <strong>26 - 31 January 2023.</strong></li>\r\n	<li>Ka qeyb galayaasha waxay kasoo muuqanayaa App-ka Bulsho Tech qeybta Ololaha iyadoo qof walba uu arkayo Tirada dad-ka uu u shaqre gareeyay iyo tirada dadka la degtay App-ka</li>\r\n	<li>Sidoo kale waxaad arki kartaa 10-ka tartame ee ugu horeysa share-gareynta iyo sida ay ukala badan yihiin</li>\r\n	<li>Guuleystayaasha waxaa lagu dhawaaqayaa 2da bil kasta, iyadoo <strong>2da February 2023,&nbsp;</strong></li>\r\n	<li>Guuleystaha gala kaalinta 1aad wuxuu leeyahy lacag dhan $25, guuleystaha 2aad $15, halka guuleystaha 3aad uu leeyahay $10.</li>\r\n</ol>\r\n\r\n<p>Si aad uga qeyb qaadato raac tilmaaha hoose</p>\r\n\r\n<p><strong><u>Hab-ka aad uga qeyb qaadan karto ololaha</u></strong></p>\r\n\r\n<ol>\r\n	<li>Hadii aadan horay iska diiwaangelin App-ka Bulsho Tech, Iska diiwaangeli <a href=\"https://apps.bulshotech.com/agent/regsiter\">Guji halkan</a>&nbsp;kadibna buuxi foom-ka</li>\r\n	<li>Wuxuu si toos ah kuu geynayaa Profile-kaaga oo kaaga soo muuqanaya xogtaada.</li>\r\n	<li>Dooro Qeybta Ololaha kadibna kadibna guji ka qeyb gal ololaha</li>\r\n</ol>\r\n\r\n<p><strong><em>Ka qeyb-gal wacan, waxaana kuu rajeynaynaa Guul</em></strong></p>', '2023-01-26', '2023-01-31', 2, '2023-01-24', '2023-01-24 09:02:04', '2023-01-24 09:02:04');

-- --------------------------------------------------------

--
-- Table structure for table `campaign_agent`
--

CREATE TABLE `campaign_agent` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `agent_id` int(11) NOT NULL,
  `campaign_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `campaign_agent`
--

INSERT INTO `campaign_agent` (`id`, `company_id`, `agent_id`, `campaign_id`, `date`, `action_date`, `modified_date`) VALUES
(1, 1, 1, 1, '2023-01-26', '2023-01-26 05:39:23', '2023-01-26 05:39:23'),
(9, 1, 2, 1, '2023-01-26', '2023-01-26 06:17:09', '2023-01-26 06:17:09');

-- --------------------------------------------------------

--
-- Table structure for table `company`
--

CREATE TABLE `company` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `tell` varchar(50) NOT NULL,
  `email` varchar(50) NOT NULL,
  `address` varchar(100) NOT NULL,
  `merchant_no` int(11) NOT NULL,
  `domain` varchar(100) NOT NULL,
  `letter_head` varchar(100) NOT NULL,
  `logo` varchar(100) NOT NULL,
  `slider1` varchar(100) NOT NULL,
  `slider2` varchar(100) NOT NULL,
  `slider3` varchar(100) NOT NULL,
  `facebook` varchar(100) NOT NULL,
  `twitter` varchar(100) NOT NULL,
  `instgram` varchar(100) NOT NULL,
  `google_plus` varchar(100) NOT NULL,
  `linkedin` varchar(100) NOT NULL,
  `theme_style` varchar(100) NOT NULL DEFAULT 'skin-purple-light',
  `user_id` int(11) NOT NULL,
  `type` varchar(50) NOT NULL DEFAULT 'main',
  `description` text NOT NULL,
  `dv_academic` varchar(100) NOT NULL,
  `absent_date` date NOT NULL DEFAULT '2022-11-24',
  `date` date NOT NULL,
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `expiry_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `company`
--

INSERT INTO `company` (`id`, `name`, `tell`, `email`, `address`, `merchant_no`, `domain`, `letter_head`, `logo`, `slider1`, `slider2`, `slider3`, `facebook`, `twitter`, `instgram`, `google_plus`, `linkedin`, `theme_style`, `user_id`, `type`, `description`, `dv_academic`, `absent_date`, `date`, `action_date`, `modified_date`, `expiry_date`) VALUES
(1, 'Bulsho Kaabe Health Services', '614945025,614945026,614945027', 'info@bulshotech.com', 'Mogadishu Somalia', 70, 'bulshokaabe.bulshotech.com,bk.bulshotech.com', 'images/bunner_ktc.PNG', 'uploads/bulshokaabehealthservices_ktceditsp_20230604050954.jpeg', 'uploads/universityofsomalia(uniso)_ktceditsp_20221108114929.jpg', 'uploads/universityofsomalia(uniso)_ktceditsp_20221108115125.jpg', 'uploads/universityofsomalia(uniso)_ktceditsp_20221108115133.jpg', 'https://www.facebook.com/UnisoUniversity', 'https://twitter.com/', 'https://www.instagram.com/', 'https://myaccount.google.com/', 'https://www.linkedin.com/', 'skin-purple-light', 1, 'main', '', 'Dr. Hassan Mohamed Sayid', '2022-11-24', '2019-07-04', '2019-07-05 06:26:14', '2023-06-04 10:09:54', '2021-04-05 12:12:41');

-- --------------------------------------------------------

--
-- Table structure for table `department`
--

CREATE TABLE `department` (
  `id` int(11) NOT NULL,
  `auto_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL COMMENT 'name',
  `image` varchar(100) NOT NULL COMMENT 'Image~file',
  `description` varchar(100) NOT NULL COMMENT 'description',
  `user_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `department`
--

INSERT INTO `department` (`id`, `auto_id`, `company_id`, `name`, `image`, `description`, `user_id`, `date`, `action_date`, `modified_date`) VALUES
(5, 5, 1, 'Dhakhtarka Lafaha', 'uploads/bulshotechapps_ktceditsp_20221226020015.jpeg', '', 0, '2022-12-26', '2022-12-26 07:44:53', '2022-12-29 20:47:20'),
(6, 6, 1, 'Dhakhtarka Cudurada Guud', 'uploads/bulshotechapps_ktceditsp_20221226020200.jpeg', '', 0, '2022-12-26', '2022-12-26 07:44:53', '2022-12-29 20:47:30'),
(7, 7, 1, 'Dhakhtarka Qaliimada Guud', 'uploads/bulshotechapps_ktceditsp_20221226020357.jpeg', '', 0, '2022-12-26', '2022-12-26 07:44:53', '2022-12-29 20:47:42'),
(8, 8, 1, 'Dhakhtarka Wadnaha', 'uploads/bulshotechapps_ktceditsp_20221226020747.jpeg', '', 0, '2022-12-26', '2022-12-26 07:44:53', '2022-12-29 20:47:53'),
(9, 9, 1, 'Dhakhtarka Kilyaha', 'uploads/bulshotechapps_ktceditsp_20221226020557.jpeg', '', 0, '2022-12-26', '2022-12-26 07:44:53', '2022-12-29 20:48:02'),
(10, 10, 1, 'Dhakhtarka Radiologist', 'uploads/bulshotechapps_ktceditsp_20221226021116.jpeg', '', 0, '2022-12-26', '2022-12-26 07:44:53', '2022-12-29 20:48:10'),
(11, 11, 1, 'Dhakhtarka Caruurta', 'uploads/bulshotechapps_ktceditsp_20221226021329.jpeg', '', 0, '2022-12-26', '2022-12-26 07:44:53', '2022-12-29 20:48:18'),
(12, 12, 1, 'Dhakhtarka Indhaha', 'uploads/bulshotechapps_ktceditsp_20221226021524.jpeg', '', 0, '2022-12-26', '2022-12-26 07:44:53', '2022-12-29 20:48:30'),
(13, 13, 1, 'Dhakhtarka Cunaha', 'uploads/bulshotechapps_ktceditsp_20221226022236.jpeg', '', 0, '2022-12-26', '2022-12-26 07:44:53', '2022-12-29 20:48:36'),
(14, 14, 1, 'Dhakhtarka Neerfaha', 'uploads/bulshotechapps_ktceditsp_20221226022247.jpeg', '', 0, '2022-12-26', '2022-12-26 07:44:53', '2022-12-29 20:48:46'),
(15, 15, 1, 'Dhakhtarka Haweenka', 'uploads/bulshotechapps_ktceditsp_20221226022521.jpeg', '', 0, '2022-12-26', '2022-12-26 07:44:53', '2022-12-29 20:48:53'),
(16, 16, 1, 'Dhakhtarka Ilkaha', 'uploads/bulshotechapps_ktceditsp_20221226022406.jpg', '', 0, '2022-12-26', '2022-12-26 07:44:53', '2022-12-29 20:49:00'),
(17, 17, 1, 'Dhakhtarka Maqaarka', 'uploads/bulshotechapps_ktceditsp_20221226022923.jpeg', '', 0, '2022-12-26', '2022-12-26 07:44:53', '2022-12-29 20:49:10'),
(18, 18, 1, 'Dhakhtarka Dheefshiidka', 'uploads/bulshotechapps_ktceditsp_20221226022011.webp', '', 0, '2022-12-26', '2022-12-26 07:44:53', '2022-12-29 20:49:25'),
(19, 19, 1, 'Dhakhtarka Baabasiirka', 'uploads/bulshotechapps_ktceditsp_20221226021925.jpg', '', 0, '2022-12-26', '2022-12-26 07:44:53', '2022-12-29 20:49:19'),
(20, 20, 1, 'Dhakhtarka Dhimirka', 'uploads/bulshotechapps_departmentsp_20221229155414.jpg', 'dhimirka', 3, '2022-12-29', '2022-12-29 21:54:14', '2022-12-29 21:54:14'),
(21, 21, 1, 'Dhaqtar-ka caruurta ee wadnaha', 'uploads/bulshokaabehealthservices_departmentsp_20230410215858.jpg', '', 2, '2023-04-10', '2023-04-11 02:58:58', '2023-04-11 02:58:58'),
(22, 22, 1, 'Dhaqtar-ka cancer-ka', 'uploads/bulshokaabehealthservices_departmentsp_20230410220032.jpg', '', 2, '2023-04-10', '2023-04-11 03:00:32', '2023-04-11 03:00:32'),
(23, 23, 1, 'Dhaqtar-ka shaybara cancarka', 'uploads/bulshokaabehealthservices_departmentsp_20230410220104.jpg', '', 2, '2023-04-10', '2023-04-11 03:01:04', '2023-04-11 03:01:04'),
(24, 24, 1, 'Dhaqtar-ka suxiyaha iyo daweynta xanunada culus', 'uploads/bulshokaabehealthservices_departmentsp_20230410220136.jpg', '', 2, '2023-04-10', '2023-04-11 03:01:36', '2023-04-11 03:01:36');

-- --------------------------------------------------------

--
-- Table structure for table `doctor`
--

CREATE TABLE `doctor` (
  `id` int(11) NOT NULL,
  `auto_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `hospital_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL COMMENT 'name',
  `tell` int(11) NOT NULL COMMENT 'tell',
  `image` varchar(100) NOT NULL COMMENT 'iamge',
  `department_id` int(11) NOT NULL,
  `description` text COMMENT 'description~textarea',
  `ticket_fee` double NOT NULL COMMENT 'ticket_fee',
  `user_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `doctor`
--

INSERT INTO `doctor` (`id`, `auto_id`, `company_id`, `hospital_id`, `name`, `tell`, `image`, `department_id`, `description`, `ticket_fee`, `user_id`, `date`, `action_date`, `modified_date`) VALUES
(1, 1, 1, 27, 'Dr Obaida Al Khalifi', 0, 'error', 16, NULL, 0, 2, '2022-12-26', '2022-12-26 07:56:14', '2022-12-26 07:56:14'),
(2, 2, 1, 27, 'Dr Ibrahim Abdi rahman (foodcade)', 0, 'error', 18, NULL, 0, 2, '2022-12-26', '2022-12-26 07:56:45', '2022-12-26 07:56:45'),
(3, 3, 1, 27, 'Dr Safaa Mohamed', 0, 'error', 15, NULL, 0, 2, '2022-12-26', '2022-12-26 07:57:13', '2022-12-26 07:57:13'),
(4, 4, 1, 27, 'Dr Abdirahman Xashi Dhiif', 0, 'error', 13, NULL, 0, 2, '2022-12-26', '2022-12-26 07:57:41', '2022-12-26 07:57:41'),
(5, 5, 1, 27, 'Dr Muhammed Abdul Hamid', 0, 'error', 19, NULL, 0, 2, '2022-12-26', '2022-12-26 07:58:07', '2022-12-26 07:58:07'),
(6, 6, 1, 27, 'Dr Hussain Cabdulaziz Abdulkadir (FATXI)', 0, 'error', 6, NULL, 0, 2, '2022-12-26', '2022-12-26 07:58:32', '2022-12-26 07:58:32'),
(7, 7, 1, 151, 'Dr Abdaladif Mohamed Ali', 0, 'uploads/bulshotechapps_doctorsp_20221228123152.jpg', 14, NULL, 10, 2, '2022-12-28', '2022-12-28 18:31:52', '2022-12-28 18:31:52'),
(8, 8, 1, 151, 'Dr Ahmed Ali (Ahmed Medicine)', 0, 'uploads/bulshotechapps_doctorsp_20221228124123.jpg', 6, NULL, 0, 2, '2022-12-28', '2022-12-28 18:41:23', '2022-12-28 18:41:23'),
(9, 9, 1, 15, 'Dr Rami Maruf', 619030303, 'error', 16, NULL, 10, 3, '2022-12-29', '2022-12-29 21:48:20', '2022-12-29 21:48:20'),
(10, 10, 1, 15, 'Dr Mariam Ali Abdulle', 619030303, 'error', 11, NULL, 10, 3, '2022-12-29', '2022-12-29 21:49:21', '2022-12-29 21:49:21'),
(11, 11, 1, 15, 'Dr Isxaaq Afgaab', 619030303, 'error', 6, NULL, 10, 3, '2022-12-29', '2022-12-29 21:49:52', '2022-12-29 21:49:52'),
(12, 12, 1, 150, 'Dr.Abdiladif Mohamed Ali', 613773333, 'error', 14, NULL, 7, 3, '2022-12-29', '2022-12-29 21:56:40', '2023-01-01 09:21:11'),
(13, 13, 1, 150, 'Dr.Ahmed Isxaaq', 613773333, 'error', 15, NULL, 7, 3, '2022-12-29', '2022-12-29 21:57:04', '2023-01-01 09:21:11'),
(14, 14, 1, 150, 'DR.Abdixaliim', 613773333, 'error', 11, NULL, 7, 3, '2022-12-29', '2022-12-29 21:57:27', '2022-12-29 21:57:27'),
(15, 15, 1, 150, 'Dr.Abdihalim Mohamud Mohamed', 613773333, 'error', 20, NULL, 7, 3, '2022-12-29', '2022-12-29 21:57:50', '2023-01-01 09:21:11'),
(16, 16, 1, 150, 'Dr.Ibraahim', 613773333, 'error', 16, NULL, 7, 3, '2022-12-29', '2022-12-29 21:58:10', '2023-01-01 09:21:11'),
(17, 17, 1, 150, 'Dr.Mohamed Abdullahi', 613773333, 'error', 8, NULL, 7, 3, '2022-12-29', '2022-12-29 21:58:28', '2022-12-29 21:58:28'),
(18, 18, 1, 150, 'Dr.Mohamed Cabdulahi', 613773333, 'error', 6, NULL, 7, 3, '2022-12-29', '2022-12-29 21:58:49', '2023-01-01 09:21:11'),
(19, 19, 1, 150, 'Dr.Maymun Abdi Gelle', 613773333, 'error', 15, NULL, 10, 3, '2022-12-29', '2022-12-29 21:59:08', '2023-01-01 09:21:11'),
(20, 20, 1, 150, 'Dr.Ibaraahim Guuled', 613773333, 'error', 11, NULL, 7, 3, '2022-12-29', '2022-12-29 21:59:34', '2022-12-29 21:59:34'),
(21, 21, 1, 150, 'Dr.Ahmed mohamed bas', 613773333, 'error', 9, NULL, 7, 3, '2022-12-29', '2022-12-29 21:59:56', '2023-01-01 09:21:11'),
(22, 22, 1, 150, 'Dr.Hussen Ali Shiiq', 613773333, 'error', 9, NULL, 7, 3, '2022-12-29', '2022-12-29 22:00:22', '2023-01-01 09:21:11'),
(23, 23, 1, 150, 'Dr.Kaarshe', 613773333, 'error', 5, NULL, 7, 3, '2022-12-29', '2022-12-29 22:00:53', '2023-01-01 09:21:11'),
(24, 24, 1, 150, 'Dr.Yaasmiin Mohamud', 613773333, 'error', 13, NULL, 7, 3, '2022-12-29', '2022-12-29 22:01:51', '2023-01-01 09:21:11'),
(25, 25, 1, 150, 'Dr.Mohamed Akcay', 613773333, 'error', 12, NULL, 7, 3, '2022-12-29', '2022-12-29 22:02:01', '2023-01-01 09:21:11'),
(26, 26, 1, 9, 'Dr Ali Tammim', 613334666, 'error', 14, NULL, 5, 3, '2022-12-31', '2022-12-31 09:36:22', '2022-12-31 09:36:22'),
(27, 27, 1, 9, 'Dr Ramla Mahamed', 613334666, 'error', 11, NULL, 5, 3, '2022-12-31', '2022-12-31 09:36:44', '2022-12-31 09:36:44'),
(28, 28, 1, 9, 'Dr Abdullahi m hegaze', 613334666, 'error', 13, NULL, 5, 3, '2022-12-31', '2022-12-31 09:37:33', '2022-12-31 09:37:33'),
(29, 29, 1, 9, 'Dr Anas', 613334666, 'error', 16, NULL, 5, 3, '2022-12-31', '2022-12-31 09:37:47', '2022-12-31 09:37:47'),
(31, 31, 1, 28, 'Dr Urmetbek', 613662525, 'error', 15, NULL, 5, 3, '2022-12-31', '2022-12-31 09:39:22', '2022-12-31 09:39:22'),
(33, 32, 1, 23, 'Dr Usama Al sayid Ahmed', 613233333, 'error', 10, NULL, 10, 3, '2022-12-31', '2022-12-31 09:48:21', '2022-12-31 09:48:21'),
(34, 33, 1, 23, 'Dr Hassan Alzaim', 613233333, 'error', 6, NULL, 10, 3, '2022-12-31', '2022-12-31 09:48:38', '2022-12-31 09:48:38'),
(35, 34, 1, 23, 'Dr Bilaal Kamil Yunis', 613233333, 'error', 14, NULL, 10, 3, '2022-12-31', '2022-12-31 09:48:54', '2022-12-31 09:48:54'),
(36, 35, 1, 23, 'Dr Subhi Sa\'dul diin', 613233333, 'error', 12, NULL, 10, 3, '2022-12-31', '2022-12-31 09:49:12', '2022-12-31 09:49:12'),
(37, 36, 1, 23, 'Dr Amar Mohamuud Dib', 613233333, 'error', 7, NULL, 10, 3, '2022-12-31', '2022-12-31 09:49:27', '2022-12-31 09:49:27'),
(38, 37, 1, 23, 'Dr.Nisha pragati', 613233333, 'error', 15, NULL, 10, 3, '2022-12-31', '2022-12-31 09:49:46', '2023-01-01 09:21:11'),
(39, 38, 1, 23, 'Dr Salah Alhassan', 613233333, 'error', 9, NULL, 10, 3, '2022-12-31', '2022-12-31 09:50:17', '2022-12-31 09:50:17'),
(40, 39, 1, 23, 'Dr Baazim Jowhara', 613233333, 'error', 8, NULL, 10, 3, '2022-12-31', '2022-12-31 09:50:32', '2022-12-31 09:50:32'),
(41, 40, 1, 23, 'Dr Eyad Mohamuud Ali', 613233333, 'error', 13, NULL, 10, 3, '2022-12-31', '2022-12-31 09:50:51', '2022-12-31 09:50:51'),
(42, 41, 1, 23, 'Dr Mutawakil Ibrahim Daha', 613233333, 'error', 11, NULL, 10, 3, '2022-12-31', '2022-12-31 09:51:11', '2022-12-31 09:51:11'),
(43, 42, 1, 28, 'Dr Hodman mosesultan', 613662525, 'error', 11, NULL, 10, 3, '2022-12-31', '2022-12-31 09:52:29', '2022-12-31 09:52:29'),
(44, 43, 1, 151, 'Dr. Ahmed Baashi', 3939, 'error', 7, NULL, 10, 3, '2022-12-31', '2022-12-31 10:15:20', '2022-12-31 10:15:20'),
(45, 44, 1, 151, 'Dr. Mohamed abdi latiif', 3939, 'error', 5, NULL, 10, 3, '2022-12-31', '2022-12-31 10:15:46', '2022-12-31 10:15:46'),
(46, 45, 1, 29, 'Dr.Cabdulaahi Gaab', 615507911, 'error', 12, NULL, 10, 3, '2022-12-31', '2022-12-31 10:17:13', '2023-01-01 09:21:11'),
(47, 46, 1, 176, 'Dr.khadar', 634662044, 'error', 11, NULL, 10, 3, '2022-12-31', '2022-12-31 10:18:43', '2022-12-31 10:18:43'),
(48, 47, 1, 176, 'Dr.sayed el Makawi', 634662044, 'error', 13, NULL, 10, 3, '2022-12-31', '2022-12-31 10:19:04', '2022-12-31 10:19:04'),
(49, 48, 1, 176, 'Dr.sekarias arefaine', 634662044, 'error', 6, NULL, 10, 3, '2022-12-31', '2022-12-31 10:19:19', '2022-12-31 10:19:19'),
(50, 49, 1, 176, 'Dr.jikisa', 634662044, 'error', 7, NULL, 10, 3, '2022-12-31', '2022-12-31 10:19:53', '2022-12-31 10:19:53'),
(51, 50, 1, 176, 'Dr.hagos gebrekriston', 634662044, 'error', 7, NULL, 10, 3, '2022-12-31', '2022-12-31 10:20:10', '2022-12-31 10:20:10'),
(52, 51, 1, 40, 'Dr Abdulqadir Isse Dirie', 619977712, 'error', 7, NULL, 10, 3, '2022-12-31', '2022-12-31 10:25:31', '2022-12-31 10:25:31'),
(53, 52, 1, 21, 'Dr mahamed maan', 617633663, 'error', 9, NULL, 10, 3, '2022-12-31', '2022-12-31 10:26:29', '2022-12-31 10:26:29'),
(54, 53, 1, 22, 'Dr Rehab Abdulhalim Abdalla', 619992070, 'error', 15, NULL, 10, 3, '2022-12-31', '2022-12-31 10:28:43', '2022-12-31 10:28:43'),
(55, 54, 1, 22, 'Dr Saleh Ali Khatiib', 619992070, 'error', 16, NULL, 10, 3, '2022-12-31', '2022-12-31 10:29:44', '2022-12-31 10:29:44'),
(56, 55, 1, 22, 'Dr Talal Ali Ahmed', 619992070, 'error', 11, NULL, 10, 3, '2022-12-31', '2022-12-31 10:30:00', '2022-12-31 10:30:00'),
(57, 56, 1, 22, 'Dr Mohammed Abdulkarim Nour', 619992070, 'error', 7, NULL, 10, 3, '2022-12-31', '2022-12-31 10:30:13', '2022-12-31 10:30:13'),
(58, 57, 1, 22, 'Dr Muhammed Abdulqadir hassan (kadle)', 619992070, 'error', 18, NULL, 10, 3, '2022-12-31', '2022-12-31 10:31:00', '2022-12-31 10:31:00'),
(59, 58, 1, 22, 'Dr Wael Ali Jafoul', 619992070, 'error', 5, NULL, 10, 3, '2022-12-31', '2022-12-31 10:31:18', '2022-12-31 10:31:18'),
(62, 59, 1, 160, 'Dr Daniel Mahamoud fandy', 1, 'error', 14, NULL, 10, 3, '2022-12-31', '2022-12-31 10:44:16', '2022-12-31 10:44:16'),
(63, 60, 1, 160, 'Dr Mohamed Hasza Ahmed', 1, 'error', 8, NULL, 10, 3, '2022-12-31', '2022-12-31 10:44:28', '2022-12-31 10:44:28'),
(64, 61, 1, 160, 'dr.muhanad  fahad salama', 1, 'error', 5, NULL, 10, 3, '2022-12-31', '2022-12-31 10:44:54', '2022-12-31 10:44:54'),
(65, 62, 1, 160, 'Drs Hodan Awil Jamac', 1, 'error', 20, NULL, 10, 3, '2022-12-31', '2022-12-31 10:45:08', '2022-12-31 10:45:08'),
(66, 63, 1, 61, 'Dr Dasuuqi Ibraahim', 615865627, 'error', 6, NULL, 10, 3, '2022-12-31', '2022-12-31 11:39:13', '2022-12-31 11:39:13'),
(67, 64, 1, 16, 'Dr Fartun Abdulahi Orey', 613949999, 'error', 11, NULL, 10, 3, '2022-12-31', '2022-12-31 11:43:01', '2022-12-31 11:43:01'),
(68, 65, 1, 16, 'Dr Najib Isse Dirie', 613949999, 'error', 14, NULL, 10, 3, '2022-12-31', '2022-12-31 11:43:38', '2022-12-31 11:43:38'),
(69, 66, 1, 16, 'Dr Awale Abdulahi', 613949999, 'error', 7, NULL, 10, 3, '2022-12-31', '2022-12-31 11:44:07', '2022-12-31 11:44:07'),
(70, 67, 1, 16, 'DR FETHI CENGIZ M.D', 613949999, 'error', 12, NULL, 10, 3, '2022-12-31', '2022-12-31 11:49:38', '2022-12-31 11:49:38'),
(71, 68, 1, 16, 'Dr Maryan Abdulahi Sh. NUR', 613949999, 'error', 13, NULL, 10, 3, '2022-12-31', '2022-12-31 11:53:44', '2022-12-31 11:53:44'),
(72, 69, 1, 16, 'Dr Mohammed Saney Cabdi', 613949999, 'error', 13, NULL, 10, 3, '2022-12-31', '2022-12-31 11:59:53', '2022-12-31 11:59:53'),
(73, 70, 1, 58, 'Dr bigmey', 2, 'error', 10, NULL, 10, 3, '2022-12-31', '2022-12-31 12:08:26', '2022-12-31 12:08:26'),
(74, 71, 1, 36, 'Dr Nasteha Hersi Kheire', 617861155, 'error', 11, NULL, 10, 3, '2022-12-31', '2022-12-31 12:15:39', '2022-12-31 12:15:39'),
(75, 72, 1, 36, 'Dr Abdiwahab Dahir Alasoow', 617861155, 'error', 7, NULL, 10, 3, '2022-12-31', '2022-12-31 12:15:52', '2022-12-31 12:15:52'),
(76, 73, 1, 36, 'Drs Keif Hersi Kheire', 617861155, 'error', 15, NULL, 10, 3, '2022-12-31', '2022-12-31 12:16:14', '2022-12-31 12:16:14'),
(77, 74, 1, 36, 'Dr Mustaf Ahmed', 617861155, 'error', 16, NULL, 10, 3, '2022-12-31', '2022-12-31 12:16:30', '2022-12-31 12:16:30'),
(78, 75, 1, 36, 'Dr Nouman', 617861155, 'error', 9, NULL, 10, 3, '2022-12-31', '2022-12-31 12:16:55', '2022-12-31 12:16:55'),
(79, 76, 1, 161, 'Dr.hamsa mohamed jama', 4, 'error', 20, NULL, 10, 3, '2022-12-31', '2022-12-31 12:17:33', '2022-12-31 12:17:33'),
(80, 77, 1, 25, 'Dr Abdihamid', 4, 'error', 6, NULL, 10, 3, '2022-12-31', '2022-12-31 12:18:00', '2022-12-31 12:18:00'),
(81, 78, 1, 179, 'Dr.clcasis maxamed yusuf', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230308014009.jpg', 16, NULL, 0, 5, '2023-03-08', '2023-03-08 07:40:09', '2023-03-08 07:40:09'),
(82, 79, 1, 180, 'Dr.cabdle muuse cumar', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230308015947.jpg', 17, NULL, 0, 5, '2023-03-08', '2023-03-08 07:59:47', '2023-03-08 07:59:47'),
(83, 80, 1, 181, 'Dr.mukhtar maxamud cali', 0, 'error', 6, 'Sabti - Khamiis, Saacdaha: 08AM - 12PM, 04PM - 05PM', 0, 5, '2023-03-11', '2023-03-11 14:37:15', '2023-08-10 11:21:23'),
(84, 81, 1, 182, 'Dr.cabdilahi wacays', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230311085547.jpg', 17, NULL, 0, 5, '2023-03-11', '2023-03-11 14:55:47', '2023-03-11 14:55:47'),
(85, 82, 1, 182, 'Dr.ikran faysal', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230311110532.jpg', 11, NULL, 51000, 5, '2023-03-11', '2023-03-11 17:05:32', '2023-03-11 17:05:32'),
(86, 83, 1, 183, 'Dr.maxamed cali', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230312052250.jpg', 11, NULL, 30000, 5, '2023-03-12', '2023-03-12 10:22:50', '2023-03-12 10:22:50'),
(87, 84, 1, 183, 'Dr.axmed maxamed cali', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230312052613.jpg', 6, NULL, 30000, 5, '2023-03-12', '2023-03-12 10:26:13', '2023-03-12 10:26:13'),
(88, 85, 1, 184, 'Dr.maxamed yusuf', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230312053554.jpg', 6, NULL, 25000, 5, '2023-03-12', '2023-03-12 10:35:54', '2023-03-12 10:35:54'),
(89, 86, 1, 185, 'Dr.fuaad maxamed', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230312090130.jpg', 6, NULL, 30000, 5, '2023-03-12', '2023-03-12 14:01:30', '2023-03-12 14:01:30'),
(90, 87, 1, 185, 'Dr.mohamed cawil', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230312090350.jpg', 6, NULL, 30000, 5, '2023-03-12', '2023-03-12 14:03:50', '2023-03-12 14:03:50'),
(91, 88, 1, 186, 'Dr.clcasis  walhad', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230313041520.jpg', 13, NULL, 127000, 5, '2023-03-13', '2023-03-13 09:15:20', '2023-03-13 09:15:20'),
(92, 89, 1, 186, 'Dr.axmed adan xirsi', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230313041849.jpg', 18, NULL, 86000, 5, '2023-03-13', '2023-03-13 09:18:49', '2023-03-13 09:18:49'),
(93, 90, 1, 187, 'Dr.mohamed abdrixman kawir', 4311790, 'uploads/bulshokaabehealthservices_doctorsp_20230317122643.jpg', 6, NULL, 25000, 5, '2023-03-17', '2023-03-17 17:26:43', '2023-03-17 17:26:43'),
(94, 91, 1, 187, 'Dr.mohamed abdiraxman kawir', 634311790, 'uploads/bulshokaabehealthservices_doctorsp_20230317131901.jpg', 11, NULL, 25000, 5, '2023-03-17', '2023-03-17 18:19:01', '2023-03-17 18:19:01'),
(95, 92, 1, 188, 'Dr.xussen axmed jamac', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230320025053.jpg', 11, NULL, 42000, 5, '2023-03-20', '2023-03-20 07:50:53', '2023-03-20 07:50:53'),
(96, 93, 1, 188, 'Dr.saynab maxamed cali', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230320025252.jpg', 15, NULL, 42000, 5, '2023-03-20', '2023-03-20 07:52:52', '2023-03-20 07:52:52'),
(97, 94, 1, 188, 'Dr.fosiya yusuf nuur', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230320025844.jpg', 15, NULL, 42000, 5, '2023-03-20', '2023-03-20 07:58:44', '2023-03-20 07:58:44'),
(98, 95, 1, 188, 'Dr.cabdixamid maxamed cali', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230320030104.jpg', 14, NULL, 42000, 5, '2023-03-20', '2023-03-20 08:01:04', '2023-03-20 08:01:04'),
(99, 96, 1, 189, 'Dr.mohamed ismacil', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230320040839.jpg', 18, NULL, 67000, 5, '2023-03-20', '2023-03-20 09:08:39', '2023-03-20 09:08:39'),
(100, 97, 1, 189, 'Dr.habib mansoor', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230320041132.jpg', 13, NULL, 67000, 5, '2023-03-20', '2023-03-20 09:11:32', '2023-03-20 09:11:32'),
(101, 98, 1, 190, 'Dr.mohamed abdiladif', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230324091845.jpg', 13, NULL, 15000, 5, '2023-03-24', '2023-03-24 14:18:45', '2023-03-24 14:18:45'),
(102, 99, 1, 190, 'Dr.cabdilahi cisman jamac', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230324092122.jpg', 16, NULL, 15000, 5, '2023-03-24', '2023-03-24 14:21:22', '2023-03-24 14:21:22'),
(104, 100, 1, 191, 'Dr.xamsa mohamed jamac', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230402024443.jpg', 20, NULL, 86000, 5, '2023-04-02', '2023-04-02 07:44:43', '2023-04-02 07:44:43'),
(105, 101, 1, 192, 'Dr.mohamed xamsa axmed', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230402045955.jpg', 14, NULL, 103000, 5, '2023-04-02', '2023-04-02 09:59:55', '2023-04-02 09:59:55'),
(106, 102, 1, 192, 'Dr.hodan cawil jamac', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230402050239.jpg', 11, NULL, 103000, 5, '2023-04-02', '2023-04-02 10:02:39', '2023-04-02 10:02:39'),
(107, 103, 1, 192, 'dr.imad mohamed', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230402050919.jpg', 8, NULL, 103000, 5, '2023-04-02', '2023-04-02 10:09:19', '2023-04-02 10:09:19'),
(108, 104, 1, 192, 'Dr.mohamed fahad salama', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230402052148.jpg', 5, NULL, 103000, 5, '2023-04-02', '2023-04-02 10:21:48', '2023-04-02 10:21:48'),
(109, 105, 1, 192, 'Dr.daniel mahamoud fandy', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230402052651.jpg', 14, NULL, 103000, 5, '2023-04-02', '2023-04-02 10:26:51', '2023-04-02 10:26:51'),
(110, 106, 1, 193, 'Dr.hibo ibrahin', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230402055048.jpg', 11, NULL, 86000, 5, '2023-04-02', '2023-04-02 10:50:48', '2023-04-02 10:50:48'),
(111, 107, 1, 193, 'Dr.cabdirxman mohamed abdilahi', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230402055318.jpg', 7, NULL, 86000, 5, '2023-04-02', '2023-04-02 10:53:18', '2023-04-02 10:53:18'),
(112, 108, 1, 193, 'Dr.shmasudin mustafa', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230402055448.jpg', 14, NULL, 86000, 5, '2023-04-02', '2023-04-02 10:54:48', '2023-04-02 10:54:48'),
(115, 109, 1, 194, 'Dr.sayed el make', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230403105315.jpg', 13, NULL, 86000, 5, '2023-04-03', '2023-04-03 15:53:15', '2023-04-03 15:53:15'),
(116, 110, 1, 194, 'Dr.khaadar axmed', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230403105926.jpg', 11, NULL, 60000, 5, '2023-04-03', '2023-04-03 15:59:26', '2023-04-03 15:59:26'),
(117, 111, 1, 194, 'Dr.jikis', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230411091340.jpg', 23, NULL, 86000, 5, '2023-04-11', '2023-04-11 14:13:40', '2023-04-11 14:13:40'),
(118, 112, 1, 194, 'Dr.hagos gebrekristos', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230411091941.jpg', 22, NULL, 130000, 5, '2023-04-11', '2023-04-11 14:19:41', '2023-04-11 14:19:41'),
(119, 113, 1, 194, 'Dr.sakarias Arefain', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230411092401.jpg', 18, NULL, 86000, 5, '2023-04-11', '2023-04-11 14:24:01', '2023-04-11 14:24:01'),
(120, 114, 1, 0, 'Dr.rsan hussen mohamed', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230415041029.jpg', 15, NULL, 45000, 5, '2023-04-15', '2023-04-15 09:10:29', '2023-04-15 09:10:29'),
(123, 116, 1, 195, 'Dr.abdulqadir shehibu', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230424094139.jpg', 21, NULL, 45000, 5, '2023-04-24', '2023-04-24 14:41:39', '2023-04-24 14:41:39'),
(124, 117, 1, 195, 'Dr.cabdicasis xassan ismacil', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230424101330.jpg', 6, NULL, 45000, 5, '2023-04-24', '2023-04-24 15:13:30', '2023-04-24 15:13:30'),
(127, 120, 1, 195, 'Dr.mohamed khir dyab', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230424111935.jpg', 7, NULL, 45000, 5, '2023-04-24', '2023-04-24 16:19:35', '2023-04-24 16:19:35'),
(128, 121, 1, 195, 'Dr.tessem baraki welderu teal', 0, 'uploads/bulshokaabehealthservices_doctorsp_20230424112302.jpg', 24, NULL, 45000, 5, '2023-04-24', '2023-04-24 16:23:02', '2023-04-24 16:23:02');

-- --------------------------------------------------------

--
-- Table structure for table `evc_app_receipt`
--

CREATE TABLE `evc_app_receipt` (
  `id` int(11) NOT NULL,
  `auto_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `amount` double NOT NULL,
  `patient_id` int(11) NOT NULL,
  `hospital_id` int(11) NOT NULL,
  `doctor_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `expense`
--

CREATE TABLE `expense` (
  `id` int(11) NOT NULL,
  `auto_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `expense_id` int(11) NOT NULL,
  `amount` double NOT NULL,
  `description` varchar(100) NOT NULL,
  `type` varchar(100) NOT NULL,
  `user_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `expense`
--

INSERT INTO `expense` (`id`, `auto_id`, `company_id`, `expense_id`, `amount`, `description`, `type`, `user_id`, `date`, `action_date`, `modified date`) VALUES
(5, 2, 1, 1, 15, 'Mysms Hormuud 1000 API SMS', 'e', 2, '2023-01-01', '2022-12-30 09:15:02', '2022-12-30 09:15:47'),
(6, 3, 1, 1, 35, 'WA messages API', 'e', 2, '2023-01-27', '2023-01-27 06:14:47', '2023-01-27 06:14:47');

-- --------------------------------------------------------

--
-- Table structure for table `faq`
--

CREATE TABLE `faq` (
  `id` int(11) NOT NULL,
  `auto_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `question` text NOT NULL,
  `answer` longtext NOT NULL,
  `user_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `faq`
--

INSERT INTO `faq` (`id`, `auto_id`, `company_id`, `question`, `answer`, `user_id`, `date`, `action_date`, `modified_date`) VALUES
(2, 1, 1, 'Waa maxay shirkadda  Bulsho Tech?', '<p><img alt=\"Bulsho Tech Logo\" src=\"https://apps.bulshotech.com/uploads/bulshotechapps_ktceditsp_20221222034928.png\" style=\"height:200px; width:200px\" /></p>\r\n\r\n<p><strong><span style=\"font-size:18px\"><u>Bulsho Tech&nbsp;</u></span></strong><span style=\"font-size:14px\">waa shirkad gaar loo leeyahay kana shaqeysa hormarinta bulshada dhanka tiknoolojiyadda, shirkaddan waxaa la aasaasay 28/08/2020 xarunteeda ugu weyn waxay ku taalaa Mogadishu halka xarunteeda 2aad ay ku taalo Hargeusa Somaliland.Shirkadda Bulsho Tech waxay ka diiwaangashantahay 2da Caasimad&nbsp;ee Mogadishu iyo Hargeysa.</span></p>\r\n\r\n<p><span style=\"font-size:16px\"><u><strong>Adeegyada shirkadda Bulsho Tech&nbsp;</strong></u></span></p>\r\n\r\n<ul>\r\n	<li>Dalbashada iyo Jarista Ticket-yada Isbitaalada</li>\r\n	<li>Talo bixinnada&nbsp;caafimaad&nbsp;</li>\r\n	<li>La kulanka dhaqaatiirta hab online ah</li>\r\n	<li>Ticket-yada Duulimaadyada Gudaha iyo Dibadda</li>\r\n	<li>Kala iibinta alaabaha Celis-ka ah</li>\r\n</ul>\r\n\r\n<p>&nbsp;</p>\r\n\r\n<p><span style=\"font-size:16px\"><strong><u>Meelaha aad kala soo xiriiri kart adeegyada Shirkadda</u></strong></span></p>\r\n\r\n<ul>\r\n	<li><span style=\"font-size:14px\">Facebook Page&nbsp;https://www.facebook.com/bulshotech</span></li>\r\n	<li><span style=\"font-size:14px\">Website-ka shirkadda https://www.bulshotech.com</span></li>\r\n	<li><span style=\"font-size:14px\">Whatsapp-yada iyo Wicitaan toos ah 252614945025 / 252614945026/ 252614945027&nbsp;</span></li>\r\n	<li>Xarumaha Shirkadda Bakaaro Mogadishu Somalia iyo Hargeysa</li>\r\n</ul>', 2, '2023-01-01', '2023-01-01 08:52:39', '2023-01-01 08:52:39'),
(3, 2, 1, 'Muxuu qabtaa App-ka Bulsho Tech?', '<p><img alt=\"App-ka Bulsho Tech\" src=\"https://apps.bulshotech.com/uploads/bulshotech-app.PNG\" style=\"height:233px; width:300px\" /></p>\r\n\r\n<p><strong><span style=\"font-size:14px\">App-ka Bulsho Tech&nbsp;</span></strong><span style=\"font-size:14px\">waa Application loo naqshadeeyay Dalbashada iyo Fududeynta Jarista Ticket-yada Isbitaalada, App-ka Bulsho Tech oo shaqeynayay tan iyo August/2020 waxaa lasoo degay Macaamiil aad u badan.</span></p>\r\n\r\n<p><strong><span style=\"font-size:14px\">Waxyaabaha aad App-ka Bulsho Tech&nbsp;</span></strong><span style=\"font-size:14px\">ka heli karto waxaa kamid ah</span></p>\r\n\r\n<ul>\r\n	<li><span style=\"font-size:14px\">Liiska Dhammaan Isbitaalada Mogadishu iyo gobolada Dalka</span></li>\r\n	<li>Liiska dhammaan dhaqaatiirta iyo cudurada ay daweeyaan ee Isbitaalada ka shaqeeya</li>\r\n	<li>Dalbashada hab online ah inaad ku dalbato Ticket-ka Isbitaalka iyo dhaqtarka aad dooneyso</li>\r\n	<li>In si automatic ah aad lacagta Ticket-ka isbitaalka iyo khidmadda Shirkadda Bulsho Tech ku bixiso si fudud</li>\r\n	<li>In Markiiba kuusoo dhacdo fariin qoraaleed kuu cadeyneysa Isbitaal-ka iyo Dhaqtar-ka laguu dalbay Ticket-kiisa</li>\r\n	<li>Fariin qoraaleed-ka waxaa la socdo Link kuu cadeynaya hal-ka uu marayo dalbkaaga Ticket-ka</li>\r\n	<li>Markii aan Ticket-ka Isbitaal-ka kaaga jarno waxaa markale kuusoo dhacayo fariin aad ku ogaaneyso Ticket-Number-ka aan kuu jarnay iyo Sawirka Ticket-ka Isbitaal-ka aad ku tegi lahayd.</li>\r\n</ul>', 2, '2023-01-01', '2023-01-01 09:12:12', '2023-01-01 09:12:12'),
(4, 3, 1, 'Sidee App-ka Bulsho Tech looga Jartaa Ticket-ka Isbitaalada?', '<p><strong>Si add Ticket Isbitaal uga Jarato App-ka Bulsh Tech Raac tilmaamahan hoose</strong></p>\r\n\r\n<p><img alt=\"Dooro Home-ka App-ka Bulsho Tech\" src=\"https://apps.bulshotech.com/uploads/ticket-order-steps/App-slct-home.PNG\" style=\"height:550px; width:300px\" /></p>\r\n\r\n<ol>\r\n	<li>Marka hore soo kici qeybta&nbsp;<strong>Home</strong>-ka ee App-ka Bulsho Tech&nbsp;</li>\r\n	<li><img alt=\"Raadi Isbitaalka aad rabto\" src=\"https://apps.bulshotech.com/uploads/ticket-order-steps/App-search-hospital.PNG\" style=\"height:550px; width:366px\" />Qeybta kore ee Search-ga ku qor Isbitaalka aad dooneyso inaad Ticket ka goosato .</li>\r\n	<li><img alt=\"Ka dooro isbitaalada kuusoo baxay midka aad ka rabto\" src=\"https://apps.bulshotech.com/uploads/ticket-order-steps//App-select-hospital.PNG\" style=\"height:550px; width:310px\" />Waxaan tusaale u qaadaneynaa Isbitaalka Digfeer in aan ka goosano tikcet-ka Dhaqtar-ka caruurta - dooro Isbitaalka aad dooneyso inaad Ticket-ka ka goosato</li>\r\n	<li><img alt=\"Dooro dhaqtarka aad dooneyso inaad Ticket-ka ka jarato\" src=\"https://apps.bulshotech.com/uploads/ticket-order-steps/App-select-doctor.PNG\" style=\"height:550px; width:319px\" />Waxaa kuu soo baxaya Dhaqaatiir-ta ka shaqeysa Isbitaalka aad dooratay, qeybta Raadinta ku qor Dhaqtarka ama qeybta aad ka rabto Isbitaalka waxaan dooranay qeybta Caruurta.</li>\r\n	<li><img alt=\"\" src=\"https://apps.bulshotech.com/uploads/ticket-order-steps/App-patient-form-1.PNG\" style=\"height:450px; width:319px\" /><img alt=\"ku Buuxi foomka xogta bukaanka\" src=\"https://apps.bulshotech.com/uploads/ticket-order-steps/App-patient-form-2.PNG\" style=\"height:450px; width:330px\" />&nbsp;Marka aad doorato qeybta aad rabto waxaa kuu soo baxaya Foom-ka lagu qorayo xogta Bukaanka iyo lacagaha Ticket-ka iyo Khidmadda Shirkadda Bulsho Tech , foomka ku buuxi xogta bukaanka sida ku cad 2da screenshot ee sare, kadibna guji&nbsp;<strong>Dalbo oo bixi Lacagta</strong></li>\r\n	<li><img alt=\"Fiiri oo hubi telka aad lacagta ka bixineyso\" src=\"https://apps.bulshotech.com/uploads/ticket-order-steps/App-paymentform-1.PNG\" style=\"height:500px; width:288px\" /><img alt=\"Aqbal lacag bixinta Bulsho Tech\" src=\"https://apps.bulshotech.com/uploads/ticket-order-steps/App-check-payment-0.jpeg\" style=\"height:550px; width:248px\" />Markiiba waxaa moobile ka aad lacagta ka bixineyso kaaga soo baxayo Aqbalaada lacagta Ticket-ka iyo Khidmadda Bulsho Tech, si dhaqso ah aan waqti badan qaadaneyn ku aqbal kuna bixi.</li>\r\n	<li><img alt=\"Fariinta Ticket-ka ee Bulsho Tech\" src=\"https://apps.bulshotech.com/uploads/ticket-order-steps/App-bulsho-tikcet-sms.jpeg\" style=\"height:550px; width:248px\" /><img alt=\"Waad ku guuleystay lacag bixinta\" src=\"https://apps.bulshotech.com/uploads/ticket-order-steps/App-paymentform-2.PNG\" style=\"height:300px; width:337px\" />Markii aad aqbasho Pin-kaagana aad geliso lacag bixintana lagu guuleysto, Wa waxaa Taleefan-ka Bukaanka&nbsp; kuugusoo dhacaysa fariinta Ticket-ka aad jaraty io Linkiga aad ticket-kaaga kala socon karto&nbsp;, sidoo kalana Foom-ka dalbashada Ticket-ka waxaa kaaga soo muuqanaya fariin kuu cadeynaysa in lagu guuleystay dalbashada Ticket-kaaga</li>\r\n	<li><img alt=\"Ticket-ka Isbitaalka\" src=\"https://apps.bulshotech.com/uploads/ticket-order-steps/App-bulsho-ticket.jpeg\" style=\"height:550px; width:248px\" />Fariinta mobile-kaaga kusoo dhacday waxaa la socoto Link hadii aad gujiso kuusoo baxaya Xogta Bukaanka iyo Ticket-ka laguu jaray, Hadii sawirka ticket-ka iyo Ticket-Number ka isbitaalka kuusoo muuqan waxaa socoto dalbidda Ticket-kaaga.</li>\r\n</ol>\r\n\r\n<p><em><strong>Waad-ku mahadsantahay akhrintaada qodobada Dalbashada Ticket-ka Isbitaalada ee Bulsho tech</strong></em></p>\r\n\r\n<p><strong>Hadii qodobaas kore aad si taxadr leh u raacdo waxaa si fudud ku dalban kartaa Ticket-ka isbitaalada adigoo joogo gurigaa iyo goobtaada shaqro, sdioo kale waxaan soo raacin doonnaa hal-ka Muuqaal hab-ka Ticket-ka looga jaran karo</strong></p>', 2, '2023-01-01', '2023-01-01 17:47:10', '2023-01-01 17:47:10');

-- --------------------------------------------------------

--
-- Table structure for table `general`
--

CREATE TABLE `general` (
  `id` int(11) NOT NULL,
  `auto_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `name` varchar(250) NOT NULL,
  `name_ar` varchar(100) DEFAULT NULL,
  `description` text NOT NULL,
  `type` varchar(50) NOT NULL,
  `user_id` int(11) NOT NULL,
  `status` int(11) NOT NULL DEFAULT '0',
  `is_default` int(11) DEFAULT NULL,
  `default_val` varchar(50) DEFAULT NULL,
  `order_by` int(11) NOT NULL DEFAULT '0',
  `date` date NOT NULL,
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `general`
--

INSERT INTO `general` (`id`, `auto_id`, `company_id`, `name`, `name_ar`, `description`, `type`, `user_id`, `status`, `is_default`, `default_val`, `order_by`, `date`, `action_date`, `modified_date`) VALUES
(1, 1, 1, 'App Ads', NULL, '', 'expense', 2, 0, NULL, NULL, 0, '2022-12-30', '2022-12-30 09:13:02', '2022-12-30 09:13:02'),
(2, 2, 1, 'Sallary', NULL, '', 'expense', 2, 0, NULL, NULL, 0, '2022-12-30', '2022-12-30 09:13:12', '2022-12-30 09:13:12');

-- --------------------------------------------------------

--
-- Table structure for table `hospital`
--

CREATE TABLE `hospital` (
  `id` int(11) NOT NULL,
  `auto_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL COMMENT 'name',
  `tell` int(11) NOT NULL COMMENT 'tell',
  `cashier_tell` int(11) NOT NULL COMMENT 'cashier_tell',
  `address` varchar(100) NOT NULL COMMENT 'address',
  `city` varchar(100) NOT NULL COMMENT 'city',
  `region` varchar(100) NOT NULL COMMENT 'region',
  `ticket_fee` double NOT NULL COMMENT 'ticket_fee',
  `commission_fee` double NOT NULL COMMENT 'commision_fee',
  `service_fee` double NOT NULL COMMENT 'service_fee',
  `currency` char(10) NOT NULL DEFAULT '$' COMMENT 'currency',
  `free_days` varchar(100) NOT NULL DEFAULT '' COMMENT 'free_days~checkbox~day_',
  `logo` varchar(100) NOT NULL COMMENT 'logo',
  `manager` varchar(250) NOT NULL DEFAULT '' COMMENT 'manager',
  `contract_file` varchar(250) NOT NULL DEFAULT '' COMMENT 'contract_file~file',
  `user_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `hospital`
--

INSERT INTO `hospital` (`id`, `auto_id`, `company_id`, `name`, `tell`, `cashier_tell`, `address`, `city`, `region`, `ticket_fee`, `commission_fee`, `service_fee`, `currency`, `free_days`, `logo`, `manager`, `contract_file`, `user_id`, `date`, `action_date`, `modified_date`) VALUES
(181, 181, 1, 'Shiikh isixaaq pharmacy', 634089021, 634089021, 'Wuxuu uu dhowyahay shaybe hotel  wana jigjiga', 'Hargeysa', 'Somaliland', 17000, 0, 9000, 'Shilin', '', '0', '', '', 5, '2023-03-11', '2023-03-11 14:34:40', '2023-04-22 07:24:31'),
(182, 182, 1, 'Procare poly clinic center pharmacy', 637589731, 637589677, 'Wuxuu uu dhowyahay masjid jamac', 'Hargeysa', 'Somaliland', 70000, 0, 9000, 'Shilin', '', '0', '', '', 5, '2023-03-11', '2023-03-11 14:52:51', '2023-04-22 07:25:26'),
(183, 183, 1, 'Gurmad medical center pharmacy', 634240373, 633061263, 'Waa agagarka birishka wayn shimbirta', 'Hargeysa', 'Somaliland', 30000, 0, 9000, 'Shilin', '', '0', '', '', 5, '2023-03-12', '2023-03-12 10:11:04', '2023-04-22 07:26:08'),
(184, 184, 1, 'Madar medical center pharmacy', 634437507, 633284813, 'Waa agagarka birishka xidigta', 'Hargeysa', 'Somaliland', 25000, 0, 9000, 'Shilin', '', '0', '', '', 5, '2023-03-12', '2023-03-12 10:33:32', '2023-04-22 07:26:46'),
(185, 185, 1, 'European poly clinic pharmacy', 634333336, 634333336, 'Wuxuu uu dhowyahay hotel mansor', 'Hargeysa', 'Somaliland', 30000, 0, 9000, 'Shilin', '', '0', '', '', 5, '2023-03-12', '2023-03-12 13:58:59', '2023-04-22 07:27:37'),
(186, 186, 1, 'Baxnaano speciality clinic', 634535353, 634518644, 'Wuxuu uu dhowyahay garaha', 'Hargeysa', 'Somaliland', 127000, 0, 9000, 'Shilin', '', '0', '', '', 5, '2023-03-13', '2023-03-13 09:10:29', '2023-04-22 07:28:20'),
(187, 187, 1, 'Kawir medical center pharmacy', 634311790, 634311790, 'Waa actobar garahan suuq dhoweye', 'Burco', 'Somaliland', 25000, 0, 9000, 'Shilin', '', '0', '', '', 5, '2023-03-17', '2023-03-17 17:22:34', '2023-04-22 07:28:53'),
(188, 188, 1, 'Hooyo Dhawar hospital', 634406050, 634872588, '150 wadada sheedaha ibrahim koodbur', 'Hargeysa', 'Somaliland', 42000, 0, 9000, 'Shilin', '', '0', '', '', 5, '2023-03-20', '2023-03-20 07:47:18', '2023-04-22 07:29:50'),
(189, 189, 1, 'Mahdi hospital', 637580361, 634171989, 'Immigration lanta socdalka ayu uu dhowyahay', 'Hargeysa', 'Somaliland', 67000, 0, 9000, 'Shilin', '', '0', '', '', 5, '2023-03-20', '2023-03-20 09:06:01', '2023-04-22 07:30:48'),
(190, 190, 1, 'Shifo pharmacy', 634414890, 634414890, 'Wuxuu uu dhowyahay brig wayn hadhwanag hotel', 'Hargeysa', 'Somaliland', 60000, 0, 9000, 'Shilin', '', '0', '', '', 5, '2023-03-24', '2023-03-24 14:16:22', '2023-04-22 07:31:22'),
(191, 191, 1, 'Manhal mental hospital', 634438916, 634438916, 'Wuxuu yala xafada turta ee galbedka burco', 'Burco', 'Somaliland', 86000, 0, 9000, 'Shilin', '', '0', '', '', 5, '2023-04-01', '2023-04-01 15:59:51', '2023-04-22 07:31:59'),
(192, 192, 1, 'Hargeysa neurology hospital', 634128844, 634128844, 'Wuxuu ku yala pepsig jamacada hargeysa agteeda', 'Hargeysa', 'Somaliland', 103000, 0, 9000, 'Shilin', '', '0', '', '', 5, '2023-04-02', '2023-04-02 09:55:23', '2023-04-22 07:32:36'),
(193, 193, 1, 'Amal grand hospital', 634605759, 654006593, 'Waa ex xamda hotel ina afdiinle wana new hargeysa', 'Hargeysa', 'Somaliland', 86000, 0, 9000, 'Shilin', '', '0', '', '', 5, '2023-04-02', '2023-04-02 10:48:46', '2023-04-22 07:33:07'),
(194, 194, 1, 'Needle hospital and pathology', 634662044, 636666645, 'Wuxuu ka so horjeeda masajidka shiikh bashir', 'Hargeysa', 'Somaliland', 60000, 0, 9000, 'Shilin', '', '0', '', '', 5, '2023-04-02', '2023-04-02 16:14:46', '2023-04-15 10:44:10'),
(197, 195, 1, 'Horyal hospital', 634820301, 633936905, 'Wuxuu ku yala Xafada hodan qaylo 15 may', 'Burco', 'Somaliland', 45000, 0, 9000, '$', '', '0', '', '', 5, '2023-04-24', '2023-04-24 16:09:02', '2023-04-24 16:09:02'),
(200, 196, 1, 'Janaale clinic pharmacy', 634603362, 634603362, 'Waa ka soo horjedka basaska calamadaha', 'Hargeysa', 'Somaliland', 0, 0, 9000, '$', '', '0', '', '', 5, '2023-04-28', '2023-04-28 17:42:45', '2023-04-28 17:42:45');

--
-- Triggers `hospital`
--
DELIMITER $$
CREATE TRIGGER `auto_grant_hospital` AFTER INSERT ON `hospital` FOR EACH ROW INSERT ignore INTO `ktc_user_permission`( `link_id`, `user_id`, `granted_user_id`, `action`,company_id) VALUES (NEW.auto_id,NEW.user_id,NEW.user_id,'hospital',NEW.company_id)
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `ktc_category`
--

CREATE TABLE `ktc_category` (
  `id` int(11) NOT NULL,
  `auto_id` int(11) NOT NULL DEFAULT '0',
  `name` varchar(100) NOT NULL,
  `icon` varchar(50) NOT NULL,
  `description` text NOT NULL,
  `order_by` int(11) NOT NULL DEFAULT '0',
  `company_id` int(11) NOT NULL DEFAULT '17',
  `user_id` int(11) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ktc_category`
--

INSERT INTO `ktc_category` (`id`, `auto_id`, `name`, `icon`, `description`, `order_by`, `company_id`, `user_id`, `date`) VALUES
(1, 1, 'Developer', 'fa fa-user', '', 5, 1, 2, '2018-10-25 07:45:25'),
(125, 2, 'Registration', 'fa fa-pencil-square-o', '', 0, 1, 3, '2022-12-22 17:22:51'),
(126, 3, 'Reports', 'fa fa-list-alt', '', 0, 1, 3, '2022-12-22 17:23:23');

-- --------------------------------------------------------

--
-- Table structure for table `ktc_chart`
--

CREATE TABLE `ktc_chart` (
  `id` int(11) NOT NULL,
  `auto_id` int(11) NOT NULL,
  `chart` varchar(50) NOT NULL,
  `icon` varchar(50) NOT NULL,
  `class_color` varchar(50) NOT NULL,
  `description` varchar(100) NOT NULL,
  `type` varchar(50) NOT NULL DEFAULT 'box',
  `position` int(11) NOT NULL DEFAULT '1',
  `description2` varchar(50) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL DEFAULT '17',
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ktc_chart`
--

INSERT INTO `ktc_chart` (`id`, `auto_id`, `chart`, `icon`, `class_color`, `description`, `type`, `position`, `description2`, `user_id`, `company_id`, `date`) VALUES
(1, 1, 'form', 'fa fa-plus', 'bg-black', 'Form', 'user', 1, 'developer', 0, 1, '2022-07-01 15:37:55'),
(2, 2, 'element', 'fa fa-money', 'bg-blue', 'Form Elements', 'user', 1, 'developer', 0, 1, '2022-07-01 15:37:51'),
(3, 3, 'procedure', 'fa fa-user', 'bg-green', 'Procedures', 'user', 1, 'developer', 0, 1, '2022-07-01 15:37:48'),
(4, 4, 'table', 'fa fa-home', 'bg-yellow', 'Tables', 'user', 1, 'developer', 0, 1, '2022-07-01 15:37:44'),
(5, 5, 'hospital', 'fa fa-home', 'bg-light-green', 'Hospitals', 'user', 0, NULL, 2, 1, '2022-12-29 09:35:47'),
(6, 6, 'doctor', 'fa fa-user-md', 'bg-pink', 'Doctors', 'user', 0, NULL, 2, 1, '2022-12-29 09:37:19'),
(7, 7, 'Department', 'fa fa-home', 'bg-pink', 'Department', 'user', 0, NULL, 3, 1, '2022-12-29 21:35:10'),
(8, 8, 'Patient', 'fa fa-users', 'bg-light-green', 'Patient', 'user', 0, NULL, 3, 1, '2022-12-29 21:36:03'),
(9, 9, 'Ticket', 'fa fa-list-alt', 'bg-light-green', 'Ticket', 'user', 0, NULL, 3, 1, '2022-12-29 21:41:25');

--
-- Triggers `ktc_chart`
--
DELIMITER $$
CREATE TRIGGER `auto_grant_chart` AFTER INSERT ON `ktc_chart` FOR EACH ROW INSERT ignore INTO `ktc_user_permission`( `link_id`, `user_id`, `granted_user_id`, `action`,company_id) VALUES (NEW.auto_id,NEW.user_id,NEW.user_id,'chart',NEW.company_id)
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `ktc_common_param`
--

CREATE TABLE `ktc_common_param` (
  `id` int(11) NOT NULL,
  `parameter` varchar(100) NOT NULL,
  `label` varchar(100) NOT NULL,
  `type` varchar(100) NOT NULL,
  `action` varchar(100) NOT NULL,
  `placeholder` varchar(250) NOT NULL,
  `default_value` varchar(100) NOT NULL,
  `class` varchar(100) NOT NULL,
  `size` varchar(200) NOT NULL,
  `load_action` varchar(100) NOT NULL,
  `user_id` int(11) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ktc_common_param`
--

INSERT INTO `ktc_common_param` (`id`, `parameter`, `label`, `type`, `action`, `placeholder`, `default_value`, `class`, `size`, `load_action`, `user_id`, `date`) VALUES
(3, 'category_p', 'Category', 'dropdown', 'ktc_category|', '', '', 'load', '', 'category_id,ktc_sub_category-', 0, '2022-12-13 15:44:00'),
(4, 'user_p', 'User', 'hidden', '', '', '', '', '', '', 0, '2022-11-26 05:36:53'),
(5, 'sub_category_p', 'Subcategory', 'dropdown', 'ktc_sub_category', '', '', 'load', '', 'sub_category_id,ktc_link-', 0, '2022-07-04 21:19:34'),
(6, 'link_p', 'Link', 'dropdown', 'ktc_link|', '', '', 'load_me', '', 'category_id,ktc_link-', 0, '2022-10-21 08:43:05'),
(7, 'file', 'default_label', 'file', '', '', '', '', '', '', 0, '2019-01-19 21:54:49'),
(8, 'image', 'default_label', 'file', '', '', '', '', '', '', 0, '2019-01-19 21:54:57'),
(9, 'cv', 'default_label', 'file', '', '', '', '', '', '', 0, '2019-01-19 21:55:05'),
(10, 'attach', 'default_label', 'file', '', '', '', '', '', '', 0, '2019-01-19 21:55:15'),
(11, 'param_p', 'Param', 'Element Type', '', '', '', '', '', '', 2, '2021-12-18 10:02:24'),
(12, 'table_p', 'Table', 'dropdown', 'table', '', '', '', '', '', 2, '2022-02-11 17:53:22'),
(13, 'gender', 'default_label', 'radio', 'gender_', '', '', '', '', '', 2, '2019-01-24 09:53:18'),
(14, 'sex', 'default_label', 'radio', 'gender_', '', '', '', '', '', 2, '2019-01-24 09:53:29'),
(15, 'month', 'default_label', 'dropdown', 'month_', '', '', '', '', '', 2, '2019-01-24 09:53:45'),
(16, 'day', 'default_label', 'dropdown', 'day_', '', '', '', '', '', 2, '2019-01-24 09:54:03'),
(17, '_user', 'hidden', '', '', '', '', '', '', '', 2, '2019-02-02 21:43:42'),
(18, '_user_id', 'hidden', '', '', '', '', '', '', '', 2, '2023-08-10 11:15:24'),
(19, 'from_p', 'From', 'date', '', '', '', '', ' ', '', 2, '2021-12-18 12:48:39'),
(20, 'to_p', 'To', 'date', '', '', '', '', ' ', '', 2, '2022-10-02 08:47:08'),
(21, 'tell', 'default_label', '', '', '', '', 'number tell', '', '', 2, '2019-02-15 09:28:37'),
(22, '_co_id', 'hidden_u', '', '', '', '', '', '', '', 2, '2019-03-10 09:33:16'),
(23, '_branch_id', ' Branch', 'dropdown', 'branch', '', '', 'varchar', '', '', 2, '2022-09-22 21:35:20'),
(24, '_invoice_no', 'Invoice No', 'hidden_ele', '', '', '%', 'number', '', '', 2, '2019-11-17 17:16:45'),
(25, '_fee_id', 'Fee ($)', 'dropdown', 'general,status,99', '9', '', 'float', '', '', 2, '2022-12-13 06:52:39'),
(26, '_account_id', 'Select bank', 'dropdown', 'general,type,bank', '', '', '', '', '', 2, '2019-11-17 16:57:12'),
(27, '_customer_id', 'Passenger Name', 'autocomplete', 'customer|', 'Abdihamid Hussein Gedi', '', '', '', '', 2, '2021-07-30 21:36:59'),
(28, '_company_id', 'Company', 'hidden_u', 'all_company', '', '', 'load', '', 'company_id,ktc_category-', 2, '2022-12-23 18:30:39'),
(29, '_title', 'Title', 'varchar', '', '', '', '', '', '', 2, '2022-12-05 20:59:30'),
(30, '_level', 'Choose Office', 'dropdown', 'general,type,office', '', 'Admin', '', '', '', 2, '2022-09-15 14:56:58'),
(31, '_employee_id', 'Employee Name', 'autocomplete', 'employee', '', '', 'req', '', '', 2, '2022-12-10 13:50:03'),
(32, '_year', 'Year', 'dropdown', 'academic_year|', '', '', '', '', '', 2, '2022-10-06 07:03:35'),
(33, '_date', 'Date', 'date', '', '', '', '', '', '', 2, '2022-03-06 14:20:37'),
(35, '_room_id', 'Room Name', 'dropdown', 'room', '', '', '', '', '', 2, '2019-03-19 23:00:47'),
(36, '_blood_group', 'Choose Blood Group', 'dropdown', 'blood_group|', '', '', '', '', '', 2, '2019-03-23 22:12:35'),
(38, '_patient_id', 'Patient', 'autocomplete', 'patient|', '', '', '', '', '', 39, '2022-12-23 19:31:56'),
(52, '_isdefoult', 'Is Default', 'hidden_ele', '', '', '', '', '', '', 102, '2019-04-15 22:31:09'),
(57, '_sub_id', 'Choose Group', 'hidden_ele', '', '', '1', 'varchar', '', '', 2, '2019-12-13 12:47:23'),
(58, '_store_id', 'Select Store', 'hidden_ele', 'store', '', '', '', '', '', 2, '2019-11-17 15:11:03'),
(59, 'co_p', 'Co', 'hidden_u', '', '', '', '', '', '', 177, '2022-10-29 08:36:49'),
(61, '_cost', 'Cost of Sales', 'float', '', '', '', 'float', '', '', 0, '2019-11-06 03:17:18'),
(62, '_category_id', 'Select Menu', 'dropdown', 'ktc_category|', '', '', 'load', '', 'category_id,ktc_sub_category-', 0, '2022-12-13 15:51:21'),
(63, '_name', 'Doctor Name', 'text', '', 'Doctor Name', '', 'text', '3', '', 0, '2023-08-10 11:05:48'),
(64, '_quantity', ' Quantity', 'float', '', '', '0', 'float', '3', '', 0, '2019-11-10 22:32:52'),
(65, 'acc_p', 'Choose bank', 'radio', 'general,type,account', '', '', '', '', '', 0, '2022-12-02 17:59:22'),
(66, '_username', 'User Email', 'email', '', 'abc@example.com', '', 'varchar', '', '', 0, '2021-03-30 18:38:41'),
(67, '_password', 'Password', 'varchar', '', 'at least 8 charachter', '', 'password', '', '', 0, '2021-12-20 12:26:33'),
(68, '_confirm', ' Confirm', 'password', '', 'Re-type Password', '', 'on-keyup', '', '', 0, '2021-03-30 18:39:12'),
(69, '_address', 'Address', 'varchar', '', 'Km4 Hodan', '', 'varchar', '4', '', 0, '2023-01-05 14:35:37'),
(70, '_email', 'Email', 'hidden_ele', '', 'abc@example.com', '', '', '4', '', 0, '2022-12-02 14:29:57'),
(71, '_domain', 'Domain', 'hidden_ele', '', '', '', 'varchar', '4', '', 0, '2022-09-15 09:53:15'),
(72, '_letter_head', ' Letter Head', 'hidden_ele', '', '', '', 'varchar', '4', '', 0, '2019-11-13 07:11:09'),
(73, '_logo', ' Logo', 'file', 'image', '', '', 'varchar', '4', '', 0, '2022-12-22 17:58:09'),
(74, '_tell', 'Doctor Tell', 'number', '', '61xxxxxxx', '', '', '4', '', 0, '2023-08-10 11:05:48'),
(75, '_admin', '_admin', 'Element Type', '', 'Abdihamid Hussein Geddi', '', 'varchar', '', '', 0, '2021-12-18 10:02:24'),
(76, '_co_type', ' Co Type', 'hidden_ele', '', '', 'sub', 'varchar', '', '', 0, '2019-11-14 02:40:40'),
(77, '_type', 'Type', 'hidden_ele', 'other_charge_', '', 'e', '', '', '', 0, '2022-12-30 09:14:34'),
(78, '_is_default', 'Service Amount', 'float', '', '', '', 'float', '', '', 0, '2019-11-17 16:45:41'),
(79, '_open_balance', 'Open Balance ($)', 'float', '', 'Ex. 3000', '', 'float', '', '', 0, '2021-03-23 11:21:52'),
(80, '_limit', 'Bank', 'dropdown', 'general,type,bank', '', '', 'varchar', '', '', 0, '2019-11-17 16:38:24'),
(81, '_description', 'Work Time', 'textarea', '', 'Ex. Sabti, Axad, Isniin, Talaado Saacadaha : 08AM - 12PM', '', 'varchar', '12', '', 0, '2023-08-10 11:10:53'),
(82, '_image', ' Image', 'file', 'images', '', '', '', '9', '', 0, '2022-12-24 09:15:48'),
(83, '_group_id', 'Choose Shift', 'dropdown', 'hr_attendance_group|', '', '', 'varchar', '', '', 0, '2022-04-09 11:37:48'),
(86, '_discount', 'Discount', 'dropdown', 'discount|', '', '', 'float', '', '', 0, '2021-12-19 10:59:53'),
(87, '_action', 'Action', 'hidden_ele', 'action_', '', 'delete', '', '', '', 0, '2022-12-21 08:19:40'),
(88, '_bank_id', 'Bank', 'dropdown', '', '', '', 'varchar', '', '', 0, '2021-12-18 11:08:02'),
(89, 'co2_p', 'Co2', 'hidden_u', '', '', '', 'load', '', 'company_id,ktc_category-', 0, '2022-03-22 15:37:20'),
(90, 'category2_p', 'Category2', 'dropdown', 'ktc_category|', '', '', 'load', '', 'category_id,ktc_sub_category-', 0, '2022-03-22 15:37:35'),
(91, 'sub_category2_p', 'Subcategory2', 'dropdown', 'ktc_sub_category', '', '', '', '', '', 0, '2022-07-04 21:19:42'),
(92, 'link2_p', 'To Link', 'dropdown', 'ktc_link|', '', '', 'load5_me', '', 'category_id,ktc_link-', 0, '2019-11-17 17:46:08'),
(93, '_service', 'Service Amount', 'varchar', '', '', '', 'varchar', '4', '', 0, '2019-11-19 16:40:14'),
(94, '_deposit', 'Deposit Amount', 'float', '', '', '', 'float', '4', '', 0, '2019-11-19 16:40:18'),
(95, '_account', 'Bank Account', 'dropdown', 'general,type,bank', '', '', 'varchar', '4', '', 0, '2019-11-19 16:39:34'),
(96, '_wakiil', 'Magaca Wakiil', 'varchar', '', '', '', 'varchar', '4', '', 0, '2019-11-19 16:40:33'),
(97, '_wakiil_tell', ' Wakiil Tell', 'varchar', '', '', '', 'int', '4', '', 0, '2019-11-19 16:39:55'),
(98, '_aqoonsi_type', ' Aqoonsi Type', 'dropdown', 'aqoonsi_', '', '', 'varchar', '', '', 0, '2019-11-19 16:42:49'),
(99, '_from', 'From', 'date', '', '', '', '', '', '', 0, '2023-08-10 11:09:25'),
(100, '_to', 'To', 'date', '', '', '', '', '', '', 0, '2023-01-12 03:44:10'),
(101, '_amount', 'Amount', 'number', '', '', '', 'float', '', '', 0, '2022-12-23 19:33:40'),
(102, '_customer2_id', 'To Customer', 'autocomplete', 'general,type,customer', '', '', '', '', '', 0, '2019-12-11 17:07:13'),
(103, 'class_color_p', 'Classcolor', 'dropdown', 'chart_bg_', '', '', '', '', '', 0, '2022-01-20 12:04:47'),
(104, 'icon_p', 'Icon', 'autocomplete', 'icon', '', '', '', '', '', 0, '2022-01-20 12:02:28'),
(105, 'chart_p', 'Chart Action', 'Element Type', '', '', '', '', '', '', 0, '2022-01-20 12:04:24'),
(106, '_fee', 'Fee ($)', 'dropdown', 'general,type,fee', '9', '', 'float', '', '', 0, '2022-12-11 07:36:20'),
(107, '_level_id', 'Choose Level', 'dropdown', 'level|', '', '', 'load', '', 'level_id,class-', 0, '2020-08-02 21:53:18'),
(108, '_dob', 'Dob', 'date', '', '', '00-00-0000', 'number', '', '', 0, '2022-12-24 09:03:22'),
(109, '_pob', 'Ob', 'Element Type', '', '', '', 'varchar', '', '', 0, '2021-12-18 10:02:24'),
(110, '_contact_name', 'Guardian Name', 'text', '', '', '', '', '3', '', 0, '2020-08-28 11:15:38'),
(111, '_contact_tell', 'Guardian Telephone', '', '', '', '', 'number tell', '', '', 0, '2020-08-28 11:15:57'),
(112, '_contact_relation', 'Guardian Relation', 'dropdown', 'relation_', '', '', 'varchar', '', '', 0, '2020-08-28 11:16:13'),
(113, '_mother', 'Mother', 'varchar', '', '', '', 'varchar', '', '', 0, '2022-12-23 19:37:42'),
(114, '_description_discount', 'Discount Reasonable', 'text', '', '', '', '', '', '', 0, '2020-08-28 11:19:55'),
(115, '_class_id', 'Class', 'autocomplete', 'class', '', '', 'load', '', 'class_semester', 0, '2022-12-21 08:16:34'),
(116, '_sub_class_id', 'Choose Sub Class', 'dropdown', 'sub_class', '', '', '', '', '', 0, '2020-09-03 08:45:53'),
(117, '_bus_fee', 'Bus Fee', 'Number', '', 'Eg. 8', '', 'float', '', '', 0, '2020-08-28 11:19:31'),
(118, '_gender', 'Gender', 'dropdown', 'gender_', '', '', 'time', '3', '', 0, '2022-12-05 20:14:32'),
(119, '_shift_id', 'Shift', 'dropdown', 'general,type,shift', '', '%', '', '', '', 0, '2022-11-30 17:37:10'),
(120, 'description_p', 'File', 'upload', '', '', '', 'varchar', '', '', 0, '2022-12-13 07:26:51'),
(121, 'type_p', 'Type', 'hidden_ele', '', '', 'user', '', '', '', 0, '2022-12-29 09:36:52'),
(122, 'position_p', 'Position', 'hidden_ele', '', '', '', '', '', '', 0, '2022-01-20 12:04:10'),
(123, '_char_name', 'Char', 'text', '', '', '', 'text', '3', '', 0, '2020-07-30 20:36:58'),
(124, '_student_id', 'Student ID', 'autocomplete', 'student', '', '', 'load_footer load_header req', '', '', 0, '2022-12-19 09:51:47'),
(125, '_year_id', 'Year', 'dropdown', 'academic_year|', '', '', 'get_data', '', '', 0, '2022-10-28 07:35:14'),
(126, '_month_id', ' Month', 'dropdown', 'month', '', '', '', '', '', 0, '2022-12-13 06:47:03'),
(127, '_branch', ' Branch', 'dropdown', 'branch|', '', '', 'varchar', '', '', 0, '2020-08-02 18:46:07'),
(128, '_subclass_id', 'Choose Sub Class', 'dropdown', 'sub_class|', '', '', 'load', '', 'load_sub_class', 0, '2020-08-02 21:53:18'),
(129, '_address_id', 'Address', 'hidden_ele', '', '', '%', 'varchar', '', '', 0, '2020-08-03 08:08:27'),
(130, '_company2_id', 'Company2', 'dropdown', 'company2|', '', '', '', '', '', 0, '2021-12-18 11:08:02'),
(131, 'name_p', 'Name', 'Element Type', '', '', '', '', '', '', 0, '2021-12-18 10:02:24'),
(132, '_disability', 'Disability Status', 'checkbox', 'disability_', '', '', 'varchar', '', '', 0, '2020-08-28 11:16:48'),
(133, '_orphan', 'Orphan Status', 'checkbox', 'orphan_', '', '', 'varchar', '', '', 0, '2020-08-28 11:15:20'),
(134, '_refugee', 'Refugee Status', 'checkbox', 'refugee_', '', '', 'varchar', '', '', 0, '2020-08-28 11:15:24'),
(135, '_state', '_state', 'Element Type', '', '', '', 'varchar', '', '', 0, '2021-12-18 10:02:24'),
(136, '_nationality', '_nationality', 'Element Type', '', '', '', 'varchar', '3', '', 0, '2021-12-18 10:02:24'),
(137, '_region', 'Region', 'dropdown', 'region_', '', '', 'varchar', '3', '', 0, '2022-12-25 07:13:52'),
(138, '_district', '_district', 'Element Type', '', '', '', 'varchar', '3', '', 0, '2021-12-18 10:02:24'),
(139, '_village', '_village', 'Element Type', '', '', '', 'varchar', '6', '', 0, '2021-12-18 10:02:24'),
(140, '_reg_fee', 'Regfee', 'Element Type', '', '', '%', 'float', '', '', 0, '2021-12-18 11:04:49'),
(141, '_prefix', 'Search By Telephone', 'varchar', '', 'Guardian Tell or Student ID', '', 'varchar', '', '', 0, '2020-08-30 06:38:37'),
(142, '_auto_id', 'To', 'hidden_ele', 'to|', '', '', '', '', '', 0, '2023-01-24 08:32:47'),
(143, '_tell2', 'Telephone2', 'hidden_ele', '', '6xxxxxxx', '', 'number tell', '4', '', 0, '2021-03-28 13:38:59'),
(144, 'email_p', 'Email', 'email', '', '', '', '', '', '', 0, '2022-09-15 09:46:39'),
(145, 'pic_p', 'Image', 'file', 'images', '', '.2', '', '', '', 0, '2022-01-06 15:33:34'),
(146, '_department_id', 'Department', 'dropdown', 'department|', '', '', 'load', '', 'department_id,class-', 0, '2022-12-24 09:16:35'),
(147, '_doctor_id', 'Doctor', 'dropdown', 'doctor|', '', '', '', '', '', 0, '2022-12-24 09:10:21'),
(148, '_department', 'category', 'dropdown', 'department|', '', '', 'load', '', 'department_id,class-', 0, '2023-08-10 11:15:24'),
(149, '_status', 'Status', 'dropdown', 'status_', '', '', '', '', '', 0, '2022-12-21 17:06:22'),
(150, '_number', ' Number', 'hidden_ele', '', '', '', 'int', '', '', 0, '2021-03-27 05:00:34'),
(151, '_ip', ' Ip', 'ip', '', '', '', 'varchar', '', '', 0, '2021-03-27 05:01:00'),
(152, '_country', '_country', 'Element Type', '', '', '', 'varchar', '', '', 0, '2021-12-18 10:02:24'),
(153, '_city', ' City', 'hidden_ele', '', '', '%', 'varchar', '', '', 0, '2023-08-10 11:15:24'),
(154, '_device', 'Device', 'device', '', '', '', 'varchar', '', '', 0, '2022-02-18 16:51:10'),
(155, '_result', ' Result', 'hidden_ele', '', '', '', 'mediumtext', '', '', 0, '2021-03-27 05:02:44'),
(156, 'action_p', 'Date', 'date', 'auto_rec_', '', 'links', '', '', '', 0, '2022-12-13 07:26:27'),
(157, 'grant_p', 'User', 'hidden', 'user', '', '', '', '', '', 0, '2022-03-27 08:19:17'),
(158, 'username_p', 'Username', 'email', '', '', '', '', '', '', 0, '2022-01-06 15:34:20'),
(159, '_patient', 'Patient', 'autocomplete', 'patient|', '', '', '', '', '', 0, '2021-03-31 10:45:01'),
(160, '_bank', ' Bank', 'dropdown', 'general,type,account', '', '', 'int', '', '', 0, '2022-12-14 10:52:19'),
(161, '_expense', 'Expense', 'Element Type', '', '', '', 'int', '', '', 0, '2021-12-18 11:04:49'),
(162, 'parameter_p', 'Csv File', 'upload', '', '', '%', 'varchar', '', '', 0, '2021-12-18 14:32:03'),
(163, 'company_id', 'Company', 'hidden_u', 'all_company', '', '', 'load', '', 'company_id,ktc_category-', 0, '2021-05-29 05:08:10'),
(164, 'pass_p', 'Old Password', 'hidden_ele', '', '', 'reset_reset_ktc', '', '', '', 0, '2022-10-29 08:37:03'),
(165, 'auto_p', ' To', 'hidden_ele', '', '', '', '', ' ', '', 0, '2021-06-06 07:38:23'),
(166, 'user_id', 'User Id', 'hidden', '', '', '', 'int', '', '', 0, '2021-05-29 05:12:15'),
(167, 'desc_p', 'Description', 'varchar', '', '', '', 'varchar', '', '', 0, '2021-05-29 05:12:32'),
(168, 'cust_p', 'Customer', 'autocomplete', 'customer|', '', '', '', '', '', 0, '2021-05-29 06:14:00'),
(169, 'item_p', 'Item', 'autocomplete', 'item|', '', '', '', '', '', 0, '2021-05-29 05:15:50'),
(170, 'image_p', 'Image', 'file', '', '', '', '', '', '', 0, '2021-05-29 05:28:05'),
(171, 'p_name', 'Name', 'text', '', '', '', 'text', '3', '', 0, '2022-08-19 23:25:23'),
(172, 'p_company_id', 'Pcompany', 'dropdown', '', '', '', 'load', '', 'company_id,ktc_category-', 0, '2021-12-18 11:08:02'),
(173, 'p_auto_id', 'To', 'hidden_ele', 'to|', '', '', '', '', '', 0, '2022-06-26 08:02:24'),
(174, 'p_description', 'Pdescription', 'Element Type', '', '', '', 'text', '', '', 0, '2021-12-18 11:04:49'),
(175, 'discount_p', 'Discount', 'int', '', '0', '', 'int', '', '', 0, '2021-05-29 16:05:16'),
(176, 'amount_p', 'Amount', 'float', '', '123', '', 'float', '', '', 0, '2021-05-29 16:05:25'),
(177, 'unit_p', 'Unit', 'varchar', '', '', '', 'varchar', '', '', 0, '2021-06-06 07:38:23'),
(178, 'qty_p', 'Qty', 'float', '', '', '', 'float', '', '', 0, '2021-06-06 07:38:23'),
(179, 'price_p', 'Price', 'float', '', '', '', 'float', '', '', 0, '2021-06-06 07:38:23'),
(180, 'date_p', 'Date', 'date', '', '', '', 'date', '', '', 0, '2021-06-06 07:38:23'),
(181, 'tell_p', 'Tell', 'number', '', '', '', '', '', '', 0, '2022-01-06 15:34:04'),
(182, 'p_type', 'Type', 'hidden_ele', '', '', 'university', 'varchar', '', '', 0, '2022-12-19 09:57:11'),
(183, 'seller_p', 'Seller', 'varchar', '', '', '', 'varchar', '', '', 0, '2021-06-07 03:54:03'),
(184, 'address_p', 'Address', 'varchar', '', '', '', 'varchar', '', '', 0, '2021-06-07 03:54:03'),
(185, '_seat', 'No of Seat', 'int', '', '', '', 'int', '', '', 0, '2021-07-26 08:17:17'),
(186, '_air_id', 'Air', 'dropdown', 'air|', '', '', 'int', '', '', 0, '2021-12-18 11:08:02'),
(187, '_flight_id', 'Choose Flight', 'dropdown', 'flight', '', '', 'int', '', '', 0, '2021-07-26 20:45:37'),
(188, '_from_location_id', ' From', 'dropdown', 'general,type,location', '', '', '', '', '', 0, '2021-07-26 12:22:49'),
(189, '_to_location_id', ' To', 'dropdown', 'general,type,location', '', '', '', '', '', 0, '2021-07-26 12:22:57'),
(190, '_day_id', 'Day', 'hidden_ele', 'general,type,day', '', 'teachers_list', 'teachers_list', '', '', 0, '2022-10-21 08:29:35'),
(191, '_vip_amount', 'Vip Seat Amount', 'float', '', '', '', 'varchar', '', '', 0, '2021-07-26 20:58:25'),
(192, '_normal_amount', 'Normal Seat Amount', 'float', '', '10', '', 'float', '', '', 0, '2021-07-26 12:07:03'),
(193, '_flight_no', ' Flight No', 'text', '', '', '', 'int', '', '', 0, '2021-07-26 20:08:50'),
(194, '_from_id', 'From', 'date', 'from|', '', '', '', '', '', 0, '2021-12-18 12:48:39'),
(195, '_to_id', 'To', 'date', 'to|', '', '', '', '', '', 0, '2021-12-18 12:48:39'),
(196, '_seat_no', 'Seat No', 'int', '', '', '', 'int', '', '', 0, '2021-07-30 21:21:46'),
(197, '_customer', 'Customer', 'date', '', 'Search Name or Tell', '%', '', '', '', 0, '2021-12-18 12:48:39'),
(198, '_air', 'Air', 'Element Type', '', '', '', 'varchar', '', '', 0, '2021-12-18 11:04:49'),
(199, '_secondery_tell', '_secondery_tell', 'Element Type', '', '6xxxxxx', '', '', '4', '', 0, '2021-12-18 10:02:24'),
(200, '_identity', 'Entity', 'Element Type', '', '', '', 'varchar', '', '', 0, '2021-12-18 10:02:24'),
(201, '_guardian', '_guardian', 'Element Type', '', '', '', 'varchar', '', '', 0, '2021-12-18 10:02:24'),
(202, '_guardian_tell', '_guardian_tell', 'Element Type', '', '6xxxxxx', '', '', '4', '', 0, '2021-12-18 10:02:24'),
(203, '_certificate', '_certificate', 'Element Type', '', '', '', 'varchar', '', '', 0, '2021-12-18 10:02:24'),
(204, '_dhalasho', '_dhalasho', 'Element Type', '', '', '', 'varchar', '', '', 0, '2021-12-18 10:02:24'),
(205, '_sent_wa', '_sent_wa', 'Element Type', '', '', '', 'date', '', '', 0, '2021-12-18 10:02:24'),
(206, '_admin_tell', '_admin_tell', 'Element Type', '', '6xxxxxx', '', '', '4', '', 0, '2021-12-18 10:02:24'),
(207, '_device_id', 'Device', 'dropdown', '', '', '', 'varchar', '', '', 0, '2021-12-18 11:08:02'),
(208, '_token', 'Token', 'date', '', '', '', '', '', '', 0, '2021-12-18 12:48:39'),
(209, '_is_admin', '_is_admin', 'Element Type', '', 'Abdihamid Hussein Geddi', '', 'varchar', '', '', 0, '2021-12-18 10:02:24'),
(210, '_month', ' Month', 'dropdown', 'month_', '', '', '', '', '', 0, '2022-12-12 05:55:40'),
(211, '_code', 'Code', 'varchar', '', 'ar21', '', 'varchar', '', '', 0, '2021-12-20 07:21:53'),
(212, '_cv', 'Cv', 'file', 'docs', '', '', '', '', '', 0, '2021-12-18 11:18:18'),
(213, '_degree_id', 'Degree', 'dropdown', 'general,type,degree', '', '', 'varchar', '', '', 0, '2022-03-19 15:33:57'),
(214, '_title_id', 'choose title', 'dropdown', 'general,type,title', '', '', '', '', '', 0, '2022-03-19 15:33:49'),
(215, '_semester_id', ' Semester', 'dropdown', 'general,type,semester', '', '', 'load2', '', 'class_semester_course', 0, '2022-12-21 08:18:58'),
(216, '_course_id', 'Course', 'dropdown', 'course', '', '', '', '', '', 0, '2022-12-21 08:17:18'),
(217, '_lecture_id', 'Lecture', 'hidden_ele', '', '', '%', 'req', '', '', 0, '2022-12-13 12:04:26'),
(218, '_credit_hour', 'Credithour', 'Element Type', '', '', '3', 'double', '', '', 0, '2021-12-18 11:04:49'),
(219, '_rate', 'Rate', 'Element Type', '', '', '', 'double', '', '', 0, '2021-12-18 11:04:49'),
(220, '_folder', 'Folder', 'Element Type', '', '', '', 'varchar', '', '', 0, '2021-12-18 11:04:49'),
(221, '_intro_video', 'Introvideo', 'hidden_ele', 'videos', '', '', 'varchar', '', '', 0, '2022-04-05 04:34:24'),
(222, '_sample_video', 'Samplevideo', 'Element Type', '', '', '', 'varchar', '', '', 0, '2021-12-18 11:04:49'),
(223, '_ppt', 'Pt', 'Element Type', '', '', '', 'varchar', '', '', 0, '2021-12-18 10:02:24'),
(224, '_video', 'Video URL', 'text', 'videos', '', '', 'varchar', '', '', 0, '2022-03-06 14:21:44'),
(225, '_audio', 'Audio', 'Element Type', '', '', '', 'varchar', '', '', 0, '2021-12-18 11:04:49'),
(226, '_matching_id', 'new Matching', 'dropdown', 'course_teacher', '', '', '', '', '', 0, '2022-01-19 18:41:34'),
(227, '_pages', 'Ages', 'Element Type', '', '', '', 'int', '', '', 0, '2021-12-18 10:02:24'),
(228, '_video2', 'Video2', 'Element Type', '', '', '', 'varchar', '', '', 0, '2021-12-18 11:04:49'),
(229, '_minutes', 'Minutes', 'Element Type', '', '', '', 'varchar', '', '', 0, '2021-12-18 11:04:49'),
(230, '_chapter_id', 'Chapter', 'dropdown', 'chapter|', '', '', 'int', '', '', 0, '2021-12-18 11:08:02'),
(231, '_expire_date', 'Expiredate', 'date', '', '', '', '', '', '', 0, '2021-12-18 12:48:39'),
(232, '_exam_id', 'Exam', 'hidden_ele', 'general,type,exam', '', '162', 'int', '', '', 0, '2022-12-21 05:17:30'),
(233, '_marks', 'Marks', 'Marks', '', '', '', 'varchar', '', '', 0, '2022-11-23 15:23:42'),
(234, '_start_time', 'Entry time', 'time', '', '', '', '', '', '', 0, '2022-04-09 09:27:03'),
(235, '_end_time', 'Leave Time', 'time', '', '', '', '', '', '', 0, '2022-04-09 09:27:05'),
(236, '_exam_id2', 'Exam2', 'Element Type', '', '', '', 'int', '', '', 0, '2021-12-18 11:04:49'),
(237, '_martial_status', '_martial_status', 'Element Type', '', '', '1', 'int', '', '', 0, '2021-12-18 10:02:24'),
(238, '_disability_status', '_disability_status', 'Element Type', '', '', '1', 'int', '', '', 0, '2021-12-18 10:02:24'),
(239, '_orphan_status', '_orphan_status', 'Element Type', '', '', '1', 'int', '', '', 0, '2021-12-18 10:02:24'),
(240, '_refugee_status', '_refugee_status', 'Element Type', '', '', '1', 'int', '', '', 0, '2021-12-18 10:02:24'),
(241, '_matching_1', 'Old Match', 'dropdown', 'course_teacher2', '', '', 'varchar', '', '', 0, '2022-01-19 18:46:30'),
(242, '_semeser_id', 'Semeser', 'dropdown', 'semeser|', '', '', 'int', '', '', 0, '2021-12-18 11:08:02'),
(243, '_fee_monthly', 'Feemonthly', 'varchar', '', 'Fee Monthly', '', '', '', '', 0, '2022-02-22 17:12:04'),
(244, '_fee_yearly', 'Feeyearly', 'varchar', '', 'Fee Yearly', '', 'float', '', '', 0, '2022-02-22 17:12:04'),
(245, '_options', ' Options', 'varchar', '', '', '', 'varchar', '', '', 0, '2021-12-15 12:22:31'),
(246, '_correct_answer', ' Answer', 'varchar', '', '', '', 'longtext', '', '', 0, '2022-11-23 15:24:05'),
(247, '_teacher_id', 'Teacher', 'hidden_ele', 'teacher|', '', '', 'int', '', '', 0, '2022-04-05 04:34:12'),
(248, '_pdf', 'Lesson PDf', 'file', 'docs', '', '', 'varchar', '', '', 0, '2022-03-06 14:20:37'),
(249, '_experience', 'Experience', 'varchar', '', '2 Years...', '', 'varchar', '', '', 0, '2021-12-18 12:39:49'),
(250, '_degree', 'Degree', 'dropdown', 'degree_', '', '', 'varchar', '', '', 0, '2021-12-18 12:07:38'),
(251, '_price', 'Price', 'hidden_ele', '', 'Price($)', '', 'double', '', '', 0, '2022-04-05 04:34:14'),
(252, '_book', 'Course Book', 'file', 'docs', '', '', 'varchar', '', '', 0, '2021-12-20 07:30:56'),
(253, '_teacher', 'Teacher', 'dropdown', 'course_teacher', '', '', 'load', '', 'course_teacher_id,chapter-', 0, '2021-12-20 13:12:13'),
(254, '_course', 'Course', 'autocomplete', 'course', '', '', '', '', '', 0, '2022-12-20 09:48:02'),
(255, '_chapter', 'Chapter', 'dropdown', 'chapter|', '', '', '', '', '', 0, '2022-03-07 05:55:27'),
(256, '_exam_type', 'Examtype', 'hidden_ele', 'u_exam_type_', '', '%', 'int', '', '', 0, '2022-01-06 12:00:47'),
(257, '_percentage', 'Percentage', 'varchar', '', '0.5, 1, 2...', '', 'double', '', '', 0, '2021-12-19 10:50:21'),
(258, '_balance', 'Balance', 'text', '', 'Open Balance', '', 'double', '', '', 0, '2022-12-02 18:46:08'),
(259, '_acc_id', 'Account', 'dropdown', 'accounts|', '', '', 'int', '', '', 0, '2021-12-19 10:13:31'),
(260, '_dep_id', 'Choose Department', 'dropdown', 'department|', '', '', 'int', '', '', 0, '2022-02-23 18:10:30'),
(261, '_acc_year', 'Acc Year', 'dropdown', 'academic_year|', '', '', 'load_header req', '', '', 0, '2022-09-09 09:31:13'),
(262, '_lesson', 'Lesson', 'dropdown', 'lesson|', '', '', 'varchar', '', '', 0, '2021-12-18 13:11:30'),
(263, '_acc', 'Account', 'dropdown', 'accounts|', '', '', 'varchar', '', '', 0, '2021-12-18 12:24:36'),
(264, '_class', 'Class', 'dropdown', 'class|', '', '', 'load', '', '', 0, '2022-11-25 16:09:00'),
(265, 'value_p', 'com', 'hidden_u', '', '', '', '', '', '', 0, '2022-12-13 07:26:07'),
(266, 'text_p', 'user', 'hidden', '', '', '', '', '', '', 0, '2022-12-13 07:26:19'),
(267, 'user2_p', 'User2', 'hidden', '', '', '', '', '', '', 0, '2022-10-02 13:41:43'),
(268, 'label_p', 'Label', 'Element Type', '', '', '', '', '', '', 0, '2021-12-18 07:49:23'),
(269, 'class_p', 'Class', 'dropdown', '', '', '', '', '', '', 0, '2021-12-18 13:00:08'),
(270, 'size_p', 'Size', 'Element Type', '', '', '', '', '', '', 0, '2021-12-18 10:02:24'),
(271, 'load_action_p', 'Loadaction', 'Element Type', '', '', '', '', '', '', 0, '2021-12-18 11:04:49'),
(272, 'placeholder_p', 'Placeholder', 'Element Type', '', '', '', 'varchar', '', '', 0, '2021-12-18 10:02:24'),
(273, 'full_name_p', 'Fullname', 'text', '', '', '', '', '', '', 0, '2022-01-06 15:34:18'),
(274, 'password_p', 'Password', 'password', '', '', '', 'password', '', '', 0, '2022-01-06 15:34:08'),
(275, 'confirm_p', 'Confirm', 'password', '', '', '', 'on-keyup', '', '', 0, '2022-01-06 15:34:12'),
(276, 'status_p', 'Status', 'text', '', '0,1,2,3', '%', '', '', '', 0, '2022-10-02 09:28:43'),
(277, 'href_p', 'Href', 'dropdown', 'href_', '', '', 'get_info', '', '', 0, '2021-12-18 11:18:18'),
(278, 'title_p', 'Post Title', 'Element Type', '', '', '', '', '', '', 0, '2022-09-29 17:55:27'),
(279, 'sp_p', 'Date', 'date', 'sp', '', '%', '', '', '', 0, '2022-01-06 10:02:32'),
(280, 'form_action_p', 'Formaction', 'radio', 'form_', '', '', '', '', '', 0, '2021-12-18 11:18:18'),
(281, 'btn_p', 'Btn', 'Element Type', '', 'Create, Save , Add ....', '', '', '', '', 0, '2021-12-18 11:04:49'),
(282, 'link_icon_p', 'Linkicon', 'autocomplete', 'icon', '', '', '', '', '', 0, '2022-02-13 14:59:40'),
(283, 'level_p', 'Level', 'Element Type', '', '', '', 'varchar', '', '', 0, '2021-12-18 10:02:24'),
(284, 'new_p', 'New Password', 'password', '', '', '', 'password', '', '', 0, '2022-09-30 08:48:31'),
(285, 'pass2_p', 'Confirm Password', 'password', '', '', '', 'on-keyup', '', '', 0, '2022-09-29 04:28:15'),
(286, 'users_p', 'Users', 'dropdown', 'ktc_user|', '', '', '', '', '', 0, '2022-10-02 08:46:42'),
(287, 'p_user_id', 'Puser', 'dropdown', 'puser|', '', '', '', '', '', 0, '2021-12-18 11:08:02'),
(288, 'p_expense', 'Pexpense', 'Element Type', '', '', '', 'int', '', '', 0, '2021-12-18 11:04:49'),
(289, 'p_amount', 'Pamount', 'Element Type', '', '10', '', 'float', '', '', 0, '2021-12-18 11:04:49'),
(290, 'p_date', 'Pdate', 'date', '', '', '', '', '', '', 0, '2021-12-18 12:48:39'),
(291, '_class_id_2', 'Class2', 'dropdown', '', '', '', '', '', '', 0, '2021-12-18 13:00:08'),
(292, '_day', 'Day', 'Element Type', '', '', '', '', '', '', 0, '2021-12-18 11:04:49'),
(293, '_time', 'Time', 'Element Type', '', '', '', 'time', '', '', 0, '2021-12-18 11:04:49'),
(294, '_preview', 'Review', 'hidden_ele', 'preview_', '', '', 'mediumtext', '', '', 0, '2022-03-06 14:21:37'),
(295, '_duration', 'Duration', 'hidden_ele', '', '2 months, 2 Weaks...', '', 'varchar', '', '', 0, '2022-04-05 04:34:17'),
(296, '_dep', 'category', 'dropdown', 'department|', '', '', 'load', '', 'department_id,class-', 0, '2022-02-27 08:06:01'),
(297, '_cour_teacher', 'Course Teacher', 'dropdown', 'course_teacher', '', '', 'load', '', 'course_teacher_id,chapter-', 0, '2022-03-06 14:20:37'),
(298, '_language', 'Language', 'hidden_ele', 'language_', '', 'EN', 'varchar', '', '', 0, '2022-12-17 05:57:23'),
(299, '_reason', ' Reason', 'varchar', '', 'Enter fee type', '', 'varchar', '', '', 0, '2021-12-19 09:06:19'),
(300, '_std', 'Student', 'autocomplete', 'student|', '', '', 'varchar', '', '', 0, '2021-12-19 10:20:46'),
(301, '_std_id', 'Student ID', 'autocomplete', 'transfer_student', '', '', 'load_header req', '', '', 0, '2022-12-21 06:02:14'),
(302, '_course_teacher', 'Course/Teacher', 'checkbox', 'course_teacher', '', '', 'varchar', '', '', 0, '2022-01-22 14:29:10'),
(303, '_c_image', 'Course Image', 'file', 'images', '', '', 'int', '', '', 0, '2021-12-22 12:06:55'),
(304, '_shot_desc', 'Short Description', 'textarea', '', 'Short Description about the course', '', 'text', '', '', 0, '2021-12-22 12:05:37'),
(305, '_long_desc', 'Long Description', 'textarea', '', 'Long Description about the course', '', 'text', '', '', 0, '2021-12-22 15:38:03'),
(306, '_requir', 'Course Requirements', 'textarea', '', '', '', 'text', '', '', 0, '2021-12-22 15:37:14'),
(307, 'Syllabus', 'Course Syllabus', 'textarea', '', '', '', 'text', '', '', 0, '2021-12-22 15:36:55'),
(308, '_short_description', ' Short Description', 'hidden_ele', '', '', '', 'text', '', '', 0, '2022-04-05 04:34:32'),
(309, '_long_description', ' Long Description', 'hidden_ele', '', '', '', 'text', '', '', 0, '2022-04-05 04:34:34'),
(310, '_requirments', ' Requirments', 'hidden_ele', '', '', '', 'text', '', '', 0, '2022-04-05 04:34:36'),
(311, '_syllabus', ' Syllabus', 'hidden_ele', '', '', '', 'text', '', '', 0, '2022-04-05 04:34:49'),
(312, '_course_code', ' Course Code', 'hidden_ele', '', '', '', 'varchar', '', '', 0, '2022-04-05 04:34:51'),
(313, 'copy_user_p', 'Copy User', 'dropdown', 'ktcuser', '', '', 'int', '', '', 0, '2022-01-09 11:40:27'),
(314, 'paste_user_p', 'Paste User', 'checkbox', 'ktcuser', '', '', 'int', '', '', 0, '2022-11-26 06:28:42'),
(315, '_course_teacher_id', 'Choose Courses', 'dropdown', 'course_teacher', '', '', 'load', '', 'course_teacher_id,chapter-', 0, '2022-03-07 05:50:18'),
(316, '_answer', ' Answer', 'textarea2', '', '', '', 'longtext', '', '', 0, '2022-02-16 16:49:13'),
(317, '_location', ' Location', 'hidden_ele', '', '', '', 'text', '', '', 0, '2022-02-16 16:49:23'),
(318, '_yes', ' Yes', 'hidden_ele', '', '', '', 'int', '', '', 0, '2022-02-16 16:49:25'),
(319, '_no', ' No', 'hidden_ele', '', '', '', 'int', '', '', 0, '2022-02-16 16:49:27'),
(320, '_days', 'Absent  Days', '', '', 'Enter Absent Days eg. 5', '', '', '', '', 0, '2022-02-18 16:51:41'),
(322, '_faculty_id', ' Faculty', 'dropdown', 'faculty|', '', '', '', '', '', 0, '2022-12-20 13:56:10'),
(325, '_campus_id', ' Campus', 'dropdown', 'branch', '', '', 'load_check', '', 'campus_class', 0, '2022-12-14 11:53:25'),
(328, '_capmus_id', 'Choose Campus', 'dropdown', 'branch', '', '', 'varchar', '', '', 0, '2022-03-19 15:35:53'),
(331, 'id_p', 'Choose Department', 'dropdown', 'departmentid', '', '', 'varchar', '', '', 0, '2022-03-22 09:40:23'),
(334, '_in_out', ' In Out', 'dropdown', 'in_out_', '', '', '', '', '', 0, '2022-03-26 13:03:08'),
(337, '_session', ' Session', 'dropdown', 'semester_session_', '', '', 'varchar', '', '', 0, '2022-11-17 06:31:48'),
(340, '_lang', 'Language', 'dropdown', 'language_', '', '', 'varchar', '', '', 0, '2022-12-11 06:22:11'),
(343, '_dayoff', 'Day off', 'dropdown', 'day_', '', '', '', '', '', 0, '2022-04-09 09:26:41'),
(346, '_group', 'Choose Shift', 'dropdown', 'hr_attendance_group|', '', '', '', '', '', 0, '2022-04-09 09:12:18'),
(349, '_start', 'Entry Time', 'time', '', '', '', 'time', '', '', 0, '2022-04-09 09:11:32'),
(352, '_end', 'Leave Time', 'time', '', '', '', 'time', '', '', 0, '2022-04-09 09:11:46'),
(355, '_normal_time', 'Normal Time', 'time', '', '', '', 'time', '', '', 0, '2022-04-09 09:36:51'),
(358, '_seconds', ' Seconds', 'hidden_ele', '', '', '480', 'int', '', '', 0, '2022-04-09 09:37:10'),
(361, '_sem_id', 'Semester', 'dropdown', 'general,type,semester', '', '', 'load2', '', 'class_semester_course', 0, '2022-12-11 06:22:11'),
(364, '_mid_final_id', 'Mid Final Id', 'hidden_ele', 'general,type,mid_final', '', '46', '', '', '', 0, '2022-12-18 06:33:18'),
(367, '_insert_update', 'Date', 'hidden_ele', '', '', 'insert', '', '', '', 0, '2022-12-11 06:22:11'),
(370, '_table_name', 'Table', 'hidden_ele', 'table', 'eg. Morning Shift, Noon Shift, Night Shift, Part time shift', 'hr_employee', 'text', '3', '', 0, '2022-11-20 15:03:46'),
(373, '_table_auto_id', 'Course', 'autocomplete', 'course|', '', '', '', '', '', 0, '2022-11-20 15:04:33'),
(376, '_emp_id', 'user', 'hidden', '', '', '', 'int', '', '', 0, '2022-07-16 09:26:55'),
(379, '_user_level', ' User Level', 'hidden_ele', '', '', 'u', 'teacher', '', '', 0, '2022-12-02 08:23:46'),
(382, '_sem_session', ' Session', 'dropdown', 'semester_session_', '', '', 'load_header req', '', '', 0, '2022-09-09 09:34:37'),
(385, '_period_id', '', 'hidden_ele', 'period_today', '', '', 'int', '', '', 0, '2022-11-28 09:40:35'),
(386, '_link_id', 'Complaint Page', 'dropdown', 'ktc_link', '', '643', 'load_me', '', 'category_id,ktc_link-', 0, '2022-12-13 15:45:39'),
(387, 'file_p', 'File', 'file', 'images', '', '', '', '', '', 0, '2022-09-29 17:55:15'),
(388, 'content_p', 'Post Content', 'textarea2', '', '', '', 'longtext', '', '', 0, '2022-09-29 17:55:34'),
(389, 'nav_p', 'Nav', 'hidden_ele', '', '', '%', 'varchar', '', '', 0, '2022-09-30 08:32:03'),
(390, 'mob_p', 'Search by tell', 'number', '', 'Tell, ID or Bank Ref No', '', 'varchar', '', '', 0, '2022-10-11 18:25:50'),
(391, 'std_p', 'Student ID', 'autocomplete', 'all_student', '', '', 'get_info', '', '', 0, '2022-12-06 12:59:09'),
(392, 'fee_p', 'Fee', 'dropdown', 'fee', '', '', 'int', '', '', 0, '2022-12-06 03:07:32'),
(393, 'disc_p', 'Disc', 'hidden_ele', '', '', '', 'float', '', '', 0, '2022-10-12 16:49:36'),
(394, 'month_p', 'Month', 'dropdown', 'month', '', '', '', '', '', 0, '2022-12-06 03:15:22'),
(395, 'year_p', 'Year', 'hidden_ele', 'academic_year|', '', '', 'int', '', '', 0, '2022-12-05 02:16:53'),
(396, 'ref_p', 'Bank Ref No', 'varchar', '', '', '', 'varchar', '', '', 0, '2022-10-12 16:51:42'),
(397, '_type_id', 'Emp Type', 'dropdown', 'general,type,emp_type', '', '', 'varchar', '', '', 0, '2022-10-21 07:49:39'),
(398, '_mid_final', ' Mid Final', 'dropdown', 'general,type,mid_final', '', '', 'varchar', '', '', 0, '2022-11-17 06:35:15'),
(399, '_period', 'Period', 'varchar', '', '', '', 'int', '', '', 0, '2022-11-19 12:08:48'),
(400, '_couse', ' Couse', 'hidden_ele', '', '', '', 'varchar', '', '', 0, '2022-12-16 08:31:11'),
(401, '_translated', 'Arabic Teacher ANme', 'varchar', '', '', '', 'varchar', '', '', 0, '2022-11-20 15:03:58'),
(402, '_marksheet_file', ' Marksheet File', 'file', '', 'docx', '', '', '', '', 0, '2022-12-19 09:51:14'),
(403, '_from_university', 'From University', 'dropdown', '', '', '', '', '', '', 0, '2022-12-19 11:11:44'),
(404, '_old_class_id', 'Old Class', 'hidden_ele', 'class|', '', '', 'varchar', '', '', 0, '2022-12-16 08:31:28'),
(405, '_new_class_id', 'New Class', 'autocomplete', 'class', '', '', 'varchar', '', '', 0, '2022-12-16 08:31:33'),
(406, '_faculty', ' Faculty', 'dropdown', 'faculty|', '', '', '', '', '', 0, '2022-12-19 11:11:44'),
(407, '_new_course_id', 'Course', 'hidden_ele', '', '', '', 'paste', '', 'course_teacher_id,chapter-', 0, '2022-12-21 08:17:41'),
(408, '_chapter_no', ' Chapter No', 'number', '', '', '', 'int', '', '', 0, '2022-12-07 09:37:06'),
(409, '_topic', ' Topic', 'varchar', '', '', '', 'varchar', '', '', 0, '2022-11-23 13:16:57'),
(410, '_graduation_year', 'Graduation Year', 'dropdown', 'academic_year|', '', '', '', '', '', 0, '2022-11-23 13:38:04'),
(411, '_apartment', 'Apartment e.g Apartment A, Apartment B', 'varchar', '', '', '', 'varchar', '', '', 0, '2022-11-25 12:37:32'),
(412, '_question', ' Question', 'textarea', '', '', '', '', '', '', 0, '2023-01-01 08:20:49'),
(413, '_supervisor', ' Supervisor', 'autocomplete', 'employee', '', '', 'int', '', '', 0, '2022-11-26 09:46:23'),
(414, '_campus', ' Campus', 'dropdown', 'campus|', '', '', 'varchar', '', '', 0, '2022-11-25 16:26:24'),
(415, '_semester', ' Semester', 'dropdown', '', '', '', 'varchar', '', '', 0, '2022-11-25 17:42:01'),
(416, '_assignment', ' Assignment', 'dropdown', '', '', '', 'date', '', '', 0, '2022-11-25 18:12:06'),
(417, '_supervisor_id', 'Supervisor', 'autocomplete', 'employee', '', '', 'int', '', '', 0, '2022-11-26 09:19:54'),
(418, '_certificate_no', ' No', 'autocomplete', '', '', '', 'int', '', '', 0, '2022-11-29 19:48:15'),
(419, '_semester_session', 'Semester Session', 'dropdown', 'semester_session_', '', '', 'varchar', '', '', 0, '2022-11-30 11:59:51'),
(420, '_credit_houre', 'Credit Hour', 'Element Type', '', '', '3', 'double', '', '', 0, '2022-11-30 11:44:50'),
(421, '_credit_hours', ' Credit Hours', 'number', '', '', '', 'int', '', '', 0, '2022-11-30 11:59:03'),
(422, '_new_transfer', ' New Transfer', 'dropdown', 'New_Transfer_', '', '', 'int', '', '', 0, '2022-12-02 14:40:36'),
(423, '_project', 'Roject', 'file', 'docs', '', '', 'int', '', '', 0, '2022-12-02 14:53:59'),
(424, '_opr', 'Operator', 'dropdown', 'operator_', '', '', 'varchar', '', '', 0, '2022-12-02 18:45:15'),
(425, '_file', ' File', 'file', '', 'docs', '', '', '', '', 0, '2022-12-03 10:53:49'),
(426, '_sub_category_id', 'Select Sub Menu', 'dropdown', 'ktc_sub_category', '', '', 'load', '', 'sub_category_id,ktc_link-', 0, '2022-12-13 15:51:31'),
(427, '_office', ' Office', 'dropdown', '', '', '', 'varchar', '', '', 0, '2022-12-05 17:22:06'),
(428, '_mounth', 'Month', 'dropdown', 'month', '', '', 'varchar', '', '', 0, '2022-12-06 15:58:35'),
(429, '_plus', 'Othercharge', 'float', '', '', '', 'float', '', '', 0, '2022-12-13 06:46:42'),
(430, '_user_id2', 'User Id', 'hidden_ele', 'user', '', '', 'int', '', '', 0, '2022-12-19 08:18:27'),
(431, '_screenshot', 'Screenshot', 'file', 'images', '', '', 'varchar', '', '', 0, '2022-12-13 15:46:36'),
(432, '_pass', 'Password', 'varchar', '', '', '', 'varchar', '', '', 0, '2022-12-14 11:52:11'),
(433, '_full_marks', ' Full Marks', 'varchar', '', '', '', 'varchar', '', '', 0, '2022-12-18 06:53:43'),
(434, '_office_id', ' Office Id', 'dropdown', 'general,type,office', '', '', 'int', '', '', 0, '2022-12-19 08:51:59'),
(435, '_end_date', 'End Date', 'date', '', '', '', 'time', '', '', 0, '2022-12-21 17:06:07'),
(436, '_start_date', 'Start Date', 'date', '', '', '', 'time', '', '', 0, '2022-12-21 17:05:59'),
(437, '_election_id', ' Election Id', 'int', '', '', '', 'int', '', '', 0, '2022-12-21 17:23:58'),
(438, '_candidate_id', 'Candidate Date', 'date', '', '', '', '', '', '', 0, '2022-12-21 17:23:01'),
(439, '_cashier_tell', 'Cashier Tell', 'number', '', '61xxxxxxx', '', '', '4', '', 0, '2022-12-23 18:45:59'),
(440, '_ticket_fee', 'Ticket Fee ($)', 'number', 'general,type,fee', '', '', 'float', '', '', 0, '2022-12-24 09:16:42'),
(441, '_commission_fee', 'Commission Fee ($)', 'number', 'general,type,fee', '', '', 'float', '', '', 0, '2022-12-23 18:46:10'),
(442, '_service_fee', 'Service Fee ($)', 'number', 'general,type,fee', '', '', 'float', '', '', 0, '2022-12-23 18:46:13'),
(443, '_hospital', 'Hospital', 'dropdown', 'hospital|', '', '', 'varchar', '', '', 0, '2023-08-10 11:15:24'),
(444, '_hospital_id', ' Hospital Id', 'autocomplete', 'hospital|', '', '', 'int', '', '', 0, '2022-12-24 09:12:34'),
(445, '_expense_id', 'Expense Type', 'dropdown', 'general,type,expense', '', '', 'int', '', '', 0, '2022-12-30 09:13:40'),
(446, '_from2', ' From2', 'date', '', '', '', 'date', '', '', 0, '2023-08-10 11:16:33');

-- --------------------------------------------------------

--
-- Table structure for table `ktc_delete_logs`
--

CREATE TABLE `ktc_delete_logs` (
  `id` int(11) NOT NULL,
  `back_up` text,
  `column_structure` text NOT NULL,
  `description` text NOT NULL,
  `user_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL DEFAULT '17',
  `table` varchar(100) NOT NULL,
  `status` int(11) NOT NULL DEFAULT '1' COMMENT '1 deleted, 0 undo',
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ktc_delete_logs`
--

INSERT INTO `ktc_delete_logs` (`id`, `back_up`, `column_structure`, `description`, `user_id`, `company_id`, `table`, `status`, `date`) VALUES
(1, NULL, 'id,auto_id,company_id,hospital_id,name,tell,image,department_id,description,ticket_fee,user_id,date,action_date,modified_date', 'd', 3, 1, 'doctor', 1, '2022-12-31 09:43:23'),
(2, NULL, 'id,auto_id,company_id,hospital_id,name,tell,image,department_id,description,ticket_fee,user_id,date,action_date,modified_date', 'd', 3, 1, 'doctor', 1, '2022-12-31 09:43:25'),
(3, NULL, 'id,auto_id,company_id,hospital_id,name,tell,image,department_id,description,ticket_fee,user_id,date,action_date,modified_date', 'j', 3, 1, 'doctor', 1, '2022-12-31 09:48:11'),
(4, NULL, 'id,auto_id,company_id,hospital_id,name,tell,image,department_id,description,ticket_fee,user_id,date,action_date,modified_date', 'f', 3, 1, 'doctor', 1, '2022-12-31 10:33:02'),
(5, NULL, 'id,auto_id,company_id,hospital_id,name,tell,image,department_id,description,ticket_fee,user_id,date,action_date,modified_date', 'f', 3, 1, 'doctor', 1, '2022-12-31 10:44:02'),
(6, '178,178,1,Burco manhal mental hospital,634438916,634438916,Wuxuu ka yala Xafada tuurta ee galbedka burco wuxuna leyahay xeryn,Burco,Somaliland,85000,5000,8500,$,,0,,,5,2023-01-16,2023-01-16 13:31:46,2023-01-16 13:31:46', 'id,auto_id,company_id,name,tell,cashier_tell,address,city,region,ticket_fee,commission_fee,service_fee,currency,free_days,logo,manager,contract_file,user_id,date,action_date,modified_date', '1', 5, 1, 'hospital', 1, '2023-04-01 10:21:40'),
(7, NULL, 'id,auto_id,company_id,name,tell,cashier_tell,address,city,region,ticket_fee,commission_fee,service_fee,currency,free_days,logo,manager,contract_file,user_id,date,action_date,modified_date', '1', 5, 1, 'hospital', 1, '2023-04-01 10:21:57'),
(8, NULL, 'id,auto_id,company_id,name,tell,cashier_tell,address,city,region,ticket_fee,commission_fee,service_fee,currency,free_days,logo,manager,contract_file,user_id,date,action_date,modified_date', '1', 5, 1, 'hospital', 1, '2023-04-01 10:22:24'),
(9, '161,161,1,Burco manhal mental center,634438916,0,Wuxu ku yala Xafada tuurta ee galbedka burco wuxuna leyahay xerayn,Burco,Somaliland,85000,0,3,SL,,uploads/IMG-20221106-WA0000.jpg,,,2,2022-11-06,2022-12-24 03:43:32,2023-01-07 09:35:52', 'id,auto_id,company_id,name,tell,cashier_tell,address,city,region,ticket_fee,commission_fee,service_fee,currency,free_days,logo,manager,contract_file,user_id,date,action_date,modified_date', '1', 5, 1, 'hospital', 1, '2023-04-01 15:54:06'),
(10, NULL, 'id,auto_id,company_id,name,tell,cashier_tell,address,city,region,ticket_fee,commission_fee,service_fee,currency,free_days,logo,manager,contract_file,user_id,date,action_date,modified_date', '1', 5, 1, 'hospital', 1, '2023-04-01 15:54:16'),
(11, NULL, 'id,auto_id,company_id,hospital_id,name,tell,image,department_id,description,ticket_fee,user_id,date,action_date,modified_date', '1', 5, 1, 'doctor', 1, '2023-04-02 07:18:38'),
(12, NULL, 'id,auto_id,company_id,hospital_id,name,tell,image,department_id,description,ticket_fee,user_id,date,action_date,modified_date', '1', 5, 1, 'doctor', 1, '2023-04-02 07:18:39'),
(13, NULL, 'id,auto_id,company_id,hospital_id,name,tell,image,department_id,description,ticket_fee,user_id,date,action_date,modified_date', '1', 5, 1, 'doctor', 1, '2023-04-02 07:18:49'),
(14, NULL, 'id,auto_id,company_id,hospital_id,name,tell,image,department_id,description,ticket_fee,user_id,date,action_date,modified_date', '1', 5, 1, 'doctor', 1, '2023-04-02 07:18:50'),
(15, '160,160,1,Hargeysa neriology hospital,634128844,0,Wuxu uu dhowyahay jamacad hargeysa ee pepsi,Hargeysa,Somaliland,103000,0,9000,SL,,uploads/FB_IMG_1667202538160.jpg,,,2,2022-11-02,2022-12-24 03:43:32,2023-04-01 19:32:32', 'id,auto_id,company_id,name,tell,cashier_tell,address,city,region,ticket_fee,commission_fee,service_fee,currency,free_days,logo,manager,contract_file,user_id,date,action_date,modified_date', '1', 5, 1, 'hospital', 1, '2023-04-02 08:24:57'),
(16, '177,177,1,Needle hospital and pathology,634662044,636666645,Wuxuu ka so horjeeda masajidka shiikh baashiir,Hargeysa,Somaliland,133000,5000,8500,$,,0,,,5,2023-01-16,2023-01-16 13:15:43,2023-01-16 13:15:43', 'id,auto_id,company_id,name,tell,cashier_tell,address,city,region,ticket_fee,commission_fee,service_fee,currency,free_days,logo,manager,contract_file,user_id,date,action_date,modified_date', '1', 5, 1, 'hospital', 1, '2023-04-02 15:51:11'),
(17, NULL, 'id,auto_id,company_id,name,tell,cashier_tell,address,city,region,ticket_fee,commission_fee,service_fee,currency,free_days,logo,manager,contract_file,user_id,date,action_date,modified_date', '1', 5, 1, 'hospital', 1, '2023-04-02 15:51:17'),
(18, '176,176,1,Needle hospital,634432380,0,Wuxuu ka soo horjeeda masajidka shiikh bashir iyo samecable,Hargeysa,Somaliland,85000,0,3,SL,,uploads/IMG-20221218-WA0014.jpg,,,2,2022-12-18,2022-12-24 03:43:32,2023-01-07 09:35:52', 'id,auto_id,company_id,name,tell,cashier_tell,address,city,region,ticket_fee,commission_fee,service_fee,currency,free_days,logo,manager,contract_file,user_id,date,action_date,modified_date', '1', 5, 1, 'hospital', 1, '2023-04-02 15:52:02'),
(19, NULL, 'id,auto_id,company_id,name,tell,cashier_tell,address,city,region,ticket_fee,commission_fee,service_fee,currency,free_days,logo,manager,contract_file,user_id,date,action_date,modified_date', '1', 5, 1, 'hospital', 1, '2023-04-02 15:52:02'),
(20, NULL, 'id,auto_id,company_id,name,tell,cashier_tell,address,city,region,ticket_fee,commission_fee,service_fee,currency,free_days,logo,manager,contract_file,user_id,date,action_date,modified_date', '1', 5, 1, 'hospital', 1, '2023-04-02 15:52:04'),
(21, NULL, 'id,auto_id,company_id,name,tell,cashier_tell,address,city,region,ticket_fee,commission_fee,service_fee,currency,free_days,logo,manager,contract_file,user_id,date,action_date,modified_date', '1', 5, 1, 'hospital', 1, '2023-04-02 15:52:21'),
(22, NULL, 'id,auto_id,company_id,hospital_id,name,tell,image,department_id,description,ticket_fee,user_id,date,action_date,modified_date', '1', 5, 1, 'doctor', 1, '2023-04-03 15:44:15'),
(23, NULL, 'id,auto_id,company_id,hospital_id,name,tell,image,department_id,description,ticket_fee,user_id,date,action_date,modified_date', '1', 5, 1, 'doctor', 1, '2023-04-03 15:45:12'),
(24, '174,174,1,Horyal hospital,634820301,0,Wuxuu ku yala burco garahan Xafada hodan qaylo 15 may,Burco,Somaliland,42000,0,3,SL,,uploads/IMG-20221125-WA0006.jpg,,,2,2022-12-03,2022-12-24 03:43:32,2023-01-07 09:35:52', 'id,auto_id,company_id,name,tell,cashier_tell,address,city,region,ticket_fee,commission_fee,service_fee,currency,free_days,logo,manager,contract_file,user_id,date,action_date,modified_date', '1', 5, 1, 'hospital', 1, '2023-04-14 14:46:01'),
(25, NULL, 'id,auto_id,company_id,name,tell,cashier_tell,address,city,region,ticket_fee,commission_fee,service_fee,currency,free_days,logo,manager,contract_file,user_id,date,action_date,modified_date', '1', 5, 1, 'hospital', 1, '2023-04-14 14:46:09'),
(26, '195,195,1,Horyal hospital,634820301,633936905,Wuxu ku yala xafada hodan qaylo 15 may,Burco,Somaliland,45000,0,9000,$,,0,,,5,2023-04-15,2023-04-15 04:17:37,2023-04-15 04:17:37', 'id,auto_id,company_id,name,tell,cashier_tell,address,city,region,ticket_fee,commission_fee,service_fee,currency,free_days,logo,manager,contract_file,user_id,date,action_date,modified_date', '1', 5, 1, 'hospital', 1, '2023-04-15 10:06:28'),
(27, NULL, 'id,auto_id,company_id,hospital_id,name,tell,image,department_id,description,ticket_fee,user_id,date,action_date,modified_date', '1', 5, 1, 'doctor', 1, '2023-04-24 14:28:31'),
(28, '196,195,1,Horyal hospital,634820301,633936905,Wuxuu ku yala xafada hodan qaylo 15 may,Burco,Somaliland,45000,0,9000,Shilin,,0,,,5,2023-04-15,2023-04-15 05:16:40,2023-04-15 05:37:14', 'id,auto_id,company_id,name,tell,cashier_tell,address,city,region,ticket_fee,commission_fee,service_fee,currency,free_days,logo,manager,contract_file,user_id,date,action_date,modified_date', '1', 5, 1, 'hospital', 1, '2023-04-24 16:01:58'),
(29, NULL, 'id,auto_id,company_id,name,tell,cashier_tell,address,city,region,ticket_fee,commission_fee,service_fee,currency,free_days,logo,manager,contract_file,user_id,date,action_date,modified_date', '1', 5, 1, 'hospital', 1, '2023-04-24 16:01:58'),
(30, NULL, 'id,auto_id,company_id,hospital_id,name,tell,image,department_id,description,ticket_fee,user_id,date,action_date,modified_date', '1', 5, 1, 'doctor', 1, '2023-04-24 16:29:52'),
(31, NULL, 'id,auto_id,company_id,hospital_id,name,tell,image,department_id,description,ticket_fee,user_id,date,action_date,modified_date', '1', 5, 1, 'doctor', 1, '2023-04-24 16:30:50'),
(32, NULL, 'id,auto_id,company_id,hospital_id,name,tell,image,department_id,description,ticket_fee,user_id,date,action_date,modified_date', '1', 5, 1, 'doctor', 1, '2023-04-24 16:33:07'),
(33, '180,180,1,Janaale clinic pharmacy,634603362,634603362,Waa ka so horjedka basaska calamadaha,Hargeysa,Somaliland,0,0,9000,$,,0,,,5,2023-03-08,2023-03-08 01:57:36,2023-03-08 01:57:36', 'id,auto_id,company_id,name,tell,cashier_tell,address,city,region,ticket_fee,commission_fee,service_fee,currency,free_days,logo,manager,contract_file,user_id,date,action_date,modified_date', '1', 5, 1, 'hospital', 1, '2023-04-25 14:19:12'),
(34, '179,179,1,Janaale dental pharmacy,634603362,634603362,Waa ka so horjeeda basasaka calamadaha,Hargeysa,Somaliland,0,0,9000,Shilin,,0,,,5,2023-03-08,2023-03-08 01:37:30,2023-04-22 02:23:03', 'id,auto_id,company_id,name,tell,cashier_tell,address,city,region,ticket_fee,commission_fee,service_fee,currency,free_days,logo,manager,contract_file,user_id,date,action_date,modified_date', '1', 5, 1, 'hospital', 1, '2023-04-25 14:28:31'),
(35, '198,196,1,Janaale clinic pharmacy,634603362,634603362,Waa ka soo horjeedka basaska calamadaha,Hargeysa,Somaliland,0,0,9000,$,,0,,,5,2023-04-25,2023-04-25 09:33:50,2023-04-25 09:33:50', 'id,auto_id,company_id,name,tell,cashier_tell,address,city,region,ticket_fee,commission_fee,service_fee,currency,free_days,logo,manager,contract_file,user_id,date,action_date,modified_date', '1', 5, 1, 'hospital', 1, '2023-04-25 14:54:23'),
(36, '199,196,1,Janaale clinic pharmacy,634603362,634603362,Wuxuu ka soo horjeeda basaska calamadaha,Hargeysa,Somaliland,0,0,9000,$,,0,,,5,2023-04-25,2023-04-25 09:59:28,2023-04-25 09:59:28', 'id,auto_id,company_id,name,tell,cashier_tell,address,city,region,ticket_fee,commission_fee,service_fee,currency,free_days,logo,manager,contract_file,user_id,date,action_date,modified_date', '1', 5, 1, 'hospital', 1, '2023-04-25 15:05:51'),
(37, '167,167,1,Togdheer medical center  ,634323181,0,Xafadu waa shinay lamiga agagarka masajidka tawfiq somtesha  hargeysa,Hargeysa,Somaliland,15000,0,3,SL,,uploads/IMG-20221107-WA0004(1).jpg,,,2,2022-11-09,2022-12-24 03:43:32,2023-01-07 09:35:52', 'id,auto_id,company_id,name,tell,cashier_tell,address,city,region,ticket_fee,commission_fee,service_fee,currency,free_days,logo,manager,contract_file,user_id,date,action_date,modified_date', '1', 5, 1, 'hospital', 1, '2023-04-25 15:11:06');

-- --------------------------------------------------------

--
-- Table structure for table `ktc_dropdown`
--

CREATE TABLE `ktc_dropdown` (
  `id` int(11) NOT NULL,
  `value` varchar(100) NOT NULL,
  `text` varchar(100) NOT NULL,
  `action` varchar(100) NOT NULL DEFAULT 'peroid',
  `description` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ktc_dropdown`
--

INSERT INTO `ktc_dropdown` (`id`, `value`, `text`, `action`, `description`) VALUES
(2, 'forms/create', 'KTC Vertical Form', 'href', ''),
(4, '90', 'sadaam', 'filed', ''),
(5, 'forms/list', 'KTC Horizontal Form', 'href', ''),
(6, 'forms/save', 'Insert Page', 'form', ''),
(7, 'forms/report', 'Data-table Report', 'form', ''),
(8, 'ktc_dropdown', 'Edit Dropdown', 'edit', 'developer'),
(9, 'ktc_link', 'Form Edit', 'edit', 'developer'),
(10, 'ktc_chart', 'Edit Chart', 'edit', 'developer'),
(11, 'ktc_chart', 'Delete Chart', 'delete', 'developer'),
(12, 'ktc_user_permission', 'Delete User Permission', 'delete', 'developer'),
(13, 'ktc_common_param', 'delete common par', 'delete', 'developer'),
(14, 'ktc_common_param', 'edit common par', 'edit', 'developer'),
(15, 'ktc_link', 'Delete Form', 'delete', 'developer'),
(16, 'fa fa-glass', 'fa fa-glass', 'icon', ''),
(17, 'fa fa-music', 'fa fa-music', 'icon', ''),
(18, 'fa fa-search', 'fa fa-search', 'icon', ''),
(19, 'fa fa-envelope-o', 'fa fa-envelope-o', 'icon', ''),
(20, 'fa fa-heart', 'fa fa-heart', 'icon', ''),
(21, 'fa fa-star', 'fa fa-star', 'icon', ''),
(22, 'fa fa-star-o', 'fa fa-star-o', 'icon', ''),
(23, 'fa fa-user', 'fa fa-user', 'icon', ''),
(24, 'fa fa-film', 'fa fa-film', 'icon', ''),
(25, 'fa fa-th-large', 'fa fa-th-large', 'icon', ''),
(26, 'fa fa-th', 'fa fa-th', 'icon', ''),
(27, 'fa fa-th-list', 'fa fa-th-list', 'icon', ''),
(28, 'fa fa-check', 'fa fa-check', 'icon', ''),
(29, 'fa fa-times', 'fa fa-times', 'icon', ''),
(30, 'fa fa-search-plus', 'fa fa-search-plus', 'icon', ''),
(31, 'fa fa-search-minus', 'fa fa-search-minus', 'icon', ''),
(32, 'fa fa-power-off', 'fa fa-power-off', 'icon', ''),
(33, 'fa fa-signal', 'fa fa-signal', 'icon', ''),
(34, 'fa fa-cog', 'fa fa-cog', 'icon', ''),
(35, 'fa fa-trash-o', 'fa fa-trash-o', 'icon', ''),
(36, 'fa fa-home', 'fa fa-home', 'icon', ''),
(37, 'fa fa-file-o', 'fa fa-file-o', 'icon', ''),
(38, 'fa fa-clock-o', 'fa fa-clock-o', 'icon', ''),
(39, 'fa fa-road', 'fa fa-road', 'icon', ''),
(40, 'fa fa-download', 'fa fa-download', 'icon', ''),
(41, 'fa fa-arrow-circle-o-down', 'fa fa-arrow-circle-o-down', 'icon', ''),
(42, 'fa fa-arrow-circle-o-up', 'fa fa-arrow-circle-o-up', 'icon', ''),
(43, 'fa fa-inbox', 'fa fa-inbox', 'icon', ''),
(44, 'fa fa-play-circle-o', 'fa fa-play-circle-o', 'icon', ''),
(45, 'fa fa-repeat', 'fa fa-repeat', 'icon', ''),
(46, 'fa fa-refresh', 'fa fa-refresh', 'icon', ''),
(47, 'fa fa-list-alt', 'fa fa-list-alt', 'icon', ''),
(48, 'fa fa-lock', 'fa fa-lock', 'icon', ''),
(49, 'fa fa-flag', 'fa fa-flag', 'icon', ''),
(50, 'fa fa-headphones', 'fa fa-headphones', 'icon', ''),
(51, 'fa fa-volume-off', 'fa fa-volume-off', 'icon', ''),
(52, 'fa fa-volume-down', 'fa fa-volume-down', 'icon', ''),
(53, 'fa fa-volume-up', 'fa fa-volume-up', 'icon', ''),
(54, 'fa fa-qrcode', 'fa fa-qrcode', 'icon', ''),
(55, 'fa fa-barcode', 'fa fa-barcode', 'icon', ''),
(56, 'fa fa-tag', 'fa fa-tag', 'icon', ''),
(57, 'fa fa-tags', 'fa fa-tags', 'icon', ''),
(58, 'fa fa-book', 'fa fa-book', 'icon', ''),
(59, 'fa fa-bookmark', 'fa fa-bookmark', 'icon', ''),
(60, 'fa fa-print', 'fa fa-print', 'icon', ''),
(61, 'fa fa-camera', 'fa fa-camera', 'icon', ''),
(62, 'fa fa-font', 'fa fa-font', 'icon', ''),
(63, 'fa fa-bold', 'fa fa-bold', 'icon', ''),
(64, 'fa fa-italic', 'fa fa-italic', 'icon', ''),
(65, 'fa fa-text-height', 'fa fa-text-height', 'icon', ''),
(66, 'fa fa-text-width', 'fa fa-text-width', 'icon', ''),
(67, 'fa fa-align-left', 'fa fa-align-left', 'icon', ''),
(68, 'fa fa-align-center', 'fa fa-align-center', 'icon', ''),
(69, 'fa fa-align-right', 'fa fa-align-right', 'icon', ''),
(70, 'fa fa-align-justify', 'fa fa-align-justify', 'icon', ''),
(71, 'fa fa-list', 'fa fa-list', 'icon', ''),
(72, 'fa fa-outdent', 'fa fa-outdent', 'icon', ''),
(73, 'fa fa-indent', 'fa fa-indent', 'icon', ''),
(74, 'fa fa-video-camera', 'fa fa-video-camera', 'icon', ''),
(75, 'fa fa-picture-o', 'fa fa-picture-o', 'icon', ''),
(76, 'fa fa-pencil', 'fa fa-pencil', 'icon', ''),
(77, 'fa fa-map-marker', 'fa fa-map-marker', 'icon', ''),
(78, 'fa fa-adjust', 'fa fa-adjust', 'icon', ''),
(79, 'fa fa-tint', 'fa fa-tint', 'icon', ''),
(80, 'fa fa-pencil-square-o', 'fa fa-pencil-square-o', 'icon', ''),
(81, 'fa fa-share-square-o', 'fa fa-share-square-o', 'icon', ''),
(82, 'fa fa-check-square-o', 'fa fa-check-square-o', 'icon', ''),
(83, 'fa fa-arrows', 'fa fa-arrows', 'icon', ''),
(84, 'fa fa-step-backward', 'fa fa-step-backward', 'icon', ''),
(85, 'fa fa-fast-backward', 'fa fa-fast-backward', 'icon', ''),
(86, 'fa fa-backward', 'fa fa-backward', 'icon', ''),
(87, 'fa fa-play', 'fa fa-play', 'icon', ''),
(88, 'fa fa-pause', 'fa fa-pause', 'icon', ''),
(89, 'fa fa-stop', 'fa fa-stop', 'icon', ''),
(90, 'fa fa-forward', 'fa fa-forward', 'icon', ''),
(91, 'fa fa-fast-forward', 'fa fa-fast-forward', 'icon', ''),
(92, 'fa fa-step-forward', 'fa fa-step-forward', 'icon', ''),
(93, 'fa fa-eject', 'fa fa-eject', 'icon', ''),
(94, 'fa fa-chevron-left', 'fa fa-chevron-left', 'icon', ''),
(95, 'fa fa-chevron-right', 'fa fa-chevron-right', 'icon', ''),
(96, 'fa fa-plus-circle', 'fa fa-plus-circle', 'icon', ''),
(97, 'fa fa-minus-circle', 'fa fa-minus-circle', 'icon', ''),
(98, 'fa fa-times-circle', 'fa fa-times-circle', 'icon', ''),
(99, 'fa fa-check-circle', 'fa fa-check-circle', 'icon', ''),
(100, 'fa fa-question-circle', 'fa fa-question-circle', 'icon', ''),
(101, 'fa fa-info-circle', 'fa fa-info-circle', 'icon', ''),
(102, 'fa fa-crosshairs', 'fa fa-crosshairs', 'icon', ''),
(103, 'fa fa-times-circle-o', 'fa fa-times-circle-o', 'icon', ''),
(104, 'fa fa-check-circle-o', 'fa fa-check-circle-o', 'icon', ''),
(105, 'fa fa-ban', 'fa fa-ban', 'icon', ''),
(106, 'fa fa-arrow-left', 'fa fa-arrow-left', 'icon', ''),
(107, 'fa fa-arrow-right', 'fa fa-arrow-right', 'icon', ''),
(108, 'fa fa-arrow-up', 'fa fa-arrow-up', 'icon', ''),
(109, 'fa fa-arrow-down', 'fa fa-arrow-down', 'icon', ''),
(110, 'fa fa-share', 'fa fa-share', 'icon', ''),
(111, 'fa fa-expand', 'fa fa-expand', 'icon', ''),
(112, 'fa fa-compress', 'fa fa-compress', 'icon', ''),
(113, 'fa fa-plus', 'fa fa-plus', 'icon', ''),
(114, 'fa fa-minus', 'fa fa-minus', 'icon', ''),
(115, 'fa fa-asterisk', 'fa fa-asterisk', 'icon', ''),
(116, 'fa fa-exclamation-circle', 'fa fa-exclamation-circle', 'icon', ''),
(117, 'fa fa-gift', 'fa fa-gift', 'icon', ''),
(118, 'fa fa-leaf', 'fa fa-leaf', 'icon', ''),
(119, 'fa fa-fire', 'fa fa-fire', 'icon', ''),
(120, 'fa fa-eye', 'fa fa-eye', 'icon', ''),
(121, 'fa fa-eye-slash', 'fa fa-eye-slash', 'icon', ''),
(122, 'fa fa-exclamation-triangle', 'fa fa-exclamation-triangle', 'icon', ''),
(123, 'fa fa-plane', 'fa fa-plane', 'icon', ''),
(124, 'fa fa-calendar', 'fa fa-calendar', 'icon', ''),
(125, 'fa fa-random', 'fa fa-random', 'icon', ''),
(126, 'fa fa-comment', 'fa fa-comment', 'icon', ''),
(127, 'fa fa-magnet', 'fa fa-magnet', 'icon', ''),
(128, 'fa fa-chevron-up', 'fa fa-chevron-up', 'icon', ''),
(129, 'fa fa-chevron-down', 'fa fa-chevron-down', 'icon', ''),
(130, 'fa fa-retweet', 'fa fa-retweet', 'icon', ''),
(131, 'fa fa-shopping-cart', 'fa fa-shopping-cart', 'icon', ''),
(132, 'fa fa-folder', 'fa fa-folder', 'icon', ''),
(133, 'fa fa-folder-open', 'fa fa-folder-open', 'icon', ''),
(134, 'fa fa-arrows-v', 'fa fa-arrows-v', 'icon', ''),
(135, 'fa fa-arrows-h', 'fa fa-arrows-h', 'icon', ''),
(136, 'fa fa-bar-chart', 'fa fa-bar-chart', 'icon', ''),
(137, 'fa fa-twitter-square', 'fa fa-twitter-square', 'icon', ''),
(138, 'fa fa-facebook-square', 'fa fa-facebook-square', 'icon', ''),
(139, 'fa fa-camera-retro', 'fa fa-camera-retro', 'icon', ''),
(140, 'fa fa-key', 'fa fa-key', 'icon', ''),
(141, 'fa fa-cogs', 'fa fa-cogs', 'icon', ''),
(142, 'fa fa-comments', 'fa fa-comments', 'icon', ''),
(143, 'fa fa-thumbs-o-up', 'fa fa-thumbs-o-up', 'icon', ''),
(144, 'fa fa-thumbs-o-down', 'fa fa-thumbs-o-down', 'icon', ''),
(145, 'fa fa-star-half', 'fa fa-star-half', 'icon', ''),
(146, 'fa fa-heart-o', 'fa fa-heart-o', 'icon', ''),
(147, 'fa fa-sign-out', 'fa fa-sign-out', 'icon', ''),
(148, 'fa fa-linkedin-square', 'fa fa-linkedin-square', 'icon', ''),
(149, 'fa fa-thumb-tack', 'fa fa-thumb-tack', 'icon', ''),
(150, 'fa fa-external-link', 'fa fa-external-link', 'icon', ''),
(151, 'fa fa-sign-in', 'fa fa-sign-in', 'icon', ''),
(152, 'fa fa-trophy', 'fa fa-trophy', 'icon', ''),
(153, 'fa fa-github-square', 'fa fa-github-square', 'icon', ''),
(154, 'fa fa-upload', 'fa fa-upload', 'icon', ''),
(155, 'fa fa-lemon-o', 'fa fa-lemon-o', 'icon', ''),
(156, 'fa fa-phone', 'fa fa-phone', 'icon', ''),
(157, 'fa fa-square-o', 'fa fa-square-o', 'icon', ''),
(158, 'fa fa-bookmark-o', 'fa fa-bookmark-o', 'icon', ''),
(159, 'fa fa-phone-square', 'fa fa-phone-square', 'icon', ''),
(160, 'fa fa-twitter', 'fa fa-twitter', 'icon', ''),
(161, 'fa fa-facebook', 'fa fa-facebook', 'icon', ''),
(162, 'fa fa-github', 'fa fa-github', 'icon', ''),
(163, 'fa fa-unlock', 'fa fa-unlock', 'icon', ''),
(164, 'fa fa-credit-card', 'fa fa-credit-card', 'icon', ''),
(165, 'fa fa-rss', 'fa fa-rss', 'icon', ''),
(166, 'fa fa-hdd-o', 'fa fa-hdd-o', 'icon', ''),
(167, 'fa fa-bullhorn', 'fa fa-bullhorn', 'icon', ''),
(168, 'fa fa-bell', 'fa fa-bell', 'icon', ''),
(169, 'fa fa-certificate', 'fa fa-certificate', 'icon', ''),
(170, 'fa fa-hand-o-right', 'fa fa-hand-o-right', 'icon', ''),
(171, 'fa fa-hand-o-left', 'fa fa-hand-o-left', 'icon', ''),
(172, 'fa fa-hand-o-up', 'fa fa-hand-o-up', 'icon', ''),
(173, 'fa fa-hand-o-down', 'fa fa-hand-o-down', 'icon', ''),
(174, 'fa fa-arrow-circle-left', 'fa fa-arrow-circle-left', 'icon', ''),
(175, 'fa fa-arrow-circle-right', 'fa fa-arrow-circle-right', 'icon', ''),
(176, 'fa fa-arrow-circle-up', 'fa fa-arrow-circle-up', 'icon', ''),
(177, 'fa fa-arrow-circle-down', 'fa fa-arrow-circle-down', 'icon', ''),
(178, 'fa fa-globe', 'fa fa-globe', 'icon', ''),
(179, 'fa fa-wrench', 'fa fa-wrench', 'icon', ''),
(180, 'fa fa-tasks', 'fa fa-tasks', 'icon', ''),
(181, 'fa fa-filter', 'fa fa-filter', 'icon', ''),
(182, 'fa fa-briefcase', 'fa fa-briefcase', 'icon', ''),
(183, 'fa fa-arrows-alt', 'fa fa-arrows-alt', 'icon', ''),
(184, 'fa fa-users', 'fa fa-users', 'icon', ''),
(185, 'fa fa-link', 'fa fa-link', 'icon', ''),
(186, 'fa fa-cloud', 'fa fa-cloud', 'icon', ''),
(187, 'fa fa-flask', 'fa fa-flask', 'icon', ''),
(188, 'fa fa-scissors', 'fa fa-scissors', 'icon', ''),
(189, 'fa fa-files-o', 'fa fa-files-o', 'icon', ''),
(190, 'fa fa-paperclip', 'fa fa-paperclip', 'icon', ''),
(191, 'fa fa-floppy-o', 'fa fa-floppy-o', 'icon', ''),
(192, 'fa fa-square', 'fa fa-square', 'icon', ''),
(193, 'fa fa-bars', 'fa fa-bars', 'icon', ''),
(194, 'fa fa-list-ul', 'fa fa-list-ul', 'icon', ''),
(195, 'fa fa-list-ol', 'fa fa-list-ol', 'icon', ''),
(196, 'fa fa-strikethrough', 'fa fa-strikethrough', 'icon', ''),
(197, 'fa fa-underline', 'fa fa-underline', 'icon', ''),
(198, 'fa fa-table', 'fa fa-table', 'icon', ''),
(199, 'fa fa-magic', 'fa fa-magic', 'icon', ''),
(200, 'fa fa-truck', 'fa fa-truck', 'icon', ''),
(201, 'fa fa-pinterest', 'fa fa-pinterest', 'icon', ''),
(202, 'fa fa-pinterest-square', 'fa fa-pinterest-square', 'icon', ''),
(203, 'fa fa-google-plus-square', 'fa fa-google-plus-square', 'icon', ''),
(204, 'fa fa-google-plus', 'fa fa-google-plus', 'icon', ''),
(205, 'fa fa-money', 'fa fa-money', 'icon', ''),
(206, 'fa fa-caret-down', 'fa fa-caret-down', 'icon', ''),
(207, 'fa fa-caret-up', 'fa fa-caret-up', 'icon', ''),
(208, 'fa fa-caret-left', 'fa fa-caret-left', 'icon', ''),
(209, 'fa fa-caret-right', 'fa fa-caret-right', 'icon', ''),
(210, 'fa fa-columns', 'fa fa-columns', 'icon', ''),
(211, 'fa fa-sort', 'fa fa-sort', 'icon', ''),
(212, 'fa fa-sort-desc', 'fa fa-sort-desc', 'icon', ''),
(213, 'fa fa-sort-asc', 'fa fa-sort-asc', 'icon', ''),
(214, 'fa fa-envelope', 'fa fa-envelope', 'icon', ''),
(215, 'fa fa-linkedin', 'fa fa-linkedin', 'icon', ''),
(216, 'fa fa-undo', 'fa fa-undo', 'icon', ''),
(217, 'fa fa-gavel', 'fa fa-gavel', 'icon', ''),
(218, 'fa fa-tachometer', 'fa fa-tachometer', 'icon', ''),
(219, 'fa fa-comment-o', 'fa fa-comment-o', 'icon', ''),
(220, 'fa fa-comments-o', 'fa fa-comments-o', 'icon', ''),
(221, 'fa fa-bolt', 'fa fa-bolt', 'icon', ''),
(222, 'fa fa-sitemap', 'fa fa-sitemap', 'icon', ''),
(223, 'fa fa-umbrella', 'fa fa-umbrella', 'icon', ''),
(224, 'fa fa-clipboard', 'fa fa-clipboard', 'icon', ''),
(225, 'fa fa-lightbulb-o', 'fa fa-lightbulb-o', 'icon', ''),
(226, 'fa fa-exchange', 'fa fa-exchange', 'icon', ''),
(227, 'fa fa-cloud-download', 'fa fa-cloud-download', 'icon', ''),
(228, 'fa fa-cloud-upload', 'fa fa-cloud-upload', 'icon', ''),
(229, 'fa fa-user-md', 'fa fa-user-md', 'icon', ''),
(230, 'fa fa-stethoscope', 'fa fa-stethoscope', 'icon', ''),
(231, 'fa fa-suitcase', 'fa fa-suitcase', 'icon', ''),
(232, 'fa fa-bell-o', 'fa fa-bell-o', 'icon', ''),
(233, 'fa fa-coffee', 'fa fa-coffee', 'icon', ''),
(234, 'fa fa-cutlery', 'fa fa-cutlery', 'icon', ''),
(235, 'fa fa-file-text-o', 'fa fa-file-text-o', 'icon', ''),
(236, 'fa fa-building-o', 'fa fa-building-o', 'icon', ''),
(237, 'fa fa-hospital-o', 'fa fa-hospital-o', 'icon', ''),
(238, 'fa fa-ambulance', 'fa fa-ambulance', 'icon', ''),
(239, 'fa fa-medkit', 'fa fa-medkit', 'icon', ''),
(240, 'fa fa-fighter-jet', 'fa fa-fighter-jet', 'icon', ''),
(241, 'fa fa-beer', 'fa fa-beer', 'icon', ''),
(242, 'fa fa-h-square', 'fa fa-h-square', 'icon', ''),
(243, 'fa fa-plus-square', 'fa fa-plus-square', 'icon', ''),
(244, 'fa fa-angle-double-left', 'fa fa-angle-double-left', 'icon', ''),
(245, 'fa fa-angle-double-right', 'fa fa-angle-double-right', 'icon', ''),
(246, 'fa fa-angle-double-up', 'fa fa-angle-double-up', 'icon', ''),
(247, 'fa fa-angle-double-down', 'fa fa-angle-double-down', 'icon', ''),
(248, 'fa fa-angle-left', 'fa fa-angle-left', 'icon', ''),
(249, 'fa fa-angle-right', 'fa fa-angle-right', 'icon', ''),
(250, 'fa fa-angle-up', 'fa fa-angle-up', 'icon', ''),
(251, 'fa fa-angle-down', 'fa fa-angle-down', 'icon', ''),
(252, 'fa fa-desktop', 'fa fa-desktop', 'icon', ''),
(253, 'fa fa-laptop', 'fa fa-laptop', 'icon', ''),
(254, 'fa fa-tablet', 'fa fa-tablet', 'icon', ''),
(255, 'fa fa-mobile', 'fa fa-mobile', 'icon', ''),
(256, 'fa fa-circle-o', 'fa fa-circle-o', 'icon', ''),
(257, 'fa fa-quote-left', 'fa fa-quote-left', 'icon', ''),
(258, 'fa fa-quote-right', 'fa fa-quote-right', 'icon', ''),
(259, 'fa fa-spinner', 'fa fa-spinner', 'icon', ''),
(260, 'fa fa-circle', 'fa fa-circle', 'icon', ''),
(261, 'fa fa-reply', 'fa fa-reply', 'icon', ''),
(262, 'fa fa-github-alt', 'fa fa-github-alt', 'icon', ''),
(263, 'fa fa-folder-o', 'fa fa-folder-o', 'icon', ''),
(264, 'fa fa-folder-open-o', 'fa fa-folder-open-o', 'icon', ''),
(265, 'fa fa-smile-o', 'fa fa-smile-o', 'icon', ''),
(266, 'fa fa-frown-o', 'fa fa-frown-o', 'icon', ''),
(267, 'fa fa-meh-o', 'fa fa-meh-o', 'icon', ''),
(268, 'fa fa-gamepad', 'fa fa-gamepad', 'icon', ''),
(269, 'fa fa-keyboard-o', 'fa fa-keyboard-o', 'icon', ''),
(270, 'fa fa-flag-o', 'fa fa-flag-o', 'icon', ''),
(271, 'fa fa-flag-checkered', 'fa fa-flag-checkered', 'icon', ''),
(272, 'fa fa-terminal', 'fa fa-terminal', 'icon', ''),
(273, 'fa fa-code', 'fa fa-code', 'icon', ''),
(274, 'fa fa-reply-all', 'fa fa-reply-all', 'icon', ''),
(275, 'fa fa-star-half-o', 'fa fa-star-half-o', 'icon', ''),
(276, 'fa fa-location-arrow', 'fa fa-location-arrow', 'icon', ''),
(277, 'fa fa-crop', 'fa fa-crop', 'icon', ''),
(278, 'fa fa-code-fork', 'fa fa-code-fork', 'icon', ''),
(279, 'fa fa-chain-broken', 'fa fa-chain-broken', 'icon', ''),
(280, 'fa fa-question', 'fa fa-question', 'icon', ''),
(281, 'fa fa-info', 'fa fa-info', 'icon', ''),
(282, 'fa fa-exclamation', 'fa fa-exclamation', 'icon', ''),
(283, 'fa fa-superscript', 'fa fa-superscript', 'icon', ''),
(284, 'fa fa-subscript', 'fa fa-subscript', 'icon', ''),
(285, 'fa fa-eraser', 'fa fa-eraser', 'icon', ''),
(286, 'fa fa-puzzle-piece', 'fa fa-puzzle-piece', 'icon', ''),
(287, 'fa fa-microphone', 'fa fa-microphone', 'icon', ''),
(288, 'fa fa-microphone-slash', 'fa fa-microphone-slash', 'icon', ''),
(289, 'fa fa-shield', 'fa fa-shield', 'icon', ''),
(290, 'fa fa-calendar-o', 'fa fa-calendar-o', 'icon', ''),
(291, 'fa fa-fire-extinguisher', 'fa fa-fire-extinguisher', 'icon', ''),
(292, 'fa fa-rocket', 'fa fa-rocket', 'icon', ''),
(293, 'fa fa-maxcdn', 'fa fa-maxcdn', 'icon', ''),
(294, 'fa fa-chevron-circle-left', 'fa fa-chevron-circle-left', 'icon', ''),
(295, 'fa fa-chevron-circle-right', 'fa fa-chevron-circle-right', 'icon', ''),
(296, 'fa fa-chevron-circle-up', 'fa fa-chevron-circle-up', 'icon', ''),
(297, 'fa fa-chevron-circle-down', 'fa fa-chevron-circle-down', 'icon', ''),
(298, 'fa fa-html5', 'fa fa-html5', 'icon', ''),
(299, 'fa fa-css3', 'fa fa-css3', 'icon', ''),
(300, 'fa fa-anchor', 'fa fa-anchor', 'icon', ''),
(301, 'fa fa-unlock-alt', 'fa fa-unlock-alt', 'icon', ''),
(302, 'fa fa-bullseye', 'fa fa-bullseye', 'icon', ''),
(303, 'fa fa-ellipsis-h', 'fa fa-ellipsis-h', 'icon', ''),
(304, 'fa fa-ellipsis-v', 'fa fa-ellipsis-v', 'icon', ''),
(305, 'fa fa-rss-square', 'fa fa-rss-square', 'icon', ''),
(306, 'fa fa-play-circle', 'fa fa-play-circle', 'icon', ''),
(307, 'fa fa-ticket', 'fa fa-ticket', 'icon', ''),
(308, 'fa fa-minus-square', 'fa fa-minus-square', 'icon', ''),
(309, 'fa fa-minus-square-o', 'fa fa-minus-square-o', 'icon', ''),
(310, 'fa fa-level-up', 'fa fa-level-up', 'icon', ''),
(311, 'fa fa-level-down', 'fa fa-level-down', 'icon', ''),
(312, 'fa fa-check-square', 'fa fa-check-square', 'icon', ''),
(313, 'fa fa-pencil-square', 'fa fa-pencil-square', 'icon', ''),
(314, 'fa fa-external-link-square', 'fa fa-external-link-square', 'icon', ''),
(315, 'fa fa-share-square', 'fa fa-share-square', 'icon', ''),
(316, 'fa fa-compass', 'fa fa-compass', 'icon', ''),
(317, 'fa fa-caret-square-o-down', 'fa fa-caret-square-o-down', 'icon', ''),
(318, 'fa fa-caret-square-o-up', 'fa fa-caret-square-o-up', 'icon', ''),
(319, 'fa fa-caret-square-o-right', 'fa fa-caret-square-o-right', 'icon', ''),
(320, 'fa fa-eur', 'fa fa-eur', 'icon', ''),
(321, 'fa fa-gbp', 'fa fa-gbp', 'icon', ''),
(322, 'fa fa-usd', 'fa fa-usd', 'icon', ''),
(323, 'fa fa-inr', 'fa fa-inr', 'icon', ''),
(324, 'fa fa-jpy', 'fa fa-jpy', 'icon', ''),
(325, 'fa fa-rub', 'fa fa-rub', 'icon', ''),
(326, 'fa fa-krw', 'fa fa-krw', 'icon', ''),
(327, 'fa fa-btc', 'fa fa-btc', 'icon', ''),
(328, 'fa fa-file', 'fa fa-file', 'icon', ''),
(329, 'fa fa-file-text', 'fa fa-file-text', 'icon', ''),
(330, 'fa fa-sort-alpha-asc', 'fa fa-sort-alpha-asc', 'icon', ''),
(331, 'fa fa-sort-alpha-desc', 'fa fa-sort-alpha-desc', 'icon', ''),
(332, 'fa fa-sort-amount-asc', 'fa fa-sort-amount-asc', 'icon', ''),
(333, 'fa fa-sort-amount-desc', 'fa fa-sort-amount-desc', 'icon', ''),
(334, 'fa fa-sort-numeric-asc', 'fa fa-sort-numeric-asc', 'icon', ''),
(335, 'fa fa-sort-numeric-desc', 'fa fa-sort-numeric-desc', 'icon', ''),
(336, 'fa fa-thumbs-up', 'fa fa-thumbs-up', 'icon', ''),
(337, 'fa fa-thumbs-down', 'fa fa-thumbs-down', 'icon', ''),
(338, 'fa fa-youtube-square', 'fa fa-youtube-square', 'icon', ''),
(339, 'fa fa-youtube', 'fa fa-youtube', 'icon', ''),
(340, 'fa fa-xing', 'fa fa-xing', 'icon', ''),
(341, 'fa fa-xing-square', 'fa fa-xing-square', 'icon', ''),
(342, 'fa fa-youtube-play', 'fa fa-youtube-play', 'icon', ''),
(343, 'fa fa-dropbox', 'fa fa-dropbox', 'icon', ''),
(344, 'fa fa-stack-overflow', 'fa fa-stack-overflow', 'icon', ''),
(345, 'fa fa-instagram', 'fa fa-instagram', 'icon', ''),
(346, 'fa fa-flickr', 'fa fa-flickr', 'icon', ''),
(347, 'fa fa-adn', 'fa fa-adn', 'icon', ''),
(348, 'fa fa-bitbucket', 'fa fa-bitbucket', 'icon', ''),
(349, 'fa fa-bitbucket-square', 'fa fa-bitbucket-square', 'icon', ''),
(350, 'fa fa-tumblr', 'fa fa-tumblr', 'icon', ''),
(351, 'fa fa-tumblr-square', 'fa fa-tumblr-square', 'icon', ''),
(352, 'fa fa-long-arrow-down', 'fa fa-long-arrow-down', 'icon', ''),
(353, 'fa fa-long-arrow-up', 'fa fa-long-arrow-up', 'icon', ''),
(354, 'fa fa-long-arrow-left', 'fa fa-long-arrow-left', 'icon', ''),
(355, 'fa fa-long-arrow-right', 'fa fa-long-arrow-right', 'icon', ''),
(356, 'fa fa-apple', 'fa fa-apple', 'icon', ''),
(357, 'fa fa-windows', 'fa fa-windows', 'icon', ''),
(358, 'fa fa-android', 'fa fa-android', 'icon', ''),
(359, 'fa fa-linux', 'fa fa-linux', 'icon', ''),
(360, 'fa fa-dribbble', 'fa fa-dribbble', 'icon', ''),
(361, 'fa fa-skype', 'fa fa-skype', 'icon', ''),
(362, 'fa fa-foursquare', 'fa fa-foursquare', 'icon', ''),
(363, 'fa fa-trello', 'fa fa-trello', 'icon', ''),
(364, 'fa fa-female', 'fa fa-female', 'icon', ''),
(365, 'fa fa-male', 'fa fa-male', 'icon', ''),
(366, 'fa fa-gratipay', 'fa fa-gratipay', 'icon', ''),
(367, 'fa fa-sun-o', 'fa fa-sun-o', 'icon', ''),
(368, 'fa fa-moon-o', 'fa fa-moon-o', 'icon', ''),
(369, 'fa fa-archive', 'fa fa-archive', 'icon', ''),
(370, 'fa fa-bug', 'fa fa-bug', 'icon', ''),
(371, 'fa fa-vk', 'fa fa-vk', 'icon', ''),
(372, 'fa fa-weibo', 'fa fa-weibo', 'icon', ''),
(373, 'fa fa-renren', 'fa fa-renren', 'icon', ''),
(374, 'fa fa-pagelines', 'fa fa-pagelines', 'icon', ''),
(375, 'fa fa-stack-exchange', 'fa fa-stack-exchange', 'icon', ''),
(376, 'fa fa-arrow-circle-o-right', 'fa fa-arrow-circle-o-right', 'icon', ''),
(377, 'fa fa-arrow-circle-o-left', 'fa fa-arrow-circle-o-left', 'icon', ''),
(378, 'fa fa-caret-square-o-left', 'fa fa-caret-square-o-left', 'icon', ''),
(379, 'fa fa-dot-circle-o', 'fa fa-dot-circle-o', 'icon', ''),
(380, 'fa fa-wheelchair', 'fa fa-wheelchair', 'icon', ''),
(381, 'fa fa-vimeo-square', 'fa fa-vimeo-square', 'icon', ''),
(382, 'fa fa-try', 'fa fa-try', 'icon', ''),
(383, 'fa fa-plus-square-o', 'fa fa-plus-square-o', 'icon', ''),
(384, 'fa fa-space-shuttle', 'fa fa-space-shuttle', 'icon', ''),
(385, 'fa fa-slack', 'fa fa-slack', 'icon', ''),
(386, 'fa fa-envelope-square', 'fa fa-envelope-square', 'icon', ''),
(387, 'fa fa-wordpress', 'fa fa-wordpress', 'icon', ''),
(388, 'fa fa-openid', 'fa fa-openid', 'icon', ''),
(389, 'fa fa-university', 'fa fa-university', 'icon', ''),
(390, 'fa fa-graduation-cap', 'fa fa-graduation-cap', 'icon', ''),
(391, 'fa fa-yahoo', 'fa fa-yahoo', 'icon', ''),
(392, 'fa fa-google', 'fa fa-google', 'icon', ''),
(393, 'fa fa-reddit', 'fa fa-reddit', 'icon', ''),
(394, 'fa fa-reddit-square', 'fa fa-reddit-square', 'icon', ''),
(395, 'fa fa-stumbleupon-circle', 'fa fa-stumbleupon-circle', 'icon', ''),
(396, 'fa fa-stumbleupon', 'fa fa-stumbleupon', 'icon', ''),
(397, 'fa fa-delicious', 'fa fa-delicious', 'icon', ''),
(398, 'fa fa-digg', 'fa fa-digg', 'icon', ''),
(399, 'fa fa-pied-piper', 'fa fa-pied-piper', 'icon', ''),
(400, 'fa fa-pied-piper-alt', 'fa fa-pied-piper-alt', 'icon', ''),
(401, 'fa fa-drupal', 'fa fa-drupal', 'icon', ''),
(402, 'fa fa-joomla', 'fa fa-joomla', 'icon', ''),
(403, 'fa fa-language', 'fa fa-language', 'icon', ''),
(404, 'fa fa-fax', 'fa fa-fax', 'icon', ''),
(405, 'fa fa-building', 'fa fa-building', 'icon', ''),
(406, 'fa fa-child', 'fa fa-child', 'icon', ''),
(407, 'fa fa-paw', 'fa fa-paw', 'icon', ''),
(408, 'fa fa-spoon', 'fa fa-spoon', 'icon', ''),
(409, 'fa fa-cube', 'fa fa-cube', 'icon', ''),
(410, 'fa fa-cubes', 'fa fa-cubes', 'icon', ''),
(411, 'fa fa-behance', 'fa fa-behance', 'icon', ''),
(412, 'fa fa-behance-square', 'fa fa-behance-square', 'icon', ''),
(413, 'fa fa-steam', 'fa fa-steam', 'icon', ''),
(414, 'fa fa-steam-square', 'fa fa-steam-square', 'icon', ''),
(415, 'fa fa-recycle', 'fa fa-recycle', 'icon', ''),
(416, 'fa fa-car', 'fa fa-car', 'icon', ''),
(417, 'fa fa-taxi', 'fa fa-taxi', 'icon', ''),
(418, 'fa fa-tree', 'fa fa-tree', 'icon', ''),
(419, 'fa fa-spotify', 'fa fa-spotify', 'icon', ''),
(420, 'fa fa-deviantart', 'fa fa-deviantart', 'icon', ''),
(421, 'fa fa-soundcloud', 'fa fa-soundcloud', 'icon', ''),
(422, 'fa fa-database', 'fa fa-database', 'icon', ''),
(423, 'fa fa-file-pdf-o', 'fa fa-file-pdf-o', 'icon', ''),
(424, 'fa fa-file-word-o', 'fa fa-file-word-o', 'icon', ''),
(425, 'fa fa-file-excel-o', 'fa fa-file-excel-o', 'icon', ''),
(426, 'fa fa-file-powerpoint-o', 'fa fa-file-powerpoint-o', 'icon', ''),
(427, 'fa fa-file-image-o', 'fa fa-file-image-o', 'icon', ''),
(428, 'fa fa-file-archive-o', 'fa fa-file-archive-o', 'icon', ''),
(429, 'fa fa-file-audio-o', 'fa fa-file-audio-o', 'icon', ''),
(430, 'fa fa-file-video-o', 'fa fa-file-video-o', 'icon', ''),
(431, 'fa fa-file-code-o', 'fa fa-file-code-o', 'icon', ''),
(432, 'fa fa-vine', 'fa fa-vine', 'icon', ''),
(433, 'fa fa-codepen', 'fa fa-codepen', 'icon', ''),
(434, 'fa fa-jsfiddle', 'fa fa-jsfiddle', 'icon', ''),
(435, 'fa fa-life-ring', 'fa fa-life-ring', 'icon', ''),
(436, 'fa fa-circle-o-notch', 'fa fa-circle-o-notch', 'icon', ''),
(437, 'fa fa-rebel', 'fa fa-rebel', 'icon', ''),
(438, 'fa fa-empire', 'fa fa-empire', 'icon', ''),
(439, 'fa fa-git-square', 'fa fa-git-square', 'icon', ''),
(440, 'fa fa-git', 'fa fa-git', 'icon', ''),
(441, 'fa fa-hacker-news', 'fa fa-hacker-news', 'icon', ''),
(442, 'fa fa-tencent-weibo', 'fa fa-tencent-weibo', 'icon', ''),
(443, 'fa fa-qq', 'fa fa-qq', 'icon', ''),
(444, 'fa fa-weixin', 'fa fa-weixin', 'icon', ''),
(445, 'fa fa-paper-plane', 'fa fa-paper-plane', 'icon', ''),
(446, 'fa fa-paper-plane-o', 'fa fa-paper-plane-o', 'icon', ''),
(447, 'fa fa-history', 'fa fa-history', 'icon', ''),
(448, 'fa fa-circle-thin', 'fa fa-circle-thin', 'icon', ''),
(449, 'fa fa-header', 'fa fa-header', 'icon', ''),
(450, 'fa fa-paragraph', 'fa fa-paragraph', 'icon', ''),
(451, 'fa fa-sliders', 'fa fa-sliders', 'icon', ''),
(452, 'fa fa-share-alt', 'fa fa-share-alt', 'icon', ''),
(453, 'fa fa-share-alt-square', 'fa fa-share-alt-square', 'icon', ''),
(454, 'fa fa-bomb', 'fa fa-bomb', 'icon', ''),
(455, 'fa fa-futbol-o', 'fa fa-futbol-o', 'icon', ''),
(456, 'fa fa-tty', 'fa fa-tty', 'icon', ''),
(457, 'fa fa-binoculars', 'fa fa-binoculars', 'icon', ''),
(458, 'fa fa-plug', 'fa fa-plug', 'icon', ''),
(459, 'fa fa-slideshare', 'fa fa-slideshare', 'icon', ''),
(460, 'fa fa-twitch', 'fa fa-twitch', 'icon', ''),
(461, 'fa fa-yelp', 'fa fa-yelp', 'icon', ''),
(462, 'fa fa-newspaper-o', 'fa fa-newspaper-o', 'icon', ''),
(463, 'fa fa-wifi', 'fa fa-wifi', 'icon', ''),
(464, 'fa fa-calculator', 'fa fa-calculator', 'icon', ''),
(465, 'fa fa-paypal', 'fa fa-paypal', 'icon', ''),
(466, 'fa fa-google-wallet', 'fa fa-google-wallet', 'icon', ''),
(467, 'fa fa-cc-visa', 'fa fa-cc-visa', 'icon', ''),
(468, 'fa fa-cc-mastercard', 'fa fa-cc-mastercard', 'icon', ''),
(469, 'fa fa-cc-discover', 'fa fa-cc-discover', 'icon', ''),
(470, 'fa fa-cc-amex', 'fa fa-cc-amex', 'icon', ''),
(471, 'fa fa-cc-paypal', 'fa fa-cc-paypal', 'icon', ''),
(472, 'fa fa-cc-stripe', 'fa fa-cc-stripe', 'icon', ''),
(473, 'fa fa-bell-slash', 'fa fa-bell-slash', 'icon', ''),
(474, 'fa fa-bell-slash-o', 'fa fa-bell-slash-o', 'icon', ''),
(475, 'fa fa-trash', 'fa fa-trash', 'icon', ''),
(476, 'fa fa-copyright', 'fa fa-copyright', 'icon', ''),
(477, 'fa fa-at', 'fa fa-at', 'icon', ''),
(478, 'fa fa-eyedropper', 'fa fa-eyedropper', 'icon', ''),
(479, 'fa fa-paint-brush', 'fa fa-paint-brush', 'icon', ''),
(480, 'fa fa-birthday-cake', 'fa fa-birthday-cake', 'icon', ''),
(481, 'fa fa-area-chart', 'fa fa-area-chart', 'icon', ''),
(482, 'fa fa-pie-chart', 'fa fa-pie-chart', 'icon', ''),
(483, 'fa fa-line-chart', 'fa fa-line-chart', 'icon', ''),
(484, 'fa fa-lastfm', 'fa fa-lastfm', 'icon', ''),
(485, 'fa fa-lastfm-square', 'fa fa-lastfm-square', 'icon', ''),
(486, 'fa fa-toggle-off', 'fa fa-toggle-off', 'icon', ''),
(487, 'fa fa-toggle-on', 'fa fa-toggle-on', 'icon', ''),
(488, 'fa fa-bicycle', 'fa fa-bicycle', 'icon', ''),
(489, 'fa fa-bus', 'fa fa-bus', 'icon', ''),
(490, 'fa fa-ioxhost', 'fa fa-ioxhost', 'icon', ''),
(491, 'fa fa-angellist', 'fa fa-angellist', 'icon', ''),
(492, 'fa fa-cc', 'fa fa-cc', 'icon', ''),
(493, 'fa fa-ils', 'fa fa-ils', 'icon', ''),
(494, 'fa fa-meanpath', 'fa fa-meanpath', 'icon', ''),
(495, 'fa fa-buysellads', 'fa fa-buysellads', 'icon', ''),
(496, 'fa fa-connectdevelop', 'fa fa-connectdevelop', 'icon', ''),
(497, 'fa fa-dashcube', 'fa fa-dashcube', 'icon', ''),
(498, 'fa fa-forumbee', 'fa fa-forumbee', 'icon', ''),
(499, 'fa fa-leanpub', 'fa fa-leanpub', 'icon', ''),
(500, 'fa fa-sellsy', 'fa fa-sellsy', 'icon', ''),
(501, 'fa fa-shirtsinbulk', 'fa fa-shirtsinbulk', 'icon', ''),
(502, 'fa fa-simplybuilt', 'fa fa-simplybuilt', 'icon', ''),
(503, 'fa fa-skyatlas', 'fa fa-skyatlas', 'icon', ''),
(504, 'fa fa-cart-plus', 'fa fa-cart-plus', 'icon', ''),
(505, 'fa fa-cart-arrow-down', 'fa fa-cart-arrow-down', 'icon', ''),
(506, 'fa fa-diamond', 'fa fa-diamond', 'icon', ''),
(507, 'fa fa-ship', 'fa fa-ship', 'icon', ''),
(508, 'fa fa-user-secret', 'fa fa-user-secret', 'icon', ''),
(509, 'fa fa-motorcycle', 'fa fa-motorcycle', 'icon', ''),
(510, 'fa fa-street-view', 'fa fa-street-view', 'icon', ''),
(511, 'fa fa-heartbeat', 'fa fa-heartbeat', 'icon', ''),
(512, 'fa fa-venus', 'fa fa-venus', 'icon', ''),
(513, 'fa fa-mars', 'fa fa-mars', 'icon', ''),
(514, 'fa fa-mercury', 'fa fa-mercury', 'icon', ''),
(515, 'fa fa-transgender', 'fa fa-transgender', 'icon', ''),
(516, 'fa fa-transgender-alt', 'fa fa-transgender-alt', 'icon', ''),
(517, 'fa fa-venus-double', 'fa fa-venus-double', 'icon', ''),
(518, 'fa fa-mars-double', 'fa fa-mars-double', 'icon', ''),
(519, 'fa fa-venus-mars', 'fa fa-venus-mars', 'icon', ''),
(520, 'fa fa-mars-stroke', 'fa fa-mars-stroke', 'icon', ''),
(521, 'fa fa-mars-stroke-v', 'fa fa-mars-stroke-v', 'icon', ''),
(522, 'fa fa-mars-stroke-h', 'fa fa-mars-stroke-h', 'icon', ''),
(523, 'fa fa-neuter', 'fa fa-neuter', 'icon', ''),
(524, 'fa fa-genderless', 'fa fa-genderless', 'icon', ''),
(525, 'fa fa-facebook-official', 'fa fa-facebook-official', 'icon', ''),
(526, 'fa fa-pinterest-p', 'fa fa-pinterest-p', 'icon', ''),
(527, 'fa fa-whatsapp', 'fa fa-whatsapp', 'icon', ''),
(528, 'fa fa-server', 'fa fa-server', 'icon', ''),
(529, 'fa fa-user-plus', 'fa fa-user-plus', 'icon', ''),
(530, 'fa fa-user-times', 'fa fa-user-times', 'icon', ''),
(531, 'fa fa-bed', 'fa fa-bed', 'icon', ''),
(532, 'fa fa-viacoin', 'fa fa-viacoin', 'icon', ''),
(533, 'fa fa-train', 'fa fa-train', 'icon', ''),
(534, 'fa fa-subway', 'fa fa-subway', 'icon', ''),
(535, 'fa fa-medium', 'fa fa-medium', 'icon', ''),
(536, 'fa fa-y-combinator', 'fa fa-y-combinator', 'icon', ''),
(537, 'fa fa-optin-monster', 'fa fa-optin-monster', 'icon', ''),
(538, 'fa fa-opencart', 'fa fa-opencart', 'icon', ''),
(539, 'fa fa-expeditedssl', 'fa fa-expeditedssl', 'icon', ''),
(540, 'fa fa-battery-full', 'fa fa-battery-full', 'icon', ''),
(541, 'fa fa-battery-three-quarters', 'fa fa-battery-three-quarters', 'icon', ''),
(542, 'fa fa-battery-half', 'fa fa-battery-half', 'icon', ''),
(543, 'fa fa-battery-quarter', 'fa fa-battery-quarter', 'icon', ''),
(544, 'fa fa-battery-empty', 'fa fa-battery-empty', 'icon', ''),
(545, 'fa fa-mouse-pointer', 'fa fa-mouse-pointer', 'icon', ''),
(546, 'fa fa-i-cursor', 'fa fa-i-cursor', 'icon', ''),
(547, 'fa fa-object-group', 'fa fa-object-group', 'icon', ''),
(548, 'fa fa-object-ungroup', 'fa fa-object-ungroup', 'icon', ''),
(549, 'fa fa-sticky-note', 'fa fa-sticky-note', 'icon', ''),
(550, 'fa fa-sticky-note-o', 'fa fa-sticky-note-o', 'icon', ''),
(551, 'fa fa-cc-jcb', 'fa fa-cc-jcb', 'icon', ''),
(552, 'fa fa-cc-diners-club', 'fa fa-cc-diners-club', 'icon', ''),
(553, 'fa fa-clone', 'fa fa-clone', 'icon', ''),
(554, 'fa fa-balance-scale', 'fa fa-balance-scale', 'icon', ''),
(555, 'fa fa-hourglass-o', 'fa fa-hourglass-o', 'icon', ''),
(556, 'fa fa-hourglass-start', 'fa fa-hourglass-start', 'icon', ''),
(557, 'fa fa-hourglass-half', 'fa fa-hourglass-half', 'icon', ''),
(558, 'fa fa-hourglass-end', 'fa fa-hourglass-end', 'icon', ''),
(559, 'fa fa-hourglass', 'fa fa-hourglass', 'icon', ''),
(560, 'fa fa-hand-rock-o', 'fa fa-hand-rock-o', 'icon', ''),
(561, 'fa fa-hand-paper-o', 'fa fa-hand-paper-o', 'icon', ''),
(562, 'fa fa-hand-scissors-o', 'fa fa-hand-scissors-o', 'icon', ''),
(563, 'fa fa-hand-lizard-o', 'fa fa-hand-lizard-o', 'icon', ''),
(564, 'fa fa-hand-spock-o', 'fa fa-hand-spock-o', 'icon', ''),
(565, 'fa fa-hand-pointer-o', 'fa fa-hand-pointer-o', 'icon', ''),
(566, 'fa fa-hand-peace-o', 'fa fa-hand-peace-o', 'icon', ''),
(567, 'fa fa-trademark', 'fa fa-trademark', 'icon', ''),
(568, 'fa fa-registered', 'fa fa-registered', 'icon', ''),
(569, 'fa fa-creative-commons', 'fa fa-creative-commons', 'icon', ''),
(570, 'fa fa-gg', 'fa fa-gg', 'icon', ''),
(571, 'fa fa-gg-circle', 'fa fa-gg-circle', 'icon', ''),
(572, 'fa fa-tripadvisor', 'fa fa-tripadvisor', 'icon', ''),
(573, 'fa fa-odnoklassniki', 'fa fa-odnoklassniki', 'icon', ''),
(574, 'fa fa-odnoklassniki-square', 'fa fa-odnoklassniki-square', 'icon', ''),
(575, 'fa fa-get-pocket', 'fa fa-get-pocket', 'icon', ''),
(576, 'fa fa-wikipedia-w', 'fa fa-wikipedia-w', 'icon', ''),
(577, 'fa fa-safari', 'fa fa-safari', 'icon', ''),
(578, 'fa fa-chrome', 'fa fa-chrome', 'icon', ''),
(579, 'fa fa-firefox', 'fa fa-firefox', 'icon', ''),
(580, 'fa fa-opera', 'fa fa-opera', 'icon', ''),
(581, 'fa fa-internet-explorer', 'fa fa-internet-explorer', 'icon', ''),
(582, 'fa fa-television', 'fa fa-television', 'icon', ''),
(583, 'fa fa-contao', 'fa fa-contao', 'icon', ''),
(584, 'fa fa-500px', 'fa fa-500px', 'icon', ''),
(585, 'fa fa-amazon', 'fa fa-amazon', 'icon', ''),
(586, 'fa fa-calendar-plus-o', 'fa fa-calendar-plus-o', 'icon', ''),
(587, 'fa fa-calendar-minus-o', 'fa fa-calendar-minus-o', 'icon', ''),
(588, 'fa fa-calendar-times-o', 'fa fa-calendar-times-o', 'icon', ''),
(589, 'fa fa-calendar-check-o', 'fa fa-calendar-check-o', 'icon', ''),
(590, 'fa fa-industry', 'fa fa-industry', 'icon', ''),
(591, 'fa fa-map-pin', 'fa fa-map-pin', 'icon', ''),
(592, 'fa fa-map-signs', 'fa fa-map-signs', 'icon', ''),
(593, 'fa fa-map-o', 'fa fa-map-o', 'icon', ''),
(594, 'fa fa-map', 'fa fa-map', 'icon', ''),
(595, 'fa fa-commenting', 'fa fa-commenting', 'icon', ''),
(596, 'fa fa-commenting-o', 'fa fa-commenting-o', 'icon', ''),
(597, 'fa fa-houzz', 'fa fa-houzz', 'icon', ''),
(598, 'fa fa-vimeo', 'fa fa-vimeo', 'icon', ''),
(599, 'fa fa-black-tie', 'fa fa-black-tie', 'icon', ''),
(600, 'fa fa-fonticons', 'fa fa-fonticons', 'icon', ''),
(601, 'ktc_category', 'Menus Edit', 'edit', 'developer'),
(602, 'ktc_category', 'Delete Menus', 'delete', 'developer'),
(603, 'ktc_sub_category', 'Delete sub Category', 'delete', 'developer'),
(604, 'ktc_sub_category', 'sub Category Edit', 'edit', 'developer'),
(605, 'ktc_dropdown', 'Delete Dropdown', 'delete', 'developer'),
(606, 'ktc_user', 'Edit User', 'edit', 'developer'),
(607, 'menu', 'Menu', 'menu', ''),
(608, 'sub menu', 'Sub Menus', 'menu', ''),
(609, 'Male', 'Male', 'gender', ''),
(610, 'Female', 'Female', 'gender', ''),
(620, '8', 'August', 'month', ''),
(621, '9', 'September', 'month', ''),
(622, '10', 'October', 'month', ''),
(623, '11', 'November', 'month', ''),
(624, '12', 'December', 'month', ''),
(625, 'Saturday', 'Saturday', 'day', ''),
(626, 'Sunday', 'Sunday', 'day', ''),
(627, 'Monday', 'Monday', 'day', ''),
(628, 'Tuesday', 'Tuesday', 'day', ''),
(629, 'Wednesday', 'Wednesday', 'day', ''),
(630, 'Thursday', 'Thursday', 'day', ''),
(631, 'Friday', 'Friday', 'day', ''),
(634, 'Active', 'Active', 'active', ''),
(635, 'Inactive', 'Inactive', 'active', ''),
(636, 'On', 'On', 'on', ''),
(637, 'Off', 'Off', 'on', ''),
(638, 'Enable', 'Enable', 'enable', ''),
(639, 'Disable', 'Disable', 'enable', ''),
(646, 'forms/report2', 'Report No Datatable', 'form', ''),
(647, 'forms/upload', 'Upload Page', 'form', ''),
(649, 'ktc_parameter', 'Edit ktc_parameter', 'edit', 'developer'),
(655, '', 'VIP', 'ROOM', ''),
(656, '', 'General', 'ROOM', ''),
(657, '2021', '2021', 'year', ''),
(658, 'branch', 'Edit branch', 'edit', 'developer'),
(659, 'branch', 'Delete branch', 'delete', 'developer'),
(670, '1', 'Active', 'Status', ''),
(671, '0', 'Inactive', 'Status', ''),
(689, 'A-', 'A-', 'blood', ''),
(690, 'AB+', 'AB+', 'blood', ''),
(691, 'AB-', 'AB-', 'blood', ''),
(692, 'B+', 'B+', 'blood', ''),
(693, 'B-', 'B-', 'blood', ''),
(694, 'O+', 'O+', 'blood', ''),
(695, 'O-', 'O-', 'blood', ''),
(696, 'A+', 'A+', 'blood', ''),
(717, 'company', 'Edit company', 'edit', 'developer'),
(718, 'company', 'Delete company', 'delete', 'developer'),
(721, 'unknown', 'unknown', 'blood', ''),
(731, 'lab', 'lab', 'is_defoult', ''),
(732, 'room', 'room', 'is_defoult', ''),
(733, 'delivery', 'delivery', 'is_defoult', ''),
(734, 'pharmacy', 'pharmacy', 'is_defoult', ''),
(735, 'Registration', 'Registration', 'is_defoult', ''),
(742, 'Old', 'Old', 'old', ''),
(743, 'New', 'New', 'old', ''),
(744, 'sub_total', 'Sub total', 'sales_footer', ''),
(745, 'paid', 'Paid', 'sales_footer', ''),
(746, 'discount', 'Discount', 'sales_footer', ''),
(747, 'balance', 'Balance', 'sales_footer', ''),
(776, 'imigration/ktc_entry.php', 'Bulk Insert', 'form', ''),
(794, 'images', 'png,jpg,jpeg,gif', 'folder', ''),
(795, 'videos', 'mp4, mov,avi,3gp,wmv,flv,ogg', 'folder', ''),
(796, 'docs', 'doc,docx,pdf,xls,xlsx,ppt,pptx,csv', 'folder', ''),
(804, 'Pending', 'Pending', 'multi_status', ''),
(805, 'Process', 'Process', 'multi_status', ''),
(806, 'Done', 'Done', 'multi_status', ''),
(807, 'Canceled', 'Canceled', 'multi_status', ''),
(808, 'skin-black-light', 'Black Header and Light Navbar', 'theme_style', ''),
(809, 'skin-black', 'Black Header and Black Navbar', 'theme_style', ''),
(810, 'skin-blue-light', 'Blue Header and Light Navbar', 'theme_style', ''),
(811, 'skin-blue', 'Blue Header and Black Navbar', 'theme_style', ''),
(812, 'skin-green-light', 'Green Header and Light Navbar', 'theme_style', ''),
(813, 'skin-green', 'Green Header and Black Navbar', 'theme_style', ''),
(814, 'skin-purple-light', 'Purple Header and Light Navbar', 'theme_style', ''),
(815, 'skin-purple', 'Purple Header and Black Navbar', 'theme_style', ''),
(816, 'skin-red-light', 'Red Header and Light Navbar', 'theme_style', ''),
(817, 'skin-red', 'Red Header and Black Navbar', 'theme_style', ''),
(818, 'skin-yellow-light', 'Yellow Header and Light Navbar', 'theme_style', ''),
(819, 'skin-yellow', 'Yellow Header and Black Navbar', 'theme_style', ''),
(821, 'Deposit', 'Deposit', 'receipt_type', ''),
(822, 'Service', 'Service', 'receipt_type', ''),
(830, 'bg-light-green', 'Green', 'chart_bg', ''),
(831, 'bg-pink', 'Red', 'chart_bg', ''),
(833, 'bg-cyan', 'Blue', 'chart_bg', ''),
(834, 'bg-orange', 'Orange', 'chart_bg', ''),
(839, 'Aabe', 'Aabe', 'relation', ''),
(840, 'Hooyo', 'Hooyo', 'relation', ''),
(841, 'Adeer', 'Adeer', 'relation', ''),
(842, 'New', 'New', 'std_type', ''),
(843, 'Transfer', 'Transfer', 'std_type', ''),
(847, 'general', 'Delete general', 'delete', NULL),
(853, '20/21', '20/21', 'academic_year', ''),
(856, 'No Disability', 'No Disability', 'disability', ''),
(857, 'Hands', 'Hands', 'disability', ''),
(858, 'Mental', 'Mental', 'disability', ''),
(859, 'Limps (Movement)', 'Limps (Movement)', 'disability', ''),
(860, 'No Orphan', 'No Orphan', 'orphan', ''),
(861, 'No Mother', 'No Mother', 'orphan', ''),
(862, 'No Father', 'No Father', 'orphan', ''),
(863, 'Both Parent', 'Both Parent', 'orphan', ''),
(864, 'No Refugee', 'No Refugee', 'refugee', ''),
(865, 'IDP', 'IDP', 'refugee', ''),
(866, 'Refugee', 'Refugee', 'refugee', ''),
(867, 'Hearing Visual', 'Hearing Visual', 'disability', ''),
(868, 'Puntland', 'Puntland', 'state', ''),
(869, 'Jubaland', 'Jubaland', 'state', ''),
(870, 'Gift/Talented', 'Gift/Talented', 'disability', ''),
(871, 'Others', 'Others', 'disability', ''),
(872, 'Hiirshabelle', 'Hiirshabelle', 'state', ''),
(873, 'Koonfur Galbeed', 'Koonfur Galbeed', 'state', ''),
(874, 'Galmudug', 'Galmudug', 'state', ''),
(875, 'somaliland', 'somaliland', 'state', ''),
(876, 'Banaadir', 'Banaadir', 'state', ''),
(880, '1', 'January', 'month', ''),
(881, '2', 'February', 'month', ''),
(882, '3', 'March', 'month', ''),
(883, '4', 'April', 'month', ''),
(884, '5', 'May', 'month', ''),
(885, '6', 'June', 'month', ''),
(886, '7', 'July', 'month', ''),
(918, 'tf', 'True/False', 'tf_ch', ''),
(919, 'ch', 'Choice', 'tf_ch', ''),
(923, 'time table', 'Time table', 'timetable_lesson', ''),
(924, 'lesson', 'Lessons', 'timetable_lesson', ''),
(925, '2', 'batch Level', 'degree', ''),
(926, '3', 'Master Level', 'degree', ''),
(927, '1', 'Secondary Level', 'degree', ''),
(928, 'choose', 'choose', 'ques_type', ''),
(929, 'tf', 'tf', 'ques_type', ''),
(932, '4', 'PHD Level', 'degree', ''),
(935, '1', 'Allowed', 'preview', ''),
(936, '2', 'Not Allowed', 'preview', ''),
(940, 'Membership', 'Membership', 'types', ''),
(941, 'Normal', 'Normal', 'types', ''),
(946, '1', 'Somali', 'lang', 'lang'),
(947, '2', 'English', 'lang', 'lang'),
(948, '3', 'Arabi', 'lang', 'lang'),
(955, '1', 'Assignment', 'u_exam_type', ''),
(956, '2', 'Quiz', 'u_exam_type', ''),
(957, '3', 'MidTerm', 'u_exam_type', ''),
(958, '4', 'Final', 'u_exam_type', ''),
(959, '2022', '2022', 'year', ''),
(962, 'direct', 'direct', 'ques_type', ''),
(964, 'forms/update', 'Update Form', 'form', ''),
(982, 'I', 'In', 'in_out', ''),
(985, 'O', 'Out', 'in_out', ''),
(988, 'EN', 'English', 'language', ''),
(991, 'AR', 'العربية', 'language', ''),
(994, 'I', 'Entry Rule', 'rule', ''),
(997, 'O', 'Leave Rule', 'rule', ''),
(1021, 'Session 1', 'Sep - Feb', 'semester_Session', NULL),
(1024, 'Session 2', 'Mar - Aug', 'semester_session', NULL),
(1026, 'Attend', 'Attend', 'attend', ''),
(1027, 'Not attend', 'Not attend', 'attend', ''),
(1028, 'Transfer', 'Transfer', 're_course', ''),
(1029, 'Re-course', 'Re-course', 're_course', ''),
(1032, '', '', 'post', NULL),
(1033, 'about', 'about', 'post', NULL),
(1034, 'call_to_action', 'call_to_action', 'post', NULL),
(1035, 'departments', 'departments', 'post', NULL),
(1036, 'events', 'events', 'post', NULL),
(1037, 'facts', 'facts', 'post', NULL),
(1038, 'google_map', 'google_map', 'post', NULL),
(1039, 'news', 'news', 'post', NULL),
(1040, 'partners', 'partners', 'post', NULL),
(1041, 'slider', 'slider', 'post', NULL),
(1042, 'testimonial', 'testimonial', 'post', NULL),
(1043, 'vision_mission', 'vision_mission', 'post', NULL),
(1049, 'chancellor_message', 'chancellor_message', 'post', ''),
(1052, 'mobile', 'By Mobile', 'auto_rec', ''),
(1053, 'std_id', 'By Student ID', 'auto_rec', ''),
(1054, 'ref', 'By Reference', 'auto_rec', ''),
(1055, '1', 'Submited', 'attend_submit', ''),
(1056, '0', 'Not Submited', 'attend_submit', ''),
(1057, 'No entry', 'No entry', 'attend_submit', ''),
(1063, 'no entry summary', 'No entry summary', 'attend_submit', ''),
(1071, '2', 'Graduated', 'Status', ''),
(1072, 'Transfer', 'Transfer', 'New_Transfer', ''),
(1073, 'New', 'New', 'New_Transfer', ''),
(1078, '>=', '>=', 'operator', ''),
(1079, '<=', '<=', 'operator', ''),
(1080, 'Monthly', 'Monthly', 'typ', ''),
(1081, 'Scholarship', 'Scholarship', 'typ', ''),
(1082, 'Full Scholarship', 'Full Scholarship', 'typ', ''),
(1083, 'Semester', 'Semester', 'typ', ''),
(1092, 'student_charge', 'Cancel student_charge', 'cancel', NULL),
(1093, 'student_receipt', 'Cancel student_receipt', 'cancel', NULL),
(1096, 'User', 'User', 'action', ''),
(1097, 'Bank', 'Bank', 'action', ''),
(1098, 'Fee', 'Fee', 'action', ''),
(1099, 'Amount', 'Amount', 'other_charge', ''),
(1100, 'Rate', 'Rate', 'other_charge', ''),
(1101, 'developer', 'developer', 'user_level', ''),
(1102, 'user', 'user', 'user_level', ''),
(1103, 'anyuser', 'anyuser', 'user_level', ''),
(1104, 'teacher', 'teacher', 'user_level', ''),
(1120, 'Banadir', 'Banadir', 'region', ''),
(1121, 'Somaliland', 'Somaliland', 'region', ''),
(1122, 'Puntland', 'Puntland', 'region', ''),
(1123, 'Konfur Galbed', 'Konfur Galbed', 'region', ''),
(1124, 'Jubaland', 'Jubaland', 'region', ''),
(1125, 'Galmudug', 'Galmudug', 'region', ''),
(1126, 'hospital', 'Edit hospital', 'edit', NULL),
(1127, 'hospital', 'Delete hospital', 'delete', NULL),
(1128, 'doctor', 'Edit doctor', 'edit', NULL),
(1129, 'doctor', 'Delete doctor', 'delete', NULL),
(1130, 'department', 'Edit department', 'edit', NULL),
(1131, 'department', 'Delete department', 'delete', NULL),
(1132, 'patient', 'Edit patient', 'edit', NULL),
(1133, 'patient', 'Delete patient', 'delete', NULL),
(1134, 'ticket', 'Edit ticket', 'edit', NULL),
(1135, 'ticket', 'Delete ticket', 'delete', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `ktc_edit_logs`
--

CREATE TABLE `ktc_edit_logs` (
  `id` int(11) NOT NULL,
  `tran_id` varchar(50) NOT NULL,
  `table` varchar(100) NOT NULL,
  `col` varchar(100) NOT NULL,
  `set_col` varchar(50) NOT NULL,
  `val` text NOT NULL,
  `old_value` text NOT NULL,
  `description` varchar(250) NOT NULL,
  `status` int(11) NOT NULL DEFAULT '1',
  `accepted_user_id` int(11) NOT NULL DEFAULT '0',
  `user_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL DEFAULT '17',
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ktc_edit_logs`
--

INSERT INTO `ktc_edit_logs` (`id`, `tran_id`, `table`, `col`, `set_col`, `val`, `old_value`, `description`, `status`, `accepted_user_id`, `user_id`, `company_id`, `date`) VALUES
(1, '1', 'company', 'id', 'logo', 'uploads/bulshotechapps_ktceditsp_20221222034928.png', 'uploads/universityofsomalia(uniso)_ktceditsp_20220711082845.jpg', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-22 09:49:28'),
(2, '1', 'company', 'id', 'Tell', '614945025,614945026,614945027', '252612897776', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-22 09:50:02'),
(3, '1449', 'ktc_link', 'id', 'name', 'New Doctor', 'Doctor', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:32:37'),
(4, '1449', 'ktc_link', 'id', 'title', 'New Doctor', 'Doctor', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:32:42'),
(5, '1448', 'ktc_link', 'id', 'name', 'New Department', 'Department', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:32:50'),
(6, '1448', 'ktc_link', 'id', 'title', 'New Department', 'Department', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:34:19'),
(7, '19773', 'ktc_parameter', 'id', 'type', 'docs', 'file', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:44:31'),
(8, '19774', 'ktc_parameter', 'id', 'lable', 'Description', ' Ip', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:44:41'),
(9, '19774', 'ktc_parameter', 'id', 'type', 'Varchar', 'ip', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:44:52'),
(10, '19774', 'ktc_parameter', 'id', 'is_required', '', 'required', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:45:30'),
(11, '19773', 'ktc_parameter', 'id', 'type', 'file', 'docs', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:45:40'),
(12, '19773', 'ktc_parameter', 'id', 'action', 'docs', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:45:46'),
(13, '19773', 'ktc_parameter', 'id', 'action', 'image', 'docs', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:46:10'),
(14, '19782', 'ktc_parameter', 'id', 'action', 'docs', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:47:04'),
(15, '19794', 'ktc_parameter', 'id', 'type', 'varchar', 'autocomplete', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:48:04'),
(16, '19794', 'ktc_parameter', 'id', 'lable', 'Patient Name', 'Student Name', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:48:46'),
(17, '19794', 'ktc_parameter', 'id', 'type', 'varchar', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:48:51'),
(18, '19794', 'ktc_parameter', 'id', 'type', 'varchar', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:48:52'),
(19, '19794', 'ktc_parameter', 'id', 'type', 'varchar', 'varchar', 'null', 1, 0, 3, 1, '2022-12-22 17:48:53'),
(20, '19794', 'ktc_parameter', 'id', 'type', 'varchar', 'varchar', 'null', 1, 0, 3, 1, '2022-12-22 17:48:54'),
(21, '19794', 'ktc_parameter', 'id', 'type', 'varchar', 'varchar', 'null', 1, 0, 3, 1, '2022-12-22 17:48:55'),
(22, '19794', 'ktc_parameter', 'id', 'type', 'varchar', 'varchar', 'null', 1, 0, 3, 1, '2022-12-22 17:48:56'),
(23, '19794', 'ktc_parameter', 'id', 'type', 'varchar', 'varchar', 'null', 1, 0, 3, 1, '2022-12-22 17:49:10'),
(24, '19794', 'ktc_parameter', 'id', 'lable', 'HName', 'Patient Name', 'null', 1, 0, 3, 1, '2022-12-22 17:49:56'),
(25, '19794', 'ktc_parameter', 'id', 'lable', 'HospitalName', 'HName', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:52:09'),
(26, '19794', 'ktc_parameter', 'id', 'placeholder', 'Hospital Name', 'Student Name', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:52:18'),
(27, '19795', 'ktc_parameter', 'id', 'lable', 'HospitalTell', 'Student Tell', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:52:37'),
(28, '19796', 'ktc_parameter', 'id', 'lable', 'Cashier Tell', 'Student Tell', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:52:59'),
(29, '19799', 'ktc_parameter', 'id', 'lable', 'Region', '_region', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:53:18'),
(30, '19799', 'ktc_parameter', 'id', 'type', 'varchar', 'Element Type', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:53:28'),
(31, '19798', 'ktc_parameter', 'id', 'type', 'city', 'city', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:53:35'),
(32, '19799', 'ktc_parameter', 'id', 'type', 'varchar', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:53:35'),
(33, '19799', 'ktc_parameter', 'id', 'type', 'varchar', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:53:44'),
(34, '19798', 'ktc_parameter', 'id', 'type', 'varchar', 'city', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:53:45'),
(35, '19797', 'ktc_parameter', 'id', 'type', 'varchar', 'text', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:53:48'),
(36, '19796', 'ktc_parameter', 'id', 'type', 'varchar', 'text', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:53:55'),
(37, '19795', 'ktc_parameter', 'id', 'type', 'varchar', 'text', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:53:57'),
(38, '19795', 'ktc_parameter', 'id', 'lable', 'HospitalTell', 'HospitalTell', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:53:59'),
(39, '19795', 'ktc_parameter', 'id', 'lable', 'HospitalTell', 'HospitalTell', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:53:59'),
(40, '19795', 'ktc_parameter', 'id', 'lable', 'HospitalTell', 'HospitalTell', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:54:03'),
(41, '19795', 'ktc_parameter', 'id', 'lable', 'HospitalTell', 'HospitalTell', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:54:04'),
(42, '19795', 'ktc_parameter', 'id', 'type', 'varchar', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:54:04'),
(43, '19795', 'ktc_parameter', 'id', 'type', 'varchar', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:54:05'),
(44, '19795', 'ktc_parameter', 'id', 'type', 'varchar', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:54:05'),
(45, '19795', 'ktc_parameter', 'id', 'type', 'varchar', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:54:06'),
(46, '19795', 'ktc_parameter', 'id', 'type', 'varchar', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:54:06'),
(47, '19795', 'ktc_parameter', 'id', 'type', 'varchar', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:54:06'),
(48, '19795', 'ktc_parameter', 'id', 'type', 'varchar', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:54:06'),
(49, '19795', 'ktc_parameter', 'id', 'type', 'varchar', 'varchar', 'null', 1, 0, 3, 1, '2022-12-22 17:54:09'),
(50, '19795', 'ktc_parameter', 'id', 'lable', 'Hospital Tell', 'HospitalTell', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:56:33'),
(51, '19795', 'ktc_parameter', 'id', 'type', 'int', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:56:38'),
(52, '19796', 'ktc_parameter', 'id', 'type', 'int', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:56:44'),
(53, '19800', 'ktc_parameter', 'id', 'lable', 'Ticket Fee ($)', 'Fee ($)', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:57:08'),
(54, '19801', 'ktc_parameter', 'id', 'lable', 'Commission Fee ($)', 'Fee ($)', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:57:26'),
(55, '19800', 'ktc_parameter', 'id', 'placeholder', '9', '9', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:57:37'),
(56, '19802', 'ktc_parameter', 'id', 'lable', 'Service Fee ($)', 'Fee ($)', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:57:52'),
(57, '19803', 'ktc_parameter', 'id', 'action', 'image', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 17:58:09'),
(58, '19809', 'ktc_parameter', 'id', 'type', 'varchar', 'autocomplete', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 18:00:19'),
(59, '19811', 'ktc_parameter', 'id', 'type', 'varchar', 'dropdown', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 18:00:29'),
(60, '19817', 'ktc_parameter', 'id', 'type', 'int', 'text', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 18:02:09'),
(61, '19819', 'ktc_parameter', 'id', 'lable', 'Dob', '_dob', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 18:02:17'),
(62, '19820', 'ktc_parameter', 'id', 'lable', 'Mother', '_mother', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 18:02:25'),
(63, '19819', 'ktc_parameter', 'id', 'lable', 'Dob', 'Dob', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 18:02:26'),
(64, '19819', 'ktc_parameter', 'id', 'lable', 'Dob', 'Dob', 'null', 1, 0, 3, 1, '2022-12-22 18:02:28'),
(65, '19819', 'ktc_parameter', 'id', 'lable', 'Dob', 'Dob', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 18:02:29'),
(66, '19819', 'ktc_parameter', 'id', 'lable', 'Dob', 'Dob', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 18:02:30'),
(67, '19819', 'ktc_parameter', 'id', 'lable', 'Dob', 'Dob', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 18:02:30'),
(68, '19819', 'ktc_parameter', 'id', 'lable', 'Dob', 'Dob', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 18:02:30'),
(69, '19819', 'ktc_parameter', 'id', 'lable', 'Dob', 'Dob', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 18:02:31'),
(70, '19819', 'ktc_parameter', 'id', 'lable', 'Dob', 'Dob', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 18:02:31'),
(71, '19819', 'ktc_parameter', 'id', 'lable', 'Dob', 'Dob', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 18:02:31'),
(72, '19819', 'ktc_parameter', 'id', 'lable', 'Dob', 'Dob', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 18:02:31'),
(73, '19819', 'ktc_parameter', 'id', 'lable', 'Dob', 'Dob', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 18:02:31'),
(74, '19819', 'ktc_parameter', 'id', 'lable', 'Dob', 'Dob', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 18:02:31'),
(75, '19819', 'ktc_parameter', 'id', 'lable', 'Dob', 'Dob', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 18:02:31'),
(76, '19819', 'ktc_parameter', 'id', 'lable', 'Dob', 'Dob', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 18:02:32'),
(77, '19819', 'ktc_parameter', 'id', 'lable', 'Dob', 'Dob', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 18:02:32'),
(78, '19819', 'ktc_parameter', 'id', 'lable', 'Dob', 'Dob', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 18:02:32'),
(79, '19819', 'ktc_parameter', 'id', 'lable', 'Dob', 'Dob', 'null', 1, 0, 3, 1, '2022-12-22 18:02:40'),
(80, '19819', 'ktc_parameter', 'id', 'lable', 'Dob', 'Dob', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 18:02:41'),
(81, '19819', 'ktc_parameter', 'id', 'lable', 'Dob', 'Dob', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 18:02:42'),
(82, '19821', 'ktc_parameter', 'id', 'lable', 'Description', ' Ip', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 18:02:56'),
(83, '19821', 'ktc_parameter', 'id', 'type', 'varchar', 'ip', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-22 18:03:04'),
(84, '19772', 'ktc_parameter', 'id', 'lable', 'Department Name', 'Student Name', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 12:50:26'),
(85, '19780', 'ktc_parameter', 'id', 'lable', 'Doctor Name', 'Student Name', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 12:52:43'),
(86, '19781', 'ktc_parameter', 'id', 'lable', 'Doctor Tell', 'Student Tell', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 12:52:52'),
(87, '19784', 'ktc_parameter', 'id', 'type', 'int', 'dropdown', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 12:53:33'),
(88, '19794', 'ktc_parameter', 'id', 'lable', 'Hospital Name', 'HospitalName', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 12:53:56'),
(89, '19800', 'ktc_parameter', 'id', 'type', 'int', 'dropdown', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 12:57:00'),
(90, '19801', 'ktc_parameter', 'id', 'type', 'int', 'dropdown', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 12:57:02'),
(91, '19802', 'ktc_parameter', 'id', 'type', 'int', 'dropdown', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 12:57:06'),
(92, '19816', 'ktc_parameter', 'id', 'lable', 'Patient Name', 'Student Name', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 13:05:04'),
(93, '19817', 'ktc_parameter', 'id', 'lable', 'Patient Tell', 'Student Tell', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 13:05:10'),
(94, '19831', 'ktc_parameter', 'id', 'lable', 'Hospital', ' Hospital', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 13:07:29'),
(95, '19832', 'ktc_parameter', 'id', 'type', 'dropdown', 'dropdown', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 13:07:34'),
(96, '19831', 'ktc_parameter', 'id', 'type', 'dropdown', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 13:07:38'),
(97, '19833', 'ktc_parameter', 'id', 'type', 'dropdown', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 13:07:42'),
(98, '19831', 'ktc_parameter', 'id', 'lable', 'Hospital', 'Hospital', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 13:07:44'),
(99, '19831', 'ktc_parameter', 'id', 'lable', 'Hospital', 'Hospital', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 13:07:46'),
(100, '19831', 'ktc_parameter', 'id', 'lable', 'Hospital', 'Hospital', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 13:07:46'),
(101, '19831', 'ktc_parameter', 'id', 'lable', 'Hospital', 'Hospital', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 13:07:50'),
(102, '19834', 'ktc_parameter', 'id', 'type', 'dropdown', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 13:07:57'),
(103, '19846', 'ktc_parameter', 'id', 'type', 'dropdown', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 16:26:26'),
(104, '19847', 'ktc_parameter', 'id', 'type', 'dropdown', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 16:26:30'),
(105, '19848', 'ktc_parameter', 'id', 'type', 'dropdown', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 16:26:35'),
(106, '19883', 'ktc_parameter', 'id', 'type', 'dropdown', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 16:44:56'),
(107, '19885', 'ktc_parameter', 'id', 'type', 'dropdown', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 16:45:00'),
(108, '19886', 'ktc_parameter', 'id', 'type', 'dropdown', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 16:45:06'),
(109, '19916', 'ktc_parameter', 'id', 'type', 'dropdown', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:31:58'),
(110, '19916', 'ktc_parameter', 'id', 'action', 'region_', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:32:04'),
(111, '19933', 'ktc_parameter', 'id', 'placeholder', '', '9', 'null', 1, 0, 3, 1, '2022-12-23 18:37:06'),
(112, '19934', 'ktc_parameter', 'id', 'placeholder', '', '9', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:10'),
(113, '19935', 'ktc_parameter', 'id', 'placeholder', '', '9', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:16'),
(114, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:18'),
(115, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:20'),
(116, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:20'),
(117, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:20'),
(118, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:20'),
(119, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:21'),
(120, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:21'),
(121, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:21'),
(122, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:21'),
(123, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:21'),
(124, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:21'),
(125, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:22'),
(126, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:22'),
(127, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:22'),
(128, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:22'),
(129, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:23'),
(130, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:23'),
(131, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:23'),
(132, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:23'),
(133, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:29'),
(134, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:29'),
(135, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:29'),
(136, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:30'),
(137, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:30'),
(138, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:30'),
(139, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:30'),
(140, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:30'),
(141, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:31'),
(142, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:31'),
(143, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:31'),
(144, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:32'),
(145, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:32'),
(146, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:32'),
(147, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:32'),
(148, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:33'),
(149, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:33'),
(150, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:33'),
(151, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:34'),
(152, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:34'),
(153, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'null', 1, 0, 3, 1, '2022-12-23 18:37:36'),
(154, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'null', 1, 0, 3, 1, '2022-12-23 18:37:37'),
(155, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:40'),
(156, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:41'),
(157, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:37:42'),
(158, '19846', 'ktc_parameter', 'id', 'action', 'hospital|', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-23 18:38:51'),
(159, '19847', 'ktc_parameter', 'id', 'action', 'region_', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-23 18:39:14'),
(160, '19848', 'ktc_parameter', 'id', 'type', 'hidden_ele', 'dropdown', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-23 18:39:27'),
(161, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:39:29'),
(162, '19848', 'ktc_parameter', 'id', 'default_value', '%', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-23 18:39:33'),
(163, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'null', 1, 0, 3, 1, '2022-12-23 18:41:08'),
(164, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'null', 1, 0, 3, 1, '2022-12-23 18:41:08'),
(165, '19933', 'ktc_parameter', 'id', 'placeholder', '', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:42:01'),
(166, '19928', 'ktc_parameter', 'id', 'type', 'number', 'int', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-23 18:45:52'),
(167, '19928', 'ktc_parameter', 'id', 'type', 'number', 'number', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:45:55'),
(168, '19929', 'ktc_parameter', 'id', 'type', 'number', 'int', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:45:59'),
(169, '19929', 'ktc_parameter', 'id', 'type', 'number', 'number', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-23 18:46:03'),
(170, '19933', 'ktc_parameter', 'id', 'type', 'number', 'int', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:46:07'),
(171, '19934', 'ktc_parameter', 'id', 'type', 'number', 'int', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:46:10'),
(172, '19935', 'ktc_parameter', 'id', 'type', 'number', 'int', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 18:46:13'),
(173, '19831', 'ktc_parameter', 'id', 'action', 'hospital|', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-23 18:59:05'),
(174, '19833', 'ktc_parameter', 'id', 'action', 'region_', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-23 18:59:14'),
(175, '19831', 'ktc_parameter', 'id', 'action', 'hospital|', 'hospital|', 'null', 1, 0, 2, 1, '2022-12-23 18:59:15'),
(176, '19831', 'ktc_parameter', 'id', 'action', 'hospital|', 'hospital|', 'null', 1, 0, 2, 1, '2022-12-23 18:59:17'),
(177, '19831', 'ktc_parameter', 'id', 'action', 'hospital|', 'hospital|', 'null', 1, 0, 2, 1, '2022-12-23 18:59:18'),
(178, '19834', 'ktc_parameter', 'id', 'type', 'hidden_ele', 'dropdown', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-23 18:59:32'),
(179, '19834', 'ktc_parameter', 'id', 'default_value', '%', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-23 18:59:35'),
(180, '19779', 'ktc_parameter', 'id', 'type', 'number', 'int', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 19:20:31'),
(181, '19780', 'ktc_parameter', 'id', 'action', 'student|', 'student', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 19:20:43'),
(182, '19781', 'ktc_parameter', 'id', 'type', 'number', 'text', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 19:20:50'),
(183, '19784', 'ktc_parameter', 'id', 'type', 'number', 'int', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 19:20:57'),
(184, '19784', 'ktc_parameter', 'id', 'placeholder', '', '9', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 19:21:01'),
(185, '19783', 'ktc_parameter', 'id', 'action', 'category|', 'department|', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 19:22:09'),
(186, '19780', 'ktc_parameter', 'id', 'action', 'doctor|', 'student|', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 19:26:01'),
(187, '19780', 'ktc_parameter', 'id', 'placeholder', 'Doctor Name', 'Student Name', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 19:26:11'),
(188, '19772', 'ktc_parameter', 'id', 'action', 'department|', 'student', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 19:29:53'),
(189, '19772', 'ktc_parameter', 'id', 'placeholder', 'Department Name', 'Student Name', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 19:30:03'),
(190, '19809', 'ktc_parameter', 'id', 'type', 'autocomplete', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 19:31:56'),
(191, '19810', 'ktc_parameter', 'id', 'type', 'number', 'int', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 19:32:13'),
(192, '19811', 'ktc_parameter', 'id', 'action', 'doctor|', 'doctor', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 19:33:36'),
(193, '19812', 'ktc_parameter', 'id', 'type', 'number', 'double', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 19:33:40'),
(194, '19811', 'ktc_parameter', 'id', 'type', 'autocomplete', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 19:34:42'),
(195, '19816', 'ktc_parameter', 'id', 'placeholder', 'Patient Name', 'Student Name', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 19:37:06'),
(196, '19816', 'ktc_parameter', 'id', 'action', 'patient|', 'student', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 19:37:15'),
(197, '19817', 'ktc_parameter', 'id', 'type', 'number', 'int', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 19:37:22'),
(198, '19819', 'ktc_parameter', 'id', 'type', 'date', 'Element Type', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 19:37:34'),
(199, '19820', 'ktc_parameter', 'id', 'type', 'varchar', 'Element Type', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 19:37:42'),
(200, '19868', 'ktc_parameter', 'id', 'type', 'dropdown', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 19:56:07'),
(201, '19871', 'ktc_parameter', 'id', 'type', 'hidden_ele', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 19:56:25'),
(202, '19872', 'ktc_parameter', 'id', 'default_value', '%', '', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 19:56:33'),
(203, '19870', 'ktc_parameter', 'id', 'type', 'dropdown', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 19:56:48'),
(204, '19869', 'ktc_parameter', 'id', 'action', '', 'department|', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-23 19:56:57'),
(205, '19872', 'ktc_parameter', 'id', 'default_value', '', '%', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-24 08:26:46'),
(206, '19872', 'ktc_parameter', 'id', 'default_value', '', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-24 08:27:01'),
(207, '19868', 'ktc_parameter', 'id', 'action', 'hospital|', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-24 08:27:14'),
(208, '19772', 'ktc_parameter', 'id', 'type', 'varchar', 'autocomplete', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-24 08:55:13'),
(209, '19816', 'ktc_parameter', 'id', 'type', 'varchar', 'autocomplete', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-24 09:02:37'),
(210, '19819', 'ktc_parameter', 'id', 'default_value', '1', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-24 09:02:46'),
(211, '19819', 'ktc_parameter', 'id', 'default_value', '%', '1', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-24 09:02:59'),
(212, '19819', 'ktc_parameter', 'id', 'default_value', '00-00-0000', '%', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-24 09:03:22'),
(213, '19821', 'ktc_parameter', 'id', 'type', 'hidden_ele', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-24 09:04:26'),
(214, '19810', 'ktc_parameter', 'id', 'type', 'autocomplete', 'number', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-24 09:10:05'),
(215, '19810', 'ktc_parameter', 'id', 'action', 'hospital|', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-24 09:10:13'),
(216, '19811', 'ktc_parameter', 'id', 'type', 'dropdown', 'autocomplete', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-24 09:10:21'),
(217, '19810', 'ktc_parameter', 'id', 'class', 'load', 'int', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-24 09:10:27'),
(218, '19810', 'ktc_parameter', 'id', 'load_action', 'hospital_id,doctor-', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-24 09:11:31'),
(219, '19810', 'ktc_parameter', 'id', 'load_action', 'hospital_id,doctor-', 'hospital_id,doctor-', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-24 09:11:44'),
(220, '19779', 'ktc_parameter', 'id', 'type', 'autocomplete', 'number', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-24 09:12:20'),
(221, '19779', 'ktc_parameter', 'id', 'action', 'hospital|', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-24 09:12:34'),
(222, '19780', 'ktc_parameter', 'id', 'type', 'text', 'autocomplete', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-24 09:12:46'),
(223, '19780', 'ktc_parameter', 'id', 'action', '', 'doctor|', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-24 09:12:49'),
(224, '19782', 'ktc_parameter', 'id', 'action', 'images', 'docs', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-24 09:15:48'),
(225, '19783', 'ktc_parameter', 'id', 'action', 'department|', 'category|', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-24 09:16:29'),
(226, '19783', 'ktc_parameter', 'id', 'lable', 'Department', 'category', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-24 09:16:35'),
(227, '19784', 'ktc_parameter', 'id', 'lable', 'Ticket Fee ($)', 'Fee ($)', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-24 09:16:42'),
(228, '19849', 'ktc_parameter', 'id', 'is_required', '', 'required', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-25 06:17:58'),
(229, '19849', 'ktc_parameter', 'id', 'default_value', '', '', 'null', 1, 0, 2, 1, '2022-12-25 06:18:27'),
(230, '19883', 'ktc_parameter', 'id', 'action', 'hospital|', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-25 07:13:22'),
(231, '19884', 'ktc_parameter', 'id', 'lable', 'Department', 'category', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-25 07:13:44'),
(232, '19885', 'ktc_parameter', 'id', 'action', 'region_', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-25 07:13:52'),
(233, '19886', 'ktc_parameter', 'id', 'type', 'hidden_ele', 'dropdown', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-25 07:14:01'),
(234, '19886', 'ktc_parameter', 'id', 'default_value', '%', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-25 07:14:07'),
(235, '9', 'ticket', 'id', 'hospital_ticket', '35', '0', 'ticket', 1, 0, 2, 1, '2022-12-25 07:25:51'),
(236, '19781', 'ktc_parameter', 'id', 'is_required', '', 'required', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-26 07:54:43'),
(237, '19782', 'ktc_parameter', 'id', 'is_required', '', 'required', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-26 07:54:49'),
(238, '19784', 'ktc_parameter', 'id', 'is_required', '', 'required', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-26 07:55:01'),
(239, '5', 'department', 'id', 'Image', 'uploads/bulshotechapps_ktceditsp_20221226020015.jpeg', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-26 08:00:15'),
(240, '6', 'department', 'id', 'Image', 'uploads/bulshotechapps_ktceditsp_20221226020200.jpeg', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-26 08:02:00'),
(241, '7', 'department', 'id', 'Image', 'uploads/bulshotechapps_ktceditsp_20221226020357.jpeg', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-26 08:03:57'),
(242, '9', 'department', 'id', 'Image', 'uploads/bulshotechapps_ktceditsp_20221226020557.jpeg', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-26 08:05:57'),
(243, '8', 'department', 'id', 'Image', 'uploads/bulshotechapps_ktceditsp_20221226020747.jpeg', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-26 08:07:47'),
(244, '10', 'department', 'id', 'Image', 'uploads/bulshotechapps_ktceditsp_20221226021116.jpeg', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-26 08:11:16'),
(245, '11', 'department', 'id', 'Image', 'uploads/bulshotechapps_ktceditsp_20221226021329.jpeg', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-26 08:13:29'),
(246, '12', 'department', 'id', 'Image', 'uploads/bulshotechapps_ktceditsp_20221226021524.jpeg', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-26 08:15:24'),
(247, '19', 'department', 'id', 'Image', 'uploads/bulshotechapps_ktceditsp_20221226021925.jpg', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-26 08:19:25'),
(248, '18', 'department', 'id', 'Image', 'uploads/bulshotechapps_ktceditsp_20221226022011.webp', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-26 08:20:11'),
(249, '13', 'department', 'id', 'Image', 'uploads/bulshotechapps_ktceditsp_20221226022236.jpeg', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-26 08:22:36'),
(250, '14', 'department', 'id', 'Image', 'uploads/bulshotechapps_ktceditsp_20221226022247.jpeg', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-26 08:22:47'),
(251, '16', 'department', 'id', 'Image', 'uploads/bulshotechapps_ktceditsp_20221226022406.jpg', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-26 08:24:06'),
(252, '15', 'department', 'id', 'Image', 'uploads/bulshotechapps_ktceditsp_20221226022521.jpeg', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-26 08:25:21'),
(253, '17', 'department', 'id', 'Image', 'uploads/bulshotechapps_ktceditsp_20221226022923.jpeg', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-26 08:29:23'),
(254, '8455', 'ktc_parameter', 'id', 'default_value', 'user', 'chart', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-29 09:36:52'),
(255, '19965', 'ktc_parameter', 'id', 'lable', 'Description', ' Ip', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-29 21:26:01'),
(256, '19965', 'ktc_parameter', 'id', 'type', 'vatchar', 'ip', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-29 21:26:08'),
(257, '19963', 'ktc_parameter', 'id', 'type', 'varchar', 'Element Type', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-29 21:27:56'),
(258, '19963', 'ktc_parameter', 'id', 'type', 'int', 'varchar', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-29 21:30:03'),
(259, '19963', 'ktc_parameter', 'id', 'type', 'number', 'int', 'Qalad iga dhacay', 1, 0, 3, 1, '2022-12-29 21:30:22'),
(260, '16', 'ticket', 'id', 'image', 'uploads/bulshotechapps_ktceditsp_20221230024753.jpeg', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-30 08:47:53'),
(261, '16', 'ticket', 'id', 'hospital_ticket', '2', '0', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-30 08:48:00'),
(262, '16', 'ticket', 'id', 'hospital_ticket', '3', '2', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-30 08:49:00'),
(263, '16', 'ticket', 'id', 'hospital_ticket', '2', '3', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-30 08:54:00'),
(264, '19963', 'ktc_parameter', 'id', 'lable', 'Expense Type', 'Expense', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-30 09:13:26'),
(265, '19963', 'ktc_parameter', 'id', 'type', 'dropdown', 'number', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-30 09:13:31'),
(266, '19963', 'ktc_parameter', 'id', 'action', 'general,type,expense', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-30 09:13:40'),
(267, '19965', 'ktc_parameter', 'id', 'type', 'vatchar', 'vatchar', 'null', 1, 0, 2, 1, '2022-12-30 09:13:44'),
(268, '19966', 'ktc_parameter', 'id', 'type', 'hidden_ele', 'dropdown', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-30 09:14:24'),
(269, '19966', 'ktc_parameter', 'id', 'default_value', 'e', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2022-12-30 09:14:34'),
(270, '19994', 'ktc_parameter', 'id', 'class', '', 'date', 'Qalad iga dhacay', 1, 0, 2, 1, '2023-01-01 08:20:16'),
(271, '19995', 'ktc_parameter', 'id', 'type', 'textarea2', 'textarea2', 'null', 1, 0, 2, 1, '2023-01-01 08:20:39'),
(272, '19994', 'ktc_parameter', 'id', 'type', 'textare', 'texterea', 'null', 1, 0, 2, 1, '2023-01-01 08:20:43'),
(273, '19994', 'ktc_parameter', 'id', 'type', 'textarea', 'textare', 'Qalad iga dhacay', 1, 0, 2, 1, '2023-01-01 08:20:49'),
(274, '17', 'ticket', 'id', 'image', 'uploads/bulshotechapps_ktceditsp_20230101033947.jpeg', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2023-01-01 09:39:47'),
(275, '17', 'ticket', 'id', 'hospital_ticket', '2', '0', 'Qalad iga dhacay', 1, 0, 2, 1, '2023-01-01 09:40:02'),
(276, '20001', 'ktc_parameter', 'id', 'type', 'text', 'number', 'Qalad iga dhacay', 1, 0, 2, 1, '2023-01-05 07:06:10'),
(277, '17385', 'ktc_parameter', 'id', 'type', 'hidden_ele', 'dropdown', 'Qalad iga dhacay', 1, 0, 2, 1, '2023-01-10 08:56:50'),
(278, '19846', 'ktc_parameter', 'id', 'action', 'hospital', 'hospital|', 'Qalad iga dhacay', 1, 0, 2, 1, '2023-01-10 09:10:24'),
(279, '19846', 'ktc_parameter', 'id', 'action', 'hospital|', 'hospital', 'null', 1, 0, 2, 1, '2023-01-10 09:10:44'),
(280, '19846', 'ktc_parameter', 'id', 'action', 'hospital', 'hospital|', 'Qalad iga dhacay', 1, 0, 2, 1, '2023-01-10 09:11:03'),
(281, '19850', 'ktc_parameter', 'id', 'is_required', '', 'required', 'Qalad iga dhacay', 1, 0, 2, 1, '2023-01-12 03:43:39'),
(282, '19850', 'ktc_parameter', 'id', 'default_value', '0000-00-00', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2023-01-12 03:43:48'),
(283, '19850', 'ktc_parameter', 'id', 'default_value', '', '0000-00-00', 'Qalad iga dhacay', 1, 0, 2, 1, '2023-01-12 03:44:10'),
(284, '19849', 'ktc_parameter', 'id', 'default_value', '0000-00-00', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2023-01-12 03:44:14'),
(285, '20036', 'ktc_parameter', 'id', 'type', 'hidden_ele', 'date', 'Qalad iga dhacay', 1, 0, 2, 1, '2023-01-24 08:32:47'),
(286, '20039', 'ktc_parameter', 'id', 'lable', 'Description', ' Ip', 'Qalad iga dhacay', 1, 0, 2, 1, '2023-01-24 08:33:00'),
(287, '20039', 'ktc_parameter', 'id', 'type', 'textarea', 'ip', 'Qalad iga dhacay', 1, 0, 2, 1, '2023-01-24 08:33:08'),
(288, '20038', 'ktc_parameter', 'id', 'lable', 'Campaign Name', 'Hospital Name', 'Qalad iga dhacay', 1, 0, 2, 1, '2023-01-24 08:33:24'),
(289, '20038', 'ktc_parameter', 'id', 'placeholder', 'Campaign Name', 'Hospital Name', 'Qalad iga dhacay', 1, 0, 2, 1, '2023-01-24 08:33:27'),
(290, '20039', 'ktc_parameter', 'id', 'type', 'textarea2', 'textarea', 'Qalad iga dhacay', 1, 0, 2, 1, '2023-01-24 08:34:58'),
(291, '160', 'hospital', 'id', 'service_fee', '9000', '3', 'Qalad iga dhacay', 1, 0, 5, 1, '2023-04-02 00:32:32'),
(292, '196', 'hospital', 'id', 'currency', 'Shilin', '$', '', 1, 0, 5, 1, '2023-04-15 10:37:14'),
(293, '196', 'hospital', 'id', 'currency', 'Shilin', 'Shilin', 'Qalad iga dhacay', 1, 0, 5, 1, '2023-04-15 10:37:39'),
(294, '194', 'hospital', 'id', 'currency', 'Shilin', '$', 'Qalad iga dhacay', 1, 0, 5, 1, '2023-04-15 10:44:10'),
(295, '179', 'hospital', 'id', 'currency', 'Shilin', '$', 'wan saxay', 1, 0, 5, 1, '2023-04-22 07:23:03'),
(296, '181', 'hospital', 'id', 'currency', 'Shilin', '$', 'wan waxay', 1, 0, 5, 1, '2023-04-22 07:24:31'),
(297, '182', 'hospital', 'id', 'currency', 'Shilin', '$', 'wan saxay', 1, 0, 5, 1, '2023-04-22 07:25:26'),
(298, '183', 'hospital', 'id', 'currency', 'Shilin', '$', 'wan saxay', 1, 0, 5, 1, '2023-04-22 07:26:08'),
(299, '184', 'hospital', 'id', 'currency', 'Shilin', '$', 'wan saxay', 1, 0, 5, 1, '2023-04-22 07:26:46'),
(300, '185', 'hospital', 'id', 'currency', 'Shilin', '$', 'wan saxay', 1, 0, 5, 1, '2023-04-22 07:27:37'),
(301, '186', 'hospital', 'id', 'currency', 'Shilin', '$', 'wan saxay', 1, 0, 5, 1, '2023-04-22 07:28:20'),
(302, '187', 'hospital', 'id', 'currency', 'Shilin', '$', 'wan saxay', 1, 0, 5, 1, '2023-04-22 07:28:53'),
(303, '188', 'hospital', 'id', 'currency', 'Shilin', '$', 'wan saxay', 1, 0, 5, 1, '2023-04-22 07:29:50'),
(304, '189', 'hospital', 'id', 'currency', 'Shilin', '$', 'wan saxay', 1, 0, 5, 1, '2023-04-22 07:30:48'),
(305, '190', 'hospital', 'id', 'currency', 'Shilin', '$', 'wan saxay', 1, 0, 5, 1, '2023-04-22 07:31:22'),
(306, '191', 'hospital', 'id', 'currency', 'Shilin', '$', 'wan saxay', 1, 0, 5, 1, '2023-04-22 07:31:59'),
(307, '192', 'hospital', 'id', 'currency', 'Shilin', '$', 'wan saxay', 1, 0, 5, 1, '2023-04-22 07:32:36'),
(308, '193', 'hospital', 'id', 'currency', 'Shilin', '$', 'wan saxay', 1, 0, 5, 1, '2023-04-22 07:33:07'),
(309, '1', 'company', 'id', 'logo', 'uploads/bulshokaabehealthservices_ktceditsp_20230604050954.jpeg', 'uploads/bulshotechapps_ktceditsp_20221222034928.png', 'Qalad iga dhacay', 1, 0, 2, 1, '2023-06-04 10:09:54'),
(310, '19835', 'ktc_parameter', 'id', 'is_required', '', 'required', 'Qalad iga dhacay', 1, 0, 2, 1, '2023-08-10 11:09:25'),
(311, '20051', 'ktc_parameter', 'id', 'type', 'textarea', 'textarea2', 'Qalad iga dhacay', 1, 0, 2, 1, '2023-08-10 11:09:47'),
(312, '20051', 'ktc_parameter', 'id', 'lable', 'Work Time', 'Description', 'Qalad iga dhacay', 1, 0, 2, 1, '2023-08-10 11:10:12'),
(313, '20051', 'ktc_parameter', 'id', 'placeholder', 'Ex. Sabti, Axad, Isniin, Talaado Saacadaha : 08AM - 12PM', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2023-08-10 11:10:53'),
(314, '19835', 'ktc_parameter', 'id', 'is_required', '', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2023-08-10 11:11:36'),
(315, '20064', 'ktc_parameter', 'id', 'is_required', '', 'required', 'Qalad iga dhacay', 1, 0, 2, 1, '2023-08-10 11:16:33'),
(316, '83', 'doctor', 'id', 'description', 'Sabti - Khamiis, Saacdaha: 08AM - 12PM, 04PM - 05PM', '', 'Qalad iga dhacay', 1, 0, 2, 1, '2023-08-10 11:21:23');

-- --------------------------------------------------------

--
-- Table structure for table `ktc_error`
--

CREATE TABLE `ktc_error` (
  `id` int(11) NOT NULL,
  `auto_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `sub_category_id` int(11) NOT NULL,
  `link_id` int(11) NOT NULL,
  `description` text NOT NULL,
  `screenshot` varchar(100) NOT NULL,
  `status` varchar(100) NOT NULL,
  `user_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ktc_error`
--

INSERT INTO `ktc_error` (`id`, `auto_id`, `company_id`, `category_id`, `sub_category_id`, `link_id`, `description`, `screenshot`, `status`, `user_id`, `date`, `action_date`, `modified_date`) VALUES
(3, 1, 1, 62, 107, 707, 'Hal-ka ma shaqeynaayo', 'error', '1', 2, '2022-12-13', '2022-12-13 15:47:11', '2022-12-13 16:01:12'),
(4, 2, 1, 64, 0, 769, 'iyo report kiisa', 'error', '1', 52, '2022-12-14', '2022-12-14 11:32:52', '2022-12-14 11:32:52'),
(5, 3, 1, 64, 109, 0, 'waxa codsi ah in student statment lugu so cadeeyo ardayga scholarshipka ah sidi kii hore', 'error', '1', 117, '2022-12-15', '2022-12-15 12:20:43', '2022-12-15 12:20:43'),
(6, 4, 1, 56, 106, 725, 'Asc Eng Abdihamid waxaan rajaynaa in aad caafimad qabto insha allah \r\n1.Complaint aan qabo waxaa waa', 'uploads/universityofsomalia(uniso)_ktcerrorsp_20221218071510.jpeg', '1', 164, '2022-12-18', '2022-12-18 05:15:10', '2022-12-18 05:15:10'),
(7, 5, 1, 56, 106, 0, 'EXAM RESULTS\r\n1.Logo Layee SI SPACE U YARAAD\r\nSTUDENTS BY CLASS\r\n1-In Design Laga Saxo Waayo Final W', 'uploads/universityofsomalia(uniso)_ktcerrorsp_20221218140423.jpg', '1', 164, '2022-12-18', '2022-12-18 12:04:23', '2022-12-18 12:04:23'),
(8, 1, -1, -1, 0, 0, '', '0', '2', 2023, '0000-00-00', '2023-01-05 07:46:38', '2023-01-05 07:46:38'),
(9, 6, 1, 3, 0, 735, 'Error: SQLSTATE[42000]: Syntax error or access violation: 1318 Incorrect number of arguments for PRO', '', '0', 2, '2023-01-05', '2023-01-05 07:47:36', '2023-01-05 07:47:36'),
(10, 7, 1, 3, 0, 735, 'Error: SQLSTATE[42000]: Syntax error or access violation: 1318 Incorrect number of arguments for PROCEDURE kashi_bulsho_apps.search_ticket_sp; expected 3, got 4 - Post:', '', '0', 2, '2023-01-05', '2023-01-05 07:48:48', '2023-01-05 07:48:48');

-- --------------------------------------------------------

--
-- Table structure for table `ktc_inbox`
--

CREATE TABLE `ktc_inbox` (
  `id` int(11) NOT NULL,
  `from_user` int(11) NOT NULL,
  `to_user_id` int(11) NOT NULL,
  `title` varchar(250) NOT NULL,
  `msg` text NOT NULL,
  `file` varchar(250) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `ktc_languages`
--

CREATE TABLE `ktc_languages` (
  `id` int(11) NOT NULL,
  `auto_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `translated` varchar(250) NOT NULL,
  `table_auto_id` int(11) NOT NULL,
  `table_name` varchar(50) NOT NULL,
  `language` varchar(50) NOT NULL,
  `user_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `ktc_link`
--

CREATE TABLE `ktc_link` (
  `id` int(11) NOT NULL,
  `auto_id` int(11) NOT NULL DEFAULT '0',
  `href` varchar(250) NOT NULL,
  `category_id` int(11) NOT NULL,
  `sub_category_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `title` varchar(250) NOT NULL,
  `sp` varchar(50) NOT NULL,
  `description` text NOT NULL,
  `form_action` varchar(50) NOT NULL DEFAULT 'ktc_call_sp.php',
  `btn` varchar(100) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `link_icon` varchar(50) NOT NULL,
  `status` int(11) NOT NULL DEFAULT '1',
  `order_by` int(11) NOT NULL DEFAULT '0',
  `dropdown_action` varchar(50) DEFAULT NULL,
  `company_id` int(11) NOT NULL DEFAULT '17',
  `level` varchar(50) NOT NULL DEFAULT 'user',
  `user_id` int(11) NOT NULL,
  `form_name` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ktc_link`
--

INSERT INTO `ktc_link` (`id`, `auto_id`, `href`, `category_id`, `sub_category_id`, `name`, `title`, `sp`, `description`, `form_action`, `btn`, `date`, `link_icon`, `status`, `order_by`, `dropdown_action`, `company_id`, `level`, `user_id`, `form_name`) VALUES
(1, 1, 'forms/create', 1, 1, 'Create Form', 'Create Form', 'ktc_link_sp', '', 'forms/save', 'Create', '2018-11-13 01:54:03', 'fa fa-list', 1, 0, NULL, 1, 'user', 1, 'Form'),
(7, 7, 'forms/create', 1, 13, 'Add Common Label', '', 'ktc_common_paramete_sp', 'Create common pa..', 'forms/save', 'Create', '2018-11-19 12:27:00', 'fa fa-plus', 1, 0, NULL, 1, 'user', 2, 'CommonLabel'),
(14, 14, 'forms/create', 1, 1, 'Repair Form', 'Repair Forms', 'ktc_repair_link_sp', '', 'forms/save', 'Repair', '2018-11-22 01:31:32', 'fa fa-edit', 1, 0, NULL, 1, 'user', 1, 'Repair-Form'),
(16, 16, 'forms/list', 1, 12, 'Forms List', '', 'ktc_rp_link_sp', '', 'forms/report', 'Search', '2018-11-29 01:33:35', 'fa fa-list', 1, 0, NULL, 1, 'user', 1, 'Forms-List'),
(18, 18, 'forms/list', 1, 12, 'Users List', '', 'ktc_rp_user_sp', 'users List', 'forms/report', 'Search', '2018-12-01 01:18:01', 'fa fa-list', 1, 0, NULL, 1, 'user', 1, 'Users-List'),
(21, 21, 'forms/list', 1, 13, 'Common labels list', '', 'ktc_rp_common_parameter_sp', '', 'forms/report', 'Search', '2018-12-07 01:34:03', 'fa fa-list', 1, 0, NULL, 1, 'user', 0, 'Common-labels-list'),
(22, 22, 'forms/list', 1, 13, 'Labels List', '', 'ktc_rp_parameters_sp', '', 'forms/report', 'Search', '2018-12-07 01:34:37', 'fa fa-list', 1, 0, NULL, 1, 'user', 0, 'Labels-List'),
(32, 32, 'forms/list', 1, 12, 'Options list', '', 'ktc_rp_dropdown_sp', '', 'forms/report', 'Search', '2018-12-12 12:23:08', 'fa fa-list', 1, 0, NULL, 1, 'user', 0, 'Options-list'),
(33, 33, 'forms/list', 1, 2, 'User Permission (Super)', '', 'ktc_ls_link_permission_sp', '', 'users/permission', 'Show Permissions', '2018-12-13 01:46:36', 'fa fa-check', 1, 0, NULL, 1, 'user', 0, 'User-Permission-(Super)'),
(35, 35, 'forms/list', 1, 2, 'User Permission', '', 'ktc_ls_link_permission1_sp', '', 'users/permission', 'Show Permissions', '2018-12-15 03:43:36', 'fa fa-check', 1, 0, NULL, 1, 'user', 2, 'User-Permission'),
(36, 36, 'forms/create', 1, 1, 'Create Sub Menu', '', 'ktc_sub_category_sp', 'create new sub  menu', 'forms/save', 'Create', '2018-12-15 13:24:22', 'fa fa-plus', 1, 0, NULL, 1, 'user', 2, 'SubMenu'),
(37, 37, 'forms/create', 1, 1, 'Create Main Menu', '', 'ktc_category_sp', 'create new menu', 'forms/save', 'Create', '2018-12-15 13:25:21', 'fa fa-plus', 1, 0, NULL, 1, 'user', 2, 'MainMenu'),
(41, 41, 'forms/create', 1, 2, 'Create User', '', 'ktc_user_sp', 'Craetes new user', 'forms/save', 'Create', '2018-12-30 12:37:30', 'fa fa-user', 1, 0, NULL, 1, 'user', 2, 'User'),
(52, 52, 'forms/create', 1, 2, 'Change Password', '', 'ktc_change_pass_sp', 'Change password Form', 'forms/save', 'Change', '2019-01-02 09:00:15', 'fa fa-lock', 1, 0, NULL, 1, 'user', 2, 'Change-Password'),
(53, 53, 'forms/create', 1, 2, 'Reset Password', '', 'ktc_change_pass_sp', 'Reset password Form', 'forms/save', 'Reset', '2019-01-02 09:22:01', 'fa fa-lock', 1, 0, NULL, 1, 'user', 2, 'Reset-Password'),
(54, 54, 'forms/create', 1, 13, 'Create Option', '', 'ktc_dropdown_sp', 'Create Option', 'forms/save', 'Create', '2019-01-09 08:45:56', 'fa fa-plus', 1, 0, NULL, 1, 'user', 2, 'Option'),
(55, 55, 'forms/create', 1, 1, 'Add Chart Box', '', 'ktc_add_chart_sp', '', 'forms/save', 'Save', '2019-01-09 09:03:08', 'fa fa-plus', 1, 0, NULL, 1, 'user', 2, 'ChartBox'),
(56, 56, 'forms/list', 1, 12, 'Menu List', '', 'ktc_rp_category_sp', '', 'forms/report', 'Search', '2019-01-09 09:15:57', 'fa fa-plus', 1, 0, NULL, 1, 'user', 2, 'Menu-List'),
(57, 57, 'forms/list', 1, 12, 'Charts List', '', 'ktc_rp_chart_sp', '', 'forms/report', 'Search', '2019-01-09 09:16:28', 'fa fa-list', 1, 0, NULL, 1, 'user', 2, 'Charts-List'),
(59, 59, 'forms/create', 1, 1, 'Copy Form', '', 'ktc_copy_form_sp', 'Copy forms', 'forms/save', 'Copy', '2019-01-09 09:32:46', 'fa fa-copy', 1, 0, NULL, 1, 'user', 2, 'Copy-Form'),
(61, 61, 'forms/list', 1, 2, 'User Permission Report', '', 'ktc_rp_user_permission', '', 'forms/report', 'Show Permissions', '2019-01-09 10:06:11', 'fa fa-list', 1, 0, NULL, 1, 'user', 2, 'User-Permission-Report'),
(74, 74, 'forms/list', 1, 1, 'Generate Proc', 'Generate Procedure Form', 'ktc_rp_table_sp', '', 'forms/report', 'Search', '2019-02-03 08:04:17', 'fa fa-cog', 1, 0, NULL, 1, 'user', 2, 'Generate-Proc'),
(93, 93, 'forms/create', 1, 2, 'Copy Permission', 'copy permission', 'ktc_copy_permission_sp', 'copy permission', 'forms/save', 'Copy', '2019-03-09 05:58:25', 'fa fa-play-circle-o', 1, 0, NULL, 1, 'user', 2, 'Copy-Permission'),
(270, 270, 'forms/create', 1, 1, 'Custom Form', 'Custom Form', 'ktc_link_sp', '', 'forms/save', 'Create', '2018-11-13 01:54:03', 'fa fa-list', 1, 0, NULL, 1, 'user', 1, 'Custom-Form'),
(352, 352, 'views/export.php', 1, 69, 'Full Backup', 'Full Backup', 'ktc_', 'Full Backup Structure,Data, & Framework Objects', 'c', 'c', '2019-05-04 16:21:26', 'fa fa-database', 1, 0, NULL, 1, 'user', 2, 'Full-Backup'),
(353, 353, 'views/export_ktc.php', 1, 69, 'Framework  Backup', 'Framework  Backup', 'ktc_', 'Backup Structure,Data, & Framework Objects only', 'c', 'c', '2019-05-04 16:21:55', 'fa fa-database', 1, 0, NULL, 1, 'user', 2, 'Framework--Backup'),
(369, 369, 'views/export_company_data.php', 1, 69, 'Backup Now', 'Full Backup Data by company', 'ktc_', 'Full Backup Structure,Data, & Framework Objects', 'c', 'c', '2019-05-04 16:21:26', 'fa fa-database', 1, 0, NULL, 1, 'user', 2, 'Backup-Now'),
(390, 390, 'views/export_company_data.php', 1, 69, 'System Backup', 'System Backup ', 'ktc_', 'Full Backup Structure,Data, & Framework Objects', 'c', 'c', '2019-05-04 16:21:26', 'fa fa-database', 1, 0, NULL, 1, 'user', 2, 'System-Backup'),
(453, 423, 'forms/create', 1, 13, 'Copy Labels', 'Copy Labels', 'ktc_copy_parameter_sp', 'Copy forms', 'forms/save', 'Copy', '2019-01-09 09:32:46', 'fa fa-copy', 1, 0, NULL, 1, 'user', 1, 'Copy-Labels'),
(506, 459, 'forms/create', 1, 1, 'Copy Forms', 'Copy Forms', 'ktc_copy_multi_form_sp', 'Copy Forms', 'forms/save', 'Copy All', '2020-08-25 14:09:51', 'fa fa-copyright', 1, 0, NULL, 1, 'user', 1, 'Copy-Forms'),
(538, 460, 'forms/create', 1, 1, 'Transfer Form', 'Transfer Form', 'ktc_tranfer_form_sp', 'Copy forms', 'forms/save', 'Transfer', '2019-01-09 09:32:46', 'fa fa-copy', 1, 0, NULL, 1, 'user', 1, 'Transfer-Form'),
(576, 485, 'forms/list', 1, 2, 'Deleted Records', 'Deleted Records', 'ktc_rp_delete_logs_sp', '', 'forms/report', 'Search', '2018-12-07 01:35:03', 'fa fa-list', 1, 0, NULL, 1, 'user', 1, 'Deleted-records.'),
(577, 486, 'forms/list', 1, 2, 'Updated Records', 'Updated Records', 'ktc_rp_edit_logs_sp', '', 'forms/report', 'Search', '2018-12-12 11:24:27', 'fa fa-list', 1, 0, NULL, 1, 'user', 1, 'Updated-records.'),
(578, 487, 'forms/list', 1, 2, 'User Logs', 'User Logs', 'ktc_rp_user_logs_sp', '', 'forms/report', 'Search', '2018-12-12 12:14:12', 'fa fa-list', 1, 0, NULL, 1, 'user', 1, 'User-Logs.'),
(1181, 612, 'forms/list', 1, 12, 'Unwanted Procedure', 'Unwanted Procedure', 'ktc_rp_expired_procedure_sp', '', 'forms/report', 'Search', '2022-02-13 14:59:10', '', 1, 0, NULL, 1, 'user', 2, 'Unwanted-Procedure'),
(1204, 622, 'forms/list', 1, 12, 'Company Profile', 'Company Profile', 'rp_company_sp', '', 'forms/report', 'Preview', '2022-03-23 10:47:42', 'fa fa-home', 1, 0, NULL, 1, 'user', 2, 'Company-Profile'),
(1261, 641, 'forms/create', 1, 1, 'Translate Languages', 'ktc_languages Form', 'ktc_languages_sp', 'ktc_languages Form', 'forms/save', 'Save', '2022-07-11 16:23:06', 'fa fa-plus', 1, 0, NULL, 1, 'user', 2, '-ktc_languages'),
(1291, 649, 'forms/create', 1, 13, 'Add General Table', 'General Form eg Day, month, Fee & ETC', 'general_sp', '', 'forms/save', 'Create', '2022-06-26 08:01:54', 'fa fa-plus-circle', 1, 0, NULL, 1, 'user', 2, '-Title.'),
(1297, 651, 'forms/create', 1, 81, 'Create attendance', 'attendance Form', 'attendance_sp', 'attendance Form', 'forms/save', 'Save', '2022-09-11 17:25:13', 'fa fa-plus', 1, 0, NULL, 1, 'user', 2, '-attendance'),
(1315, 669, 'forms/create', 1, 81, 'Create topic', 'topic Form', 'topic_sp', 'topic Form', 'forms/save', 'Save', '2022-09-28 19:11:24', 'fa fa-plus', 1, 0, NULL, 1, 'user', 2, '-topic'),
(1364, 717, 'forms/create', 1, 2, 'Copy Permission Links', 'Copy Permission without branches & faculties', 'ktc_copy_permission_sp', 'copy permission', 'forms/save', 'Copy', '2019-03-09 05:58:25', 'fa fa-play-circle-o', 1, 0, NULL, 1, 'user', 2, 'Copy-Permission.'),
(1448, 719, 'forms/create', 2, 0, 'New Department', 'New Department', 'department_sp', '', 'forms/save', 'save', '2022-12-22 17:25:10', 'fa fa-home', 1, 0, NULL, 1, 'user', 3, 'Department'),
(1449, 720, 'forms/create', 2, 0, 'New Doctor', 'New Doctor', 'doctor_sp', '', 'forms/save', 'save', '2022-12-22 17:26:14', 'fa fa-user-md', 1, 0, NULL, 1, 'user', 3, 'Doctor'),
(1450, 721, 'forms/create', 2, 0, 'New Hospital', 'New Hospital', 'hospital_sp', '', 'forms/save', 'save', '2022-12-22 17:29:31', 'fa fa-home', 1, 0, NULL, 1, 'user', 3, 'New-Hospital'),
(1451, 722, 'forms/create', 2, 0, 'New Ticket', 'New Ticket', 'ticket_sp', '', 'forms/save', 'save', '2022-12-22 17:30:33', 'fa fa-list-alt', 1, 0, NULL, 1, 'user', 3, 'New-Ticket'),
(1452, 723, 'forms/create', 2, 0, 'New Patient', 'New Patient', 'patient_sp', '', 'forms/save', 'save', '2022-12-22 17:31:19', 'fa fa-users', 1, 0, NULL, 1, 'user', 3, 'New-Patient'),
(1453, 724, 'forms/list', 3, 0, 'Doctor List', 'Doctor List', 'rp_doctor_sp', '', 'forms/report', 'search', '2022-12-22 18:20:50', 'fa fa-user-md', 1, 0, NULL, 1, 'user', 3, 'Doctor-'),
(1454, 725, 'forms/list', 3, 0, 'Hospital List', 'Hospital List', 'rp_hospital_sp', '', 'forms/report', 'search', '2022-12-22 18:21:47', 'fa fa-home', 1, 0, NULL, 1, 'user', 3, 'Hospital-'),
(1455, 726, 'forms/list', 3, 0, 'Department List', 'Department List', 'rp_department_sp', '', 'forms/report', 'search', '2022-12-22 18:26:31', 'fa fa-home', 1, 0, NULL, 1, 'user', 3, 'Department-'),
(1456, 727, 'forms/list', 3, 0, 'Patient List', 'Patient List', 'rp_patient_sp', '', 'forms/report', 'search', '2022-12-22 18:28:45', 'fa fa-users', 1, 0, NULL, 1, 'user', 3, 'Patient-'),
(1457, 728, 'forms/list', 3, 0, 'Ticket List', 'Ticket List', 'rp_ticket_sp', '', 'forms/report', 'search', '2022-12-22 18:29:29', 'fa fa-list-alt', 1, 0, NULL, 1, 'user', 3, 'Ticket-'),
(1458, 729, 'forms/list', 3, 0, 'App Patient List', 'App Patient List', 'rp_app_patient_sp', '', 'forms/report', 'search', '2022-12-22 18:32:22', 'fa fa-user', 1, 0, NULL, 1, 'user', 3, 'App-Patient-'),
(1459, 730, 'forms/list', 3, 0, 'Evc App Receipt List', 'Evc App Receipt List', 'rp_evc_app_receipt_sp', '', 'forms/report', 'search', '2022-12-22 18:33:20', 'fa fa-money', 1, 0, NULL, 1, 'user', 3, 'Evc-App-Receipt-'),
(1460, 731, 'forms/create', 2, 0, 'New Expense', 'New Expense', 'expense_sp', '', 'forms/save', 'save', '2022-12-29 21:24:44', 'fa fa-money', 1, 0, NULL, 1, 'user', 3, 'New-Expense'),
(1461, 732, 'forms/list', 3, 0, 'FAQ List', 'FAQ List', 'rp_faq_sp', '', 'forms/report', 'search', '2022-12-31 09:14:38', 'fa fa-list', 1, 0, NULL, 1, 'user', 3, 'FAQ-'),
(1462, 733, 'forms/list', 3, 0, 'Expense List', 'Expense List', 'rp_expense_sp', '', 'forms/report', 'search', '2022-12-31 09:15:14', 'fa fa-money', 1, 0, NULL, 1, 'user', 3, 'Expense-'),
(1463, 734, 'forms/create', 2, 0, 'New FAQ', 'New FAQ', 'faq_sp', '', 'forms/save', 'Save', '2023-01-01 07:47:19', 'fa fa-question-circle', 1, 0, NULL, 1, 'user', 2, 'New-FAQ'),
(1464, 735, 'forms/list', 3, 0, 'Search Ticket', 'Search Ticket', 'search_ticket_sp', '', 'forms/report', 'Search', '2023-01-05 06:55:59', 'fa fa-search-plus', 1, 0, NULL, 1, 'user', 2, 'Search-Ticket'),
(1465, 736, 'forms/list', 3, 0, 'Blood List', 'Blood List', 'rp_blood_sp', '', 'forms/report', 'search', '2023-01-06 14:35:36', 'fa fa-expand', 1, 0, NULL, 1, 'user', 3, 'Blood-'),
(1466, 737, 'forms/list', 3, 0, 'Agent  List', 'Agent List', 'rp_agent_sp', '', 'forms/report', 'search', '2023-01-06 14:40:23', 'fa fa-desktop', 1, 0, NULL, 1, 'user', 3, 'Agent--'),
(1467, 738, 'forms/create', 1, 81, 'Create campaign', 'campaign Form', 'campaign_sp', 'campaign Form', 'forms/save', 'Save', '2023-01-24 08:31:19', 'fa fa-plus', 1, 0, NULL, 1, 'user', 2, '-campaign');

--
-- Triggers `ktc_link`
--
DELIMITER $$
CREATE TRIGGER `auto_grant_link` AFTER INSERT ON `ktc_link` FOR EACH ROW INSERT ignore INTO `ktc_user_permission`( `link_id`, `user_id`, `granted_user_id`, `action`,company_id) VALUES (NEW.auto_id,NEW.user_id,NEW.user_id,'link',NEW.company_id)
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `del_param` BEFORE DELETE ON `ktc_link` FOR EACH ROW BEGIN
DELETE FROM ktc_parameter where link_id = OLD.auto_id and company_id = OLD.company_id;
DELETE FROM ktc_user_permission where link_id = OLD.auto_id and action = 'link' and company_id = OLD.company_id;


END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `ktc_parameter`
--

CREATE TABLE `ktc_parameter` (
  `id` int(11) NOT NULL,
  `parameter` varchar(50) NOT NULL,
  `type` varchar(50) NOT NULL COMMENT 'html element(dropdown/radio/checkbox or default text)',
  `action` varchar(50) NOT NULL COMMENT 'used for dropdown/radio',
  `placeholder` varchar(100) NOT NULL COMMENT 'input placeholder',
  `lable` varchar(100) NOT NULL COMMENT 'input label',
  `class` varchar(50) NOT NULL COMMENT 'input class in case',
  `size` varchar(200) NOT NULL,
  `load_action` varchar(50) NOT NULL,
  `help_text` varchar(250) NOT NULL,
  `default_value` varchar(250) NOT NULL,
  `is_required` varchar(50) NOT NULL DEFAULT 'required',
  `description` varchar(250) NOT NULL DEFAULT '',
  `link_id` int(11) NOT NULL COMMENT 'stored procedure name',
  `company_id` int(11) NOT NULL DEFAULT '17',
  `table` varchar(50) NOT NULL,
  `columns` varchar(250) NOT NULL,
  `sample` varchar(250) NOT NULL,
  `icon` varchar(50) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ktc_parameter`
--

INSERT INTO `ktc_parameter` (`id`, `parameter`, `type`, `action`, `placeholder`, `lable`, `class`, `size`, `load_action`, `help_text`, `default_value`, `is_required`, `description`, `link_id`, `company_id`, `table`, `columns`, `sample`, `icon`, `date`) VALUES
(443, 'user_p', 'hidden', '', '', 'User', '', '', '', '', '', 'required', '', 32, 1, '', '', '', '', '2018-12-13 08:39:28'),
(444, 'acc_p', 'dropdown', 'ktcget_dr', '', 'Action', '', '', '', '', '%', 'required', '', 32, 1, '', '', '', '', '2018-12-13 08:39:28'),
(596, 'value_p', 'Element Type', '', '', 'Value', '', '', '', '', '', 'required', '', 54, 1, '', '', '', '', '2019-01-09 02:45:56'),
(597, 'text_p', 'Element Type', '', '', 'Text', '', '', '', '', '', 'required', '', 54, 1, '', '', '', '', '2019-01-09 02:45:56'),
(598, 'action_p', 'Element Type', '', '', 'Action', '', '', '', '', '', 'required', '', 54, 1, '', '', '', '', '2019-01-09 02:45:56'),
(599, 'description_p', 'Element Type', '', '', 'Description', '', '', '', '', '', '', '', 54, 1, '', '', '', '', '2019-01-09 02:45:56'),
(695, 'user_p', 'hidden', '', '', 'User', '', '', '', '', '', 'required', '', 21, 1, '', '', '', '', '2019-01-22 04:57:23'),
(696, 'param_p', 'Element Type', '', '', 'Param', '', '', '', '', '', 'required', '', 21, 1, '', '', '', '', '2019-01-22 04:57:23'),
(724, 'user_p', 'hidden', '', '', 'User', '', '', '', '', '', 'required', '', 18, 1, '', '', '', '', '2019-01-23 05:46:58'),
(725, 'user2_p', 'dropdown', 'user', '', 'Choose User', '', '', '', '', '', 'required', '', 18, 1, '', '', '', '', '2019-01-23 05:46:58'),
(816, 'table_p', 'dropdown', 'table', '', 'Table', '', '', '', '', '', 'required', '', 74, 1, '', '', '', '', '2019-02-03 02:04:17'),
(968, 'parameter_p', 'Element Type', '', '', 'Parameter', '', '', '', '', '', 'required', '', 7, 1, '', '', '', '', '2019-03-10 09:50:45'),
(969, 'label_p', 'Element Type', '', '', 'Label', '', '', '', '', '', 'required', '', 7, 1, '', '', '', '', '2019-03-10 09:50:45'),
(970, 'type_p', 'Element Type', '', '', 'Type', '', '', '', '', '', 'required', '', 7, 1, '', '', '', '', '2019-03-10 09:50:45'),
(971, 'action_p', 'Element Type', '', '', 'Action', '', '', '', '', '', '', '', 7, 1, '', '', '', '', '2019-03-10 09:50:45'),
(972, 'class_p', 'dropdown', '', '', 'Class', '', '', '', '', '', '', '', 7, 1, '', '', '', '', '2019-03-10 09:50:45'),
(973, 'size_p', 'Element Type', '', '', 'Size', '', '', '', '', '', '', '', 7, 1, '', '', '', '', '2019-03-10 09:50:45'),
(974, 'load_action_p', 'Element Type', '', '', 'Loadaction', '', '', '', '', '', '', '', 7, 1, '', '', '', '', '2019-03-10 09:50:45'),
(975, 'user_p', 'hidden', '', '', 'User', '', '', '', '', '', 'required', '', 7, 1, '', '', '', '', '2019-03-10 09:50:45'),
(976, 'placeholder_p', 'Element Type', '', '', 'Placeholder', 'varchar', '', '', '', '', '', '', 7, 1, '', '', '', '', '2019-03-10 09:50:45'),
(6430, 'href_p', 'dropdown', '', '', 'Href', '', '', '', '', '', 'required', '', 270, 1, '', '', '', '', '2019-05-04 11:20:03'),
(6431, 'title_p', 'Element Type', '', '', 'Title', '', '', '', '', '', 'required', '', 270, 1, '', '', '', '', '2019-05-04 11:20:03'),
(6432, 'category_p', 'dropdown', 'ktc_category|', '', 'Category', 'load get_info', '', 'category_id,ktc_sub_category-', '', '', 'required', '', 270, 1, '', '', '', '', '2019-05-04 11:20:03'),
(6433, 'sub_category_p', 'dropdown', 'ktc_sub_category', '', 'Subcategory', '', '', '', '', '', '', '', 270, 1, '', '', '', '', '2019-05-04 11:20:03'),
(6434, 'text_p', 'Element Type', '', '', 'Text', '', '', '', '', '', '', '', 270, 1, '', '', '', '', '2019-05-04 11:20:03'),
(6435, 'sp_p', 'autocomplete', '', '', 'Sp', 'get_info', '', '', '', '0', '', '', 270, 1, '', '', '', '', '2019-05-04 11:20:03'),
(6436, 'description_p', 'Element Type', '', '', 'Description', '', '', '', '', '', '', '', 270, 1, '', '', '', '', '2019-05-04 11:20:03'),
(6437, 'form_action_p', 'radio', 'form_', '', 'Formaction', '', '', '', '', 'c', 'required', '', 270, 1, '', '', '', '', '2019-05-04 11:20:03'),
(6438, 'btn_p', 'Element Type', '', 'Create, Save , Add ....', 'Btn', '', '', '', '', 'c', 'required', '', 270, 1, '', '', '', '', '2019-05-04 11:20:03'),
(6439, 'link_icon_p', 'autocomplete', '', '', 'Linkicon', '', '', '', '', '', '', '', 270, 1, '', '', '', '', '2019-05-04 11:20:03'),
(6440, 'user_p', 'hidden', '', '', 'User', '', '', '', '', '', 'required', '', 270, 1, '', '', '', '', '2019-05-04 11:20:03'),
(6441, 'level_p', 'Element Type', '', '', 'Level', 'varchar', '', '', '', '', 'required', '', 270, 1, '', '', '', '', '2019-05-04 11:20:03'),
(6644, 'user_p', 'hidden', '', '', 'User', '', '', '', '', '', 'required', '', 57, 1, '', '', '', '', '2019-05-18 11:50:42'),
(6645, 'chart_p', 'Element Type', '', '', 'Chart', '', '', '', '', '', 'required', '', 57, 1, '', '', '', '', '2019-05-18 11:50:42'),
(6646, 'co_p', 'hidden_u', '', '', 'Co', 'int', '', '', '', '', 'required', '', 57, 1, '', '', '', '', '2019-05-18 11:50:42'),
(6950, 'category_p', 'text', '', '', 'Category', '', '', '', '', '', 'required', '', 37, 1, '', '', '', '', '2019-06-23 02:48:36'),
(6951, 'icon_p', 'autocomplete', 'icon', '', 'Icon', '', '', '', '', '', '', '', 37, 1, '', '', '', '', '2019-06-23 02:48:36'),
(6952, 'user_p', 'hidden', '', '', 'User', '', '', '', '', '', 'required', '', 37, 1, '', '', '', '', '2019-06-23 02:48:36'),
(6953, 'co_p', 'hidden_u', 'company', '', 'Co', 'int', '', '', '', '', 'required', '', 37, 1, '', '', '', '', '2019-06-23 02:48:36'),
(6994, 'co_p', 'dropdown', 'company', '', 'Co', 'load', '', 'company_id,ktc_category-', '', '', 'required', '', 22, 1, '', '', '', '', '2019-07-05 00:56:54'),
(6995, 'category_p', 'dropdown', 'ktc_category|', '', 'Category', 'load', '', 'category_id,ktc_sub_category-', '', '', 'required', '', 22, 1, '', '', '', '', '2019-07-05 00:56:54'),
(6996, 'sub_category_p', 'dropdown', 'ktc_sub_category', '', 'Subcategory', 'load', '', 'sub_category_id,ktc_link-		', '', '', '', '', 22, 1, '', '', '', '', '2019-07-05 00:56:54'),
(6997, 'link_p', 'dropdown', 'ktc_link|', '', 'Link', 'load2_me', '', 'category_id,ktc_link-', '', '', 'required', '', 22, 1, '', '', '', '', '2019-07-05 00:56:54'),
(6998, 'parameter_p', 'Element Type', '', '', 'Parameter', 'varchar', '', '', '', '%', '', '', 22, 1, '', '', '', '', '2019-07-05 00:56:54'),
(7008, 'href_p', 'dropdown', 'href_', '', 'Href', 'get_info', '', '', '', '', 'required', '', 1, 1, '', '', 'uploads/departement of hms.txt', '', '2019-07-07 00:03:49'),
(7009, 'title_p', 'Element Type', '', '', 'Title', '', '', '', '', '', 'required', '', 1, 1, '', '', '', '', '2019-07-07 00:03:49'),
(7010, 'category_p', 'dropdown', 'ktc_category|', '', 'Category', 'load', '', 'category_id,ktc_sub_category-', '', '', 'required', '', 1, 1, '', '', '', '', '2019-07-07 00:03:49'),
(7011, 'sub_category_p', 'dropdown', 'ktc_sub_category', '', 'Subcategory', '', '', '', '', '', '', '', 1, 1, '', '', '', '', '2019-07-07 00:03:49'),
(7012, 'text_p', 'Element Type', '', '', 'Text', '', '', '', '', '', '', '', 1, 1, '', '', '', '', '2019-07-07 00:03:49'),
(7013, 'sp_p', 'autocomplete', 'sp', '', 'Sp', 'get_info', '', '', '', '', '', '', 1, 1, '', '', '', '', '2019-07-07 00:03:49'),
(7014, 'description_p', 'Element Type', '', '', 'Description', '', '', '', '', '', '', '', 1, 1, '', '', '', '', '2019-07-07 00:03:49'),
(7015, 'form_action_p', 'radio', 'form_', '', 'Formaction', '', '', '', '', '', 'required', '', 1, 1, '', '', '', '', '2019-07-07 00:03:49'),
(7016, 'btn_p', 'Element Type', '', 'Create, Save , Add ....', 'Btn', '', '', '', '', '', 'required', '', 1, 1, '', '', '', '', '2019-07-07 00:03:49'),
(7017, 'link_icon_p', 'autocomplete', 'icon', '', 'Linkicon', '', '', '', '', '', '', '', 1, 1, '', '', '', '', '2019-07-07 00:03:49'),
(7018, 'user_p', 'hidden', '', '', 'User', '', '', '', '', '', 'required', '', 1, 1, '', '', '', '', '2019-07-07 00:03:49'),
(7019, 'co_p', 'hidden_u', '', '', 'Co', '', '', '', '', '', 'required', '', 1, 1, '', '', '', '', '2019-07-07 00:03:49'),
(7026, 'co_p', 'hidden_u', 'company', '', 'Co', 'load', '', 'company_id,ktc_category-', '', '', 'required', '', 16, 1, '', '', '', '', '2019-07-07 01:08:35'),
(7027, 'category_p', 'dropdown', 'ktc_category|', '', 'Category', 'load', '', 'category_id,ktc_sub_category-', '', '', 'required', '', 16, 1, '', '', '', '', '2019-07-07 01:08:35'),
(7028, 'sub_category_p', 'dropdown', 'ktc_sub_category', '', 'Subcategory', 'load', '', 'sub_category_id,ktc_link-', '', '', '', '', 16, 1, '', '', '', '', '2019-07-07 01:08:35'),
(7029, 'link_p', 'dropdown', 'ktc_link|', '', 'Link', 'load_me', '', 'category_id,ktc_link-', '', '', 'required', '', 16, 1, '', '', '', '', '2019-07-07 01:08:35'),
(7030, 'sp_p', 'autocomplete', 'sp', '', 'Sp', '', '', '', '', '%', '', '', 16, 1, '', '', '', '', '2019-07-07 01:08:35'),
(7031, 'user_p', 'hidden', '', '', 'User', '', '', '', '', '', 'required', '', 16, 1, '', '', '', '', '2019-07-07 01:08:35'),
(7289, 'co_p', 'hidden_u', 'company', '', 'Co', 'load', '', 'company_id,ktc_category-', '', '', 'required', '', 59, 1, '', '', '', '', '2019-07-09 06:32:09'),
(7290, 'category_p', 'dropdown', 'ktc_category|', '', 'Category', 'load get_info', '', 'category_id,ktc_sub_category-', '', '', 'required', '', 59, 1, '', '', '', '', '2019-07-09 06:32:09'),
(7291, 'sub_category_p', 'dropdown', 'ktc_sub_category', '', 'Subcategory', 'load', '', 'sub_category_id,ktc_link-', '', '', 'required', '', 59, 1, '', '', '', '', '2019-07-09 06:32:09'),
(7292, 'link_p', 'dropdown', 'ktc_link|', '', 'Link', 'load_me', '', 'category_id,ktc_link-', '', '', 'required', '', 59, 1, '', '', '', '', '2019-07-09 06:32:09'),
(7293, 'text_p', 'Element Type', '', '', 'Text', '', '', '', '', '', 'required', '', 59, 1, '', '', '', '', '2019-07-09 06:32:09'),
(7294, 'title_p', 'Element Type', '', '', 'Title', '', '', '', '', '', 'required', '', 59, 1, '', '', '', '', '2019-07-09 06:32:09'),
(7295, 'co2_p', 'hidden_u', '', '', 'Co2', 'load', '', 'company_id,ktc_category-', '', '', 'required', '', 59, 1, '', '', '', '', '2019-07-09 06:32:09'),
(7296, 'category2_p', 'dropdown', 'ktc_category|', '', 'Category2', 'load', '', 'category_id,ktc_sub_category-', '', '', 'required', '', 59, 1, '', '', '', '', '2019-07-09 06:32:09'),
(7297, 'sub_category2_p', 'dropdown', 'ktc_sub_category', '', 'Subcategory2', '', '', '', '', '', 'required', '', 59, 1, '', '', '', '', '2019-07-09 06:32:09'),
(7298, 'user_p', 'hidden', '', '', 'User', '', '', '					\n					  \n					\n\n					\n					  ', '', '', 'required', '', 59, 1, '', '', '', '', '2019-07-09 06:32:09'),
(7552, 'user_p', 'hidden', '', '', 'User', '', '', '', '', '', 'required', '', 52, 1, '', '', '', '', '2019-07-26 00:07:38'),
(7553, 'pass_p', 'password', '', '', 'Old Password', '', '', '', '', '', 'required', '', 52, 1, '', '', '', '', '2019-07-26 00:07:38'),
(7554, 'new_p', 'password', '', '', 'New Password', 'password', '', '', '', '', 'required', '', 52, 1, '', '', '', '', '2019-07-26 00:07:38'),
(7555, 'pass2_p', 'password', '', '', 'Confirm Password', 'on-keyup', '', '', '', '', 'required', '', 52, 1, '', '', '', '', '2019-07-26 00:07:38'),
(7556, 'co_p', 'hidden_u', '', '', 'Co', '', '', '', '', '', 'required', '', 52, 1, '', '', '', '', '2019-07-26 00:07:38'),
(7559, 'user_p', 'dropdown', 'user', '', 'Choose User', '', '', '', '', '', 'required', '', 53, 1, '', '', '', '', '2019-07-26 00:07:39'),
(7560, 'pass_p', 'hidden_ele', '', '', 'Pass', '', '', '', '', 'reset_reset_ktc', 'required', '', 53, 1, '', '', '', '', '2019-07-26 00:07:39'),
(7561, 'new_p', 'password', '', '', 'New Password', 'password', '', '', '', '', 'required', '', 53, 1, '', '', '', '', '2019-07-26 00:07:39'),
(7562, 'pass2_p', 'password', '', '', 'Confirm Password', 'on-keyup', '', '', '', '', 'required', '', 53, 1, '', '', '', '', '2019-07-26 00:07:39'),
(7563, 'co_p', 'hidden_u', '', '', 'Co', '', '', '', '', '', 'required', '', 53, 1, '', '', '', '', '2019-07-26 00:07:39'),
(7844, '_company_id', 'hidden_u', '', '', 'Company', '', '', '', '', '', 'required', '', 419, 1, '', '', '', '', '2019-11-17 15:26:53'),
(7845, '_employee_id', 'dropdown', '', '', 'Employee', '', '', '', '', '', 'required', '', 419, 1, '', '', '', '', '2019-11-17 15:26:53'),
(7846, '_name', 'Element Type', '', 'Ex. Ali Omar Hassan', 'Name', 'text', '3', '', '', '', 'required', '', 419, 1, '', '', '', '', '2019-11-17 15:26:53'),
(7847, '_tell', 'Element Type', '', '', 'Tell', 'number', '4', '', '', '', 'required', '', 419, 1, '', '', '', '', '2019-11-17 15:26:53'),
(7848, '_address', 'Element Type', '', '', 'Address', 'varchar', '4', '', '', '', 'required', '', 419, 1, '', '', '', '', '2019-11-17 15:26:53'),
(7849, '_user_id', 'hidden', 'user|', '', 'User', '', '', '', '', '', 'required', '', 419, 1, '', '', '', '', '2019-11-17 15:26:53'),
(7850, '_date', 'date', '', '', 'Date', '', '', '', '', '', 'required', '', 419, 1, '', '', '', '', '2019-11-17 15:26:53'),
(8451, 'chart_p', 'Element Type', '', '', 'Chart Action', '', '', '', '', '', 'required', '', 55, 1, '', '', '', '', '2020-07-29 08:15:35'),
(8452, 'icon_p', 'autocomplete', 'icon', '', 'Icon', '', '', '', '', '', '', '', 55, 1, '', '', '', '', '2020-07-29 08:15:35'),
(8453, 'class_color_p', 'dropdown', 'chart_bg_', '', 'Classcolor', '', '', '', '', '', 'required', '', 55, 1, '', '', '', '', '2020-07-29 08:15:35'),
(8454, 'description_p', 'textarea', '', '', 'Description', '', '', '', '', '', '', '', 55, 1, '', '', '', '', '2020-07-29 08:15:35'),
(8455, 'type_p', 'hidden_ele', '', '', 'Type', '', '', '', '', 'user', 'required', '', 55, 1, '', '', '', '', '2020-07-29 08:15:35'),
(8456, 'position_p', 'hidden_ele', '', '', 'Position', '', '', '', '', '', 'required', '', 55, 1, '', '', '', '', '2020-07-29 08:15:35'),
(8457, 'co_p', 'hidden_u', '', '', 'Co', '', '', '', '', '', 'required', '', 55, 1, '', '', '', '', '2020-07-29 08:15:35'),
(8458, 'user_p', 'hidden', '', '', 'User', '', '', '', '', '', 'required', '', 55, 1, '', '', '', '', '2020-07-29 08:15:35'),
(8618, 'user_p', 'hidden', '', '', 'User', '', '', '					\n					  \n					\n\n					\n					  ', '', '', 'required', '', 14, 1, '', '', '', '', '2020-08-02 20:22:23'),
(8619, 'category_p', 'dropdown', 'ktc_category|', '', 'Category', 'load', '', 'category_id,ktc_sub_category-', '', '', 'required', '', 14, 1, '', '', '', '', '2020-08-02 20:22:23'),
(8620, 'sub_category_p', 'dropdown', 'ktc_sub_category', '', 'Subcategory', 'load', '', 'sub_category_id,ktc_link-', '', '', 'required', '', 14, 1, '', '', '', '', '2020-08-02 20:22:23'),
(8621, 'link_p', 'dropdown', 'ktc_link|', '', 'Link', 'load_me', '', 'category_id,ktc_link-', '', '', 'required', '', 14, 1, '', '', '', '', '2020-08-02 20:22:23'),
(8622, 'co_p', 'hidden_u', '', '', 'Co', '', '', '', '', '', 'required', '', 14, 1, '', '', '', '', '2020-08-02 20:22:23'),
(8837, '_company_id', 'hidden_u', 'company', '', 'Company', '', '', '', '', '', 'required', '', 459, 1, '', '', '', '', '2020-08-25 09:09:51'),
(8838, '_company2_id', 'dropdown', 'company2|', '', 'Company2', '', '', '', '', '', 'required', '', 459, 1, '', '', '', '', '2020-08-25 09:09:51'),
(8839, '_user_id', 'hidden', 'user|', '', 'User', '', '', '', '', '', 'required', '', 459, 1, '', '', '', '', '2020-08-25 09:09:51'),
(9114, 'co_p', 'hidden_u', 'company', '', 'Co', 'load', '', 'company_id,ktc_category-', '', '', 'required', '', 460, 1, '', '', '', '', '2020-08-25 10:17:20'),
(9115, 'category_p', 'dropdown', 'ktc_category|', '', 'Category', 'load get_info', '', 'category_id,ktc_sub_category-', '', '', 'required', '', 460, 1, '', '', '', '', '2020-08-25 10:17:20'),
(9116, 'sub_category_p', 'dropdown', 'ktc_sub_category', '', 'Subcategory', 'load', '', 'sub_category_id,ktc_link-', '', '', 'required', '', 460, 1, '', '', '', '', '2020-08-25 10:17:20'),
(9117, 'link_p', 'dropdown', 'ktc_link|', '', 'Link', 'load2_me', '', 'category_id,ktc_link-', '', '', 'required', '', 460, 1, '', '', '', '', '2020-08-25 10:17:20'),
(9118, 'co2_p', 'Element Type', '', '', 'Co2', 'load', '', 'company_id,ktc_category-', '', '', 'required', '', 460, 1, '', '', '', '', '2020-08-25 10:17:20'),
(9119, 'category2_p', 'Element Type', '', '', 'Category2', 'load', '', 'category_id,ktc_sub_category-', '', '', 'required', '', 460, 1, '', '', '', '', '2020-08-25 10:17:20'),
(9120, 'sub_category2_p', 'Element Type', '', '', 'Subcategory2', '', '', '', '', '', 'required', '', 460, 1, '', '', '', '', '2020-08-25 10:17:20'),
(9121, 'user_p', 'hidden', '', '', 'User', '', '', '					\n					  \n					\n\n					\n					  ', '', '', 'required', '', 460, 1, '', '', '', '', '2020-08-25 10:17:20'),
(9129, 'co_p', 'hidden_u', 'company', '', 'Co', 'load', '', 'company_id,ktc_category-', '', '', 'required', '', 36, 1, '', '', '', '', '2020-08-25 10:27:15'),
(9130, 'category_p', 'dropdown', 'ktc_category|', '', 'Category', '', '', '', '', '', 'required', '', 36, 1, '', '', '', '', '2020-08-25 10:27:15'),
(9131, 'name_p', 'Element Type', '', '', 'Name', '', '', '', '', '', 'required', '', 36, 1, '', '', '', '', '2020-08-25 10:27:15'),
(9132, 'icon_p', 'autocomplete', 'icon', '', 'Icon', '', '', '', '', '', '', '', 36, 1, '', '', '', '', '2020-08-25 10:27:15'),
(9133, 'user_p', 'hidden', '', '', 'User', '', '', '', '', '', 'required', '', 36, 1, '', '', '', '', '2020-08-25 10:27:15'),
(9782, 'co_p', 'hidden_u', 'company', '', 'Co', 'load', '', 'company_id,ktc_user-', '', '', 'required', '', 33, 1, '', '', '', '', '2021-03-30 08:02:31'),
(9783, 'user_p', 'dropdown', 'user', '', 'User', '', '', '', '', '', 'required', '', 33, 1, '', '', '', '', '2021-03-30 08:02:31'),
(9785, 'co_p', 'hidden_u', '', '', 'Co', 'int', '', '', '', '', 'required', '', 35, 1, '', '', '', '', '2021-03-30 08:05:50'),
(9786, 'user_p', 'dropdown', 'user', '', 'User', '', '', '', '', '', 'required', '', 35, 1, '', '', '', '', '2021-03-30 08:05:50'),
(9787, 'grant_p', 'hidden', 'user', '', 'User', '', '', '', '', '', 'required', '', 35, 1, '', '', '', '', '2021-03-30 08:05:50'),
(9788, 'user_p', 'hidden', '', '', 'User', '', '', '', '', '', 'required', '', 485, 1, '', '', '', '', '2021-03-30 08:09:13'),
(9789, 'table_p', 'Element Type', '', '', 'Table', '', '', '', '', '', 'required', '', 485, 1, '', '', '', '', '2021-03-30 08:09:13'),
(9790, 'from_p', 'date', '', '', 'From', '', '', '', '', '', 'required', '', 485, 1, '', '', '', '', '2021-03-30 08:09:13'),
(9791, 'to_p', 'Element Type', '', '', 'To', '', '', '', '', '', 'required', '', 485, 1, '', '', '', '', '2021-03-30 08:09:13'),
(9795, 'user_p', 'hidden', '', '', 'User', '', '', '', '', '', 'required', '', 486, 1, '', '', '', '', '2021-03-30 08:10:14'),
(9796, 'table_p', 'Element Type', '', '', 'Table', '', '', '', '', '', 'required', '', 486, 1, '', '', '', '', '2021-03-30 08:10:14'),
(9797, 'from_p', 'date', '', '', 'From', '', '', '', '', '', 'required', '', 486, 1, '', '', '', '', '2021-03-30 08:10:14'),
(9798, 'to_p', 'Element Type', '', '', 'To', '', '', '', '', '', 'required', '', 486, 1, '', '', '', '', '2021-03-30 08:10:14'),
(12384, 'co_p', 'hidden_u', 'company', '', 'Co', 'load', '', 'company_id,ktc_category-', '', '', 'required', '', 56, 1, '', '', '', '', '2021-04-21 10:36:11'),
(12385, 'category_p', 'dropdown', 'ktc_category|', '', 'Category', '', '', '', '', '', 'required', '', 56, 1, '', '', '', '', '2021-04-21 10:36:11'),
(12386, 'type_p', 'dropdown', 'menu_', '', 'Type', '', '', '', '', '', 'required', '', 56, 1, '', '', '', '', '2021-04-21 10:36:11'),
(12387, 'user_p', 'hidden', '', '', 'User', '', '', '', '', '', 'required', '', 56, 1, '', '', '', '', '2021-04-21 10:36:11'),
(15799, '_user_id', '', '', '', 'hidden', '', '', '', '', '', 'required', '', 612, 1, '', '', '', '', '2022-02-13 17:15:04'),
(15800, '_type', '', '', 'PROCEDURE, FUNCTIOB', 'Type', 'varchar', '', '', '', 'PROCEDURE', '', '', 612, 1, '', '', '', '', '2022-02-13 17:15:04'),
(15801, '_action', 'hidden_ele', '', '', 'Action', 'varchar', '', '', '', '', '', '', 612, 1, '', '', '', '', '2022-02-13 17:15:04'),
(15802, '_domain', 'domain', '', '', 'Domain', 'varchar', '4', '', '', '', 'required', '', 612, 1, '', '', '', '', '2022-02-13 17:15:04'),
(16519, '_company_id', 'dropdown', 'all_company', '', 'Company', 'load', '', 'company_id,ktc_category-', '', '', 'required', '', 622, 1, '', '', '', '', '2022-03-23 10:47:42'),
(16522, '_user_id', 'hidden', '', '', 'User Id', 'int', '', '', '', '', 'required', '', 622, 1, '', '', '', '', '2022-03-23 10:47:42'),
(17263, 'p_auto_id', 'hidden_ele', 'to|', '', 'To', '', '', '', '', '', 'required', '', 649, 1, '', '', '', '', '2022-08-19 23:01:43'),
(17266, 'p_company_id', 'hidden_u', 'company', '', 'Co', 'load', '', 'company_id,ktc_user-', '', '', 'required', '', 649, 1, '', '', '', '', '2022-08-19 23:01:43'),
(17269, 'p_name', 'text', '', '', 'Name', 'text', '3', '', '', '', 'required', '', 649, 1, '', '', '', '', '2022-08-19 23:01:43'),
(17272, 'p_type', 'text', '', '', 'Type', 'varchar', '', '', '', '', 'required', '', 649, 1, '', '', '', '', '2022-08-19 23:01:43'),
(17275, 'p_user_id', 'hidden', '', '', 'User Id', 'int', '', '', '', '', 'required', '', 649, 1, '', '', '', '', '2022-08-19 23:01:43'),
(17278, 'p_date', 'date', '', '', 'Date', '', '', '', '', '', 'required', '', 649, 1, '', '', '', '', '2022-08-19 23:01:43'),
(17305, '_id', 'int', '', '', ' Id', 'int', '', '', '', '', 'required', '', 651, 1, '', '', '', '', '2022-09-11 17:25:13'),
(17308, '_auto_id', 'hidden_ele', '', '', 'To', '', '', '', '', '', 'required', '', 651, 1, '', '', '', '', '2022-09-11 17:25:13'),
(17311, '_company_id', 'hidden_u', 'all_company', '', 'Company', 'load', '', 'company_id,ktc_category-', '', '', 'required', '', 651, 1, '', '', '', '', '2022-09-11 17:25:13'),
(17314, '_student_id', 'autocomplete', 'student', '', 'Student', '', '', '', '', '', 'required', '', 651, 1, '', '', '', '', '2022-09-11 17:25:13'),
(17317, '_course_id', 'dropdown', 'course_teacher', '', 'Course/Lecture', 'load', '', 'course_teacher_id,chapter-', '', '', 'required', '', 651, 1, '', '', '', '', '2022-09-11 17:25:13'),
(17320, '_semester_id', 'dropdown', 'general,type,semester', '', 'Semester', 'load2', '', 'course_department_load2', '', '', 'required', '', 651, 1, '', '', '', '', '2022-09-11 17:25:13'),
(17323, '_lecture_id', 'hidden', '', '', 'Lecture', 'req', '', '', '', '', 'required', '', 651, 1, '', '', '', '', '2022-09-11 17:25:13'),
(17326, '_day_id', 'dropdown', 'day_', '', 'Day', '', '', '', '', '', 'required', '', 651, 1, '', '', '', '', '2022-09-11 17:25:13'),
(17329, '_period_id', 'int', '', '', 'Eriod Id', 'int', '', '', '', '', 'required', '', 651, 1, '', '', '', '', '2022-09-11 17:25:13'),
(17332, '_date', 'date', '', '', 'Date', '', '', '', '', '', 'required', '', 651, 1, '', '', '', '', '2022-09-11 17:25:13'),
(17335, '_absent_reason_id', 'varchar', '', 'Enter fee type', ' Reason', 'varchar', '', '', '', '', 'required', '', 651, 1, '', '', '', '', '2022-09-11 17:25:13'),
(17385, '_auto_id', 'hidden_ele', 'old_user', 'Old Database User ID', 'User ID', '', '', '', '', '', '', '', 41, 1, '', '', '', '', '2022-09-15 09:53:15'),
(17388, 'full_name_p', 'text', '', '', 'Fullname', '', '', '', '', '', 'required', '', 41, 1, '', '', '', '', '2022-09-15 09:53:15'),
(17391, 'username_p', 'email', '', '', 'Username', '', '', '', '', '', 'required', '', 41, 1, '', '', '', '', '2022-09-15 09:53:15'),
(17394, 'password_p', 'password', '', '', 'Password', 'password', '', '', '', '', 'required', '', 41, 1, '', '', '', '', '2022-09-15 09:53:15'),
(17397, 'confirm_p', 'password', '', '', 'Confirm', 'on-keyup', '', '', '', '', 'required', '', 41, 1, '', '', '', '', '2022-09-15 09:53:15'),
(17400, 'tell_p', 'number', '', '', 'Tell', '', '', '', '', '', 'required', '', 41, 1, '', '', '', '', '2022-09-15 09:53:15'),
(17403, 'pic_p', 'file', 'images', '', 'Image', '', '', '', '', '.2', 'required', '', 41, 1, '', '', '', '', '2022-09-15 09:53:15'),
(17406, 'status_p', 'hidden_ele', '', '', 'Status', '', '', '', '', '1', '', '', 41, 1, '', '', '', '', '2022-09-15 09:53:15'),
(17409, 'email_p', 'email', '', '', 'Email', '', '', '', '', '', 'required', '', 41, 1, '', '', '', '', '2022-09-15 09:53:15'),
(17412, 'user_p', 'hidden', '', '', 'User', '', '', '', '', '', 'required', '', 41, 1, '', '', '', '', '2022-09-15 09:53:15'),
(17415, '_company_id', 'hidden_u', '', '', 'Company', '', '', '', '', '', 'required', '', 41, 1, '', '', '', '', '2022-09-15 09:53:15'),
(17418, '_branch_id', 'dropdown', 'branch|', '', 'Branch', '', '', '', '', '', 'required', '', 41, 1, '', '', '', '', '2022-09-15 09:53:15'),
(17421, '_domain', 'hidden_ele', '', '', 'Domain', 'varchar', '', '', '', '', '', '', 41, 1, '', '', '', '', '2022-09-15 09:53:15'),
(17424, '_level', 'dropdown', 'general,type,office', '', 'Choose Office', '', '', '', '', 'Admin', 'required', '', 41, 1, '', '', '', '', '2022-09-15 09:53:15'),
(17663, '_auto_id', 'date', 'to|', '', 'To', '', '', '', '', '', 'required', '', 669, 1, '', '', '', '', '2022-09-28 19:11:24'),
(17664, '_company_id', 'hidden_u', 'all_company', '', 'Company', 'load', '', 'company_id,ktc_category-', '', '', 'required', '', 669, 1, '', '', '', '', '2022-09-28 19:11:24'),
(17665, '_chapter_id', 'dropdown', 'chapter|', '', 'Chapter', '', '', '', '', '', 'required', '', 669, 1, '', '', '', '', '2022-09-28 19:11:24'),
(17666, '_name', 'text', '', 'eg. Morning Shift, Noon Shift, Night Shift, Part time shift', 'Shift Name', 'text', '3', '', '', '', 'required', '', 669, 1, '', '', '', '', '2022-09-28 19:11:24'),
(17667, '_class_id', 'autocomplete', 'class|', '', 'Class', 'varchar', '', '', '', '', 'required', '', 669, 1, '', '', '', '', '2022-09-28 19:11:24'),
(17668, '_course_id', 'dropdown', 'course_teacher', '', 'Course/Lecture', 'load', '', 'course_teacher_id,chapter-', '', '', 'required', '', 669, 1, '', '', '', '', '2022-09-28 19:11:24'),
(17669, '_semester_id', 'dropdown', 'general,type,semester', '', 'Semester', 'load2', '', 'class_semester_course', '', '', 'required', '', 669, 1, '', '', '', '', '2022-09-28 19:11:24'),
(17670, '_period_id', 'dropdown', 'period', '', 'Choose Period', 'int', '', '', '', '', 'required', '', 669, 1, '', '', '', '', '2022-09-28 19:11:24'),
(17671, '_user_id', 'hidden', '', '', 'User Id', 'int', '', '', '', '', 'required', '', 669, 1, '', '', '', '', '2022-09-28 19:11:24'),
(17672, '_date', 'date', '', '', 'Date', '', '', '', '', '', 'required', '', 669, 1, '', '', '', '', '2022-09-28 19:11:24'),
(17695, 'users_p', 'dropdown', 'ktc_user|', '', 'Users', '', '', '', '', '', 'required', '', 487, 1, '', '', '', '', '2022-10-02 09:27:57'),
(17696, 'link_p', 'dropdown', 'ktc_link|', '', 'Link', '', '', '', '', '', 'required', '', 487, 1, '', '', '', '', '2022-10-02 09:27:57'),
(17697, 'from_p', 'date', '', '', 'From', '', '', '', '', '', '', '', 487, 1, '', '', '', '', '2022-10-02 09:27:57'),
(17698, 'to_p', 'date', '', '', 'To', '', '', '', '', '', '', '', 487, 1, '', '', '', '', '2022-10-02 09:27:57'),
(17699, 'status_p', 'text', '', '0,1,2,3', 'Status', '', '', '', '', '%', 'required', '', 487, 1, '', '', '', '', '2022-10-02 09:27:57'),
(17702, 'acc_p', 'hidden_ele', '', '', 'Acc', '', '', '', '', '%', 'required', '', 61, 1, '', '', '', '', '2022-10-02 13:41:43'),
(17703, 'user_p', 'dropdown', 'user', '', 'User', '', '', '', '', '', 'required', '', 61, 1, '', '', '', '', '2022-10-02 13:41:43'),
(17704, 'user2_p', 'hidden', '', '', 'User2', '', '', '', '', '', 'required', '', 61, 1, '', '', '', '', '2022-10-02 13:41:43'),
(17705, 'co_p', 'hidden_u', 'company', '', 'Co', 'load', '', 'company_id,ktc_user-', '', '', 'required', '', 61, 1, '', '', '', '', '2022-10-02 13:41:43'),
(17706, 'link_p', 'dropdown', 'ktc_link|', '', 'Link', 'load_me', '', '', '', '', 'required', '', 61, 1, '', '', '', '', '2022-10-02 13:41:43'),
(18113, '_auto_id', 'hidden_ele', '', '', 'To', '', '', '', '', '', 'required', '', 641, 1, '', '', '', '', '2022-11-20 14:32:35'),
(18114, '_company_id', 'hidden_u', 'company', '', 'Co', 'load', '', 'company_id,ktc_user-', '', '', 'required', '', 641, 1, '', '', '', '', '2022-11-20 14:32:35'),
(18115, '_table_auto_id', 'number', '', 'Ex Student ID, Teacher ID', 'Translate ID', '', '', '', '', '', 'required', '', 641, 1, '', '', '', '', '2022-11-20 14:32:35'),
(18116, '_translated', 'varchar', '', '', ' Translated', 'varchar', '', '', '', '', 'required', '', 641, 1, '', '', '', '', '2022-11-20 14:32:35'),
(18117, '_table_name', 'dropdown', 'table', 'eg. Morning Shift, Noon Shift, Night Shift, Part time shift', 'Table', 'text', '3', '', '', '', 'required', '', 641, 1, '', '', '', '', '2022-11-20 14:32:35'),
(18118, '_language', 'dropdown', 'language_', '', 'Language', 'load_header load_footer  req', '', '', '', '', 'required', '', 641, 1, '', '', '', '', '2022-11-20 14:32:35'),
(18119, '_user_id', 'hidden', '', '', 'User Id', 'int', '', '', '', '', 'required', '', 641, 1, '', '', '', '', '2022-11-20 14:32:35'),
(18120, '_date', 'date', '', '', 'Date', '', '', '', '', '', 'required', '', 641, 1, '', '', '', '', '2022-11-20 14:32:35'),
(18551, 'copy_user_p', 'dropdown', 'ktcuser', '', 'Copy User', 'int', '', '', '', '', 'required', '', 93, 1, '', '', '', '', '2022-11-26 05:36:53'),
(18552, 'paste_user_p', 'dropdown', 'ktcuser', '', 'Paste User', 'int', '', '', '', '', 'required', '', 93, 1, '', '', '', '', '2022-11-26 05:36:53'),
(18553, 'user_p', 'hidden', '', '', 'User', '', '', '', '', '', 'required', '', 93, 1, '', '', '', '', '2022-11-26 05:36:53'),
(18554, 'action_p', 'hidden_ele', 'auto_rec_', '', 'Action', '', '', '', '', 'all', 'required', '', 93, 1, '', '', '', '', '2022-11-26 05:36:53'),
(18558, 'copy_user_p', 'dropdown', 'ktcuser', '', 'Copy User', 'int', '', '', '', '', 'required', '', 717, 1, '', '', '', '', '2022-11-26 05:38:44'),
(18559, 'paste_user_p', 'checkbox', 'ktcuser', '', 'Paste User', 'int', '', '', '', '', 'required', '', 717, 1, '', '', '', '', '2022-11-26 05:38:44'),
(18560, 'user_p', 'hidden', '', '', 'User', '', '', '', '', '', 'required', '', 717, 1, '', '', '', '', '2022-11-26 05:38:44'),
(18561, 'action_p', 'hidden_ele', 'auto_rec_', '', 'Action', '', '', '', '', 'links', 'required', '', 717, 1, '', '', '', '', '2022-11-26 05:38:44'),
(19771, '_company_id', 'hidden_u', 'all_company', '', 'Company', 'load', '', 'company_id,ktc_category-', '', '', 'required', '', 719, 1, '', '', '', '', '2022-12-22 17:25:10'),
(19772, '_name', 'varchar', 'department|', 'Department Name', 'Department Name', 'text', '3', '', '', '', 'required', '', 719, 1, '', '', '', '', '2022-12-22 17:25:10'),
(19773, '_image', 'file', 'image', '', ' Image', '', '', '', '', '', 'required', '', 719, 1, '', '', '', '', '2022-12-22 17:25:10'),
(19774, '_description', 'Varchar', '', '', 'Description', 'varchar', '', '', '', '', '', '', 719, 1, '', '', '', '', '2022-12-22 17:25:10'),
(19775, '_user_id', 'hidden', '', '', 'User Id', 'int', '', '', '', '', 'required', '', 719, 1, '', '', '', '', '2022-12-22 17:25:10'),
(19776, '_date', 'date', '', '', 'Date', '', '', '', '', '', 'required', '', 719, 1, '', '', '', '', '2022-12-22 17:25:10'),
(19808, '_company_id', 'hidden_u', 'all_company', '', 'Company', 'load', '', 'company_id,ktc_category-', '', '', 'required', '', 722, 1, '', '', '', '', '2022-12-22 17:30:33'),
(19809, '_patient_id', 'autocomplete', 'patient|', '', 'Patient', '', '', '', '', '', 'required', '', 722, 1, '', '', '', '', '2022-12-22 17:30:33'),
(19810, '_hospital_id', 'autocomplete', 'hospital|', '', ' Hospital Id', 'load', '', 'hospital_id,doctor-', '', '', 'required', '', 722, 1, '', '', '', '', '2022-12-22 17:30:33'),
(19811, '_doctor_id', 'dropdown', 'doctor|', '', 'Doctor', '', '', '', '', '', 'required', '', 722, 1, '', '', '', '', '2022-12-22 17:30:33'),
(19812, '_amount', 'number', '', '', 'Amount', 'float', '', '', '', '', 'required', '', 722, 1, '', '', '', '', '2022-12-22 17:30:33'),
(19813, '_user_id', '', '', '', 'hidden', '', '', '', '', '', 'required', '', 722, 1, '', '', '', '', '2022-12-22 17:30:33'),
(19814, '_date', 'date', '', '', 'Date', '', '', '', '', '', 'required', '', 722, 1, '', '', '', '', '2022-12-22 17:30:33'),
(19845, '_company_id', 'hidden_u', 'all_company', '', 'Company', 'load', '', 'company_id,ktc_category-', '', '', 'required', '', 725, 1, '', '', '', '', '2022-12-22 18:21:47'),
(19846, '_hospital', 'dropdown', 'hospital', '', ' Hospital', 'varchar', '', '', '', '', 'required', '', 725, 1, '', '', '', '', '2022-12-22 18:21:47'),
(19847, '_region', 'dropdown', 'region_', '', 'Region', 'varchar', '3', '', '', '', 'required', '', 725, 1, '', '', '', '', '2022-12-22 18:21:47'),
(19848, '_city', 'hidden_ele', '', '', ' City', 'varchar', '', '', '', '%', 'required', '', 725, 1, '', '', '', '', '2022-12-22 18:21:47'),
(19849, '_from', 'date', '', '', 'From', '', '', '', '', '0000-00-00', '', '', 725, 1, '', '', '', '', '2022-12-22 18:21:47'),
(19850, '_to', 'date', '', '', 'To', '', '', '', '', '', '', '', 725, 1, '', '', '', '', '2022-12-22 18:21:47'),
(19851, '_user_id', '', '', '', 'hidden', '', '', '', '', '', 'required', '', 725, 1, '', '', '', '', '2022-12-22 18:21:47'),
(19860, '_company_id', 'hidden_u', 'all_company', '', 'Company', 'load', '', 'company_id,ktc_category-', '', '', 'required', '', 726, 1, '', '', '', '', '2022-12-22 18:26:31'),
(19861, '_department', 'dropdown', 'department|', '', 'category', 'load', '', 'department_id,class-', '', '', 'required', '', 726, 1, '', '', '', '', '2022-12-22 18:26:31'),
(19862, '_user_id', '', '', '', 'hidden', '', '', '', '', '', 'required', '', 726, 1, '', '', '', '', '2022-12-22 18:26:31'),
(19882, '_company_id', 'hidden_u', 'all_company', '', 'Company', 'load', '', 'company_id,ktc_category-', '', '', 'required', '', 728, 1, '', '', '', '', '2022-12-22 18:29:29'),
(19883, '_hospital', 'dropdown', 'hospital|', '', ' Hospital', 'varchar', '', '', '', '', 'required', '', 728, 1, '', '', '', '', '2022-12-22 18:29:29'),
(19884, '_department', 'dropdown', 'department|', '', 'Department', 'load', '', 'department_id,class-', '', '', 'required', '', 728, 1, '', '', '', '', '2022-12-22 18:29:29'),
(19885, '_region', 'dropdown', 'region_', '', 'Region', 'varchar', '3', '', '', '', 'required', '', 728, 1, '', '', '', '', '2022-12-22 18:29:29'),
(19886, '_city', 'hidden_ele', '', '', ' City', 'varchar', '', '', '', '%', 'required', '', 728, 1, '', '', '', '', '2022-12-22 18:29:29'),
(19887, '_from', 'date', '', '', 'From', '', '', '', '', '', 'required', '', 728, 1, '', '', '', '', '2022-12-22 18:29:29'),
(19888, '_to', 'date', '', '', 'To', '', '', '', '', '', 'required', '', 728, 1, '', '', '', '', '2022-12-22 18:29:29'),
(19889, '_user_id', '', '', '', 'hidden', '', '', '', '', '', 'required', '', 728, 1, '', '', '', '', '2022-12-22 18:29:29'),
(19897, '_company_id', 'hidden_u', '', '', 'Co', '', '', '', '', '', 'required', '', 729, 1, '', '', '', '', '2022-12-22 18:32:22'),
(19898, '_hospital', 'varchar', '', '', ' Hospital', 'varchar', '', '', '', '', 'required', '', 729, 1, '', '', '', '', '2022-12-22 18:32:22'),
(19899, '_department', 'dropdown', 'department|', '', 'category', 'load', '', 'department_id,class-', '', '', 'required', '', 729, 1, '', '', '', '', '2022-12-22 18:32:22'),
(19900, '_status', 'dropdown', 'status_', '', 'Status', '', '', '', '', '', 'required', '', 729, 1, '', '', '', '', '2022-12-22 18:32:22'),
(19901, '_from', 'date', '', '', 'From', '', '', '', '', '', 'required', '', 729, 1, '', '', '', '', '2022-12-22 18:32:22'),
(19902, '_to', 'date', '', '', 'To', '', '', '', '', '', 'required', '', 729, 1, '', '', '', '', '2022-12-22 18:32:22'),
(19904, '_company_id', 'hidden_u', '', '', 'Co', '', '', '', '', '', 'required', '', 730, 1, '', '', '', '', '2022-12-22 18:33:20'),
(19905, '_hospital', 'varchar', '', '', ' Hospital', 'varchar', '', '', '', '', 'required', '', 730, 1, '', '', '', '', '2022-12-22 18:33:20'),
(19906, '_from', 'date', '', '', 'From', '', '', '', '', '', 'required', '', 730, 1, '', '', '', '', '2022-12-22 18:33:20'),
(19907, '_to', 'date', '', '', 'To', '', '', '', '', '', 'required', '', 730, 1, '', '', '', '', '2022-12-22 18:33:20'),
(19945, '_company_id', 'hidden_u', 'all_company', '', 'Company', 'load', '', 'company_id,ktc_category-', '', '', 'required', '', 727, 1, '', '', '', '', '2022-12-26 13:46:09'),
(19946, '_from', 'date', '', '', 'From', '', '', '', '', '', 'required', '', 727, 1, '', '', '', '', '2022-12-26 13:46:09'),
(19947, '_to', 'date', '', '', 'To', '', '', '', '', '', 'required', '', 727, 1, '', '', '', '', '2022-12-26 13:46:09'),
(19948, '_user_id', '', '', '', 'hidden', '', '', '', '', '', 'required', '', 727, 1, '', '', '', '', '2022-12-26 13:46:09'),
(19952, '_company_id', 'hidden_u', 'all_company', '', 'Company', 'load', '', 'company_id,ktc_category-', '', '', 'required', '', 723, 1, '', '', '', '', '2022-12-26 13:46:20'),
(19953, '_name', 'varchar', 'patient|', 'Patient Name', 'Patient Name', 'text', '3', '', '', '', 'required', '', 723, 1, '', '', '', '', '2022-12-26 13:46:20'),
(19954, '_gender', 'dropdown', 'gender_', '', 'Gender', 'time', '3', '', '', '', 'required', '', 723, 1, '', '', '', '', '2022-12-26 13:46:20'),
(19955, '_tell', 'number', '', '61xxxxxxx', 'Patient Tell', '', '4', '', '', '', 'required', '', 723, 1, '', '', '', '', '2022-12-26 13:46:20'),
(19956, '_address', 'text', '', 'Km4 Hodan', 'Address', 'varchar', '4', '', '', '', 'required', '', 723, 1, '', '', '', '', '2022-12-26 13:46:20'),
(19957, '_dob', 'date', '', '', 'Dob', 'number', '', '', '', '00-00-0000', 'required', '', 723, 1, '', '', '', '', '2022-12-26 13:46:20'),
(19958, '_mother', 'varchar', '', '', 'Mother', 'varchar', '', '', '', '', 'required', '', 723, 1, '', '', '', '', '2022-12-26 13:46:20'),
(19959, '_description', 'hidden_ele', '', '', 'Description', 'varchar', '', '', '', '', 'required', '', 723, 1, '', '', '', '', '2022-12-26 13:46:20'),
(19960, '_user_id', '', '', '', 'hidden', '', '', '', '', '', 'required', '', 723, 1, '', '', '', '', '2022-12-26 13:46:20'),
(19961, '_date', 'date', '', '', 'Date', '', '', '', '', '', 'required', '', 723, 1, '', '', '', '', '2022-12-26 13:46:20'),
(19962, '_company_id', 'hidden_u', '', '', 'Co', '', '', '', '', '', 'required', '', 731, 1, '', '', '', '', '2022-12-29 21:24:44'),
(19963, '_expense_id', 'dropdown', 'general,type,expense', '', 'Expense Type', 'int', '', '', '', '', 'required', '', 731, 1, '', '', '', '', '2022-12-29 21:24:44'),
(19964, '_amount', 'number', '', '', 'Amount', 'float', '', '', '', '', 'required', '', 731, 1, '', '', '', '', '2022-12-29 21:24:44'),
(19965, '_description', 'vatchar', '', '', 'Description', 'varchar', '', '', '', '', 'required', '', 731, 1, '', '', '', '', '2022-12-29 21:24:44'),
(19966, '_type', 'hidden_ele', 'other_charge_', '', 'Type', '', '', '', '', 'e', 'required', '', 731, 1, '', '', '', '', '2022-12-29 21:24:44'),
(19967, '_user_id', '', '', '', 'hidden', '', '', '', '', '', 'required', '', 731, 1, '', '', '', '', '2022-12-29 21:24:44'),
(19968, '_date', 'date', '', '', 'Date', '', '', '', '', '', 'required', '', 731, 1, '', '', '', '', '2022-12-29 21:24:44'),
(19979, '_company_id', 'hidden_u', 'all_company', '', 'Company', 'load', '', 'company_id,ktc_category-', '', '', 'required', '', 732, 1, '', '', '', '', '2022-12-31 09:31:06'),
(19980, '_from', 'date', '', '', 'From', '', '', '', '', '', 'required', '', 732, 1, '', '', '', '', '2022-12-31 09:31:06'),
(19981, '_to', 'date', '', '', 'To', '', '', '', '', '', 'required', '', 732, 1, '', '', '', '', '2022-12-31 09:31:06'),
(19982, '_user_id', '', '', '', 'hidden', '', '', '', '', '', 'required', '', 732, 1, '', '', '', '', '2022-12-31 09:31:06'),
(19986, '_company_id', 'hidden_u', 'all_company', '', 'Company', 'load', '', 'company_id,ktc_category-', '', '', 'required', '', 733, 1, '', '', '', '', '2022-12-31 09:31:13'),
(19987, '_Expense_id', 'dropdown', 'general,type,expense', '', 'Expense Type', 'int', '', '', '', '', 'required', '', 733, 1, '', '', '', '', '2022-12-31 09:31:13'),
(19988, '_type', 'hidden_ele', 'other_charge_', '', 'Type', '', '', '', '', 'e', 'required', '', 733, 1, '', '', '', '', '2022-12-31 09:31:13'),
(19989, '_from', 'date', '', '', 'From', '', '', '', '', '', 'required', '', 733, 1, '', '', '', '', '2022-12-31 09:31:13'),
(19990, '_to', 'date', '', '', 'To', '', '', '', '', '', 'required', '', 733, 1, '', '', '', '', '2022-12-31 09:31:13'),
(19991, '_user_id', '', '', '', 'hidden', '', '', '', '', '', 'required', '', 733, 1, '', '', '', '', '2022-12-31 09:31:13'),
(19993, '_company_id', 'hidden_u', '', '', 'Co', '', '', '', '', '', 'required', '', 734, 1, '', '', '', '', '2023-01-01 07:47:19'),
(19994, '_question', 'textarea', '', '', ' Question', '', '', '', '', '', 'required', '', 734, 1, '', '', '', '', '2023-01-01 07:47:19'),
(19995, '_answer', 'textarea2', '', '', ' Answer', 'longtext', '', '', '', '', 'required', '', 734, 1, '', '', '', '', '2023-01-01 07:47:19'),
(19996, '_user_id', '', '', '', 'hidden', '', '', '', '', '', 'required', '', 734, 1, '', '', '', '', '2023-01-01 07:47:19'),
(19997, '_date', 'date', '', '', 'Date', '', '', '', '', '', 'required', '', 734, 1, '', '', '', '', '2023-01-01 07:47:19'),
(20000, '_company_id', 'hidden_u', '', '', 'Co', '', '', '', '', '', 'required', '', 735, 1, '', '', '', '', '2023-01-05 06:55:59'),
(20001, '_tell', 'text', '', '61xxxxxxx', 'Patient Tell', '', '4', '', '', '', 'required', '', 735, 1, '', '', '', '', '2023-01-05 06:55:59'),
(20002, '_user_id', '', '', '', 'hidden', '', '', '', '', '', 'required', '', 735, 1, '', '', '', '', '2023-01-05 06:55:59'),
(20007, '_company_id', 'hidden_u', 'all_company', '', 'Company', 'load', '', 'company_id,ktc_category-', '', '', 'required', '', 721, 1, '', '', '', '', '2023-01-05 14:35:37'),
(20008, '_name', 'varchar', 'student', 'Hospital Name', 'Hospital Name', 'text', '3', '', '', '', 'required', '', 721, 1, '', '', '', '', '2023-01-05 14:35:37'),
(20009, '_tell', 'number', '', '61xxxxxxx', 'Hospital Tell', '', '4', '', '', '', 'required', '', 721, 1, '', '', '', '', '2023-01-05 14:35:37'),
(20010, '_cashier_tell', 'number', '', '61xxxxxxx', 'Cashier Tell', '', '4', '', '', '', 'required', '', 721, 1, '', '', '', '', '2023-01-05 14:35:37'),
(20011, '_region', 'dropdown', 'region_', '', 'Region', 'varchar', '3', '', '', '', 'required', '', 721, 1, '', '', '', '', '2023-01-05 14:35:37'),
(20012, '_city', 'varchar', '', '', ' City', 'varchar', '', '', '', '', 'required', '', 721, 1, '', '', '', '', '2023-01-05 14:35:37'),
(20013, '_address', 'varchar', '', 'Km4 Hodan', 'Address', 'varchar', '4', '', '', '', 'required', '', 721, 1, '', '', '', '', '2023-01-05 14:35:37'),
(20014, '_ticket_fee', 'number', 'general,type,fee', '', 'Ticket Fee ($)', 'float', '', '', '', '', 'required', '', 721, 1, '', '', '', '', '2023-01-05 14:35:37'),
(20015, '_commission_fee', 'number', 'general,type,fee', '', 'Commission Fee ($)', 'float', '', '', '', '', 'required', '', 721, 1, '', '', '', '', '2023-01-05 14:35:37'),
(20016, '_service_fee', 'number', 'general,type,fee', '', 'Service Fee ($)', 'float', '', '', '', '', 'required', '', 721, 1, '', '', '', '', '2023-01-05 14:35:37'),
(20017, '_logo', 'file', 'image', '', ' Logo', 'varchar', '4', '', '', '', 'required', '', 721, 1, '', '', '', '', '2023-01-05 14:35:37'),
(20018, '_user_id', '', '', '', 'hidden', '', '', '', '', '', 'required', '', 721, 1, '', '', '', '', '2023-01-05 14:35:37'),
(20019, '_date', 'date', '', '', 'Date', '', '', '', '', '', 'required', '', 721, 1, '', '', '', '', '2023-01-05 14:35:37'),
(20022, '_company_id', 'hidden_u', '', '', 'Co', '', '', '', '', '', 'required', '', 736, 1, '', '', '', '', '2023-01-06 14:35:36'),
(20023, '_from', 'date', '', '', 'From', '', '', '', '', '', 'required', '', 736, 1, '', '', '', '', '2023-01-06 14:35:36'),
(20024, '_to', 'date', '', '', 'To', '', '', '', '', '', 'required', '', 736, 1, '', '', '', '', '2023-01-06 14:35:36'),
(20025, '_user_id', '', '', '', 'hidden', '', '', '', '', '', 'required', '', 736, 1, '', '', '', '', '2023-01-06 14:35:36'),
(20029, '_company_id', 'hidden_u', '', '', 'Co', '', '', '', '', '', 'required', '', 737, 1, '', '', '', '', '2023-01-06 14:40:24'),
(20030, '_from', 'date', '', '', 'From', '', '', '', '', '', 'required', '', 737, 1, '', '', '', '', '2023-01-06 14:40:24'),
(20031, '_to', 'date', '', '', 'To', '', '', '', '', '', 'required', '', 737, 1, '', '', '', '', '2023-01-06 14:40:24'),
(20032, '_user_id', '', '', '', 'hidden', '', '', '', '', '', 'required', '', 737, 1, '', '', '', '', '2023-01-06 14:40:24'),
(20036, '_auto_id', 'hidden_ele', 'to|', '', 'To', '', '', '', '', '', 'required', '', 738, 1, '', '', '', '', '2023-01-24 08:31:19'),
(20037, '_company_id', 'hidden_u', '', '', 'Co', '', '', '', '', '', 'required', '', 738, 1, '', '', '', '', '2023-01-24 08:31:19'),
(20038, '_name', 'varchar', 'student', 'Campaign Name', 'Campaign Name', 'text', '3', '', '', '', 'required', '', 738, 1, '', '', '', '', '2023-01-24 08:31:19'),
(20039, '_description', 'textarea2', '', '', 'Description', 'varchar', '', '', '', '', 'required', '', 738, 1, '', '', '', '', '2023-01-24 08:31:19'),
(20040, '_start_date', 'date', '', '', 'Start Date', 'time', '', '', '', '', 'required', '', 738, 1, '', '', '', '', '2023-01-24 08:31:19'),
(20041, '_end_date', 'date', '', '', 'End Date', 'time', '', '', '', '', 'required', '', 738, 1, '', '', '', '', '2023-01-24 08:31:19'),
(20042, '_user_id', '', '', '', 'hidden', '', '', '', '', '', 'required', '', 738, 1, '', '', '', '', '2023-01-24 08:31:19'),
(20043, '_date', 'date', '', '', 'Date', '', '', '', '', '', 'required', '', 738, 1, '', '', '', '', '2023-01-24 08:31:19'),
(20044, '_company_id', 'hidden_u', 'all_company', '', 'Company', 'load', '', 'company_id,ktc_category-', '', '', 'required', '', 720, 1, '', '', '', '', '2023-08-10 11:05:48'),
(20045, '_hospital_id', 'autocomplete', 'hospital|', '', ' Hospital Id', 'int', '', '', '', '', 'required', '', 720, 1, '', '', '', '', '2023-08-10 11:05:48'),
(20046, '_name', 'text', '', 'Doctor Name', 'Doctor Name', 'text', '3', '', '', '', 'required', '', 720, 1, '', '', '', '', '2023-08-10 11:05:48'),
(20047, '_tell', 'number', '', '61xxxxxxx', 'Doctor Tell', '', '4', '', '', '', '', '', 720, 1, '', '', '', '', '2023-08-10 11:05:48'),
(20048, '_image', 'file', 'images', '', ' Image', '', '', '', '', '', '', '', 720, 1, '', '', '', '', '2023-08-10 11:05:48'),
(20049, '_department_id', 'dropdown', 'department|', '', 'Department', 'load', '', 'department_id,class-', '', '', 'required', '', 720, 1, '', '', '', '', '2023-08-10 11:05:48'),
(20050, '_ticket_fee', 'number', 'general,type,fee', '', 'Ticket Fee ($)', 'float', '', '', '', '', '', '', 720, 1, '', '', '', '', '2023-08-10 11:05:48'),
(20051, '_description', 'textarea', '', 'Ex. Sabti, Axad, Isniin, Talaado Saacadaha : 08AM - 12PM', 'Work Time', 'varchar', '12', '', '', '', 'required', '', 720, 1, '', '', '', '', '2023-08-10 11:05:48'),
(20052, '_user_id', 'hidden', '', '', 'User Id', 'int', '', '', '', '', 'required', '', 720, 1, '', '', '', '', '2023-08-10 11:05:48'),
(20053, '_date', 'date', '', '', 'Date', '', '', '', '', '', 'required', '', 720, 1, '', '', '', '', '2023-08-10 11:05:48'),
(20059, '_company_id', 'hidden_u', 'all_company', '', 'Company', 'load', '', 'company_id,ktc_category-', '', '', 'required', '', 724, 1, '', '', '', '', '2023-08-10 11:15:24'),
(20060, '_hospital', 'dropdown', 'hospital|', '', 'Hospital', 'varchar', '', '', '', '', 'required', '', 724, 1, '', '', '', '', '2023-08-10 11:15:24'),
(20061, '_department', 'dropdown', 'department|', '', 'category', 'load', '', 'department_id,class-', '', '', 'required', '', 724, 1, '', '', '', '', '2023-08-10 11:15:24'),
(20062, '_region', 'dropdown', 'region_', '', 'Region', 'varchar', '3', '', '', '', 'required', '', 724, 1, '', '', '', '', '2023-08-10 11:15:24'),
(20063, '_city', 'hidden_ele', '', '', ' City', 'varchar', '', '', '', '%', 'required', '', 724, 1, '', '', '', '', '2023-08-10 11:15:24'),
(20064, '_from2', 'date', '', '', ' From2', 'date', '', '', '', '', '', '', 724, 1, '', '', '', '', '2023-08-10 11:15:24'),
(20065, '_to', 'date', '', '', 'To', '', '', '', '', '', 'required', '', 724, 1, '', '', '', '', '2023-08-10 11:15:24'),
(20066, '_user_id', '', '', '', 'hidden', '', '', '', '', '', 'required', '', 724, 1, '', '', '', '', '2023-08-10 11:15:24');

--
-- Triggers `ktc_parameter`
--
DELIMITER $$
CREATE TRIGGER `add_common` AFTER UPDATE ON `ktc_parameter` FOR EACH ROW BEGIN

if EXISTS(SELECT p.id FROM ktc_common_param p where p.parameter = NEW.parameter) THEN

UPDATE `ktc_common_param` SET  `label`=NEW.lable,`type`=NEW.type,`action`=NEW.action,`placeholder`=NEW.placeholder,`default_value`=NEW.default_value,`class`=NEW.class,`load_action`=NEW.load_action  WHERE parameter = NEW.parameter;
ELSE

INSERT INTO `ktc_common_param`( `parameter`, `label`, `type`, `action`, `placeholder`, `default_value`, `class`, `size`, `load_action`) VALUES (NEW.parameter,NEW.lable,NEW.type,NEW.action,NEW.placeholder,NEW.default_value,NEW.class,NEW.size,NEW.load_action);

end if;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `ktc_procedure`
--

CREATE TABLE `ktc_procedure` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `date` date NOT NULL,
  `action_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ktc_procedure`
--

INSERT INTO `ktc_procedure` (`id`, `name`, `date`, `action_date`, `modified_date`) VALUES
(1, 'branch_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:48'),
(2, 'company_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(3, 'general_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(4, 'ktc_add_chart_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(5, 'ktc_autocomplete_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(6, 'ktc_category_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(7, 'ktc_change_pass_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(8, 'ktc_common_paramete_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(9, 'ktc_complete_user_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(10, 'ktc_copy_form_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(11, 'ktc_copy_multi_form_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(12, 'ktc_copy_parameter_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(13, 'ktc_copy_permission_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(14, 'ktc_delete_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(15, 'ktc_dropdown_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(16, 'ktc_edit_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(17, 'ktc_forgot_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(18, 'ktc_form_structure_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(19, 'ktc_get_auto_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(20, 'ktc_get_dropdown_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(21, 'ktc_get_info_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(22, 'ktc_get_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(23, 'ktc_get_user_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(24, 'ktc_inbox_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(25, 'ktc_invoice_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(26, 'ktc_link_info_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(27, 'ktc_link_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(28, 'ktc_login_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(29, 'ktc_ls_link_permission1_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(30, 'ktc_ls_link_permission_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(31, 'ktc_ls_link_sidebar_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(32, 'ktc_pie_chart_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(33, 'ktc_repair_link_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(34, 'ktc_report_header_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(35, 'ktc_rp_category_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(36, 'ktc_rp_chart_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(37, 'ktc_rp_common_parameter_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(38, 'ktc_rp_delete_logs_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(39, 'ktc_rp_dropdown_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(40, 'ktc_rp_edit_logs_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(41, 'ktc_rp_inbox_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(42, 'ktc_rp_link_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(43, 'ktc_rp_parameters_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(44, 'ktc_rp_table_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(45, 'ktc_rp_user_logs_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(46, 'ktc_rp_user_permission', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(47, 'ktc_rp_user_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(48, 'ktc_search_row_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(49, 'ktc_set_auto_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(50, 'ktc_sub_category_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(51, 'ktc_tracker_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(52, 'ktc_tranfer_form_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(53, 'ktc_undo_delete_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(54, 'ktc_user_permission_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(55, 'ktc_user_schedule_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(56, 'ktc_user_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(57, 'rp_branch_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(58, 'rp_company_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(59, 'rp_general_sp', '2021-03-11', '2021-03-11 06:17:13', '2021-03-11 06:17:58'),
(68, 'ktc_get_company_sp', '2021-03-24', '2021-03-24 09:12:41', '2021-03-24 09:12:41'),
(80, 'ktc_reset_token_sp', '2021-03-30', '2021-03-30 16:30:35', '2021-03-30 16:30:35'),
(82, 'ktc_activate_user_sp', '2021-03-30', '2021-03-31 05:19:29', '2021-03-31 05:19:29'),
(97, 'ktc_update_user_sp', '2021-04-20', '2021-04-20 07:06:49', '2021-04-20 07:06:49'),
(265, 'ktc_rp_expired_procedure_sp', '2022-02-13', '2022-02-13 14:59:10', '2022-02-13 14:59:10'),
(352, 'ktc_languages_sp', '2022-07-11', '2022-07-11 16:23:06', '2022-07-11 16:23:06'),
(358, 'ktc_sms_sp', '2022-07-23', '2022-07-23 12:53:52', '2022-07-23 12:53:52'),
(424, 'ktc_enable_2fa_sp', '2022-10-08', '2022-10-08 15:23:44', '2022-10-08 15:23:44'),
(428, 'ktc_report_footer_sp', '2022-10-20', '2022-10-20 08:25:11', '2022-10-20 08:25:11'),
(466, 'ktc_todo_sp', '2022-12-02', '2022-12-02 15:09:42', '2022-12-02 15:09:42'),
(468, 'ktc_solution_sp', '2022-12-02', '2022-12-02 15:57:27', '2022-12-02 15:57:27'),
(476, 'ktc_error_sp', '2022-12-03', '2022-12-03 15:31:59', '2022-12-03 15:31:59'),
(477, 'ktc_rp_todo_sp', '2022-12-03', '2022-12-03 15:46:58', '2022-12-03 15:46:58'),
(478, 'ktc_rp_error_sp', '2022-12-03', '2022-12-03 15:55:09', '2022-12-03 15:55:09'),
(480, 'ktc_rp_solution_sp', '2022-12-03', '2022-12-03 16:12:05', '2022-12-03 16:12:05'),
(494, 'ktc_cancel_sp', '2022-12-08', '2022-12-08 05:26:38', '2022-12-08 05:26:38'),
(538, 'app_patient_sp', '2022-12-22', '2022-12-22 17:24:21', '2022-12-22 17:24:21'),
(539, 'department_sp', '2022-12-22', '2022-12-22 17:25:10', '2022-12-22 17:25:10'),
(540, 'doctor_sp', '2022-12-22', '2022-12-22 17:26:14', '2022-12-22 17:26:14'),
(541, 'hospital_sp', '2022-12-22', '2022-12-22 17:29:31', '2022-12-22 17:29:31'),
(542, 'ticket_sp', '2022-12-22', '2022-12-22 17:30:33', '2022-12-22 17:30:33'),
(543, 'patient_sp', '2022-12-22', '2022-12-22 17:31:19', '2022-12-22 17:31:19'),
(544, 'rp_doctor_sp', '2022-12-22', '2022-12-22 18:20:50', '2022-12-22 18:20:50'),
(545, 'rp_hospital_sp', '2022-12-22', '2022-12-22 18:21:47', '2022-12-22 18:21:47'),
(546, 'rp_department_sp', '2022-12-22', '2022-12-22 18:26:31', '2022-12-22 18:26:31'),
(547, 'rp_patient_sp', '2022-12-22', '2022-12-22 18:28:45', '2022-12-22 18:28:45'),
(548, 'rp_ticket_sp', '2022-12-22', '2022-12-22 18:29:29', '2022-12-22 18:29:29'),
(549, 'rp_app_patient_sp', '2022-12-22', '2022-12-22 18:32:22', '2022-12-22 18:32:22'),
(550, 'rp_evc_app_receipt_sp', '2022-12-22', '2022-12-22 18:33:20', '2022-12-22 18:33:20'),
(551, 'portal_hospital_list_sp', '2022-12-25', '2022-12-25 07:56:07', '2022-12-25 07:56:07'),
(552, 'portal_doctor_list_sp', '2022-12-26', '2022-12-26 08:42:22', '2022-12-26 08:42:22'),
(553, 'expense_sp', '2022-12-30', '2022-12-29 21:24:44', '2022-12-29 21:24:44'),
(554, 'rp_faq_sp', '2022-12-31', '2022-12-31 09:14:38', '2022-12-31 09:14:38'),
(555, 'rp_expense_sp', '2022-12-31', '2022-12-31 09:15:14', '2022-12-31 09:15:14'),
(556, 'faq_sp', '2023-01-01', '2023-01-01 07:47:19', '2023-01-01 07:47:19'),
(557, 'portal_faq_list_sp', '2023-01-01', '2023-01-01 17:53:43', '2023-01-01 17:53:43'),
(558, 'portal_visitor_sp', '2023-01-02', '2023-01-02 07:30:14', '2023-01-02 07:33:46'),
(559, 'portal_check_visitor_sp', '2023-01-02', '2023-01-02 07:33:18', '2023-01-02 07:33:18'),
(560, 'search_ticket_sp', '2023-01-05', '2023-01-05 06:55:59', '2023-01-05 06:55:59'),
(562, 'rp_blood_sp', '2023-01-06', '2023-01-06 14:35:36', '2023-01-06 14:35:36'),
(563, 'rp_agent_sp', '2023-01-06', '2023-01-06 14:40:23', '2023-01-06 14:40:23'),
(564, 'portal_app_click_sp', '2023-01-07', '2023-01-07 04:02:41', '2023-01-07 04:02:41'),
(565, 'portal_department_sp', '2023-01-07', '2023-01-07 18:14:52', '2023-01-07 18:14:52'),
(566, 'get_hospital_sp', '2023-01-11', '2023-01-11 03:00:20', '2023-01-11 03:00:20'),
(567, 'agent_sp', '2023-01-16', '2023-01-16 05:16:13', '2023-01-16 05:16:13'),
(568, 'portal_sharer_sp', '2023-01-16', '2023-01-16 05:24:38', '2023-01-16 05:24:38'),
(569, 'portal_agent_profile_sp', '2023-01-16', '2023-01-16 08:24:51', '2023-01-16 08:24:51'),
(570, 'campaign_sp', '2023-01-24', '2023-01-24 08:31:19', '2023-01-24 08:31:19'),
(571, 'portal_campaign_list_sp', '2023-01-24', '2023-01-24 09:04:49', '2023-01-24 09:04:49'),
(572, 'portal_join_campaign_sp', '2023-01-26', '2023-01-26 05:32:43', '2023-01-26 05:32:43');

-- --------------------------------------------------------

--
-- Table structure for table `ktc_sms`
--

CREATE TABLE `ktc_sms` (
  `id` int(11) NOT NULL,
  `tell` varchar(50) NOT NULL,
  `sms` text NOT NULL,
  `table` varchar(50) NOT NULL,
  `to_id` int(11) NOT NULL,
  `action` varchar(50) NOT NULL,
  `user_id` int(11) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ktc_sms`
--

INSERT INTO `ktc_sms` (`id`, `tell`, `sms`, `table`, `to_id`, `action`, `user_id`, `date`) VALUES
(1, '252613712280', '[BULSHO TECH]*%0aAsc Shirkadda Bulsho Tech waxay kugu bishaareyneysaa in dad-ka doonaya Ticket-ka isbitaalada ay usoo kordhisay App u fududeynaya Jarashada Ticket-ka isbitaalada goor kasta iyo goob kasta Fadlan kalasoo deg App-ka https://bit.ly/3XeGXmJ Mahadsanid', 'hospital', 15, 'as_patient', 2, '2023-01-06 20:11:45'),
(2, '252613712280', '[BULSHO TECH]*%0aAsc Shirkadda Bulsho Tech waxay kugu bishaareyneysaa in dad-ka doonaya Ticket-ka isbitaalada ay usoo kordhisay App u fududeynaya Jarashada Ticket-ka isbitaalada goor kasta iyo goob kasta Fadlan kalasoo deg App-ka https://bit.ly/3XeGXmJ Mahadsanid', 'hospital', 15, 'as_patient', 2, '2023-01-06 20:12:52'),
(3, '252613712280', '[BULSHO TECH]*%0aAsc Shirkadda Bulsho Tech waxay kugu bishaareyneysaa in dad-ka doonaya Ticket-ka isbitaalada ay usoo kordhisay App u fududeynaya Jarashada Ticket-ka isbitaalada goor kasta iyo goob kasta Fadlan kalasoo deg App-ka https://bit.ly/3XeGXmJ Mahadsanid', 'hospital', 15, 'as_patient', 2, '2023-01-06 20:13:49'),
(4, '252613712280', '[BULSHO TECH]*%0aAsc Shirkadda Bulsho Tech waxay kugu bishaareyneysaa in dad-ka doonaya Ticket-ka isbitaalada ay usoo kordhisay App u fududeynaya Jarashada Ticket-ka isbitaalada goor kasta iyo goob kasta Fadlan kalasoo deg App-ka https://bit.ly/3XeGXmJ Mahadsanid', 'hospital', 15, 'as_patient', 2, '2023-01-06 20:14:43'),
(5, '252613712280', '[BULSHO TECH]*%0aAsc Shirkadda Bulsho Tech waxay kugu bishaareyneysaa in dad-ka doonaya Ticket-ka isbitaalada ay usoo kordhisay App u fududeynaya Jarashada Ticket-ka isbitaalada goor kasta iyo goob kasta Fadlan kalasoo deg App-ka https://bit.ly/3XeGXmJ Mahadsanid', 'hospital', 15, 'as_patient', 2, '2023-01-06 20:16:18'),
(6, '252613712280', '[BULSHO TECH]*%0aAsc Shirkadda Bulsho Tech waxay kugu bishaareyneysaa in dad-ka doonaya Ticket-ka isbitaalada ay usoo kordhisay App u fududeynaya Jarashada Ticket-ka isbitaalada goor kasta iyo goob kasta Fadlan kalasoo deg App-ka https://bit.ly/3XeGXmJ Mahadsanid', 'hospital', 15, 'as_patient', 2, '2023-01-06 20:16:55'),
(7, '252613712280', '[BULSHO TECH]*%0aAsc Shirkadda Bulsho Tech waxay kugu bishaareyneysaa in dad-ka doonaya Ticket-ka isbitaalada ay usoo kordhisay App u fududeynaya Jarashada Ticket-ka isbitaalada goor kasta iyo goob kasta Fadlan kalasoo deg App-ka https://bit.ly/3XeGXmJ Mahadsanid', 'hospital', 15, 'as_patient', 2, '2023-01-06 20:18:05'),
(8, '252613332244', '[BULSHO TECH]*%0aAsc Shirkadda Bulsho Tech waxay kugu bishaareyneysaa in dad-ka doonaya Ticket-ka isbitaalada ay usoo kordhisay App u fududeynaya Jarashada Ticket-ka isbitaalada goor kasta iyo goob kasta Fadlan kalasoo deg App-ka https://bit.ly/3XeGXmJ Mahadsanid', 'hospital', 35, 'as_patient', 2, '2023-01-06 20:18:24');

-- --------------------------------------------------------

--
-- Table structure for table `ktc_solution`
--

CREATE TABLE `ktc_solution` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `error_id` int(11) NOT NULL,
  `description` varchar(100) NOT NULL,
  `screenshot` varchar(100) NOT NULL,
  `user_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `ktc_sub_category`
--

CREATE TABLE `ktc_sub_category` (
  `id` int(11) NOT NULL,
  `auto_id` int(11) NOT NULL DEFAULT '0',
  `category_id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `icon` varchar(50) NOT NULL,
  `description` text NOT NULL,
  `order_by` int(11) NOT NULL DEFAULT '0',
  `company_id` int(11) NOT NULL DEFAULT '17',
  `user_id` int(11) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ktc_sub_category`
--

INSERT INTO `ktc_sub_category` (`id`, `auto_id`, `category_id`, `name`, `icon`, `description`, `order_by`, `company_id`, `user_id`, `date`) VALUES
(1, 1, 1, 'Forms', 'fa fa-home', '', 0, 1, 1, '2019-07-06 22:50:47'),
(2, 2, 1, 'User Management', 'fa fa-users', '', 0, 1, 1, '2019-07-06 22:50:47'),
(12, 12, 1, 'Reports', 'fa fa-list', '', 0, 1, 2, '2019-07-06 22:50:47'),
(13, 13, 1, 'Labels', 'fa fa-plus', '', 0, 1, 2, '2019-07-06 22:50:47'),
(69, 69, 1, 'Backup & Restore', 'fa fa-database', '', 0, 1, 2, '2019-07-06 22:50:47'),
(158, 81, 1, 'Generated Forms', 'fa fa-pencil-square-o', '', 0, 1, 2, '2021-12-15 05:13:06');

-- --------------------------------------------------------

--
-- Table structure for table `ktc_table_alias`
--

CREATE TABLE `ktc_table_alias` (
  `id` int(11) NOT NULL,
  `table_name` varchar(50) NOT NULL,
  `alias` char(5) NOT NULL,
  `report` varchar(50) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ktc_table_alias`
--

INSERT INTO `ktc_table_alias` (`id`, `table_name`, `alias`, `report`, `date`) VALUES
(1, 'ktc_parameter', 'p', 'ktc_rp_parameter_sp', '2021-03-23 07:57:48');

-- --------------------------------------------------------

--
-- Table structure for table `ktc_todo`
--

CREATE TABLE `ktc_todo` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `description` varchar(100) NOT NULL,
  `status` varchar(100) NOT NULL,
  `user_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `ktc_user`
--

CREATE TABLE `ktc_user` (
  `id` int(11) NOT NULL,
  `auto_id` int(11) NOT NULL DEFAULT '0',
  `name` varchar(100) NOT NULL COMMENT 'name',
  `username` varchar(100) NOT NULL COMMENT 'username',
  `password` varchar(250) NOT NULL,
  `description` varchar(250) NOT NULL COMMENT 'description',
  `tell` varchar(50) NOT NULL COMMENT 'tell',
  `image` varchar(200) NOT NULL COMMENT 'image~file',
  `status` int(11) NOT NULL DEFAULT '1' COMMENT 'status~dropdown~status_',
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `email` varchar(200) NOT NULL COMMENT 'email~email',
  `reset_code` varchar(250) DEFAULT NULL,
  `reset_count` int(11) NOT NULL DEFAULT '0',
  `user_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `branch_id` int(11) NOT NULL COMMENT 'branch_id~dropdown~branch',
  `is_online` int(11) NOT NULL DEFAULT '0',
  `last_login` datetime NOT NULL,
  `last_activity` datetime NOT NULL,
  `last_page` varchar(50) NOT NULL,
  `level` varchar(50) NOT NULL,
  `employee_id` int(11) NOT NULL COMMENT 'employee_id',
  `office_id` int(11) NOT NULL COMMENT 'office_id~dropdown~general,type,office',
  `secret` varchar(100) NOT NULL,
  `is_enable_2fa` int(11) NOT NULL DEFAULT '0' COMMENT 'is_enable_2fa',
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ktc_user`
--

INSERT INTO `ktc_user` (`id`, `auto_id`, `name`, `username`, `password`, `description`, `tell`, `image`, `status`, `date`, `email`, `reset_code`, `reset_count`, `user_id`, `company_id`, `branch_id`, `is_online`, `last_login`, `last_activity`, `last_page`, `level`, `employee_id`, `office_id`, `secret`, `is_enable_2fa`, `action_date`, `modified_date`) VALUES
(2, 2, 'Abdihamid Hussein Gedi', 'kashi', '18587adecc839e551b85ff5088867ee7', '', '615190777', 'uploads/universityofsomalia(uniso)_ktceditsp_20220917113115.jpeg', 1, '2021-07-31 21:31:27', 'abdihamidkashi@gmail.com', '', 0, 1, 1, 3, 1, '2023-08-10 13:54:25', '2023-08-10 13:54:25', '', 'developer', 118, 76, 'SPJJLRNTIYKYDEJ6', 0, '2022-10-07 18:03:38', '2023-08-10 10:54:25'),
(3, 3, 'Abdirahman Sh Ibrahim', 'abdirahmanict', 'e13dd027be0f2152ce387ac0ea83d863', '', '612692022', 'uploads/universityofsomalia(uniso)_ktcusersp_20221117201701.jpeg', 1, '2022-11-17 18:17:01', 'Maanka895@gmail.com', '48962467678f2198a143715428fa9380', 0, 2, 1, 1, 1, '2023-01-06 17:20:08', '2023-01-06 17:20:08', '', 'developer', 118, 78, '5YXQ7SJM3CZSOWF7', 0, '2022-11-17 18:17:01', '2023-01-06 14:20:08'),
(4, 4, 'Bulsho Tech Automatic', 'automatic', 'e13dd027be0f2152ce387ac0ea83d863', '', '612692022', 'uploads/universityofsomalia(uniso)_ktcusersp_20221117201701.jpeg', 1, '2022-11-17 18:17:01', 'Maanka895@gmail.com', '48962467678f2198a143715428fa9380', 0, 2, 1, 1, 1, '2022-12-27 09:44:47', '2022-12-27 09:44:47', '', 'developer', 118, 78, '5YXQ7SJM3CZSOWF7', 0, '2022-11-17 18:17:01', '2022-12-27 06:44:47'),
(5, 5, 'Maxamed axmed baashe', 'baashe', 'e9dc97642da1699fbcc4808f72d20364', '', '634432380', 'uploads/bulshotechapps_ktcusersp_20230110030124.jpeg', 0, '2023-01-10 09:01:24', 'Maxamedbulshaawi101@gmail.com', '3b7c7512d97833e25f517d14c6787b42', 0, 2, 1, 1, 1, '2023-11-28 13:01:31', '2023-11-28 13:01:31', '', '', 0, 0, '', 0, '2023-01-10 09:01:24', '2023-11-28 10:01:31');

--
-- Triggers `ktc_user`
--
DELIMITER $$
CREATE TRIGGER `auto_grant_user` AFTER INSERT ON `ktc_user` FOR EACH ROW INSERT ignore INTO `ktc_user_permission`( `link_id`, `user_id`, `granted_user_id`, `action`,company_id) VALUES (NEW.auto_id,NEW.user_id,NEW.user_id,'user',NEW.company_id)
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `ktc_user_authentication`
--

CREATE TABLE `ktc_user_authentication` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `title` varchar(100) NOT NULL,
  `from` varchar(100) NOT NULL,
  `msg` text NOT NULL,
  `expire` int(11) NOT NULL COMMENT 'as minute',
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `ktc_user_logs`
--

CREATE TABLE `ktc_user_logs` (
  `id` int(11) NOT NULL,
  `user_id` varchar(50) NOT NULL,
  `link_id` int(11) NOT NULL,
  `attempt` int(11) NOT NULL DEFAULT '1',
  `date` datetime NOT NULL,
  `last_date` date NOT NULL,
  `count` int(11) NOT NULL DEFAULT '1',
  `today_count` int(11) NOT NULL,
  `ip` varchar(30) NOT NULL,
  `device` varchar(230) NOT NULL,
  `os` varchar(230) NOT NULL,
  `browser` varchar(230) NOT NULL,
  `country` varchar(230) NOT NULL,
  `region` varchar(230) NOT NULL,
  `city` varchar(230) NOT NULL,
  `cookie` varchar(10) NOT NULL DEFAULT 'Old',
  `tries` int(11) NOT NULL DEFAULT '0',
  `status` int(11) NOT NULL DEFAULT '1' COMMENT '1 secure login , 0 error login, 2 in active login, 3 uncomplete info user login',
  `username` varchar(100) DEFAULT NULL,
  `password` varchar(250) DEFAULT NULL,
  `user_level` varchar(20) NOT NULL DEFAULT 'u',
  `company_id` int(11) NOT NULL DEFAULT '17'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ktc_user_logs`
--

INSERT INTO `ktc_user_logs` (`id`, `user_id`, `link_id`, `attempt`, `date`, `last_date`, `count`, `today_count`, `ip`, `device`, `os`, `browser`, `country`, `region`, `city`, `cookie`, `tries`, `status`, `username`, `password`, `user_level`, `company_id`) VALUES
(1, '2', 0, 1, '2022-12-22 03:14:46', '2022-12-22', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(2, '2', 0, 1, '2022-12-22 03:15:21', '2022-12-22', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(3, '3', 0, 1, '2022-12-22 03:16:37', '2022-12-22', 1, 1, '197.220.84.54', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', 'Old', 0, 1, NULL, NULL, 'u', 1),
(4, '3', 0, 1, '2022-12-22 03:17:02', '2022-12-22', 1, 1, '197.220.84.54', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', 'Old', 0, 1, NULL, NULL, 'u', 1),
(5, '2', 0, 1, '2022-12-22 03:20:50', '2022-12-22', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(6, '3', 0, 1, '2022-12-22 03:21:33', '2022-12-22', 1, 1, '197.220.84.54', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', 'Old', 0, 1, NULL, NULL, 'u', 1),
(7, '0', 0, 1, '2022-12-22 12:21:46', '2022-12-22', 1, 1, '', '', '', '', '', '', '', '', 0, 0, 'kashi', 'Kashi123?', 'u', 1),
(8, '0', 0, 1, '2022-12-22 12:22:03', '2022-12-22', 1, 1, '', '', '', '', '', '', '', '', 0, 0, 'kashi', 'Kashi123', 'u', 1),
(9, '0', 0, 1, '2022-12-22 12:24:26', '2022-12-22', 1, 1, '', '', '', '', '', '', '', '', 0, 0, 'kashi', 'Kashi123?', 'u', 1),
(10, '2', 0, 1, '2022-12-22 03:24:57', '2022-12-22', 1, 1, '', '', '', '', '', '', '', '', 0, 1, NULL, NULL, 'u', 1),
(11, '2', 0, 1, '2022-12-22 03:32:18', '2022-12-22', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(12, '2', 0, 1, '2022-12-22 03:38:49', '2022-12-22', 1, 1, '78.166.226.189', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-M326B', 'Chrome/108.0.0.0 Mobile Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(13, '2', 0, 1, '2022-12-22 03:39:34', '2022-12-22', 1, 1, '78.166.226.189', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-M326B', 'Chrome/108.0.0.0 Mobile Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(14, '3', 0, 1, '2022-12-22 03:40:06', '2022-12-22', 1, 1, '197.220.84.54', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', 'Old', 0, 1, NULL, NULL, 'u', 1),
(15, '2', 0, 1, '2022-12-22 03:40:15', '2022-12-22', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(16, '2', 622, 1, '2022-12-22 12:40:29', '2022-12-22', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', '1', 1, 1, NULL, NULL, 'user', 1),
(17, '2', 622, 1, '2022-12-22 12:42:19', '2022-12-22', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', '1', 1, 1, NULL, NULL, 'user', 1),
(18, '2', 0, 1, '2022-12-22 03:50:17', '2022-12-22', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(19, '2', 0, 1, '2022-12-22 03:50:22', '2022-12-22', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(20, '2', 0, 1, '2022-12-22 03:50:30', '2022-12-22', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(21, '2', 0, 1, '2022-12-22 03:51:09', '2022-12-22', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(22, '2', 0, 1, '2022-12-22 03:51:13', '2022-12-22', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(23, '3', 0, 1, '2022-12-22 03:51:32', '2022-12-22', 1, 1, '197.220.84.54', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', 'Old', 0, 1, NULL, NULL, 'u', 1),
(24, '2', 0, 1, '2022-12-22 03:53:52', '2022-12-22', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(25, '2', 16, 1, '2022-12-22 12:54:47', '2022-12-22', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', '1', 1, 1, NULL, NULL, 'user', 1),
(26, '3', 0, 1, '2022-12-22 11:10:45', '2022-12-22', 1, 1, '192.145.168.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', 'Old', 0, 1, NULL, NULL, 'u', 1),
(27, '2', 0, 1, '2022-12-22 11:16:49', '2022-12-22', 1, 1, '78.166.226.189', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-M326B', 'Chrome/108.0.0.0 Mobile Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(28, '2', 33, 1, '2022-12-22 20:17:40', '2022-12-22', 1, 1, '78.166.226.189', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-M326B', 'Chrome/108.0.0.0 Mobile Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', '1', 1, 1, NULL, NULL, 'user', 1),
(29, '2', 35, 1, '2022-12-22 20:17:55', '2022-12-22', 1, 1, '78.166.226.189', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-M326B', 'Chrome/108.0.0.0 Mobile Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', '1', 1, 1, NULL, NULL, 'user', 1),
(30, '2', 35, 1, '2022-12-22 20:18:18', '2022-12-22', 1, 1, '78.166.226.189', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-M326B', 'Chrome/108.0.0.0 Mobile Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', '1', 1, 1, NULL, NULL, 'user', 1),
(31, '3', 1, 1, '2022-12-22 20:20:08', '2022-12-22', 1, 1, '192.145.168.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(32, '3', 37, 1, '2022-12-22 20:22:25', '2022-12-22', 1, 1, '192.145.168.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(33, '3', 1, 1, '2022-12-22 20:23:33', '2022-12-22', 1, 1, '192.145.168.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(34, '3', 16, 1, '2022-12-22 20:31:48', '2022-12-22', 1, 1, '192.145.168.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(35, '3', 16, 1, '2022-12-22 20:33:17', '2022-12-22', 1, 1, '192.145.168.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(36, '3', 719, 1, '2022-12-22 20:34:34', '2022-12-22', 1, 1, '192.145.168.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(37, '3', 719, 1, '2022-12-22 20:40:12', '2022-12-22', 1, 1, '192.145.168.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(38, '3', 719, 1, '2022-12-22 20:44:53', '2022-12-22', 1, 1, '192.145.168.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(39, '3', 719, 1, '2022-12-22 20:45:48', '2022-12-22', 1, 1, '192.145.168.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(40, '3', 719, 1, '2022-12-22 20:46:12', '2022-12-22', 1, 1, '192.145.168.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(41, '3', 720, 1, '2022-12-22 20:46:32', '2022-12-22', 1, 1, '192.145.168.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(42, '3', 721, 1, '2022-12-22 20:47:05', '2022-12-22', 1, 1, '192.145.168.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(43, '3', 721, 1, '2022-12-22 20:49:14', '2022-12-22', 1, 1, '192.145.168.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(44, '3', 721, 1, '2022-12-22 20:51:02', '2022-12-22', 1, 1, '192.145.168.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(45, '3', 721, 1, '2022-12-22 20:54:09', '2022-12-22', 1, 1, '192.145.168.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(46, '3', 721, 1, '2022-12-22 20:55:35', '2022-12-22', 1, 1, '192.145.168.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(47, '3', 721, 1, '2022-12-22 20:58:13', '2022-12-22', 1, 1, '192.145.168.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(48, '3', 722, 1, '2022-12-22 20:58:31', '2022-12-22', 1, 1, '192.145.168.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(49, '3', 722, 1, '2022-12-22 21:00:36', '2022-12-22', 1, 1, '192.145.168.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(50, '3', 723, 1, '2022-12-22 21:00:48', '2022-12-22', 1, 1, '192.145.168.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(51, '3', 723, 1, '2022-12-22 21:03:05', '2022-12-22', 1, 1, '192.145.168.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(52, '3', 1, 1, '2022-12-22 21:18:30', '2022-12-22', 1, 1, '192.145.168.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(53, '3', 724, 1, '2022-12-22 21:33:40', '2022-12-22', 1, 1, '192.145.168.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(54, '3', 0, 1, '2022-12-23 06:48:31', '2022-12-23', 1, 1, '192.145.168.73', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', 'Old', 0, 1, NULL, NULL, 'u', 1),
(55, '3', 719, 1, '2022-12-23 15:49:27', '2022-12-23', 1, 1, '192.145.168.73', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(56, '3', 719, 1, '2022-12-23 15:50:27', '2022-12-23', 1, 1, '192.145.168.73', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(57, '3', 720, 1, '2022-12-23 15:52:01', '2022-12-23', 1, 1, '192.145.168.73', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(58, '3', 720, 1, '2022-12-23 15:52:54', '2022-12-23', 1, 1, '192.145.168.73', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(59, '3', 721, 1, '2022-12-23 15:53:35', '2022-12-23', 1, 1, '192.145.168.73', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(60, '3', 721, 1, '2022-12-23 15:53:57', '2022-12-23', 1, 1, '192.145.168.73', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(61, '3', 721, 1, '2022-12-23 15:57:09', '2022-12-23', 1, 1, '192.145.168.73', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(62, '3', 722, 1, '2022-12-23 15:58:09', '2022-12-23', 1, 1, '192.145.168.73', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(63, '3', 723, 1, '2022-12-23 16:04:33', '2022-12-23', 1, 1, '192.145.168.73', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(64, '3', 723, 1, '2022-12-23 16:05:23', '2022-12-23', 1, 1, '192.145.168.73', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(65, '3', 724, 1, '2022-12-23 16:07:12', '2022-12-23', 1, 1, '192.145.168.73', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(66, '3', 724, 1, '2022-12-23 16:08:00', '2022-12-23', 1, 1, '192.145.168.73', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(67, '3', 724, 1, '2022-12-23 16:11:17', '2022-12-23', 1, 1, '192.145.168.73', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(68, '3', 0, 1, '2022-12-23 10:21:48', '2022-12-23', 1, 1, '192.145.168.73', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', 'Old', 0, 1, NULL, NULL, 'u', 1),
(69, '3', 724, 1, '2022-12-23 19:23:18', '2022-12-23', 1, 1, '192.145.168.73', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(70, '3', 725, 1, '2022-12-23 19:26:05', '2022-12-23', 1, 1, '192.145.168.73', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(71, '3', 725, 1, '2022-12-23 19:26:06', '2022-12-23', 1, 1, '192.145.168.73', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(72, '3', 725, 1, '2022-12-23 19:26:37', '2022-12-23', 1, 1, '192.145.168.73', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(73, '3', 724, 1, '2022-12-23 19:29:22', '2022-12-23', 1, 1, '192.145.168.73', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(74, '3', 728, 1, '2022-12-23 19:44:39', '2022-12-23', 1, 1, '192.145.168.73', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(75, '3', 728, 1, '2022-12-23 19:45:08', '2022-12-23', 1, 1, '192.145.168.73', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(76, '2', 0, 1, '2022-12-23 12:23:53', '2022-12-23', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(77, '2', 33, 1, '2022-12-23 21:25:35', '2022-12-23', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', '1', 1, 1, NULL, NULL, 'user', 1),
(78, '2', 33, 1, '2022-12-23 21:26:00', '2022-12-23', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', '1', 1, 1, NULL, NULL, 'user', 1),
(79, '2', 721, 1, '2022-12-23 21:27:18', '2022-12-23', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', '1', 1, 1, NULL, NULL, 'user', 1),
(80, '3', 0, 1, '2022-12-23 12:28:41', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', 'Old', 0, 1, NULL, NULL, 'u', 1),
(81, '3', 54, 1, '2022-12-23 21:28:53', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(82, '2', 14, 1, '2022-12-23 21:30:31', '2022-12-23', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', '1', 1, 1, NULL, NULL, 'user', 1),
(83, '2', 14, 1, '2022-12-23 21:30:44', '2022-12-23', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', '1', 1, 1, NULL, NULL, 'user', 1),
(84, '2', 721, 1, '2022-12-23 21:30:49', '2022-12-23', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', '1', 1, 1, NULL, NULL, 'user', 1),
(85, '3', 721, 1, '2022-12-23 21:31:36', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(86, '2', 14, 1, '2022-12-23 21:31:42', '2022-12-23', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', '1', 1, 1, NULL, NULL, 'user', 1),
(87, '3', 721, 1, '2022-12-23 21:32:05', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(88, '3', 721, 1, '2022-12-23 21:32:10', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(89, '2', 14, 1, '2022-12-23 21:34:17', '2022-12-23', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', '1', 1, 1, NULL, NULL, 'user', 1),
(90, '2', 721, 1, '2022-12-23 21:34:24', '2022-12-23', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', '1', 1, 1, NULL, NULL, 'user', 1),
(91, '3', 721, 1, '2022-12-23 21:34:32', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(92, '2', 725, 1, '2022-12-23 21:37:23', '2022-12-23', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', '1', 1, 1, NULL, NULL, 'user', 1),
(93, '2', 725, 1, '2022-12-23 21:38:52', '2022-12-23', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', '1', 1, 1, NULL, NULL, 'user', 1),
(94, '2', 725, 1, '2022-12-23 21:39:35', '2022-12-23', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', '1', 1, 1, NULL, NULL, 'user', 1),
(95, '2', 725, 1, '2022-12-23 21:41:45', '2022-12-23', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', '1', 1, 1, NULL, NULL, 'user', 1),
(96, '3', 721, 1, '2022-12-23 21:42:08', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(97, '2', 721, 1, '2022-12-23 21:45:21', '2022-12-23', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', '1', 1, 1, NULL, NULL, 'user', 1),
(98, '2', 721, 1, '2022-12-23 21:46:13', '2022-12-23', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', '1', 1, 1, NULL, NULL, 'user', 1),
(99, '3', 721, 1, '2022-12-23 21:46:18', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(100, '2', 721, 1, '2022-12-23 21:51:46', '2022-12-23', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', '1', 1, 1, NULL, NULL, 'user', 1),
(101, '2', 725, 1, '2022-12-23 21:51:51', '2022-12-23', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', '1', 1, 1, NULL, NULL, 'user', 1),
(102, '2', 724, 1, '2022-12-23 21:58:48', '2022-12-23', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', '1', 1, 1, NULL, NULL, 'user', 1),
(103, '2', 724, 1, '2022-12-23 21:59:17', '2022-12-23', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', '1', 1, 1, NULL, NULL, 'user', 1),
(104, '2', 724, 1, '2022-12-23 21:59:42', '2022-12-23', 1, 1, '78.166.226.189', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9395, 32.8992 Turk Telekom', '1', 1, 1, NULL, NULL, 'user', 1),
(105, '3', 721, 1, '2022-12-23 22:19:23', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(106, '3', 720, 1, '2022-12-23 22:20:11', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(107, '3', 720, 1, '2022-12-23 22:21:05', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(108, '3', 720, 1, '2022-12-23 22:22:16', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(109, '3', 720, 1, '2022-12-23 22:26:13', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(110, '3', 720, 1, '2022-12-23 22:26:59', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(111, '3', 719, 1, '2022-12-23 22:29:13', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(112, '3', 719, 1, '2022-12-23 22:30:04', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(113, '3', 719, 1, '2022-12-23 22:30:32', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(114, '3', 722, 1, '2022-12-23 22:30:57', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(115, '3', 722, 1, '2022-12-23 22:32:25', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(116, '3', 723, 1, '2022-12-23 22:33:08', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(117, '3', 722, 1, '2022-12-23 22:33:21', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(118, '3', 722, 1, '2022-12-23 22:33:42', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(119, '3', 722, 1, '2022-12-23 22:34:44', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(120, '3', 723, 1, '2022-12-23 22:35:08', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(121, '3', 723, 1, '2022-12-23 22:37:46', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(122, '3', 724, 1, '2022-12-23 22:44:38', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(123, '3', 726, 1, '2022-12-23 22:44:58', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(124, '3', 727, 1, '2022-12-23 22:55:51', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(125, '3', 727, 1, '2022-12-23 22:56:34', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(126, '3', 727, 1, '2022-12-23 22:57:00', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(127, '3', 728, 1, '2022-12-23 23:26:30', '2022-12-23', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(128, '3', 0, 1, '2022-12-24 02:08:13', '2022-12-24', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', 'Old', 0, 1, NULL, NULL, 'u', 1),
(129, '3', 726, 1, '2022-12-24 11:10:34', '2022-12-24', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(130, '3', 727, 1, '2022-12-24 11:10:42', '2022-12-24', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(131, '3', 728, 1, '2022-12-24 11:10:57', '2022-12-24', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(132, '3', 726, 1, '2022-12-24 11:12:19', '2022-12-24', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(133, '3', 728, 1, '2022-12-24 11:13:01', '2022-12-24', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(134, '3', 727, 1, '2022-12-24 11:13:03', '2022-12-24', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(135, '3', 727, 1, '2022-12-24 11:13:03', '2022-12-24', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(136, '3', 728, 1, '2022-12-24 11:21:40', '2022-12-24', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(137, '2', 0, 1, '2022-12-24 02:26:01', '2022-12-24', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(138, '2', 727, 1, '2022-12-24 11:26:22', '2022-12-24', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(139, '2', 727, 1, '2022-12-24 11:26:46', '2022-12-24', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(140, '2', 727, 1, '2022-12-24 11:27:02', '2022-12-24', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(141, '2', 727, 1, '2022-12-24 11:27:57', '2022-12-24', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(142, '3', 726, 1, '2022-12-24 11:29:37', '2022-12-24', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(143, '2', 726, 1, '2022-12-24 11:44:39', '2022-12-24', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(144, '2', 719, 1, '2022-12-24 11:52:40', '2022-12-24', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(145, '2', 726, 1, '2022-12-24 11:53:40', '2022-12-24', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(146, '3', 719, 1, '2022-12-24 11:54:57', '2022-12-24', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(147, '3', 719, 1, '2022-12-24 11:54:58', '2022-12-24', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(148, '2', 719, 1, '2022-12-24 11:55:31', '2022-12-24', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(149, '2', 726, 1, '2022-12-24 11:56:18', '2022-12-24', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(150, '2', 723, 1, '2022-12-24 12:02:08', '2022-12-24', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(151, '3', 723, 1, '2022-12-24 12:02:22', '2022-12-24', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(152, '2', 723, 1, '2022-12-24 12:02:48', '2022-12-24', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(153, '2', 723, 1, '2022-12-24 12:03:00', '2022-12-24', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(154, '2', 723, 1, '2022-12-24 12:03:04', '2022-12-24', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(155, '2', 723, 1, '2022-12-24 12:03:23', '2022-12-24', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(156, '2', 727, 1, '2022-12-24 12:04:30', '2022-12-24', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(157, '2', 14, 1, '2022-12-24 12:04:37', '2022-12-24', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(158, '2', 727, 1, '2022-12-24 12:04:48', '2022-12-24', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(159, '3', 723, 1, '2022-12-24 12:06:30', '2022-12-24', 1, 1, '192.145.168.1', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(160, '2', 722, 1, '2022-12-24 12:09:36', '2022-12-24', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(161, '2', 722, 1, '2022-12-24 12:11:46', '2022-12-24', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(162, '2', 720, 1, '2022-12-24 12:12:00', '2022-12-24', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(163, '2', 720, 1, '2022-12-24 12:12:55', '2022-12-24', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(164, '2', 720, 1, '2022-12-24 12:15:48', '2022-12-24', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(165, '2', 720, 1, '2022-12-24 12:16:42', '2022-12-24', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(166, '2', 722, 1, '2022-12-24 12:18:15', '2022-12-24', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(167, '2', 728, 1, '2022-12-24 12:19:51', '2022-12-24', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(168, '2', 723, 1, '2022-12-24 12:21:40', '2022-12-24', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(169, '3', 0, 1, '2022-12-24 05:17:36', '2022-12-24', 1, 1, '192.145.170.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', 'Old', 0, 1, NULL, NULL, 'u', 1),
(170, '3', 719, 1, '2022-12-24 14:17:37', '2022-12-24', 1, 1, '192.145.170.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(171, '3', 720, 1, '2022-12-24 14:19:38', '2022-12-24', 1, 1, '192.145.170.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(172, '3', 726, 1, '2022-12-24 14:20:13', '2022-12-24', 1, 1, '192.145.170.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(173, '3', 721, 1, '2022-12-24 14:21:33', '2022-12-24', 1, 1, '192.145.170.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(174, '3', 722, 1, '2022-12-24 14:24:32', '2022-12-24', 1, 1, '192.145.170.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(175, '3', 33, 1, '2022-12-24 14:29:32', '2022-12-24', 1, 1, '192.145.170.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(176, '3', 724, 1, '2022-12-24 14:30:23', '2022-12-24', 1, 1, '192.145.170.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(177, '3', 725, 1, '2022-12-24 14:30:39', '2022-12-24', 1, 1, '192.145.170.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(178, '3', 726, 1, '2022-12-24 14:30:47', '2022-12-24', 1, 1, '192.145.170.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(179, '3', 727, 1, '2022-12-24 14:30:55', '2022-12-24', 1, 1, '192.145.170.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(180, '3', 728, 1, '2022-12-24 14:31:04', '2022-12-24', 1, 1, '192.145.170.80', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(181, '2', 0, 1, '2022-12-25 00:17:07', '2022-12-25', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(182, '2', 724, 1, '2022-12-25 09:17:19', '2022-12-25', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(183, '2', 725, 1, '2022-12-25 09:17:22', '2022-12-25', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(184, '2', 725, 1, '2022-12-25 09:17:58', '2022-12-25', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(185, '2', 725, 1, '2022-12-25 09:19:39', '2022-12-25', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(186, '2', 725, 1, '2022-12-25 09:58:02', '2022-12-25', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(187, '2', 722, 1, '2022-12-25 09:58:09', '2022-12-25', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(188, '2', 723, 1, '2022-12-25 10:11:02', '2022-12-25', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1);
INSERT INTO `ktc_user_logs` (`id`, `user_id`, `link_id`, `attempt`, `date`, `last_date`, `count`, `today_count`, `ip`, `device`, `os`, `browser`, `country`, `region`, `city`, `cookie`, `tries`, `status`, `username`, `password`, `user_level`, `company_id`) VALUES
(189, '2', 722, 1, '2022-12-25 10:11:45', '2022-12-25', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(190, '2', 728, 1, '2022-12-25 10:13:00', '2022-12-25', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(191, '2', 728, 1, '2022-12-25 10:14:09', '2022-12-25', 1, 1, '78.172.177.6', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(192, '2', 0, 1, '2022-12-26 01:50:56', '2022-12-26', 1, 1, '88.232.217.143', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(193, '2', 726, 1, '2022-12-26 10:51:02', '2022-12-26', 1, 1, '88.232.217.143', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(194, '2', 720, 1, '2022-12-26 10:53:42', '2022-12-26', 1, 1, '88.232.217.143', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(195, '2', 720, 1, '2022-12-26 10:55:03', '2022-12-26', 1, 1, '88.232.217.143', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(196, '3', 0, 1, '2022-12-26 01:55:08', '2022-12-26', 1, 1, '192.145.168.65', 'Computer', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7', 'Version/16.1 Safari/605.1.15', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', 'Old', 0, 1, NULL, NULL, 'u', 1),
(197, '3', 726, 1, '2022-12-26 10:55:15', '2022-12-26', 1, 1, '192.145.168.65', 'Computer', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7', 'Version/16.1 Safari/605.1.15', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(198, '3', 726, 1, '2022-12-26 10:58:18', '2022-12-26', 1, 1, '192.145.168.65', 'Computer', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7', 'Version/16.1 Safari/605.1.15', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(199, '2', 724, 1, '2022-12-26 10:58:54', '2022-12-26', 1, 1, '88.232.217.143', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(200, '2', 726, 1, '2022-12-26 10:59:40', '2022-12-26', 1, 1, '88.232.217.143', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(201, '3', 0, 1, '2022-12-26 07:44:58', '2022-12-26', 1, 1, '192.145.170.86', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', 'Old', 0, 1, NULL, NULL, 'u', 1),
(202, '3', 14, 1, '2022-12-26 16:45:44', '2022-12-26', 1, 1, '192.145.170.86', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(203, '3', 723, 1, '2022-12-26 16:46:32', '2022-12-26', 1, 1, '192.145.170.86', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(204, '3', 727, 1, '2022-12-26 16:46:49', '2022-12-26', 1, 1, '192.145.170.86', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(205, '3', 728, 1, '2022-12-26 16:51:12', '2022-12-26', 1, 1, '192.145.170.86', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(206, '3', 0, 1, '2022-12-26 11:32:27', '2022-12-26', 1, 1, '192.145.170.86', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', 'Old', 0, 1, NULL, NULL, 'u', 1),
(207, '3', 728, 1, '2022-12-26 20:35:41', '2022-12-26', 1, 1, '192.145.170.86', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(208, '0', 0, 1, '2022-12-27 09:13:06', '2022-12-27', 1, 1, '192.145.168.83', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', 'Old', 0, 0, 'abdirahmanict', '133579', 'u', 1),
(209, '3', 0, 1, '2022-12-27 00:13:31', '2022-12-27', 1, 1, '192.145.168.83', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', 'Old', 0, 1, NULL, NULL, 'u', 1),
(210, '3', 728, 1, '2022-12-27 09:13:53', '2022-12-27', 1, 1, '192.145.168.83', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(211, '3', 0, 1, '2022-12-27 00:44:47', '2022-12-27', 1, 1, '192.145.168.83', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', 'Old', 0, 1, NULL, NULL, 'u', 1),
(212, '3', 727, 1, '2022-12-27 09:44:57', '2022-12-27', 1, 1, '192.145.168.83', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(213, '2', 0, 1, '2022-12-28 12:30:25', '2022-12-28', 1, 1, '88.232.217.143', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-M326B', 'Chrome/108.0.0.0 Mobile Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(214, '2', 720, 1, '2022-12-28 21:30:34', '2022-12-28', 1, 1, '88.232.217.143', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-M326B', 'Chrome/108.0.0.0 Mobile Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(215, '2', 720, 1, '2022-12-28 21:40:08', '2022-12-28', 1, 1, '88.232.217.143', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-M326B', 'Chrome/108.0.0.0 Mobile Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(216, '3', 0, 1, '2022-12-29 01:55:22', '2022-12-29', 1, 1, '192.145.168.64', 'Computer', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7', 'Version/16.1 Safari/605.1.15', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', 'Old', 0, 1, NULL, NULL, 'u', 1),
(217, '3', 720, 1, '2022-12-29 10:55:33', '2022-12-29', 1, 1, '192.145.168.64', 'Computer', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7', 'Version/16.1 Safari/605.1.15', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(218, '3', 720, 1, '2022-12-29 10:55:42', '2022-12-29', 1, 1, '192.145.168.64', 'Computer', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7', 'Version/16.1 Safari/605.1.15', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(219, '2', 0, 1, '2022-12-29 03:32:40', '2022-12-29', 1, 1, '88.232.217.143', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(220, '2', 55, 1, '2022-12-29 12:32:49', '2022-12-29', 1, 1, '88.232.217.143', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(221, '2', 33, 1, '2022-12-29 12:33:30', '2022-12-29', 1, 1, '88.232.217.143', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(222, '2', 33, 1, '2022-12-29 12:33:52', '2022-12-29', 1, 1, '88.232.217.143', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(223, '2', 33, 1, '2022-12-29 12:35:09', '2022-12-29', 1, 1, '88.232.217.143', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(224, '2', 55, 1, '2022-12-29 12:36:42', '2022-12-29', 1, 1, '88.232.217.143', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(225, '2', 55, 1, '2022-12-29 12:36:55', '2022-12-29', 1, 1, '88.232.217.143', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(226, '2', 728, 1, '2022-12-29 12:38:26', '2022-12-29', 1, 1, '88.232.217.143', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(227, '0', 0, 1, '2022-12-29 22:35:51', '2022-12-29', 1, 1, '76.76.14.36', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:108.0', '', 'United States', 'MN Minneapolis', '44.9896, -93.2786 NetSPI', 'Old', 0, 0, 'dnskflkjf', 'fgdfsfvz', 'u', 1),
(228, '0', 0, 1, '2022-12-29 22:36:07', '2022-12-29', 1, 1, '76.76.14.36', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:108.0', '', 'United States', 'MN Minneapolis', '44.9896, -93.2786 NetSPI', 'Old', 0, 0, 'kashi', 'fgsfavf', 'u', 1),
(229, '0', 0, 1, '2022-12-29 22:36:37', '2022-12-29', 1, 1, '76.76.14.36', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:108.0', '', 'United States', 'MN Minneapolis', '44.9896, -93.2786 NetSPI', 'Old', 0, 0, 'kashi&#39;', 'vgfjjb', 'u', 1),
(230, '0', 0, 1, '2022-12-29 22:37:37', '2022-12-29', 1, 1, '76.76.14.36', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:108.0', '', 'United States', 'MN Minneapolis', '44.9896, -93.2786 NetSPI', 'Old', 0, 0, 'kashi&#39; or 1=1 #', 'ghgjffhkhjf', 'u', 1),
(231, '0', 0, 1, '2022-12-29 22:38:18', '2022-12-29', 1, 1, '76.76.14.36', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:108.0', '', 'United States', 'MN Minneapolis', '44.9896, -93.2786 NetSPI', 'Old', 0, 0, '&#39; OR &#39;a&#39;=&#39;a', 'hjhfhhgfhh', 'u', 1),
(232, '0', 0, 1, '2022-12-29 22:39:16', '2022-12-29', 1, 1, '76.76.14.36', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:108.0', '', 'United States', 'MN Minneapolis', '44.9896, -93.2786 NetSPI', 'Old', 0, 0, '&#39; OR &#39;a&#39;=&#39;a', 'hjhfhhgfhh', 'u', 1),
(233, '0', 0, 1, '2022-12-29 22:41:44', '2022-12-29', 1, 1, '76.76.14.36', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:108.0', '', 'United States', 'MN Minneapolis', '44.9896, -93.2786 NetSPI', 'Old', 0, 0, 'kashi', 'ghsdhhdt', 'u', 1),
(234, '0', 0, 1, '2022-12-29 22:44:10', '2022-12-29', 1, 1, '76.76.14.36', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:108.0', '', 'United States', 'MN Minneapolis', '44.9896, -93.2786 NetSPI', 'Old', 0, 0, '&#39; or 1=1 -- a', 'ghsdhhdt', 'u', 1),
(235, '0', 0, 1, '2022-12-29 22:45:18', '2022-12-29', 1, 1, '76.76.14.36', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:108.0', '', 'United States', 'MN Minneapolis', '44.9896, -93.2786 NetSPI', 'Old', 0, 0, '&#39; OR 1=1 #', 'ghsdhhdt', 'u', 1),
(236, '0', 0, 1, '2022-12-29 22:46:30', '2022-12-29', 1, 1, '76.76.14.36', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:108.0', '', 'United States', 'MN Minneapolis', '44.9896, -93.2786 NetSPI', 'Old', 0, 0, '&#39; OR sleep(10) OR &#39;', 'ghsdhhdt', 'u', 1),
(237, '2', 0, 1, '2022-12-29 13:49:15', '2022-12-29', 1, 1, '76.76.14.36', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:108.0', '', 'United States', 'MN Minneapolis', '44.9896, -93.2786 NetSPI', 'Old', 0, 1, NULL, NULL, 'u', 1),
(238, '2', 0, 1, '2022-12-29 13:51:49', '2022-12-29', 1, 1, '76.76.14.36', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.5359.125 Safari/537.36', 'United States', 'MN Minneapolis', '44.9896, -93.2786 NetSPI', 'Old', 0, 1, NULL, NULL, 'u', 1),
(239, '2', 719, 1, '2022-12-29 23:26:52', '2022-12-29', 1, 1, '76.76.14.36', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.5359.125 Safari/537.36', 'United States', 'MN Minneapolis', '44.9896, -93.2786 NetSPI', '1', 1, 1, NULL, NULL, 'user', 1),
(240, '2', 719, 1, '2022-12-29 23:27:20', '2022-12-29', 1, 1, '76.76.14.36', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.5359.125 Safari/537.36', 'United States', 'MN Minneapolis', '44.9896, -93.2786 NetSPI', '1', 1, 1, NULL, NULL, 'user', 1),
(241, '2', 719, 1, '2022-12-29 23:27:40', '2022-12-29', 1, 1, '76.76.14.36', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.5359.125 Safari/537.36', 'United States', 'MN Minneapolis', '44.9896, -93.2786 NetSPI', '1', 1, 1, NULL, NULL, 'user', 1),
(242, '2', 719, 1, '2022-12-29 23:28:18', '2022-12-29', 1, 1, '76.76.14.36', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.5359.125 Safari/537.36', 'United States', 'MN Minneapolis', '44.9896, -93.2786 NetSPI', '1', 1, 1, NULL, NULL, 'user', 1),
(243, '3', 0, 1, '2022-12-29 15:22:15', '2022-12-29', 1, 1, '192.145.168.87', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', 'Old', 0, 1, NULL, NULL, 'u', 1),
(244, '3', 1, 1, '2022-12-30 00:22:33', '2022-12-30', 1, 1, '192.145.168.87', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(245, '3', 731, 1, '2022-12-30 00:24:52', '2022-12-30', 1, 1, '192.145.168.87', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(246, '3', 731, 1, '2022-12-30 00:26:27', '2022-12-30', 1, 1, '192.145.168.87', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(247, '3', 731, 1, '2022-12-30 00:28:53', '2022-12-30', 1, 1, '192.145.168.87', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(248, '3', 731, 1, '2022-12-30 00:30:06', '2022-12-30', 1, 1, '192.145.168.87', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(249, '3', 731, 1, '2022-12-30 00:30:22', '2022-12-30', 1, 1, '192.145.168.87', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(250, '3', 33, 1, '2022-12-30 00:32:35', '2022-12-30', 1, 1, '192.145.168.87', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(251, '3', 55, 1, '2022-12-30 00:34:02', '2022-12-30', 1, 1, '192.145.168.87', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(252, '3', 55, 1, '2022-12-30 00:35:28', '2022-12-30', 1, 1, '192.145.168.87', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(253, '3', 16, 1, '2022-12-30 00:39:49', '2022-12-30', 1, 1, '192.145.168.87', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(254, '3', 55, 1, '2022-12-30 00:40:39', '2022-12-30', 1, 1, '192.145.168.87', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(255, '3', 720, 1, '2022-12-30 00:42:09', '2022-12-30', 1, 1, '192.145.168.87', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(256, '3', 719, 1, '2022-12-30 00:50:41', '2022-12-30', 1, 1, '192.145.168.87', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(257, '3', 719, 1, '2022-12-30 00:54:21', '2022-12-30', 1, 1, '192.145.168.87', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(258, '3', 720, 1, '2022-12-30 00:54:25', '2022-12-30', 1, 1, '192.145.168.87', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(259, '3', 0, 1, '2022-12-30 02:27:35', '2022-12-30', 1, 1, '192.145.168.87', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', 'Old', 0, 1, NULL, NULL, 'u', 1),
(260, '2', 0, 1, '2022-12-30 02:29:27', '2022-12-30', 1, 1, '88.232.217.143', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(261, '2', 33, 1, '2022-12-30 11:29:34', '2022-12-30', 1, 1, '88.232.217.143', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(262, '2', 728, 1, '2022-12-30 11:41:47', '2022-12-30', 1, 1, '88.232.217.143', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(263, '2', 725, 1, '2022-12-30 12:10:43', '2022-12-30', 1, 1, '88.232.217.143', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(264, '2', 33, 1, '2022-12-30 12:11:24', '2022-12-30', 1, 1, '88.232.217.143', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(265, '2', 33, 1, '2022-12-30 12:11:42', '2022-12-30', 1, 1, '88.232.217.143', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(266, '2', 731, 1, '2022-12-30 12:11:46', '2022-12-30', 1, 1, '88.232.217.143', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(267, '2', 649, 1, '2022-12-30 12:12:06', '2022-12-30', 1, 1, '88.232.217.143', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(268, '2', 731, 1, '2022-12-30 12:13:16', '2022-12-30', 1, 1, '88.232.217.143', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(269, '2', 731, 1, '2022-12-30 12:13:47', '2022-12-30', 1, 1, '88.232.217.143', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(270, '2', 731, 1, '2022-12-30 12:14:35', '2022-12-30', 1, 1, '88.232.217.143', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9623, 32.7868 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(271, '3', 0, 1, '2022-12-31 03:09:54', '2022-12-31', 1, 1, '192.145.168.93', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', 'Old', 0, 1, NULL, NULL, 'u', 1),
(272, '3', 33, 1, '2022-12-31 12:11:37', '2022-12-31', 1, 1, '192.145.168.93', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(273, '3', 1, 1, '2022-12-31 12:12:19', '2022-12-31', 1, 1, '192.145.168.93', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(274, '3', 732, 1, '2022-12-31 12:16:13', '2022-12-31', 1, 1, '192.145.168.93', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(275, '3', 733, 1, '2022-12-31 12:20:03', '2022-12-31', 1, 1, '192.145.168.93', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(276, '3', 732, 1, '2022-12-31 12:26:12', '2022-12-31', 1, 1, '192.145.168.93', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(277, '3', 14, 1, '2022-12-31 12:30:53', '2022-12-31', 1, 1, '192.145.168.93', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(278, '3', 732, 1, '2022-12-31 12:31:21', '2022-12-31', 1, 1, '192.145.168.93', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(279, '3', 733, 1, '2022-12-31 12:31:29', '2022-12-31', 1, 1, '192.145.168.93', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(280, '3', 720, 1, '2022-12-31 12:31:44', '2022-12-31', 1, 1, '192.145.168.93', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(281, '3', 724, 1, '2022-12-31 12:42:28', '2022-12-31', 1, 1, '192.145.168.93', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(282, '3', 724, 1, '2022-12-31 12:42:28', '2022-12-31', 1, 1, '192.145.168.93', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(283, '3', 720, 1, '2022-12-31 12:43:31', '2022-12-31', 1, 1, '192.145.168.93', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(284, '3', 724, 1, '2022-12-31 12:45:02', '2022-12-31', 1, 1, '192.145.168.93', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(285, '3', 720, 1, '2022-12-31 12:46:11', '2022-12-31', 1, 1, '192.145.168.93', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(286, '3', 724, 1, '2022-12-31 12:47:39', '2022-12-31', 1, 1, '192.145.168.93', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(287, '3', 724, 1, '2022-12-31 12:52:05', '2022-12-31', 1, 1, '192.145.168.93', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(288, '3', 1, 1, '2022-12-31 13:12:26', '2022-12-31', 1, 1, '192.145.168.93', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(289, '3', 720, 1, '2022-12-31 13:12:35', '2022-12-31', 1, 1, '192.145.168.93', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(290, '3', 724, 1, '2022-12-31 13:13:22', '2022-12-31', 1, 1, '192.145.168.93', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(291, '3', 720, 1, '2022-12-31 13:14:06', '2022-12-31', 1, 1, '192.145.168.93', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(292, '3', 724, 1, '2022-12-31 13:32:11', '2022-12-31', 1, 1, '192.145.168.93', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(293, '3', 720, 1, '2022-12-31 14:36:49', '2022-12-31', 1, 1, '192.145.168.93', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(294, '2', 0, 1, '2022-12-31 08:26:50', '2022-12-31', 1, 1, '88.246.253.36', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '31 Antakya', '36.2073, 36.1619 TurkTelecom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(295, '2', 0, 1, '2023-01-01 01:29:18', '2023-01-01', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(296, '2', 33, 1, '2023-01-01 10:29:30', '2023-01-01', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(297, '2', 1, 1, '2023-01-01 10:32:20', '2023-01-01', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(298, '2', 1, 1, '2023-01-01 10:47:20', '2023-01-01', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(299, '2', 734, 1, '2023-01-01 10:47:25', '2023-01-01', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(300, '2', 734, 1, '2023-01-01 11:19:27', '2023-01-01', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(301, '2', 734, 1, '2023-01-01 11:20:27', '2023-01-01', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(302, '2', 734, 1, '2023-01-01 11:20:50', '2023-01-01', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(303, '2', 734, 1, '2023-01-01 11:36:55', '2023-01-01', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(304, '2', 622, 1, '2023-01-01 11:38:07', '2023-01-01', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(305, '2', 734, 1, '2023-01-01 11:53:35', '2023-01-01', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(306, '2', 734, 1, '2023-01-01 12:12:49', '2023-01-01', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(307, '2', 728, 1, '2023-01-01 12:39:14', '2023-01-01', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(308, '2', 734, 1, '2023-01-01 12:48:06', '2023-01-01', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(309, '2', 0, 1, '2023-01-01 09:24:58', '2023-01-01', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(310, '2', 734, 1, '2023-01-01 18:24:59', '2023-01-01', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(311, '2', 0, 1, '2023-01-01 11:47:04', '2023-01-01', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(312, '2', 33, 1, '2023-01-01 20:47:04', '2023-01-01', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', 'Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(313, '2', 0, 1, '2023-01-04 22:10:08', '2023-01-04', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(314, '2', 0, 1, '2023-01-04 22:10:22', '2023-01-04', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(315, '2', 0, 1, '2023-01-04 22:10:47', '2023-01-04', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(316, '2', 0, 1, '2023-01-04 22:11:05', '2023-01-04', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(317, '2', 0, 1, '2023-01-04 22:11:37', '2023-01-04', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(318, '0', 0, 1, '2023-01-05 07:14:32', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 0, 'kashi', 'Kashi123?1', 'u', 1),
(319, '0', 0, 1, '2023-01-05 07:15:09', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 0, 'kashi', '222', 'u', 1),
(320, '0', 0, 1, '2023-01-05 07:15:55', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 0, 'kashi', '222', 'u', 1),
(321, '0', 0, 1, '2023-01-05 07:16:29', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 0, 'kashi', '222', 'u', 1),
(322, '0', 0, 1, '2023-01-05 07:16:47', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 0, 'kashi', '222', 'u', 1),
(323, '2', 0, 1, '2023-01-04 22:17:01', '2023-01-04', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(324, '0', 0, 1, '2023-01-05 07:17:08', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 0, 'kashi', '11', 'u', 1),
(325, '0', 0, 1, '2023-01-05 07:17:13', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 0, 'kashi', '2', 'u', 1),
(326, '0', 0, 1, '2023-01-05 07:17:19', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 0, 'kashi', '4', 'u', 1),
(327, '0', 0, 1, '2023-01-05 07:17:36', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 0, 'kashi', '2', 'u', 1),
(328, '0', 0, 1, '2023-01-05 07:17:41', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 0, 'kashi', '4', 'u', 1),
(329, '0', 0, 1, '2023-01-05 07:18:16', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 0, 'kashi', '5435', 'u', 1),
(330, '0', 0, 1, '2023-01-05 07:18:24', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 0, 'kashi', '5435', 'u', 1),
(331, '2', 0, 1, '2023-01-04 23:15:12', '2023-01-04', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(332, '0', 0, 1, '2023-01-05 08:15:24', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 0, 'kashi', '111', 'u', 1),
(333, '0', 0, 1, '2023-01-05 08:15:29', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 0, 'kashi', '55', 'u', 1),
(334, '0', 0, 1, '2023-01-05 08:16:23', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 0, 'kashi', '55', 'u', 1),
(335, '0', 0, 1, '2023-01-05 08:16:41', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 0, 'kashi', '55', 'u', 1),
(336, '0', 0, 1, '2023-01-05 08:17:03', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 0, 'kashi', '55', 'u', 1),
(337, '0', 0, 1, '2023-01-05 08:18:41', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 0, 'kashi', '55', 'u', 1),
(338, '0', 0, 1, '2023-01-05 08:18:47', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 0, 'kashi', '55', 'u', 1),
(339, '0', 0, 1, '2023-01-05 08:20:45', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 0, 'kashi', '55', 'u', 1),
(340, '0', 0, 1, '2023-01-05 08:21:02', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 0, 'kashi', '55', 'u', 1),
(341, '0', 0, 1, '2023-01-05 08:21:17', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 0, 'kashi', '55', 'u', 1),
(342, '0', 0, 1, '2023-01-05 08:21:45', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 0, 'kashi', '55', 'u', 1),
(343, '2', 0, 1, '2023-01-04 23:32:11', '2023-01-04', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(344, '2', 0, 1, '2023-01-04 23:32:25', '2023-01-04', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(345, '2', 0, 1, '2023-01-04 23:32:40', '2023-01-04', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(346, '2', 0, 1, '2023-01-04 23:32:45', '2023-01-04', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 1, NULL, NULL, 'u', 1),
(347, '0', 0, 1, '2023-01-05 08:32:51', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 0, 'kashi', '4', 'u', 1),
(348, '0', 0, 1, '2023-01-05 08:33:00', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 0, 0, 'kashi', '5', 'u', 1),
(349, '0', 0, 1, '2023-01-05 08:33:55', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 2, 0, 'kashi', '6', 'u', 1),
(350, '0', 0, 1, '2023-01-05 08:33:59', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 3, 0, 'kashi', '5', 'u', 1),
(351, '2', 0, 1, '2023-01-04 23:34:02', '2023-01-04', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 4, 1, NULL, NULL, 'u', 1),
(352, '2', 719, 1, '2023-01-05 08:34:49', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(353, '2', 724, 1, '2023-01-05 08:40:42', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(354, '2', 724, 1, '2023-01-05 08:52:38', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(355, '2', 0, 1, '2023-01-05 00:52:46', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(356, '2', 724, 1, '2023-01-05 09:52:47', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(357, '2', 1, 1, '2023-01-05 09:52:52', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(358, '2', 1, 1, '2023-01-05 09:55:24', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(359, '2', 1, 1, '2023-01-05 09:56:21', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(360, '2', 735, 1, '2023-01-05 09:56:26', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(361, '2', 735, 1, '2023-01-05 10:00:35', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(362, '2', 735, 1, '2023-01-05 10:00:45', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(363, '2', 33, 1, '2023-01-05 10:03:04', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(364, '2', 33, 1, '2023-01-05 10:05:28', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(365, '2', 735, 1, '2023-01-05 10:05:53', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(366, '2', 735, 1, '2023-01-05 10:06:12', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(367, '2', 735, 1, '2023-01-05 10:18:50', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(368, '2', 735, 1, '2023-01-05 10:22:34', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(369, '2', 735, 1, '2023-01-05 10:22:46', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(370, '2', 735, 1, '2023-01-05 10:24:46', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(371, '2', 735, 1, '2023-01-05 10:26:15', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(372, '2', 735, 1, '2023-01-05 10:35:11', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(373, '2', 735, 1, '2023-01-05 10:43:55', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(374, '2', 735, 1, '2023-01-05 10:44:03', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(375, '2', 735, 1, '2023-01-05 10:44:13', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(376, '2', 735, 1, '2023-01-05 10:44:35', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(377, '2', 735, 1, '2023-01-05 10:46:24', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1);
INSERT INTO `ktc_user_logs` (`id`, `user_id`, `link_id`, `attempt`, `date`, `last_date`, `count`, `today_count`, `ip`, `device`, `os`, `browser`, `country`, `region`, `city`, `cookie`, `tries`, `status`, `username`, `password`, `user_level`, `company_id`) VALUES
(378, '2', 0, 1, '2023-01-05 08:09:03', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(379, '2', 16, 1, '2023-01-05 17:09:12', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(380, '2', 16, 1, '2023-01-05 17:18:57', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(381, '2', 16, 1, '2023-01-05 17:35:15', '2023-01-05', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(382, '3', 0, 1, '2023-01-06 01:39:28', '2023-01-06', 1, 1, '192.145.173.201', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', 'Old', 1, 1, NULL, NULL, 'u', 1),
(383, '3', 0, 1, '2023-01-06 08:20:08', '2023-01-06', 1, 1, '197.220.84.61', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', 'Old', 1, 1, NULL, NULL, 'u', 1),
(384, '3', 1, 1, '2023-01-06 17:32:50', '2023-01-06', 1, 1, '197.220.84.61', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(385, '3', 736, 1, '2023-01-06 17:40:39', '2023-01-06', 1, 1, '197.220.84.61', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(386, '3', 737, 1, '2023-01-06 17:40:53', '2023-01-06', 1, 1, '197.220.84.61', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '1', 1, 1, NULL, NULL, 'user', 1),
(387, '2', 0, 1, '2023-01-10 02:56:17', '2023-01-10', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(388, '2', 41, 1, '2023-01-10 11:56:32', '2023-01-10', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(389, '2', 41, 1, '2023-01-10 11:57:13', '2023-01-10', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(390, '2', 725, 1, '2023-01-10 12:04:39', '2023-01-10', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(391, '2', 725, 1, '2023-01-10 12:08:41', '2023-01-10', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(392, '2', 725, 1, '2023-01-10 12:10:04', '2023-01-10', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(393, '2', 725, 1, '2023-01-10 12:10:24', '2023-01-10', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(394, '2', 725, 1, '2023-01-10 12:10:48', '2023-01-10', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(395, '2', 725, 1, '2023-01-10 12:11:05', '2023-01-10', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(396, '2', 33, 1, '2023-01-10 12:11:18', '2023-01-10', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(397, '0', 0, 1, '2023-01-10 12:33:26', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 0, 'Baashe', 'baashe123', 'u', 1),
(398, '0', 0, 1, '2023-01-10 12:34:42', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 2, 0, 'Baashe', '123456', 'u', 1),
(399, '0', 0, 1, '2023-01-10 12:35:16', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 3, 0, 'Baashe', '123456', 'u', 1),
(400, '0', 0, 1, '2023-01-10 12:35:47', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 4, 0, 'Baashe', 'baashe123', 'u', 1),
(401, '0', 0, 1, '2023-01-10 12:36:02', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 5, 0, 'Baashe', '123456', 'u', 1),
(402, '0', 0, 1, '2023-01-10 12:42:36', '2023-01-10', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 1, 2, 'baashe', 'Baashe123', 'u', 1),
(403, '5', 0, 1, '2023-01-10 03:43:56', '2023-01-10', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 2, 1, NULL, NULL, 'u', 1),
(404, '0', 0, 1, '2023-01-10 12:59:14', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 0, 'Baashe', 'baashe123', 'u', 1),
(405, '5', 0, 1, '2023-01-10 04:02:04', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(406, '0', 0, 1, '2023-01-10 13:14:39', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 0, 'Baashe', 'baashe123', 'u', 1),
(407, '5', 0, 1, '2023-01-10 04:15:28', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 2, 1, NULL, NULL, 'u', 1),
(408, '5', 0, 1, '2023-01-10 04:40:11', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(409, '5', 720, 1, '2023-01-10 13:40:38', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(410, '5', 721, 1, '2023-01-10 13:42:27', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(411, '5', 722, 1, '2023-01-10 13:43:27', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(412, '5', 723, 1, '2023-01-10 13:44:41', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(413, '5', 734, 1, '2023-01-10 13:46:51', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(414, '5', 736, 1, '2023-01-10 13:47:28', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(415, '5', 724, 1, '2023-01-10 13:48:04', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(416, '5', 726, 1, '2023-01-10 13:48:40', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(417, '5', 0, 1, '2023-01-10 04:52:23', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(418, '5', 0, 1, '2023-01-10 04:52:53', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 2, 1, NULL, NULL, 'u', 1),
(419, '5', 0, 1, '2023-01-10 04:52:57', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 3, 1, NULL, NULL, 'u', 1),
(420, '5', 0, 1, '2023-01-10 04:56:15', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(421, '5', 0, 1, '2023-01-10 10:44:06', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(422, '5', 719, 1, '2023-01-10 19:45:12', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(423, '5', 0, 1, '2023-01-10 10:46:32', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(424, '5', 720, 1, '2023-01-10 19:47:49', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(425, '5', 0, 1, '2023-01-10 10:49:57', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(426, '5', 734, 1, '2023-01-10 19:50:14', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(427, '5', 722, 1, '2023-01-10 19:50:47', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(428, '5', 721, 1, '2023-01-10 19:51:16', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(429, '5', 721, 1, '2023-01-10 19:54:00', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(430, '0', 0, 1, '2023-01-10 19:58:04', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 0, 'Baashe', 'Baashe', 'u', 1),
(431, '5', 0, 1, '2023-01-10 10:58:48', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(432, '5', 721, 1, '2023-01-10 19:59:03', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(433, '5', 719, 1, '2023-01-10 19:59:14', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(434, '5', 720, 1, '2023-01-10 19:59:40', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(435, '5', 721, 1, '2023-01-10 20:00:29', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(436, '5', 720, 1, '2023-01-10 20:04:12', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(437, '5', 722, 1, '2023-01-10 20:04:35', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(438, '5', 723, 1, '2023-01-10 20:07:40', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(439, '5', 734, 1, '2023-01-10 20:08:34', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(440, '5', 724, 1, '2023-01-10 20:09:06', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(441, '5', 726, 1, '2023-01-10 20:09:28', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(442, '5', 726, 1, '2023-01-10 20:09:46', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(443, '5', 727, 1, '2023-01-10 20:10:13', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(444, '5', 728, 1, '2023-01-10 20:10:33', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(445, '5', 729, 1, '2023-01-10 20:10:53', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(446, '5', 732, 1, '2023-01-10 20:11:12', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(447, '5', 735, 1, '2023-01-10 20:11:30', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(448, '5', 736, 1, '2023-01-10 20:11:49', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(449, '5', 737, 1, '2023-01-10 20:12:18', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(450, '5', 719, 1, '2023-01-10 20:12:37', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(451, '5', 726, 1, '2023-01-10 20:13:02', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(452, '5', 724, 1, '2023-01-10 20:13:32', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(453, '5', 721, 1, '2023-01-10 20:13:47', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(454, '5', 737, 1, '2023-01-10 20:14:08', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(455, '5', 719, 1, '2023-01-10 20:14:31', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(456, '5', 724, 1, '2023-01-10 20:14:58', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(457, '5', 732, 1, '2023-01-10 20:15:18', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(458, '5', 725, 1, '2023-01-10 20:15:41', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(459, '5', 725, 1, '2023-01-10 20:16:16', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(460, '5', 729, 1, '2023-01-10 20:16:29', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(461, '5', 737, 1, '2023-01-10 20:16:37', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(462, '5', 735, 1, '2023-01-10 20:16:44', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(463, '5', 729, 1, '2023-01-10 20:16:52', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(464, '5', 726, 1, '2023-01-10 20:17:00', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(465, '5', 725, 1, '2023-01-10 20:17:07', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(466, '5', 724, 1, '2023-01-10 20:17:13', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(467, '5', 725, 1, '2023-01-10 20:17:19', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(468, '5', 726, 1, '2023-01-10 20:17:32', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(469, '5', 729, 1, '2023-01-10 20:17:42', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(470, '5', 735, 1, '2023-01-10 20:17:50', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(471, '5', 737, 1, '2023-01-10 20:17:57', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(472, '5', 729, 1, '2023-01-10 20:18:05', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(473, '5', 724, 1, '2023-01-10 20:18:26', '2023-01-10', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(474, '0', 0, 1, '2023-01-11 09:50:25', '2023-01-11', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 0, 'Baashe', 'Baashe', 'u', 1),
(475, '5', 0, 1, '2023-01-11 00:51:00', '2023-01-11', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 2, 1, NULL, NULL, 'u', 1),
(476, '5', 0, 1, '2023-01-11 01:19:51', '2023-01-11', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(477, '5', 721, 1, '2023-01-11 10:20:06', '2023-01-11', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(478, '5', 720, 1, '2023-01-11 10:21:59', '2023-01-11', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(479, '5', 0, 1, '2023-01-11 01:56:08', '2023-01-11', 1, 1, '197.231.201.204', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(480, '5', 720, 1, '2023-01-11 10:56:08', '2023-01-11', 1, 1, '197.231.201.204', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(481, '5', 721, 1, '2023-01-11 10:56:21', '2023-01-11', 1, 1, '197.231.201.204', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(482, '0', 0, 1, '2023-01-11 17:09:34', '2023-01-11', 1, 1, '197.231.201.207', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 0, 'Baaahe', 'Baashe123', 'u', 1),
(483, '5', 0, 1, '2023-01-11 08:10:01', '2023-01-11', 1, 1, '197.231.201.207', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 2, 1, NULL, NULL, 'u', 1),
(484, '5', 721, 1, '2023-01-11 17:10:02', '2023-01-11', 1, 1, '197.231.201.207', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(485, '5', 720, 1, '2023-01-11 17:10:19', '2023-01-11', 1, 1, '197.231.201.207', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(486, '2', 0, 1, '2023-01-11 20:43:07', '2023-01-11', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(487, '2', 725, 1, '2023-01-12 06:43:19', '2023-01-12', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(488, '2', 725, 1, '2023-01-12 06:43:49', '2023-01-12', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(489, '2', 725, 1, '2023-01-12 06:44:17', '2023-01-12', 1, 1, '78.174.41.152', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(490, '5', 0, 1, '2023-01-12 23:32:28', '2023-01-12', 1, 1, '197.231.201.207', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(491, '5', 724, 1, '2023-01-13 08:32:40', '2023-01-13', 1, 1, '197.231.201.207', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(492, '5', 725, 1, '2023-01-13 08:33:06', '2023-01-13', 1, 1, '197.231.201.207', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(493, '5', 726, 1, '2023-01-13 08:34:28', '2023-01-13', 1, 1, '197.231.201.207', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(494, '5', 727, 1, '2023-01-13 08:35:50', '2023-01-13', 1, 1, '197.231.201.207', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(495, '5', 728, 1, '2023-01-13 08:36:04', '2023-01-13', 1, 1, '197.231.201.207', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(496, '5', 729, 1, '2023-01-13 08:36:39', '2023-01-13', 1, 1, '197.231.201.207', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(497, '5', 732, 1, '2023-01-13 08:37:01', '2023-01-13', 1, 1, '197.231.201.207', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(498, '5', 735, 1, '2023-01-13 08:37:10', '2023-01-13', 1, 1, '197.231.201.207', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(499, '5', 736, 1, '2023-01-13 08:37:23', '2023-01-13', 1, 1, '197.231.201.207', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(500, '5', 737, 1, '2023-01-13 08:37:36', '2023-01-13', 1, 1, '197.231.201.207', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(501, '5', 736, 1, '2023-01-13 08:37:45', '2023-01-13', 1, 1, '197.231.201.207', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(502, '5', 0, 1, '2023-01-13 01:08:06', '2023-01-13', 1, 1, '197.231.201.207', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(503, '5', 721, 1, '2023-01-13 10:08:16', '2023-01-13', 1, 1, '197.231.201.207', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(504, '0', 0, 1, '2023-01-13 10:23:48', '2023-01-13', 1, 1, '197.231.201.207', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 0, 'Baashe', 'Baashe', 'u', 1),
(505, '5', 0, 1, '2023-01-13 01:24:34', '2023-01-13', 1, 1, '197.231.201.207', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(506, '5', 721, 1, '2023-01-13 10:24:42', '2023-01-13', 1, 1, '197.231.201.207', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(507, '5', 720, 1, '2023-01-13 10:25:29', '2023-01-13', 1, 1, '197.231.201.207', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(508, '5', 721, 1, '2023-01-13 10:26:54', '2023-01-13', 1, 1, '197.231.201.207', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(509, '5', 719, 1, '2023-01-13 10:27:33', '2023-01-13', 1, 1, '197.231.201.207', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(510, '0', 0, 1, '2023-01-14 13:03:13', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 0, 'Baashe', 'Baashe', 'u', 1),
(511, '5', 0, 1, '2023-01-14 04:04:23', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(512, '5', 0, 1, '2023-01-14 04:04:25', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 2, 1, NULL, NULL, 'u', 1),
(513, '5', 721, 1, '2023-01-14 13:12:34', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(514, '5', 0, 1, '2023-01-14 11:48:58', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(515, '5', 721, 1, '2023-01-14 20:48:58', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(516, '5', 720, 1, '2023-01-14 20:49:10', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(517, '5', 721, 1, '2023-01-14 20:49:44', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(518, '5', 721, 1, '2023-01-14 20:49:51', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(519, '5', 721, 1, '2023-01-14 20:49:58', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(520, '5', 721, 1, '2023-01-14 20:50:08', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(521, '5', 0, 1, '2023-01-14 11:51:07', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(522, '5', 721, 1, '2023-01-14 20:51:07', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(523, '5', 721, 1, '2023-01-14 20:51:14', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(524, '5', 721, 1, '2023-01-14 20:51:23', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(525, '5', 721, 1, '2023-01-14 20:51:41', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(526, '5', 719, 1, '2023-01-14 20:51:48', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(527, '5', 721, 1, '2023-01-14 20:52:02', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(528, '5', 721, 1, '2023-01-14 20:52:13', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(529, '5', 721, 1, '2023-01-14 20:52:24', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(530, '5', 721, 1, '2023-01-14 20:52:36', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(531, '5', 725, 1, '2023-01-14 20:52:48', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(532, '5', 725, 1, '2023-01-14 20:52:58', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(533, '5', 721, 1, '2023-01-14 20:53:06', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(534, '5', 725, 1, '2023-01-14 20:54:17', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(535, '5', 725, 1, '2023-01-14 20:54:27', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(536, '5', 0, 1, '2023-01-14 11:55:31', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(537, '5', 721, 1, '2023-01-14 20:55:31', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(538, '5', 721, 1, '2023-01-14 20:55:49', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(539, '5', 725, 1, '2023-01-14 20:56:06', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(540, '5', 721, 1, '2023-01-14 20:56:27', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(541, '5', 0, 1, '2023-01-14 11:57:14', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(542, '5', 721, 1, '2023-01-14 20:57:15', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(543, '5', 721, 1, '2023-01-14 20:57:39', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(544, '5', 721, 1, '2023-01-14 20:57:46', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(545, '5', 0, 1, '2023-01-14 12:00:30', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(546, '5', 721, 1, '2023-01-14 21:00:30', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(547, '5', 721, 1, '2023-01-14 21:00:48', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(548, '5', 722, 1, '2023-01-14 21:00:57', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(549, '5', 721, 1, '2023-01-14 21:01:11', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(550, '5', 722, 1, '2023-01-14 21:03:23', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(551, '5', 721, 1, '2023-01-14 21:03:34', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(552, '5', 720, 1, '2023-01-14 21:04:16', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(553, '5', 721, 1, '2023-01-14 21:05:50', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(554, '5', 722, 1, '2023-01-14 21:05:51', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(555, '5', 0, 1, '2023-01-14 12:14:27', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(556, '5', 721, 1, '2023-01-14 21:14:27', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(557, '5', 727, 1, '2023-01-14 21:14:46', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(558, '5', 726, 1, '2023-01-14 21:15:04', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(559, '5', 725, 1, '2023-01-14 21:15:15', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(560, '5', 725, 1, '2023-01-14 21:15:29', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(561, '5', 725, 1, '2023-01-14 21:15:40', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(562, '5', 726, 1, '2023-01-14 21:15:47', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(563, '5', 727, 1, '2023-01-14 21:15:59', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(564, '5', 721, 1, '2023-01-14 21:16:18', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(565, '5', 721, 1, '2023-01-14 21:16:32', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1);
INSERT INTO `ktc_user_logs` (`id`, `user_id`, `link_id`, `attempt`, `date`, `last_date`, `count`, `today_count`, `ip`, `device`, `os`, `browser`, `country`, `region`, `city`, `cookie`, `tries`, `status`, `username`, `password`, `user_level`, `company_id`) VALUES
(566, '5', 0, 1, '2023-01-14 12:51:01', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(567, '5', 721, 1, '2023-01-14 21:51:02', '2023-01-14', 1, 1, '197.231.201.170', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(568, '0', 0, 1, '2023-01-15 20:05:24', '2023-01-15', 1, 1, '197.231.201.228', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 0, 'Baashe', 'baashe123', 'u', 1),
(569, '5', 0, 1, '2023-01-15 11:08:37', '2023-01-15', 1, 1, '197.231.201.228', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(570, '5', 721, 1, '2023-01-15 20:08:39', '2023-01-15', 1, 1, '197.231.201.228', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(571, '5', 721, 1, '2023-01-15 20:10:23', '2023-01-15', 1, 1, '197.231.201.228', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(572, '0', 0, 1, '2023-01-15 22:30:34', '2023-01-15', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 6.3; WOW64', ' Chrome/89.0.4389.128 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 0, 'baashe', 'baashe123', 'u', 1),
(573, '0', 0, 1, '2023-01-15 22:33:09', '2023-01-15', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 6.3; WOW64', ' Chrome/89.0.4389.128 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 2, 0, 'Baashe', 'baashe123', 'u', 1),
(574, '0', 0, 1, '2023-01-15 22:34:53', '2023-01-15', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 6.3; WOW64', ' Chrome/89.0.4389.128 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 3, 0, 'Baashe', 'baashe123', 'u', 1),
(575, '0', 0, 1, '2023-01-15 22:35:34', '2023-01-15', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 6.3; WOW64', ' Chrome/89.0.4389.128 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 4, 0, 'Baashe', 'bAASHE123', 'u', 1),
(576, '0', 0, 1, '2023-01-15 22:36:11', '2023-01-15', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 6.3; WOW64', ' Chrome/89.0.4389.128 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 5, 0, 'Baashe', 'bAASHE123', 'u', 1),
(577, '5', 0, 1, '2023-01-15 13:43:16', '2023-01-15', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(578, '5', 721, 1, '2023-01-15 22:43:47', '2023-01-15', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(579, '0', 0, 1, '2023-01-15 22:52:13', '2023-01-15', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 6.3; WOW64', ' Chrome/89.0.4389.128 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 0, 'Baashe', 'BAASHE123', 'u', 1),
(580, '5', 0, 1, '2023-01-15 13:52:43', '2023-01-15', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 6.3; WOW64', ' Chrome/89.0.4389.128 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 2, 1, NULL, NULL, 'u', 1),
(581, '5', 721, 1, '2023-01-15 22:53:10', '2023-01-15', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 6.3; WOW64', ' Chrome/89.0.4389.128 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(582, '5', 0, 1, '2023-01-15 15:05:25', '2023-01-15', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 6.3; WOW64', ' Chrome/89.0.4389.128 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(583, '5', 724, 1, '2023-01-16 00:05:47', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 6.3; WOW64', ' Chrome/89.0.4389.128 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(584, '5', 0, 1, '2023-01-15 15:13:16', '2023-01-15', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 6.3; WOW64', ' Chrome/89.0.4389.128 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(585, '5', 724, 1, '2023-01-16 00:13:50', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 6.3; WOW64', ' Chrome/89.0.4389.128 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(586, '5', 725, 1, '2023-01-16 00:13:57', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 6.3; WOW64', ' Chrome/89.0.4389.128 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(587, '5', 726, 1, '2023-01-16 00:14:02', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 6.3; WOW64', ' Chrome/89.0.4389.128 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(588, '5', 727, 1, '2023-01-16 00:15:04', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 6.3; WOW64', ' Chrome/89.0.4389.128 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(589, '5', 728, 1, '2023-01-16 00:15:39', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 6.3; WOW64', ' Chrome/89.0.4389.128 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(590, '5', 725, 1, '2023-01-16 00:16:07', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 6.3; WOW64', ' Chrome/89.0.4389.128 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(591, '5', 728, 1, '2023-01-16 00:16:26', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 6.3; WOW64', ' Chrome/89.0.4389.128 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(592, '5', 726, 1, '2023-01-16 00:20:23', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 6.3; WOW64', ' Chrome/89.0.4389.128 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(593, '5', 725, 1, '2023-01-16 00:20:30', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 6.3; WOW64', ' Chrome/89.0.4389.128 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(594, '5', 0, 1, '2023-01-15 16:19:48', '2023-01-15', 1, 1, '197.231.201.171', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(595, '5', 721, 1, '2023-01-16 01:19:49', '2023-01-16', 1, 1, '197.231.201.171', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(596, '5', 721, 1, '2023-01-16 01:20:00', '2023-01-16', 1, 1, '197.231.201.171', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(597, '5', 725, 1, '2023-01-16 01:21:53', '2023-01-16', 1, 1, '197.231.201.171', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(598, '5', 725, 1, '2023-01-16 01:22:04', '2023-01-16', 1, 1, '197.231.201.171', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(599, '5', 721, 1, '2023-01-16 01:22:11', '2023-01-16', 1, 1, '197.231.201.171', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(600, '2', 0, 1, '2023-01-15 21:36:09', '2023-01-15', 1, 1, '78.172.177.223', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(601, '5', 0, 1, '2023-01-15 23:39:37', '2023-01-15', 1, 1, '197.231.202.26', 'Computer', 'Mozilla/5.0 (Windows NT 6.3; WOW64', ' Chrome/89.0.4389.128 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56239, 44.077 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(602, '2', 0, 1, '2023-01-16 02:01:29', '2023-01-16', 1, 1, '78.172.177.223', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(603, '2', 74, 1, '2023-01-16 11:01:35', '2023-01-16', 1, 1, '78.172.177.223', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(604, '0', 0, 1, '2023-01-16 11:42:08', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 0, 'Baashe', 'BAASHE123', 'u', 1),
(605, '0', 0, 1, '2023-01-16 11:43:09', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 2, 0, 'Baashe', 'bAashe12', 'u', 1),
(606, '0', 0, 1, '2023-01-16 11:43:34', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 3, 0, 'Baashe', 'BAASHE123', 'u', 1),
(607, '0', 0, 1, '2023-01-16 11:44:27', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 4, 0, 'Baashe', 'baashe1223', 'u', 1),
(608, '0', 0, 1, '2023-01-16 11:46:01', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 5, 0, 'Baashe', 'Baashe12', 'u', 1),
(609, '5', 0, 1, '2023-01-16 02:48:42', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(610, '5', 721, 1, '2023-01-16 11:51:12', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(611, '5', 719, 1, '2023-01-16 11:51:29', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(612, '5', 720, 1, '2023-01-16 11:52:08', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(613, '5', 0, 1, '2023-01-16 03:50:56', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(614, '5', 722, 1, '2023-01-16 12:50:56', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(615, '5', 721, 1, '2023-01-16 12:51:00', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(616, '5', 720, 1, '2023-01-16 12:58:49', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(617, '5', 719, 1, '2023-01-16 12:59:22', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(618, '5', 722, 1, '2023-01-16 13:00:14', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(619, '5', 724, 1, '2023-01-16 13:03:00', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(620, '5', 725, 1, '2023-01-16 13:03:23', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(621, '5', 726, 1, '2023-01-16 13:03:48', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(622, '5', 727, 1, '2023-01-16 13:04:26', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(623, '5', 734, 1, '2023-01-16 13:05:04', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(624, '5', 736, 1, '2023-01-16 13:06:04', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(625, '5', 0, 1, '2023-01-16 04:11:48', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(626, '5', 722, 1, '2023-01-16 13:11:48', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(627, '5', 0, 1, '2023-01-16 04:14:06', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 2, 1, NULL, NULL, 'u', 1),
(628, '5', 722, 1, '2023-01-16 13:14:07', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(629, '5', 0, 1, '2023-01-16 04:17:52', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36 Edg/108.0.1462.76', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(630, '5', 0, 1, '2023-01-16 04:20:22', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36 Edg/108.0.1462.76', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(631, '5', 0, 1, '2023-01-16 04:20:48', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36 Edg/108.0.1462.76', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(632, '5', 0, 1, '2023-01-16 04:21:05', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36 Edg/108.0.1462.76', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(633, '5', 0, 1, '2023-01-16 07:15:46', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36 Edg/108.0.1462.76', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(634, '5', 734, 1, '2023-01-16 16:15:57', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36 Edg/108.0.1462.76', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(635, '5', 729, 1, '2023-01-16 16:16:09', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36 Edg/108.0.1462.76', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(636, '5', 726, 1, '2023-01-16 16:16:21', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36 Edg/108.0.1462.76', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(637, '5', 720, 1, '2023-01-16 16:33:58', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36 Edg/108.0.1462.76', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(638, '5', 0, 1, '2023-01-16 07:49:31', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(639, '5', 722, 1, '2023-01-16 16:49:31', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(640, '5', 0, 1, '2023-01-16 07:49:50', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(641, '5', 722, 1, '2023-01-16 16:49:51', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(642, '5', 722, 1, '2023-01-16 16:50:23', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(643, '5', 722, 1, '2023-01-16 16:50:43', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/86.0.4240.75 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(644, '5', 0, 1, '2023-01-16 08:10:30', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36 Edg/108.0.1462.76', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(645, '5', 0, 1, '2023-01-16 09:06:20', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36 Edg/108.0.1462.76', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(646, '5', 0, 1, '2023-01-16 09:41:32', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36 Edg/108.0.1462.76', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(647, '5', 0, 1, '2023-01-16 10:21:57', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36 Edg/108.0.1462.76', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(648, '5', 721, 1, '2023-01-16 19:22:05', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36 Edg/108.0.1462.76', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(649, '5', 720, 1, '2023-01-16 19:22:17', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36 Edg/108.0.1462.76', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(650, '5', 726, 1, '2023-01-16 19:22:58', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36 Edg/108.0.1462.76', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(651, '5', 0, 1, '2023-01-16 10:26:59', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36 Edg/108.0.1462.76', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(652, '5', 0, 1, '2023-01-16 10:32:49', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36 Edg/108.0.1462.76', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(653, '5', 721, 1, '2023-01-16 19:33:11', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36 Edg/108.0.1462.76', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(654, '5', 721, 1, '2023-01-16 19:33:12', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36 Edg/108.0.1462.76', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(655, '5', 0, 1, '2023-01-16 11:23:26', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36 Edg/109.0.1518.52', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(656, '5', 0, 1, '2023-01-16 11:24:04', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36 Edg/109.0.1518.52', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(657, '5', 720, 1, '2023-01-16 20:24:15', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36 Edg/109.0.1518.52', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(658, '5', 0, 1, '2023-01-16 12:16:34', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36 Edg/109.0.1518.52', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(659, '5', 724, 1, '2023-01-16 21:16:59', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36 Edg/109.0.1518.52', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(660, '5', 0, 1, '2023-01-16 12:20:19', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36 Edg/109.0.1518.52', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(661, '5', 721, 1, '2023-01-16 21:54:07', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36 Edg/109.0.1518.52', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(662, '5', 720, 1, '2023-01-16 22:03:40', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36 Edg/109.0.1518.52', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(663, '5', 721, 1, '2023-01-16 22:04:15', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36 Edg/109.0.1518.52', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(664, '5', 0, 1, '2023-01-16 13:10:07', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(665, '5', 721, 1, '2023-01-16 22:10:08', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(666, '5', 721, 1, '2023-01-16 22:10:27', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(667, '5', 0, 1, '2023-01-16 13:18:22', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(668, '5', 721, 1, '2023-01-16 22:18:22', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(669, '5', 721, 1, '2023-01-16 22:18:30', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(670, '0', 0, 1, '2023-01-16 22:27:00', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 0, 'Baashe', 'Baashe23', 'u', 1),
(671, '5', 0, 1, '2023-01-16 13:27:31', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 2, 1, NULL, NULL, 'u', 1),
(672, '5', 721, 1, '2023-01-16 22:27:31', '2023-01-16', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(673, '5', 0, 1, '2023-01-17 07:40:26', '2023-01-17', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36 Edg/109.0.1518.52', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(674, '5', 724, 1, '2023-01-17 16:40:44', '2023-01-17', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36 Edg/109.0.1518.52', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(675, '5', 0, 1, '2023-01-17 07:41:55', '2023-01-17', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36 Edg/109.0.1518.55', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(676, '5', 0, 1, '2023-01-21 09:29:50', '2023-01-21', 1, 1, '197.231.201.216', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(677, '5', 721, 1, '2023-01-21 18:30:10', '2023-01-21', 1, 1, '197.231.201.216', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(678, '0', 0, 1, '2023-01-22 08:26:21', '2023-01-22', 1, 1, '197.231.201.216', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 0, 'Baashe', 'baashe123', 'u', 1),
(679, '5', 0, 1, '2023-01-21 23:27:04', '2023-01-21', 1, 1, '197.231.201.216', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 2, 1, NULL, NULL, 'u', 1),
(680, '5', 721, 1, '2023-01-22 08:27:46', '2023-01-22', 1, 1, '197.231.201.216', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(681, '0', 0, 1, '2023-01-22 10:57:55', '2023-01-22', 1, 1, '197.231.201.216', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 0, 'Baashe', 'baashe123', 'u', 1),
(682, '5', 0, 1, '2023-01-22 01:58:24', '2023-01-22', 1, 1, '197.231.201.216', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 2, 1, NULL, NULL, 'u', 1),
(683, '5', 0, 1, '2023-01-22 01:58:27', '2023-01-22', 1, 1, '197.231.201.216', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 3, 1, NULL, NULL, 'u', 1),
(684, '5', 721, 1, '2023-01-22 10:58:27', '2023-01-22', 1, 1, '197.231.201.216', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(685, '5', 721, 1, '2023-01-22 10:59:11', '2023-01-22', 1, 1, '197.231.201.216', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(686, '5', 0, 1, '2023-01-23 07:26:52', '2023-01-23', 1, 1, '41.79.197.10', 'Computer', 'Mozilla/5.0 (Windows NT 6.3; WOW64', ' Chrome/89.0.4389.128 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SASomcable Safaricom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(687, '5', 721, 1, '2023-01-23 16:27:05', '2023-01-23', 1, 1, '41.79.197.10', 'Computer', 'Mozilla/5.0 (Windows NT 6.3; WOW64', ' Chrome/89.0.4389.128 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(688, '2', 0, 1, '2023-01-24 02:29:40', '2023-01-24', 1, 1, '78.167.61.48', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9107, 32.8554 TurkTelecom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(689, '2', 74, 1, '2023-01-24 11:30:32', '2023-01-24', 1, 1, '78.167.61.48', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9107, 32.8554 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(690, '2', 74, 1, '2023-01-24 11:32:27', '2023-01-24', 1, 1, '78.167.61.48', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9107, 32.8554 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(691, '2', 738, 1, '2023-01-24 11:32:32', '2023-01-24', 1, 1, '78.167.61.48', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9107, 32.8554 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(692, '2', 738, 1, '2023-01-24 11:33:11', '2023-01-24', 1, 1, '78.167.61.48', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9107, 32.8554 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(693, '2', 738, 1, '2023-01-24 11:33:28', '2023-01-24', 1, 1, '78.167.61.48', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9107, 32.8554 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(694, '2', 738, 1, '2023-01-24 11:34:58', '2023-01-24', 1, 1, '78.167.61.48', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9107, 32.8554 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(695, '5', 0, 1, '2023-01-25 04:18:53', '2023-01-25', 1, 1, '197.231.201.193', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(696, '5', 721, 1, '2023-01-25 13:19:29', '2023-01-25', 1, 1, '197.231.201.193', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(697, '5', 720, 1, '2023-01-25 13:20:00', '2023-01-25', 1, 1, '197.231.201.193', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(698, '2', 0, 1, '2023-01-27 00:14:09', '2023-01-27', 1, 1, '78.167.61.48', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9107, 32.8554 TurkTelecom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(699, '2', 731, 1, '2023-01-27 09:14:19', '2023-01-27', 1, 1, '78.167.61.48', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9107, 32.8554 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(700, '2', 0, 1, '2023-01-27 20:58:20', '2023-01-27', 1, 1, '88.251.27.235', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9107, 32.8554 TurkTelecom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(701, '0', 0, 1, '2023-01-29 10:54:34', '2023-01-29', 1, 1, '197.231.201.214', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 0, 'Baashe', 'baashe123', 'u', 1),
(702, '0', 0, 1, '2023-01-29 10:55:00', '2023-01-29', 1, 1, '197.231.201.214', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 2, 0, 'Baashe', 'Baaahe123', 'u', 1),
(703, '5', 0, 1, '2023-01-29 01:55:24', '2023-01-29', 1, 1, '197.231.201.214', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 3, 1, NULL, NULL, 'u', 1),
(704, '0', 0, 1, '2023-02-07 15:09:01', '2023-02-07', 1, 1, '197.231.201.187', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 0, 'Baashe', 'baashe123', 'u', 1),
(705, '5', 0, 1, '2023-02-08 08:58:45', '2023-02-08', 1, 1, '41.79.198.11', 'Computer', 'Mozilla/5.0 (Windows NT 6.3; WOW64', ' Chrome/89.0.4389.128 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 Somcable', 'Old', 1, 1, NULL, NULL, 'u', 1),
(706, '5', 0, 1, '2023-02-08 08:58:45', '2023-02-08', 1, 1, '41.79.198.11', 'Computer', 'Mozilla/5.0 (Windows NT 6.3; WOW64', ' Chrome/89.0.4389.128 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 Somcable', 'Old', 2, 1, NULL, NULL, 'u', 1),
(707, '5', 720, 1, '2023-02-08 17:59:00', '2023-02-08', 1, 1, '41.79.198.11', 'Computer', 'Mozilla/5.0 (Windows NT 6.3; WOW64', ' Chrome/89.0.4389.128 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 Somcable', '1', 1, 1, NULL, NULL, 'user', 1),
(708, '5', 721, 1, '2023-02-08 17:59:42', '2023-02-08', 1, 1, '41.79.198.11', 'Computer', 'Mozilla/5.0 (Windows NT 6.3; WOW64', ' Chrome/89.0.4389.128 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 Somcable', '1', 1, 1, NULL, NULL, 'user', 1),
(709, '5', 0, 1, '2023-02-14 03:54:03', '2023-02-14', 1, 1, '41.79.198.11', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', 'Old', 1, 1, NULL, NULL, 'u', 1),
(710, '5', 0, 1, '2023-02-14 03:54:05', '2023-02-14', 1, 1, '41.79.198.11', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', 'Old', 2, 1, NULL, NULL, 'u', 1),
(711, '5', 720, 1, '2023-02-14 12:54:17', '2023-02-14', 1, 1, '41.79.198.11', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', '1', 1, 1, NULL, NULL, 'user', 1),
(712, '5', 725, 1, '2023-02-14 12:54:38', '2023-02-14', 1, 1, '41.79.198.11', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', '1', 1, 1, NULL, NULL, 'user', 1),
(713, '5', 0, 1, '2023-02-15 02:00:28', '2023-02-15', 1, 1, '197.231.201.189', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(714, '5', 720, 1, '2023-02-15 11:00:46', '2023-02-15', 1, 1, '197.231.201.189', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(715, '5', 720, 1, '2023-02-15 11:00:46', '2023-02-15', 1, 1, '197.231.201.189', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(716, '5', 0, 1, '2023-02-15 02:01:31', '2023-02-15', 1, 1, '197.231.201.189', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(717, '5', 720, 1, '2023-02-15 11:01:52', '2023-02-15', 1, 1, '197.231.201.189', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(718, '0', 0, 1, '2023-02-15 11:04:45', '2023-02-15', 1, 1, '41.79.198.17', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', 'Old', 1, 0, 'baashe', 'baashe123', 'u', 1),
(719, '5', 0, 1, '2023-02-15 02:05:00', '2023-02-15', 1, 1, '41.79.198.17', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', 'Old', 2, 1, NULL, NULL, 'u', 1),
(720, '5', 720, 1, '2023-02-15 11:05:41', '2023-02-15', 1, 1, '41.79.198.17', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', '1', 1, 1, NULL, NULL, 'user', 1),
(721, '5', 0, 1, '2023-02-15 02:53:33', '2023-02-15', 1, 1, '197.231.201.189', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(722, '2', 0, 1, '2023-02-18 23:43:58', '2023-02-18', 1, 1, '78.167.89.148', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Turkey', '38 Hacılar', '38.6092, 35.2588 TurkTelecom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(723, '2', 0, 1, '2023-02-20 06:47:50', '2023-02-20', 1, 1, '78.167.89.148', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Turkey', '38 Hacılar', '38.6092, 35.2588 TurkTelecom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(724, '5', 0, 1, '2023-02-20 06:54:56', '2023-02-20', 1, 1, '197.231.201.159', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(725, '5', 719, 1, '2023-02-20 16:23:52', '2023-02-20', 1, 1, '197.231.201.159', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(726, '5', 734, 1, '2023-02-20 16:25:42', '2023-02-20', 1, 1, '197.231.201.159', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(727, '5', 720, 1, '2023-02-20 16:26:07', '2023-02-20', 1, 1, '197.231.201.159', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(728, '5', 719, 1, '2023-02-20 16:26:09', '2023-02-20', 1, 1, '197.231.201.159', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(729, '5', 720, 1, '2023-02-20 16:26:35', '2023-02-20', 1, 1, '197.231.201.159', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(730, '5', 721, 1, '2023-02-20 16:26:49', '2023-02-20', 1, 1, '197.231.201.159', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(731, '5', 720, 1, '2023-02-20 16:28:23', '2023-02-20', 1, 1, '197.231.201.159', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(732, '5', 0, 1, '2023-02-20 11:51:37', '2023-02-20', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(733, '5', 720, 1, '2023-02-20 20:51:48', '2023-02-20', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(734, '5', 0, 1, '2023-02-20 13:02:54', '2023-02-20', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(735, '5', 721, 1, '2023-02-20 22:03:08', '2023-02-20', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(736, '5', 721, 1, '2023-02-20 22:03:21', '2023-02-20', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(737, '5', 722, 1, '2023-02-20 22:06:08', '2023-02-20', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(738, '5', 720, 1, '2023-02-20 22:06:27', '2023-02-20', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(739, '5', 721, 1, '2023-02-20 22:08:19', '2023-02-20', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(740, '5', 0, 1, '2023-02-21 08:21:09', '2023-02-21', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.5277, 45.5329 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(741, '5', 720, 1, '2023-02-21 17:21:19', '2023-02-21', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.5277, 45.5329 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(742, '5', 720, 1, '2023-02-21 17:21:19', '2023-02-21', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.5277, 45.5329 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(743, '5', 0, 1, '2023-02-21 08:21:46', '2023-02-21', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.5277, 45.5329 SOMTEL INTERNATIONAL Ltd', 'Old', 2, 1, NULL, NULL, 'u', 1),
(744, '5', 0, 1, '2023-02-21 08:29:06', '2023-02-21', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.5277, 45.5329 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(745, '5', 0, 1, '2023-02-21 08:59:37', '2023-02-21', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.5277, 45.5329 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(746, '5', 721, 1, '2023-02-21 18:00:48', '2023-02-21', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.5277, 45.5329 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(747, '5', 0, 1, '2023-02-21 10:41:34', '2023-02-21', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.5277, 45.5329 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(748, '5', 720, 1, '2023-02-21 19:41:42', '2023-02-21', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.5277, 45.5329 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1);
INSERT INTO `ktc_user_logs` (`id`, `user_id`, `link_id`, `attempt`, `date`, `last_date`, `count`, `today_count`, `ip`, `device`, `os`, `browser`, `country`, `region`, `city`, `cookie`, `tries`, `status`, `username`, `password`, `user_level`, `company_id`) VALUES
(749, '5', 0, 1, '2023-02-21 10:49:51', '2023-02-21', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.5277, 45.5329 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(750, '5', 721, 1, '2023-02-21 19:50:00', '2023-02-21', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.5277, 45.5329 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(751, '5', 0, 1, '2023-02-22 04:15:44', '2023-02-22', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.5277, 45.5329 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(752, '5', 720, 1, '2023-02-22 13:16:09', '2023-02-22', 1, 1, '197.231.202.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.5277, 45.5329 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(753, '5', 0, 1, '2023-02-22 08:23:02', '2023-02-22', 1, 1, '197.231.201.167', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(754, '5', 721, 1, '2023-02-22 17:23:12', '2023-02-22', 1, 1, '197.231.201.167', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(755, '5', 0, 1, '2023-02-27 06:56:01', '2023-02-27', 1, 1, '41.79.198.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', 'Old', 1, 1, NULL, NULL, 'u', 1),
(756, '5', 719, 1, '2023-02-27 15:56:13', '2023-02-27', 1, 1, '41.79.198.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', '1', 1, 1, NULL, NULL, 'user', 1),
(757, '5', 722, 1, '2023-02-27 15:56:21', '2023-02-27', 1, 1, '41.79.198.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', '1', 1, 1, NULL, NULL, 'user', 1),
(758, '5', 723, 1, '2023-02-27 15:56:28', '2023-02-27', 1, 1, '41.79.198.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', '1', 1, 1, NULL, NULL, 'user', 1),
(759, '5', 734, 1, '2023-02-27 15:56:34', '2023-02-27', 1, 1, '41.79.198.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', '1', 1, 1, NULL, NULL, 'user', 1),
(760, '5', 724, 1, '2023-02-27 15:56:43', '2023-02-27', 1, 1, '41.79.198.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', '1', 1, 1, NULL, NULL, 'user', 1),
(761, '5', 726, 1, '2023-02-27 15:56:50', '2023-02-27', 1, 1, '41.79.198.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', '1', 1, 1, NULL, NULL, 'user', 1),
(762, '5', 724, 1, '2023-02-27 15:57:00', '2023-02-27', 1, 1, '41.79.198.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', '1', 1, 1, NULL, NULL, 'user', 1),
(763, '5', 728, 1, '2023-02-27 15:57:39', '2023-02-27', 1, 1, '41.79.198.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', '1', 1, 1, NULL, NULL, 'user', 1),
(764, '5', 725, 1, '2023-02-27 15:57:48', '2023-02-27', 1, 1, '41.79.198.18', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', '1', 1, 1, NULL, NULL, 'user', 1),
(765, '5', 0, 1, '2023-02-28 02:30:38', '2023-02-28', 1, 1, '197.231.201.228', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(766, '5', 737, 1, '2023-02-28 11:30:51', '2023-02-28', 1, 1, '197.231.201.228', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(767, '5', 729, 1, '2023-02-28 11:31:46', '2023-02-28', 1, 1, '197.231.201.228', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(768, '5', 726, 1, '2023-02-28 11:32:13', '2023-02-28', 1, 1, '197.231.201.228', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(769, '5', 0, 1, '2023-02-28 03:17:42', '2023-02-28', 1, 1, '197.231.201.228', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(770, '5', 726, 1, '2023-02-28 12:17:55', '2023-02-28', 1, 1, '197.231.201.228', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(771, '0', 0, 1, '2023-03-01 18:04:08', '2023-03-01', 1, 1, '197.231.201.193', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 0, 'Baashe', 'Baashe', 'u', 1),
(772, '5', 0, 1, '2023-03-01 09:04:38', '2023-03-01', 1, 1, '197.231.201.193', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', 'Old', 2, 1, NULL, NULL, 'u', 1),
(773, '5', 720, 1, '2023-03-01 18:04:56', '2023-03-01', 1, 1, '197.231.201.193', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(774, '5', 724, 1, '2023-03-01 18:08:04', '2023-03-01', 1, 1, '197.231.201.193', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(775, '5', 0, 1, '2023-03-01 09:09:10', '2023-03-01', 1, 1, '197.231.201.193', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', 'Old', 3, 1, NULL, NULL, 'u', 1),
(776, '5', 722, 1, '2023-03-01 18:09:37', '2023-03-01', 1, 1, '197.231.201.193', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(777, '5', 720, 1, '2023-03-01 18:10:04', '2023-03-01', 1, 1, '197.231.201.193', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(778, '5', 719, 1, '2023-03-01 18:12:02', '2023-03-01', 1, 1, '197.231.201.193', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(779, '0', 0, 1, '2023-03-01 18:16:40', '2023-03-01', 1, 1, '197.231.201.193', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 0, 'Baaahe', '123456', 'u', 1),
(780, '5', 0, 1, '2023-03-01 09:17:08', '2023-03-01', 1, 1, '197.231.201.193', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', 'Old', 2, 1, NULL, NULL, 'u', 1),
(781, '5', 723, 1, '2023-03-01 18:17:19', '2023-03-01', 1, 1, '197.231.201.193', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(782, '5', 721, 1, '2023-03-01 18:17:50', '2023-03-01', 1, 1, '197.231.201.193', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(783, '5', 721, 1, '2023-03-01 18:36:17', '2023-03-01', 1, 1, '197.231.201.193', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(784, '5', 720, 1, '2023-03-01 18:37:22', '2023-03-01', 1, 1, '197.231.201.193', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(785, '5', 722, 1, '2023-03-01 18:38:46', '2023-03-01', 1, 1, '197.231.201.193', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(786, '5', 720, 1, '2023-03-01 18:39:04', '2023-03-01', 1, 1, '197.231.201.193', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(787, '5', 721, 1, '2023-03-01 18:39:17', '2023-03-01', 1, 1, '197.231.201.193', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(788, '0', 0, 1, '2023-03-02 09:54:23', '2023-03-02', 1, 1, '197.231.201.230', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 0, 'Baashe', 'Baashe', 'u', 1),
(789, '5', 0, 1, '2023-03-02 00:54:43', '2023-03-02', 1, 1, '197.231.201.230', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', 'Old', 2, 1, NULL, NULL, 'u', 1),
(790, '5', 721, 1, '2023-03-02 09:55:34', '2023-03-02', 1, 1, '197.231.201.230', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(791, '5', 719, 1, '2023-03-02 10:06:55', '2023-03-02', 1, 1, '197.231.201.230', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(792, '5', 727, 1, '2023-03-02 10:08:03', '2023-03-02', 1, 1, '197.231.201.230', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(793, '5', 719, 1, '2023-03-02 10:09:54', '2023-03-02', 1, 1, '197.231.201.230', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(794, '5', 727, 1, '2023-03-02 10:10:58', '2023-03-02', 1, 1, '197.231.201.230', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(795, '5', 726, 1, '2023-03-02 10:11:25', '2023-03-02', 1, 1, '197.231.201.230', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(796, '5', 727, 1, '2023-03-02 10:12:00', '2023-03-02', 1, 1, '197.231.201.230', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(797, '5', 0, 1, '2023-03-02 07:58:45', '2023-03-02', 1, 1, '197.231.203.105', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(798, '5', 720, 1, '2023-03-02 16:59:13', '2023-03-02', 1, 1, '197.231.203.105', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(799, '5', 722, 1, '2023-03-02 17:01:13', '2023-03-02', 1, 1, '197.231.203.105', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(800, '5', 721, 1, '2023-03-02 17:01:38', '2023-03-02', 1, 1, '197.231.203.105', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G', ' Chrome/110.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(801, '5', 0, 1, '2023-03-07 02:31:18', '2023-03-07', 1, 1, '197.231.201.185', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(802, '5', 721, 1, '2023-03-07 11:31:39', '2023-03-07', 1, 1, '197.231.201.185', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(803, '5', 0, 1, '2023-03-07 07:45:36', '2023-03-07', 1, 1, '197.231.201.185', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(804, '5', 722, 1, '2023-03-07 16:46:52', '2023-03-07', 1, 1, '197.231.201.185', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(805, '5', 722, 1, '2023-03-07 16:47:22', '2023-03-07', 1, 1, '197.231.201.185', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(806, '5', 722, 1, '2023-03-07 16:47:30', '2023-03-07', 1, 1, '197.231.201.185', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(807, '5', 721, 1, '2023-03-07 16:47:37', '2023-03-07', 1, 1, '197.231.201.185', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(808, '5', 722, 1, '2023-03-07 16:47:58', '2023-03-07', 1, 1, '197.231.201.185', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(809, '5', 721, 1, '2023-03-07 16:48:39', '2023-03-07', 1, 1, '197.231.201.185', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(810, '5', 0, 1, '2023-03-08 01:17:35', '2023-03-08', 1, 1, '197.231.203.108', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(811, '5', 721, 1, '2023-03-08 10:17:45', '2023-03-08', 1, 1, '197.231.203.108', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(812, '5', 722, 1, '2023-03-08 10:22:53', '2023-03-08', 1, 1, '197.231.203.108', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(813, '5', 723, 1, '2023-03-08 10:23:02', '2023-03-08', 1, 1, '197.231.203.108', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(814, '5', 722, 1, '2023-03-08 10:25:32', '2023-03-08', 1, 1, '197.231.203.108', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(815, '5', 721, 1, '2023-03-08 10:26:46', '2023-03-08', 1, 1, '197.231.203.108', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(816, '5', 722, 1, '2023-03-08 10:31:15', '2023-03-08', 1, 1, '197.231.203.108', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(817, '5', 722, 1, '2023-03-08 10:31:25', '2023-03-08', 1, 1, '197.231.203.108', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(818, '5', 721, 1, '2023-03-08 10:31:25', '2023-03-08', 1, 1, '197.231.203.108', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(819, '5', 722, 1, '2023-03-08 10:37:50', '2023-03-08', 1, 1, '197.231.203.108', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(820, '5', 720, 1, '2023-03-08 10:37:58', '2023-03-08', 1, 1, '197.231.203.108', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(821, '5', 722, 1, '2023-03-08 10:40:46', '2023-03-08', 1, 1, '197.231.203.108', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(822, '5', 721, 1, '2023-03-08 10:40:54', '2023-03-08', 1, 1, '197.231.203.108', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(823, '5', 0, 1, '2023-03-08 01:55:06', '2023-03-08', 1, 1, '197.231.203.108', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(824, '5', 721, 1, '2023-03-08 10:55:15', '2023-03-08', 1, 1, '197.231.203.108', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(825, '5', 720, 1, '2023-03-08 10:57:58', '2023-03-08', 1, 1, '197.231.203.108', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(826, '5', 0, 1, '2023-03-08 02:18:19', '2023-03-08', 1, 1, '197.231.203.108', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(827, '5', 721, 1, '2023-03-08 11:19:04', '2023-03-08', 1, 1, '197.231.203.108', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(828, '5', 0, 1, '2023-03-11 08:24:37', '2023-03-11', 1, 1, '197.231.203.104', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(829, '5', 721, 1, '2023-03-11 17:24:48', '2023-03-11', 1, 1, '197.231.203.104', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(830, '5', 721, 1, '2023-03-11 17:27:39', '2023-03-11', 1, 1, '197.231.203.104', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(831, '5', 720, 1, '2023-03-11 17:35:07', '2023-03-11', 1, 1, '197.231.203.104', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(832, '5', 0, 1, '2023-03-11 08:44:59', '2023-03-11', 1, 1, '197.231.203.104', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(833, '5', 721, 1, '2023-03-11 17:45:00', '2023-03-11', 1, 1, '197.231.203.104', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(834, '5', 721, 1, '2023-03-11 17:45:07', '2023-03-11', 1, 1, '197.231.203.104', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(835, '5', 720, 1, '2023-03-11 17:53:28', '2023-03-11', 1, 1, '197.231.203.104', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(836, '5', 721, 1, '2023-03-11 17:59:12', '2023-03-11', 1, 1, '197.231.203.104', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(837, '5', 721, 1, '2023-03-11 18:08:50', '2023-03-11', 1, 1, '197.231.203.104', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(838, '5', 721, 1, '2023-03-11 18:12:19', '2023-03-11', 1, 1, '197.231.203.104', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(839, '5', 721, 1, '2023-03-11 18:22:39', '2023-03-11', 1, 1, '197.231.203.104', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(840, '5', 0, 1, '2023-03-11 11:02:38', '2023-03-11', 1, 1, '197.231.201.203', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(841, '5', 719, 1, '2023-03-11 20:02:47', '2023-03-11', 1, 1, '197.231.201.203', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(842, '5', 720, 1, '2023-03-11 20:03:26', '2023-03-11', 1, 1, '197.231.201.203', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(843, '5', 0, 1, '2023-03-12 05:05:50', '2023-03-12', 1, 1, '41.79.198.17', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', 'Old', 1, 1, NULL, NULL, 'u', 1),
(844, '5', 721, 1, '2023-03-12 13:05:58', '2023-03-12', 1, 1, '41.79.198.17', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', '1', 1, 1, NULL, NULL, 'user', 1),
(845, '5', 720, 1, '2023-03-12 13:11:21', '2023-03-12', 1, 1, '41.79.198.17', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', '1', 1, 1, NULL, NULL, 'user', 1),
(846, '5', 721, 1, '2023-03-12 13:15:41', '2023-03-12', 1, 1, '41.79.198.17', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', '1', 1, 1, NULL, NULL, 'user', 1),
(847, '5', 720, 1, '2023-03-12 13:20:32', '2023-03-12', 1, 1, '41.79.198.17', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', '1', 1, 1, NULL, NULL, 'user', 1),
(848, '5', 720, 1, '2023-03-12 13:24:09', '2023-03-12', 1, 1, '41.79.198.17', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', '1', 1, 1, NULL, NULL, 'user', 1),
(849, '5', 721, 1, '2023-03-12 13:28:49', '2023-03-12', 1, 1, '41.79.198.17', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', '1', 1, 1, NULL, NULL, 'user', 1),
(850, '5', 720, 1, '2023-03-12 13:33:57', '2023-03-12', 1, 1, '41.79.198.17', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', '1', 1, 1, NULL, NULL, 'user', 1),
(851, '5', 0, 1, '2023-03-12 08:41:33', '2023-03-12', 1, 1, '197.231.201.175', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(852, '5', 720, 1, '2023-03-12 16:41:33', '2023-03-12', 1, 1, '197.231.201.175', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(853, '5', 721, 1, '2023-03-12 16:41:45', '2023-03-12', 1, 1, '197.231.201.175', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(854, '5', 721, 1, '2023-03-12 16:55:41', '2023-03-12', 1, 1, '197.231.201.175', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(855, '5', 720, 1, '2023-03-12 16:59:22', '2023-03-12', 1, 1, '197.231.201.175', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(856, '5', 720, 1, '2023-03-12 17:02:00', '2023-03-12', 1, 1, '197.231.201.175', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(857, '0', 0, 1, '2023-03-13 12:02:56', '2023-03-13', 1, 1, '41.79.197.11', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', 'Old', 1, 0, 'Bulsho', 'Bulsho123', 'u', 1),
(858, '5', 0, 1, '2023-03-13 04:03:18', '2023-03-13', 1, 1, '41.79.197.11', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', 'Old', 2, 1, NULL, NULL, 'u', 1),
(859, '5', 721, 1, '2023-03-13 12:03:31', '2023-03-13', 1, 1, '41.79.197.11', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(860, '5', 720, 1, '2023-03-13 12:10:46', '2023-03-13', 1, 1, '41.79.197.11', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(861, '5', 720, 1, '2023-03-13 12:15:37', '2023-03-13', 1, 1, '41.79.197.11', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(862, '0', 0, 1, '2023-03-17 20:11:07', '2023-03-17', 1, 1, '197.231.201.175', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 0, 'Baaahe', '123456', 'u', 1),
(863, '5', 0, 1, '2023-03-17 12:11:52', '2023-03-17', 1, 1, '197.231.201.175', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 2, 1, NULL, NULL, 'u', 1),
(864, '5', 725, 1, '2023-03-17 20:17:34', '2023-03-17', 1, 1, '197.231.201.175', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(865, '5', 721, 1, '2023-03-17 20:19:01', '2023-03-17', 1, 1, '197.231.201.175', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(866, '5', 720, 1, '2023-03-17 20:23:48', '2023-03-17', 1, 1, '197.231.201.175', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(867, '5', 0, 1, '2023-03-17 13:02:35', '2023-03-17', 1, 1, '197.231.203.103', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(868, '5', 720, 1, '2023-03-17 21:02:52', '2023-03-17', 1, 1, '197.231.203.103', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(869, '5', 721, 1, '2023-03-17 21:06:33', '2023-03-17', 1, 1, '197.231.203.103', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(870, '5', 720, 1, '2023-03-17 21:15:28', '2023-03-17', 1, 1, '197.231.203.103', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(871, '5', 0, 1, '2023-03-20 02:29:03', '2023-03-20', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(872, '5', 719, 1, '2023-03-20 10:29:12', '2023-03-20', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(873, '5', 720, 1, '2023-03-20 10:29:35', '2023-03-20', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(874, '5', 726, 1, '2023-03-20 10:29:53', '2023-03-20', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(875, '5', 726, 1, '2023-03-20 10:30:07', '2023-03-20', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(876, '5', 0, 1, '2023-03-20 02:41:50', '2023-03-20', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(877, '5', 721, 1, '2023-03-20 10:41:59', '2023-03-20', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(878, '5', 720, 1, '2023-03-20 10:47:43', '2023-03-20', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(879, '5', 720, 1, '2023-03-20 10:48:41', '2023-03-20', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(880, '5', 720, 1, '2023-03-20 10:51:23', '2023-03-20', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(881, '5', 720, 1, '2023-03-20 10:56:03', '2023-03-20', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(882, '5', 720, 1, '2023-03-20 10:59:29', '2023-03-20', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(883, '5', 0, 1, '2023-03-20 03:43:18', '2023-03-20', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(884, '5', 727, 1, '2023-03-20 11:43:44', '2023-03-20', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(885, '5', 726, 1, '2023-03-20 11:44:08', '2023-03-20', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(886, '5', 0, 1, '2023-03-20 03:58:34', '2023-03-20', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(887, '5', 722, 1, '2023-03-20 11:59:06', '2023-03-20', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(888, '5', 721, 1, '2023-03-20 11:59:18', '2023-03-20', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(889, '5', 721, 1, '2023-03-20 11:59:18', '2023-03-20', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(890, '5', 721, 1, '2023-03-20 12:01:26', '2023-03-20', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(891, '5', 721, 1, '2023-03-20 12:06:10', '2023-03-20', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(892, '5', 720, 1, '2023-03-20 12:06:42', '2023-03-20', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(893, '5', 719, 1, '2023-03-20 12:09:06', '2023-03-20', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(894, '5', 720, 1, '2023-03-20 12:09:19', '2023-03-20', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(895, '5', 0, 1, '2023-03-22 04:55:01', '2023-03-22', 1, 1, '41.79.197.10', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(896, '5', 721, 1, '2023-03-22 12:57:34', '2023-03-22', 1, 1, '41.79.197.10', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(897, '5', 0, 1, '2023-03-24 09:05:00', '2023-03-24', 1, 1, '197.231.201.191', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(898, '5', 721, 1, '2023-03-24 17:05:10', '2023-03-24', 1, 1, '197.231.201.191', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(899, '5', 721, 1, '2023-03-24 17:09:23', '2023-03-24', 1, 1, '197.231.201.191', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(900, '5', 720, 1, '2023-03-24 17:16:49', '2023-03-24', 1, 1, '197.231.201.191', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(901, '5', 720, 1, '2023-03-24 17:19:16', '2023-03-24', 1, 1, '197.231.201.191', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(902, '5', 0, 1, '2023-03-24 09:27:48', '2023-03-24', 1, 1, '197.231.201.191', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(903, '5', 720, 1, '2023-03-24 17:27:49', '2023-03-24', 1, 1, '197.231.201.191', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(904, '5', 720, 1, '2023-03-24 17:32:37', '2023-03-24', 1, 1, '197.231.201.191', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(905, '5', 720, 1, '2023-03-24 17:44:23', '2023-03-24', 1, 1, '197.231.201.191', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(906, '5', 725, 1, '2023-03-24 17:46:35', '2023-03-24', 1, 1, '197.231.201.191', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(907, '5', 724, 1, '2023-03-24 17:50:01', '2023-03-24', 1, 1, '197.231.201.191', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(908, '5', 724, 1, '2023-03-24 17:50:14', '2023-03-24', 1, 1, '197.231.201.191', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(909, '0', 0, 1, '2023-03-24 18:47:38', '2023-03-24', 1, 1, '197.231.201.191', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 0, 'Baashe', 'Baasghe123', 'u', 1),
(910, '5', 0, 1, '2023-03-24 10:48:12', '2023-03-24', 1, 1, '197.231.201.191', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 2, 1, NULL, NULL, 'u', 1),
(911, '5', 724, 1, '2023-03-24 18:48:38', '2023-03-24', 1, 1, '197.231.201.191', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(912, '5', 725, 1, '2023-03-24 18:56:07', '2023-03-24', 1, 1, '197.231.201.191', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(913, '5', 724, 1, '2023-03-24 19:02:00', '2023-03-24', 1, 1, '197.231.201.191', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(914, '5', 724, 1, '2023-03-24 19:02:11', '2023-03-24', 1, 1, '197.231.201.191', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/110.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(915, '5', 0, 1, '2023-03-24 16:43:50', '2023-03-24', 1, 1, '41.79.197.10', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(916, '5', 724, 1, '2023-03-25 00:44:05', '2023-03-25', 1, 1, '41.79.197.10', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(917, '5', 0, 1, '2023-03-25 02:44:03', '2023-03-25', 1, 1, '41.79.197.10', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(918, '5', 724, 1, '2023-03-25 10:44:15', '2023-03-25', 1, 1, '41.79.197.10', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(919, '5', 725, 1, '2023-03-25 11:06:55', '2023-03-25', 1, 1, '41.79.197.10', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(920, '5', 724, 1, '2023-03-25 11:09:54', '2023-03-25', 1, 1, '41.79.197.10', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(921, '5', 724, 1, '2023-03-25 11:12:36', '2023-03-25', 1, 1, '41.79.197.10', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(922, '5', 724, 1, '2023-03-25 11:14:51', '2023-03-25', 1, 1, '41.79.197.10', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(923, '5', 0, 1, '2023-03-25 03:35:56', '2023-03-25', 1, 1, '197.231.201.197', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(924, '5', 725, 1, '2023-03-25 11:36:09', '2023-03-25', 1, 1, '197.231.201.197', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(925, '5', 0, 1, '2023-03-25 03:48:22', '2023-03-25', 1, 1, '41.79.197.2', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(926, '5', 724, 1, '2023-03-25 11:49:50', '2023-03-25', 1, 1, '41.79.197.2', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(927, '5', 724, 1, '2023-03-25 12:09:47', '2023-03-25', 1, 1, '41.79.197.2', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(928, '5', 724, 1, '2023-03-25 12:10:01', '2023-03-25', 1, 1, '41.79.197.2', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(929, '5', 724, 1, '2023-03-25 12:15:15', '2023-03-25', 1, 1, '41.79.197.2', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(930, '5', 0, 1, '2023-03-25 04:20:24', '2023-03-25', 1, 1, '41.79.197.2', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(931, '5', 724, 1, '2023-03-25 12:20:40', '2023-03-25', 1, 1, '41.79.197.2', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(932, '5', 0, 1, '2023-03-25 04:23:38', '2023-03-25', 1, 1, '41.79.197.2', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(933, '5', 724, 1, '2023-03-25 12:23:46', '2023-03-25', 1, 1, '41.79.197.2', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(934, '5', 0, 1, '2023-03-25 08:24:42', '2023-03-25', 1, 1, '41.79.197.2', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(935, '5', 734, 1, '2023-03-25 16:25:11', '2023-03-25', 1, 1, '41.79.197.2', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1);
INSERT INTO `ktc_user_logs` (`id`, `user_id`, `link_id`, `attempt`, `date`, `last_date`, `count`, `today_count`, `ip`, `device`, `os`, `browser`, `country`, `region`, `city`, `cookie`, `tries`, `status`, `username`, `password`, `user_level`, `company_id`) VALUES
(936, '5', 732, 1, '2023-03-25 16:25:49', '2023-03-25', 1, 1, '41.79.197.2', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(937, '5', 724, 1, '2023-03-25 16:26:11', '2023-03-25', 1, 1, '41.79.197.2', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(938, '5', 0, 1, '2023-03-26 08:28:36', '2023-03-26', 1, 1, '41.79.197.2', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(939, '5', 728, 1, '2023-03-26 16:29:46', '2023-03-26', 1, 1, '41.79.197.2', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(940, '5', 724, 1, '2023-03-26 16:30:12', '2023-03-26', 1, 1, '41.79.197.2', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(941, '5', 0, 1, '2023-03-27 13:10:16', '2023-03-27', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(942, '5', 724, 1, '2023-03-27 21:10:37', '2023-03-27', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(943, '5', 724, 1, '2023-03-27 21:16:17', '2023-03-27', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(944, '5', 725, 1, '2023-03-27 21:17:56', '2023-03-27', 1, 1, '197.231.201.165', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(945, '5', 0, 1, '2023-03-31 14:47:56', '2023-03-31', 1, 1, '197.231.203.106', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(946, '5', 724, 1, '2023-03-31 22:48:11', '2023-03-31', 1, 1, '197.231.203.106', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(947, '5', 0, 1, '2023-03-31 19:45:03', '2023-03-31', 1, 1, '197.231.201.226', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(948, '5', 726, 1, '2023-04-01 03:45:15', '2023-04-01', 1, 1, '197.231.201.226', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(949, '5', 725, 1, '2023-04-01 03:45:34', '2023-04-01', 1, 1, '197.231.201.226', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(950, '5', 726, 1, '2023-04-01 03:51:13', '2023-04-01', 1, 1, '197.231.201.226', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(951, '5', 0, 1, '2023-04-01 05:19:31', '2023-04-01', 1, 1, '197.231.201.226', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(952, '5', 725, 1, '2023-04-01 13:19:42', '2023-04-01', 1, 1, '197.231.201.226', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(953, '5', 0, 1, '2023-04-01 10:12:30', '2023-04-01', 1, 1, '197.231.201.226', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(954, '5', 726, 1, '2023-04-01 18:12:46', '2023-04-01', 1, 1, '197.231.201.226', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(955, '5', 0, 1, '2023-04-01 10:51:05', '2023-04-01', 1, 1, '197.231.201.226', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(956, '5', 725, 1, '2023-04-01 18:51:21', '2023-04-01', 1, 1, '197.231.201.226', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(957, '5', 721, 1, '2023-04-01 18:55:30', '2023-04-01', 1, 1, '197.231.201.226', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(958, '5', 720, 1, '2023-04-01 19:00:07', '2023-04-01', 1, 1, '197.231.201.226', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(959, '5', 0, 1, '2023-04-01 19:30:32', '2023-04-01', 1, 1, '197.231.201.226', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(960, '5', 725, 1, '2023-04-02 03:30:49', '2023-04-02', 1, 1, '197.231.201.226', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(961, '5', 0, 1, '2023-04-02 01:34:20', '2023-04-02', 1, 1, '41.79.197.5', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(962, '5', 725, 1, '2023-04-02 09:35:10', '2023-04-02', 1, 1, '41.79.197.5', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(963, '5', 724, 1, '2023-04-02 09:35:48', '2023-04-02', 1, 1, '41.79.197.5', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(964, '5', 725, 1, '2023-04-02 09:36:55', '2023-04-02', 1, 1, '41.79.197.5', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(965, '5', 725, 1, '2023-04-02 09:39:03', '2023-04-02', 1, 1, '41.79.197.5', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(966, '5', 724, 1, '2023-04-02 09:39:51', '2023-04-02', 1, 1, '41.79.197.5', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(967, '5', 725, 1, '2023-04-02 09:41:24', '2023-04-02', 1, 1, '41.79.197.5', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(968, '5', 724, 1, '2023-04-02 09:41:51', '2023-04-02', 1, 1, '41.79.197.5', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(969, '5', 725, 1, '2023-04-02 09:41:58', '2023-04-02', 1, 1, '41.79.197.5', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(970, '5', 724, 1, '2023-04-02 09:43:36', '2023-04-02', 1, 1, '41.79.197.5', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(971, '5', 724, 1, '2023-04-02 09:44:19', '2023-04-02', 1, 1, '41.79.197.5', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(972, '5', 0, 1, '2023-04-02 01:55:04', '2023-04-02', 1, 1, '197.231.201.226', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(973, '5', 725, 1, '2023-04-02 09:55:32', '2023-04-02', 1, 1, '197.231.201.226', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(974, '5', 724, 1, '2023-04-02 09:55:56', '2023-04-02', 1, 1, '197.231.201.226', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(975, '5', 725, 1, '2023-04-02 09:56:44', '2023-04-02', 1, 1, '197.231.201.226', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(976, '5', 724, 1, '2023-04-02 09:59:43', '2023-04-02', 1, 1, '197.231.201.226', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(977, '5', 725, 1, '2023-04-02 10:01:21', '2023-04-02', 1, 1, '197.231.201.226', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(978, '5', 724, 1, '2023-04-02 10:05:16', '2023-04-02', 1, 1, '197.231.201.226', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(979, '5', 0, 1, '2023-04-02 02:12:14', '2023-04-02', 1, 1, '197.231.201.221', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(980, '5', 724, 1, '2023-04-02 10:12:59', '2023-04-02', 1, 1, '197.231.201.221', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(981, '5', 724, 1, '2023-04-02 10:16:32', '2023-04-02', 1, 1, '197.231.201.221', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(982, '5', 0, 1, '2023-04-02 02:19:35', '2023-04-02', 1, 1, '197.231.201.221', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', 'Old', 2, 1, NULL, NULL, 'u', 1),
(983, '5', 724, 1, '2023-04-02 10:20:24', '2023-04-02', 1, 1, '197.231.201.221', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(984, '5', 721, 1, '2023-04-02 10:21:31', '2023-04-02', 1, 1, '197.231.201.221', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(985, '5', 724, 1, '2023-04-02 10:29:10', '2023-04-02', 1, 1, '197.231.201.221', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(986, '5', 724, 1, '2023-04-02 10:33:27', '2023-04-02', 1, 1, '197.231.201.221', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(987, '5', 724, 1, '2023-04-02 10:42:31', '2023-04-02', 1, 1, '197.231.201.221', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(988, '5', 720, 1, '2023-04-02 10:43:04', '2023-04-02', 1, 1, '197.231.201.221', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(989, '5', 724, 1, '2023-04-02 10:44:49', '2023-04-02', 1, 1, '197.231.201.221', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(990, '5', 724, 1, '2023-04-02 10:45:38', '2023-04-02', 1, 1, '197.231.201.221', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(991, '5', 720, 1, '2023-04-02 10:48:13', '2023-04-02', 1, 1, '197.231.201.221', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(992, '5', 721, 1, '2023-04-02 10:49:31', '2023-04-02', 1, 1, '197.231.201.221', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(993, '5', 725, 1, '2023-04-02 11:22:47', '2023-04-02', 1, 1, '197.231.201.221', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(994, '5', 0, 1, '2023-04-02 04:39:28', '2023-04-02', 1, 1, '41.79.197.5', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(995, '5', 724, 1, '2023-04-02 12:39:51', '2023-04-02', 1, 1, '41.79.197.5', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(996, '5', 0, 1, '2023-04-02 04:50:50', '2023-04-02', 1, 1, '197.231.201.205', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(997, '5', 721, 1, '2023-04-02 12:51:07', '2023-04-02', 1, 1, '197.231.201.205', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(998, '5', 720, 1, '2023-04-02 12:55:52', '2023-04-02', 1, 1, '197.231.201.205', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(999, '5', 725, 1, '2023-04-02 12:58:21', '2023-04-02', 1, 1, '41.79.197.5', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(1000, '5', 724, 1, '2023-04-02 12:59:34', '2023-04-02', 1, 1, '41.79.197.5', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(1001, '5', 720, 1, '2023-04-02 13:00:43', '2023-04-02', 1, 1, '197.231.201.205', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1002, '5', 720, 1, '2023-04-02 13:03:00', '2023-04-02', 1, 1, '197.231.201.205', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1003, '5', 0, 1, '2023-04-02 05:06:55', '2023-04-02', 1, 1, '41.79.197.5', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1004, '5', 720, 1, '2023-04-02 13:07:06', '2023-04-02', 1, 1, '41.79.197.5', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(1005, '5', 720, 1, '2023-04-02 13:19:57', '2023-04-02', 1, 1, '197.231.201.205', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1006, '5', 720, 1, '2023-04-02 13:22:40', '2023-04-02', 1, 1, '197.231.201.205', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1007, '5', 720, 1, '2023-04-02 13:24:49', '2023-04-02', 1, 1, '197.231.201.205', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1008, '5', 0, 1, '2023-04-02 05:43:00', '2023-04-02', 1, 1, '41.79.197.5', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1009, '5', 724, 1, '2023-04-02 13:43:10', '2023-04-02', 1, 1, '41.79.197.5', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(1010, '5', 0, 1, '2023-04-02 05:44:36', '2023-04-02', 1, 1, '197.231.201.205', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1011, '5', 721, 1, '2023-04-02 13:44:48', '2023-04-02', 1, 1, '197.231.201.205', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1012, '5', 720, 1, '2023-04-02 13:49:03', '2023-04-02', 1, 1, '197.231.201.205', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1013, '5', 720, 1, '2023-04-02 13:51:04', '2023-04-02', 1, 1, '197.231.201.205', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1014, '5', 720, 1, '2023-04-02 13:53:38', '2023-04-02', 1, 1, '197.231.201.205', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1015, '5', 0, 1, '2023-04-02 08:08:20', '2023-04-02', 1, 1, '41.79.197.5', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1016, '5', 725, 1, '2023-04-02 16:08:20', '2023-04-02', 1, 1, '41.79.197.5', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(1017, '5', 724, 1, '2023-04-02 16:08:48', '2023-04-02', 1, 1, '41.79.197.5', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(1018, '5', 0, 1, '2023-04-02 08:09:38', '2023-04-02', 1, 1, '41.79.197.5', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1019, '5', 726, 1, '2023-04-02 16:09:56', '2023-04-02', 1, 1, '41.79.197.5', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '1', 1, 1, NULL, NULL, 'user', 1),
(1020, '5', 0, 1, '2023-04-02 10:48:18', '2023-04-02', 1, 1, '197.231.201.180', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1021, '5', 725, 1, '2023-04-02 18:48:29', '2023-04-02', 1, 1, '197.231.201.180', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1022, '5', 0, 1, '2023-04-02 11:08:11', '2023-04-02', 1, 1, '197.231.201.180', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1023, '5', 721, 1, '2023-04-02 19:08:21', '2023-04-02', 1, 1, '197.231.201.180', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1024, '5', 721, 1, '2023-04-02 19:10:20', '2023-04-02', 1, 1, '197.231.201.180', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1025, '5', 721, 1, '2023-04-02 19:15:09', '2023-04-02', 1, 1, '197.231.201.180', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1026, '5', 720, 1, '2023-04-02 19:15:21', '2023-04-02', 1, 1, '197.231.201.180', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1027, '5', 720, 1, '2023-04-02 19:22:51', '2023-04-02', 1, 1, '197.231.201.180', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1028, '5', 0, 1, '2023-04-03 10:42:57', '2023-04-03', 1, 1, '197.231.203.101', 'Mobile', 'Mozilla/5.0 (Linux; U; Android 10; en-us; SM-M022G Build/JOP24G', ' Version/4.0 Chrome/68.0.3440.91 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1029, '5', 724, 1, '2023-04-03 18:43:18', '2023-04-03', 1, 1, '197.231.203.101', 'Mobile', 'Mozilla/5.0 (Linux; U; Android 10; en-us; SM-M022G Build/JOP24G', ' Version/4.0 Chrome/68.0.3440.91 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1030, '5', 724, 1, '2023-04-03 18:44:29', '2023-04-03', 1, 1, '197.231.203.101', 'Mobile', 'Mozilla/5.0 (Linux; U; Android 10; en-us; SM-M022G Build/JOP24G', ' Version/4.0 Chrome/68.0.3440.91 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1031, '5', 720, 1, '2023-04-03 18:45:24', '2023-04-03', 1, 1, '197.231.203.101', 'Mobile', 'Mozilla/5.0 (Linux; U; Android 10; en-us; SM-M022G Build/JOP24G', ' Version/4.0 Chrome/68.0.3440.91 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1032, '5', 720, 1, '2023-04-03 18:57:58', '2023-04-03', 1, 1, '197.231.203.101', 'Mobile', 'Mozilla/5.0 (Linux; U; Android 10; en-us; SM-M022G Build/JOP24G', ' Version/4.0 Chrome/68.0.3440.91 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1033, '5', 0, 1, '2023-04-03 11:02:02', '2023-04-03', 1, 1, '197.231.203.101', 'Mobile', 'Mozilla/5.0 (Linux; U; Android 10; en-us; SM-M022G Build/JOP24G', ' Version/4.0 Chrome/68.0.3440.91 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 2, 1, NULL, NULL, 'u', 1),
(1034, '5', 724, 1, '2023-04-03 19:02:12', '2023-04-03', 1, 1, '197.231.203.101', 'Mobile', 'Mozilla/5.0 (Linux; U; Android 10; en-us; SM-M022G Build/JOP24G', ' Version/4.0 Chrome/68.0.3440.91 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1035, '5', 0, 1, '2023-04-03 11:03:01', '2023-04-03', 1, 1, '197.231.203.101', 'Mobile', 'Mozilla/5.0 (Linux; U; Android 10; en-us; SM-M022G Build/JOP24G', ' Version/4.0 Chrome/68.0.3440.91 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 3, 1, NULL, NULL, 'u', 1),
(1036, '5', 725, 1, '2023-04-03 19:03:10', '2023-04-03', 1, 1, '197.231.203.101', 'Mobile', 'Mozilla/5.0 (Linux; U; Android 10; en-us; SM-M022G Build/JOP24G', ' Version/4.0 Chrome/68.0.3440.91 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1037, '5', 0, 1, '2023-04-08 05:38:43', '2023-04-08', 1, 1, '197.231.201.201', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1038, '5', 725, 1, '2023-04-08 13:39:03', '2023-04-08', 1, 1, '197.231.201.201', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1039, '2', 0, 1, '2023-04-10 21:54:52', '2023-04-10', 1, 1, '88.237.221.70', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/111.0.0.0 Safari/537.36', 'Turkey', '34 Istanbul', '41.0145, 28.9533 TurkTelecom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1040, '2', 719, 1, '2023-04-11 05:54:59', '2023-04-11', 1, 1, '88.237.221.70', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/111.0.0.0 Safari/537.36', 'Turkey', '34 Istanbul', '41.0145, 28.9533 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(1041, '5', 0, 1, '2023-04-11 09:08:24', '2023-04-11', 1, 1, '154.115.222.5', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Telesom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1042, '5', 721, 1, '2023-04-11 17:08:36', '2023-04-11', 1, 1, '154.115.222.5', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Telesom', '1', 1, 1, NULL, NULL, 'user', 1),
(1043, '5', 720, 1, '2023-04-11 17:08:44', '2023-04-11', 1, 1, '154.115.222.5', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Telesom', '1', 1, 1, NULL, NULL, 'user', 1),
(1044, '5', 720, 1, '2023-04-11 17:11:38', '2023-04-11', 1, 1, '154.115.222.5', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Telesom', '1', 1, 1, NULL, NULL, 'user', 1),
(1045, '5', 720, 1, '2023-04-11 17:14:06', '2023-04-11', 1, 1, '154.115.222.5', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Telesom', '1', 1, 1, NULL, NULL, 'user', 1),
(1046, '5', 720, 1, '2023-04-11 17:16:49', '2023-04-11', 1, 1, '154.115.222.5', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Telesom', '1', 1, 1, NULL, NULL, 'user', 1),
(1047, '5', 720, 1, '2023-04-11 17:21:55', '2023-04-11', 1, 1, '154.115.222.5', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Telesom', '1', 1, 1, NULL, NULL, 'user', 1),
(1048, '5', 0, 1, '2023-04-11 13:38:37', '2023-04-11', 1, 1, '197.231.201.202', 'Mobile', 'Mozilla/5.0 (Linux; Android 13; SAMSUNG SM-A135F', ' SamsungBrowser/19.0 Chrome/102.0.5005.125 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1049, '5', 721, 1, '2023-04-11 21:39:20', '2023-04-11', 1, 1, '197.231.201.202', 'Mobile', 'Mozilla/5.0 (Linux; Android 13; SAMSUNG SM-A135F', ' SamsungBrowser/19.0 Chrome/102.0.5005.125 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1050, '5', 0, 1, '2023-04-13 13:42:33', '2023-04-13', 1, 1, '154.115.222.160', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Telesom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1051, '5', 0, 1, '2023-04-14 09:16:29', '2023-04-14', 1, 1, '154.115.222.216', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Telesom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1052, '5', 725, 1, '2023-04-14 17:42:48', '2023-04-14', 1, 1, '154.115.222.216', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Telesom', '1', 1, 1, NULL, NULL, 'user', 1),
(1053, '5', 725, 1, '2023-04-14 17:49:33', '2023-04-14', 1, 1, '154.115.222.216', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Telesom', '1', 1, 1, NULL, NULL, 'user', 1),
(1054, '5', 721, 1, '2023-04-14 17:50:43', '2023-04-14', 1, 1, '154.115.222.216', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Telesom', '1', 1, 1, NULL, NULL, 'user', 1),
(1055, '5', 0, 1, '2023-04-15 04:05:40', '2023-04-15', 1, 1, '197.231.201.227', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1056, '5', 721, 1, '2023-04-15 12:06:01', '2023-04-15', 1, 1, '197.231.201.227', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1057, '5', 720, 1, '2023-04-15 12:08:30', '2023-04-15', 1, 1, '197.231.201.227', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1058, '5', 725, 1, '2023-04-15 12:13:16', '2023-04-15', 1, 1, '197.231.201.227', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1059, '5', 722, 1, '2023-04-15 12:14:18', '2023-04-15', 1, 1, '197.231.201.227', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1060, '5', 721, 1, '2023-04-15 12:14:32', '2023-04-15', 1, 1, '197.231.201.227', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1061, '5', 720, 1, '2023-04-15 12:18:32', '2023-04-15', 1, 1, '197.231.201.227', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1062, '5', 724, 1, '2023-04-15 12:20:42', '2023-04-15', 1, 1, '197.231.201.227', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1063, '5', 720, 1, '2023-04-15 12:20:45', '2023-04-15', 1, 1, '197.231.201.227', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1064, '5', 724, 1, '2023-04-15 13:04:07', '2023-04-15', 1, 1, '197.231.201.227', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1065, '5', 725, 1, '2023-04-15 13:05:23', '2023-04-15', 1, 1, '197.231.201.227', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1066, '5', 724, 1, '2023-04-15 13:06:34', '2023-04-15', 1, 1, '197.231.201.227', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1067, '5', 720, 1, '2023-04-15 13:06:45', '2023-04-15', 1, 1, '197.231.201.227', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1068, '5', 721, 1, '2023-04-15 13:13:24', '2023-04-15', 1, 1, '197.231.201.227', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1069, '5', 720, 1, '2023-04-15 13:16:48', '2023-04-15', 1, 1, '197.231.201.227', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1070, '5', 725, 1, '2023-04-15 13:25:27', '2023-04-15', 1, 1, '197.231.201.227', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1071, '2', 0, 1, '2023-04-15 05:28:10', '2023-04-15', 1, 1, '176.30.190.245', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-M326B', ' Chrome/112.0.0.0 Mobile Safari/537.36', 'Turkey', '06 Ankara', '39.9401, 32.9097 descr Avea Iletisim Hizmetleri', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1072, '2', 725, 1, '2023-04-15 13:28:17', '2023-04-15', 1, 1, '176.30.190.245', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-M326B', ' Chrome/112.0.0.0 Mobile Safari/537.36', 'Turkey', '06 Ankara', '39.9401, 32.9097 descr Avea Iletisim Hizmetleri', '1', 1, 1, NULL, NULL, 'user', 1),
(1073, '5', 725, 1, '2023-04-15 13:32:41', '2023-04-15', 1, 1, '197.231.201.227', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1074, '5', 725, 1, '2023-04-15 13:35:54', '2023-04-15', 1, 1, '197.231.201.227', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1075, '5', 721, 1, '2023-04-15 13:42:24', '2023-04-15', 1, 1, '197.231.201.227', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1076, '5', 725, 1, '2023-04-15 13:42:39', '2023-04-15', 1, 1, '197.231.201.227', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1077, '5', 721, 1, '2023-04-15 13:44:26', '2023-04-15', 1, 1, '197.231.201.227', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1078, '5', 0, 1, '2023-04-22 02:20:24', '2023-04-22', 1, 1, '197.231.201.220', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1079, '5', 721, 1, '2023-04-22 10:20:46', '2023-04-22', 1, 1, '197.231.201.220', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1080, '5', 725, 1, '2023-04-22 10:21:31', '2023-04-22', 1, 1, '197.231.201.220', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1081, '5', 721, 1, '2023-04-22 10:23:10', '2023-04-22', 1, 1, '197.231.201.220', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1082, '5', 725, 1, '2023-04-22 10:23:23', '2023-04-22', 1, 1, '197.231.201.220', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1083, '5', 721, 1, '2023-04-22 10:33:51', '2023-04-22', 1, 1, '197.231.201.220', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1084, '0', 0, 1, '2023-04-24 17:24:36', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 0, 'Bulsho', 'Bulsgo123', 'u', 1),
(1085, '0', 0, 1, '2023-04-24 17:26:16', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 2, 0, 'Bulsho', 'Bulsho123', 'u', 1),
(1086, '5', 0, 1, '2023-04-24 09:26:42', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 3, 1, NULL, NULL, 'u', 1),
(1087, '5', 724, 1, '2023-04-24 17:27:00', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1088, '5', 720, 1, '2023-04-24 17:28:44', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1089, '5', 720, 1, '2023-04-24 17:38:01', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1090, '5', 720, 1, '2023-04-24 17:40:05', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1091, '5', 0, 1, '2023-04-24 10:11:11', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1092, '5', 720, 1, '2023-04-24 18:11:21', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1093, '5', 720, 1, '2023-04-24 18:13:48', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1094, '5', 0, 1, '2023-04-24 10:59:27', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1095, '5', 725, 1, '2023-04-24 18:59:42', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1096, '5', 724, 1, '2023-04-24 19:02:46', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1097, '5', 725, 1, '2023-04-24 19:03:46', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1098, '5', 721, 1, '2023-04-24 19:04:36', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1099, '5', 720, 1, '2023-04-24 19:09:14', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1100, '5', 721, 1, '2023-04-24 19:11:54', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1101, '5', 720, 1, '2023-04-24 19:12:03', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1102, '5', 721, 1, '2023-04-24 19:14:05', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1103, '5', 720, 1, '2023-04-24 19:14:11', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1104, '5', 721, 1, '2023-04-24 19:16:18', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1105, '5', 720, 1, '2023-04-24 19:16:23', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1106, '5', 721, 1, '2023-04-24 19:19:39', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1107, '5', 720, 1, '2023-04-24 19:19:48', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1108, '5', 721, 1, '2023-04-24 19:23:09', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1109, '5', 720, 1, '2023-04-24 19:23:15', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1110, '5', 721, 1, '2023-04-24 19:26:12', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1111, '5', 724, 1, '2023-04-24 19:26:29', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1112, '5', 724, 1, '2023-04-24 19:28:49', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1113, '5', 724, 1, '2023-04-24 19:31:54', '2023-04-24', 1, 1, '197.231.201.223', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1114, '5', 0, 1, '2023-04-25 02:23:34', '2023-04-25', 1, 1, '197.231.201.220', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1115, '5', 725, 1, '2023-04-25 10:23:51', '2023-04-25', 1, 1, '197.231.201.220', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1116, '0', 0, 1, '2023-04-25 17:13:38', '2023-04-25', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 0, 'Baaahe', 'Baashe123', 'u', 1),
(1117, '5', 0, 1, '2023-04-25 09:13:59', '2023-04-25', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 2, 1, NULL, NULL, 'u', 1),
(1118, '5', 725, 1, '2023-04-25 17:14:17', '2023-04-25', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1119, '5', 724, 1, '2023-04-25 17:15:09', '2023-04-25', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1120, '5', 725, 1, '2023-04-25 17:15:49', '2023-04-25', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1121, '5', 725, 1, '2023-04-25 17:18:23', '2023-04-25', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1);
INSERT INTO `ktc_user_logs` (`id`, `user_id`, `link_id`, `attempt`, `date`, `last_date`, `count`, `today_count`, `ip`, `device`, `os`, `browser`, `country`, `region`, `city`, `cookie`, `tries`, `status`, `username`, `password`, `user_level`, `company_id`) VALUES
(1122, '5', 720, 1, '2023-04-25 17:21:55', '2023-04-25', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1123, '5', 725, 1, '2023-04-25 17:26:12', '2023-04-25', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1124, '5', 720, 1, '2023-04-25 17:28:34', '2023-04-25', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1125, '5', 721, 1, '2023-04-25 17:29:47', '2023-04-25', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1126, '5', 720, 1, '2023-04-25 17:33:59', '2023-04-25', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1127, '5', 724, 1, '2023-04-25 17:37:33', '2023-04-25', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1128, '5', 725, 1, '2023-04-25 17:38:11', '2023-04-25', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1129, '5', 720, 1, '2023-04-25 17:39:56', '2023-04-25', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1130, '5', 725, 1, '2023-04-25 17:48:02', '2023-04-25', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1131, '5', 720, 1, '2023-04-25 17:49:39', '2023-04-25', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1132, '5', 725, 1, '2023-04-25 17:53:38', '2023-04-25', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1133, '5', 720, 1, '2023-04-25 17:54:38', '2023-04-25', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1134, '5', 721, 1, '2023-04-25 17:56:40', '2023-04-25', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1135, '5', 720, 1, '2023-04-25 17:59:56', '2023-04-25', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1136, '5', 725, 1, '2023-04-25 18:03:17', '2023-04-25', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1137, '5', 724, 1, '2023-04-25 18:03:29', '2023-04-25', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1138, '5', 725, 1, '2023-04-25 18:04:42', '2023-04-25', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1139, '5', 725, 1, '2023-04-25 18:08:51', '2023-04-25', 1, 1, '197.231.201.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1140, '5', 0, 1, '2023-04-28 12:18:29', '2023-04-28', 1, 1, '41.79.198.8', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1141, '5', 725, 1, '2023-04-28 20:18:46', '2023-04-28', 1, 1, '41.79.198.8', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', '1', 1, 1, NULL, NULL, 'user', 1),
(1142, '5', 0, 1, '2023-04-28 12:39:03', '2023-04-28', 1, 1, '41.79.198.8', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1143, '5', 721, 1, '2023-04-28 20:39:28', '2023-04-28', 1, 1, '41.79.198.8', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', '1', 1, 1, NULL, NULL, 'user', 1),
(1144, '5', 720, 1, '2023-04-28 20:43:09', '2023-04-28', 1, 1, '41.79.198.8', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/111.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', '1', 1, 1, NULL, NULL, 'user', 1),
(1145, '5', 0, 1, '2023-05-14 03:13:10', '2023-05-14', 1, 1, '197.231.201.186', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/113.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1146, '5', 725, 1, '2023-05-14 11:13:28', '2023-05-14', 1, 1, '197.231.201.186', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/113.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1147, '5', 0, 1, '2023-06-04 00:12:59', '2023-06-04', 1, 1, '197.231.201.205', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1148, '5', 725, 1, '2023-06-04 08:13:22', '2023-06-04', 1, 1, '197.231.201.205', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1149, '5', 736, 1, '2023-06-04 08:15:11', '2023-06-04', 1, 1, '197.231.201.205', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1150, '5', 737, 1, '2023-06-04 08:15:52', '2023-06-04', 1, 1, '197.231.201.205', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1151, '5', 734, 1, '2023-06-04 08:16:07', '2023-06-04', 1, 1, '197.231.201.205', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1152, '5', 719, 1, '2023-06-04 08:16:22', '2023-06-04', 1, 1, '197.231.201.205', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1153, '5', 723, 1, '2023-06-04 08:16:53', '2023-06-04', 1, 1, '197.231.201.205', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1154, '2', 0, 1, '2023-06-04 05:09:15', '2023-06-04', 1, 1, '95.5.24.158', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/113.0.0.0 Safari/537.36', 'Turkey', '38 Hacilar', '38.6092, 35.2588 Turk Telekomunikasyon Anonim Sirketi', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1155, '2', 622, 1, '2023-06-04 13:09:24', '2023-06-04', 1, 1, '95.5.24.158', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/113.0.0.0 Safari/537.36', 'Turkey', '38 Hacilar', '38.6092, 35.2588 Turk Telekomunikasyon Anonim Sirketi', '1', 1, 1, NULL, NULL, 'user', 1),
(1156, '5', 0, 1, '2023-07-24 13:54:24', '2023-07-24', 1, 1, '197.231.201.198', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1157, '5', 0, 1, '2023-07-24 13:54:24', '2023-07-24', 1, 1, '197.231.201.198', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', 'Old', 2, 1, NULL, NULL, 'u', 1),
(1158, '5', 727, 1, '2023-07-24 21:55:19', '2023-07-24', 1, 1, '197.231.201.198', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1159, '5', 0, 1, '2023-07-31 03:55:11', '2023-07-31', 1, 1, '197.231.201.184', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1160, '5', 725, 1, '2023-07-31 11:55:24', '2023-07-31', 1, 1, '197.231.201.184', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1161, '5', 0, 1, '2023-07-31 11:43:54', '2023-07-31', 1, 1, '197.231.201.184', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1162, '5', 725, 1, '2023-07-31 19:43:54', '2023-07-31', 1, 1, '197.231.201.184', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1163, '5', 737, 1, '2023-07-31 19:44:36', '2023-07-31', 1, 1, '197.231.201.184', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1164, '5', 727, 1, '2023-07-31 19:44:51', '2023-07-31', 1, 1, '197.231.201.184', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1165, '5', 736, 1, '2023-07-31 19:45:34', '2023-07-31', 1, 1, '197.231.201.184', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1166, '5', 727, 1, '2023-07-31 19:46:00', '2023-07-31', 1, 1, '197.231.201.184', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1167, '2', 0, 1, '2023-08-10 05:54:25', '2023-08-10', 1, 1, '85.110.149.108', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/115.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9205, 32.8372 TurkTelecom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1168, '2', 720, 1, '2023-08-10 13:54:45', '2023-08-10', 1, 1, '85.110.149.108', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/115.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9205, 32.8372 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(1169, '2', 14, 1, '2023-08-10 14:04:16', '2023-08-10', 1, 1, '85.110.149.108', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/115.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9205, 32.8372 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(1170, '2', 720, 1, '2023-08-10 14:07:39', '2023-08-10', 1, 1, '85.110.149.108', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/115.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9205, 32.8372 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(1171, '2', 724, 1, '2023-08-10 14:08:32', '2023-08-10', 1, 1, '85.110.149.108', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/115.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9205, 32.8372 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(1172, '5', 0, 1, '2023-08-10 06:08:48', '2023-08-10', 1, 1, '197.231.201.166', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1173, '2', 724, 1, '2023-08-10 14:09:25', '2023-08-10', 1, 1, '85.110.149.108', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/115.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9205, 32.8372 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(1174, '5', 720, 1, '2023-08-10 14:09:28', '2023-08-10', 1, 1, '197.231.201.166', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1175, '2', 720, 1, '2023-08-10 14:09:29', '2023-08-10', 1, 1, '85.110.149.108', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/115.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9205, 32.8372 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(1176, '2', 720, 1, '2023-08-10 14:11:07', '2023-08-10', 1, 1, '85.110.149.108', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/115.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9205, 32.8372 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(1177, '5', 719, 1, '2023-08-10 14:11:07', '2023-08-10', 1, 1, '197.231.201.166', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1178, '5', 720, 1, '2023-08-10 14:11:18', '2023-08-10', 1, 1, '197.231.201.166', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1179, '2', 724, 1, '2023-08-10 14:11:47', '2023-08-10', 1, 1, '85.110.149.108', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/115.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9205, 32.8372 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(1180, '5', 724, 1, '2023-08-10 14:13:34', '2023-08-10', 1, 1, '197.231.201.166', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1181, '2', 14, 1, '2023-08-10 14:14:59', '2023-08-10', 1, 1, '85.110.149.108', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/115.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9205, 32.8372 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(1182, '2', 724, 1, '2023-08-10 14:15:28', '2023-08-10', 1, 1, '85.110.149.108', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/115.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9205, 32.8372 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(1183, '2', 724, 1, '2023-08-10 14:15:42', '2023-08-10', 1, 1, '85.110.149.108', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/115.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9205, 32.8372 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(1184, '5', 737, 1, '2023-08-10 14:15:50', '2023-08-10', 1, 1, '197.231.201.166', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1185, '5', 724, 1, '2023-08-10 14:16:03', '2023-08-10', 1, 1, '197.231.201.166', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1186, '2', 724, 1, '2023-08-10 14:16:36', '2023-08-10', 1, 1, '85.110.149.108', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/115.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9205, 32.8372 TurkTelecom', '1', 1, 1, NULL, NULL, 'user', 1),
(1187, '5', 727, 1, '2023-08-10 14:16:44', '2023-08-10', 1, 1, '197.231.201.166', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1188, '5', 724, 1, '2023-08-10 14:16:55', '2023-08-10', 1, 1, '197.231.201.166', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1189, '5', 0, 1, '2023-08-10 06:32:51', '2023-08-10', 1, 1, '197.231.201.166', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1190, '5', 720, 1, '2023-08-10 14:33:20', '2023-08-10', 1, 1, '197.231.201.166', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1191, '5', 0, 1, '2023-08-24 09:08:17', '2023-08-24', 1, 1, '197.231.201.199', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1192, '5', 725, 1, '2023-08-24 17:08:47', '2023-08-24', 1, 1, '197.231.201.199', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1193, '5', 0, 1, '2023-08-24 09:14:13', '2023-08-24', 1, 1, '197.231.201.199', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', 'Old', 2, 1, NULL, NULL, 'u', 1),
(1194, '5', 725, 1, '2023-08-24 17:14:27', '2023-08-24', 1, 1, '197.231.201.199', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/114.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1195, '0', 0, 1, '2023-08-28 12:05:07', '2023-08-28', 1, 1, '154.115.222.139', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/116.0.0.0 Safari/537.36', 'Somalia', 'MU Diga gaw', '5.69935, 48.4664 Telesom', 'Old', 1, 0, 'Baashe', 'Bqashe123', 'u', 1),
(1196, '5', 0, 1, '2023-08-28 04:05:32', '2023-08-28', 1, 1, '154.115.222.139', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/116.0.0.0 Safari/537.36', 'Somalia', 'MU Diga gaw', '5.69935, 48.4664 Telesom', 'Old', 2, 1, NULL, NULL, 'u', 1),
(1197, '5', 725, 1, '2023-08-28 12:05:49', '2023-08-28', 1, 1, '154.115.222.139', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/116.0.0.0 Safari/537.36', 'Somalia', 'MU Diga gaw', '5.69935, 48.4664 Telesom', '1', 1, 1, NULL, NULL, 'user', 1),
(1198, '0', 0, 1, '2023-09-08 17:12:03', '2023-09-08', 1, 1, '154.115.222.230', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/116.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 Telesom', 'Old', 1, 0, 'Baashe', 'Baashe', 'u', 1),
(1199, '5', 0, 1, '2023-09-08 09:12:33', '2023-09-08', 1, 1, '154.115.222.230', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/116.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 Telesom', 'Old', 2, 1, NULL, NULL, 'u', 1),
(1200, '5', 724, 1, '2023-09-08 17:13:11', '2023-09-08', 1, 1, '154.115.222.230', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/116.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 Telesom', '1', 1, 1, NULL, NULL, 'user', 1),
(1201, '5', 720, 1, '2023-09-08 17:16:50', '2023-09-08', 1, 1, '154.115.222.230', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/116.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 Telesom', '1', 1, 1, NULL, NULL, 'user', 1),
(1202, '5', 724, 1, '2023-09-08 17:17:22', '2023-09-08', 1, 1, '154.115.222.230', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/116.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 Telesom', '1', 1, 1, NULL, NULL, 'user', 1),
(1203, '5', 0, 1, '2023-09-12 01:52:35', '2023-09-12', 1, 1, '154.115.222.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/116.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 Telesom', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1204, '5', 724, 1, '2023-09-12 09:53:05', '2023-09-12', 1, 1, '154.115.222.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/116.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 Telesom', '1', 1, 1, NULL, NULL, 'user', 1),
(1205, '5', 724, 1, '2023-09-12 10:00:17', '2023-09-12', 1, 1, '154.115.222.215', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/116.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 Telesom', '1', 1, 1, NULL, NULL, 'user', 1),
(1206, '5', 0, 1, '2023-10-29 04:07:52', '2023-10-29', 1, 1, '197.231.203.102', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Berbera', '10.4396, 45.0143 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1207, '5', 0, 1, '2023-10-29 04:07:52', '2023-10-29', 1, 1, '197.231.203.102', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Berbera', '10.4396, 45.0143 SOMTEL INTERNATIONAL Ltd', 'Old', 2, 1, NULL, NULL, 'u', 1),
(1208, '5', 724, 1, '2023-10-29 12:08:08', '2023-10-29', 1, 1, '197.231.203.102', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'WO Berbera', '10.4396, 45.0143 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1209, '5', 0, 1, '2023-11-18 00:44:14', '2023-11-18', 1, 1, '197.231.201.227', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/119.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', 'Old', 1, 1, NULL, NULL, 'u', 1),
(1210, '5', 724, 1, '2023-11-18 09:44:31', '2023-11-18', 1, 1, '197.231.201.227', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/119.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '1', 1, 1, NULL, NULL, 'user', 1),
(1211, '5', 0, 1, '2023-11-28 04:01:31', '2023-11-28', 1, 1, '154.115.221.139', 'Computer', 'Mozilla/5.0 (X11; Linux x86_64', ' Chrome/119.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 Telesom', 'Old', 1, 1, NULL, NULL, 'u', 1);

-- --------------------------------------------------------

--
-- Table structure for table `ktc_user_permission`
--

CREATE TABLE `ktc_user_permission` (
  `id` int(11) NOT NULL,
  `link_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL COMMENT 'got per user',
  `granted_user_id` int(11) NOT NULL COMMENT 'user granted permission',
  `action` varchar(110) NOT NULL DEFAULT 'link',
  `company_id` int(11) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ktc_user_permission`
--

INSERT INTO `ktc_user_permission` (`id`, `link_id`, `user_id`, `granted_user_id`, `action`, `company_id`, `date`) VALUES
(11910, 35, 2, 2, 'link', 1, '2021-04-10 05:47:21'),
(11911, 36, 2, 2, 'link', 1, '2021-04-10 05:47:21'),
(11912, 37, 2, 2, 'link', 1, '2021-04-10 05:47:21'),
(11913, 41, 2, 2, 'link', 1, '2021-04-10 05:47:21'),
(11914, 52, 2, 2, 'link', 1, '2021-04-10 05:47:21'),
(11915, 53, 2, 2, 'link', 1, '2021-04-10 05:47:21'),
(11916, 54, 2, 2, 'link', 1, '2021-04-10 05:47:21'),
(11918, 56, 2, 2, 'link', 1, '2021-04-10 05:47:21'),
(11919, 57, 2, 2, 'link', 1, '2021-04-10 05:47:21'),
(11920, 59, 2, 2, 'link', 1, '2021-04-10 05:47:21'),
(11921, 61, 2, 2, 'link', 1, '2021-04-10 05:47:21'),
(11922, 74, 2, 2, 'link', 1, '2021-04-10 05:47:21'),
(11923, 93, 2, 2, 'link', 1, '2021-04-10 05:47:21'),
(11925, 352, 2, 2, 'link', 1, '2021-04-10 05:47:21'),
(11926, 353, 2, 2, 'link', 1, '2021-04-10 05:47:21'),
(11927, 369, 2, 2, 'link', 1, '2021-04-10 05:47:21'),
(11928, 390, 2, 2, 'link', 1, '2021-04-10 05:47:21'),
(12339, 270, 2, 1, 'link', 1, '2021-07-31 21:31:50'),
(12340, 459, 2, 1, 'link', 1, '2021-07-31 21:31:51'),
(12341, 460, 2, 1, 'link', 1, '2021-07-31 21:31:51'),
(12342, 21, 2, 1, 'link', 1, '2021-07-31 21:31:55'),
(12343, 22, 2, 1, 'link', 1, '2021-07-31 21:31:56'),
(12344, 423, 2, 1, 'link', 1, '2021-07-31 21:31:57'),
(12345, 16, 2, 1, 'link', 1, '2021-07-31 21:31:58'),
(12346, 18, 2, 1, 'link', 1, '2021-07-31 21:31:59'),
(12347, 32, 2, 1, 'link', 1, '2021-07-31 21:32:00'),
(12348, 33, 2, 1, 'link', 1, '2021-07-31 21:32:01'),
(12370, 8, 2, 1, 'edit', 1, '2021-07-31 21:32:54'),
(12371, 9, 2, 1, 'edit', 1, '2021-07-31 21:32:54'),
(12372, 10, 2, 1, 'edit', 1, '2021-07-31 21:32:55'),
(12375, 601, 2, 1, 'edit', 1, '2021-07-31 21:33:05'),
(12376, 604, 2, 1, 'edit', 1, '2021-07-31 21:33:07'),
(12377, 606, 2, 1, 'edit', 1, '2021-07-31 21:33:08'),
(12378, 649, 2, 1, 'edit', 1, '2021-07-31 21:33:10'),
(12379, 658, 2, 1, 'edit', 1, '2021-07-31 21:33:10'),
(12380, 717, 2, 1, 'edit', 1, '2021-07-31 21:33:11'),
(12470, 1, 2, 2, 'link', 1, '2021-10-18 08:20:31'),
(12585, 487, 2, 2, 'link', 1, '2021-12-15 04:59:56'),
(12592, 486, 2, 2, 'link', 1, '2021-12-15 04:59:57'),
(12888, 485, 2, 2, 'link', 1, '2021-12-15 11:49:13'),
(13108, 11, 2, 2, 'delete', 1, '2021-12-15 13:00:41'),
(13110, 13, 2, 2, 'delete', 1, '2021-12-15 13:00:42'),
(13118, 659, 2, 2, 'delete', 1, '2021-12-15 13:00:50'),
(13131, 718, 2, 2, 'delete', 1, '2021-12-15 13:00:53'),
(13134, 847, 2, 2, 'delete', 1, '2021-12-15 13:00:53'),
(13135, 603, 2, 2, 'delete', 1, '2021-12-15 13:00:53'),
(13137, 14, 2, 2, 'link', 1, '2021-12-15 13:01:22'),
(13380, 14, 2, 2, 'edit', 1, '2022-02-13 13:47:23'),
(13381, 12, 2, 2, 'delete', 1, '2022-02-13 13:47:33'),
(13382, 15, 2, 2, 'delete', 1, '2022-02-13 13:47:34'),
(13383, 602, 2, 2, 'delete', 1, '2022-02-13 13:47:35'),
(13386, 612, 2, 2, 'link', 1, '2022-02-13 14:59:10'),
(13936, 605, 2, 2, 'delete', 1, '2022-03-22 09:27:20'),
(13939, 8, 2, 2, 'faculty', 1, '2022-03-22 09:31:04'),
(13942, 7, 2, 2, 'faculty', 1, '2022-03-22 09:31:04'),
(13945, 17, 2, 2, 'faculty', 1, '2022-03-22 09:31:04'),
(13948, 6, 2, 2, 'faculty', 1, '2022-03-22 09:31:04'),
(13951, 5, 2, 2, 'faculty', 1, '2022-03-22 09:31:04'),
(13954, 3, 2, 2, 'faculty', 1, '2022-03-22 09:31:05'),
(13957, 9, 2, 2, 'faculty', 1, '2022-03-22 09:31:05'),
(13960, 12, 2, 2, 'faculty', 1, '2022-03-22 09:31:05'),
(13963, 10, 2, 2, 'faculty', 1, '2022-03-22 09:31:05'),
(13966, 11, 2, 2, 'faculty', 1, '2022-03-22 09:31:05'),
(13969, 18, 2, 2, 'faculty', 1, '2022-03-22 09:31:05'),
(13996, 622, 2, 2, 'link', 1, '2022-03-23 10:47:42'),
(14926, 1, 2, 2, 'branch', 1, '2022-03-27 07:53:01'),
(14929, 2, 2, 2, 'branch', 1, '2022-03-27 07:53:01'),
(14932, 3, 2, 2, 'branch', 1, '2022-03-27 07:53:01'),
(14935, 4, 2, 2, 'branch', 1, '2022-03-27 07:53:02'),
(14938, 6, 2, 2, 'branch', 1, '2022-03-27 07:53:02'),
(14941, 7, 2, 2, 'branch', 1, '2022-03-27 07:53:02'),
(14947, 8, 2, 2, 'branch', 1, '2022-03-27 07:53:06'),
(15427, 641, 2, 2, 'link', 1, '2022-07-11 16:23:06'),
(15529, 649, 2, 2, 'link', 1, '2022-08-19 23:01:43'),
(15535, 651, 2, 2, 'link', 1, '2022-09-11 17:25:13'),
(16950, 2, 2, 2, 'user', 1, '2022-09-15 15:03:46'),
(18913, 669, 2, 2, 'link', 1, '2022-09-28 19:11:24'),
(19679, 354, 2, 2, 'user', 1, '2022-11-17 18:17:01'),
(19680, 1, 3, 2, 'branch', 1, '2022-12-22 09:06:07'),
(19681, 8, 3, 2, 'branch', 1, '2022-12-22 09:06:07'),
(19682, 6, 3, 2, 'branch', 1, '2022-12-22 09:06:07'),
(19683, 3, 3, 2, 'branch', 1, '2022-12-22 09:06:07'),
(19684, 2, 3, 2, 'branch', 1, '2022-12-22 09:06:07'),
(19685, 4, 3, 2, 'branch', 1, '2022-12-22 09:06:07'),
(19686, 7, 3, 2, 'branch', 1, '2022-12-22 09:06:07'),
(19709, 658, 3, 2, 'edit', 1, '2022-12-22 09:06:07'),
(19712, 10, 3, 2, 'edit', 1, '2022-12-22 09:06:07'),
(19715, 14, 3, 2, 'edit', 1, '2022-12-22 09:06:07'),
(19716, 717, 3, 2, 'edit', 1, '2022-12-22 09:06:07'),
(19721, 8, 3, 2, 'edit', 1, '2022-12-22 09:06:07'),
(19728, 649, 3, 2, 'edit', 1, '2022-12-22 09:06:07'),
(19736, 606, 3, 2, 'edit', 1, '2022-12-22 09:06:07'),
(19737, 9, 3, 2, 'edit', 1, '2022-12-22 09:06:07'),
(19738, 601, 3, 2, 'edit', 1, '2022-12-22 09:06:07'),
(19739, 604, 3, 2, 'edit', 1, '2022-12-22 09:06:07'),
(20092, 55, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20093, 59, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20094, 459, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20096, 37, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20097, 36, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20098, 270, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20099, 74, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20100, 14, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20101, 460, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20102, 641, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20103, 7, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20104, 649, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20105, 21, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20106, 423, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20107, 54, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20108, 22, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20109, 369, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20110, 353, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20111, 352, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20112, 390, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20113, 52, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20114, 93, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20115, 41, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20116, 485, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20117, 53, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20118, 486, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20119, 487, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20120, 35, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20121, 33, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20122, 61, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20310, 354, 3, 2, 'user', 1, '2022-12-22 09:06:07'),
(20471, 57, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20472, 622, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20473, 16, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20474, 56, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20475, 32, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20476, 612, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20477, 18, 3, 2, 'link', 1, '2022-12-22 09:06:07'),
(20499, 8, 3, 2, 'faculty', 1, '2022-12-22 09:06:07'),
(20500, 18, 3, 2, 'faculty', 1, '2022-12-22 09:06:07'),
(20501, 17, 3, 2, 'faculty', 1, '2022-12-22 09:06:07'),
(20502, 7, 3, 2, 'faculty', 1, '2022-12-22 09:06:07'),
(20503, 6, 3, 2, 'faculty', 1, '2022-12-22 09:06:07'),
(20504, 5, 3, 2, 'faculty', 1, '2022-12-22 09:06:07'),
(20505, 3, 3, 2, 'faculty', 1, '2022-12-22 09:06:07'),
(20506, 9, 3, 2, 'faculty', 1, '2022-12-22 09:06:07'),
(20507, 12, 3, 2, 'faculty', 1, '2022-12-22 09:06:07'),
(20508, 10, 3, 2, 'faculty', 1, '2022-12-22 09:06:07'),
(20509, 11, 3, 2, 'faculty', 1, '2022-12-22 09:06:07'),
(20666, 717, 2, 2, 'link', 1, '2022-11-26 05:38:44'),
(22273, 1092, 2, 2, 'cancel', 1, '2022-12-07 21:00:00'),
(22284, 1093, 2, 2, 'cancel', 1, '2022-12-07 21:00:00'),
(22756, 719, 3, 3, 'link', 1, '2022-12-22 17:25:10'),
(22757, 720, 3, 3, 'link', 1, '2022-12-22 17:26:14'),
(22758, 721, 3, 3, 'link', 1, '2022-12-22 17:29:31'),
(22759, 722, 3, 3, 'link', 1, '2022-12-22 17:30:33'),
(22760, 723, 3, 3, 'link', 1, '2022-12-22 17:31:19'),
(22761, 724, 3, 3, 'link', 1, '2022-12-22 18:20:50'),
(22762, 725, 3, 3, 'link', 1, '2022-12-22 18:21:47'),
(22763, 726, 3, 3, 'link', 1, '2022-12-22 18:26:31'),
(22764, 727, 3, 3, 'link', 1, '2022-12-22 18:28:45'),
(22765, 728, 3, 3, 'link', 1, '2022-12-22 18:29:29'),
(22766, 729, 3, 3, 'link', 1, '2022-12-22 18:32:22'),
(22767, 730, 3, 3, 'link', 1, '2022-12-22 18:33:20'),
(22768, 729, 2, 2, 'link', 1, '2022-12-23 18:25:47'),
(22769, 724, 2, 2, 'link', 1, '2022-12-23 18:25:47'),
(22770, 725, 2, 2, 'link', 1, '2022-12-23 18:25:47'),
(22771, 726, 2, 2, 'link', 1, '2022-12-23 18:25:47'),
(22772, 728, 2, 2, 'link', 1, '2022-12-23 18:25:47'),
(22773, 727, 2, 2, 'link', 1, '2022-12-23 18:25:47'),
(22774, 730, 2, 2, 'link', 1, '2022-12-23 18:25:47'),
(22775, 3, 2, 2, 'user', 1, '2022-12-23 18:25:51'),
(22776, 723, 2, 2, 'link', 1, '2022-12-23 18:25:56'),
(22777, 722, 2, 2, 'link', 1, '2022-12-23 18:25:56'),
(22778, 721, 2, 2, 'link', 1, '2022-12-23 18:25:56'),
(22779, 720, 2, 2, 'link', 1, '2022-12-23 18:25:56'),
(22780, 719, 2, 2, 'link', 1, '2022-12-23 18:25:56'),
(22781, 1126, 2, 2, 'edit', 1, '2022-12-23 06:00:00'),
(22782, 1127, 2, 2, 'delete', 1, '2022-12-23 06:00:00'),
(22783, 1128, 2, 2, 'edit', 1, '2022-12-23 06:00:00'),
(22784, 1129, 2, 2, 'delete', 1, '2022-12-23 06:00:00'),
(22785, 1130, 2, 2, 'edit', 1, '2022-12-24 06:00:00'),
(22786, 1131, 2, 2, 'delete', 1, '2022-12-24 06:00:00'),
(22787, 1132, 2, 2, 'edit', 1, '2022-12-24 06:00:00'),
(22788, 1133, 2, 2, 'delete', 1, '2022-12-24 06:00:00'),
(22789, 1134, 2, 2, 'edit', 1, '2022-12-24 06:00:00'),
(22790, 1135, 2, 2, 'delete', 1, '2022-12-24 06:00:00'),
(22791, 1134, 3, 3, 'edit', 1, '2022-12-24 11:29:55'),
(22792, 1132, 3, 3, 'edit', 1, '2022-12-24 11:29:55'),
(22793, 1126, 3, 3, 'edit', 1, '2022-12-24 11:29:55'),
(22794, 1130, 3, 3, 'edit', 1, '2022-12-24 11:29:56'),
(22795, 1128, 3, 3, 'edit', 1, '2022-12-24 11:29:56'),
(22796, 1135, 3, 3, 'delete', 1, '2022-12-24 11:30:02'),
(22797, 1133, 3, 3, 'delete', 1, '2022-12-24 11:30:04'),
(22798, 1127, 3, 3, 'delete', 1, '2022-12-24 11:30:05'),
(22799, 1129, 3, 3, 'delete', 1, '2022-12-24 11:30:09'),
(22800, 1131, 3, 3, 'delete', 1, '2022-12-24 11:30:10'),
(22801, 4, 2, 2, 'user', 1, '2022-12-28 08:26:38'),
(22803, 5, 2, 2, 'chart', 1, '2022-12-29 09:35:19'),
(22804, 6, 2, 2, 'chart', 1, '2022-12-29 09:37:19'),
(22805, 731, 3, 3, 'link', 1, '2022-12-29 21:24:44'),
(22806, 5, 3, 3, 'chart', 1, '2022-12-29 21:33:29'),
(22807, 6, 3, 3, 'chart', 1, '2022-12-29 21:33:33'),
(22808, 7, 3, 3, 'chart', 1, '2022-12-29 21:35:10'),
(22809, 8, 3, 3, 'chart', 1, '2022-12-29 21:36:03'),
(22810, 9, 3, 3, 'chart', 1, '2022-12-29 21:41:25'),
(22811, 7, 2, 2, 'chart', 1, '2022-12-30 08:29:50'),
(22812, 8, 2, 2, 'chart', 1, '2022-12-30 08:29:52'),
(22813, 9, 2, 2, 'chart', 1, '2022-12-30 08:29:54'),
(22814, 731, 2, 2, 'link', 1, '2022-12-30 09:11:40'),
(22815, 1, 3, 3, 'link', 1, '2022-12-31 09:12:06'),
(22816, 732, 3, 3, 'link', 1, '2022-12-31 09:14:38'),
(22817, 733, 3, 3, 'link', 1, '2022-12-31 09:15:14'),
(22818, 733, 2, 2, 'link', 1, '2023-01-01 07:29:41'),
(22819, 732, 2, 2, 'link', 1, '2023-01-01 07:29:41'),
(22820, 734, 2, 2, 'link', 1, '2023-01-01 07:47:19'),
(22821, 735, 2, 2, 'link', 1, '2023-01-05 06:55:59'),
(22822, 55, 2, 2, 'link', 1, '2023-01-05 07:05:46'),
(22823, 736, 3, 3, 'link', 1, '2023-01-06 14:35:36'),
(22824, 737, 3, 3, 'link', 1, '2023-01-06 14:40:23'),
(22825, 5, 2, 2, 'user', 1, '2023-01-10 09:01:24'),
(22826, 15, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22827, 35, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22828, 157, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22829, 25, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22830, 50, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22831, 82, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22832, 53, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22833, 59, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22834, 118, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22835, 115, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22836, 12, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22837, 147, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22838, 10, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22839, 87, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22840, 54, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22841, 155, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22842, 63, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22843, 154, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22844, 153, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22845, 66, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22846, 161, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22847, 65, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22848, 119, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22849, 39, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22850, 73, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22851, 57, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22852, 134, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22853, 92, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22854, 20, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22855, 148, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22856, 31, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22857, 126, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22858, 100, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22859, 150, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22860, 34, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22861, 58, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22862, 36, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22863, 133, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22864, 61, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22865, 103, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22866, 16, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22867, 49, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22868, 86, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22869, 48, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22870, 1, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22871, 77, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22872, 62, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22873, 14, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22874, 84, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22875, 56, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22876, 13, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22877, 19, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22878, 121, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22879, 160, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22880, 89, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22881, 64, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22882, 125, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22883, 174, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22884, 74, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22885, 17, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22886, 120, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22887, 11, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22888, 139, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22889, 152, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22890, 106, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22891, 22, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22892, 46, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22893, 33, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22894, 117, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22895, 30, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22896, 21, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22897, 111, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22898, 101, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22899, 90, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22900, 80, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22901, 41, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22902, 112, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22903, 94, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22904, 47, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22905, 55, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22906, 52, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22907, 67, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22908, 93, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22909, 51, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22910, 132, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22911, 40, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22912, 42, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22913, 104, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22914, 85, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22915, 137, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22916, 79, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22917, 95, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22918, 138, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22919, 83, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22920, 176, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22921, 141, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22922, 32, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22923, 29, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22924, 110, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22925, 116, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22926, 124, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22927, 18, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22928, 98, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22929, 68, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22930, 151, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22931, 122, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22932, 37, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22933, 88, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22934, 26, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22935, 105, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22936, 27, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22937, 131, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22938, 23, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22939, 146, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22940, 44, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22941, 28, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22942, 78, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22943, 167, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22944, 72, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22945, 135, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22946, 45, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22947, 9, 2, 2, 'hospital', 1, '2023-01-10 09:15:06'),
(22948, 15, 3, 2, 'hospital', 1, '2023-01-10 09:15:11'),
(22949, 35, 3, 2, 'hospital', 1, '2023-01-10 09:15:11'),
(22950, 25, 3, 2, 'hospital', 1, '2023-01-10 09:15:11'),
(22951, 157, 3, 2, 'hospital', 1, '2023-01-10 09:15:11'),
(22952, 82, 3, 2, 'hospital', 1, '2023-01-10 09:15:11'),
(22953, 50, 3, 2, 'hospital', 1, '2023-01-10 09:15:11'),
(22954, 53, 3, 2, 'hospital', 1, '2023-01-10 09:15:11'),
(22955, 118, 3, 2, 'hospital', 1, '2023-01-10 09:15:11'),
(22956, 12, 3, 2, 'hospital', 1, '2023-01-10 09:15:11'),
(22957, 115, 3, 2, 'hospital', 1, '2023-01-10 09:15:11'),
(22958, 59, 3, 2, 'hospital', 1, '2023-01-10 09:15:11'),
(22959, 87, 3, 2, 'hospital', 1, '2023-01-10 09:15:11'),
(22960, 147, 3, 2, 'hospital', 1, '2023-01-10 09:15:11'),
(22961, 155, 3, 2, 'hospital', 1, '2023-01-10 09:15:11'),
(22962, 10, 3, 2, 'hospital', 1, '2023-01-10 09:15:11'),
(22963, 54, 3, 2, 'hospital', 1, '2023-01-10 09:15:11'),
(22964, 153, 3, 2, 'hospital', 1, '2023-01-10 09:15:11'),
(22965, 154, 3, 2, 'hospital', 1, '2023-01-10 09:15:11'),
(22966, 63, 3, 2, 'hospital', 1, '2023-01-10 09:15:11'),
(22967, 66, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22968, 161, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22969, 65, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22970, 73, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22971, 57, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22972, 119, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22973, 134, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22974, 39, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22975, 92, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22976, 148, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22977, 20, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22978, 126, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22979, 31, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22980, 150, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22981, 100, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22982, 34, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22983, 58, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22984, 36, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22985, 133, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22986, 103, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22987, 16, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22988, 61, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22989, 77, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22990, 86, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22991, 1, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22992, 49, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22993, 62, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22994, 48, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22995, 84, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22996, 14, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22997, 13, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22998, 121, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(22999, 19, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23000, 56, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23001, 89, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23002, 64, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23003, 74, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23004, 160, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23005, 120, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23006, 174, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23007, 125, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23008, 17, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23009, 11, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23010, 139, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23011, 152, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23012, 33, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23013, 101, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23014, 106, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23015, 30, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23016, 90, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23017, 80, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23018, 41, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23019, 27, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23020, 46, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23021, 117, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23022, 93, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23023, 94, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23024, 40, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23025, 55, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23026, 111, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23027, 47, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23028, 67, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23029, 132, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23030, 42, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23031, 104, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23032, 22, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23033, 21, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23034, 52, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23035, 51, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23036, 85, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23037, 137, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23038, 79, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23039, 95, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23040, 138, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23041, 83, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23042, 176, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23043, 141, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23044, 32, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23045, 29, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23046, 110, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23047, 124, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23048, 18, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23049, 68, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23050, 122, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23051, 37, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23052, 26, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23053, 116, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23054, 23, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23055, 105, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23056, 78, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23057, 131, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23058, 112, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23059, 44, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23060, 9, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23061, 151, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23062, 135, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23063, 72, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23064, 45, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23065, 88, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23066, 98, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23067, 167, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23068, 28, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23069, 146, 3, 2, 'hospital', 1, '2023-01-10 09:15:12'),
(23070, 161, 5, 2, 'hospital', 1, '2023-01-10 09:17:32'),
(23071, 160, 5, 2, 'hospital', 1, '2023-01-10 09:17:35'),
(23072, 174, 5, 2, 'hospital', 1, '2023-01-10 09:17:36'),
(23073, 176, 5, 2, 'hospital', 1, '2023-01-10 09:17:40'),
(23074, 167, 5, 2, 'hospital', 1, '2023-01-10 09:17:44'),
(23075, 737, 5, 2, 'link', 1, '2023-01-10 09:18:48'),
(23076, 736, 5, 2, 'link', 1, '2023-01-10 09:18:48'),
(23077, 724, 5, 2, 'link', 1, '2023-01-10 09:18:48'),
(23079, 726, 5, 2, 'link', 1, '2023-01-10 09:18:48'),
(23080, 735, 5, 2, 'link', 1, '2023-01-10 09:18:48'),
(23081, 729, 5, 2, 'link', 1, '2023-01-10 09:18:48'),
(23082, 727, 5, 2, 'link', 1, '2023-01-10 09:18:48'),
(23083, 728, 5, 2, 'link', 1, '2023-01-10 09:18:48'),
(23084, 732, 5, 2, 'link', 1, '2023-01-10 09:18:48'),
(23085, 725, 5, 2, 'link', 1, '2023-01-10 09:18:48'),
(23088, 720, 5, 2, 'link', 1, '2023-01-10 09:19:17'),
(23089, 734, 5, 2, 'link', 1, '2023-01-10 09:19:17'),
(23090, 723, 5, 2, 'link', 1, '2023-01-10 09:19:17'),
(23091, 722, 5, 2, 'link', 1, '2023-01-10 09:19:17'),
(23092, 719, 5, 2, 'link', 1, '2023-01-10 09:19:17'),
(23093, 721, 5, 2, 'link', 1, '2023-01-10 09:19:17'),
(23094, 1132, 5, 2, 'edit', 1, '2023-01-10 09:20:12'),
(23095, 1126, 5, 2, 'edit', 1, '2023-01-10 09:20:14'),
(23096, 1128, 5, 2, 'edit', 1, '2023-01-10 09:20:15'),
(23097, 1134, 5, 2, 'edit', 1, '2023-01-10 09:20:21'),
(23098, 1135, 5, 2, 'delete', 1, '2023-01-10 09:20:26'),
(23099, 1133, 5, 2, 'delete', 1, '2023-01-10 09:20:28'),
(23100, 1127, 5, 2, 'delete', 1, '2023-01-10 09:20:29'),
(23101, 1129, 5, 2, 'delete', 1, '2023-01-10 09:20:32'),
(23102, 177, 5, 5, 'hospital', 1, '2023-01-16 19:15:43'),
(23103, 178, 5, 5, 'hospital', 1, '2023-01-16 19:31:46'),
(23104, 738, 2, 2, 'link', 1, '2023-01-24 08:31:19'),
(23105, 179, 5, 5, 'hospital', 1, '2023-03-08 07:37:30'),
(23106, 180, 5, 5, 'hospital', 1, '2023-03-08 07:57:36'),
(23107, 181, 5, 5, 'hospital', 1, '2023-03-11 14:34:40'),
(23108, 182, 5, 5, 'hospital', 1, '2023-03-11 14:52:51'),
(23109, 183, 5, 5, 'hospital', 1, '2023-03-12 10:11:04'),
(23110, 184, 5, 5, 'hospital', 1, '2023-03-12 10:33:32'),
(23111, 185, 5, 5, 'hospital', 1, '2023-03-12 13:58:59'),
(23112, 186, 5, 5, 'hospital', 1, '2023-03-13 09:10:29'),
(23113, 187, 5, 5, 'hospital', 1, '2023-03-17 17:22:34'),
(23114, 188, 5, 5, 'hospital', 1, '2023-03-20 07:47:18'),
(23115, 189, 5, 5, 'hospital', 1, '2023-03-20 09:06:01'),
(23116, 190, 5, 5, 'hospital', 1, '2023-03-24 14:16:22'),
(23117, 191, 5, 5, 'hospital', 1, '2023-04-01 15:59:51'),
(23118, 192, 5, 5, 'hospital', 1, '2023-04-02 09:55:23'),
(23119, 193, 5, 5, 'hospital', 1, '2023-04-02 10:48:46'),
(23120, 194, 5, 5, 'hospital', 1, '2023-04-02 16:14:46'),
(23121, 195, 5, 5, 'hospital', 1, '2023-04-15 09:17:37'),
(23124, 196, 5, 5, 'hospital', 1, '2023-04-25 14:33:50');

-- --------------------------------------------------------

--
-- Table structure for table `ktc_user_schedule`
--

CREATE TABLE `ktc_user_schedule` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `time_in` time NOT NULL,
  `time_out` time NOT NULL,
  `days` varchar(250) NOT NULL,
  `user_id2` int(11) NOT NULL COMMENT 'granted user',
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `patient`
--

CREATE TABLE `patient` (
  `id` int(11) NOT NULL,
  `auto_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL COMMENT 'name',
  `gender` varchar(100) NOT NULL COMMENT 'gender~dropdown~gender_',
  `tell` int(11) NOT NULL COMMENT 'tell',
  `address` varchar(100) NOT NULL COMMENT 'address',
  `dob` date NOT NULL COMMENT 'dob',
  `mother` varchar(100) NOT NULL COMMENT 'mother',
  `description` varchar(100) NOT NULL COMMENT 'description',
  `user_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `patient`
--

INSERT INTO `patient` (`id`, `auto_id`, `company_id`, `name`, `gender`, `tell`, `address`, `dob`, `mother`, `description`, `user_id`, `date`, `action_date`, `modified_date`) VALUES
(1, 0, 1, 'jamac', 'male', 612222222, 'xamar', '0000-00-00', 'raxma', '12', 3, '2022-12-23', '2022-12-23 13:07:05', '2022-12-26 13:40:57'),
(2, 1, 1, 'Abdihamid Hussin Gedi', 'male', 615190777, 'Ankara Turkey', '0000-00-00', 'Nuurto Sh Mohamud', 'Test', 2, '2022-12-24', '2022-12-24 09:04:10', '2022-12-26 13:41:07'),
(3, 2, 1, 'Abdirahaman Sh Ibrahim', 'male', 612692022, 'Gubta', '2022-12-25', 'Nuurto SH Mohamud', '', 2, '2022-12-25', '2022-12-25 07:11:43', '2022-12-26 13:41:15'),
(4, 3, 1, 'Abdirahman Sh ibrahim', 'Male', 612692022, 'Dayniile Gubta', '2002-01-01', 'Nuurto Sh Mohamud', '', 4, '2022-12-28', '2022-12-28 09:00:39', '2022-12-28 09:00:39'),
(5, 4, 1, 'Abdihamid Hussein Gedi', 'Male', 615190777, 'Ankara', '1989-05-01', 'Nuurto Mohamud', 'Dheefshiidka-Somali Syrian Hospital', 4, '2022-12-28', '2022-12-28 16:07:30', '2022-12-28 16:07:30'),
(6, 5, 1, 'Mohamed Abdihamid Hussein', 'Male', 615190777, 'Ankar', '2017-02-28', 'Iqro Hassan mohamud', 'Dheefshiidka-Somali Syrian Hospital', 4, '2022-12-28', '2022-12-28 16:10:00', '2022-12-28 16:10:00'),
(7, 6, 1, 'Abdihamid Hussein Geddi', 'Male', 2147483647, 'Somali Mogadishu Holwdaag', '1989-05-01', 'Nuurto Maxamud', 'Dhakhtarka Ilkaha-Aadan-Ade Hospital', 4, '2022-12-30', '2022-12-30 07:18:38', '2022-12-30 07:18:38'),
(8, 7, 1, 'Abdihamid Hussein Geddi', 'Male', 2147483647, 'Somali Mogadishu Holwdaag', '1989-05-01', 'Nuurto Maxamud', 'Dhakhtarka Ilkaha-Aadan-Ade Hospital', 4, '2022-12-30', '2022-12-30 07:22:52', '2022-12-30 07:22:52'),
(9, 8, 1, 'Abdihamid Hussein Geddi', 'Male', 615190777, 'Somali Mogadishu Holwdaag', '1989-05-01', 'Nuurto Maxamud', 'Dhakhtarka Ilkaha-Aadan-Ade Hospital', 4, '2022-12-30', '2022-12-30 07:24:08', '2022-12-30 07:24:08'),
(10, 9, 1, 'Maxamed axmed baashe', 'Male', 7866366, 'Burco', '2023-05-14', 'Nuura xasan muuse', 'Dhakhtarka Cudurada Guud-Shiikh isixaaq pharmacy', 4, '2023-05-14', '2023-05-14 08:01:59', '2023-05-14 08:01:59'),
(11, 10, 1, 'Maxamed axmed baashe', 'Male', 78366366, 'Burco', '2023-05-14', 'Nuura axmed yusuf', 'Dhakhtarka Cudurada Guud-Shiikh isixaaq pharmacy', 4, '2023-05-14', '2023-05-14 09:04:04', '2023-05-14 09:04:04'),
(12, 11, 1, 'Maxamed axmed baashe', 'Male', 634432380, 'Burco', '2023-05-14', 'Xaawo cali yusuf', 'Dhakhtarka Caruurta-Hooyo Dhawar hospital', 4, '2023-05-14', '2023-05-14 09:15:02', '2023-05-14 09:15:02'),
(13, 12, 1, 'Siciid cabdi adan', 'Male', 634471123, 'Hargeisa', '2023-06-03', 'Surer sahal jaciir', 'Dhakhtarka Ilkaha-Shifo pharmacy', 4, '2023-06-03', '2023-06-03 18:41:53', '2023-06-03 18:41:53'),
(14, 13, 1, 'Maxamed axmed baashe', 'Male', 67866366, 'Burco', '2023-06-11', 'Nuura axmed yusuf', 'Dhakhtarka Maqaarka-Procare poly clinic center pharmacy', 4, '2023-06-11', '2023-06-11 18:31:51', '2023-06-11 18:31:51'),
(15, 14, 1, 'Maxamed axmed baashe', 'Male', 637866366, 'Hargeysa', '2023-06-12', 'Haweya nuur warsame', 'Dhakhtarka Caruurta-Amal grand hospital', 4, '2023-06-12', '2023-06-12 03:02:04', '2023-06-12 03:02:04'),
(16, 15, 1, 'Maxamed axmed bashe', 'Male', 636110636, 'Hargeysa', '2023-06-18', 'Haweya cali nuuur', 'Dhakhtarka Cunaha-Shifo pharmacy', 4, '2023-06-18', '2023-06-18 19:21:34', '2023-06-18 19:21:34'),
(17, 16, 1, 'Maxamed axmed baashe', 'Male', 63786636, 'Burco', '2023-07-07', 'Nuura xasan cali', 'Dhakhtarka Caruurta-Amal grand hospital', 4, '2023-07-08', '2023-07-08 20:48:29', '2023-07-08 20:48:29'),
(18, 17, 1, 'Nuura  cali axmed', 'Male', 634432380, 'Burco', '2023-10-24', 'Xawo yusuf cali', 'Dhakhtarka Caruurta-Amal grand hospital', 4, '2023-10-24', '2023-10-24 15:52:44', '2023-10-24 15:52:44'),
(19, 18, 1, 'Maxamed axmed', 'Male', 634432380, 'Burco', '2023-11-20', 'Nuura cali', 'Dhakhtarka Cunaha-Baxnaano speciality clinic', 4, '2023-11-24', '2023-11-24 16:42:42', '2023-11-24 16:42:42'),
(20, 19, 1, 'Hamse', 'Male', 634432380, 'Newnhargeisa', '2016-08-05', 'Nuuta', 'Dhakhtarka Caruurta-Amal grand hospital', 4, '2024-01-28', '2024-01-28 17:54:04', '2024-01-28 17:54:04');

-- --------------------------------------------------------

--
-- Table structure for table `sharer`
--

CREATE TABLE `sharer` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL DEFAULT '17',
  `tell` varchar(50) NOT NULL,
  `campaign_id` int(11) NOT NULL DEFAULT '0',
  `ip` varchar(30) NOT NULL,
  `device` varchar(230) NOT NULL,
  `os` varchar(230) NOT NULL,
  `browser` varchar(230) NOT NULL,
  `country` varchar(230) NOT NULL,
  `region` varchar(230) NOT NULL,
  `city` varchar(230) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `sharer`
--

INSERT INTO `sharer` (`id`, `company_id`, `tell`, `campaign_id`, `ip`, `device`, `os`, `browser`, `country`, `region`, `city`, `date`) VALUES
(1, 1, '615190777', 0, '78.172.177.223', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-M326B', ' Chrome/108.0.0.0 Mobile Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '2023-01-16 14:44:50'),
(2, 1, '615190777', 0, '78.172.177.223', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-M326B', ' Chrome/108.0.0.0 Mobile Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '2023-01-16 14:45:27'),
(3, 1, '615190777', 0, '78.172.177.223', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-M326B', ' Chrome/108.0.0.0 Mobile Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '2023-01-16 14:45:44'),
(4, 1, '615190777', 0, '78.172.177.223', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-M326B', ' Chrome/108.0.0.0 Mobile Safari/537.36', 'Turkey', '06 Ankara', '39.8959, 32.863 TurkTelecom', '2023-01-16 14:53:26'),
(5, 1, '615190777', 0, '78.172.177.223', 'Mobile', 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_6 like Mac OS X', ' CriOS/108.0.5359.112 Mobile/15E148 Safari/604.1', 'Turkey', '06 Ankara', '39.9401, 32.9097 TurkTelecom', '2023-01-18 00:03:32'),
(6, 1, '615190777', 1, '78.167.61.48', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-M326B', ' Chrome/109.0.0.0 Mobile Safari/537.36', 'Turkey', '06 Ankara', '39.9107, 32.8554 TurkTelecom', '2023-01-26 15:35:56'),
(7, 1, '615190777', 1, '102.38.49.144', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-A035F', ' Chrome/109.0.0.0 Mobile Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Somlink Wireless', '2023-01-26 15:45:58'),
(8, 1, '615190777', 1, '102.38.49.144', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Somlink Wireless', '2023-01-26 15:47:05'),
(9, 1, '615190777', 1, '102.38.49.144', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SAMSUNG SM-J610F', ' SamsungBrowser/19.0 Chrome/102.0.5005.125 Mobile Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Somlink Wireless', '2023-01-26 15:55:44'),
(10, 1, '615190777', 1, '192.145.168.1', 'Mobile', 'Mozilla/5.0 (Linux; Android 13; SM-M326B', ' Chrome/109.0.0.0 Mobile Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '2023-01-26 16:05:40'),
(11, 1, '615190777', 1, '102.38.49.144', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Somlink Wireless', '2023-01-26 17:17:28'),
(12, 1, '615190777', 1, '192.145.170.239', 'Mobile', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_5_1 like Mac OS X', ' Version/13.1.1 Mobile/15E148 Safari/604.1', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '2023-01-26 19:09:40'),
(13, 1, '615190777', 1, '102.38.49.144', 'Mobile', 'Mozilla/5.0 (Linux; Android 13; SM-A515F', ' Chrome/109.0.0.0 Mobile Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Somlink Wireless', '2023-01-28 00:11:43'),
(14, 1, '615190777', 1, '192.145.170.214', 'Mobile', 'Mozilla/5.0 (Linux; U; Android 12; en-gb; SM-A127F Build/SP1A.210812.016', ' Chrome/98.0.4758.101 Mobile Safari/537.36 PHX/11.9', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '2023-02-16 00:13:52');

-- --------------------------------------------------------

--
-- Table structure for table `ticket`
--

CREATE TABLE `ticket` (
  `id` int(11) NOT NULL,
  `auto_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `hospital_id` int(11) NOT NULL,
  `doctor_id` int(11) NOT NULL,
  `amount` double NOT NULL,
  `payment_tell` varchar(50) NOT NULL DEFAULT '',
  `image` varchar(100) NOT NULL COMMENT 'image~file',
  `hospital_ticket` int(11) NOT NULL DEFAULT '0' COMMENT 'hospital_ticket~number',
  `user_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modified_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ticket`
--

INSERT INTO `ticket` (`id`, `auto_id`, `company_id`, `patient_id`, `hospital_id`, `doctor_id`, `amount`, `payment_tell`, `image`, `hospital_ticket`, `user_id`, `date`, `action_date`, `modified_date`) VALUES
(4, 1, 1, 1, 3, 4, 15, '', '', 0, 2, '2022-12-24', '2022-12-24 09:19:44', '2022-12-24 09:19:44'),
(5, 2, 1, 1, 150, 4, 10, '', '', 0, 2, '2022-12-25', '2022-12-25 06:59:33', '2022-12-25 06:59:33'),
(6, 3, 1, 1, 150, 4, 10, '', '', 0, 2, '2022-12-25', '2022-12-25 07:01:38', '2022-12-25 07:01:38'),
(7, 4, 1, 1, 150, 4, 10, '', '', 0, 2, '2022-12-25', '2022-12-25 07:03:51', '2022-12-25 07:03:51'),
(8, 5, 1, 1, 150, 4, 10, '', '', 0, 2, '2022-12-25', '2022-12-25 07:04:48', '2022-12-25 07:04:48'),
(9, 6, 1, 2, 150, 4, 15, '', '', 35, 2, '2022-12-25', '2022-12-25 07:12:10', '2022-12-25 07:25:51'),
(10, 7, 1, 3, 27, 6, 10, '', '', 0, 4, '2022-12-28', '2022-12-28 09:00:39', '2022-12-28 09:00:39'),
(11, 8, 1, 3, 27, 4, 10, '', '', 0, 4, '2022-12-28', '2022-12-28 09:12:28', '2022-12-28 09:12:28'),
(12, 9, 1, 4, 27, 2, 10, '', '', 0, 4, '2022-12-28', '2022-12-28 16:07:30', '2022-12-28 16:07:30'),
(13, 10, 1, 5, 27, 2, 10, '', '', 0, 4, '2022-12-28', '2022-12-28 16:10:00', '2022-12-28 16:10:00'),
(14, 11, 1, 6, 15, 9, 13, '', '', 0, 4, '2022-12-30', '2022-12-30 07:18:38', '2022-12-30 07:18:38'),
(15, 12, 1, 7, 15, 9, 13, '', '', 0, 4, '2022-12-30', '2022-12-30 07:22:52', '2022-12-30 07:22:52'),
(16, 13, 1, 8, 15, 9, 13, '', 'uploads/bulshotechapps_ktceditsp_20221230024753.jpeg', 2, 4, '2022-12-30', '2022-12-30 07:24:08', '2022-12-30 08:54:00'),
(17, 14, 1, 8, 150, 20, 10, '', 'uploads/bulshotechapps_ktceditsp_20230101033947.jpeg', 2, 4, '2023-01-01', '2023-01-01 09:35:17', '2023-01-01 09:40:02'),
(18, 15, 1, 9, 181, 80, 26000, '634432380', '', 0, 4, '2023-05-14', '2023-05-14 08:01:59', '2023-05-14 08:01:59'),
(19, 16, 1, 9, 181, 80, 26000, '634432380', '', 0, 4, '2023-05-14', '2023-05-14 08:40:49', '2023-05-14 08:40:49'),
(20, 17, 1, 9, 188, 92, 51000, '634432380', '', 0, 4, '2023-05-14', '2023-05-14 08:42:56', '2023-05-14 08:42:56'),
(21, 18, 1, 10, 181, 80, 26000, '634432380', '', 0, 4, '2023-05-14', '2023-05-14 09:04:04', '2023-05-14 09:04:04'),
(22, 19, 1, 11, 188, 92, 51000, '634432380', '', 0, 4, '2023-05-14', '2023-05-14 09:15:02', '2023-05-14 09:15:02'),
(23, 20, 1, 11, 190, 98, 24000, '634432380', '', 0, 4, '2023-05-16', '2023-05-15 22:49:49', '2023-05-15 22:49:49'),
(24, 21, 1, 9, 190, 98, 24000, '634432380', '', 0, 4, '2023-05-27', '2023-05-27 02:04:31', '2023-05-27 02:04:31'),
(25, 22, 1, 12, 190, 99, 24000, '634471123', '', 0, 4, '2023-06-03', '2023-06-03 18:41:53', '2023-06-03 18:41:53'),
(26, 23, 1, 11, 193, 106, 95000, '634432380', '', 0, 4, '2023-06-04', '2023-06-04 06:58:39', '2023-06-04 06:58:39'),
(27, 24, 1, 11, 190, 98, 24000, '634432380', '', 0, 4, '2023-06-08', '2023-06-08 03:43:20', '2023-06-08 03:43:20'),
(28, 25, 1, 12, 190, 98, 24000, '634471123', '', 0, 4, '2023-06-08', '2023-06-08 04:25:46', '2023-06-08 04:25:46'),
(29, 26, 1, 11, 190, 99, 24000, '634432380', '', 0, 4, '2023-06-08', '2023-06-08 14:09:32', '2023-06-08 14:09:32'),
(30, 27, 1, 13, 182, 81, 79000, '634432380', '', 0, 4, '2023-06-11', '2023-06-11 18:31:51', '2023-06-11 18:31:51'),
(31, 28, 1, 14, 193, 106, 95000, '634432380', '', 0, 4, '2023-06-12', '2023-06-12 03:02:04', '2023-06-12 03:02:04'),
(32, 29, 1, 15, 190, 98, 24000, '634432380', '', 0, 4, '2023-06-18', '2023-06-18 19:21:34', '2023-06-18 19:21:34'),
(33, 30, 1, 16, 193, 106, 95000, '634432380', '', 0, 4, '2023-07-08', '2023-07-08 20:48:29', '2023-07-08 20:48:29'),
(34, 31, 1, 17, 193, 106, 95000, '634432380', '', 0, 4, '2023-10-24', '2023-10-24 15:52:44', '2023-10-24 15:52:44'),
(35, 32, 1, 18, 186, 88, 136000, '634432380', '', 0, 4, '2023-11-24', '2023-11-24 16:42:42', '2023-11-24 16:42:42'),
(36, 33, 1, 18, 193, 106, 95000, '634432380', '', 0, 4, '2023-11-28', '2023-11-28 10:42:21', '2023-11-28 10:42:21'),
(37, 34, 1, 11, 193, 106, 95000, '634432380', '', 0, 4, '2024-01-22', '2024-01-22 08:58:38', '2024-01-22 08:58:38'),
(38, 35, 1, 19, 193, 106, 95000, '634432380', '', 0, 4, '2024-01-28', '2024-01-28 17:54:04', '2024-01-28 17:54:04');

-- --------------------------------------------------------

--
-- Table structure for table `visitor`
--

CREATE TABLE `visitor` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL DEFAULT '17',
  `token` text NOT NULL,
  `ip` varchar(30) NOT NULL,
  `device` varchar(230) NOT NULL,
  `os` varchar(230) NOT NULL,
  `browser` varchar(230) NOT NULL,
  `country` varchar(230) NOT NULL,
  `region` varchar(230) NOT NULL,
  `city` varchar(230) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `visitor`
--

INSERT INTO `visitor` (`id`, `company_id`, `token`, `ip`, `device`, `os`, `browser`, `country`, `region`, `city`, `date`) VALUES
(1, 1, 'dgvBvhmJRO2pQJNAL-GAi3:APA91bHxGGWOvn82QTnfUMasRSZnBZ5bj2LKSBYZqTxyj_LeEmtPYpS-rJsX7TGCaXu1Hxm-iXGA_YjFdg0ab16OTmLUh2fZYdXTlX2YPFyFETR8yn6FXF95o4qDTyfN8ymvIjAuDIIF', '78.174.41.152', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-M326B Build/SP1A.210812.016; wv', ' Version/4.0 Chrome/108.0.5359.128 Mobile Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '2023-01-02 16:46:09'),
(2, 1, '', '78.174.41.152', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-M326B Build/SP1A.210812.016; wv', ' Version/4.0 Chrome/108.0.5359.128 Mobile Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '2023-01-02 16:54:26'),
(3, 1, 'empty', '104.133.10.103', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; Pixel 3 XL Build/QQ3A.200605.001; wv', ' Version/4.0 Chrome/108.0.5359.128 Mobile Safari/537.36', 'India', 'KA Bengaluru', '12.9634, 77.5855 Google LLC', '2023-01-02 17:20:03'),
(4, 1, 'ds72maceTPCVCDqUAPHmoK:APA91bFC7LPfFQ2f4bNX60meaT1mV7iwRGbxhldgJcYK7kv-3Kl4Z_wzrsUsC82Oao5eu7RpM01O3k2N4z5Ss5I4DS2K6TqRZWA49xCSImwR7xppUwVEOAMVXnP2hXeQkzzxBUioPzAf', '104.133.10.103', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; Pixel 3 XL Build/QQ3A.200605.001; wv', ' Version/4.0 Chrome/108.0.5359.128 Mobile Safari/537.36', 'India', 'KA Bengaluru', '12.9634, 77.5855 Google LLC', '2023-01-02 17:20:56'),
(5, 1, 'free', '74.125.212.150', 'Mobile', 'Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MTC20F; wv', ' Version/4.0 Chrome/53.0.2785.124 Mobile Safari/537.36', 'United States', 'CA Mountain View', '37.422, -122.084 Google LLC', '2023-01-04 17:05:43'),
(6, 1, 'fI3j2s8ETDaVzmRdPpCPMp:APA91bFV_zcetwxXTtVy0Hd081mpWsR05NMNmnX9FQVHYJ0S3At5SmnIlLUAdnoJjfujumC_qBm8S_W2H-kWSQBac7yFQrOdcVw2218xFH8XtPZk2btaHpy8QubCn5eT2Gc9gmniUVYM', '197.231.201.213', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G Build/QP1A.190711.020; wv', ' Version/4.0 Chrome/108.0.5359.79 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '2023-01-06 14:35:33'),
(7, 1, 'fW9-pvSLTU6lnvgYTlIDHg:APA91bE-fLaQoGRZ-7GamYOUUNUfODl7gXXnYHlnHhXBbH9qWlYNXcABgGixEmu_IOXw8mX2hQUhOLlIJlTnDfCOgnGhidyNcFHqwwX9WsX3iDpxWIivd3U67G5-cE3LLst0AA0IhkdQ', '78.174.41.152', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-M326B Build/SP1A.210812.016; wv', ' Version/4.0 Chrome/108.0.5359.128 Mobile Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '2023-01-06 16:02:43'),
(8, 1, 'cnPWQLadTOudCyiZMv-MJe:APA91bELX3Y3GzM77HBqfgyTutuWsPkIg8MBF_HEIft3uVFQkL29UnJifxEEeBW2fBKoGKx3Y1glTucbAGQRy37ohiCkWZo1_yQIl0mnb3t9ktoC-L4mM1pUHDkYA_MdREyDZ8_dvu_x', '78.174.41.152', 'Computer', 'Mozilla/5.0 (Linux; Android 12; SM-T220 Build/SP1A.210812.016; wv', ' Version/4.0 Chrome/108.0.5359.128 Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '2023-01-07 04:26:22'),
(9, 1, 'no-token', '78.174.41.152', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-M326B Build/SP1A.210812.016; wv', ' Version/4.0 Chrome/108.0.5359.128 Mobile Safari/537.36', 'Turkey', '14 Bolu', '40.6704, 31.7864 TurkTelecom', '2023-01-08 02:59:37'),
(10, 1, 'branchitem', '192.145.168.73', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/108.0.0.0 Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '2023-01-09 04:20:48'),
(11, 1, 'cN_gv3WFSOWRmFH59fK4UJ:APA91bFWYora4Shv2SiByVXGt6OZeM4F-lM4_E2UwRFG5flhOeBbmXQbA2adM4InNAUNjGX-KPWpCTcS3ktS0__03OLfP2LyawGOL0uNSH166B_Y7XOVdtF8CqQ_98kkxOVHQlfDvgMh', '197.231.203.103', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G Build/QP1A.190711.020; wv', ' Version/4.0 Chrome/108.0.5359.79 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '2023-01-09 21:44:25'),
(12, 1, 'dJmeOJXSQvewPwLwfvmNvP:APA91bHWwJIRiR0xSn1qpQbPnnkvyfFS8m7l_GWzbIYqKSGod1K-_MDsmyRLyjWiCxp66J99gFTjhUh9YZvEB0SxnzMm75fehCo9Tz_Cp4VCkcsUbg1rWLiChKXr8vYeX1SXRPVQomOz', '197.231.201.165', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G Build/QP1A.190711.020; wv', ' Version/4.0 Chrome/108.0.5359.79 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '2023-01-10 16:36:42'),
(13, 1, 'eeNnHlTdR5qpaW48sesduk:APA91bGoaICa3BMGRJQtXNmHdWtk7PNDU4uiw90Obp_-yD9IDfzTHPfFq6u7XX6yEMkbvdQ9us0LWgbByoyZysrAO2gfFdcJyslz_yujj--V0Gl5ePZdtcHgAF6bVlBtlxOzKnbo6TfL', '192.145.170.207', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; M2006C3MG Build/QP1A.190711.020; wv', ' Version/4.0 Chrome/103.0.5060.129 Mobile Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '2023-01-14 02:23:02'),
(14, 1, 'cQDOZSj6RPyft5VVi1x3N3:APA91bHD7pmOQmOVZ0Q8IbQ4o2qGHLmT8_v53vt0f0g3lnY696zlVGZNRqPQDezqv0Kw7lXe2bjE_E1TfpdLZ0I52pe8OPdffM87k0M9UtJ3waUN0UUVhJwjfBckdmrCT6DausCUGg-e', '197.231.201.225', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G Build/QP1A.190711.020; wv', ' Version/4.0 Chrome/108.0.5359.79 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '2023-01-14 03:30:45'),
(15, 1, 'f0ehSEpfQl2CynXRXcDmFd:APA91bFmzQw8z73hJDv7F6TV3w0oVTWELchN8qL3wvBADbGEJnt3sxSXeXJX5X1q0srvZEqDlTSKEwd3Ly60SKrZnyei8F8IZt_3iNtVFZVqshzoyXpNLi3XML_PFji1lmFaewSWajIA', '197.231.202.18', 'Mobile', 'Mozilla/5.0 (Linux; Android 9; SM-J810G Build/PPR1.180610.011; wv', ' Version/4.0 Chrome/108.0.5359.128 Mobile Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '2023-01-14 20:16:34'),
(16, 1, 'eefnCQRxR2ecHIy-7Zr9Ra:APA91bGS76sueAoOlRLpcWzTqTgj1X0gzm4fFLQqM0Zmb8aLjToju0k4mjITNG5I7GxZ7mhbfSm-8Ka68zOIcooY5XCisv4SNJyPsZWIjRLXEIK2LWABz8xYfg2G9rfe1k6NLUj3u2Zw', '197.220.84.101', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-M336BU Build/SP1A.210812.016; wv', ' Version/4.0 Chrome/109.0.5414.86 Mobile Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '2023-01-23 01:09:58'),
(17, 1, 'fJyeYECtTgWjAj1QsznnAF:APA91bGCSQMmZAu2WBBOUSihTL87bx_Bwc6wSOn8AJMP-Pi_oUlLoXlw_JDzYhZULjWLbKUaz9KwgChKcTJqkkEjkksw5FDR-Xk5btIW8Oyp_-U1oU_vzcX7asOMXA6YgdCPggXAw6eb', '102.141.197.38', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-A035F Build/SP1A.210812.016; wv', ' Version/4.0 Chrome/108.0.5359.128 Mobile Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Amtel LTD', '2023-01-28 06:23:18'),
(18, 1, 'testWA()', '88.251.27.235', 'Computer', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64', ' Chrome/109.0.0.0 Safari/537.36', 'Turkey', '06 Ankara', '39.9107, 32.8554 TurkTelecom', '2023-01-28 12:57:22'),
(19, 1, 'dkYWwcgXTouUqaRj4y7D3d:APA91bEXqzoYgNO3B6Fz69KwAnxj9PehJGhCmCyI_BkaT3JEZSCamF_eaTUSLmV2dfjyA6jsStZJQ_F27Du6pbx9cxNHwPFac21j4kSXvZ8YhQ437t7eh2g-w1sHrqu4E_tnZ7GetLiN', '197.231.201.175', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G Build/QP1A.190711.020; wv', ' Version/4.0 Chrome/108.0.5359.79 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '2023-01-28 16:02:28'),
(20, 1, 'cra8viqHSpKw4AgvWOMbuH:APA91bHGuJBnkeA9IN55uaQedpoEL37K-ddqwSZsBq_tqslgXEAX7KrPzMbnvY70K_ICUMM6bVFxenmFMW9OJ1JvfnZeT5M9cB03YiTZjyO2ED3jvre7r2FS7RzgyR_jfWrHZtz6eoGE', '197.231.201.205', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G Build/QP1A.190711.020; wv', ' Version/4.0 Chrome/108.0.5359.79 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '2023-02-01 14:58:01'),
(21, 1, 'eXWgiI8tSeC_gBMvjtj7DO:APA91bE9JW29lQg9cucN1gHgbBNgBNvKNQFGpaT0f8OON2JCt7-lHFN6OLoC4xe_8PPsTETFpOBr2VMtMfXaOqigZIKK9z8va8FXa43F0dBISJ3YM6gaX2i8Al0ObaTHM2Ky3e7BMPI5', '197.220.84.52', 'Mobile', 'Mozilla/5.0 (Linux; Android 13; SM-M326B Build/TP1A.220624.014; wv', ' Version/4.0 Chrome/109.0.5414.117 Mobile Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '2023-02-07 22:23:33'),
(22, 1, 'dxHN-QhoSQGAuRmev0-cxs:APA91bGMp7XMAA_6RvUsFRVpAqVNEY_WM_O5uY6PjYwxxz-9famTQAu7s_RoUz2wnmd2Z1NV5RUtGBacUcAlj7HMGubOhSVgxkGNhB9No-ZwJdqaaoIUBj153f0fV3fud59sW9EZFgEL', '70.32.128.251', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; Pixel 6 Build/SQ1D.220205.004; wv', ' Version/4.0 Chrome/91.0.4472.114 Mobile Safari/537.36', 'United States', 'CA Palo Alto', '37.4152, -122.1224 Google LLC', '2023-02-13 10:37:35'),
(23, 1, 'fQvtJrwSQCu2i-DTBr1sa2:APA91bH2mPCaHwjdpQyJmt17PHTkz9fdeef0-s6jyAnd23-plRqWlk_2fm7_02gTDz1QoV8PWacFVFHr-SJ9b15x42QWxh_Uc9xRful9elM084Gn6Tb88falxWWticeG8uAQzttnlJcj', '192.145.175.226', 'Mobile', 'Mozilla/5.0 (Linux; Android 11; SM-A305F Build/RP1A.200720.012; wv', ' Version/4.0 Chrome/107.0.5304.141 Mobile Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '2023-02-13 17:04:04'),
(24, 1, 'ciLc5upsQmmxcOMniL3ZV0:APA91bEW-QLZEeILwH0fIZOQA0YeUUkmOJc06R7o-TsWVrLdZtMLf34w917qBTyWGw8bZoid1zCWJCJQnVDQ7XDz9PcLtWTVLIIQRNMXT-mwstCzqZh9xLzZxm-Oxbgfk5a7x-lTKGmE', '41.79.198.18', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G Build/QP1A.190711.020; wv', ' Version/4.0 Chrome/109.0.5414.117 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', '2023-02-28 19:26:37'),
(25, 1, 'eWX3T0OYQzm2ryGebtSjma:APA91bFqFSzmxbCIBgN0G4OXDrd53q-CtOiV07VLJdGsCbwdyxsU73vTlAB-SMf0qNq_0vo0uUEaZa8cCe1-Hu5hULrKqhO_E2mmQkqWicgnJQCY25U3936w4HjiYw5GhiloBoFaHvlp', '78.167.121.111', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-M326B Build/SP1A.210812.016; wv', ' Version/4.0 Chrome/110.0.5481.154 Mobile Safari/537.36', 'Turkey', '06 Ankara', '39.9401, 32.9097 TurkTelecom', '2023-03-05 12:07:29'),
(26, 1, 'e17Vdo6FQ3qWaSetGTLiSd:APA91bEe5mwrywJoVlpS0pImRJUJCx69iJCnQSpjOYYrJS5a5-d_19yVykd31Nqj5FWEy9MicqVkwo_o2t5WCkQi5ZRskcQNQvLpvYon_oZ2BgpRPoVG7CH5bci5MsUb6lEjA0tN3n3_', '108.177.7.85', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; Pixel 6 Build/SQ1D.220205.004; wv', ' Version/4.0 Chrome/91.0.4472.114 Mobile Safari/537.36', 'United States', 'VA Reston', '38.9687, -77.3411 Google LLC', '2023-03-05 12:31:09'),
(27, 1, 'dwPfzIZMQeuvcCpweSh56G:APA91bHfadrsmOYDKjw3qE0th9mKE6iVRKUqCg7JTF1sYTZereSYU7wuWO2X2AaAfic0STTFn_JIEnwzMjef4j8g7bfl7SVg5LbDSbrohUzp7u4lJFnQbR4vQegcLx2600I4YWjbb9_B', '108.177.7.90', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; Pixel 6 Build/SQ1D.220205.004; wv', ' Version/4.0 Chrome/91.0.4472.114 Mobile Safari/537.36', 'United States', 'VA Reston', '38.9687, -77.3411 Google LLC', '2023-03-05 12:33:23'),
(28, 1, 'fUj6Qzd1RzmgOt2iAvZDAC:APA91bE7oZ08el5XzOmfJ3QUi47jWOORhLF_m89c67vspgRy_GWMZpeV1NUG8KWsCE0M56QGwZYjl0zhaIooUykzx4J6c1ZKkwedFNg6WPzXEIBSCZnbUXjXIIp-8ZhtI0mlVJohAsoz', '154.115.221.157', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-A217F Build/QP1A.190711.020; wv', ' Version/4.0 Chrome/106.0.5249.126 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Telesom', '2023-03-08 00:15:12'),
(29, 1, 'd7LuP4J8RK264NimlERGYR:APA91bGxVjUUU_FPpxlOaSTjb6RGtFeFl91yG9FUlJe6drHBG7qiZCeBFKpr2Pl7wKZROzPzGmXOnWqbN09_2wYdTKuCvGgcsSvCdO3yrE273yfRi2t8j5GGLUqZs2cxY0Jrhp8A42kB', '197.231.201.185', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G Build/QP1A.190711.020; wv', ' Version/4.0 Chrome/109.0.5414.117 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '2023-03-08 01:24:59'),
(30, 1, 'd947vNwARzyPhgzUaDiYMG:APA91bEw6_Gkrf_0ZBIT8vDE2WEkuYjEmvBNsKpIKJSQ8pWlNsFO36SLIBcy2LwmDmrb5agT1ra40yF7d3MXOjEul5VsLvQOAmtqiLXh5-QhZiyAMBNWOZVSb_o-15nO3YQywk4JByfb', '154.115.222.226', 'Mobile', 'Mozilla/5.0 (Linux; Android 13; SM-A135F Build/TP1A.220624.014; wv', ' Version/4.0 Chrome/106.0.5249.126 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56239, 44.077 Telesom', '2023-03-08 17:07:47'),
(31, 1, 'cI4k2k14QzayLlLELpBPt5:APA91bEQv6gUWiGa48OJBngWpvtOIJ49xiWC40Raws-MF_pD6VNF1osh6jsjoapm11kz8XUjRSxdFUyDnIPjsxSWb35IznncZV0PJSkKdhDBakSQx5Q1PJmDbKA49v6cx9pXyG9ovH4f', '154.115.222.184', 'Mobile', 'Mozilla/5.0 (Linux; Android 9; SM-J415F Build/PPR1.180610.011; wv', ' Version/4.0 Chrome/74.0.3729.136 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 Telesom', '2023-03-08 18:26:04'),
(32, 1, 'cMLkH9KMTw-domr2paUUvg:APA91bHMCJJySY4Skz6aksqDAms_1RsHBa4ZnDNAglriuiFyZISwUPlRAdnhypljMTNB5TrGCLVtZtu6-C4XgRrwjmTarJTo5cslGYi6R5FBFCQYl_pbuc8-mDDCMHLbxiFY3SX0Nund', '197.231.203.109', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-A525F Build/SP1A.210812.016; wv', ' Version/4.0 Chrome/110.0.5481.153 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '2023-03-12 16:08:33'),
(33, 1, 'cGcpAHoqRsWBhHBNWQnIzx:APA91bG1YhsMvKo_4kNMdnuTmQXWUXbiw9W4Fbw1GNZ3LYj14wnMRXO9YCtMzCmC32hWffHoV7d5CbulQ3bSHcy3p97MiWcMKYYMzSRFBodrtJTmgx_AD1iy4M1-EdVUMWQM4TeO_9Cw', '197.231.201.217', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G Build/QP1A.190711.020; wv', ' Version/4.0 Chrome/109.0.5414.117 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '2023-03-17 03:10:37'),
(34, 1, 'dbaFXIVBSmWq3JR1CrthQ8:APA91bGE10z9Ql5sHOH-grNVkQmCOtNLSgHoj1_9Bb0V6k7xBVY-4F1uocdryBqZQ_rac3JoL3l6w9lEw_XE-Q_fKZpiOq28FvtT-PsJ21G5lK2V4cQgp_FPjUVS1m-KmMiUGeQ2mmuE', '197.231.201.200', 'Mobile', 'Mozilla/5.0 (Linux; Android 8.0.0; SM-J810G Build/R16NW; wv', ' Version/4.0 Chrome/104.0.5112.97 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '2023-03-18 01:27:53'),
(35, 1, 'f5vN89tGRuqPF_bXsrRMPz:APA91bFjV_tEwd7N2BBka6hHeq0cg3KvH8zX8F7C_KpRz5oLcsZhyildRzkJfy9SIZK6qirINZY77fjG9AeC_5LrKPmpoRQbVsrD9oSBb3CHexXLmYPml4QX3bfYlA2ihWuWvljTflBM', '197.231.203.103', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G Build/QP1A.190711.020; wv', ' Version/4.0 Chrome/109.0.5414.117 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '2023-03-18 01:59:57'),
(36, 1, 'cKASckFLRz6TqwaYeYdYhh:APA91bES2j0XV0WZxDrzx2ytic0MkHUaSHIt7HL5sxfRRjGZECvBsmH0DYBnkwjxsDX2KZmT-xFsWL4iw4yPIZVywl94LJzyANGv-N--yaHz5BuoC3UEHgfCEjwpR_-htI7hps4EM6_J', '41.79.197.2', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-A037F Build/SP1A.210812.016; wv', ' Version/4.0 Chrome/110.0.5481.153 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SASomcable Safaricom', '2023-03-20 15:52:01'),
(37, 1, 'dBNtpUXCRqaJxXOm5qbNs_:APA91bEyxYk2PWoQby5f7Bx3cYmst4YxkIDLyPrQ_MfFHafNxQUR0eiuRaNOnOCaY3s-UI8iR-hSfDtuqN9cVCbTUOJOP51auxjRvenoKKm-yPJ3Qgq4y-Brvu0sPbpSo1GkfD3a2c1K', '197.231.201.205', 'Mobile', 'Mozilla/5.0 (Linux; Android 11; SM-A127F Build/RP1A.200720.012; wv', ' Version/4.0 Chrome/87.0.4280.141 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '2023-03-22 12:59:55'),
(38, 1, 'eJJbBChBTx2QUm47zj4otL:APA91bEyxjcB4ypw-93CW_SI-RHoiJPCxEFURKe-vh2Or6fpBj5gxlKGRUyWn7sGDD-9CnNoxOHoOcwhi6q7Ilu0reY755pvWLTkv4TrlGu2MzGBW9ohOD2d-1fs-jJaXB0e8cXAaced', '197.231.201.180', 'Mobile', 'Mozilla/5.0 (Linux; Android 11; SM-M307F Build/RP1A.200720.012; wv', ' Version/4.0 Chrome/108.0.5359.128 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '2023-03-28 16:56:40'),
(39, 1, 'cLJRFeRzRuWkNFU-Dr2LpS:APA91bFaFLui2SFI6dAmoEGV71Ef6tBNFlWJ-Q6F0ue3sAeo1rhIXtfbQ3hnUybFryp1SPtH2hJS6iCaNa7MNeA30beJV42KNQoDd7VPStL-Xtg8F-5mkvWZ_KUgTdjxUC1ZReTphns-', '197.231.201.212', 'Mobile', 'Mozilla/5.0 (Linux; Android 11; SM-M307F Build/RP1A.200720.012; wv', ' Version/4.0 Chrome/108.0.5359.128 Mobile Safari/537.36', 'Somalia', 'TO Ceek', '8.99907, 45.3582 SOMTEL INTERNATIONAL Ltd', '2023-03-30 04:48:21'),
(40, 1, 'cQ4kiOzVSlOhO5otWoC2G0:APA91bER2N0KQz-Vd7vS6lX_jsYvZMLzP_7dKiwK26VNcLwUto_QnpQl16dztzmoAi0tIW5h5YhT-ACvGJIMZYXsWNjNyS1ym22V4DjiTmWp6uhe3ZluQiFXm2gkVwtH-5V8GW3unKKy', '192.145.175.198', 'Mobile', 'Mozilla/5.0 (Linux; Android 9; SM-J400F Build/PPR1.180610.011; wv', ' Version/4.0 Chrome/72.0.3626.121 Mobile Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '2023-04-04 14:24:43'),
(41, 1, 'fDfnvNK-ScaUsqm_ADKAvM:APA91bEvDlsc0vb5CjmUtIChb_-4Pe8u0sEVCl8xsH_jLnGkrwVUxH92AfWtFwI0nbUzZohD0BguegYeQCTugTPyyC3BfGPLsjUZqel8us1Fmbqe_SfMnFkGHbfUnP0a9OtleylE0o8N', '197.231.202.193', 'Mobile', 'Mozilla/5.0 (Linux; Android 13; SM-A236U1 Build/TP1A.220624.014; wv', ' Version/4.0 Chrome/111.0.5563.116 Mobile Safari/537.36', 'Somalia', 'TO Burao', '9.5277, 45.5329 SOMTEL INTERNATIONAL Ltd', '2023-04-07 00:08:45'),
(42, 1, 'deR8iL6URHKsOPa6N2N_Cf:APA91bGis4nI8c9qMSUxKMbt6QfnfUyurdGmZIGxty80qa2kI8tM8BGFiIFapTtRsWj_B2GX7Q_DWHHMFgxxRVpEJqwcsDdwlfML1Nv0hIMRl0lEVIrzyLhvkNpzMk0NwVrNkua6kBxM', '37.56.17.49', 'Mobile', 'Mozilla/5.0 (Linux; Android 11; SM-A307FN Build/RP1A.200720.012; wv', ' Version/4.0 Chrome/111.0.5563.116 Mobile Safari/537.36', 'Saudi Arabia', '02 Makkah', '21.4266, 39.8256 Saudi Telecom Company JSC', '2023-04-07 07:28:26'),
(43, 1, 'een5kt1QQs2AAJch36vj5x:APA91bEsZBykK6xztX481ufv7h_p6VqRKjLfZBE17C4JL4NeUTk0U0knU400Z_OUY44P2l7CJuGMY_Fx36Y4IIuSS3Ni_QiHAg2mMgfE4bKX3DPh81akqSKTHUdLtmTts1yUmTIHot6x', '102.220.40.224', 'Mobile', 'Mozilla/5.0 (Linux; Android 11; SM-A127F Build/RP1A.200720.012; wv', ' Version/4.0 Chrome/103.0.5060.129 Mobile Safari/537.36', 'Somalia', 'BR Bosaso', '11.2842, 49.1816 Golis Telecom Somali', '2023-04-07 17:10:07'),
(44, 1, 'fAZphvxJTjC7yF7JINJDYH:APA91bFrz_fjqxwuPYFooUXAqwverErOnj0xECKVYqSNAT28JXXWpmxnwYIvjrSEI9ohPh7QCJQnETcpES2qEJpslRSPIA0c_KkQWZ1f4e8RqJsMFd8S_hmIlv0fWCf4LYdFZDN0aSOi', '154.115.222.220', 'Mobile', 'Mozilla/5.0 (Linux; Android 11; SM-A107F Build/RP1A.200720.012; wv', ' Version/4.0 Chrome/102.0.5005.125 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Telesom', '2023-04-09 01:31:31'),
(45, 1, 'c6ij_uLES62vvmPmEpHmBK:APA91bHa4LVY_QJlUgQQaKslWKbpW_Vx4lORo9K1gUnyrasJ_Jy9wXUJjIf7mg7MBN6YjVvYsq0OtE4aAE0XW6tF8MdZ7zy4G2gewBYToNnI5IkHg3bX6GUCgYmy7vNI5li7EUbinHcM', '197.231.201.209', 'Mobile', 'Mozilla/5.0 (Linux; Android 11; SM-A107F Build/RP1A.200720.012; wv', ' Version/4.0 Chrome/111.0.5563.116 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '2023-04-10 00:40:32'),
(46, 1, 'c3-_EzXzTbut40YZBG7KzP:APA91bGBDBvg4XFe4t_p1r8aPMwwQjDtPau8JdfWVw-Wk7QRuT9xCONr4QDsvx7SDcbA8eZnlb5Nyzu9dP1zpNowGD3V6IKWw7JycLMFWahdUVuNAR0nfEGK5Ra_a3AqOY7iZk7nBg6o', '197.231.203.106', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-A015M Build/SP1A.210812.016; wv', ' Version/4.0 Chrome/111.0.5563.116 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '2023-04-13 08:13:34'),
(47, 1, 'fSQFLQtiTt-jrI8LHS117w:APA91bGt-4VXyZ4500o5Gk7S7RvEaQcjClUWYQ7JKJdF6wtqsJr7k8p69w9khyR-XKqTRaSnrnPSjQ_nimm_bpM1oCFwCYXZr9IqdAibRMJPI48TjahzWYcg6GhrGK3AJBumBkV36jyR', '197.231.201.203', 'Mobile', 'Mozilla/5.0 (Linux; Android 13; SM-M135F Build/TP1A.220624.014; wv', ' Version/4.0 Chrome/111.0.5563.116 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '2023-04-14 02:12:48'),
(48, 1, 'dDF8jsZPSPGV5n3Ag3TZUj:APA91bEh69KEwUgPhUns_AEcjPcxgpA99xQEBD05ZTF3zIhJrLsfrHQkMgSicEt2h2yjpF4BqtM9O1-5oacQ0IOWaEDe_nCccOdRktKTPcOlJ5gnZmP84ZC7zHK5B_gf_Eu1hvwoFQRd', '108.177.7.92', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; Pixel 6 Build/SQ1D.220205.004; wv', ' Version/4.0 Chrome/91.0.4472.114 Mobile Safari/537.36', 'United States', 'VA Reston', '38.9687, -77.3411 Google LLC', '2023-04-15 02:18:50'),
(49, 1, 'djTOmP5kTkOyTmzqmM55Ch:APA91bH-ViHa1L8DkDF5DLglCW3fFhlLjyUnOdg_ZU2WRnzbFTjf9EUUKJLCaBp2E7QVTSQH3Di7pfAbWnO0Y-la81fg14D0DeVANnKI-qPTcM9gzw_EolaFsGF-YP2m9uzfNQHFnzmG', '154.115.222.254', 'Mobile', 'Mozilla/5.0 (Linux; Android 13; SM-A137F Build/TP1A.220624.014; wv', ' Version/4.0 Chrome/111.0.5563.116 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Telesom', '2023-04-15 21:45:35'),
(50, 1, 'dkHgcox4RuioeVQR_v1SK5:APA91bFVbF3xOFZsu1zNMkKTacat-pm17h77hNqJf_P-DQheUREjFaN8_yp4swZCFaEkOOsxrVlOmO16VJ4YbEjJTccePHVVmR03sI0AlDNNdqEY-swUnrICJjd5wlsyDLpq3xlgRtux', '197.231.203.106', 'Mobile', 'Mozilla/5.0 (Linux; Android 9; SM-A105F Build/PPR1.180610.011; wv', ' Version/4.0 Chrome/74.0.3729.136 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '2023-04-16 00:07:21'),
(51, 1, 'BLACKLISTED', '34.69.234.70', 'Mobile', 'Mozilla/5.0 (Linux; Android 9; GCE x86 phone Build/PGR1.190916.001; wv', ' Version/4.0 Chrome/66.0.3359.158 Mobile Safari/537.36', 'United States', 'IA Council Bluffs', '41.2619, -95.8608 Google LLC', '2023-04-24 15:36:01'),
(52, 1, 'eI6ggPSaTgmNSkQesPVMQn:APA91bHLjJeCjSZS3FmI6Z9n31vfEobRDv8cZsPJwKk2bDiDgbGFLi0OqKpiNswOkkJMXmuKxG4jRSGTl7r6p8tDYRnWBF5FSLtm_aKZeMyk2f2G4B79mEqNR-EpZszhq0lcb_VZaLVS', '154.115.222.136', 'Mobile', 'Mozilla/5.0 (Linux; Android 11; SM-A022G Build/RP1A.200720.012; wv', ' Version/4.0 Chrome/87.0.4280.141 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Telesom', '2023-04-28 02:56:00'),
(53, 1, 'e4rSeTDoRqKHF4uaHTlO8b:APA91bHR23U8CG1JSnQAXmkQ8_zcLdQ9SDtSAXwlzke3mf5Y34Od0zqnY3q4JixkzUF8gBCtgr-FtthLhlnJoCNY06TxtnSMk-GhKh9s1ZhItE30TMygOwtHcY2zQ-STimx0pOQpnipq', '197.231.201.175', 'Mobile', 'Mozilla/5.0 (Linux; Android 13; SM-M127G Build/TP1A.220624.014; wv', ' Version/4.0 Chrome/112.0.5615.135 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '2023-04-29 00:52:33'),
(54, 1, 'e8vZEK70S4m1-3llrvYtja:APA91bE558BMS3w6Jq7Sa6NfcrNBoHCWL5A7_7KmI-ZBH0b0E_EcfwOCs2e3ZZXrHzr1jK-OuM-r2CjYXBdrcZ-vejcFdggI6EiNCLyQsOQH57chjuac6mJR2q0kXLKiX6_DjdOirykt', '197.231.201.172', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-A217F Build/QP1A.190711.020; wv', ' Version/4.0 Chrome/111.0.5563.116 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '2023-04-30 03:21:38'),
(55, 1, 'eqYYIP7HTzKJqAADT6HjkU:APA91bEVSR-7E0cYEPa397u5rDbzwthYS3CKh3HSJFvdQyoRjLDnQdbsUbVm4I516_MLt_B6bKIgteaK8QhLrC2UxUrHT0OEa-nbymoXWJulMj85q0JZ9Kw0TQV1YG9PE4Y5FJVza3yu', '102.68.16.123', 'Mobile', 'Mozilla/5.0 (Linux; Android 11; SM-A032F Build/RP1A.201005.001; wv', ' Version/4.0 Chrome/108.0.5359.128 Mobile Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Somtel Somalia LTD', '2023-04-30 23:37:52'),
(56, 1, 'dTzi8llPRoGzUlhMYeF1SN:APA91bH1WLv2-aOvU5stG-nnyl-04gM8lIV3AZYkueaYAHB6mdC6GUcpR43UiZ_QVHIMJu5kbt_WmNHJB54fx0qJQvG4oZrr-LUqD1LKzrEHmKxvG4CaumNWU6mDFKSFUhBdfnfov0JE', '154.115.222.195', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; M2101K6P Build/SKQ1.210908.001; wv', ' Version/4.0 Chrome/111.0.5563.116 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Telesom', '2023-05-03 11:23:12'),
(57, 1, 'cQTzQi-rRZ2ML617-r4YB8:APA91bE31fig6kI1fZMoAMWDqWJbgVM-lZSfgcsIAOkiGPutxzmccbWcSLkAmBqneC3N3-1eGn43XnHyPldnTnCVmwFgGIWyWTeNdFEmO7Of9N_XZMg09tEoEKhMQA8f5N6fDcZILZCy', '154.115.230.91', 'Mobile', 'Mozilla/5.0 (Linux; Android 13; SM-A037F Build/TP1A.220624.014; wv', ' Version/4.0 Chrome/112.0.5615.136 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56239, 44.077 Telesom', '2023-05-16 21:08:55'),
(58, 1, 'ccyK2kQERZ-3gbz1BgqfbA:APA91bFgHi-febTyn8fguaOVniDdqv_lHtoUqexhm15MVm7Xlyk_c9-i6wSbAQ70Aagv24DyQ-5VDm7vLUo9DkwgBqsdMmHuBvVjSRxMyk0_mQxH9_eZjADZNFZ_3XnLcwPJoxjsQBmP', '41.79.198.8', 'Mobile', 'Mozilla/5.0 (Linux; Android 13; SM-A325F Build/TP1A.220624.014; wv', ' Version/4.0 Chrome/113.0.5672.131 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', '2023-05-27 15:11:02'),
(59, 1, 'f5vN89tGRuqPF_bXsrRMPz:APA91bEe8gLgATQuDY_Os4dlR5jiBQRPlkq2oFZfeRo0AIxsepafA68vbnGOFSihNYnQ9tGMWDBIKHD2EIXHIBTAXOu7QW0w1LrB3ZvGby5CGFPTmu75K-Z0DeVWM8hmIybGgNdbSlQA', '197.231.201.212', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G Build/QP1A.190711.020; wv', ' Version/4.0 Chrome/112.0.5615.135 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '2023-05-27 22:20:09'),
(60, 1, 'ddFGDcQmQf6jcveXyJHEgC:APA91bEClCV1lLqiTRqr4lrh7Cr6GxBjj5mE11via4TBCUKo1R0SecCjpdn7oMvaIGvU4Xgs7rEuFb6dVnyI4vut_yL_D7agzM9lzyguY3_Cm5V2P3eQqK2YoAW-oBNRnW0J7Ipfrpbi', '154.115.222.196', 'Mobile', 'Mozilla/5.0 (Linux; Android 11; SM-A217F Build/RP1A.200720.012; wv', ' Version/4.0 Chrome/113.0.5672.76 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Telesom', '2023-05-30 06:43:46'),
(61, 1, 'fgQZPrgoQPCmeDnLMqm1r0:APA91bE5oPyel190W26Ez1dEnxU4aNQ1mnbx6gSghblKbkDPocpcftxxbGA8EUBtyf2rhgWp0dVEXaTvEUEMC8bC7f0klUPKfU9RXBXAXkoxdUHYtBv_362SP7QxGuJDjJ9Jp9Eaze23', '102.68.16.88', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-J610G Build/QP1A.190711.020; wv', ' Version/4.0 Chrome/81.0.4044.138 Mobile Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Somtel Somalia LTD', '2023-05-31 13:02:35'),
(62, 1, 'cXTfZZLLTn-FjfGcLFYlOD:APA91bHlnPgVP7bLHIH_FfAGVOenzptOsTXko_YdvJVNqY1Um5o81WERVYt5F3r9SsTPZytCvYRqw6h-MKXrst-WVKfJ-NlhLAjTHskl-zCY6Hdn4rUDB2lJPfSokbpNx1yD270BhCK1', '197.231.203.91', 'Mobile', 'Mozilla/5.0 (Linux; Android 13; SM-A336E Build/TP1A.220624.014; wv', ' Version/4.0 Chrome/104.0.5112.97 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '2023-05-31 22:58:29'),
(63, 1, 'e7lQI8uHR5qxeR0HVfwn-S:APA91bGl2r-JTLEqexy4AGtOVOl2USyySnGKxlk3EefmPjxcRpWn8FsNnAi4YUn0ArlL4I1KMNKBW0QAWZ7k1FLWxed7o_PsoBHJd6WFCj-dpe7OAK0ERTXF9h3nsLLuSdCDvuSPlGen', '197.231.201.161', 'Mobile', 'Mozilla/5.0 (Linux; Android 11; SM-A207F Build/RP1A.200720.012; wv', ' Version/4.0 Chrome/113.0.5672.162 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '2023-06-08 04:23:17'),
(64, 1, 'd85MgQfzR96RviyWTfOsqU:APA91bGiXkKIT9by8EccXj1N1dSiUyOfEWIMZhwUu1EnFwMauIeTJA-3vouS-Yucb9z4iVASg-y601Y2fhWymvcAWwGsBCWDxUyIe19SX6ALE9nAXC69vSpNvSfrGALdteCLUTmmP6Ru', '197.231.203.108', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-A217F Build/SP1A.210812.016; wv', ' Version/4.0 Chrome/107.0.5304.141 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '2023-06-10 06:25:55'),
(65, 1, 'cZ4_7IkjQTOlpSVHiWckPP:APA91bFEy0mDsXYMm3wNYAwuIqeo7EQnQcR2PhxTtYrApDUsppZcM1otTcRwWWYfoz_VldcrCbrS5Cgc-CAw3WiAuSYzQWcy-yKxHVejcz8ChfsjceGwKUAjVfpOc3ZLseirWeTtP-Iv', '154.115.221.172', 'Computer', 'Mozilla/5.0 (Linux; Android 13; SM-A037F Build/TP1A.220624.014; wv', ' Version/4.0 Chrome/113.0.5672.162 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Telesom', '2023-06-16 17:20:44'),
(66, 1, 'dUm6ZYjFTwKCyUnJpii_Co:APA91bGrL98zQQ0-c_DIo1IG6otAl1Roi7j4iNOyIfGwAb4i4K4meaHPRPl-UmPJELBQvm3OEUWqw7y9tS1XBbj9nWvbv9TJHCD0b3x2HbvmPeti0QG7TAfCR-aBtQ24-v-R01X8b_lB', '197.231.203.107', 'Mobile', 'Mozilla/5.0 (Linux; Android 13; SM-M127F Build/TP1A.220624.014; wv', ' Version/4.0 Chrome/104.0.5112.97 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '2023-06-30 18:25:51'),
(67, 1, 'doEk6mFVTqu71Oh27f0pVE:APA91bE9V4wOS4LTTEGEekkbM2TzK5mi7ypw1ZgJ0pRF9QxIGQNgYb7eKY3kMr_0DNbpy4Ro-GTv5AYyQxz55Ue4IAokvm3iahACm3y17m3dPpDfRm_Ejhm7Z5llSkOMDzgi0E0Hn67B', '197.231.201.171', 'Mobile', 'Mozilla/5.0 (Linux; Android 13; SM-A135F Build/TP1A.220624.014; wv', ' Version/4.0 Chrome/104.0.5112.97 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '2023-07-07 01:59:23'),
(68, 1, 'cxN3GjHkRXG9I2CfYVQmO0:APA91bFFqq5GzdPt7AJiyyeVhqmz2IcEIySw1u1kRwWISdlQyc5nL3G9gFjVCY6vL5F1h8045fPbN0tdkwl1s7ipQF-2wyoed4VJ3kqNkbr80xSBEFYOAx1rcqjVLhdcRqb8_0__DDla', '154.115.253.5', 'Computer', 'Mozilla/5.0 (Linux; Android 11; SM-T515 Build/RP1A.200720.012; wv', ' Version/4.0 Chrome/114.0.5735.196 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 TELESOM', '2023-07-10 04:57:55'),
(69, 1, 'dA1_eq5lQqmfHamfY4nIbg:APA91bE_aGRq-0A97GHdv3ZcWT8JqxFfPzwE9ivZ-9itSR9PX0S-_4rqy24g4QrU-fDG41ZnNm9XAIZFpFv3yaz9ZgWgakJLGiA-4n-P6GNITJfkeh4LJ9goExZXCQPyqh5xVXecJT9B', '197.231.201.173', 'Mobile', 'Mozilla/5.0 (Linux; Android 11; SM-A032F Build/RP1A.201005.001; wv', ' Version/4.0 Chrome/87.0.4280.141 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '2023-07-13 16:19:34'),
(70, 1, 'esF2jtCGR1SnEDe9fhyPr6:APA91bGaGFF86eUqkSIuOnnAorohBwv1tzyaNYiKhfa9UptI9pdpD9euBWCLL4b8W8VBUVqnDjcnKdNWN7RUCuOMPU_NJLfY5N_Fl5_Hs7UtHy7ldpR_KkJHNXvW-Aiv7yfr2OV6Sp79', '197.231.201.177', 'Mobile', 'Mozilla/5.0 (Linux; Android 9; SM-A202F Build/PPR1.180610.011; wv', ' Version/4.0 Chrome/114.0.5735.196 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '2023-07-13 20:09:22'),
(71, 1, 'cqaS-Ps_QCesiIMLUa3O67:APA91bE-46qVMJu8W1aMp1FNGqZ-iOkcn2McFVcU2UndMhDuq4HmM2Vi1XHtmP2PQonYwTXXxCzkp1vSPmUJZgqmzonz8Jz-f6hp2OpVQTu6Anlc2X7gF-nDM67AgxEzIYCmclGmHVqq', '154.115.221.145', 'Mobile', 'Mozilla/5.0 (Linux; Android 11; SM-A125F Build/RP1A.200720.012; wv', ' Version/4.0 Chrome/111.0.5563.116 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Telesom', '2023-07-16 16:23:47'),
(72, 1, 'cisEdGMUTQiGzUgfprWuqO:APA91bGkL-2NfldwKtD6HVbK41TE61NgzpEAaFXNfnJBfKS12jr6XRcovzLkvy32Tq-4NNobpr7rbgpBwl3CrsjSFX2NFyExtKeEhz2bkf-yBu_9w24r5KfhAS_X28larq5yt1B9kvm7', '197.231.201.191', 'Mobile', 'Mozilla/5.0 (Linux; Android 13; SM-A135F Build/TP1A.220624.014; wv', ' Version/4.0 Chrome/114.0.5735.196 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '2023-07-17 02:37:24'),
(73, 1, 'fEZsDGedR_KeZGKWWg3cKu:APA91bGHwmdz1QFg9BfNvzDdxgUE6HIoE662P4NcEtYr1K0lW7rhrRSUK_-QpQOkaRv6U1Jadi9Kg_sa9oxGLXDIbuO7FeMaiDghCdn7nLaLBHKTvdNeWfMPwbcnv_kZnJJH-xRloQOa', '102.128.129.28', 'Mobile', 'Mozilla/5.0 (Linux; Android 11; SM-A107F Build/RP1A.200720.012; wv', ' Version/4.0 Chrome/114.0.5735.196 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.57292, 44.0508 SOMTEL INTERNATIONAL Ltd', '2023-07-17 12:25:36'),
(74, 1, 'emwp6QxBQV-ix8LN2nCmR6:APA91bGWZVWmWsQh8LmdEx2wYi2zDW4Cj2WJKDCTReeCs7_buAVCn5zTrX7SbsY5Edoq-vh_20mSmK32jKYJEUpUGwlLwmQ1F_JWNB8M1ov2eNK2Djn4AQXTR4rbwPWTiLOYabw1GRyo', '197.231.201.198', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G Build/QP1A.190711.020; wv', ' Version/4.0 Chrome/114.0.5735.131 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '2023-07-25 02:46:24'),
(75, 1, 'cqgtKstbSj-nY14Ow4DuIi:APA91bEMfSati2n-5NpL5U8dJ9JX6M8AB32nHRC1O7_8nl3lvMvATMuDcQluHQ0w1qqKPH2GzOx-hC3snkJWH73ycvrzAcX0UmLxscshi2C5fT1-g-TrSQDiM2tlchz5HlAeXnM47rWN', '197.231.201.216', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G Build/QP1A.190711.020; wv', ' Version/4.0 Chrome/114.0.5735.131 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '2023-07-28 03:15:34'),
(76, 1, 'czcKBh6kQmSCRHWWW9nFnq:APA91bEuQ6AGtQ23kpNzbn-4e-Va62Uo75iqXnKNhj_PRJORlaDdvFUHTTfGjPKhyf46OWkzgJCzLmgg7aTskuX9QTpj3-oSpkMruu3lXzI6gqm_b8NjCOM33uZMv1aO6MzNN4gzQwwn', '197.231.203.107', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-A135F Build/SP1A.210812.016; wv', ' Version/4.0 Chrome/106.0.5249.126 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 SOMTEL INTERNATIONAL Ltd', '2023-08-03 00:41:33'),
(77, 1, 'cn66FH-ITTGtU1gdBtadtb:APA91bEX2D5-2xOO_Vf0v07lAd9xptrjFMFY0rjnCQecQrt7OjaVTGYhijIBSiclteU-K0y0LGY9K6KvzBfqsLWJoL9wLMq45Ba2h7GRsYe9PFkBuKnHvQaTU2sWmqSeBKWvy8ZNAEIb', '197.231.201.177', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-M022G Build/QP1A.190711.020; wv', ' Version/4.0 Chrome/114.0.5735.196 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '2023-08-06 22:20:50'),
(78, 1, 'ciRQ9rrrRDCsLunQYgbDIV:APA91bGQFamrqjbEIPzSFtznqf3W-cWHDi1OP5POT0DpxfFSuaqRWFcgogV5n5gY-lzTRbqYWPLu6B2XI371V0GVIihFMetSMKhPl89cnVVhdT1Eck23uOCnPhmkeL3Rxz6FPD2cywJD', '102.68.16.104', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; Redmi Note 9 Pro Build/QKQ1.191215.002; wv', ' Version/4.0 Chrome/83.0.4103.101 Mobile Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Somtel Somalia LTD', '2023-08-28 17:07:20'),
(79, 1, 'enTZcZU7S-CCabAMYGHeVi:APA91bGDiZB5on9BBZFKIeukNJ3RJphHebWwV0J2q3M5p9tdGWAYyyydShHq20nIHPAKzHq0YSBB8E3gJShMYPcMOLpHUKMOR8AYo0KvB_GjMeFvzq2WZe2OPFMcHUNua2tppoz4wF-9', '199.192.115.23', 'Mobile', 'Mozilla/5.0 (Linux; Android 9; GCE x86 phone Build/PGR1.190916.001; wv', ' Version/4.0 Chrome/66.0.3359.158 Mobile Safari/537.36', 'United States', 'IA Council Bluffs', '41.2619, -95.8608 Google LLC', '2023-09-15 22:38:47'),
(80, 1, 'dE0VV6hbQqGJfmkLYxfhJ_:APA91bFkBYDydl8GPLkk-3X4wAos7_cf1pRkQsAbFzVciXwaDDsD78q9LENnVgeIrovRCFZo9y2Wy4Z33zmyGX5qgl8uIxItE47yECMuT2peIFOl4sYm66wIwXM_hsJBr3VsQlQNJ53Q', '192.145.174.40', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-A115F Build/QP1A.190711.020; wv', ' Version/4.0 Chrome/81.0.4044.138 Mobile Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '2023-09-19 02:44:09'),
(81, 1, 'cckJ3uvARt6gEQpL93O7Ys:APA91bFA1nxAb2rRWqYFmXdbPNq7Zbf3S_dMW2sbTbO5rC3O9UiHhRbBQUE9poiOkCfOT-FaWuoYeReYA3ngaOcAm8IEh_IJd38ctVV2jev_T1Q_htKssKgP4KLxXeBBad3ZbrVdOBtT', '192.145.174.40', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-A115F Build/QP1A.190711.020; wv', ' Version/4.0 Chrome/81.0.4044.138 Mobile Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '2023-09-19 02:52:39'),
(82, 1, 'd-yF-UsfRo-zhwSJ9ch0eP:APA91bGda0tMI1p2oi-ZZc_YK-koCKpE7RU6WecZGhJQv1n4A3bbQRLOQzJpmgGFMhHtweLyKjpef5Ng0QwZtK8mbbu6mkwrDwDYMA4YoD96h82B4_AAXemdYRrFNJs3GHA-A3-_U6Up', '192.145.168.47', 'Mobile', 'Mozilla/5.0 (Linux; Android 10; SM-G965F Build/QP1A.190711.020; wv', ' Version/4.0 Chrome/116.0.0.0 Mobile Safari/537.36', 'Somalia', 'BN Mogadishu', '2.0442, 45.3358 Hormuud Telecom Somalia INC', '2023-09-20 23:46:28'),
(83, 1, 'cA6QojJxQ02M_9u1O_QCun:APA91bFekF7ryEZ4frVGWntkm5_PKSq2SwGcqSQK77e2H2pO3pp7GA65EQk7-aNJb-L23shQB6MfLsggVYB9SYvH43oaHlMWPwyZoIp_GFpqWYYsd1XZnJHOJ0pYZUaF1ku8ohTDYwRy', '197.231.202.18', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; TECNO KI5k Build/SP1A.210812.016; wv', ' Version/4.0 Chrome/117.0.0.0 Mobile Safari/537.36', 'Somalia', 'TO Burao', '9.52213, 45.5336 SOMTEL INTERNATIONAL Ltd', '2023-10-01 22:28:51'),
(84, 1, 'c05l1AAqTSeKmu83eBOkns:APA91bFLBzafPLgE9AOjqDWAOCHOSY2tYVtsGL6CW2VyNd9K-kxVoZ_GrZlaOb4F6hUrqFFN0o3-PCFFjelcoWLaneiYPloZN9RciK_UWB2UrY7nN3W3nJsLD_qGOFociuCAkykPcTLX', '154.115.221.84', 'Mobile', 'Mozilla/5.0 (Linux; Android 13; SM-M135FU Build/TP1A.220624.014; wv', ' Version/4.0 Chrome/106.0.5249.126 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 Telesom', '2023-10-14 06:39:36'),
(85, 1, 'c39NkCLFSrSrc4FVYtr7SH:APA91bEOVJk740g3O1dh5HzhmKgjbDxAj1hKKeH0vrMFcUPjOYmZJRjKa7Y3rRXAo3ZJ0WmVn2_VMUrNi-1RcInxDDfRwb6C6-G39rUm5CEwqUwbJDHm5QL240gm3fcVqRVBysYmS0gr', '197.231.201.204', 'Mobile', 'Mozilla/5.0 (Linux; Android 9; SM-J415F Build/PPR1.180610.011; wv', ' Version/4.0 Chrome/116.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '2023-10-14 16:04:30'),
(86, 1, 'esV6sSMtQPy84lAGkXZTRR:APA91bF4oUm1xL8Frq7NN7a-jZSdBjR1Yqk4z640Uk9cpqEqZZBksZh_l92KeDVE1KRDsnzwSbicySyjMGMGbun0VNLPYgDMcZjZMJUurXWEa5j7QKtvC30zkYSImgrMaNcNxmRQTcie', '154.115.222.247', 'Computer', 'Mozilla/5.0 (Linux; Android 13; SM-P610 Build/TP1A.220624.014; wv', ' Version/4.0 Chrome/117.0.0.0 Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 Telesom', '2023-10-26 15:36:03'),
(87, 1, 'fyNggiQKS3WTdqHuXbWOED:APA91bF_eVJ1wL_LXvuOHL6-MNY943RzkhssNTuLKncNhh41NCfD9D47NIl7YweWxHVanc8tf4Y1caaR2EXuvUxn_q7i8jg71YaLMO49U7k7ToflcZbPOnNff4SMwhhgky_pYCBzQPzg', '41.79.198.19', 'Mobile', 'Mozilla/5.0 (Linux; Android 13; SM-A127F Build/TP1A.220624.014; wv', ' Version/4.0 Chrome/118.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.5582, 44.0604 Somcable', '2023-11-03 06:33:24'),
(88, 1, 'eLTGK9E0QD6O4TotNCYI-O:APA91bFaFqPJxLcX1FFeJeRW_xY2SW6lCQRvYjPgQeHPVwOhAI08zYVCKKBtU6-KuZsOT9_z6aGPIkahDg9gHqaH0Td7MwQv2TNefy6_LVE9jBYxqXU3dTd8Sgf-LsNq2avWAq5VHjMU', '154.115.221.23', 'Mobile', 'Mozilla/5.0 (Linux; Android 13; SM-E135F Build/TP1A.220624.014; wv', ' Version/4.0 Chrome/117.0.0.0 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 Telesom', '2023-11-14 03:01:43'),
(89, 1, 'eQQhvGiuSmCuYNup9KD6Cf:APA91bGMlACEERNjJfKohj0-1zKPZhamlHp4YT20sU0uLcrJdcYKEtEtqE6u9XsQHRW_hnt8Zv0H-81ukgpL5Ex9vyzDl2IThh6SrDVpXAZzAlyyVsIF1VxkpuLKv2RmECIXnSoJOl69', '192.145.168.51', 'Mobile', 'Mozilla/5.0 (Linux; Android 11; SM-A207F Build/RP1A.200720.012; wv', ' Version/4.0 Chrome/120.0.6099.144 Mobile Safari/537.36', 'Somalia', 'BN Mogadishu', '2.04933, 45.3198 Hormuud Telecom Somalia INC', '2024-01-11 01:56:58'),
(90, 1, 'e7NGoFy7Rs2o08cGF3n3WG:APA91bGfmoiAyh4q7cocJIWonnq8YODCwFUU8M9E5qC2GSi5zFSrOTOWpAYxhX5x1AjY7OPptPQMmBHfDm_-4WzaooJfp_bbfaghAd_5fak59rmBAbenVTysq1rFdKbzgsHyRUTpD_hc', '104.133.229.101', 'Mobile', 'Mozilla/5.0 (Linux; Android 13; SM-A336E Build/TP1A.220624.014; wv', ' Version/4.0 Chrome/119.0.6045.67 Mobile Safari/537.36', 'Malaysia', '14 Kuala Lumpur', '3.1412, 101.687 Google LLC', '2024-01-15 16:55:09'),
(91, 1, 'fH6_ShIIQ2mPDSitr12x6n:APA91bHyGeUgC5ClBX6EOHtheAuYWH0KerJV2lBXWkVASpRU_Ev48lWtWA20cOKFkAbwduHECIBL5rWfnnN37th3RQl5k7eItZejg9gcdl8t_-7g01gz2Z7ZYA-1ndb1ygqVOv5NGYSZ', '197.231.201.180', 'Mobile', 'Mozilla/5.0 (Linux; Android 13; SM-A145M Build/TP1A.220624.014; wv', ' Version/4.0 Chrome/120.0.6099.210 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56239, 44.077 SOMTEL INTERNATIONAL Ltd', '2024-01-23 01:30:10'),
(92, 1, 'c-Q1VTLaTA2bxeLQndkYmw:APA91bHGxO3rvzSuavmzCXgHgqqieX3oVzLR9EymhOZ7TDK0phr0EFO8ROYazD6T1NsKZro-u4-c0piNVESUDgaZcQQmNAR-GURXpRiQnb3eLvBGrvEyDP15qkep85_L9wD1WOt1cLia', '197.220.84.101', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-A217F Build/SP1A.210812.016; wv', ' Version/4.0 Chrome/120.0.6099.211 Mobile Safari/537.36', 'Somalia', 'BN Mogadishu', '2.03711, 45.3438 Hormuud Telecom Somalia INC', '2024-01-24 02:25:11'),
(93, 1, 'ebGZEYGE2e8lJ7_o7JvgUj:APA91bF2KocID0co1ilOb4Cat38ciNYqtxqLBhZ-Lc3feGWWo2JszkGNsO1RBuBbyCrNfFr2Ps4-dHqC06dAaV3duM8jbiefnLbQ5QmiBZNiGJLFiKn3P2MR-NpIwIKOlSbxaNoUPJiK', '197.231.201.177', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-A115F Build/SP1A.210812.016; wv', ' Version/4.0 Chrome/120.0.6099.230 Mobile Safari/537.36', 'Somalia', 'WO Hargeisa', '9.56, 44.065 SOMTEL INTERNATIONAL Ltd', '2024-02-14 06:22:59'),
(94, 1, 'fD15DVQYTBu383H1M7gLyA:APA91bGEjlSLStvfG6msRioyNygij1sJ3gByMptT7UssQteocKSVsGao4a8OkKWhLNHNufKV4OmjmdHtMBOX9NbPmWWUCs5FPYPzupdSMWHAb2cavqF2WnlEl3Afj8xWr3OpBamVpO4-', '192.145.175.162', 'Mobile', 'Mozilla/5.0 (Linux; Android 13; SM-M326B Build/TP1A.220624.014; wv', ' Version/4.0 Chrome/106.0.5249.126 Mobile Safari/537.36', 'Somalia', 'BN Mogadishu', '2.03711, 45.3438 Hormuud Telecom Somalia INC', '2024-02-27 19:00:59'),
(95, 1, 'eo6f1WZET_aRUfC35SqfVq:APA91bF0ux9LbZ6_dPv1EbXD5LH1TXRtEKSrdtM9SDSkmFaDxd2lasN0lnyoLjQgz5rAYpmfr3Vin3AFRjMets_yQgZMdTA0vYwjT3ClIvGQ_62kz9XzTi85DhOTu_0-XyCZBz2zD_gV', '192.145.175.226', 'Mobile', 'Mozilla/5.0 (Linux; Android 12; SM-A217F Build/SP1A.210812.016; wv', ' Version/4.0 Chrome/121.0.6167.178 Mobile Safari/537.36', 'Somalia', 'BN Mogadishu', '2.03711, 45.3438 Hormuud Telecom Somalia INC', '2024-02-27 19:29:10');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `agent`
--
ALTER TABLE `agent`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `app_click`
--
ALTER TABLE `app_click`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `app_patient`
--
ALTER TABLE `app_patient`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `blood`
--
ALTER TABLE `blood`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `branch`
--
ALTER TABLE `branch`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`,`address`),
  ADD UNIQUE KEY `auto_id` (`auto_id`,`company_id`);

--
-- Indexes for table `campaign`
--
ALTER TABLE `campaign`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `campaign_agent`
--
ALTER TABLE `campaign_agent`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `agent_id` (`agent_id`,`campaign_id`);

--
-- Indexes for table `company`
--
ALTER TABLE `company`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`domain`) USING BTREE;

--
-- Indexes for table `department`
--
ALTER TABLE `department`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `doctor`
--
ALTER TABLE `doctor`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `evc_app_receipt`
--
ALTER TABLE `evc_app_receipt`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `expense`
--
ALTER TABLE `expense`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `faq`
--
ALTER TABLE `faq`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `general`
--
ALTER TABLE `general`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auto_id_2` (`auto_id`,`company_id`),
  ADD KEY `auto_id` (`auto_id`),
  ADD KEY `company_id` (`company_id`),
  ADD KEY `name` (`name`),
  ADD KEY `name_ar` (`name_ar`),
  ADD KEY `type` (`type`);

--
-- Indexes for table `hospital`
--
ALTER TABLE `hospital`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ktc_category`
--
ALTER TABLE `ktc_category`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `category` (`name`,`company_id`) USING BTREE;

--
-- Indexes for table `ktc_chart`
--
ALTER TABLE `ktc_chart`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ktc_common_param`
--
ALTER TABLE `ktc_common_param`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `parameter` (`parameter`);

--
-- Indexes for table `ktc_delete_logs`
--
ALTER TABLE `ktc_delete_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `table` (`table`),
  ADD KEY `id` (`id`);

--
-- Indexes for table `ktc_dropdown`
--
ALTER TABLE `ktc_dropdown`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ktc_edit_logs`
--
ALTER TABLE `ktc_edit_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ktc_error`
--
ALTER TABLE `ktc_error`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ktc_inbox`
--
ALTER TABLE `ktc_inbox`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ktc_languages`
--
ALTER TABLE `ktc_languages`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auto_id` (`auto_id`,`company_id`),
  ADD UNIQUE KEY `table_auto_id` (`table_auto_id`,`table_name`,`language`);

--
-- Indexes for table `ktc_link`
--
ALTER TABLE `ktc_link`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `text` (`name`,`category_id`,`sub_category_id`,`company_id`) USING BTREE;

--
-- Indexes for table `ktc_parameter`
--
ALTER TABLE `ktc_parameter`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_parameter` (`parameter`,`link_id`,`company_id`) USING BTREE;

--
-- Indexes for table `ktc_procedure`
--
ALTER TABLE `ktc_procedure`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `ktc_sms`
--
ALTER TABLE `ktc_sms`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ktc_solution`
--
ALTER TABLE `ktc_solution`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ktc_sub_category`
--
ALTER TABLE `ktc_sub_category`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`,`category_id`,`company_id`) USING BTREE;

--
-- Indexes for table `ktc_table_alias`
--
ALTER TABLE `ktc_table_alias`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ktc_todo`
--
ALTER TABLE `ktc_todo`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ktc_user`
--
ALTER TABLE `ktc_user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`username`,`company_id`) USING BTREE,
  ADD UNIQUE KEY `auto_id` (`auto_id`,`company_id`),
  ADD KEY `password` (`password`),
  ADD KEY `level` (`level`),
  ADD KEY `branch_id` (`branch_id`),
  ADD KEY `status` (`status`),
  ADD KEY `office_id` (`office_id`),
  ADD KEY `employee_id` (`employee_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `ktc_user_authentication`
--
ALTER TABLE `ktc_user_authentication`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ktc_user_logs`
--
ALTER TABLE `ktc_user_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `link_id` (`link_id`),
  ADD KEY `os` (`os`),
  ADD KEY `browser` (`browser`),
  ADD KEY `device` (`device`),
  ADD KEY `ip` (`ip`),
  ADD KEY `today_count` (`today_count`),
  ADD KEY `count` (`count`),
  ADD KEY `last_date` (`last_date`),
  ADD KEY `date` (`date`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `ktc_user_permission`
--
ALTER TABLE `ktc_user_permission`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `link_id` (`link_id`,`user_id`,`action`,`company_id`) USING BTREE,
  ADD UNIQUE KEY `link_id_2` (`link_id`,`user_id`,`action`,`company_id`);

--
-- Indexes for table `ktc_user_schedule`
--
ALTER TABLE `ktc_user_schedule`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `patient`
--
ALTER TABLE `patient`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `sharer`
--
ALTER TABLE `sharer`
  ADD PRIMARY KEY (`id`),
  ADD KEY `os` (`os`),
  ADD KEY `browser` (`browser`),
  ADD KEY `device` (`device`),
  ADD KEY `ip` (`ip`),
  ADD KEY `date` (`date`);

--
-- Indexes for table `ticket`
--
ALTER TABLE `ticket`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `visitor`
--
ALTER TABLE `visitor`
  ADD PRIMARY KEY (`id`),
  ADD KEY `os` (`os`),
  ADD KEY `browser` (`browser`),
  ADD KEY `device` (`device`),
  ADD KEY `ip` (`ip`),
  ADD KEY `date` (`date`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `agent`
--
ALTER TABLE `agent`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `app_click`
--
ALTER TABLE `app_click`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1406;

--
-- AUTO_INCREMENT for table `app_patient`
--
ALTER TABLE `app_patient`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=248;

--
-- AUTO_INCREMENT for table `blood`
--
ALTER TABLE `blood`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `branch`
--
ALTER TABLE `branch`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `campaign`
--
ALTER TABLE `campaign`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `campaign_agent`
--
ALTER TABLE `campaign_agent`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `company`
--
ALTER TABLE `company`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `department`
--
ALTER TABLE `department`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `doctor`
--
ALTER TABLE `doctor`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=129;

--
-- AUTO_INCREMENT for table `evc_app_receipt`
--
ALTER TABLE `evc_app_receipt`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `expense`
--
ALTER TABLE `expense`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `faq`
--
ALTER TABLE `faq`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `general`
--
ALTER TABLE `general`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `hospital`
--
ALTER TABLE `hospital`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=201;

--
-- AUTO_INCREMENT for table `ktc_category`
--
ALTER TABLE `ktc_category`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=127;

--
-- AUTO_INCREMENT for table `ktc_chart`
--
ALTER TABLE `ktc_chart`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `ktc_common_param`
--
ALTER TABLE `ktc_common_param`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=447;

--
-- AUTO_INCREMENT for table `ktc_delete_logs`
--
ALTER TABLE `ktc_delete_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `ktc_dropdown`
--
ALTER TABLE `ktc_dropdown`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1136;

--
-- AUTO_INCREMENT for table `ktc_edit_logs`
--
ALTER TABLE `ktc_edit_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=317;

--
-- AUTO_INCREMENT for table `ktc_error`
--
ALTER TABLE `ktc_error`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `ktc_inbox`
--
ALTER TABLE `ktc_inbox`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ktc_languages`
--
ALTER TABLE `ktc_languages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ktc_link`
--
ALTER TABLE `ktc_link`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1468;

--
-- AUTO_INCREMENT for table `ktc_parameter`
--
ALTER TABLE `ktc_parameter`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20067;

--
-- AUTO_INCREMENT for table `ktc_procedure`
--
ALTER TABLE `ktc_procedure`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=573;

--
-- AUTO_INCREMENT for table `ktc_sms`
--
ALTER TABLE `ktc_sms`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `ktc_solution`
--
ALTER TABLE `ktc_solution`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ktc_sub_category`
--
ALTER TABLE `ktc_sub_category`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=159;

--
-- AUTO_INCREMENT for table `ktc_table_alias`
--
ALTER TABLE `ktc_table_alias`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `ktc_todo`
--
ALTER TABLE `ktc_todo`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ktc_user`
--
ALTER TABLE `ktc_user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `ktc_user_logs`
--
ALTER TABLE `ktc_user_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1212;

--
-- AUTO_INCREMENT for table `ktc_user_permission`
--
ALTER TABLE `ktc_user_permission`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23125;

--
-- AUTO_INCREMENT for table `ktc_user_schedule`
--
ALTER TABLE `ktc_user_schedule`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `patient`
--
ALTER TABLE `patient`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `sharer`
--
ALTER TABLE `sharer`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `ticket`
--
ALTER TABLE `ticket`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

--
-- AUTO_INCREMENT for table `visitor`
--
ALTER TABLE `visitor`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=96;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
