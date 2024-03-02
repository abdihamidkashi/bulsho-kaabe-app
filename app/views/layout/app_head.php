<!DOCTYPE html>
<html lang="en">
<head>
	<title>Bulsho Kaabe  Health Services</title>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
<!--===============================================================================================-->	
	<link rel="icon" type="image/png" href="<?php echo URLROOT;?>/app_files/images/icons/favicon.ico"/>
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="<?php echo URLROOT;?>/app_files/vendor/bootstrap/css/bootstrap.min.css">
<!--===============================================================================================-->
 
 
 <!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="<?php echo URLROOT;?>/app_files/css/util.css">
	<link rel="stylesheet" type="text/css" href="<?php echo URLROOT;?>/app_files/css/main.css?v=1.2">
<!--===============================================================================================-->
 
  <link href="<?php echo URLROOT;?>/app_files/vendor/bootstrap/css/font-awesome.min.css" rel="stylesheet">
 <link href="<?php echo URLROOT;?>/app_files/css/menu-style.css?v=1.1" rel="stylesheet">
 
 <style>
     body{
         width: 100% !important;
     }
     
       .absolute {
          position: fixed;
          bottom: 0;
          width:`100%;
          z-index:99999;
        
        }
        
         .btm{
         position: fixed;
    bottom: 30px;
    left: 10px;
    border-top: 1px solid #eee;
    border-radius: 40%;
    padding:;
    overflow: hidden;
    z-index : 999999;
     }
     
     
     
     .footer-links li{
         width: 25%;
     }
 </style>
</head>
<body>
    <span id="visitor-token" style="display:none"><?php echo @$_SESSION['token'];?></span>