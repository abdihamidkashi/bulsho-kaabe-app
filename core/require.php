<?php
    require_once 'config/config.php';
    require_once 'libraries/Core.php';
    require_once 'helpers/Session.php';
    require_once 'helpers/FixedBitNotation.php';
    require_once 'helpers/GoogleAuthenticatorInterface.php';
    require_once 'helpers/GoogleAuthenticator.php';
    require_once 'helpers/GoogleQrUrl.php';


    
    require_once 'libraries/Controller.php';
    require_once 'libraries/Model.php';
    
    
    //call core clas
    $init = new Core();
    