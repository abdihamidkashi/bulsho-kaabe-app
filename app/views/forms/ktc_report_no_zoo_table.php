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
<div id="msg-placeholder2">
<div class="alert"></div>
</div>

<button id="generate-modal" class="btn btn-primary btn-lg " title="Download as Excel, PDFor Print ">Print/Download</button>
<?php  $dir =  @$_POST['_lang'] == 'AR' || @$_POST['lang_p'] == 'AR' || @$_POST['_language'] == 'AR' ? 'RTL' : 'LTR';?>          

<div class="table-responsive" dir="<?php  echo $dir;?>">
    
                <table class="table table-bordered table-striped table-hover dataTable js-exportable ktc-table" id="ktc-datatable" dir="<?php  echo $dir;?>">
                    
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
									<option value="" >Select One/Empty This peroiod</option>
										 
 
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
                        <?php if( !empty($lastrow)){ ?>
                 <tfoot >
                    <tr class="ktc-footer">
                        <?php 
                       // $footer = !empty($lastrow) ? $lastrow : $data['columns'];
              
                        foreach($lastrow as $col){
                            if($col == "no_footer") continue;
                            $k = explode("~", $col);
                            ?>
                            <th alt="" class="<?php echo $k[1];?>"><?php echo $k[0];?></th>
                            <?php
                        }
                        ?>
                    </tr>
                </tfoot>
                        <?php }else{
                        ?> <tfoot >
                    <tr class="ktc-footer hide d-none">
                        <?php 
                       // $footer = !empty($lastrow) ? $lastrow : $data['columns'];
              
                         
						foreach($columns as $col => $val){
                            if($col == "no_footer") continue;
                            $k = explode("~", $col);
                            ?>
                            <th alt="" class="<?php echo $k[1];?>"></th>
                            <?php
                        }
                        ?>
                    </tr>
                </tfoot>
<?php
                        } ?>
            </table>
            </div>
                <script>
                   var URLROOT = $("#domain").text();
   				 var co = $("#co").text();
   			 var user = $("#us").text();
    
  		  $(".force_dropdown").each(function(){
            
         	
            var action = $(this).attr("action");
            var id= $(this).attr("alt");
            var data = "sp=20&action="+action+"&id="+id+"&user="+user+"&co="+co;
                
    var default_value = $(this).attr("default");
    var url = URLROOT+"/forms/options/dropdown/"+default_value;
     //  alert(url);
          //     alert(data);     
            var select = $(this);
         select.attr("title",url+"/"+data);
         var selected = "";
            $.post(url,data,function(res){
               // alert(res); //ll
            /*
                list = $.parseJSON(res);
     		//	alert(list);
                $.each(list, function(index, value) {
                 var j2a = []; 
              
            for(var i in value) {
            
                j2a.push(value[i]); 
            
                }
                if(default_value == j2a[0]) {
                	selected = "selected";
                }else{
                selected = "";
                }
                
            select.append("<option value='"+j2a[0]+"' "+ selected +" >"+j2a[1]+ "</option>");
                
                });
                */
            select.append(res);
            });
        });
             
      $(".add_time_table").change(function(){
	
	var alt = $(this).attr("alt2").split('|');
	var day = alt[2];
	var peroid = alt[3];
	var user = alt[4];
	var clc = $(this).val();
	
	var data = "sp=410&clc="+clc+"&day="+day+"&peroid="+peroid+"&user="+user+"&share=no_share";
	var url = URLROOT+"/forms/save/";
//alert(data);
	$.post(url, data, function(res){
 ///  alert(res);
    $('#msg-placeholder2').find(".alert").removeClass("alert-success");
    $('#msg-placeholder2').find(".alert").removeClass("alert-danger");
    $('#msg-placeholder2').find(".alert").removeClass("alert-warning");
    
    var r = res.split("|");
    	$('#msg-placeholder2').find(".alert").addClass("alert-"+r[0]);
    	$('#msg-placeholder2').find(".alert").html(r[1]);
    
    });
             
             
	
});
             
                     $("body").delegate(".add_share_time_table","click",function(e){
                     e.preventDefault();
 
	var alt = $(this).attr("alt").split('-');
	var day = alt[1];
	var peroid = alt[2];
	var user = alt[3];
	var clc = alt[0];
	
	var data = "sp=410&clc="+clc+"&day="+day+"&peroid="+peroid+"&user="+user+"&share=share";
	var url = URLROOT+"/forms/save/";
//alert(data);
	$.post(url, data, function(res){
 // alert(res);
    $('#msg-placeholder2').find(".alert").removeClass("alert-success");
    $('#msg-placeholder2').find(".alert").removeClass("alert-danger");
    $('#msg-placeholder2').find(".alert").removeClass("alert-warning");
    
    var r = res.split("|");
    	$('#msg-placeholder2').find(".alert").addClass("alert-"+r[0]);
    	$('#msg-placeholder2').find(".alert").html(r[1]);
    
    });
             
             
	
});
             
                  $(".ktc-autocomplete").keyup(function(){
    
    		var prefix = $(this).val();
    	
     var ul = $(this).closest(".ktc-form-box").find("ul");
    if(prefix == "" || prefix.length < 3){
    	ul.html("");
    return false;
    }
    	ul.html("");
    
    	 var url = URLROOT+"/forms/options/autocomplete";
          
    
    var data = "sp=5&action="+$(this).attr("action")+"&prefix="+prefix+"&co="+co+"&user="+user
                
               // alert(url);
              //  alert(data);
            
           
            $.post(url,data,function(res){
              //  alert(res);
            /*    
            list = $.parseJSON(res);
					
            
                $.each(list, function(index, value) {
                      var j2a = []; 
              
            for(var i in value) {
            
                j2a.push(value[i]); 
            
                }
                    ul.append("<li class='list-group-item ktc-autocomplete-item'  value='"+j2a[0]+"'>"+j2a[1]+"</li>");
                });
            */
            
            ul.html(res);
            });
    	
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
		$("ktc-table tfoot .ktc-footer").find("th").eq(th_index).text((sum/count).toFixed(2)+" %");
	}
	
	
	
	
});

$(".ktc-table tbody tr td.color").each(function(){
    $(this).closest("tr").css("background-color",$(this).text());
});
             
           

$("tbody tr td.customcolor").each(function(){
    
	var td = $.trim($(this).text());

	if(td == 480){
    	$(this).css("background", "red");
    }else if(td > 0){
    	$(this).css("background", "yellow");
    }
});
             
    function popitup(url,windowName) {
       newwindow=window.open(url,windowName,'height=500,width=300');
       if (window.focus) {newwindow.focus()}
       return false;
     }     
             
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
              var refresh = true;
              if($(this).hasClass("no-refresh")){
              refresh = false;
              }
      var url = "/forms/save";
      if(confirm("Are you sure to submit "+title)){
      $.post(url,data,function(res){
     // alert(res);
      alert(title+" submited success");
      if(refresh){
      location.reload();
      }

      });
      }
      
      })

         $(".accept-reject").click(function(e){
      e.preventDefault();
      var table = $(this).attr("table");
      var set_col = $(this).attr("set_col");
      var col = $(this).attr("col");
      var val = $(this).attr("val");
      var co = $(this).attr("co");
      var us = $(this).attr("us");
      var id = $(this).attr("id");
              
              var btn = $(this);
      
      var title = $(this).attr("title");
      
      var data = "sp=16&id="+id+"&t="+table+"&sc="+set_col+"&v="+val+"&c="+col+"&us="+us+"&co="+co+"&desc=Confirmed";
    //  alert(data);
      var url = "/forms/save";
             var accept_reject = "Accept";
             // alert(refresh);
           if($(this).hasClass("reject")){
           accept_reject = "Reject";
           }
      if(confirm("Are you sure to "+accept_reject)){
      $.post(url,data,function(res){
     // alert(res);
      alert(accept_reject+"ed success");
     

      });
      }
      
      })  

    //Exportable table
    $('.js-exportable').DataTable();
                </script>
<?php } ?>