			<link href="<?php echo URLROOT;?>/plugins/single-page/css/main.css" rel="stylesheet" type="text/css">

	<body>

		<!-- BACKGROUND-IMAGE -->
		<div class="login-img">

			<!-- GLOABAL LOADER -->
			<div id="global-loader">
				<img src="<?php echo URLROOT;?>/images/loader.svg" class="loader-img" alt="Loader">
			</div>
			<!-- /GLOABAL LOADER -->

        <!-- PAGE -->
			<div class="page">
				<div class="">
				    <!-- CONTAINER OPEN -->
					<div class="col col-login mx-auto">
						<div class="text-center text-light fw-bold" style="font-family:'Bahnschrift Condensed'">
					<img src="<?php echo URLROOT.'/'.$data['company']->logo;?>" class=" rounded-circle" style="width:6%" alt="">
							<h3><?php echo $data['company']->name;?></h3>
						</div>
					</div>
					<div class="container-login100">
						<div class="wrap-login100 p-0">
							<div class="card-body">
								<form class="login100-form validate-form"method="POST" action="<?php echo URLROOT;?>/users/forgot">

									<span class="login100-form-title">
										Reset Code request form, please enter your email
									</span>
									   <input type="hidden" name="sp" value="80" readonly />
                    					 <input type="hidden" name="co" value="<?php echo $data['company']->id;?>" readonly/>
                     
									<div class="wrap-input100 validate-input" data-bs-validate = "Valid email is required: ex@abc.xyz">
										<input class="input100" type="text" name="username" placeholder="Email"  value="<?php echo @$_COOKIE['username'];?>">
										<span class="focus-input100"></span>
										<span class="symbol-input100">
											<i class="zmdi zmdi-email" aria-hidden="true"></i>
										</span>
									</div>
									 
									 
									<div class="text-end pt-1">
										<p class="mb-0"><a href="<?php echo URLROOT;?>/users/login" class="text-primary ms-1">Back to Login</a></p>
									</div>
									 
									<div class="container-login100-form-btn">
										<button type="submit" class="login100-form-btn btn-primary">
											Requet Reset Code
										</button>
									</div>
									<div class="text-center pt-3 d-none">
										<p class="text-dark mb-0">Not a member?<a href="<?php echo URLROOT;?>/users/register" class="text-primary ms-1">Create an Account</a></p>
									</div>
			<?php if(isset($data['user']->msg)){
                                $msg = explode("|", $data['user']->msg);
            		
                                ?>
                               <div class="alert alert-<?php echo $msg[0];?>">
                                   <strong><?php echo @$msg[0];?></strong> <?php echo @$msg[1];?>
                                <?php print_r($data);?>
                               </div> 
                               <?php } ?>				
            </form>
								
							</div>
							<div class="card-footer">
								<div class="d-flex justify-content-center my-3">
									<a href="" class="social-login  text-center me-4">
										<i class="fa fa-google"></i>
									</a>
									<a href="" class="social-login  text-center me-4">
										<i class="fa fa-facebook"></i>
									</a>
									<a href="" class="social-login  text-center">
										<i class="fa fa-twitter"></i>
									</a>
								</div>
							</div>
						</div>
					</div>
					<!-- CONTAINER CLOSED -->
				</div>
			</div>
			<!-- End PAGE -->
            </div>
		<!-- BACKGROUND-IMAGE CLOSED -->

