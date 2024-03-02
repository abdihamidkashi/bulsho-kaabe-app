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
							<h3><?php echo $data['company']->name;?>   </h3>
            
             
    <marquee class="d-none">
            <h3>Remaining time   -    &nbsp; &nbsp;    <span id="demo" style="font-size:30px;font-weigt:bold;color:yellow"></span>
    </marquee>
 
						</div>
					</div>
					<div class="container-login100">
						<div class="wrap-login100 p-0">
							<div class="card-body">
								<form class="login100-form validate-form"method="POST" action="<?php echo URLROOT;?>/users/login">

									<span class="login100-form-title">
										Login/الدخول
									</span>
									  <input type="hidden" name="sp" value="28" readonly/>

									<div class="wrap-input100  "  >
										<input class="input100" type="text" name="username" placeholder="Username/اسم االمستخدم" required value="<?php echo @$_COOKIE['username'];?>">
										<span class="focus-input100"></span>
										<span class="symbol-input100">
											<i class="zmdi zmdi-email" aria-hidden="true"></i>
										</span>
									</div>
									<div class="wrap-input100 validate-input" data-bs-validate = "Password is required">
										<input class="input100" type="password" name="password"required value="<?php echo @$_COOKIE['password'];?>" placeholder="Password/كلمه السر">
										<span class="focus-input100"></span>
										<span class="symbol-input100">
											<i class="zmdi zmdi-lock" aria-hidden="true"></i>
										</span>
									</div>
								
									<div class="text-end pt-1">
										<p class="mb-0"><a href="<?php echo URLROOT;?>/users/forgot" class="text-primary ms-1">Forgot Password? <br/>هل نسيت كلمة السر
?</a></p>
									</div>
									<div class="text-first pt-1">
									<input type="checkbox" name="rememberme" id="rememberme" class="filled-in chk-col-pink">
                                        <label for="rememberme">Remember Me <br/>تذكرنى</label>
                                    </div>
									<div class="container-login100-form-btn">
										<button type="submit" class="login100-form-btn btn-primary">
											Login/الدخول
										</button>
									</div>
									<div class="text-center pt-3 d-none">
										<p class="text-dark mb-0">Not a member?<a href="<?php echo URLROOT;?>/users/register" class="text-primary ms-1">Create an Account</a></p>
									</div>
								</form>
								<?php if(isset($data['msg'])){
								   
                                $msg = explode("|", $data['msg'])
                                ?>
                               <div class="alert alert-<?php echo $msg[0];?>">
                                   <?php echo @$msg[1]. " " .  (5 -  $_SESSION['tries2']) . " tries left";?>
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

        
<script>
// Set the date we're counting down to
var countDownDate = new Date("Aug 15, 2022 00:00:00").getTime();

// Update the count down every 1 second
var countdownfunction = setInterval(function() {

  // Get todays date and time
  var now = new Date().getTime();
  
  // Find the distance between now an the count down date
  var distance = countDownDate - now;
  
  // Time calculations for days, hours, minutes and seconds
  var days = Math.floor(distance / (1000 * 60 * 60 * 24));
  var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
  var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
  var seconds = Math.floor((distance % (1000 * 60)) / 1000);
  
  // Output the result in an element with id="demo"
  document.getElementById("demo").innerHTML = days + "days " + hours + "hrs "
  + minutes + "min " + seconds + "sec ";
  
  // If the count down is over, write some text 
  if (distance < 0) {
    clearInterval(countdownfunction);
    document.getElementById("demo").innerHTML = "EXPIRED";
  }
}, 1000);
</script>                        