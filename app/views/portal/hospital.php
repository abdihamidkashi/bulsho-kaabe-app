	<div class="limiter">
 	    <br/>
	    <h5 style="color:blue; font-weight:bold"><center>Bulsho kaabe health service online</center></h5>
	    
	    <hr/>
		<div class="container" >
		       <ul class="nav nav-tabs">
    <li class="nav-item">
      <a class="nav-link active" href="<?php echo URLROOT;?>/portal/index/no-token"><b><i class="fa fa-home fa-lg"></i> Isbitaalada</b> <sup><span class="badge badge-pill badge-danger"><?php echo count($data['hospital']);?></span></sup></a>
    </li>
    <li class="nav-item">
      <a class="nav-link " href="<?php echo URLROOT;?>/portal/index/no-token/doctor"><b><i class="fa fa-user-md fa-lg"></i> Dhakhaatiirta</b></a>
    </li>
   
  </ul>
    <br/>
		    <div class="input-group mb-3">
            <input type="text" id="search" class="form-control" placeholder="Raadi Isbitaal... ">
            <div class="input-group-append">
              <button class="btn btn-primary"><i class="fa fa-search"></i></button>
            </div>
          </div>
        
		 
         
        <?php
     //   echo $_SESSION['token'];
       $wa = false;
       if($_SESSION['token'] == 'cnPWQLadTOudCyiZMv-MJe:APA91bELX3Y3GzM77HBqfgyTutuWsPkIg8MBF_HEIft3uVFQkL29UnJifxEEeBW2fBKoGKx3Y1glTucbAGQRy37ohiCkWZo1_yQIl0mnb3t9ktoC-L4mM1pUHDkYA_MdREyDZ8_dvu_x' || $_SESSION['token'] == 'fW9-pvSLTU6lnvgYTlIDHg:APA91bE-fLaQoGRZ-7GamYOUUNUfODl7gXXnYHlnHhXBbH9qWlYNXcABgGixEmu_IOXw8mX2hQUhOLlIJlTnDfCOgnGhidyNcFHqwwX9WsX3iDpxWIivd3U67G5-cE3LLst0AA0IhkdQ'){
           $wa = true;
       }
        foreach($data['hospital'] as $h){
          
            ?>
           <div class="hospital-box search-box"  id="<?php echo $h->auto_id;?>"  style="border-bottom: 1px solid #666;margin-bottom:3px;">
               <div class="row"  style=" margin-bottom:3px;">
                   <div class="col-2"  >
                   <img src="<?php echo URLROOT.'/'. $h->logo;?>"   style="width:55px; height:55px;border:1px solid #666;border-radius:50%"/>
                   </div>
                    <div class="col-10"  >
                   <p   style="margin:3px !important"> <strong><?php echo $h->name;?></strong> 
                   
                   <?php if($wa){
                        echo $h->as_patient . ' '. $h->as_hospital;
                   }?>
                   
                   <br/> <small><?php echo $h->address . ' '. $h->city ;?></small> </p>
                   
                   </div>
               </div>
           </div> 
            <?php
        }
        ?> 
 </div>
 </div>
