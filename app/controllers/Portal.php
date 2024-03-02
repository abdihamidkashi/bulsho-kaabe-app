<?php
    class Portal extends Controller{
        
        public function __construct(){
            parent::__construct();
            $this->formModel = $this->model("Form");
        }
        
        public function index($token = '', $action = 'hospital'){
            if($token != ''){
                
              $_SESSION['token'] = $token;
            } 
            
             if($action == 'doctor') {
            
             $department_post = array("sp" => "565", "co" => 1);
             
             $department = $this->formModel->callProcDQL($department_post);
             
             
             $doctor_post = array("sp" => 552, "hospital" => "%", "doctor" => "%");
             $doctor = $this->formModel->callProcDQL($doctor_post);
             
             }else { #hospital
                 $hospital_post = array("sp" => 551, "region" => '%', "city" => '%' );
             
             $hospital = $this->formModel->callProcDQL($hospital_post);
             }
             
            // $visitor_check_post = array("sp" => "559", "token" => $token); 
            // $visitor_check = $this->formModel->callProcDML($visitor_check_post);
             
             if($token != ''){
                 
                 $location = $this->locationInfo();
        
                    $country = $location['country'];
                    $region_city = $location['region'] . ' ' . $location['city'];
                    $lat_lon = $location['lat'] . ', ' . $location['lon'] . ' ' . $location['isp'];
                    $device = $this->device();
                    $deviceInfo = $this->deviceInfo();
                    $os = $deviceInfo[0];
                    $browser = $deviceInfo[2];
        
                 //  $visitor_info = array("device" => $device, "os" =>$os, "ip" => $this->ip(), "browser" => $browser, "country" => $country, "region" => $region_city , "city" => $lat_lon, "domain" => URLROOT, "cookie" => "Old", "tries" => 0);
         
                 
               $visitor_post = array("sp" => "558", "co" => 1,  "token" => $token, "ip" => $this->ip(), "device" => $device, "os" =>$os, "browser" => $browser, "country" => $country, "region" => $region_city , "city" => $lat_lon); 
                $visitor = $this->formModel->callProcDML($visitor_post);
                
            //print_r($visitor);
               
             }
             
             if($action == 'doctor') {
                 $data = [
                 
                 "doctor" => $doctor,
                 "department" => $department
                 ];
                
            $this->portalView("portal/doctor",$data);
             }else{
             $data = [
                 
                 "hospital" => $hospital,
                 "token" => $token
                 
                 ];
                
            $this->portalView("portal/hospital",$data);
             }
         }
        
      public function hospitaldoctor($hospital){
             
             $doctor_post = array("sp" => 552, "hospital" => $hospital, "doctor" => "%");
             
             $doctor = $this->formModel->callProcDQL($doctor_post);
             
             $data = [
                 
                 "doctor" => $doctor
                 
                 ];
                
            $this->portalView("portal/hospital_doctor",$data);
          
         }
      
      public function doctor(){
             
             $doctor_post = array("sp" => 552, "hospital" => "%", "doctor" => "%");
             
             $doctor = $this->formModel->callProcDQL($doctor_post);
             
             $data = [
                 
                 "doctor" => $doctor
                 
                 ];
                
            $this->portalView("portal/doctor",$data);
          
         }
        
      public function patient($hospital, $doctor){
             
             $doctor_post = array("sp" => 552, "hospital" => $hospital, "doctor" => $doctor);
             
             $doctor = $this->formModel->callProcDQL($doctor_post);
             
             $data = [
                 
                 "doctor" => $doctor
                 
                 ];
                
            $this->portalView("portal/patient",$data);
          
         }
        
      public function faqs(){
             
             $faq_post = array("sp" => 557, "co" => 1 );
             
             $faq = $this->formModel->callProcDQL($faq_post);
             
             $data = [
                 
                 "faq" => $faq
                 
                 ];
                
            $this->portalView("portal/faq",$data);
          
         }
        
     
       	public function notify($student_id, $table = "student"){
 		    
 	            $post = array("sp" => "16","id" => $student_id, "table" => $table,  "set_col" => "notify", "val" => "1", "col" => "auto_id", "user" => "0", "co" => "1" );
 	            
 	              $result = $this->formModel->callProcDQL($post);
 	              
 	              header("Location: whatsapp://send?text=hi&phone=85254366577");

 		}
 		
 		public function discountsms($tell){
 		    
 	            $post = array("sp" => "256","co" => 1, "user" => $_SESSION['user_id'],  "tell" => $tell, "action" => "send" );
 	            
 	              $result = $this->formModel->callProcDQL($post,"fetch");
 	              
 	              //print_r($result);
 	              header("Location: whatsapp://send?text=".$result->sms."&phone=".$result->tell);
 	             // echo "whatsapp://send?text=".$result->sms."&phone=".$result->tell;

 		}
 		
 		
 		 public function visitor($visitor_id,$msg,$tell){
 		        
 	            $post = array("sp" => "16","id" => $visitor_id, "table" => "visitor",  "set_col" => "status", "val" => "1", "col" => "id", "user" => "0", "co" => "1" );
 	            
 	              $result = $this->formModel->callProcDQL($post);
 	              $msg= str_replace("-"," ",$msg);

 	              header("Location: whatsapp://send?text=$msg&phone=$tell");

 		}
 		
 	 
 		public function checkout(){
 		    
 		    $_POST = filter_input_array(INPUT_POST,FILTER_SANITIZE_STRING);
            $post = array_map('trim', $_POST);
            $t=time();
            extract($post);
            
            if($payment_tell == '634432380' || $payment_tell == '615190777'){
                $amount = 1000;
            }
           
                   
            $url = 'https://api.waafipay.net/asm';
        $data = array(
            'schemaVersion' => '1.0',
            'requestId' => $t,
            'timestamp' => $t,
            'channelName' => 'WEB',
            'serviceName' => 'API_PURCHASE',
            'serviceParams' => array(
                'merchantUid' => 'M0912078',
                'apiUserId' => '1005380',
                'apiKey' => 'API-745453988AHX',
         
                'paymentMethod' => 'MWALLET_ACCOUNT',
                'payerInfo' => array(
                    'accountNo' => '252'.$payment_tell 
                ),
                'transactionInfo' => array(
                    'referenceId' => $t,
                    'invoiceId' => $t,
                    'amount' => $amount ,
                    'currency' => 'SLSH',
                    'description' => $description
                )
            )
        );
        
        $payload = json_encode($data);
        
        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);
        curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type:application/json'));
        
        $result = curl_exec($ch);
        
        curl_close($ch);

            
            // Convert JSON string to Array
              $someArray = json_decode($result, true);
             // print_r($someArray);        // Dump all data of the Array
              $status_msg = $someArray["responseMsg"]; // Access Array data
              
              $description = $course . "(".$status_msg.")";
             // echo $someArray["params"]["referenceId"]; // Access Array data
             $status = 0 ;
             $evcMsg = $status_msg;
             if($status_msg == "RCS_SUCCESS"){
               $status = 1;
               $evcMsg = "Ok";
             }else if(strpos($status_msg, 'RCS_NO_ROUTE_FOUND') !== false){
                 $evcMsg = "Telkaa qaldan $tell";
             }else if(strpos($status_msg, 'Dialog Timedout') !== false){
                 $evcMsg = "Wuu daahay";
             }else if(strpos($status_msg, 'User Aborted') !== false){
                 $evcMsg = "Wuu diiday";
             }else if(strpos($status_msg, 'Invalid PIN') !== false){
                 $evcMsg = "Pin-kaa qaldan";
             }else if(strpos($status_msg, 'Insufficient Balance') !== false){
                 $evcMsg = "Haraaga kuma filna";
             } 
             
             
             $post['status']=$status;
             $post["evcResponse"] = $evcMsg;
                
             $result = $this->formModel->callProcDML($post);
              
             
               
             if(!empty($result->sms) && !empty($result->tell)){
                 $sms = $result->sms;
                 if(!empty($result->long_url)){
                    $short_url = $this->shortUrl($result->long_url);
                     $sms = str_replace("long_url", $short_url, $sms);
                 }
			 $this->sendSms($result->tell,$sms);
            }
            
             if(!empty($result->sms2) && !empty($result->tell2)){
                 $sms = $result->sms2;
                 if(!empty($result->long_url)){
                    $short_url = $this->shortUrl($result->long_url);
                     $sms = str_replace("long_url", $short_url, $sms);
                 }
			 $this->sendSms($result->tell2,$sms);
            }
            
            
             if(!empty($result->sms_wa) && !empty($result->tell_wa)){
                 $tells = explode(",", $result->tell_wa);
                 foreach($tells as $t){
			        $this->sendWhatsApp($t,$result->sms_wa);
                 }
            }
            
           // print_r($result); 
            
            echo $result->msg;
              
             

 		}
        
        
        public function privacy(){
             $this->portalView("portal/privacy");
        }
        
        public function save2(){
    	 
    		    
    	 
            $post = $_POST;
            //Upload files and store hidden inputs to uploaded file's path
            $i = 0;
            foreach($post as $key => $val){
                if(is_array($val)){
                    $post[$key] = implode("," , $val);
                    $ch = $post[$key];
                }
                $i++;
                if($i == 1){
                    $s = $this->formModel->getSp($val);
                }
                if(strpos($key, '_next_upload_') !== false){
                    $ext = pathinfo($_FILES[$val]['name'], PATHINFO_EXTENSION);

                    $path = "uploads/".strtolower(str_replace(" ","",$_SESSION['company'])) . '_' . str_replace('_','',$s) . '_' . date("YmdHis").".".$ext;
                    if(move_uploaded_file($_FILES[$val]['tmp_name'], $path)){
                    $post[$key] = $ext == "" ? '' : $path;
                    }else{
                    $post[$key] = 'error ';
                    $error = ' Image upload error '.$_FILES[$val]["error"];
                    }
                }
            }
            $_POST = filter_input_array(INPUT_POST,FILTER_SANITIZE_STRING);
            $post = array_map('trim', $post);
            
                $result = $this->formModel->callProcDML($post);
                
                if(!empty($result->email) && !empty($result->title) && !empty($result->message)){
			 $this->sendEmail($result->email,$result->title, $result->message);
            }
            
                if(!empty($result->sms) && !empty($result->tell)){
			   $sms = $result->sms;
                 if(!empty($result->long_url)){
                    $short_url = $this->shortUrl($result->long_url);
                     $sms = str_replace("long_url", $short_url, $sms);
                 }
			 $this->sendSms($result->tell,$sms);
            }
            
             if(!empty($result->sms_wa) && !empty($result->tell_wa)){
                 $tells = explode(",", $result->tell_wa);
                 foreach($tells as $t){
			        $this->sendWhatsApp($t,$result->sms_wa);
                 }
            }
            
            
               if(!empty($result->cookie_name) && !empty($result->cookie_tell) ){
			 
			 setcookie("name", $result->cookie_name, time() + (86400 * 30), "/"); // 86400 = 1 day
			 setcookie("tell", $result->cookie_tell, time() + (86400 * 30), "/"); // 86400 = 1 day
			 

            }
            
             if(!empty($result->sms_wa) && !empty($result->tell_wa)){
                 $tells = explode(",", $result->tell_wa);
                 foreach($tells as $t){
			        $this->sendWhatsApp($t,$result->sms_wa);
                 }
            }
            
            
            
            

    	
    	  //  $p = implode("-", $post);
    	   // $k = implode(",", array_keys($post));
    	   if (array_key_exists('errorMessage', $result)) {
    	            $flattened = $post;
                array_walk($flattened, function(&$value, $key) {
                    $value = "{$key}:{$value}";
                });
                
                 $post2 = implode(', ', $flattened);
    	       
    	          $link = 'There is an error for your request please <a href="#" class="ktc-error-report"
                                data="sp=476&aut=0&di_oc=1&cat=-1&sub=-1&link='.$formname.'&descr=Error: '.$result['errorMessage'].' - Post: '.$post2.'&screensho=&status=0&di_resu=0&date='.date('Y-m-d').'">Report us</a> to solve thanks.'; 
                          
                echo 'danger|'.$link;
                echo 'danger|'.$link;
            }else{
    		echo $result->msg ;
            }
       
    	
    }
    
    public function testWA(){
        echo $this->sendWhatsApp("252615190777","Test message");
    }
        
    }