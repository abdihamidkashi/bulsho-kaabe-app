<div class="contianer">
<div class="row">
  
  <?php
	//echo $data['links_count']; 
//print_r($data['post']); 

 //print_r($data['permission'] );
  foreach($data['permission'] as $c => $sub){
      ?>
      <div class="col-md-3">
    <li style="list-style:none" class="">
          <input type="checkbox" id="<?php echo $c;?>" title="<?php echo $c;?>" value="" class="form-parent ktc_check_category"/>
             <label for="bs<?php echo $c;?>"><?php echo $c;?></label>

          <ul style="margin-left:20px">
            <?php foreach ($sub as $s => $link) { ?>
            <li style="list-style:none" class="checkbox" >
             
    <input type="checkbox" id="<?php echo $s;?>" title="<?php echo $s;?>" value="" class="filled-in ktc-link-permission ktc_check_category"/> 
                        <label for="bs<?php echo $s;?>"><?php echo $s;?></label>

              <ul style="list-style:none; margin-left:20px">
                  <?php 
                  
                  foreach($link as $l) { ?>
			      <li class="checkbox">
			          <input  id="bs<?php echo $l->link_id;?>"  title="<?php echo $l->text;?>" class="filled-in ktc-link-permission checkbox ktc-check-link" value="<?php echo $l->link_id;?>" u2="<?php echo $_SESSION['user_id'];?>" u1="<?php echo $_POST['user_p'];?>" co="<?php echo $_POST['co_p'];?>"  type="checkbox" <?php echo " ".$l->mode;?>   action="<?php echo $l->action;?>"/> 
                        <label for="bs<?php echo $l->link_id;?>"><?php echo $l->text;?></label>
			          </li>
                <?php } ?>
              </ul>
            </li>
            <?php } ?>
           </ul>
          </li>
         

      </div>
     <?php
  }
  ?>  
    
</div>




</div>