<!doctype html>
<html lang="en" dir="ltr">
	<head>

	<?php $css = @$_SESSION['language'] == "AR" ? 'css-rtl' : 'css'; ;?>

		<!-- META DATA -->
		<meta charset="UTF-8">
		<meta name='viewport' content='width=device-width, initial-scale=1.0, user-scalable=0'>
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="description" content="<?php echo $data['comapny']->name;?>">
		<meta name="author" content="<?php echo $data['comapny']->name;?>">
		<meta name="keywords" content="<?php echo $data['comapny']->name;?>">

		<!-- FAVICON -->
        <link rel="icon" href="<?php echo empty($data['company']->logo) ? URLROOT . '/' . $_SESSION['logo'] : URLROOT . '/' .$data['company']->logo?>" type="image/x-icon">

		<!-- TITLE -->
		<title><?php echo empty($data['company']->name) ? $_SESSION['company'] : $data['company']->name?> </title>

		<!-- BOOTSTRAP CSS -->
		<link href="<?php echo URLROOT;?>/plugins/bootstrap/css/bootstrap.min.css" rel="stylesheet" />

		<!-- STYLE CSS -->
		<link href="<?php echo URLROOT.'/'.$css;?>/style.css" rel="stylesheet"/>
		<link href="<?php echo URLROOT.'/'.$css;?>/dark-style.css" rel="stylesheet"/>
		<link href="<?php echo URLROOT.'/'.$css;?>/skin-modes.css" rel="stylesheet" />

		<!-- SIDE-MENU CSS -->
		<link href="<?php echo URLROOT.'/'.$css;?>/sidemenu.css" rel="stylesheet" id="sidemenu-theme">

		<!--C3 CHARTS CSS -->
		<link href="<?php echo URLROOT;?>/plugins/charts-c3/c3-chart.css" rel="stylesheet"/>

		<!-- P-scroll bar css-->
		<link href="<?php echo URLROOT;?>/plugins/p-scroll/perfect-scrollbar.css" rel="stylesheet" />

		<!--- FONT-ICONS CSS -->
		<link href="<?php echo URLROOT.'/'.$css;?>/icons.css" rel="stylesheet"/>

		<!-- SIDEBAR CSS -->
		<link href="<?php echo URLROOT;?>/plugins/sidebar/sidebar.css" rel="stylesheet">

		<!-- SELECT2 CSS -->
		<link href="<?php echo URLROOT;?>/plugins/select2/select2.min.css" rel="stylesheet"/>

		<!-- INTERNAL Data table css -->
		<link href="<?php echo URLROOT;?>/plugins/datatable/css/dataTables.bootstrap5.css" rel="stylesheet" />
		<link href="<?php echo URLROOT;?>/plugins/datatable/responsive.bootstrap5.css" rel="stylesheet" />

		<!-- COLOR SKIN CSS -->
		<link id="theme" rel="stylesheet" type="text/css" media="all" href="<?php echo URLROOT;?>/colors/color1.css" />
        
        <style>
            .hide{
                display: none;
            }

.loader-img {
    background-image: url('/ktc/images/loader.gif') ;
    background-repeat: no-repeat;
   background-size: 50px;
background-color: #FFF;
    background-position: center;
}

/** {
font-family: 'Sakkal Majalla';
font-size: 20px;
font-weight: bold;
}
   
   */
</style>
        
	</head>

    <span id="domain" class="d-none"><?php echo URLROOT;?></span>

