<?php  if (array_key_exists('errorMessage', $data['result'])) {

                ?>
                <div class="alert alert-danger">
                                <strong>Not found!</strong> <?php echo $data['result']['errorMessage']?>
                            </div>
                <?php
            } elseif(count($data['result'])  == 0){
            
            ?>
<div class="alert alert-warning">
                                <strong>Not found!</strong> No results found, please check if data exits or not (<?php //print_r($data['sql']);?>).
                            </div>
<?php } else{ ?>
<div id="msg-placeholder2"></div>

<button id="generate-modal" class="btn btn-primary btn-lg ">Print/Download</button>

          
<style>
.right {
   text-align: right;   
padding-right:8px !important;
}

table, th, td {
   border: 2px solid black;
}

  td.grouped_semester,tr
      {
        page-break-after: always;
        page-break-inside: avoid;
      }
    
</style>
<?php  $dir =  @$_POST['_lang'] == 'AR' || @$_POST['lang_p'] == 'AR' || @$_POST['_language'] == 'AR' ? 'RTL' : 'LTR';?>
<?php if($dir == "RTL") { ?>
<style>
td{
font-family: "Sakkal Majalla" !important;

}
</style>
<?php } ?>
<div class="table-responsive" dir="<?php echo $dir;?>">
    
                <table class="table table-bordered table-striped table-hover  no-datatable ktc-table" id="ktc-datatable" dir="<?php echo $dir;?>">
                    
                <thead>
                    <tr>
                         <?php
						$nofooter = 0;
             			$rows = count($data['result']);
						$columns  = $data['result'][0];
						foreach($columns as $col => $val){
                            if($col == "no_footer"){
                            $nofooter = 1;
                            continue;
                            } 
                            $k = explode("~", $col);
                            ?>
                            <th alt="<?php echo $k[2];?>" class="<?php echo $k[1];?>"><?php echo $k[0];?></th>
                            <?php
                        }
                        ?>
                    </tr>
                </thead>
                <tbody>
                    <?php
                        $i = 0;
                        foreach($data['result'] as $row) {
                        $i++;
                    if($nofooter == 0 && $i == $rows ){
                    	$lastrow = $row;
                    continue;
                    }
                    ?>
                    <tr >
                    
                        <?php
                    	$tab = 0;
                    	foreach($row as $col => $val){
                        $tab++;
                            if($col == "no_footer") continue;
                        	

                            $k = explode("~", $col);
                            if($k[1] == "image"){
                               ?>
                            <td class="<?php echo $k[1];?>"><a href="<?php echo URLROOT. '/'.$val;?>" target="_blank"><img src="<?php echo URLROOT. '/'.$val;?>" width="50px"/></a></td>
                            <?php  
                            }elseif(strpos($val, "http") !== false && strpos($val, "<a") === false){
                               ?>
                            <td class="<?php echo $k[1];?>"><a href="<?php echo $val;?>" target="_blank">Click to view</a></td>
                            <?php  
                            }elseif(!empty($k[1]) && strpos($k[1], 'force_dropdown') !== false){
    							$v = explode("|", $val);
   								 
   							 ?>
    					        <td  title="<?php echo $k[1].$val;?>" class="select "  alt="<?php echo @$k[3];?>">
  								  <select style="width:150px"
                             class="<?php echo @$k[1];?> ktc-dropdown" 
                             alt="<?php echo @$v[1];?>"
                             alt2="<?php echo @$val;?>"
                             
                             action = "<?php echo $k[2];?>"
                             default="<?php echo @$v[0];?>"
                             title="<?php echo 'action:'.$k[2].', def val:'.$v[0]. ', un:'. $v[1];?>">
									<option value="" >Select One</option>
										 
 
								  </select>
                              </td>


    						<?php 
   							 }elseif(@$k[4] == 'autocomplete'){
    							 
   							 ?>
    					        <td  title="autocomplete please type">
  								  <div class="form-group form-float ktc-form-box">
                                    <div class="form-line">
                                        <input  type="text" autocomplete="off" action ="<?php echo @$k[5];?>"   class="form-control ktc-autocomplete"
                                        placeholder="<?php echo $k[0];?>" value="<?php echo $val;?>"    >
                                      
                                    </div>
                                    <ul class="list-group auto-update" style="position: absolute;z-index:999 !important; border: 1px solid #666">
                                    </ul>
                                    <input type="hidden"   value="" class="hidden-auto ktc-autocomplete-id"/>
                                    
                                </div>
                              </td>
							
                             <?php 
   							 }else{
                            ?>
                            <td class="<?php echo $k[1];?>" tabindex="<?php echo strpos($k[1], "tabindex") !== false ? $tab : '';?>" <?php echo $k[2];?>><?php echo $val;?></td>
                            <?php
                            }
                        }
                        ?>
                    </tr>
                    <?php } ?>
                </tbody>
                        <?php if(!empty($lastrow)){?>
                 <tfoot >
                    <tr class="ktc-footer">
                        <th>No</th>
                        <?php 
                       
              
                        foreach($lastrow as $col => $val ){
                            if($col == "no_footer") continue;
                           $k = explode("~", $col);
                            ?>
                            <th title="<?php echo $col . $val;?>" alt="" class="<?php echo $k[1];?>" <?php echo $k[2];?> ><?php echo  $val;?></th>
                            <?php
                        }
                        ?>
                    </tr>
                </tfoot>
                        <?php } ?>
            </table>
            </div>
                <script >
                
        $('#ktc-datatable').each(function () {
            var Column_number_to_Merge = 1;
 
            // Previous_TD holds the first instance of same td. Initially first TD=null.
            var Previous_TD = null;
        var Current_td = null;
            var i = 1;
            $("tbody",this).find('tr').each(function () {
                // find the correct td of the correct column
                // we are considering the table column 1, You can apply on any table column
                 Current_td = $(this).find('td:nth-child(' + Column_number_to_Merge + ')');
                 
                if (Previous_TD == null) {
                    // for first row
                    Previous_TD = Current_td;
                    i = 1;
                } 
                else if (Current_td.text() == Previous_TD.text()) {
                    // the current td is identical to the previous row td
                    // remove the current td
                    Current_td.remove();
                    // increment the rowspan attribute of the first row td instance
                    Previous_TD.attr('rowspan', i + 1);
                    i = i + 1;
                } 
                else {
                    // means new value found in current td. So initialize counter variable i
                    Previous_TD = Current_td;
                    i = 1;
                }
            });
        Previous_TD.addClass("rowspan");
        
        });
    
               
                $(".ktc-table thead th").each(function(){
        var th = $(this).text();
	var th_index = $(this).index();
	
	if($(this).hasClass("count")){
		$(".ktc-table tfoot .ktc-footer").removeClass("hide d-none");
		var count = 0;
		$(".ktc-table tbody tr").each(function(){
			count++;
		});
		$(".ktc-table tfoot .ktc-footer").find("th").eq(th_index).text(count);
	}
	
	if($(this).hasClass("sum")){
	   // alert($(this).text())
		$(".ktc-table tfoot .ktc-footer").removeClass("hide d-none");
		var sum = 0;
		$(".ktc-table tbody tr").each(function(){
			 var am = $(this).find("td").eq(th_index).text();
			var cur_val = parseFloat(am.replace(/,/g,''));
			if(!isNaN(cur_val)){
				sum+=cur_val;
//console.log("Curent num is: "+am);
			}
			
		});
		
        if($(this).hasClass("min-hr")){
        	sum =  sum.toFixed(2) + " min / " + (sum/60).toFixed(2) + " hr";
        }else{
        sum = sum.toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,')
        }
		$(".ktc-table tfoot .ktc-footer").find("th").eq(th_index).text( sum );
	}
	
	if($(this).hasClass("avg")){
		$(".ktc-table tfoot .ktc-footer").removeClass("hide d-none");
		var sum = 0;
		var count = 0;
		$(".ktc-table tbody tr").each(function(){
		    var am = $(this).find("td").eq(th_index).text();
			var cur_val = parseFloat(am.replace(/,/g,''));
			count++;
			if(!isNaN(cur_val)){
				sum+=cur_val;
				
			}
			
		});
		$("tfoot .ktc-footer").find("th").eq(th_index).text((sum/count).toFixed(2)+" %");
	}
	
	
	
	
});

$(".ktc-table tbody tr td.color").each(function(){
 
    $(this).closest("tr").css("background-color",$(this).text());
});
             $("tbody tr b.light-blue").each(function(){
    $(this).closest("tr").css("background-color","rgb(173, 216, 230)");
});

             
           

$("tbody tr td.customcolor").each(function(){
    
	var td = $.trim($(this).text());

	if(td == 480){
    	$(this).css("background", "red");
    }else if(td > 0){
    	$(this).css("background", "yellow");
    }
});
             
             
      $(".submit-report").click(function(e){
      e.preventDefault();
      var table = $(this).attr("table");
      var set_col = $(this).attr("set_col");
      var col = $(this).attr("col");
      var val = $(this).attr("val");
      var co = $(this).attr("co");
      var us = $(this).attr("us");
      var id = $(this).attr("id");
      
      var title = $(this).attr("title");
      
      var data = "sp=16&id="+id+"&t="+table+"&sc="+set_col+"&v="+val+"&c="+col+"&us="+us+"&co="+co+"&desc=Confirmed";
    //  alert(data);
      var url = "/forms/save";
      if(confirm("Are you sure to submit "+title)){
      $.post(url,data,function(res){
     // alert(res);
      alert(title+" submited success");
      location.reload();

      });
      }
      
      })

  
                </script>
<?php } ?>