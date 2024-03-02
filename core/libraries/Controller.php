<?php
    class Controller{
          public function __construct()
             {	
        	 
             $this->model = new Model();		
             $this->session = new Session();	
           
        	}
        	
        public function model($model){
            require_once '../app/models/' . $model. '.php';
            return new $model;
        }
        
        public function view($view, $data = []){
            if(file_exists('../app/views/' . $view . '.php')){
                
                require_once '../app/views/layout/sidebar.php';
                require_once '../app/views/' . $view . '.php';
                require_once '../app/views/layout/script.php';
                
            }else{
                die('../app/views/' . $view . '.php - not found');
            }
        }
        
        public function view2($view, $data = []){
            if(file_exists('../app/views/' . $view . '.php')){
                require_once '../app/views/layout/head.php';
                require_once '../app/views/' . $view . '.php';
                require_once '../app/views/layout/script.php';
                
            }else{
                die('../app/views/' . $view . '.php  - not found');
            }
        }
        
        public function view4($view, $data = []){
            if(file_exists('../app/views/' . $view . '.php')){
                
                require_once '../app/views/layout/bs.php';

                require_once '../app/views/' . $view . '.php';
                require_once '../app/views/layout/sc.php';
                
            }else{
                die('../app/views/' . $view . '.php  - not found');
            }
        }
        
        public function view3($view, $data = []){
            if(file_exists('../app/views/' . $view . '.php')){
                
                require_once '../app/views/' . $view . '.php';

            }else{
                die('../app/views/' . $view . '.php  - not found');
            }
        }

 public function portalView($view, $data = []){
            if(file_exists('../app/views/' . $view . '.php')){
                
                require_once '../app/views/layout/app_head.php';
                require_once '../app/views/' . $view . '.php';
                require_once '../app/views/layout/app_script.php';
                
            }else{
                die('../app/views/' . $view . '.php  - not found');
            }
        }
        
        
        public function ip(){
            	return $_SERVER['REMOTE_ADDR'];
            }
            
         public function os()
             {
                $user_agent = $_SERVER['HTTP_USER_AGENT'];
                $os_platform    = "Unknown OS Platform";
                $os_array       = array('/windows phone 8/i'    =>  'Windows Phone 8',
                                        '/windows phone os 7/i' =>  'Windows Phone 7',
                                        '/windows nt 6.3/i'     =>  'Windows 8.1',
                                        '/windows nt 10.0/i'     =>  'Windows 10',
                                        
                                        '/windows nt 6.2/i'     =>  'Windows 8',
                                        '/windows nt 6.1/i'     =>  'Windows 7',
                                        '/windows nt 6.0/i'     =>  'Windows Vista',
                                        '/windows nt 5.2/i'     =>  'Windows Server 2003/XP x64',
                                        '/windows nt 5.1/i'     =>  'Windows XP',
                                        '/windows xp/i'         =>  'Windows XP',
                                        '/windows nt 5.0/i'     =>  'Windows 2000',
                                        '/windows me/i'         =>  'Windows ME',
                                        '/win98/i'              =>  'Windows 98',
                                        '/win95/i'              =>  'Windows 95',
                                        '/win16/i'              =>  'Windows 3.11',
                                        '/macintosh|mac os x/i' =>  'Mac OS X',
                                        '/mac_powerpc/i'        =>  'Mac OS 9',
                                        '/linux/i'              =>  'Linux',
                                        '/ubuntu/i'             =>  'Ubuntu',
                                        '/iphone/i'             =>  'iPhone',
                                        '/ipod/i'               =>  'iPod',
                                        '/ipad/i'               =>  'iPad',
                                        '/android/i'            =>  'Android',
                                        '/blackberry/i'         =>  'BlackBerry',
                                        '/webos/i'              =>  'Mobile');
                $found = false;
                
                $device = '';
                foreach ($os_array as $regex => $value) 
                { 
                    if($found)
                     break;
                    else if (preg_match($regex, $user_agent)) 
                    {
                        $os_platform    =   $value;
                        $device = !preg_match('/(windows|mac|linux|ubuntu)/i',$os_platform)
                                  ?'MOBILE':(preg_match('/phone/i', $os_platform)?'MOBILE':'SYSTEM');
                    }
                }
               
                return $os_platform ;
             }

            public function browser() 
                 {
                    $user_agent = $_SERVER['HTTP_USER_AGENT'];
                
                    $browser        =   "Unknown Browser";
                
                    $browser_array  = array('/msie/i'       =>  'Internet Explorer',
                                            '/firefox/i'    =>  'Firefox',
                                            '/safari/i'     =>  'Safari',
                                            '/chrome/i'     =>  'Chrome',
                                            '/opera/i'      =>  'Opera',
                                            '/netscape/i'   =>  'Netscape',
                                            '/maxthon/i'    =>  'Maxthon',
                                            '/konqueror/i'  =>  'Konqueror',
                                            '/mobile/i'     =>  'Handheld Browser');
                
                    foreach ($browser_array as $regex => $value) 
                    { 
                        if (preg_match($regex, $user_agent,$result)) 
                        {
                            $browser    =   $value;
                        }
                    }
                    return $browser;
                 }
                 
           public function device(){
            	 $useragent=$_SERVER['HTTP_USER_AGENT'];
            
            if(preg_match('/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i',$useragent)||preg_match('/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i',substr($useragent,0,4))){
            
            return "Mobile";
            }else{
            	return "Computer";
            }
            }

	 public  function locationInfo(){
                     $ip = $_SERVER['REMOTE_ADDR']; 
                $query = @unserialize(file_get_contents('http://ip-api.com/php/'.$ip));
     return $query;
     }
	 public  function deviceInfo(){
                       
                $useragent= explode( ")", $_SERVER['HTTP_USER_AGENT']);
     return $useragent;
     }


         public  function location($action){
                     $ip = $_SERVER['REMOTE_ADDR']; 
                     $location = "Unknown";
                $query = @unserialize(file_get_contents('http://ip-api.com/php/'.$ip));
                if($query && $query['status'] == 'success') {
                    if($action == "isp"){
                  $location = $query['isp'];
                    }
                    else if($action == "country"){
                  $location = $query['country'];
                    }
                    else if($action == "lat"){
                  $location = $query['lat'];
                    }
                    else if($action == "lon"){
                  $location = $query['lon'];
                    }
                
                
                    else if($action == "region"){
                  $location = $query['region'];
                    }
                    else if($action == "city"){
                  $location = $query['city'];
                    }else if($action == "ip"){
                  $location = $ip;
                    }else{
                        $location = "Unavailabel";
                    }
                  
                } 
                return $location;
                 }

             
        public function sendEmail($to,$subject, $message){
            //Sending email

if(mail($to, $subject, $message)) {

return "Your mail has been sent successfully.";

} else{

return "Unable to send email. Please try again.";

}
        }
        
        public function sendSms($tell, $sms){
            $mobile = "0$tell";
     $message = $sms;   
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
    return  $output;
 
     }
        
        public function sendWhatsApp($tell,$sms){
            $INSTANCE_ID = '20';  // TODO: Replace it with your gateway instance ID here
            $CLIENT_ID = "bulshotech1@gmail.com";  // TODO: Replace it with your Forever Green client ID here
            $CLIENT_SECRET = "60f3984253ab4188855bcbbc8805139d";   // TODO: Replace it with your Forever Green client secret here
            
            $postData = array(
              'number' => $tell,  // TODO: Specify the recipient's number here. NOT the gateway number
              'message' => $sms
            );
            
            $headers = array(
              'Content-Type: application/json',
              'X-WM-CLIENT-ID: '.$CLIENT_ID,
              'X-WM-CLIENT-SECRET: '.$CLIENT_SECRET
            );
            
            $url = 'http://api.whatsmate.net/v3/whatsapp/single/text/message/' . $INSTANCE_ID;
            $ch = curl_init($url);
            
            curl_setopt($ch, CURLOPT_POST, 1);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($postData));
            
            $response = curl_exec($ch);
            
            return "Response: ".$response;
            curl_close($ch);
        }
        
        public function sendWhatsApp2($tell,$sms){
          
          
            $url = "https://wasniper.com/api/send.php?number=$tell&type=text&message=$sms&instance_id=61FC08DB3E742&access_token=841ffeeb91e6ad91603966d324b65675";

            $curl = curl_init($url);
            curl_setopt($curl, CURLOPT_URL, $url);
            curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
            
            //for debug only!
            curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, false);
            curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
            
            $resp = curl_exec($curl);
            curl_close($curl);
            return "response: ". $resp . $url;
        }
        
        public function shortUrl($long_url){

             $apiv4 = 'https://api-ssl.bitly.com/v4/bitlinks';
            $genericAccessToken = '3863efaeebb136fc0041aeafb386b5d627da115b';
            
            $data = array(
                'long_url' => $long_url
            );
            $payload = json_encode($data);
            
            $header = array(
                'Authorization: Bearer ' . $genericAccessToken,
                'Content-Type: application/json',
                'Content-Length: ' . strlen($payload)
            );
            
            $ch = curl_init($apiv4);
            curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST");
            curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_HTTPHEADER, $header);
            $result = curl_exec($ch);
            
            $url = json_decode($result);
            return $url->link;
        }
        
        
       public  function getRandomStringRand($length = 16)
            {
                $stringSpace = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
                $stringLength = strlen($stringSpace);
                $randomString = '';
                for ($i = 0; $i < $length; $i ++) {
                    $randomString = $randomString . $stringSpace[rand(0, $stringLength - 1)];
                }
                return $randomString;
            }
        
    }