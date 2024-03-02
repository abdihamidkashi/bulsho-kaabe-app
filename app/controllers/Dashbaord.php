<?php
    class Dashbaord extends Controller{
        
        public function __construct(){
            parent::__construct();
            $this->dashboarModel = $this->model("Dashboard");
        }
        
        public function index(){
           if($this->session->isLoged()){
              $user = $this->session->getSession("user_id");
              $co = $this->session->getSession("co_id");
              
              $sidebar = array("sp" => "31", "category" => "%", "sub" => "%", "user" => $user, "action" => $_SESSION['user_teacher'], "co" => $co);
               $chart = array("sp" => "36", "user" => $user, "action" => $_SESSION['user_teacher'],  "co" => $co);
               
                $notification = array("sp" => "96",   "co" => $co);

                $link = $this->dashboarModel->list($sidebar);
                $chart = $this->dashboarModel->list($chart);
               // $notification = $this->dashboarModel->list($notification);
               
                  $arr = array();

                foreach ($link as $key => $row) {
                   $arr[$row->category][$row->sub_category][$key] = $row;
                }
                
                ksort($arr, SORT_NUMERIC);
               
               $data = [
                  
                   "link" => $arr,
                   "chart" => $chart,
                   "order" => $notification,
                   
                   
                   ];
            $this->view("index",$data);
           }else{
              
               header("Location: ". URLROOT. "/users/login");
               
           }
        }
        
       
        public function theme($theme){
			setcookie("theme", $theme, time() + (86400 * 30), "/"); // 86400 = 1 day
			
       // echo $_COOKIE['theme'] . " seted";
		}


	public function dhaweeye($payments){
 		    
 		    $p = explode("!!!", $payments);
 		    
 		   // 165!!!123!!!0.1!!!123!!!50!!!615190777!!!333!!!12-02-2022  sample data
 		    
 		    $post = array("sp" => $p[0],  $p[1], $p[2], $p[3], $p[4], $p[5]);
 		     	   $result = $this->dashboarModel->add($post);
            
             print_r($post);
    
       
    
    
             print_r($result);
    
            
 		}
 		
 		public function testsms(){
 		    $key= "WKAvixd3ArXPG3Jg3LdoTk46U4SsfqH3";
            $username = "USERNAME_29n0vq2W";
            $password = "PASSWORD_lJ0XHmIp";
            $senderId = "Bulshokaab";
            
            $url ="https://sms.mytelesom.com/index.php/Gway/sendsms";
            
            $sms = "Asc Mohamed, fariintan waxay ka timid API TELESOM";
            $message = str_ireplace(" ", "%20", $sms);
            $to = "252634432380";
            
             $date = date("d/M/Y");
             
		echo $postdata = "hashkey=". $username . "|" . $password . "|" . $to . "|" . $message . "|" . $senderId . "|" . $date . "|" . $key;

/*
		$ch = curl_init($url);
		curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 0);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0);
		curl_setopt($ch, CURLOPT_POST, 1);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $postdata);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);

		$result = curl_exec($ch);
		curl_close($ch);
		echo $result;
      */      

 		}
 		
 		public function sendsms() {
             
     $mobile = "0634432380";
     $message = "Asc Mohamed, fariintan waxay ka timid API TELESOM Abdihamid";   
     $username = "USERNAME_29n0vq2W";
     $passowrd = "PASSWORD_lJ0XHmIp";
     $from = "Bulshokaab";
     $curentDate = date("d/m/Y");
     $key = "WKAvixd3ArXPG3Jg3LdoTk46U4SsfqH3";
    $message = str_ireplace(" ", "%20", $message);
    $msg = ($username . "|" . $passowrd . "|" . $mobile . "|" . $message . "|" . $from . "|" . $curentDate . "|" . $key);
    
    $hashkey = strtoupper(md5($username . "|" . $passowrd . "|" . $mobile . "|" . $message . "|" . $from . "|" . $curentDate . "|" . $key));
    
    
  //var_dump($hashkey);die;
    
  
    $fields = ['from' => $from, 'to' => $mobile, 'msg' => $message, 'key' => $hashkey  ];
    $postdata = http_build_query($fields);
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, 'https://sms.mytelesom.com/index.php/Gway/sendsms');
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $postdata);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
 $output = curl_exec($ch);
    //var_dump($hashkey);
   echo  $output;
  }


 		public function sendsms2() {
        
 		     $mobile = "634432380";
     $message = "Asc Mohamed, fariintan waxay ka timid API TELESOM Abdihamid2";   
     echo $this->sendSms($mobile, $message);
 		}
		  
        
    }