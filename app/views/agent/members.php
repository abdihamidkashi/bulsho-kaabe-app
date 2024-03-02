	<div class="limiter">
 	    <br/>
	    <h5 style="color:blue; font-weight:bold"><center>Bulsho Tech eTicket Hospital</center></h5>
	    
	    <hr/>
		<div class="container" >
		       <ul class="nav nav-tabs">
    <li class="nav-item">
      <a class="nav-link " href="<?php echo URLROOT;?>/agent/profile" ><b><i class="fa fa-user fa-lg"></i> Xogteyda</b> </a>
    </li>
    <li class="nav-item">
      <a class="nav-link" href="<?php echo URLROOT;?>/agent/campaign"><b><i class="fa fa-user-md fa-lg"></i> Ololaha</b></a>
    </li>
    <li class="nav-item">
      <a class="nav-link  active text-primary" href="<?php echo URLROOT;?>/agent/campaignmembers"><b><i class="fa fa-users fa-lg"></i> Xubnaha</b></a>
    </li>
   
  </ul>
    <br/>
 
        
		 <?php
		 $c = $data['campaign'][0];
          // echo @$_COOKIE['campaign_id'];
           function get_starred($str) {
                $len = strlen($str);
            
                return substr($str, 0, 1).str_repeat('*', $len - 2).substr($str, $len - 1, 1);
            }
            ?>
           <div   style="margin-bottom:3px;">
               
                <h4 style="text-align:center;font-weight:bold">Olalaha <?php echo $c->campaign . ' (' . $c->id.')';?></h4>
                <p style="text-align:center;font-weight:bold;margin:0">Liis-ka xubnaha ugu sareeya ee ku tartamaya ololahan </p>
                        <hr/>
                <ul class="list-grop">
                    <?php
                    $i = 0;
                    foreach($data['campaign'] as $c){
                    $i++;
                    ?>
                    <li class="list-group-item">
                    <span style="border-radius: 45%; fotn-size:25px; padding:10px; background: #69F;font-weight:bold;margin-right:10px; "> <?php echo $i;?></span><?php echo get_starred($c->agent) . ' <span class="badge bg-success">('.  $c->shares . ' clicks)</span>';?>
                    </li>
                    <?php } ?>
                </ul>
           </div> 
          
 </div>
 </div>
