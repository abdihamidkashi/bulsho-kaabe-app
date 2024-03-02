<!-- BOOTSTRAP CSS -->
		<link href="<?php echo URLROOT;?>/plugins/bootstrap/css/bootstrap.min.css" rel="stylesheet" />

 
<style>
   .ktc-box{
      
       padding: 6px;
      
   } 
   .ktc-border{
        border-bottom: 1px dashed black;
   }
   .ktc-title{
       font-weight:bold;
       margin:3px;
   }
   
  
   #ktc-invoice, #copy{
       width: 90%;
       height:46%;
       margin:20px auto;
   }
</style>

<div id="ktc-invoice">
     <table border="0" width="100%">
                        
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
    }else if($key == $v){
         ?>
    
    <div style="margin-left:-10px !important" class="col-<?php echo !empty($k[1]) ? $k[1] : '6';?> ktc-box"><?php echo "<u><b>".$k[0] . "</b> </u>";?> </div>
    
    <?php
    }else if($k[0] == ""){
         ?>
    
      <div class="col-<?php echo !empty($k[1]) ? $k[1] : '6';?>  ktc-box <?php echo @$k[2] == 'nb' ? '' : 'ktc-border';?> "><?php echo  $v;?> </div>
    
    <?php
    }
    else{
    ?>
    
    <div class="col-<?php echo !empty($k[1]) ? $k[1] : '6';?>  ktc-box <?php echo @$k[2] == 'nb' ? '' : 'ktc-border';?> "><?php echo "<b>".$k[0] . "</b> : ". $v;?> </div>
    
    <?php
    }
}

?>

</div>

</div>

<div id="copy"></div>
    <!-- JQUERY JS -->
		<script src="<?php echo URLROOT;?>/js/jquery.min.js"></script>
<script>



var copy = <?php echo @$copy;?>


if($.trim(copy) == "true"){
    var pr_div = $("#ktc-invoice").html();
$("#copy").html("<hr/>"+pr_div);
}

    window.print();
</script>