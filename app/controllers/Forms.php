<?php
	class Forms extends Controller{

		public function __construct(){
          parent::__construct();
        	$this->formModel = $this->model("Form");
        
        }
    
     public function create($formName){
     if($this->session->isLoged()){
        $user = $this->session->getSession("user_id");
        $co_id = $this->session->getSession("co_id");
        $co = $this->session->getSession("co_id");
        
        $checkArray = explode("~",$formName);
        $fill_form2 = array();
        if(is_array($checkArray) && count($checkArray) > 1 ){
           $formName = "forms/create/".$checkArray[0]; 
            
        $fill_form = array("sp" => "21", "id" => $checkArray[2], "action" => $checkArray[1], "user" => $user,  "co" => $co);
        
        $fill_form2 = $this->formModel->callProcDQL($fill_form,"fetch");

        }else{
          $formName = "forms/create/".$formName;  
        }
        
  		
        
        $post_form_info = array("sp" => "26", "id" => $formName, "user" => $user, "device" => $_SESSION['device'], "os" =>  $_SESSION['os'], "ip" =>  $_SESSION['ip'], "browser" =>  $_SESSION['browser'], "country" =>  $_SESSION['country'], "region" =>  $_SESSION['region'], "city" =>  $_SESSION['city'], "co" => $co_id, "user_teacher" => $_SESSION['user_teacher']);
       // $post_form_info = array("sp" => "26", "id" => $formName, "user" => $user, "device" => $this->device(), "os" => $this->os(), "ip" => $this->ip(), "browser" => $this->browser(), "country" => $this->location("country"), "region" => $this->location("region"), "city" => $this->location("city"), "co" => $co_id, "user_teacher" => $_SESSION['user_teacher']);
       
     $post_form_inputs = array("sp" => "18", "id" => $formName, "user" => $user,  "co" => $co_id);
        $post_sidebar = array("sp" => "31", "category" => "%", "sub" => "%", "user" => $user, "action" => $_SESSION['user_teacher'], "co" => $co_id);

               
               
     	$formInfo = $this->formModel->formInfo($post_form_info);
    	$formInputs = $this->formModel->formInputs($post_form_inputs);
      	$link = $this->formModel->getSidebar($post_sidebar);
       	  
      //	 $visitor_info = array("device" => $this->device(), "os" => $this->os(), "ip" => $this->ip(), "browser" => $this->browser(), "country" => $this->location("country"), "region" => $this->location("region"), "city" => $this->location("city"), "domain" => URLROOT, "cookie" => "Old", "tries" => 0);


 #lables list query for developer quickly update
       $lables = array('sp' => "43", "co" => $co, "cat" => "quick-for-devloper", "sub" => "%", "link" => $formName, "par" => "" );

            $lbl_result = $this->formModel->callProcDQL($lables);
            $lbl_columns = $this->formModel->callProcDQL($lables ,"columns");
            
            
     $arr = array();

                foreach ($link as $key => $row) {
                   $arr[$row->category][$row->sub_category][$key] = $row;
                }
                
                ksort($arr, SORT_NUMERIC);

   		 $data = [

           	 "form" => $formInfo,
           	 "input" => $formInputs,
                "link" => $arr,
            //   "visitor" => $visitor_info,
            //    "order" => $notification,
                "fill" => $fill_form2,
                	"lbl_result" => $lbl_result,
         		"lbl_columns" => $lbl_columns,
         	"lbl_post" => $lables,
    "formname2" => $formName
   		 ];


     			$this->view('forms/ktc_gvf',$data);
     }else{
             header("Location: " . URLROOT . "/users/login");
     }
 		}
    
    
    public function save(){
    	
    		if($this->session->isLoged()){
    		    if(empty($_POST)){
    		         header("Location: " . URLROOT);
    		    }
    		    
    		     $user = $this->session->getSession("user_id");
        $co_id = $this->session->getSession("co_id");
        
        $_POST['di_resu'] =  $user;
        $_POST['di_oc'] =  $co_id;
        
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
            }else{
    		echo $result->msg ;
            }
            
            }else{
             echo 'warning|Waxaad system-ka ka maqneyd waqti badan fadlan <a href="'.URLROOT.'/users/login">dib usoo gal</a> si loo fuliyo howshan';
     }
    	
    }
   
    public function save2(){
    	
    		if($this->session->isLoged()){
    		    if(empty($_POST)){
    		         header("Location: " . URLROOT);
    		    }
    		    
    		     $user = $this->session->getSession("user_id");
        $co_id = $this->session->getSession("co_id");
        
      
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
            
            }else{
             echo 'warning|Waxaad system-ka ka maqneyd waqti badan fadlan <a href="'.URLROOT.'/users/login">dib usoo gal</a> si loo fuliyo howshan';
     }
    	
    }
    
    
    
     public function update(){
    	
    		$_POST = filter_input_array(INPUT_POST,FILTER_SANITIZE_STRING);
            $post = array_map('trim', $_POST);
            
               unset($post['t']);
               
            $result = $this->formModel->getRow($post);
            $sql = $this->formModel->getRow($post, "sql");

			$data  = [
			        "row" => $result,
			        "sql" => $sql
			    ];
			    
			    $this->view3("forms/ktc_guf",$data);
    }
    
    
           


public function options($action = "dropdown", $default = "", $name = "chrd"){
            $_POST = filter_input_array(INPUT_POST,FILTER_SANITIZE_STRING);
            $_POST = array_map('trim', $_POST);

            $result = $this->formModel->callProcDQL($_POST, "index");
             $selected = "";
            if($action == "dropdown"){
               
            $i=0;
            foreach($result as $r){
            $r1 = explode("|",$r[1]); //extract display value using | symbol
            $r[1] = $r1[0];
            $i++;
                if(str_replace(' ', '', $r[0]) == str_replace(' ', '',$default) || @$r1[1] == "selected"){
                    $selected = "selected";
                } 
                else{
                     $selected = "";
                }
					echo '<option   value="'.$r[0].'" '. $selected. '  >'.$r[1]. '</option>';
           		 }
            }else if($action == "radio"){
           		 $item = 0;
           		 foreach($result as $r){
                 $item++;
					if($item == 1 ){
                	 $selected = "checked";
                }else{
                  $selected = "";
                    }
					echo '<input '. $selected ,' name="'.$name.'" type="radio" id="r'.$item.'" value="'.$r[0].'"  /> <label for="r'.$item.'">'.$r[1].'</label> &nbsp;';
           		 }
            }else if($action == "checkbox"){
            $item = 0;
           		 foreach($result as $r){
                 $item++;
          
               if($item == 1 ){
                	 $selected = "checked";
                }else{
                  $selected = "";
                    }
					echo ' <label for="r'.$item.'"><input '. $selected ,' name="'.$name.'[]" type="checkbox" id="r'.$item.'" value="'.$r[0].'"  /> '.$r[1].'</label> &nbsp;';
           		 }
            }else if($action == "autocomplete") {
            	foreach($result as $r){
             		echo '<li class="list-group-item ktc-autocomplete-item"  value="'.$r[0].'">'.$r[1].'</li>'; 
           		 }
            	
            }

 
        }

public function options2($action, $id){
            
$post = array("sp" => 20, "action" => $action, "id" => $id, "user" => $_SESSION['user_id'], "co" => $_SESSION['co_id']);

            $result = $this->formModel->callProcDQL($post);
            
$arr = array_map('utf8_encode', $result);

            $result2 = json_encode($arr);
            

            echo $result2;
print_r($result);
            print_r($post);

        }


    
    public function display(){
            $_POST = filter_input_array(INPUT_POST,FILTER_SANITIZE_STRING);
            $_POST = array_map('trim', $_POST);

            $result = $this->formModel->callProcDQL($_POST);
            
          
        }
    
    
    public function list($formName){
      if($this->session->isLoged()){
        $user = $this->session->getSession("user_id");
        $co_id = $this->session->getSession("co_id");
        $co = $this->session->getSession("co_id");
        $originalFormname = $formName;
  		$formName = "forms/list/".$formName;
  		
  		//$visitor_info = array("device" => $this->device(), "os" => $this->os(), "ip" => $this->ip(), "browser" => $this->browser(), "country" => $this->location("country"), "region" => $this->location("region"), "city" => $this->location("city"), "domain" => URLROOT, "cookie" => "Old", "tries" => 0);
        
        $post_form_info = array("sp" => "26", "id" => $formName, "user" => $user, "device" => $_SESSION['device'], "os" =>  $_SESSION['os'], "ip" =>  $_SESSION['ip'], "browser" =>  $_SESSION['browser'], "country" =>  $_SESSION['country'], "region" =>  $_SESSION['region'], "city" =>  $_SESSION['city'], "co" => $co_id, "user_teacher" => $_SESSION['user_teacher']);
       // $post_form_info = array("sp" => "26", "id" => $formName, "user" => $user, "device" => $this->device(), "os" => $this->os(), "ip" => $this->ip(), "browser" => $this->browser(), "country" => $this->location("country"), "region" => $this->location("region"), "city" => $this->location("city"), "co" => $co_id, "user_teacher" => $_SESSION['user_teacher']);
       
      $post_form_inputs = array("sp" => "18", "id" => $formName, "user" => $user,  "co" => $co_id);
        $post_sidebar = array("sp" => "31", "category" => "%", "sub" => "%", "user" => $user, "action" => $_SESSION['user_teacher'], "co" => $co_id);
 
     	$formInfo = $this->formModel->formInfo($post_form_info);
    	$formInputs = $this->formModel->formInputs($post_form_inputs);
      	$link = $this->formModel->getSidebar($post_sidebar);
       	 
      	 $company = array("sp" => "68", "domain" => URLROOT);
                    
                    
             $company = $this->formModel->callProcDQL($company, "fetch");
      	 
      	 
      	 #lables list query for developer quickly update
       $lables = array('sp' => 43, "co" => $co, "cat" => "quick-for-devloper", "sub" => "%", "link" => $formName, "par" => "" );

            $lbl_result = $this->formModel->callProcDQL($lables);
            $lbl_columns = $this->formModel->callProcDQL($lables ,"columns");
      
     $arr = array();

                foreach ($link as $key => $row) {
                   $arr[$row->category][$row->sub_category][$key] = $row;
                }
                
                ksort($arr, SORT_NUMERIC);
            
            $result = "";
            $columns = "";
            if(!empty($_POST)){
                $_POST = filter_input_array(INPUT_POST,FILTER_SANITIZE_STRING);
            $_POST = array_map('trim', $_POST);

            $result = $this->formModel->callProcDQL($_POST);
            $columns = $this->formModel->callProcDQL($_POST,"columns");
          //  $meta = $this->formModel->callProcDQL($_POST,"meta");
            
            
            }
   		 $data = [

           	 "form" => $formInfo,
           	 "input" => $formInputs,
                "link" => $arr,
                "result" => $result,
                "columns" => $columns,
             //   "meta" => $meta,
              //  "order" => $notification,
                "company" => $company,
                "visitor" => $visitor_info,
        		"lbl_result" => $lbl_result,
         		"lbl_columns" => $lbl_columns,
         	"lbl_post" => $lables,
         "formname" => $originalFormname,
         "formname2" => $formName
                

   		 ];


     			$this->view('forms/ktc_ghf',$data);
     }else{
             header("Location: " . URLROOT . "/users/login");
     }
    }
    
    public function list2($formName){
      if($this->session->isLoged()){
        $user = $this->session->getSession("user_id");
        $co_id = $this->session->getSession("co_id");
        $co = $this->session->getSession("co_id");
        
  		$formName = "forms/list/".$formName;
  		
  		$visitor_info = array("device" => $this->device(), "os" => $this->os(), "ip" => $this->ip(), "browser" => $this->browser(), "country" => $this->location("country"), "region" => $this->location("region"), "city" => $this->location("city"), "domain" => URLROOT, "cookie" => "Old", "tries" => 0);
        
        $post_form_info = array("sp" => "26", "id" => $formName, "user" => $user, "device" => $this->device(), "os" => $this->os(), "ip" => $this->ip(), "browser" => $this->browser(), "country" => $this->location("country"), "region" => $this->location("region"), "city" => $this->location("city"), "co" => $co_id, "user_teacher" => $_SESSION['user_teacher']);
        $post_form_inputs = array("sp" => "18", "id" => $formName, "user" => $user,  "co" => $co_id);
        $post_sidebar = array("sp" => "31", "category" => "%", "sub" => "%", "user" => $user, "action" => "link", "co" => $co_id);
            $notification = array("sp" => "96",   "co" => $co);

     	$formInfo = $this->formModel->formInfo($post_form_info);
    	$formInputs = $this->formModel->formInputs($post_form_inputs);
      	$link = $this->formModel->getSidebar($post_sidebar);
      	 $notification = $this->formModel->callProcDQL($notification);
      	 
      	 $company = array("sp" => "68", "domain" => URLROOT);
                    
                    
             $company = $this->formModel->callProcDQL($company, "fetch");
      	 
     $arr = array();

                foreach ($link as $key => $row) {
                   $arr[$row->category][$row->sub_category][$key] = $row;
                }
                
                ksort($arr, SORT_NUMERIC);
            
            $result = "";
            $columns = "";
            if(!empty($_POST)){
                $_POST = filter_input_array(INPUT_POST,FILTER_SANITIZE_STRING);
            $_POST = array_map('trim', $_POST);

            $result = $this->formModel->callProcDQL($_POST);
            $columns = $this->formModel->callProcDQL($_POST,"columns");
            $meta = $this->formModel->callProcDQL($_POST,"meta");
            
            
            }
   		 $data = [

           	 "form" => $formInfo,
           	 "input" => $formInputs,
                "link" => $arr,
                "result" => $result,
                "columns" => $columns,
                "meta" => $meta,
                "order" => $notification,
                "company" => $company,
                "visitor" => $visitor_info

   		 ];
   		 
   		 foreach($result as $r){
   		     if(!empty($r->sms_wa) && !empty($r->tell_wa)){
   		         ?>
   		         <script>
   		              window.open('https://wasniper.com/api/send.php?number=<?php echo $r->tell_wa;?>&type=text&<?php echo $r->sms_wa;?>&instance_id=61FC08DB3E742&access_token=841ffeeb91e6ad91603966d324b65675', '_blank');
   		         </script>
   		         <?php
                       //$res = $this->sendWhatsApp2($row->tell_wa,$row->sms_wa);
                    }
   		 }


     			$this->view('forms/ktc_ghf',$data);
     }else{
             header("Location: " . URLROOT . "/users/login");
     }
    }
    
    public function report(){
         if($this->session->isLoged()){
        
            
            $result = "";
            $columns = "";
            if(empty($_POST)){
    		         header("Location: " . URLROOT);
    		    }
     
    	$user = $this->session->getSession("user_id");
        $co_id = $this->session->getSession("co_id");
        
        $_POST['di_resu'] =  $user;
        $_POST['di_oc'] =  $co_id;
        
        
           $_POST = filter_input_array(INPUT_POST,FILTER_SANITIZE_STRING);
            $post = array_map('trim', $_POST);
			
				$formname = $post['eman_mrof'];
    		  unset($post['eman_mrof']);
    		  
			
            $result = $this->formModel->callProcDQL($post);
            
            
            $company = array("sp" => "68", "domain" => URLROOT);
             $company = $this->formModel->callProcDQL($company, "fetch");
              
   		 $data = [

           	
                "result" => $result,
                 "formname" => $formname,
                "company" => $company,
         "post" => $_POST
                

   		 ];

        $this->view3('forms/ktc_report',$data);
        
     }else{
             header("Location: " . URLROOT . "/users/login");
     }
    }
    

  public function reportNoDT($page = 'ktc_report_no_datatable'){
         if($this->session->isLoged()){
        
            
            $result = "";
            $columns = "";
            if(empty($_POST)){
    		         header("Location: " . URLROOT);
    		    }
         
         foreach($_POST as $key => $val){
    		    if(is_array($val)){
                    $_POST[$key] = implode("," , $val);
                    
                }
         }
               // $_POST = filter_input_array(INPUT_POST,FILTER_SANITIZE_STRING);
            $_POST = array_map('trim', $_POST);

            $result = $this->formModel->callProcDQL($_POST);
            $columns = $this->formModel->callProcDQL($_POST,"columns");
            $meta = $this->formModel->callProcDQL($_POST,"meta");
            $count = $this->formModel->callProcDQL($_POST,"count");
            $sql = $this->formModel->callProcDQL($_POST,"sql");
            
            $company = array("sp" => "68", "domain" => URLROOT);
                    
                    
             $company = $this->formModel->callProcDQL($company, "fetch");
            
            
            
            
   		 $data = [

           	
                "result" => $result,
                "columns" => $columns,
                "meta" => $meta,
                "count" => $count,
                "sql" => $sql,
                "company" => $company,
          "post" => $_POST
                

   		 ];


     			$this->view3('forms/'.$page,$data);
     }else{
             header("Location: " . URLROOT . "/users/login");
     }
    }
    
  public function reportNoZoo(){
         if($this->session->isLoged()){
        
            
            $result = "";
            $columns = "";
            if(empty($_POST)){
    		         header("Location: " . URLROOT);
    		    }
         
         foreach($_POST as $key => $val){
    		    if(is_array($val)){
                    $_POST[$key] = implode("," , $val);
                    
                }
         }
               // $_POST = filter_input_array(INPUT_POST,FILTER_SANITIZE_STRING);
            $_POST = array_map('trim', $_POST);

            $result = $this->formModel->callProcDQL($_POST);
            $columns = $this->formModel->callProcDQL($_POST,"columns");
            $meta = $this->formModel->callProcDQL($_POST,"meta");
            $count = $this->formModel->callProcDQL($_POST,"count");
            $sql = $this->formModel->callProcDQL($_POST,"sql");
            
            $company = array("sp" => "68", "domain" => URLROOT);
                    
                    
             $company = $this->formModel->callProcDQL($company, "fetch");
            
            
            
            
   		 $data = [

           	
                "result" => $result,
                "columns" => $columns,
                "meta" => $meta,
                "count" => $count,
                "sql" => $sql,
                "company" => $company,
          "post" => $_POST
                

   		 ];


     			$this->view3('forms/ktc_report_no_zoo_table',$data);
     }else{
             header("Location: " . URLROOT . "/users/login");
     }
    }
    
      
    public function report2(){
         if($this->session->isLoged()){
        
            
            $result = "";
            $columns = "";
            if(empty($_POST)){
    		         header("Location: " . URLROOT);
    		    }
    		    
                $_POST = filter_input_array(INPUT_POST,FILTER_SANITIZE_STRING);
            $_POST = array_map('trim', $_POST);

            $result = $this->formModel->callProcDQL($_POST);
            $columns = $this->formModel->callProcDQL($_POST,"columns");
            $meta = $this->formModel->callProcDQL($_POST,"meta");
            $count = $this->formModel->callProcDQL($_POST,"count");
            $sql = $this->formModel->callProcDQL($_POST,"sql");
            
            $company = array("sp" => "68", "domain" => URLROOT);
                    
                    
             $company = $this->formModel->callProcDQL($company, "fetch");
            
            
            
            
   		 $data = [

           	
                "result" => $result,
                "columns" => $columns,
                "meta" => $meta,
                "count" => $count,
                "sql" => $sql,
                "company" => $company
                

   		 ];

	 foreach($result as $r){
   		     if(!empty($r->sms_wa) && !empty($r->tell_wa)){
   		         ?>
   		         <script>
   		              window.open('https://wasniper.com/api/send.php?number=<?php echo $r->tell_wa;?>&type=text&&message=<?php echo $r->sms_wa;?>&instance_id=61FC08DB3E742&access_token=841ffeeb91e6ad91603966d324b65675', '_blank');
   		         </script>
   		         <?php
                       //$res = $this->sendWhatsApp2($row->tell_wa,$row->sms_wa);
                    }
   		 }
     			$this->view3('forms/ktc_report',$data);
     }else{
             header("Location: " . URLROOT . "/users/login");
     }
    }
    
    
            public function generateProc(){
                	
                		$_POST = filter_input_array(INPUT_POST,FILTER_SANITIZE_STRING);
                        $post = array_map('trim', $_POST);
                        
                        $unique = explode(",",$post['unique_columns']);
                        
                        $where = "";
                        $unique_columns = "";
                        
                        foreach($unique as $col){
                           $where .= $col . ' = _' . $col . ' AND ';  
                           $unique_columns .= '_' . $col . ',';
                        }
                        
                        $where = substr($where, 0, -4);
                        
                        $unique_columns = substr($unique_columns, 0, -1);
                        

                        $result = $this->formModel->generateProc($post['table'],  $unique_columns, $where);
                        
                        $sp = $post['table'].'_sp';
                        $text = 'Create '. $post['table'];
                        $title =  $post['table'] . ' Form';
                        
                        $link_post = array("sp" => 27,  "href_p" => "forms/create",  "title_p" => $title,  "category_p" => "1",  "sub_category_p" => "81",  "text_p" => $text,  "sp_p" => $sp,  "description_p" => $title,  "form_action_p" => "forms/save",  "btn_p" => "Save",  "lk_icon_p" => "fa fa-plus",  "user_p" => $_SESSION['user_id'],  "co_p" => $_SESSION['co_id']);
                        $link_result = $this->formModel->callProcDQL($link_post, "fetch");
            			
                		echo $result;
                	
                }
                
                 public function invoice($id,$action,$co){
                     
                    $post = array("sp" => "25", "id" => $id, "action" => $action, "co" => $co);
                    $company = array("sp" => "68", "domain" => URLROOT);
                    
                    
                     $result = $this->formModel->callProcDQL($post, "fetch");
                     $company = $this->formModel->callProcDQL($company, "fetch");
                     
                     
                     $data = [
                         "company" => $company,
                         "result" => $result
                         
                         ];
                         
            	$this->view3('forms/ktc_invoice',$data);
            }
          
            public function invoice2($id,$action,$co){
                     
                    $post = array("sp" => "25", "id" => $id, "action" => $action, "co" => $co);
                    $company = array("sp" => "68", "domain" => URLROOT);
                    
                    
                     $result = $this->formModel->callProcDQL($post, "fetch");
                     $company = $this->formModel->callProcDQL($company, "fetch");
                     
                     
                     $data = [
                         "company" => $company,
                         "result" => $result
                         
                         ];
                         
            	$this->view3('forms/ktc_invoice_no_print',$data);
            }
                 
                 
                 	public function drop($action, $name){

        	 $result = $this->formModel->drop($action,$name);
        
        	print_r($result);
        
		}
                 
                 
                 public function upload(){
                     $file = $_FILES['csv']['tmp_name'];
                     $csv = array_map('str_getcsv', file($file));
                     
                     $lines = file($file);

                    $header = array_shift($lines);
                    
                    $csv2 = array_map(function ($line) use ($header) {
                    $state = array_combine(
                        str_getcsv($header),
                        str_getcsv($line)
                    );
                
                    return $state;
                }, $lines);
                    
                     //$csv = array("a"=>"a");
                     $data = [
                         "post" => $_POST,
                       
                         "csv2" => $csv2
                         
                         
                         ];
                    	$this->view3('forms/ktc_upload',$data);


                 }
                 
                 public function insert(){
                     
                    $_POST = filter_input_array(INPUT_POST,FILTER_SANITIZE_STRING);
                    
                    $post = array_map('trim', $_POST);
                           
                     $result = $this->formModel->insertSQL($post);

                     print_r($result);
                 }

				public function reportHeader(){
                	$_POST = filter_input_array(INPUT_POST,FILTER_SANITIZE_STRING);
           			 $_POST = array_map('trim', $_POST);

           			 $result = $this->formModel->callProcDQL($_POST, "fetch");
                	
                foreach($result as $k => $v){
                	$k = trim($k);
                	if(($k == "Student Comment" or $k == "Student Info") && $v == "") {
						continue;
					}
                	if($k == "h1" || $k == "h2" || $k == "h3" || $k == "h4" || $k == "h5" || $k == "h6"){
                    echo "<center><$k> $v </$k></center>";
                    }else{
                    ?>
                	<div class="col-xs-6 col-sm-6 col-md-6 col-lg-6" style="font-size:14px;font-family:Arial"><?php echo $k . " : <b>" . $v."</b>" ;?>
                        </div>
                <?php }
                }
                	
				}

				public function reportFooter(){
                	$_POST = filter_input_array(INPUT_POST,FILTER_SANITIZE_STRING);
           			 $_POST = array_map('trim', $_POST);

           			 $columns = $this->formModel->callProcDQL($_POST, "columns");
                	 $result = $this->formModel->callProcDQL($_POST);
                
                	?>
                 
                    <strong><span id="report_caption"></span></strong><br/>
                    <table class="table table-bordered" width="80%">
                    <thead>
                    <tr>
                 
                     <?php
						
						foreach($columns as $col){
                           if($col == "report_caption") continue;
                            $k = explode("~", $col);
                            ?>
                            <th alt="<?php echo $k[2];?>" class="<?php echo $k[1];?>"><?php echo $k[0];?></th>
                            <?php
                        }
                        ?>
                    </tr>
                </thead>
                <tbody>
                         <?php
                        $i = 0;
                        foreach($result as $row) {
                        $i++;
                   
                    ?>
                    <tr >
                        <?php
                    	
                    	foreach($row as $col => $val){
                       
                        
                           if($col == "report_caption") {
                           if($i == 1){
                           echo "<span id='caption-text'> $val </span>";
                           }
                           continue;
                           }
                        
                       ?>
                       <td><?php echo $val;?></td>
                       <?php } ?>
                     </tr>
                     <?php } ?>
                    </tbody>
                        </table>
                    
                        <script>
var caption = document.getElementById("report-caption").innerHTML;
                document.getElementById("caption-text").innerHTML=caption;
                        </script>
                    <?php
               
               
                	
				}


		public function sms_sms($table, $id,  $action,$tell, $user){
 		    
 	            $post = array("sp" => "358","co" => 1, "tell" => $tell, "table" => $table, "id" => $id, "action" => $action, "user" =>$user);
 	            
 	          $result = $this->formModel->callProcDQL($post,"fetch");
 	              
 	              
 	            //  print_r($post);
               //   print_r($result);
        //
        
 	           //  header("Location: whatsapp://send?text=".$result->sms."&phone=".$result->tell);
 	           echo "whatsapp://send?text=".$result->sms."&phone=".$result->tell;
        
       // print_r(explode("&",$result->sms));

 		}

 
        
        public function contract($hospital_id){
              $user = $this->session->getSession("user_id");
           $contract_post = array("sp" => "566", "hospital" => $hospital_id, "user_id" => $user, "co" => 1);
             $contract = $this->formModel->callProcDQL($contract_post,"fetch");
                 
            
            $data = [
                "contract" => $contract
                ] ;
                
            $this->view2("forms/contract",$data);
        }
	}