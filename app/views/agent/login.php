<div class="limiter">
		<div class="container-login100" >
			<div class="wrap-login100 p-t-190 p-b-30">
<center style="color: yellow;font-weight:boldl; display:none">Kusoo dhawoow App-ka Bulsho Tech, hal-kan waxaad ka geli kartaa ama ka abuuran kartaa Account gaar ah aad u isticmaasho adeegyada guud ee Bulsho Tech</center>

				<form class="login100-form validate-form" method="POST" action="<?php echo URLROOT;?>/agent/checklogin">
					<div class="login100-form-avatar">
						<img src="<?php echo URLROOT.'/'.$data['company']->logo;?>" alt="AVATAR">
					</div>

					<span class="login100-form-title p-t-15 p-b-30">
						<?php echo  $data['company']->name;?>
					</span>
						<input type="hidden"  name="sp" value = "497"/>

					<div class="wrap-input100 validate-input m-b-10" >
						<input class="input100" type="number" name="username" autocomplete="off" required  placeholder="Taleefan -kaaga">
						<span class="focus-input100"></span>
						<span class="symbol-input100">
							<i class="fa fa-user"></i>
						</span>
					</div>

					<div class="wrap-input100 validate-input m-b-10" data-validate = "Password is required">
						<input class="input100 password" type="password" pattern="[0-9]*" inputmode="numeric" autocomplete="off"  name="password" placeholder="Password">
						<span class="focus-input100"></span>
						<span class="symbol-input100">
							<i class="fa fa-lock"></i>
						</span>
					</div>

					<div class="container-login100-form-btn p-t-10">
						<button class="login100-form-btn">
							Login 
						</button>

					</div>

				

				</form>

<hr/>

<center><p style="color:white;">Ma lihi account <a  class="" href="<?php echo URLROOT;?>/agent/regsiter"><b>is diiwanageli</b></a> hadda</p></center>
			</div>
		</div>
	</div>
	
	
