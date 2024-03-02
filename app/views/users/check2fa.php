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
					<img src="<?php echo URLROOT.'/'.$data['company']->logo;?>"  style="width:100px" alt="">
            <br/> <br/>
							<h3><?php echo $data['company']->name;?> <br/> جامعة الصومال</h3>
            
             
    <marquee class="d-none">
            <h3>Remaining time   -    &nbsp; &nbsp;    <span id="demo" style="font-size:30px;font-weigt:bold;color:yellow"></span>
    </marquee>
 
						</div>
					</div>
					<div class="container-login100">
						<div class="wrap-login100 p-0">
							<div class="card-body">
								<form class="login100-form validate-form"method="POST" action="<?php echo URLROOT;?>/users/check2FA">

									<span class="login100-form-title">
										Soo geli Code-ka Mobile-kaaga
									</span>
          

 <input type="hidden" name="sec" value="<?php echo $data['secret'];?>" readonly/>

									<div class="wrap-input100 validate-input" data-bs-validate = "Code is required">
										<input class="input100" type="text" autofocus name="code"required  placeholder="Soo geli code-ka Mobile-kaaga kaaga muuqda">
										<span class="focus-input100"></span>
										<span class="symbol-input100">
											<i class="zmdi zmdi-lock" aria-hidden="true"></i>
										</span>
									</div>
									
									<div class="text-end pt-1 d-none">
										<p class="mb-0"><a href="<?php echo URLROOT;?>/users/forgot" class="text-primary ms-1">Forgot Password? <br/>هل نسيت كلمة السر
?</a></p>
									</div>
									<div class="text-first pt-1 d-none">
									<input type="checkbox" name="rememberme" id="rememberme" class="filled-in chk-col-pink">
                                        <label for="rememberme">Remember Me <br/>تذكرنى</label>
                                    </div>
									<div class="container-login100-form-btn">
										<button type="submit" class="login100-form-btn btn-primary">
											Confirm/أكد
										</button>
									</div>
									<div class="text-center pt-3 d-none">
										<p class="text-dark mb-0">Not a member?<a href="<?php echo URLROOT;?>/users/register" class="text-primary ms-1">Create an Account</a></p>
									</div>
								</form>
								<?php if(isset($data['user']->msg)){
                                $msg = explode("|", $data['user']->msg)
                                ?>
                               <div class="alert alert-<?php echo $msg[0];?>">
                                   <strong><?php echo @$msg[0];?></strong> <?php echo @$msg[1];?>
                               </div> 
                               <?php } ?>
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

        
                       