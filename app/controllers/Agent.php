<?php
    class Agent extends Controller{
        
        public function __construct(){
            parent::__construct();
            $this->formModel = $this->model("Form");
        }
        
    
        public function index(){
            if(empty($_COOKIE['agent_tell'])){
                header("Location: ". URLROOT.'/agent/login');
                exit;
            }
            
            header("Location: ". URLROOT.'/agent/profile');
            
            
        }
        
        
 		
 		  public function profile(){
 		     
 		      $check_agent = array("sp" => "569", "tell" => $_COOKIE['agent_tell']);
                    
                    
             $agent = $this->formModel->callProcDQL($check_agent, "fetch");
      	 
      	     
      	 
      	 $data = [
      	     "agent" => $agent
      	     ];
 		     
          $this->portalView("agent/profile", $data);
                
        }
        
        public function campaign(){
 		     
 		      $campaign_post = array("sp" => "571", "co" => 1, "agent_tell" => $_COOKIE['agent_tell'], "action" => "current_campaign");
                    
                    
             $campaign = $this->formModel->callProcDQL($campaign_post, "fetch" );
      	 
      	     
      	 
      	 $data = [
      	     "campaign" => $campaign
      	     ];
 		     
          $this->portalView("agent/campaign", $data);
                
        }
        
         public function campaignmembers(){
 		     
 		      $campaign_post = array("sp" => "571", "co" => 1, "agent_tell" => $_COOKIE['agent_tell'], "action" => "agent_campaign");
                    
                    
             $campaign = $this->formModel->callProcDQL($campaign_post);
      	 
      	     
      	 
      	 $data = [
      	     "campaign" => $campaign
      	     ];
 		     
          $this->portalView("agent/members", $data);
                
        }
        
        
        
       public function join($campaign){
 		     
 		      $campaign_post = array("sp" => "572", "co" => 1, "agent_tell" => $_COOKIE['agent_tell'], "campaign" => $campaign);
                    
                    
             $campaign = $this->formModel->callProcDQL($campaign_post, "fetch" );
      	     setcookie("campaign_id", $campaign->campaign_id, time() + (86400 * 30), "/"); // 86400 = 1 day

      	     
      	 echo $campaign->msg;
      	 
        }
        
        
        
        
         public function login(){
 		     
 		      $company = array("sp" => "68", "domain" => URLROOT);
                    
                    
             $company = $this->formModel->callProcDQL($company, "fetch");
      	 
      	 $data = [
      	     "company" => $company
      	     ];
 		     
          $this->portalView("agent/login", $data);
                
        }
        
        
        
        public function regsiter(){
 		     
 		      $company = array("sp" => "68", "domain" => URLROOT);
                    
                    
             $company = $this->formModel->callProcDQL($company, "fetch");
      	 
      	 $data = [
      	     "company" => $company
      	     ];
 		     
          $this->portalView("agent/agent-form", $data);
                
        }
        
        
        public function goToPlayStore($tell){
            if(!empty($_COOKIE['sharer_tell']) &&  strpos($_COOKIE['sharer_tell'], $tell) !== false ){
                
                 header("Location: https://play.google.com/store/apps/details?id=com.bulshotech"); 
                 
            }else{
                
               setcookie("sharer_tell", @$_COOKIE['sharer_tell'].','.$tell, time() + (86400 * 30), "/"); // 86400 = 1 day
            
              $location = $this->locationInfo();
        
                    $country = $location['country'];
                    $region_city = $location['region'] . ' ' . $location['city'];
                    $lat_lon = $location['lat'] . ', ' . $location['lon'] . ' ' . $location['isp'];
                    $device = $this->device();
                    $deviceInfo = $this->deviceInfo();
                    $os = $deviceInfo[0];
                    $browser = $deviceInfo[2];
            
            $sharer_post = array("sp" => "568", "co" => 1,  "tell" => $tell, "ip" => $this->ip(), "device" => $device, "os" =>$os, "browser" => $browser, "country" => $country, "region" => $region_city , "city" => $lat_lon); 
                $sharer = $this->formModel->callProcDML($sharer_post);
                
           
                
                header("Location: https://play.google.com/store/apps/details?id=com.bulshotech"); 
            }
        }
        
        
        
        public function agentSave(){
              $_POST = filter_input_array(INPUT_POST,FILTER_SANITIZE_STRING);
            $post = array_map('trim', $_POST);
            $post['short_url'] =   $this->shortUrl(URLROOT.'/agent/goToPlayStore/'.$post['tell']);
            $post['date'] = date("Y-m-d");
            
            $result = $this->formModel->getRow($post);
            
            setcookie("agent_tell", $post['tell'], time() + (86400 * 360), "/"); // 86400 = 1 day
            
             if(!empty($result->sms_wa) && !empty($result->tell_wa)){
                 $tells = explode(",", $result->tell_wa);
                 foreach($tells as $t){
			        $this->sendWhatsApp($t,$result->sms_wa);
                 }
            }
         header("Location: ". URLROOT.'/agent/profile');
            
        }

			public function checklogin(){
			 $_POST = filter_input_array(INPUT_POST,FILTER_SANITIZE_STRING);
            $post = array_map('trim', $_POST);
            
             $result = $this->formModel->getRow($post);
            
            
            if(!empty($result->msg)){
            	$data = [
                	"msg" => $result->msg
                ];
             $this->portalView("agent/login", $data);
            
            }else{
            	foreach($result as $c => $v){
                	$_SESSION[$c] = $v;
               		
                }
             header("Location: ".URLROOT.'/agent/dashboard');
            }
            
            
            }
        
         public function logout(){
           
            $this->session->destroy();
            
            header("Location: " . URLROOT . "/agent/login");

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
        
    }