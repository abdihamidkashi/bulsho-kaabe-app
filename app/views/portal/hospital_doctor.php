	<div class="limiter">
	    <?php $h = $data['doctor'][0];?>
	    <br/>
	    <h5 style="color:blue; font-weight:bold"><center>Dhakhaatiirta <?php echo $h->hospital;?></center></h5>
	    <hr/>
		<div class="container" >
  <div class="input-group mb-3">
            <input type="text" id="search" class="form-control" placeholder="Raadi Dhaqtar... ">
            <div class="input-group-append">
              <button class="btn btn-primary"><i class="fa fa-search"></i></button>
            </div>
          </div>
          <div style="border: 2px dashed #900;padding:5px;">
          <center><h6 style="color: #900;"> <strong>Kusoo dhawoow <?php echo $h->hospital;?></strong></h6></center>
          <hr/>
          <p style="margin:0 !important; ">Waad ku mahadsantahay booqashadaada  <strong><?php echo $h->hospital;?></strong>,  waxaana kugusoo dhaweyneynaa gacmo furan iyo adeeg caafimaad oo tayo sare leh,  <a href="#" class="show-more">sii akhri ...</a> <span class="d-none more-text"> hadii aad u baahantahay inaad jarato Ticket dhakhtar
              fadlan App-kan waxaad ka jaran kartaa Ticket-ka Isbitaalkeena,
              Dhakhaatiirta ka howlgasha isbitaalkeenana waa dhkhaatiirta hoose ku xusan magacyadooda iyo Takhasusyadooda Mahadsanid <a href="#" class="show-less">iga xir</a></span> </p>
       
        </div>
         <br/>
        <?php
        if($h->doctor == 'no-doctor'){
          
        }else{  
        foreach($data['doctor'] as $d){
          
            ?>
           <div class="doctor-box search-box" alt="<?php echo $d->hospital_id;?>" id="<?php echo $d->auto_id;?>"  style="border-bottom: 1px solid #666;margin-bottom:3px;">
               <div class="row"  style=" margin-bottom:3px;">
                   <div class="col-2"  >
                   <img src="<?php echo $d->doctor_image == 'error' ? URLROOT . '/'. $d->department_image :  URLROOT . '/'. $d->doctor_image;?>"   style="width:55px; height:55px;border:1px solid #666;border-radius:50%"/>
                   </div>
                    <div class="col-10"  >
                   <p   style="margin:3px !important; "> <strong><?php echo $d->doctor;?></strong> <br/> <small><?php echo $d->department . ' - Ticket fee : '. $d->ticket_fee ;?></small> </p>
                   <p><?php echo $d->doctor_description;?></p>
                   </div>
               </div>
           </div> 
            <?php
        }
        }
        ?> 
 </div>
 </div>
