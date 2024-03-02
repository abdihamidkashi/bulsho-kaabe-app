<?php

class Session{

protected static $session;
public function __construct()
{
 if( !isset($_SESSION) ){
        self::init();
    }
    //session_start();
    //$this->sessionID = session_id();
}

public static function init(){
    session_start();
}

public static function destroy(){
    session_destroy();
	unset($_SESSOIN);
//header("Location: ".URLROOT);
}

public function isLoged($key = 'user_id'){
if(empty($_SESSION[$key]) ){
  
setcookie("current_page", $_SERVER['REQUEST_URI'], time() + (86400 * 1), "/"); // 86400 = 1 day

return false;
}else{
if($_SESSION['2fa']!=1){
setcookie("current_page", $_SERVER['REQUEST_URI'], time() + (86400 * 1), "/"); // 86400 = 1 day

return false;
}else{
return true;
}
}
}

public static function  setSession($key, $value){
	if(!empty($key) && !empty($value)){
    $_SESSION[$key] = $value;
    }
}

public static function getSession($key){
if(!empty($key)){
   return  $_SESSION[$key];
    }
else {
echo 'errror';
}
}



}

?>