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
      <a class="nav-link active text-primary" href="<?php echo URLROOT;?>/agent/campaign"><b><i class="fa fa-user-md fa-lg"></i> Ololaha</b></a>
    </li>
    <li class="nav-item">
      <a class="nav-link " href="<?php echo URLROOT;?>/agent/campaignmembers"><b><i class="fa fa-users fa-lg"></i> Xubnaha</b></a>
    </li>
   
  </ul>
    <br/>
 
        
		 <?php
		 $c = $data['campaign'];
          // echo @$_COOKIE['campaign_id'];
            ?>
           <div   style="margin-bottom:3px;">
                
                <ul class="list-grop">
                    <li class="list-group-item">
                        <h4 style="text-align:center;font-weight:bold">Olalaha <?php echo $c->name . ' (' . $c->id.')';?></h4>
                        <button href="<?php echo URLROOT;?>/agent/join/<?php echo $c->auto_id;?>" type="button" class="<?php echo @$_COOKIE['campaign_id'] == $c->auto_id ? 'd-none' : '';?> btn btn-warning btn-sm btn-block join-campaign" <?php echo @$_COOKIE['campaign_id'] == $c->auto_id ? 'disabled' : '';?>  >Ku biir ololahan oo hel $25</button>
                        <hr/>
                        
                        <p><?php echo nl2br($c->description);?></p>
                        
                        </li>
                </ul>
           </div> 
          
 </div>
 </div>
