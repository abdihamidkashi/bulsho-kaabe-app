	<div class="limiter">
 	    <br/>
	    <h5 style="color:blue; font-weight:bold"><center>Bulsho Tech eTicket Hospital</center></h5>
	    
	    <hr/>
		<div class="container" >
		    <p>Kusoo dhawoow qeybta caawimaada App-ka Bulsho Tech, Hal-kan waxaad ka heleysaa qeybo ka mid ah su'aalaha aad is weydiineyso oo ku gedaaman Shirkadda Bulsho tech iyo App-ka sida uu u haqeeyo</p>
  <div id="accordion" >
      		       <ul class="nav nav-tabs">
    <li class="nav-item">
      <a class="nav-link active" href="#"><b><i class="fa fa-list fa-lg"></i> All</b>  </a>
    </li>
    <li class="nav-item">
      <a class="nav-link" href="#"><b><i class="fa fa-users fa-lg"></i> Bukaan</b> </a>
    </li>
    
    <li class="nav-item">
      <a class="nav-link " href="#"><b><i class="fa fa-home fa-lg"></i> Isbıtaal</b></a>
    </li>
   
  </ul>
    <br/>
      	<?php 

$i = 0;
	foreach($data['faq'] as $f){
    $i++;
    ?>
    <div class="card" >
    
        <a class="card-link btn btn-info btn-block" data-toggle="collapse" href="#ques<?php echo $i;?>">
         <?php echo $f->question;?>
        </a>
     
      <div id="ques<?php echo $i;?>" class="collapse" style="width:100%" data-parent="#accordion" >
         <?php echo nl2br($f->answer);?>
      </div>
    </div>
 <?php }
  ?>
   </div>
</div>
 
</div>