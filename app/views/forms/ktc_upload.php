<?php 
//print_r($data['csv2']);

$post = (array) $data['post'];
?>
<div id="msg-placeholder2"></div>
                <button id="save-all-selected" class="btn btn-info btn-lg ">Save all selected</button>

<div class="table-responsive">
                <table class="table table-bordered table-striped table-hover dataTable js-exportable" id="ktc-datatable" table="<?php echo $post['table_name'];?>" columns="<?php echo $post['columns'];?>">
                    <?php
                    $csv = $data['csv2'];
                    $i=0;
                    $row=1;
                    
                    foreach($csv as $data)
                        {   
                            $i++;
                            
                               if($row == 1){
                                    ?>
                                    <thead>
                                     <tr>
                                    <th><input type="checkbox" checked  class="rp-checkbox"/></th>
                        
                                        <?php
                                        foreach($data as $col => $val){
                                            ?>
                                            <th><?php echo $col;?></th>
                                            <?php
                                        }
                                        foreach($post as $key => $col){
                                           if($key == "sp" || $key == "table_name" || $key == "columns"){
                                                continue;
                                            }
                                             else if((strpos($key, '_next_upload_') !== false)) { continue;
                                                 
                                             }
                                            ?>
                                            <th class="hide"><?php echo $key;?></th>
                                            <?php
                                        }
                                        
                                        ?>
                            </tr> 
                            </thead>
            <tbody>
            <?php
        }
         ?>
             <tr>
          <td><input type="checkbox" checked  class="rp-checkbox"/></td>

                <?php
                foreach($data as $val){
                    ?>
                    <td class="req"><?php echo $val;?></td>
                    <?php
                }
                 foreach($post as  $key => $val){
                      if($key == "sp" || $key == "table_name" || $key == "columns"){
                        continue;
                    }
                     else if((strpos($key, '_next_upload_') !== false)) { continue;
                         
                     }
                    ?>
                    <td class="req hide"><?php echo $val;?></td>
                    <?php
                }
                ?>
            </tr>
            <?php
            $row++;  
        }
       
      
      
    
    
    

?>
</tbody>
            </table>
            </div>
<script>
    $('#ktc-datatable').DataTable({
    aLengthMenu: [
        [ -1],
        [ "All"]
    ]
    
});
</script>

