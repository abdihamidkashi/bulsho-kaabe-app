 <span class="d-none" id="co"><?php echo $_SESSION['co_id'];?></span>
    <span class="d-none" id="us"><?php echo $_SESSION['user_id'];?></span>
                           
                                <?php
                               // print_r($data);
                                foreach($data['row'] as $c => $v) {
                                    $type = explode("~",$c);
                                $label = str_replace("_id","",$type[0]);
                                     if($type[1] == "dropdown"){
                                        ?>
                                
                                <form action="<?php echo URLROOT. '/forms/save' ;?>" method="POST" class="ktc-form ktc-form-create edit-form" enctype="multipart/form-data">
                                    
                                <div class="row">
                                    <div class="col-md-10">
                                    <input name="sp" type="hidden" redonly autocomplete="off"   value="16">
                                     <input type="hidden" value="<?php echo $_POST['id'];?>" name="id"/>
                                    <input type="hidden" value="<?php echo $_POST['t'];?>" name="table"/>
                                    <input type="hidden" value="<?php echo @$type[0];?>" name="set_col"/>
                                          <div class="form-group form-float">
                                              <label class="form-label"><?php echo ucfirst(str_replace('_',' ',$label ));?></label>

                                    <div class="form-line">
                                        <select default="<?php echo $v;?>"  class="form-control show-tick ktc-dropdown form-select ktc-update-btn-show" action="<?php echo $type[2];?>"  name="<?php echo $type[0];?>">
                                        <option value="0">Choose <?php echo $label ;?></option>
                                        
                                    </select>
									
                                    </div>
                                </div>
                                
                                    <input type="hidden" value="<?php echo $_POST['c'];?>" name="col"/>
                	 <input type="hidden" value="<?php echo $_SESSION['user_id'];?>" name="di_resu"/>
                	 	  <input type="hidden" value="<?php echo $_SESSION['co_id'];?>" name="di_oc"/>
                                        
                                        <div class="form-line">
                                      
                                        <input  name="desc<?php echo $type[0];?>" placeholder="Why you Update" required type="text" autocomplete="off"   class="form-control ktc-why-update">
                                         
                                    </div>
                     </div>
                                    <div class="col-md-2">
                                        
                                <label class="form-label">&nbsp;</label><button type="submit" class="btn btn-warning  m-t-15 waves-effect button d-none">Update</button>
                                </div>
                              </div>

                                </form>
                             <div class="ktc-msg-placeholder"></div>
                            

                                        <?php
                                    }else if(@$type[1] == "autocomplete"){
                                ?>
                                 <form action="<?php echo URLROOT. '/forms/save' ;?>" method="POST" class="ktc-form ktc-form-create edit-form" enctype="multipart/form-data">
                                         <div class="row">
                                    <div class="col-md-10">
                                    <input name="sp" type="hidden" redonly autocomplete="off"   value="16">
                                     <input type="hidden" value="<?php echo $_POST['id'];?>" name="id"/>
                                    <input type="hidden" value="<?php echo $_POST['t'];?>" name="table"/>
                                    <input type="hidden" value="<?php echo $c;?>" name="set_col"/>
                                <div class="form-group form-float">
                                    <label class="form-label"><?php echo ucfirst(str_replace('_',' ',$label ));?></label>

                                    <div class="form-line">
                                        <input  type="text" autocomplete="off" action ="<?php echo $type[2];?>"   class="form-control ktc-autocomplete ktc-update-btn-show">
                                        
                                    </div>
                                    <ul class="list-group" style="position: absolute;z-index:999 !important; width:90%">
                                    </ul>
                                    <input type="hidden"  name="<?php echo $type[0];?>" value="" class="ktc-autocomplete-id"/>
                                    

                                </div>
                                                             <input type="hidden" value="<?php echo $_POST['c'];?>" name="col"/>
	 <input type="hidden" value="<?php echo $_SESSION['user_id'];?>" name="di_resu"/>
	 	  <input type="hidden" value="<?php echo $_SESSION['co_id'];?>" name="di_oc"/>
  
                                <div class="form-line">
                                      
                                        <input  name="desc<?php echo $type[0];?>" placeholder="Why you Update" required type="text" autocomplete="off"   class="form-control ktc-why-update">
                                         
                                    </div>
                            </div>
                                    <div class="col-md-2">
                                <label class="form-label">&nbsp;</label><button type="submit" class="btn btn-warning  m-t-15 waves-effect button d-none">Update</button>
                                </div>
                                </div>
                            </form>
                                                        <div class="ktc-msg-placeholder"></div>

                                <?php 
                                        
                                    }else if(@$type[1] == "radio"){
                                ?>
                                  <form action="<?php echo URLROOT. '/forms/save' ;?>" method="POST" class="ktc-form ktc-form-create edit-form" enctype="multipart/form-data">
                                          <div class="row">
                                    <div class="col-md-10">
                                    <input name="sp" type="hidden" redonly autocomplete="off"   value="16">
                                     <input type="hidden" value="<?php echo $_POST['id'];?>" name="id"/>
                                    <input type="hidden" value="<?php echo $_POST['t'];?>" name="table"/>
                                    <input type="hidden" value="<?php echo $c;?>" name="set_col"/>
                                <div class="form-group form-float">
                                    <label class="form-label"><?php echo ucfirst(str_replace('_',' ',$type[0]));?></label>
                              
                                    <div class="form-line ktc-radio " action="<?php echo $type[2];?>" id="<?php echo $type[0];?>" >
                                         
                              
                                
                                    </div>
                                  

                                </div>
                                                                    <input type="hidden" value="<?php echo $_POST['c'];?>" name="col"/>
	 <input type="hidden" value="<?php echo $_SESSION['user_id'];?>" name="di_resu"/>
	 	  <input type="hidden" value="<?php echo $_SESSION['co_id'];?>" name="di_oc"/>

                                <div class="form-line">
                                      
                                        <input  name="desc<?php echo $type[0];?>" placeholder="Why you Update" required type="text" autocomplete="off"   class="form-control ktc-why-update">
                                         
                                    </div>
                           </div>
                                    <div class="col-md-2">
                                <label class="form-label">&nbsp;</label><button type="submit" class="btn btn-warning  m-t-15 waves-effect button d-none">Update</button>
                                </div>
                                </div>
                            </form>
                                                        <div class="ktc-msg-placeholder"></div>

                                <?php 
                                        
                                    }else if(@$type[1] == "file"){
                                ?>
                                  <form action="<?php echo URLROOT. '/forms/save' ;?>" method="POST" class="ktc-form ktc-form-create edit-form" enctype="multipart/form-data">
                                          <div class="row">
                                    <div class="col-md-10">
                                    <input name="sp" type="hidden" redonly autocomplete="off"   value="16">
                                     <input type="hidden" value="<?php echo $_POST['id'];?>" name="id"/>
                                    <input type="hidden" value="<?php echo $_POST['t'];?>" name="table"/>
                                    <input type="hidden" value="<?php echo $type[0];?>" name="set_col"/>
                                <div class="form-group form-float">
                                    <label class="form-label"><?php echo ucfirst(str_replace('_',' ',$type[0]));?></label>
                                
                                    <!-- notify the post loop to break and upload this image -->
		                            <input type="text"  value="<?php echo $type[0];?>" name="_next_upload_<?php echo $input->parametetype[0];?> " class="hide"/>

                                    <div class="form-line">
                                        <input  name="<?php echo $type[0];?>" type="file" autocomplete="off"   class="form-control ktc-update-btn-show">
                                        <label class="form-label"><?php echo $input->placeholder;?></label>
                                       
                                    </div>
                                </div>
                                                                                                <input type="hidden" value="<?php echo $_POST['c'];?>" name="col"/>
	 <input type="hidden" value="<?php echo $_SESSION['user_id'];?>" name="di_resu"/>
	 	  <input type="hidden" value="<?php echo $_SESSION['co_id'];?>" name="di_oc"/>
<div class="form-line">
                                      
                                        <input  name="desc<?php echo $type[0];?>" placeholder="Why you Update" required type="text" autocomplete="off"   class="form-control ktc-why-update">
                                         
                                    </div>
                            </div>
                                    <div class="col-md-2">
                                <label class="form-label">&nbsp;</label><button type="submit" class="btn btn-warning  m-t-15 waves-effect button d-none">Update</button>
                                </div>
                                </div>
                            </form>
                                                        <div class="ktc-msg-placeholder"></div>

                                <?php 
                                        
                                    }else if(@$type[1] == "textarea"){
                                ?>
                                 <form action="<?php echo URLROOT. '/forms/save' ;?>" method="POST" class="ktc-form ktc-form-create edit-form" enctype="multipart/form-data">
                                      <div class="row">
                                    <div class="col-md-10">
                                    <input name="sp" type="hidden" redonly autocomplete="off"   value="16">
                                     <input type="hidden" value="<?php echo $_POST['id'];?>" name="id"/>
                                    <input type="hidden" value="<?php echo $_POST['t'];?>" name="table"/>
                                    <input type="hidden" value="<?php echo $type[0];?>" name="set_col"/>
                                <div class="form-group form-float">
                                    <label class="form-label"><?php echo ucfirst(str_replace('_',' ',$type[0]));?></label>
                            
                                    <div class="form-line">
                                        <textarea value="<?php echo $v;?>"  name="<?php echo $type[0];?>"   class="form-control ktc-update-btn-show"><?php echo $v;?></textarea>
                                        <label class="form-label"><?php echo $input->placeholder;?></label>
                                    </div>
                                </div>
                                                                                                <input type="hidden" value="<?php echo $_POST['c'];?>" name="col"/>
	 <input type="hidden" value="<?php echo $_SESSION['user_id'];?>" name="di_resu"/>
	 	  <input type="hidden" value="<?php echo $_SESSION['co_id'];?>" name="di_oc"/>
  
                                        <div class="form-line">
                                      
                                        <input  name="desc<?php echo $type[0];?>" placeholder="Why you Update" required type="text" autocomplete="off"   class="form-control ktc-why-update">
                                         
                                    </div>
                         </div>
                                    <div class="col-md-2">
                                <label class="form-label">&nbsp;</label><button type="submit" class="btn btn-warning  m-t-15 waves-effect button d-none">Update</button>
                                </div>
                                </div>
                            </form>
                            <div class="ktc-msg-placeholder"></div>

                                <?php 
                                        
                                    }else{
                                ?>
                                 <form action="<?php echo URLROOT. '/forms/save' ;?>" method="POST" class="ktc-form ktc-form-create edit-form" enctype="multipart/form-data">
                                      <div class="row">
                                    <div class="col-md-10">
                                    <input name="sp" type="hidden" redonly autocomplete="off"   value="16">
                                     <input type="hidden" value="<?php echo $_POST['id'];?>" name="id"/>
                                    <input type="hidden" value="<?php echo $_POST['t'];?>" name="table"/>
                                    <input type="hidden" value="<?php echo $type[0];?>" name="set_col"/>
                                <div class="form-group form-float">
                                    <label class="form-label"><?php echo ucfirst(str_replace('_',' ',$type[0]));?></label>
                            
                                    <div class="form-line">
                                        <input value="<?php echo $v;?>"  name="<?php echo $type[0];?>" type="<?php echo empty($type[1]) ?'text' : $type[1];?>"
                                autocomplete="off"   class="form-control ktc-update-btn-show">
                                        <label class="form-label"><?php echo $input->placeholder;?></label>
                                    </div>
                                </div>
                                                                                                <input type="hidden" value="<?php echo $_POST['c'];?>" name="col"/>
	 <input type="hidden" value="<?php echo $_SESSION['user_id'];?>" name="di_resu"/>
	 	  <input type="hidden" value="<?php echo $_SESSION['co_id'];?>" name="di_oc"/>

                                        <div class="form-line">
                                      
                                        <input  name="desc<?php echo $type[0];?>" placeholder="Why you Update" required type="text" autocomplete="off"   class="form-control ktc-why-update">
                                         
                                    </div>
                         </div>
                                    <div class="col-md-2">
                                <label class="form-label">&nbsp;</label><button type="submit" class="btn btn-warning  m-t-15 waves-effect button d-none">Update</button>
                                </div>
                                </div>
                            </form>
                            <div class="ktc-msg-placeholder"></div>

                                <?php 
                                        
                                    }
                                } 
                                ?>
                               

                                
                             
                            
                            <script>
                                 var URLROOT = $("#domain").text();
    var co = $("#co").text();
    var user = $("#us").text();
    
	$('.ktc-why-update').addClass("d-none hide");
	$('.ktc-why-update').attr("required",false);


    $(".edit-form .ktc-dropdown").each(function(){
            
         	
            var action = $(this).attr("action");
            var id= "0";
            var data = "sp=20&action="+action+"&id="+id+"&user="+user+"&co="+co;
                //alert(url);
    var default_value = $(this).attr("default");
              // alert(default_value);
    
    var url = URLROOT+"/forms/options/dropdown/"+default_value;
            
            var select = $(this);
         
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
                            </script>
                        