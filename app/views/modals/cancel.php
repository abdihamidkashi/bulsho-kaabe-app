<!-- MODAL EFFECTS -->
<div class="modal fade"  id="cancel-modal">
			<div class="modal-dialog modal-dialog-centered text-center" role="document">
				<div class="modal-content modal-content-demo">
				    <form action="<?php echo URLROOT;?>/forms/save" method="post" class="ktc-form ktc-form-create">
					<div class="modal-header">
						<h6 class="modal-title">Cancel Record Confirmation</h6>	<button aria-label="Close" class="btn-close" data-bs-dismiss="modal" ><span aria-hidden="true">&times;</span></button>
					</div>
					<div class="modal-body">
					    <p class="text-success">Don't worry!. Canceled Records can be return to its orign </p>
					    <input type="hidden" name="sp" value="494" />
                  <input type="hidden" name="id" value="" id="ktc-cancel-id"/>
			   <input type="hidden" name="t" value="" id="ktc-cancel-t"/>
			   <input type="hidden" name="c" value="" id="ktc-cancel-c"/>
               <input type="hidden" name="st" value="" id="ktc-cancel-status"/>
               
			   <input type="hidden" name="user" value="<?php echo $_SESSION['user_id'];?>"/> 

                              <div class="row clearfix">
                                <div class="col-sm-12">
                                    <div class="form-group form-float">
                                        <label class="form-label">Description</label>
                                        <div class="form-line">
                                            <textarea type="text" class="form-control"  name="description" required placeholder="Why do you delete this record? this note is required & will be recordable"></textarea>
                                            
                                        </div>
                                    </div>
                                </div>
                                <div class="col-sm-12">
                                    <div class="form-group form-float">
                                          <label class="form-label">Password</label>
                                        <div class="form-line">
                                            <input type="password" class="form-control" required  name="password" placeholder="Your password">
                                          
                                        </div>
                                    </div>
                                </div>
                            </div>
      
      
      			   <input type="hidden" name="co" value="<?php echo $_SESSION['co_id'];?>"/> 
					</div>
					<div class="modal-footer">
						 <button type="button" class="btn btn-light" data-bs-dismiss="modal" >Close</button>
						 <button type="submit" class="btn btn-primary">Cancel</button>

					</div>
					</form>
			  <div class="msg-placeholder"></div>

				</div>
			</div>
		</div>
	