<div class="limiter">
		<div class="container-login100" >
			<div class="wrap-login100 p-t-190 p-b-30">
<center style="color: yellow;font-weight:boldl; display:none">Kusoo dhawoow App-ka Bulsho Tech, hal-kan waxaad ka geli kartaa ama ka abuuran kartaa Account gaar ah aad u isticmaasho adeegyada guud ee Bulsho Tech</center>

				<form class="login100-form validate-form" method="POST" action="<?php echo URLROOT;?>/agent/agentSave">
					<div class="login100-form-avatar">
						<img src="<?php echo URLROOT.'/'.$data['company']->logo;?>" alt="AVATAR">
					</div>

					<span class="login100-form-title p-t-15 p-b-30">
						<?php echo  $data['company']->name;?>
					</span>
						<input type="hidden"  name="sp" value = "567"/>
<input type="hidden"  name="co" value = "1"/>

					<div class="wrap-input100 validate-input m-b-10" >
						<input class="input100" type="text" name="name" autocomplete="off"   required  placeholder="Magacaaga oo seddean *">
						<span class="focus-input100"></span>
						<span class="symbol-input100">
							<i class="fa fa-user"></i>
						</span>
					</div>

                    <div class="wrap-input100 validate-input m-b-10" >
						<input class="input100" type="number" name="tell" autocomplete="off" required  placeholder="Taleefankaaga *">
						<span class="focus-input100"></span>
						<span class="symbol-input100">
							<i class="fa fa-phone"></i>
						</span>
					</div>
                    <div class="wrap-input100 validate-input m-b-10" >
						<input class="input100"  type="text" name="address" autocomplete="off" required  placeholder="Deegaanakaaga *">
						<span class="focus-input100"></span>
						<span class="symbol-input100">
							<i class="fa fa-home"></i>
						</span>
					</div>

					<div class="wrap-input100 validate-input m-b-10" data-validate = "Password is required">
						<select class="input100 "  required   name="gender" >
						    <option value="">Dooro Jinsiga *</option>
						    <option value="Lab">Lab</option>
						    <option value="Dhedig">Dhedig</option>
						</select>
						<span class="focus-input100"></span>
						<span class="symbol-input100">
							<i class="fa fa-transgender"></i>
						</span>
					</div>
<div class="wrap-input100 validate-input m-b-10" data-validate = "Password is required">
						<input class="input100 password" type="password" pattern="[0-9]*" inputmode="numeric" autocomplete="off"  name="password" placeholder="Password Sameeyso">
						<span class="focus-input100"></span>
						<span class="symbol-input100">
							<i class="fa fa-lock"></i>
						</span>
					</div>
					<div class="wrap-input100 validate-input m-b-10" data-validate = "Password is required">
						<input class="input100 password" type="password" pattern="[0-9]*" inputmode="numeric" autocomplete="off"   placeholder="Hubi Password">
						<span class="focus-input100"></span>
						<span class="symbol-input100">
							<i class="fa fa-lock"></i>
						</span>
					</div>
					
					<div class="container-login100-form-btn p-t-10">
						<button class="login100-form-btn">
							Diiwaangeli 
						</button>

					</div>

				

				</form>

<hr/>

<center><p style="color:white;">Waan leeyahay account <a  class="" href="<?php echo URLROOT;?>/agent/login"><b> gal </b></a> hadda</p></center>
			</div>
		</div>
	</div>
	
	
