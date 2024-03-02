<!-- LARGE MODAL -->
		<div class="modal fade"  id="report-modal">
			<div class="modal-dialog modal-lg" role="document">
				<div class="modal-content modal-content-demo">
					<div class="modal-header">
						<a href="#" class="btn btn-success btn-sm exportExcel "><i class="fa fa-download"></i> To Excel</a> 
              <a href="#" class="btn btn-primary btn-sm exportCSV "><i class="fa fa-download"></i> To CSV</a> 
 <a href="#" class="btn btn-danger btn-sm print-report"><i class="fa fa-print"></i> Print</a>
						<button aria-label="Close" class="btn-close" data-bs-dismiss="modal" ><span aria-hidden="true">&times;</span></button>
					</div>
					<div class="modal-body" id="printable-area">
           <div id="logo-header">
                      <style>
                        .col-4, .col-sm-4, .col-lg-4, .col-md-4 {
                        	width: 33%;
                        }
                        .col-6, .col-sm-6, .col-lg-6, .col-md-6 {
                        	width: 50%;
                        }
						.col-8, .col-sm-8, .col-lg-8, .col-md-8 {
                        	width: 67%;
                        }
						.col-3, .col-sm-3, .col-lg-3, .col-md-3 {
                        	width: 25%;
                        }
						.col-9, .col-sm-9, .col-lg-9, .col-md-9 {
                        	width: 75%;
                        }
</style>

                       <div class="row">
                        <div class="col-3 col-md-3 col-xs-3 ">
                        <center>
            <img src="<?php echo URLROOT.'/'.$data['company']->logo;?>" style="height:150px !important; width:130px !important;"  alt="<?php echo $data['company']->name;?>"/><br/>
         
       </center>
          
        </div>
         <div class="col-9 col-md-9 col-xs-9"    style="padding:10px !important">
                     <br/>   
               <h1><?php echo $data['company']->name;?></h1>
           </div>
           </div>
                       
           <hr/>
          <!-- <center><h1><?php echo $data['form']->report_title;?></h1></center> -->
            
        
 
 <div id="report-header"  class="row" style="margin-left:20px !important"></div>
                        </div> <!-- logo and header end -->
              <div class="modal-body table-responsive"  >
                 <table  id="reprt-table-modal" class="table table-bordered table-striped" border="1px" width="100%" style="margin-bottom: 10px !important">
                     <thead></thead>
                     <tbody></tbody>
                     <tfoot></tfoot>
                 </table>
              </div>
<style>
.right {text-align: right; padding-right:5px !important;}
.row-3-col > div {
	width: 30% !important;
//border: 1px solid black;
}

div.footer {
   position: fixed;
        text-align: center;
bottom: 0;
        left: 0;
        right: 0;
}
</style>
<div  class="row row-3-col">
     <div id="report-footer" class="col-xs-4 col-md-4"  style="margin-left:20px !important;page-break-inside: avoid;"></div>
  <?php if($data['formname'] == "official-transcript") { ?>
  
  
  
    	<div class="signature col-xs-4 col-md-4" style="margin-left:20px !important;page-break-inside: avoid;">
<br/><br/><br/>
<strong>DVC Academic & Research</strong><br/><br/>

_____________________________

<br/><br/>
<p style="font-style:italic"><?php echo $_SESSION['dv_academic'];?></p> 
</div>
  
  
	<div class="signature col-xs-4 col-md-4" style="margin-left:20px !important;page-break-inside: avoid;">
<br/><br/><br/>
<strong><?php echo $_SESSION['title_description'];?></strong><br/><br/>

_____________________________
<br/><br/>
<p style="font-style:italic"><?php echo $_SESSION['full_name'];?></p> 
</div>
  

  
  
  <?php }else { ?>
  	<div class="signature col-xs-4 col-md-4" style="margin-left:20px !important;page-break-inside: avoid;">
<br/><br/><br/>
<strong><?php echo $_SESSION['title_description'];?></strong><br/><br/>

_____________________________
  <br/><br/>
<p style="font-style:italic"><?php echo $_SESSION['full_name'];?></p> 
</div>
  
  
  <?php } ?>
</div>
   <div class="footer btm-footer">

<div class="inner"><br/><small> <?php echo  $_SESSION['office'] . ", ". $_SESSION['office_address'] ;?> </small></div>
</div>
              
              
              <br>
              </div>
					<div class="modal-footer">
						 <button class="btn btn-light" data-bs-dismiss="modal" >Close</button>
					</div>
				</div>
			</div>
		</div>

	<iframe id="txtArea1" style="display:none"></iframe>	