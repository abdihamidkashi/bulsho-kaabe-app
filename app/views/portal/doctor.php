	<div class="limiter">
 	    <br/>
	    <h5 style="color:blue; font-weight:bold"><center>Bulsho kaabe health service online</center></h5>
	    
	    <hr/>
		<div class="container" >
		 <ul class="nav nav-tabs">
    <li class="nav-item">
      <a class="nav-link " href="<?php echo URLROOT;?>/portal/index/no-token"><b><i class="fa fa-home fa-lg"></i> Isbitaalada</b></a>
    </li>
    <li class="nav-item">
      <a class="nav-link active" href="<?php echo URLROOT;?>/portal/index/no-token/doctor"><b><i class="fa fa-user-md fa-lg"></i> Dhakhaatiirta</b>  <sup><span class="badge badge-pill badge-danger"><?php echo count($data['doctor']);?></span></sup></a>
    </li>
   
  </ul>
    <br/>
    <select class="form-control select-department">
        <option value="">Dooro Qeybaha Dhakhaatiirta</option>
        <?php foreach($data['department'] as $dd){
            ?>
             <option value="<?php echo $dd->name;?>"><?php echo $dd->name;?></option>
            <?php
        }
        ?>
    </select>
    <br/>
         <div class="input-group mb-3">
            <input type="text" id="search" class="form-control" placeholder="Raadi Dhaqtar... ">
            <div class="input-group-append">
              <button class="btn btn-primary"><i class="fa fa-search"></i></button>
            </div>
          </div>
          <p id="filtered-result"></p>
        <?php
        foreach($data['doctor'] as $d){
          
            ?>
           <div class="doctor-box search-box"  alt="<?php echo $d->hospital_id;?>" id="<?php echo $d->auto_id;?>"  style="border-bottom: 1px solid #666;margin-bottom:3px;">
               <div class="row"  style=" margin-bottom:3px;">
                   <div class="col-2"  >
                   <img src="<?php echo $d->doctor_image == 'error' ? URLROOT . '/'. $d->department_image :  URLROOT . '/'. $d->doctor_image;?>"   style="width:55px; height:55px;border:1px solid #666;border-radius:50%"/>
                   </div>
                    <div class="col-10"  >
                   <p   style="margin:3px !important"> <strong><?php echo $d->department . ', Ticket: '. $d->ticket_fee ;?></strong> <br/><small><strong><?php echo $d->doctor;?></small></strong> <small><?php echo $d->hospital;?></small> </p>
                                      <p><?php echo $d->doctor_description;?></p>

                   </div>
               </div>
           </div> 
            <?php
        }
        ?> 
 </div>
 </div>
