<!-- BOOTSTRAP CSS -->
		<link href="<?php echo URLROOT;?>/plugins/bootstrap/css/bootstrap.min.css" rel="stylesheet" />

 
<style>
   .ktc-box{
      
       padding: 12px;
    } 
   .ktc-border{
        border-bottom: 1px dashed black;
   }
   .ktc-title{
       font-weight:bold;
       margin:6px;
   }
   
    *{
      font-size: 30px;
  }
</style>
<div class="container">
<div id="ktc-invoice" style="border: 3px dashed #666; padding: 25px;margin:10px">
     <table border="0"  >
                        
       <tr>
                        <td>
          <center>
            <img src="<?php echo URLROOT.'/'.$data['company']->logo;?>" style="height:110px !important; width:100px !important;"  alt="<?php echo $data['company']->name;?>"/><br/>
         
       </center>
          
        </td>
         <td   style="padding:10px !important">
                        
               <h1><?php echo $data['company']->name;?></h1>
           </td>
           </tr>
                        </table>
           <hr/>



<div class="row">
    <?php
    $copy = "false";
    $r = (array) $data['result'];
foreach($r as $key => $v){
    $k = explode("~",$key);
    if($k[0] == "copy"){
       $copy = "true" ;
       continue;
    }
    elseif(@$k[1] == "title"){
        ?>
       <center> <h2 class="ktc-title"><?php echo $v;?></h2></center>
        <?php
    } elseif(@$k[1] == "title2"){
        ?>
       <center> <h4 class="ktc-title"><?php echo $v;?></h4></center>
        <?php
    }elseif(@$k[1] == "title3"){
        ?>
       <center> <h6 class="ktc-title"><?php echo $v;?></h6></center>
        <?php
    }else if($key == $v){
         ?>
    
    <div style="margin-left:-10px !important" class="col-<?php echo !empty($k[1]) ? $k[1] : '6';?> ktc-box"><?php echo "<u><b>".$k[0] . "</b> </u>";?> </div>
    
    <?php
    }else if($k[0] == ""){
         ?>
    
      <div class="col-<?php echo !empty($k[1]) ? $k[1] : '12';?>  ktc-box <?php echo @$k[2] == 'nb' ? '' : 'ktc-border';?> "><?php echo  $v;?> </div>
    
    <?php
    }else if($k[0] == "image" && $v != 'no-image'){
         ?>
    
      <div class="col-<?php echo !empty($k[1]) ? $k[1] : '12';?>  ktc-box <?php echo @$k[2] == 'nb' ? '' : 'ktc-border';?> "><a href="<?php echo  $v;?>" download>  La deg Ticket-ka Isbitaalka</a> <img src="<?php echo  $v;?>" width="99%"/> </div>
    
    <?php
    }
    else{
    ?>
    
    <div class="col-<?php echo !empty($k[1]) ? $k[1] : '12';?>  ktc-box <?php echo @$k[2] == 'nb' ? '' : 'ktc-border';?> "><?php echo "<b>".$k[0] . "</b> : ". $v;?> </div>
    
    <?php
    }
}

?>

</div>
</div>
</div>


