	<div class="limiter">
 	    <br/>
	    <h5 style="color:blue; font-weight:bold"><center>Bulsho Tech eTicket Hospital</center></h5>
	    
	    <hr/>
		<div class="container" >
		       <ul class="nav nav-tabs">
    <li class="nav-item">
      <a class="nav-link active text-primary" href="<?php echo URLROOT;?>/agent/profile" ><b><i class="fa fa-home fa-lg"></i> Xogteyda</b> </a>
    </li>
    <li class="nav-item">
      <a class="nav-link " href="<?php echo URLROOT;?>/agent/campaign"><b><i class="fa fa-user-md fa-lg"></i> Ololaha</b></a>
    </li>
   <li class="nav-item">
      <a class="nav-link " href="<?php echo URLROOT;?>/agent/campaignmembers"><b><i class="fa fa-users fa-lg"></i> Xubnaha</b></a>
    </li>
  </ul>
    <br/>
 
        
		 <?php
		 $a = $data['agent'];
             ?>
           <div   style="margin-bottom:3px;">
                
                   <center><img src="<?php echo URLROOT.'/'. $a->image;?>"   style="width:100px; height:100px;border:1px solid #666;border-radius:50%;padding:5px"/></center>
                <br/>
                <table class="table">
                    <?php foreach($a as $k => $v){
                        if($k == 'image') continue;
                        ?>
                        <tr>
                            <td><?php echo $k;?></td>
                            <th><?php echo $v;?></th>
                        </tr>
                        <?php
                    }
                    ?>
                </table>
                <p style="font-weight:bold;margin:0">Si aad uga qeyb qaadato ololaha kuna guuleysato $25 guji button-ka hoose oo ku share garee asxaabtaada Whatsapp-ka</p>
                    <a href="whatsapp://send?text=*[Bulsho Tech App]*%0aKalsoo deg App-ka Bulsho Tech <?php echo $a->Linkigayga;?> App-kan wuxuu kuu sahalaya dalbasharada iyo jarista Ticket-ka Isbitaalada." data-action="share/whatsapp/share" target="_blank" class="btn btn-primary btn-block"><i class="fa fa-whatsapp fa-2x"></i> <strong>Share garee</strong></a>
                               
           </div> 
          
 </div>
 </div>
