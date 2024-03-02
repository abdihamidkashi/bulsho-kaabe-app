  <!--app-content open-->
  <style>
                                      .list-group li{
                                          border-bottom: 1px solid #666666 !important;
  }
 
                                  </style>
				<div class="app-content">
					<div class="side-app">
    <span class="d-none" id="co"><?php echo $_SESSION['co_id'];?></span>
    <span class="d-none" id="us"><?php echo $_SESSION['user_id'];?></span>
    <?php 
    $fill  = (array) $data['fill'];
    $visitor  = (array) $data['visitor'];
    //print_r($data);
    ?>
						<!-- PAGE-HEADER -->
						<div class="page-header">
							<div>
								<h1 class="page-title"><?php echo $data['form']->report_title;?></h1>
								<ol class="breadcrumb">
									<li class="breadcrumb-item d-none"><a href="#">Home</a></li>
									<li class="breadcrumb-item active" aria-current="page"> <?php echo $data['form']->title;?></li>
								</ol>
							</div>
							<div class="ms-auto pageheader-btn d-none">
								<a href="#" class="btn btn-primary btn-icon text-white me-2">
									<span>
										<i class="fe fe-plus"></i>
									</span> Add Account
								</a>
								<a href="#" class="btn btn-success btn-icon text-white">
									<span>
										<i class="fe fe-log-in"></i>
									</span> Export
								</a>
							</div>
						</div>
						<!-- PAGE-HEADER END -->

						<!-- ROW-1 -->
						<div class="row">
							<div class="col-lg-12 col-md-12 col-sm-12 col-xl-12">
								<div class="row">
								 <div class="col-lg-3 col-md-3 col-sm-3 col-xl-3">   </div>
								 <div class="col-lg-6 col-md-6 col-sm-6 col-xl-6">
								     <div class="card">
									<div class="card-header">
										<h3 class="card-title"><?php echo $data['form']->report_title;?></h3>
									</div>
									<div class="card-body pb-2">
                             <form action="<?php echo URLROOT. '/' . $data['form']->form_action;?>" method="POST" class="ktc-form ktc-form-create" enctype="multipart/form-data">
                            <input name="sp" type="hidden" redonly autocomplete="off"   value="<?php echo $data['form']->sp;?>">

                                <?php 
                                foreach($data['input'] as $input) {
                                    if($input->type == "hidden" || $input->lable == "hidden"){
                                        ?>
                                        <input name="di_resu" type="hidden" redonly autocomplete="off"   value="<?php echo @$_SESSION['user_id'];?>">
                                        <?php
                                    }else if($input->type == "hidden_u" || $input->lable == "hidden_u"){
                                        ?>
                                        <input name="di_oc" type="hidden" redonly autocomplete="off"   value="<?php echo @$_SESSION['co_id'];?>">
                                        <?php
                                    }else if($input->type == "hidden_ele" || $input->lable == "hidden_ele"){
                                        ?>
                                        <input name="<?php echo $input->parameter;?>" type="hidden" redonly autocomplete="off"   value="<?php echo $input->default_value;?>">
                                        <?php
                                    }else if (array_key_exists($input->type,$visitor)){
                                        ?>
                                        <input name="<?php echo $input->parameter;?>" type="hidden" redonly autocomplete="off"   value="<?php echo $visitor[$input->type];?>">
                                        <?php
                                    }else if($input->type == "dropdown"){
                                        ?>
                                        
                                        <div class="ktc-form-box mb-3 mt-3">
                                <label for="<?php echo $input->parameter;?>" class="form-label"><?php echo $input->lable;?> <span style="color:red"><?php echo (strpos($input->is_required, 'required') !== false) ? '*' : '';?></span></label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fa fa-download"></i></span>
                                    <select <?php echo $input->is_required;?> class="form-control show-tick ktc-dropdown form-select <?php echo $input->aclass;?>" action="<?php echo $input->query;?>" 
                                        load_action="<?php echo $input->load_query;?>"
                                        name="<?php echo $input->parameter;?>"
                                        default="<?php echo !empty($fill[substr($input->parameter, 1)]) ? $fill[substr($input->parameter, 1)] : $input->default_value;?>"
                                        >
                                        <option value=""><?php echo $input->lable;?></option>
                                        
                                    </select>
                                  </div>
                                  </div>
                               
                                    
                                        <?php
                                    }else if($input->type == "autocomplete"){
                                ?>
                                <div class="mb-3 mt-3 ktc-form-box">
                                <label for="<?php echo $input->parameter;?>" class="form-label"><?php echo $input->lable;?> <span style="color:red"><?php echo (strpos($input->is_required, 'required') !== false) ? '*' : '';?></span></label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fa fa-edit"></i></span>
                                   <!--
                                 <input 
                                    <?php echo $input->is_required;?> 
                                    id="<?php echo $input->parameter;?>"
                                    
                                    type="text" autocomplete="off"   
                                        autocomplete="off" action ="<?php echo $input->query;?>"  
                                        class="form-control ktc-autocomplete <?php echo $input->aclass;?>"
                                        
                                        placeholder = "<?php echo $input->placeholder;?>"
                                        >

-->
                                    
                                     <input  type="text" autocomplete="off" action ="<?php echo $input->query;?>"   class="form-control ktc-autocomplete <?php echo $input->aclass;?>"
                                        placeholder="<?php echo $input->lable;?>"  load_action="<?php echo $input->load_query;?>" alt="<?php echo $input->table;?>">
                                      
                                  </div>
                                  
                                  <ul class="list-group" style="position: absolute;z-index:999 !important; width:90%">
                                    </ul>
                                    <input type="hidden" <?php echo $input->is_required;?> name="<?php echo $input->parameter;?>" value="" class="ktc-autocomplete-id hidden-auto"/>
                                  </div>
                               
                                
                                <?php 
                                        
                                    }else if($input->type == "radio"){
                                ?>
                                <div class="form-group form-float">
                                 <label class="form-label"><?php echo $input->lable;?>  <span style="color:red"><?php echo (strpos($input->is_required, 'required') !== false) ? '*' : '';?></span></label>

                                    <div class="form-line ktc-radio " action="<?php echo $input->query;?>" id="<?php echo $input->parameter;?>" >
                                         
                              
                                
                                    </div>
                                  

                                </div>
                                <?php 
                                        
                                    }else if($input->type == "checkbox"){
                                ?>
                                <div class="form-group form-float">
                                 <label class="form-label"><?php echo $input->lable;?>  <span style="color:red"><?php echo (strpos($input->is_required, 'required') !== false) ? '*' : '';?></span></label>

                                    <div class="form-line ktc-radio checkbox checkbox-div" action="<?php echo $input->query;?>" id="<?php echo $input->parameter;?>" >
                                         
                                        <input  type='checkbox' id='rall' class="check-all-checkbox" value=''  /> <label for='rall'>(Check All)</label>
                              
                                
                                    </div>
                                  

                                </div>
                                <?php 
                                        
                                    }else if($input->type == "file"){
                                ?>
                                <div class="mb-3 mt-3">
                                <label for="<?php echo $input->parameter;?>" class="form-label"><?php echo $input->lable;?> <span style="color:red"><?php echo (strpos($input->is_required, 'required') !== false) ? '*' : '';?></span></label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fa fa-upload"></i></span>
                                     <!-- notify the post loop to break and upload this image -->
		                            <input type="text"  value="<?php echo $input->parameter;?>" name="_next_upload_<?php echo $input->parameter;?> " class="d-none"/>
                                    <input 
                                    <?php echo $input->is_required;?> 
                                    name="<?php echo $input->parameter;?>"
                                    id="<?php echo $input->parameter;?>"
                                    
                                    type="file" autocomplete="off"   
                                        class="form-control <?php echo $input->aclass;?>"
                                        value="<?php echo !empty($fill[substr($input->parameter, 1)]) ? $fill[substr($input->parameter, 1)] : ($input->type == 'date' ? date("Y-m-d") : $input->default_value);?>"
                                        placeholder = "<?php echo $input->placeholder;?>"
                                        >
                                  </div>
                                                                          <p><?php echo $input->allowed;?></p>

                                  </div>
                               
                               
                                <?php 
                                        
                                    }else if($input->type == "textarea") {
                                ?>
                                <div class="mb-3 mt-3">
                                <label for="<?php echo $input->parameter;?>" class="form-label"><?php echo $input->lable;?> <span style="color:red"><?php echo (strpos($input->is_required, 'required') !== false) ? '*' : '';?></span></label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fa fa-edit"></i></span>
                                    <textarea 
                                    <?php echo $input->is_required;?> 
                                    name="<?php echo $input->parameter;?>"
                                    id="<?php echo $input->parameter;?>"
                                    
                                  
                                        class="form-control <?php echo $input->aclass;?>"
                                        value="<?php echo !empty($fill[substr($input->parameter, 1)]) ? $fill[substr($input->parameter, 1)] : ($input->type == 'date' ? date("Y-m-d") : $input->default_value);?>"
                                        placeholder = "<?php echo $input->placeholder;?>"
                                        ></textarea>
                                  </div>
                                  </div>
                               
                                <?php 
                                       
                                    }else if($input->type == "textarea2") {
                                ?>
                                <div class="mb-3 mt-3">
                                <label for="editor" class="form-label"><?php echo $input->lable;?> <span style="color:red"><?php echo (strpos($input->is_required, 'required') !== false) ? '*' : '';?></span></label>
                                <div class="input-group nopadding">
                                    <textarea 
                                    <?php echo $input->is_required;?> 
                                    name="<?php echo $input->parameter;?>"
                                    id="editor"
                                    
                                  
                                        class="form-control <?php echo $input->aclass;?>"
                                        value="<?php echo !empty($fill[substr($input->parameter, 1)]) ? $fill[substr($input->parameter, 1)] : ($input->type == 'date' ? date("Y-m-d") : $input->default_value);?>"
                                        placeholder = "<?php echo $input->placeholder;?>"
                                        ></textarea>
                                  </div>
                                  </div>
                             
                             
                                <?php 
                                        
                                    }else{
                                ?>
                                <div class="mb-3 mt-3">
                                <label for="<?php echo $input->parameter;?>" class="form-label"><?php echo $input->lable;?> <span style="color:red"><?php echo (strpos($input->is_required, 'required') !== false) ? '*' : '';?></span></label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fa fa-edit"></i></span>
                                    <input 
                                    <?php echo $input->is_required;?> 
                                    name="<?php echo $input->parameter;?>"
                                    id="<?php echo $input->parameter;?>"
                                    
                                    type="<?php echo $input->type;?>" autocomplete="off"   
                                        class="form-control <?php echo $input->aclass;?>"
                                        value="<?php echo !empty($fill[substr($input->parameter, 1)]) ? $fill[substr($input->parameter, 1)] : ($input->type == 'date' ? date("Y-m-d") : $input->default_value);?>"
                                        placeholder = "<?php echo $input->placeholder;?>"
                                        >
                                  </div>
                                  </div>
                               
                                <?php 
                                        
                                    }
                                } 
                                ?>
                                
                                <br>
                                <div class="row">
                                    <div class="col-md-2">
                                        <button type="reset" class="btn btn-danger m-t-15 waves-effect">Clear</button>
                                    </div>
                                    <div class="col-md-8"></div>
                                    
                                    <div class="col-md-2">
                                <button type="submit" class="btn btn-success m-t-15 waves-effect button"><?php echo $data['form']->btn;?></button>
                                </div>
                                </div>
                            </form>
                            <div class="ktc-msg-placeholder"></div>
                            </div>
                            </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-lg-12 col-md-12 col-sm-12 col-xl-12">
                                  <!-- Lables list only for developers -->
                                
                                
                     
                       <?php if($_SESSION['level'] == "developer"){;?>
                       
                       
                        <a href="#" class="quick-link">Click   here  to Update Form Lables</a>    
<div class="table-responsive quick-label d-none">
    
                <table class="table table-bordered table-striped table-hover " id="">
                    
                <thead>
                    <tr>
                        <?php foreach($data['lbl_columns'] as $col){
                            if($col == "no_footer") continue;
                            $k = explode("~", $col);
                            ?>
                            <th alt="<?php echo $k[2];?>" class="<?php echo $k[1];?>"><?php echo $k[0];?></th>
                            <?php
                        }
                        ?>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach($data['lbl_result'] as $row) { ?>
                    <tr>
                        <?php foreach($row as $col => $val){
                            if($col == "no_footer") continue;

                            $k = explode("~", $col);
                            if($k[1] == "image"){
                               ?>
                            <td class="<?php echo $k[1];?>"><a href="<?php echo URLROOT. '/'.$val;?>" target="_blank"><img src="<?php echo URLROOT. '/'.$val;?>" width="50px"/></a></td>
                            <?php  
                            }elseif(strpos($val, "http") !== false && strpos($val, "<a") === false){
                               ?>
                            <td class="<?php echo $k[1];?>"><a href="<?php echo $val;?>" target="_blank"><?php echo $val;?></a></td>
                            <?php  
                            }else{
                            ?>
                            <td class="<?php echo $k[1];?>" <?php echo $k[2];?>><?php echo $val;?></td>
                            <?php
                            }
                        }
                        ?>
                    </tr>
                    <?php } ?>
                </tbody>
                 <tfoot >
                    <tr class="ktc-footer">
                        <?php foreach($data['columns'] as $col){
                            if($col == "no_footer") continue;
                            $k = explode("~", $col);
                            ?>
                            <th alt="" class="<?php echo $k[1];?>"><?php echo $k[0];?></th>
                            <?php
                        }
                        ?>
                    </tr>
                </tfoot>
            </table>
            </div>
             <?php } ?>                   
                               <!-- lables ends here -->
                       
                                
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            </div>
    