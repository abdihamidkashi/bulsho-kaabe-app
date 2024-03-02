 <!--app-content open-->
 <style>
 *{
 	font-size: 18px !important;
 }

.rtl {
	direction: rtl;
}
 </style>
				<div class="app-content">
					<div class="side-app">
    <span class="d-none" id="co"><?php echo $_SESSION['co_id'];?></span>
    <span class="d-none" id="us"><?php echo $_SESSION['user_id'];?></span>
    <?php 
    $fill  = (array) $data['fill'];
    $visitor  = (array) $data['visitor'];
   // print_r($data);
    ?>
					<br/>
						<!-- ROW-1 -->
						<div class="row">
							<div class="col-lg-12 col-md-12 col-sm-12 col-xl-12">
							
								     <div class="card">
									<div class="card-header">
										<h3 class="card-title"><?php echo $data['form']->report_title;?> </h3>
									</div>
									<div class="card-body pb-2">
                            <form action="<?php echo URLROOT. '/' . $data['form']->form_action ;?>" method="POST" class="ktc-form ktc-form-report" enctype="multipart/form-data">
                            <input name="ps" type="hidden" redonly autocomplete="off"   value="<?php echo $data['form']->sp;?>">
                            
                             <input name="eman_mrof" type="hidden"  redonly autocomplete="off"   value="<?php echo $data['formname2'];?>">
                    <div class="row clearfix">
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
                                        <input class="<?php echo $input->aclass;?>" name="<?php echo $input->parameter;?>" type="hidden" redonly autocomplete="off"   value="<?php echo $input->default_value;?>">
                                        <?php
                                    }else if (array_key_exists($input->type,$visitor)){
                                        ?>
                                        <input name="<?php echo $input->parameter;?>" type="hidden" redonly autocomplete="off"   value="<?php echo $visitor[$input->type];?>">
                                        <?php
                                    }else if($input->type == "dropdown"){
                                        ?>
                                         <div class="col-lg-1 col-md-1 col-sm-1 col-xs-6 ktc-form-box">

                                          <div class="form-group form-float">

                                    <div class="form-line">
                                        <select default="<?php echo @$_POST[$input->parameter];?>"
                                        <?php echo $input->is_required;?>
                                        class="form-control show-tick ktc-dropdown form-select <?php echo $input->aclass;?>"
                                        action="<?php echo $input->query;?>" 
                                        load_action="<?php echo $input->load_query;?>"
                                        name="<?php echo $input->parameter;?><?php echo strpos($input->aclass, 'multi-select') !== false ? '[]' : '';?>"
                                        alt="<?php echo $input->table;?>"
                                         alt2="<?php echo $input->columns;?>"
                                        <?php echo strpos($input->aclass, 'multi-select') !== false ? 'multiple' : '';?>
                                        >
                                        <option value="%" <?php echo @$_POST[$input->parameter] == '%' ? 'selected' : '';?> selected >All <?php echo $input->lable;?>s</option>
                                        
                                    </select>

                                    </div>
                                </div>
                                </div>
                                      
                                        <?php
                                    }else if($input->type == "autocomplete"){
                                ?>
                                   <div class="col-lg-2 col-md-2 col-sm-2 col-xs-6 ktc-form-box">

                                <div class="form-group form-float">
                                    <div class="form-line">
                                        <input  type="text" autocomplete="off" action ="<?php echo $input->query;?>"   class="form-control ktc-autocomplete <?php echo $input->aclass;?>"
                                        placeholder="<?php echo $input->lable;?>"  load_action="<?php echo $input->load_query;?>" alt="<?php echo $input->table;?>"  alt2="<?php echo $input->columns;?>">
                                      
                                    </div>
                                    <ul class="list-group" style="position: absolute;z-index:999 !important; width:90%">
                                    </ul>
                                    <input type="hidden" name="<?php echo $input->parameter;?>" value="" class="hidden-auto ktc-autocomplete-id"/>
                                    
                                </div>
                                </div>
                                
                                <?php 
                                        
                                    }else if($input->type == "radio"){
                                ?>
                               <div class="col-lg-2 col-md-2 col-sm-2 col-xs-6">

                                <div class="form-group form-float">
                                 <label class="form-label"><?php echo $input->lable;?></label>

                                    <div class="form-line ktc-radio " action="<?php echo $input->query;?>" id="<?php echo $input->parameter;?>" name="<?php echo $input->parameter;?>">
                                         
                              
                                
                                    </div>
                                  
                                </div>
                                </div>
                                <?php 
                                        
                                    }else if($input->type == "checkbox"){
                                ?>
                               <div class="col-lg-2 col-md-2 col-sm-2 col-xs-6">

                                <div class="form-group form-float">
                                 <label class="form-label"><?php echo $input->lable;?></label>

                                    <div class="form-line ktc-radio checkbox checkbox-div" action="<?php echo $input->query;?>" id="<?php echo $input->parameter;?>" name="<?php echo $input->parameter;?>">
                                         
                              
                                
                                    </div>
                                  
                                </div>
                                </div>
                                <?php 
                                        
                                    }else if($input->type == "upload"){
                                ?>
                            <div class="col-lg-2 col-md-2 col-sm-2 col-xs-6">

                                <div class="form-group form-float">
                        
                                    <div class="form-line">
                                         <input type="hidden" name="table_name" value="<?php echo $input->table;?>"/>
        <input type="hidden" name="columns" value="<?php echo $input->columns;?>"/>
                                        <input <?php echo $input->is_required;?> value="<?php echo $input->default_value;?>" name="csv" type="file" autocomplete="off"
                                        accept=".csv" 
                                        class="form-control <?php echo $input->aclass;?>">
                                        <a href="<?php echo URLROOT.'/'. $input->sample;?>" title="Please be care full to upload same format of this sample data"><i class="fa fa-download"></i> Download Sample</a>
                                    </div>
                                </div>
                            </div>
                                <?php 
                                        
                                    }else{
                                ?>
                            <div class="col-lg-2 col-md-2 col-sm-2 col-xs-6">

                                <div class="form-group ">
                                    <div class="form-line">
                                        <input 
                                        <?php echo $input->is_required;?> 
                                        value="<?php echo $input->default_value;?><?php echo $input->parameter == '_from' ? date('Y-m-01') : '';?><?php echo $input->parameter == '_to' ? date('Y-m-d') : '';?>" 
                                        name="<?php echo $input->parameter;?>" type="<?php echo $input->type;?>" autocomplete="off"
                                        class="form-control <?php echo $input->aclass;?>"
                                         alt="<?php echo $input->table;?>"
                                         alt2="<?php echo $input->columns;?>"
                                                                                placeholder="<?php echo $input->lable;?>">

                                       
                                    </div>
                                </div>
                            </div>
                                <?php 
                                        
                                    }
                                } 
                                ?>
                               
                                    <div class="col-lg-2 col-md-2 col-sm-2 col-xs-6">
                                       
                                        <button type="submit" class="btn btn-primary m-l-15 waves-effect button load"><?php echo $data['form']->btn;?></button>
                                    </div>
                                </div>
                            </form>
                            <hr/>
                           
                             <!-- Lables list only for developers -->
                                
                                
                     
                       <?php
                              if($_SESSION['level'] == "developer"){;?>
                       
                       
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
              <div id="report-header2" class="row " style="margin-left:20px !important"></div>                 
            <div id="ktc-report-placeholder">
                       
                       <div style="height: 100%;text-align:center;padding:15%">
                       	Your report shows hear
                       </div>
                       
                        </div>
                              <div id="report-footer2" class="row" style="margin-left:20px !important"></div>                 
                            </div>
                            </div>
                            
                            
            
           
            <?php 
            require_once("../app/views/modals/delete.php");
            require_once("../app/views/modals/edit.php");
            require_once("../app/views/modals/cancel.php");

            require_once("../app/views/modals/report.php");
            
             ?>
                        </div>
                    </div>
                </div>
            </div>
       