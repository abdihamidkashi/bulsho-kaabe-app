<?php
    class Users extends Controller{
        
         public function __construct(){
            parent::__construct();
             $this->userModel = $this->model('User');
         }
        public function index(){
                //  $visitor_info = array("device" => $this->device(), "os" => $this->os(), "ip" => $this->ip(), "browser" => $this->browser(), "country" => $this->location("country"), "region" => $this->location("region"), "city" => $this->location("city"), "domain" => URLROOT, "cookie" => "Old", "tries" => 0);
                     $post = array("sp"=> 68, "domain" => URLROOT);
                    $company = $this->userModel->login($post); //not used login, get company
                    if(empty($company->id)){
                            $this->view2("users/404");
                            exit;
                    }
                    $data = [
                        "company" => $company,
                        "visitor" => $visitor_info
                        ];
                 $this->view2("users/login",$data);
                    

            }
            
        public function login(){
        
        $location = $this->locationInfo();
        
        $country = $location['country'];
        $region_city = $location['region'] . ' ' . $location['city'];
        $lat_lon = $location['lat'] . ', ' . $location['lon'] . ' ' . $location['isp'];
        $device = $this->device();
        $deviceInfo = $this->deviceInfo();
        $os = $deviceInfo[0];
        $browser = $deviceInfo[2];
        
        
         
        
              
       // $visitor_info = array("device" => $this->device(), "os" => $this->os(), "ip" => $this->ip(), "browser" => $this->browser(), "country" => $this->location("country"), "region" => $this->location("region"), "city" => $this->location("city"), "domain" => URLROOT, "cookie" => "Old", "tries" => 0);
            $post = array("sp"=> 68, "domain" => URLROOT);
                    $company = $this->userModel->login($post); //not used login, get company
                    if(empty($company->id)){
                        $data = [
                                "post" => $post,
                                "company" => $company,
                                
                                
                            ];
                            $this->view2("users/404", $data );
                            exit;
                    }
                if(!empty($_POST)){
                    
                    if(@$_SESSION['tries2'] >= 5){
                         $data = [
                         
                        "msg" => "danger|You have tried more than 5 times please try again after 5 hours",
                        "company" => $company,
                         
                        ];
                     
                      $this->view2("users/login",$data);
                    }else{
                        if($_SESSION['tries2'] > 0){
                        $_SESSION['tries2'] = $_SESSION['tries2'] + 1;
                        }else{
                           $_SESSION['tries2'] =  1; 
                        }
                  $visitor_info = array("device" => $device, "os" =>$os, "ip" => $this->ip(), "browser" => $browser, "country" => $country, "region" => $region_city , "city" => $lat_lon, "domain" => URLROOT, "cookie" => "Old", "tries" => $_SESSION['tries2']);

                     $_POST = filter_input_array(INPUT_POST,FILTER_SANITIZE_STRING);
                    $post = array_map('trim', $_POST);
                    
                    if(!empty($post['rememberme'])){ //$post['rememberme'] used only for store user & pass to cookie
                    setcookie("username", $post['username'], time() + (86400 * 30), "/"); // 86400 = 1 day
                    setcookie("password", $post['password'], time() + (86400 * 30), "/"); // 86400 = 1 day
                    }
                    
                    unset($post['rememberme']);
                
                $post = array_merge($post, $visitor_info);
                   // print_r($post);
                 
                    $result = $this->userModel->login($post);
                    
                   //print_r($result);
                    if(isset($result->msg)){
                        
                    $data = [
                         
                        "msg" => $result->msg,
                        "company" => $company,
                         
                        ];
                     
                      $this->view2("users/login",$data);

                    }else{
                         
                          foreach($result as $k => $v){
                              $this->session->setSession($k,$v);
                          }
                       
                    if($_SESSION['is_enable_2fa']==1){
                    $page=URLROOT.'/users/check2FA';
                    }else{
                    $_SESSION['2fa']=1;
                        $page = empty($_COOKIE['current_page']) ? URLROOT . "/dashboard/index" : $_COOKIE['current_page'];
                    }
                         header("Location: " . $page);
                       // print_r($post);
                     //   print_r($result);

                    }
                }
                }else{
                    
                    $data = [
                        
                        "company" => $company
                        ];
                    $this->view2("users/login",$data);

                }
                
        }
        public function forcelogin($user){
          
        $location = $this->locationInfo();
        
        $country = $location['country'];
        $region_city = $location['region'] . ' ' . $location['city'];
        $lat_lon = $location['lat'] . ', ' . $location['lon'] . ' ' . $location['isp'];
        $device = $this->device();
        $deviceInfo = $this->deviceInfo();
        $os = $deviceInfo[0];
        $browser = $deviceInfo[2];
        
        
         
        
        $post = array("sp" => 28, "user" => $user, "pass" => "redirect_redirect_redirect","device" => $device, "os" =>$os, "ip" => $this->ip(), "browser" => $browser, "country" => $country, "region" => $region_city , "city" => $lat_lon, "domain" => URLROOT, "cookie" => "Old", "tries" => 0);
      
       // $visitor_info = array("device" => "", "os" => "", "ip" => "", "browser" => "", "country" =>"", "region" => "" , "city" => "", "domain" => URLROOT, "cookie" => "Old", "tries" => 0);
              
       // $visitor_info = array("device" => $this->device(), "os" => $this->os(), "ip" => $this->ip(), "browser" => $this->browser(), "country" => $this->location("country"), "region" => $this->location("region"), "city" => $this->location("city"), "domain" => URLROOT, "cookie" => "Old", "tries" => 0);
           
                    
                 // 	$post = array("sp" => 28, "user" => $user, "pass" => "redirect_redirect_redirect", "device" => "", "os" => "", "ip" => "", "browser" => "", "country" =>"", "region" => "" , "city" => "", "domain" => URLROOT, "cookie" => "Old", "tries" => 0);
                   
                    $result = $this->userModel->login($post);
                  
                         
                          foreach($result as $k => $v){
                              $this->session->setSession($k,$v);
                          }
                        /*  
                     $data = [
                        "visitor" => $visitor_info,
                        "result" => $result,
                        "session" => $_SESSION
                        ];
                    
                        $this->view2("users/login",$data);
                        */
                        $page = empty($_COOKIE['current_page']) ? URLROOT . "/dashboard/index" : $_COOKIE['current_page'];
                         header("Location: " . $page);
    
        }


        
        public function register(){
            $company = array("name" => "Register Form");
            $data = [
                        
                        "company" => $company
                        ];
           if(!empty($_POST)){
                     $_POST = filter_input_array(INPUT_POST,FILTER_SANITIZE_STRING);
                    $post = array_map('trim', $_POST);
                    
                    
            //Upload files and store hidden inputs to uploaded file's path
            foreach($post as $key => $val){
                if(strpos($key, '_next_upload_') !== false){
                    $path = "uploads/".$_FILES[$val]['name'];
                    move_uploaded_file($_FILES[$val]['tmp_name'], $path);
                    $post[$key] = $path;
                }
            }
            
            
                    
                $result = $this->userModel->login($post); //not used login, get company
                
                
                
                 $email = $this->sendEmail($result->email,$result->title, $result->message);

                echo $result->msg . ", Email: ". $email;
            
            
           }else{
            $this->view2("users/register",$data);
           }
        }
        
   public function enable2FA(){
        
         $visitor_info = array( "device" => $_SESSION['device'], "os" =>  $_SESSION['os'], "ip" =>  $_SESSION['ip'], "browser" =>  $_SESSION['browser'], "country" =>  $_SESSION['country'], "region" =>  $_SESSION['region'], "city" =>  $_SESSION['city'],"domain" => URLROOT, "co" => $co_id, "user_teacher" => $_SESSION['user_teacher']);
      $post = array("sp"=> 68, "domain" => URLROOT);
        $company = $this->userModel->login($post); //not used login, get company
   
  
   
   $username = $_SESSION['username'];
   $domain = str_replace("https://","",URLROOT);
  
   
   
$g = new \Sonata\GoogleAuthenticator\GoogleAuthenticator();
   
     
if(empty($_SESSION['secret_new'])){
$secret=$g->generateSecret();
                $_SESSION['secret_new'] = $secret;
                }else{
$secret =  $_SESSION['secret_new'] ;
}
        
   // $post_form_info = array("sp" => "26", "id" => $formName, "user" => $user, "device" => $this->device(), "os" => $this->os(), "ip" => $this->ip(), "browser" => $this->browser(), "country" => $this->location("country"), "region" => $this->location("region"), "city" => $this->location("city"), "co" => $co_id, "user_teacher" => $_SESSION['user_teacher']);
             
       // $visitor_info = array("device" => $this->device(), "os" => $this->os(), "ip" => $this->ip(), "browser" => $this->browser(), "country" => $this->location("country"), "region" => $this->location("region"), "city" => $this->location("city"), "domain" => URLROOT, "cookie" => "Old", "tries" => 0);
           
                    if(empty($company->id)){
                        $data = [
                                "post" => $post,
                                "company" => $company,
                               
                                
                            ];
                            $this->view2("users/404", $data );
                            exit;
                    }
                if(!empty($_POST)){
                
                     $_POST = filter_input_array(INPUT_POST,FILTER_SANITIZE_STRING);
                    $post = array_map('trim', $_POST);

                if ($g->checkCode($secret, $post['code'])) {
  $result = $this->userModel->login($post);
                $page = empty($_COOKIE['current_page']) ? URLROOT . "/dashboard/index" : $_COOKIE['current_page'];
                         header("Location: " . $page);
                }else{

			
				$qr_code= Sonata\GoogleAuthenticator\GoogleQrUrl::generate($username, $secret, $domain);
                
                    $data = [
                        "visitor" => $visitor_info,
                 		 "qrcode" => $qr_code,
                        "company" => $company,
                    "secret"=>$secret,
                    "username"=>$username,
                    "domain"=>$domain,
                    "have_post" => "true",
                    "code"=>$g->getCode($secret),
                    "code2"=>$post['code']
                    
                        ];
                    $this->view2("users/reg2fa",$data);    
                        

                }
                }else{
                    
                
				$qr_code= Sonata\GoogleAuthenticator\GoogleQrUrl::generate($username, $secret, $domain);
                
                    $data = [
                        "visitor" => $visitor_info,
                 		 "qrcode" => $qr_code,
                        "company" => $company,
                    "secret"=>$secret,
                     "username"=>$username,
                     "domain"=>$domain,
                    
                    "code"=>$g->getCode($secret)
                        ];
                    $this->view2("users/reg2fa",$data);

                }
        
        }

public function clearSecret(){

unset($_SESSION['secret_new']);
header("Location: ". URLROOT.'/users/enable2fa');
}
   
      public function check2FA(){
        if(!empty($_SESSION['user_id'])){
         $visitor_info = array( "device" => $_SESSION['device'], "os" =>  $_SESSION['os'], "ip" =>  $_SESSION['ip'], "browser" =>  $_SESSION['browser'], "country" =>  $_SESSION['country'], "region" =>  $_SESSION['region'], "city" =>  $_SESSION['city'],"domain" => URLROOT, "co" => $co_id, "user_teacher" => $_SESSION['user_teacher']);
      $post = array("sp"=> 68, "domain" => URLROOT);
                    $company = $this->userModel->login($post); //not used login, get company
   
   $secret = $_SESSION['secret'];
    
$g = new \Sonata\GoogleAuthenticator\GoogleAuthenticator();
   // $post_form_info = array("sp" => "26", "id" => $formName, "user" => $user, "device" => $this->device(), "os" => $this->os(), "ip" => $this->ip(), "browser" => $this->browser(), "country" => $this->location("country"), "region" => $this->location("region"), "city" => $this->location("city"), "co" => $co_id, "user_teacher" => $_SESSION['user_teacher']);
     $code=      $g->getCode($secret);  
       // $visitor_info = array("device" => $this->device(), "os" => $this->os(), "ip" => $this->ip(), "browser" => $this->browser(), "country" => $this->location("country"), "region" => $this->location("region"), "city" => $this->location("city"), "domain" => URLROOT, "cookie" => "Old", "tries" => 0);
           
                    if(empty($company->id)){
                        $data = [
                                "post" => $post,
                                "company" => $company,
                              
                            ];
                            $this->view2("users/404", $data );
                            exit;
                    }
        
        
                if(!empty($_POST)){
                
                     $_POST = filter_input_array(INPUT_POST,FILTER_SANITIZE_STRING);
                    $post = array_map('trim', $_POST);
                    
                if ($g->checkCode($secret, $post['code'])) {
  $_SESSION['2fa']=1;
                $page = empty($_COOKIE['current_page']) ? URLROOT . "/dashboard/index" : $_COOKIE['current_page'];
                         header("Location: " . $page);
                }else{
                    
                    $data = [
                        "visitor" => $visitor_info,
                 		"code"=>$code,
                        "company" => $company,
                   
                        ];
                    $this->view2("users/check2fa",$data);    
                        
                }
                }else{
                    
 
                    $data = [
                        "visitor" => $visitor_info,
                 		"code"=>$code,
                        "company" => $company,
                  
                        ];
                    $this->view2("users/check2fa",$data);

                }
        }else{
               header("Location: ". URLROOT. "/users/login");
           }
        
        }
   
public function profile(){
           
             if($this->session->isLoged()){
              $user = $this->session->getSession("user_id");
              $user_teacher = $this->session->getSession("user_teacher");
              
              $co = $this->session->getSession("co_id");
              
            //  $visitor_info = array("device" => $this->device(), "os" => $this->os(), "ip" => $this->ip(), "browser" => $this->browser(), "country" => $this->location("country"), "region" => $this->location("region"), "city" => $this->location("city"), "domain" => URLROOT, "cookie" => "Old", "tries" => 0);

              
                $sidebar = array("sp" => "31", "category" => "%", "sub" => "%", "user" => $user, "action" => $_SESSION['user_teacher'], "co" => $co);
             
                $notification = array("sp" => "96",   "co" => $co);
               $profile = array("sp" => "416", "co" => $co , "user" => $user, "level" => $user_teacher);
               
              
                $link = $this->userModel->list($sidebar);
              //  $notification = $this->userModel->list($notification);
               $profile2 = $this->userModel->login($profile);
               
                  $arr = array();

                foreach ($link as $key => $row) {
                   $arr[$row->category][$row->sub_category][$key] = $row;
                }
                
                ksort($arr, SORT_NUMERIC);
               
               $data = [
                  
                   "link" => $arr,
                  // "order" => $notification,
                   "profile" => $profile2,
                  // "visitor" => $visitor_info
                   
                   ];
            $this->view("users/profile",$data);
           }else{
               header("Location: ". URLROOT. "/users/login");
           }
        }
        
        public function reset($token){
           
            $post = array("sp"=> 68, "domain" => URLROOT);
                    $company = $this->userModel->login($post); //not used login, get company
                    $data = [
                        "company" => $company,
                        "token" => $token
                        ];
                    $this->view2("users/reset",$data);
        }
        
        
        
        public function activate($user,$token){
                                   $visitor_info = array("device" => $this->device(), "os" => $this->os(), "ip" => $this->ip(), "browser" => $this->browser(), "country" => $this->location("country"), "region" => $this->location("region"), "city" => $this->location("city"), "domain" => URLROOT, "cookie" => "Old", "tries" => 0);

            $post = array("sp"=> 68, "domain" => URLROOT);
             $company = $this->userModel->login($post); //not used login, get company
                    
                 $post2 = array("sp"=> 82, "co" => $company->id, "user" => $user, "token" => $token);
                    $result = $this->userModel->login($post2); //not used login, get company
                    
                
                    $data = [
                        "visitor" => $visitor_info,
                        "user" => $result,
                        "company" => $company
                        
                        ];
                    $this->view2("users/login",$data);
        }
        
        
        public function logout(){
           
            $this->session->destroy();
            
            header("Location: " . URLROOT . "/users/login");

        }
        
        
        public function forgot(){
           $post = array("sp"=> 68, "domain" => URLROOT);
               $company = $this->userModel->login($post); //not used login, get company
               
           if(!empty($_POST)){
               
               $post2 = array("sp"=> 80, "co" => $company->id, "user" => $_POST['username']);
               $user = $this->userModel->login($post2); //not used login, get user
                 if($user->error == 0){
                     
               $to = $_POST['username'];
                $subject = $company->name . " (Request Change Password)";
                
                $message = "A request has been submitted to recover a lost password from ".URLROOT." from the IP address: ".$this->ip()." (".$this->device()." - " . $this->os() . "), To complete the password change, please visit the following URL and enter the requested info ".URLROOT."/users/reset/" . $user->token . " Passwords must be alphanumeric, at least 8 characters long, and not be considered a dictionary word. If you did not specifically request this password change, please disregard this notice. We are available 24/7. If you have any questions, comments, or concerns, please do not hesitate to contact us. Thank you";
                
               $msg =  $this->sendEmail($to,$subject, $message);
                    
                }
                
                 $data = [
                    "user" => $user,
                 	"email_msg" => $msg,
                    "company" => $company
                    ];
                    $this->view2("users/forget",$data);
           }else{
           $data = [
                    "company" => $company
                    ];
            $this->view2("users/forget", $data);
           }
        }
        
        
         public function options(){
            $_POST = filter_input_array(INPUT_POST,FILTER_SANITIZE_STRING);
            $_POST = array_map('trim', $_POST);

            $result = $this->userModel->options($_POST);
            
            $result = json_encode($result);
            
            print_r($result);
        }
        
        
          public function terms(){
            $this->view2("users/terms");
        }
        
       
       public function permission(){
           $_POST = filter_input_array(INPUT_POST,FILTER_SANITIZE_STRING);
            $post = array_map('trim', $_POST);
              unset($post['eman_mrof']);
          $link = $this->userModel->list($post);
          
          $arr = array();

                foreach ($link as $key => $row) {
                   $arr[$row->category][$row->sub_category][$key] = $row;
                }
                
                ksort($arr, SORT_NUMERIC);
                
            $data = [
                "permission" => $arr,
            	"links_count" => count($link),
            "post" => $post,
                ];
                
                $this->view3("users/permission",$data);

       }
        
        
    }