<!doctype html>
<html lang="en" dir="ltr">
	<head>

		<!-- FAVICON -->
        <link rel="icon" href="<?php echo empty($data['company']->logo) ? URLROOT . '/' . $_SESSION['logo'] : URLROOT . '/' .$data['company']->logo?>" type="image/x-icon">

		<!-- TITLE -->
		<title><?php echo empty($data['company']->name) ? $_SESSION['company'] : $data['company']->name?> </title>

		<!-- BOOTSTRAP CSS -->
		<link href="<?php echo URLROOT;?>/plugins/bootstrap/css/bootstrap.min.css" rel="stylesheet" />

        <style>
            .hide{
                display: none;
            }
   
  


      </style>
        
	</head>

    <span id="domain" class="d-none"><?php echo URLROOT;?></span>
	<body class="app sidebar-mini <?php echo $_COOKIE['theme'];?>">

