<!-- MODAL EFFECTS -->
<div class="modal fade"  id="contact-modal">
			<div class="modal-dialog modal-dialog-centered text-center" role="document">
				<div class="modal-content modal-content-demo">
				    
					<div class="modal-header">
						<h6 class="modal-title">Bulsho Kaabe - Contacts</h6>	<button type="button" aria-label="Close" class="btn-close" data-bs-dismiss="modal" ><span aria-hidden="true">&times;</span></button>
					</div>
					<div class="modal-body">
					    <p class="text-success">Waxaad nagala soo xiriiri kartaa taleefanadan hoose  </p>
					   <table class="table table-striped table-bordered">
					       <thead>
					       <tr>
					           
					           <th>Call Us</th>
					           <th>Xarunta</th>
					           <th>Whatsapp</th>
					       </tr>
					       </thead>
					  <tbody>
					  <?php
					   $wa_sms = "Asc waxaan kaala soo xiriirayaa App-ka Bulsho Kaabe Health services, waxaan u baahnaa xog ku saabsan adeeg-yada Shirkadda adigoo mahadsan";
					   $tells = array("252634432380" => "Hargeysa");
			            
			            foreach($tells as $k=> $v){
			               ?>
			               <tr>
			                 <td><a href="tel:<?php echo $k;?>"><?php echo $k;?></a></td> 
			                 <td> <?php echo $v;?> </td> 
			                 <td><a href="whatsapp://send?text=<?php echo $wa_sms;?>&phone=<?php echo $k;?>"><i class="fa fa-whatsapp fa-lg"></i> </a></td> 
			               </tr>
			               <?php
			            }
			        ?>
			        </tbody>
			         </table>
				</div>
			</div>
		</div>
	